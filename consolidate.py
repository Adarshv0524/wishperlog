#!/usr/bin/env python3
"""Consolidate repo source files into a Claude-friendly Markdown bundle.

Collects (Android-focused):
    - All Dart files under lib/ and test/
    - Android Kotlin/Java/build/config files
    - Cloudfare worker files
    - Firebase Functions files
    - Important root config/documentation files
    - Selected lightweight assets used by the app

Output format:
  - Markdown document with one section per file
  - Each file is wrapped in a fenced code block with a matching language tag
  - A machine-readable JSON manifest is also written for reference
"""

from __future__ import annotations

import json
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path


EXCLUDED_PARTS = {
    "build",
    ".gradle",
    "generated",
    "intermediates",
    "outputs",
    "tmp",
    "node_modules",
    ".dart_tool",
}


@dataclass(frozen=True)
class FileRecord:
    path: Path
    language: str
    code: str


def collect_dart_files(lib_dir: Path) -> list[Path]:
    """Collect all Dart files from lib directory."""
    return sorted(path for path in lib_dir.rglob("*.dart") if path.is_file())


def collect_test_files(test_dir: Path) -> list[Path]:
    """Collect all Dart test files from test directory."""
    if not test_dir.exists():
        return []
    return sorted(path for path in test_dir.rglob("*.dart") if path.is_file())


def collect_android_files(android_dir: Path) -> list[Path]:
    """Collect Android Kotlin, Java, and configuration files."""
    collected_files: set[Path] = set()

    for file_path in android_dir.rglob("*"):
        if not file_path.is_file():
            continue
        if any(part in EXCLUDED_PARTS for part in file_path.parts):
            continue

        suffix = file_path.suffix.lower()
        name = file_path.name.lower()
        if suffix in {".kt", ".java", ".kts", ".gradle", ".xml", ".json", ".properties", ".pro"}:
            collected_files.add(file_path)
        elif name == "androidmanifest.xml" or name == "local.properties":
            collected_files.add(file_path)

    return sorted(collected_files)


def collect_cloudfare_files(cloudfare_dir: Path) -> list[Path]:
    """Collect TypeScript and config files from cloudfare directory."""
    allowed_suffixes = {
        ".ts",
        ".tsx",
        ".js",
        ".jsx",
        ".mjs",
        ".cjs",
        ".json",
        ".toml",
        ".yml",
        ".yaml",
    }
    excluded_parts = EXCLUDED_PARTS | {".wrangler"}

    collected_files = set()

    for file_path in cloudfare_dir.rglob("*"):
        if file_path.is_file() and file_path.suffix.lower() in allowed_suffixes:
            if file_path.name == "package-lock.json":
                continue
            if not any(part in excluded_parts for part in file_path.parts):
                collected_files.add(file_path)

    return sorted(collected_files)


def collect_functions_files(functions_dir: Path) -> list[Path]:
    """Collect Firebase Functions source and config files."""
    if not functions_dir.exists():
        return []

    allowed_suffixes = {
        ".js",
        ".mjs",
        ".cjs",
        ".ts",
        ".tsx",
        ".json",
        ".yaml",
        ".yml",
    }

    collected_files: set[Path] = set()
    for file_path in functions_dir.rglob("*"):
        if not file_path.is_file():
            continue
        if any(part in EXCLUDED_PARTS for part in file_path.parts):
            continue
        if file_path.name == "package-lock.json":
            continue
        if file_path.suffix.lower() in allowed_suffixes:
            collected_files.add(file_path)

    return sorted(collected_files)


def collect_root_files(repo_root: Path) -> list[Path]:
    """Collect important project-level config and docs files."""
    allowed_exact_names = {
        "pubspec.yaml",
        "analysis_options.yaml",
        "devtools_options.yaml",
        "firebase.json",
        "firestore.rules",
        "README.md",
        "ARCHITECTURE.md",
        "issues.md",
        "variables.md",
        "cloudfare-fix.md",
        "documentation (2).md",
    }
    collected: list[Path] = []
    for child in repo_root.iterdir():
        if child.is_file() and child.name in allowed_exact_names:
            collected.append(child)
    return sorted(collected)


