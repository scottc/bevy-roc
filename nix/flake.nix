{
  description = "Pinned Jackdaw release for roc-bevy (Linux FHS via steam-run-free)";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }: {
    overlays.default = final: prev:
      let
        jackdawVersion = "0.20.0";
        linuxUrl =
          "https://github.com/jbuehler23/jackdaw/releases/download/v${jackdawVersion}/jackdaw-x86_64-unknown-linux-gnu.tar.zst";
        # nix flake prefetch <linuxUrl>
        linuxHash = "sha256-djHeLjTZbFyxjd3XOMx3bodP4ZD/gkZ0aUGqWWI00eY=";

        fhsRun =
          if prev ? steam-run-free then prev.steam-run-free
          else if prev ? steamPackages
            && prev.steamPackages ? steam-fhsenv-without-steam
          then prev.steamPackages.steam-fhsenv-without-steam.run
          else
            throw "nixpkgs missing steam-run-free / steam-fhsenv-without-steam";

        # Full upstream tree at $out so jd can find:
        #   $out/x86_64-unknown-linux-gnu/bin/libjackdaw_sdk.so
        #   $out/bin/jackdaw-rustc-wrapper (after `jd setup`)
        jackdaw-release = prev.stdenv.mkDerivation {
          pname = "jackdaw-release";
          version = jackdawVersion;
          src = prev.fetchurl {
            url = linuxUrl;
            hash = linuxHash;
          };
          nativeBuildInputs = [ prev.zstd prev.gnutar ];
          # Don't strip prebuilt binaries
          dontStrip = true;
          installPhase = ''
            runHook preInstall
            mkdir -p $out
            # tar may unpack flat or with one top-level dir
            if [ -f ./jd ] || [ -d ./x86_64-unknown-linux-gnu ]; then
              cp -a . "$out/"
            else
              top=$(find . -mindepth 1 -maxdepth 1 -type d | head -n1)
              cp -a "$top"/. "$out/"
            fi
            # Ensure $out/bin exists for PATH + future jd setup wrappers
            mkdir -p "$out/bin"
            if [ -x "$out/jd" ]; then
              ln -sf "$out/jd" "$out/bin/jd"
            fi
            if [ -x "$out/jackdaw" ]; then
              ln -sf "$out/jackdaw" "$out/bin/jackdaw"
            fi
            # Some archives already ship bin/
            if [ -x "$out/bin/jd" ] && [ ! -e "$out/jd" ]; then
              ln -sf "$out/bin/jd" "$out/jd"
            fi
            runHook postInstall
          '';
          meta = with prev.lib; {
            description = "Jackdaw ${jackdawVersion} full Linux release tree";
            platforms = [ "x86_64-linux" ];
          };
        };
      in
      {
        inherit jackdaw-release;

        jd = prev.writeShellScriptBin "jd" ''
          # Release root must be the store path (SDK paths are relative to it).
          export JACKDAW_RELEASE_ROOT="${jackdaw-release}"
          exec ${fhsRun}/bin/steam-run ${jackdaw-release}/bin/jd "$@"
        '';

        jackdaw = prev.writeShellScriptBin "jackdaw" ''
          export JACKDAW_RELEASE_ROOT="${jackdaw-release}"
          exec ${fhsRun}/bin/steam-run ${jackdaw-release}/bin/jackdaw "$@"
        '';

        steam-run = fhsRun;
      };
  };
}
