# cookiecutter-python

Cookiecutter template for a Python lib/script

inspired by https://github.com/audreyfeldroy/cookiecutter-pypackage

## Usage

from repo checkout:

```shell
cookiecutter --no-input gh:nazarewk-iac/cookiecutter-python project_name=crowdstrike-falcon-installer project_short_description='Helps with installing CrowdStrike' has_{cli,scripting,http}=y
```

from local checkout:

```shell
cookiecutter --no-input ~/dev/github.com/nazarewk-iac/cookiecutter-python project_name=crowdstrike-falcon-installer project_short_description='Helps with installing CrowdStrike' has_{cli,scripting,http}=y
```