def collect_asset_files(assets_dir: Path) -> list[Path]:
    """Collect small, relevant app assets (avoid large binaries)."""
    if not assets_dir.exists():
        return []

    allowed_suffixes = {".svg", ".json", ".txt", ".md"}
    collected_files: set[Path] = set()
    for file_path in assets_dir.rglob("*"):
        if not file_path.is_file():
            continue
        if any(part in EXCLUDED_PARTS for part in file_path.parts):
            continue
        if file_path.suffix.lower() in allowed_suffixes:
            collected_files.add(file_path)

    return sorted(collected_files)


def language_for_path(file_path: Path) -> str:
    """Return a fenced-code language tag for a file path."""
    suffix = file_path.suffix.lower()
    name = file_path.name.lower()

    if name == "androidmanifest.xml" or suffix == ".xml":
        return "xml"
    if suffix == ".dart":
        return "dart"
    if suffix in {".kt", ".kts"}:
        return "kotlin"
    if suffix == ".java":
        return "java"
    if suffix in {".js", ".mjs", ".cjs", ".jsx"}:
        return "javascript"
    if suffix in {".ts", ".tsx"}:
        return "typescript"
    if suffix == ".json":
        return "json"
    if suffix in {".yml", ".yaml"}:
        return "yaml"
    if suffix == ".toml":
        return "toml"
    if suffix == ".svg":
        return "xml"
    if suffix == ".rules":
        return "text"
    if suffix == ".properties":
        return "properties"
    if suffix == ".md":
        return "markdown"
    if suffix == ".gradle":
        return "groovy"
    return "text"


def max_backtick_run(text: str) -> int:
    """Return the longest consecutive backtick run in the text."""
    longest = 0
    current = 0
    for char in text:
        if char == "`":
            current += 1
            longest = max(longest, current)
        else:
            current = 0
    return longest


def fenced_block(language: str, code: str) -> str:
    """Create a safe fenced code block for Markdown output."""
    fence = "`" * max(3, max_backtick_run(code) + 1)
    return f"{fence}{language}\n{code.rstrip()}\n{fence}"


def build_records(file_paths: list[Path], repo_root: Path) -> list[FileRecord]:
    """Read files and convert them into structured records."""
    records: list[FileRecord] = []

    for file_path in file_paths:
        try:
            relative_path = file_path.relative_to(repo_root)
            content = file_path.read_text(encoding="utf-8")
            records.append(
                FileRecord(
                    path=relative_path,
                    language=language_for_path(file_path),
                    code=content,
                )
            )
        except (UnicodeDecodeError, OSError) as error:
            print(f"Warning: Skipped {file_path} ({error})")

    return records


def render_markdown(records: list[FileRecord], counts: dict[str, int]) -> str:
    """Render the bundle as a Claude-friendly Markdown document."""
    now = datetime.now(timezone.utc).isoformat(timespec="seconds")
    lines: list[str] = [
        "# Consolidated Source Bundle",
        "",
        f"Generated: {now}",
        "",
        "## Summary",
        f"- Dart files (lib): {counts['dart']}",
        f"- Dart test files: {counts['test']}",
        f"- Android files: {counts['android']}",
        f"- Cloudfare files: {counts['cloudfare']}",
        f"- Functions files: {counts['functions']}",
        f"- Root config/docs files: {counts['root']}",
        f"- Assets files: {counts['assets']}",
        f"- Total files: {len(records)}",
        "",
        "## File Index",
    ]

    for record in records:
        lines.append(f"- {record.path.as_posix()} ({record.language})")

    lines.extend(["", "## Files"])

    for record in records:
        lines.extend([
            "",
            f"### {record.path.as_posix()}",
            "",
            fenced_block(record.language, record.code),
        ])

    lines.append("")
    return "\n".join(lines)


def render_json(records: list[FileRecord]) -> str:
    """Render a machine-readable JSON manifest."""
    payload = [
        {
            "path": record.path.as_posix(),
            "language": record.language,
            "code": record.code.rstrip(),
        }
        for record in records
    ]
    return json.dumps(payload, ensure_ascii=False, indent=2)


