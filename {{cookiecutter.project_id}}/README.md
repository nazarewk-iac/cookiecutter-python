# {{cookiecutter.project_id}}

{{cookiecutter.project_short_description}}

## building container image

`nix build '.#container' && podman load -i ./result`
