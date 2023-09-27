{
  description = "Description for the project";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    #devenv.url = "github:cachix/devenv/latest";
    #devenv.url = "/home/XXX/dev/github.com/cachix/devenv";
    devenv.url = "github:cachix/devenv/main";
    flake-utils.url = "github:numtide/flake-utils";
    mk-shell-bin.url = "github:rrbutani/nix-mk-shell-bin";
    nix2container.url = "github:nlewo/nix2container";
    nix2container.inputs.flake-utils.follows = "flake-utils";
    nix2container.inputs.nixpkgs.follows = "nixpkgs";
  };

  nixConfig = {
    extra-trusted-public-keys = "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=";
    extra-substituters = "https://devenv.cachix.org";
  };

  outputs = inputs@{ self, nixpkgs, flake-parts, ... }: flake-parts.lib.mkFlake { inherit inputs; } {
    imports = [
      inputs.devenv.flakeModule
    ];

    systems = [
      "x86_64-linux"
      "x86_64-darwin"
      "aarch64-linux"
      "aarch64-darwin"
    ];

    flake = {
      # Nixpkgs overlay providing the application
      overlays.default = nixpkgs.lib.composeManyExtensions [ ];
    };

    perSystem = { config, self', inputs', pkgs, system, ... }:
      let
        conf = import ./config.nix { inherit pkgs; };
      in
      {
        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;
          overlays = [
            self.overlays.default
          ];
        };

        packages.default = conf.pkg;

        devenv.shells.default = {
          name = "default";

          languages.python.enable = true;
          languages.python.package = conf.python;
          languages.python.poetry.enable = true;
          languages.python.poetry.install.installRootPackage = true;

          # https://devenv.sh/reference/options/
          packages = with pkgs; [
            black
          ];
        };
        # inspired by https://github.com/NixOS/nix/issues/3803#issuecomment-748612294
        # usage: nix run '.#repl'
        apps.repl = {
          type = "app";
          program = "${pkgs.writeShellScriptBin "repl" ''
              confnix=$(mktemp)
              trap "rm '$confnix' || true" EXIT
              echo "builtins.getFlake (toString "$PWD")" >$confnix
              nix repl "$confnix"
            ''}/bin/repl";
        };
      };
  };
}