def main() -> int:
    repo_root = Path(__file__).resolve().parent
    lib_dir = repo_root / "lib"
    test_dir = repo_root / "test"
    android_dir = repo_root / "android"
    cloudfare_dir = repo_root / "cloudfare"
    functions_dir = repo_root / "functions"
    assets_dir = repo_root / "assets"
    markdown_output_path = repo_root / "consolidated-code.md"
    json_output_path = repo_root / "consolidated-code.json"

    if not lib_dir.exists():
        raise FileNotFoundError(f"Missing lib directory: {lib_dir}")

    if not android_dir.exists():
        raise FileNotFoundError(f"Missing android directory: {android_dir}")

    if not cloudfare_dir.exists():
        raise FileNotFoundError(f"Missing cloudfare directory: {cloudfare_dir}")

    dart_files = collect_dart_files(lib_dir)
    test_files = collect_test_files(test_dir)
    android_files = collect_android_files(android_dir)
    cloudfare_files = collect_cloudfare_files(cloudfare_dir)
    functions_files = collect_functions_files(functions_dir)
    root_files = collect_root_files(repo_root)
    assets_files = collect_asset_files(assets_dir)

    all_files = sorted(set(
        dart_files
        + test_files
        + android_files
        + cloudfare_files
        + functions_files
        + root_files
        + assets_files
    ))
    if not all_files:
        print("Warning: No files found to consolidate")
        return 1

    records = build_records(all_files, repo_root)
    if not records:
        print("Warning: No readable files found to consolidate")
        return 1

    markdown_output_path.write_text(
        render_markdown(
            records,
            {
                "dart": len(dart_files),
                "test": len(test_files),
                "android": len(android_files),
                "cloudfare": len(cloudfare_files),
                "functions": len(functions_files),
                "root": len(root_files),
                "assets": len(assets_files),
            },
        ),
        encoding="utf-8",
    )
    json_output_path.write_text(render_json(records), encoding="utf-8")

    dart_count = len(dart_files)
    test_count = len(test_files)
    android_count = len(android_files)
    cloudfare_count = len(cloudfare_files)
    functions_count = len(functions_files)
    root_count = len(root_files)
    assets_count = len(assets_files)
    total = len(records)

    print(f"✓ Consolidated {total} files:")
    print(f"  • Dart files (lib): {dart_count}")
    print(f"  • Dart test files: {test_count}")
    print(f"  • Android files: {android_count}")
    print(f"  • Cloudfare files: {cloudfare_count}")
    print(f"  • Functions files: {functions_count}")
    print(f"  • Root config/docs files: {root_count}")
    print(f"  • Assets files: {assets_count}")

    java_files = [path for path in android_files if path.suffix.lower() == ".java"]
    kotlin_files = [path for path in android_files if path.suffix.lower() in {".kt", ".kts"}]

    if java_files:
        print(f"✓ Java files included ({len(java_files)}):")
        for java_file in java_files:
            print(f"  • {java_file.relative_to(repo_root).as_posix()}")

    if kotlin_files:
        print(f"✓ Kotlin files included ({len(kotlin_files)}):")
        for kotlin_file in kotlin_files:
            print(f"  • {kotlin_file.relative_to(repo_root).as_posix()}")

    if android_files:
        print("✓ Important Android files included:")
        for android_file in android_files:
            rel_path = android_file.relative_to(repo_root).as_posix()
            print(f"  • {rel_path}")

    if cloudfare_files:
        print("✓ Cloudfare files included:")
        for cloudfare_file in cloudfare_files:
            rel_path = cloudfare_file.relative_to(repo_root).as_posix()
            print(f"  • {rel_path}")

    if functions_files:
        print("✓ Functions files included:")
        for functions_file in functions_files:
            rel_path = functions_file.relative_to(repo_root).as_posix()
            print(f"  • {rel_path}")

    if root_files:
        print("✓ Root config/docs included:")
        for root_file in root_files:
            rel_path = root_file.relative_to(repo_root).as_posix()
            print(f"  • {rel_path}")

    print(f"✓ Markdown output: {markdown_output_path}")
    print(f"✓ JSON output: {json_output_path}")
    print("✓ Format: Markdown bundle with fenced code blocks, plus JSON manifest")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
