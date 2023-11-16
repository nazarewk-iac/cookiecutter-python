{ pkgs, lib, ... }:
let
  pyproject = builtins.fromTOML (builtins.readFile attrs.common.pyproject);
  poetryName = pyproject.tool.poetry.name;

  env.forced = {
    # PLAYWRIGHT_BROWSERS_PATH = "${pkgs.playwright-driver.browsers}";
  };
  env.defaults = {
    # GIT_EXTERNAL_DIFF = "${pkgs.difftastic}/bin/difft"
  };
  attrs.common = {
    python = pkgs."python311";
    projectDir = ./.;
    pyproject = ./pyproject.toml;
    poetrylock = ./poetry.lock;
    overrides = pkgs.poetry2nix.defaultPoetryOverrides.extend (final: prev: {
      # shshsh = prev.shshsh.overridePythonAttrs (old: { buildInputs = (old.buildInputs or [ ]) ++ [ final.poetry ]; });
      # yubikey-manager = prev.yubikey-manager.overridePythonAttrs (old: { buildInputs = (old.buildInputs or [ ]) ++ [ final.poetry ]; });
    });
  };

  attrs.app = {
    propagatedBuildInputs = with pkgs; [
      # additional non-python runtime dependencies
      #jq
      #difftastic
    ];
  };
  attrs.dev = {
    # groups = [ "dev" "test" ];
  };
in
(pkgs.callPackage ./configlib.nix { }) {
  inherit attrs env;
}
