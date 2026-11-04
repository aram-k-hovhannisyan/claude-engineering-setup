"""Read-only STM32 tool discovery. --verify runs only compiler/build versions."""
import argparse
import json
import os
from pathlib import Path
import shutil
import subprocess

TOOLS = {
    "compiler": ("gnu-tools-for-stm32", "arm-none-eabi-gcc.exe"),
    "gdb": ("gnu-gdb-for-stm32", "arm-none-eabi-gdb.exe"),
    "cmake": ("cmake", "cmake.exe"),
    "ninja": ("ninja", "ninja.exe"),
    "programmer": ("programmer", "STM32_Programmer_CLI.exe"),
    "stlink_gdbserver": ("stlink-gdbserver", "ST-LINK_gdbserver.exe"),
}

def discover(bundle_root):
    result = {}
    for label, (bundle, executable) in TOOLS.items():
        paths = set()
        on_path = shutil.which(executable) or shutil.which(executable.removesuffix(".exe"))
        if on_path:
            paths.add(str(Path(on_path).resolve()))
        parent = bundle_root / bundle
        if parent.is_dir():
            for version in parent.iterdir():
                if version.is_dir():
                    paths.update(str(path.resolve()) for path in version.rglob(executable) if path.is_file())
        result[label] = sorted(paths)
    cubemx = shutil.which("STM32CubeMX")
    known = Path(os.environ.get("ProgramFiles", "C:/Program Files")) / "STMicroelectronics/STM32Cube/STM32CubeMX/STM32CubeMX.exe"
    result["cubemx"] = sorted({str(p) for p in (Path(cubemx) if cubemx else None, known) if p and p.is_file()})
    return result

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--bundle-root", type=Path, default=Path(os.environ.get("LOCALAPPDATA", str(Path.home()))) / "stm32cube/bundles")
    parser.add_argument("--verify", action="store_true", help="Run --version only for discovered compiler, CMake and Ninja")
    args = parser.parse_args()
    found = discover(args.bundle_root)
    report = {"bundle_root": str(args.bundle_root), "tools": found,
              "note": "All candidates are listed; choose the project's pinned versions. Hardware is not contacted."}
    failed = False
    if args.verify:
        versions = {}
        for label in ("compiler", "cmake", "ninja"):
            rows = []
            if not found[label]:
                failed = True
            for executable in found[label]:
                try:
                    child = subprocess.run([executable, "--version"], capture_output=True, text=True, timeout=10)
                    lines = (child.stdout or child.stderr).splitlines()
                    row = {"path": executable, "exit_code": child.returncode, "version_line": lines[0][:256] if lines else ""}
                    failed |= child.returncode != 0 or not lines
                except (OSError, subprocess.TimeoutExpired) as error:
                    row = {"path": executable, "error": str(error)[:256]}
                    failed = True
                rows.append(row)
            versions[label] = rows
        report["version_checks"] = versions
    print(json.dumps(report, indent=2))
    return int(failed)

if __name__ == "__main__":
    raise SystemExit(main())
