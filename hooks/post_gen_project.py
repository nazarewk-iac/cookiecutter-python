import json
import subprocess
import time

from pathlib import Path


def cleanup_file(path: Path):
    # cleanup templating artifacts
    if not path.is_file():
        return

    input_lines = path.read_bytes().splitlines()
    changed = False
    output_lines = []
    for line in input_lines:
        # strip trailing whitespace
        if (stripped := line.rstrip()) != line:
            changed = True
            line = stripped

        # skip comment-only lines
        if line.strip() in (b"#", b"//"):
            continue

        # last 3 lines are empty
        # also skips leading empty lines in a file
        if {line, *output_lines[-2:]} == {b""}:
            continue
        output_lines.append(line)

    # make sure file ends with empty line
    if output_lines[-1:] != [b""]:
        output_lines.append(b"")

    changed |= len(input_lines) != len(output_lines)
    if changed:
        path.write_bytes(b"\n".join(output_lines))


def main():
    cc = json.loads("""{{ cookiecutter | tojson(indent=2) }}""")
    cwd = Path.cwd()
    print(f"Running in {cwd}")
    src = cwd / cc["project_slug"]
    if cc["has_cli"] != "y":
        (src / "cli.py").unlink(missing_ok=True)

    for path in cwd.rglob("*"):
        cleanup_file(path)

    subprocess.check_call(["poetry", "lock"])
    time.sleep(0.5)
    subprocess.check_call(["nix", "flake", "lock"])  # fails for whatever reason


main()
