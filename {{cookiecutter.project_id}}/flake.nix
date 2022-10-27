{
  description = "Description for the project";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, flake-parts, ... }: flake-parts.lib.mkFlake { inherit self; } {
    imports = [
    ];

    systems = [
      "x86_64-linux"
      "x86_64-darwin"
      "aarch64-linux"
      "aarch64-darwin"
    ];

    perSystem = { config, self', inputs', pkgs, system, ... }:
      let
        cfg = builtins.fromTOML (builtins.readFile attrs.pyproject);
        name = cfg.tool.poetry.name;
        attrs = {
          python = pkgs."python{{cookiecutter.python_version.replace('.', '')}}";
          projectDir = ./.;
          pyproject = ./pyproject.toml;
          poetrylock = ./poetry.lock;
        };
        pkg = pkgs.poetry2nix.mkPoetryApplication (attrs // { });
        env = pkgs.poetry2nix.mkPoetryEnv (attrs // {
          editablePackageSources = { "${name}" = attrs.projectDir; };
        });
      in
      {
        packages.default = pkg;
        devShells = {
          default = pkgs.mkShellNoCC {
            packages = with pkgs; [
              env
              poetry
            ];
          };
        };
        # see https://github.com/NixOS/nix/issues/3803#issuecomment-748612294
        # usage: nix run '.#repl'
        apps.repl = {
          type = "app";
          program = "${pkgs.writeShellScriptBin "repl" ''
                confnix=$(mktemp)
                echo "builtins.getFlake (toString $(git rev-parse --show-toplevel))" >$confnix
                trap "rm $confnix" EXIT
                nix repl $confnix
              ''}/bin/repl";
        };
      };
    flake = {
    };
  };
}
