{ pkgs, lib, ... }:
let
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

  attrs.app = attrs.common // {
    buildInputs = with pkgs; [
      # additional non-python dependencies
      #jq
      #difftastic
    ];
  };
  attrs.env = attrs.common // {
    # groups = [ "dev" "test" ];
    editablePackageSources = { "${name}" = attrs.common.projectDir; };
  };

  pyproject = builtins.fromTOML (builtins.readFile attrs.common.pyproject);
  name = pyproject.tool.poetry.name;

  app = pkgs.poetry2nix.mkPoetryApplication attrs.app;
  env = pkgs.poetry2nix.mkPoetryEnv attrs.env;

  interpreter = pkgs.writeShellApplication {
    name = "${name}-python";
    runtimeInputs = [ env ] ++ attrs.app.buildInputs;
    text = ''exec python "$@"'';
  };

  devPkgs = [ env interpreter ];
in
{
  inherit attrs pyproject;
  inherit app env interpreter devPkgs;
  inherit (attrs.common) python;
}
