{ pkgs, lib, ... }:
{ attrs, env }:
let
  pyproject = builtins.fromTOML (builtins.readFile attrs.common.pyproject);
  poetry.name = pyproject.tool.poetry.name;

  warn = msg: value: lib.warn "configlib.nix: ${msg}" value;

  clean.env.forced = if env ? forced then env.forced else warn "`env.forced` is missing." { };
  clean.env.defaults = if env ? defaults then env.defaults else warn "`env.defaults` is missing." { };
  clean.attrs.common = if attrs ? common then attrs.common else builtins.throw "`attrs.common` is missing!";
  clean.attrs.app = clean.attrs.common // (if attrs ? app then attrs.app else warn "`attrs.app` is missing." { });
  clean.attrs.dev = clean.attrs.common // {
    editablePackageSources."${poetry.name}" = "./";
  } // (if attrs ? dev then attrs.dev else warn "`attrs.dev` is missing." { });

  poetry.app = pkgs.poetry2nix.mkPoetryApplication clean.attrs.app;
  poetry.dev = pkgs.poetry2nix.mkPoetryEnv clean.attrs.dev;

  app = wrapBinaries {
    name = poetry.name;
    paths = [ poetry.app ];
  };
  dev = wrapBinaries {
    name = "dev-${poetry.name}";
    paths = [ poetry.dev ] ++ clean.attrs.app.buildInputs or [ ];
    initScript = ''
      cd "''${DEVENV_ROOT:-"''${BASH_SOURCE[0]%/${poetry.name}/*}/${poetry.name}"}"
    '';
  };

  wrapBinaries = { name, paths, envForced ? clean.env.forced, envDefaults ? clean.env.defaults, initScript ? "" }:
    let
      wrapper =
        let
          drv = pkgs.writeShellApplication {
            name = "${name}-wrapper";
            text =
              let
                bashEnv =
                  let
                    # similar lib.escapeShellArg, but escapes double-quotes instead of single-quotes
                    escapeShellArg = arg: ''"${builtins.replaceStrings [''"'' "$"] [''\"'' "\\$"] (toString arg)}"'';
                    envToBash = name: value: "export ${name}=${escapeShellArg (toString value)}";
                    envToBashDefault = name: value: ''export ${name}="''${${name}:-${escapeShellArg (toString value)}}"'';
                  in
                  lib.concatStringsSep "\n" ((
                    lib.mapAttrsToList envToBash envForced
                  ) ++ (
                    lib.mapAttrsToList envToBashDefault envDefaults
                  ));
              in
              ''
                src="''${BASH_SOURCE[0]}"
                dir="''${BASH_SOURCE[0]%/*}"

                var="${placeholder "out"}"
                # strip /nix/store/
                var="''${var#/nix/store/}"
                # uppercase
                var="''${var^^}"
                # dash to underscore
                var="''${var//"-"/"_"}"
                # prefix
                var="_WRAPPER_ACTIVATED_$var"

                if [ "''${!var:-"no"}" != "yes" ] ; then
                  export "$var"="yes"
                  export PATH="$dir/.wrapped:$PATH"
                  ${bashEnv}
                  ${initScript}
                fi
                exec "$dir/.wrapped/''${src##*/}" "$@"
              '';
          };
        in
        "${drv}/bin/${name}-wrapper";
    in
    pkgs.symlinkJoin {
      name = "${name}-newsymlinks";
      paths = paths;
      postBuild = ''
        mv "$out/bin" "$out/.wrapped"
        mkdir -p "$out/bin"
        mv "$out/.wrapped" "$out/bin/.wrapped"
        for file in "$out/bin/.wrapped"/* ; do
          ln -s "${wrapper}" "$out/bin/''${file##*/}"
        done
      '';
    };
  container = pkgs.nix2container.buildImage {
    name = "localhost/${poetry.name}";
    tag = "latest";
    config.entrypoint = [ "${app}/bin/${poetry.name}" ];
    copyToRoot = pkgs.buildEnv {
      name = "${poetry.name}-container-root";
      paths = [ app ];
      pathsToLink = [ "/bin" ];
    };
    layers = builtins.map
      (deps: pkgs.nix2container.buildLayer { deps = lib.lists.flatten deps; })
      [
        [
          clean.attrs.app.python
          clean.attrs.app.buildInputs
        ]
      ];
  };
in
{
  inherit attrs pyproject poetry;
  inherit app dev container;
  inherit (clean.attrs.common) python;
}
