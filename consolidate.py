#!/usr/bin/env python3
"""Consolidate Dart files from lib/ and critical Android files into JSON format.

Collects:
  - All Dart files under lib/
  - Critical Android configuration files (MainActivity, manifests, gradle configs, etc.)

Output format: JSON array with each file as an object containing "path" and "code" fields.
Code blocks are preserved as multiline strings without escape characters.

Example:
[
    {
        "path": "lib/main.dart",
        "code": "import 'package:flutter/material.dart';\n..."
    },
    {
        "path": "android/app/src/main/AndroidManifest.xml",
        "code": "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n..."
    }
]
"""

from __future__ import annotations

import json
from pathlib import Path


def collect_dart_files(lib_dir: Path) -> list[Path]:
    """Collect all Dart files from lib directory."""
    return sorted(
        path for path in lib_dir.rglob("*.dart") if path.is_file()
    )


def collect_android_files(android_dir: Path) -> list[Path]:
    """Collect important Android configuration and source files."""
    important_patterns = {
        # Kotlin/Java sources
        "**/*.kt",
        "**/*.java",
        # Explicit app package sources
        "app/src/main/kotlin/com/**/*",
        "app/src/main/java/com/**/*",
        # Gradle and configuration
        "**/build.gradle.kts",
        "**/build.gradle",
        "**/settings.gradle.kts",
        "**/settings.gradle",
        "**/gradle.properties",
        "**/gradle-wrapper.properties",
        # Android manifests and configuration
        "**/AndroidManifest.xml",
        "**/*.xml",  # All XML configs
        "**/*.json",
        # Properties and config
        "**/local.properties",
        "**/proguard-rules.pro",
    }
    
    excluded_parts = {"build", ".gradle", "generated", "intermediates", "outputs", "tmp"}
    collected_files = set()
    
    for pattern in important_patterns:
        for file_path in android_dir.glob(pattern):
            if file_path.is_file():
                # Skip build and generated artifacts to keep only user-authored files.
                if not any(part in excluded_parts for part in file_path.parts):
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
    excluded_parts = {"build", ".wrangler", "generated", "intermediates", "outputs", "tmp"}

    collected_files = set()

    for file_path in cloudfare_dir.rglob("*"):
        if file_path.is_file() and file_path.suffix.lower() in allowed_suffixes:
            if file_path.name == "package-lock.json":
                continue
            if not any(part in excluded_parts for part in file_path.parts):
                collected_files.add(file_path)

    return sorted(collected_files)


def main() -> int:
    repo_root = Path(__file__).resolve().parent
    lib_dir = repo_root / "lib"
    android_dir = repo_root / "android"
    cloudfare_dir = repo_root / "cloudfare"
    output_path = repo_root / "consolidated-code.json"

    if not lib_dir.exists():
        raise FileNotFoundError(f"Missing lib directory: {lib_dir}")
    
    if not android_dir.exists():
        raise FileNotFoundError(f"Missing android directory: {android_dir}")

    if not cloudfare_dir.exists():
        raise FileNotFoundError(f"Missing cloudfare directory: {cloudfare_dir}")

    # Collect files
    dart_files = collect_dart_files(lib_dir)
    android_files = collect_android_files(android_dir)
    cloudfare_files = collect_cloudfare_files(cloudfare_dir)
    
    all_files = dart_files + android_files + cloudfare_files
    
    if not all_files:
        print("Warning: No files found to consolidate")
        return 1

    # Generate JSON array output
    file_objects: list[dict] = []
    
    for file_path in all_files:
        try:
            relative_path = file_path.relative_to(repo_root).as_posix()
            content = file_path.read_text(encoding="utf-8")
            
            # Create JSON object with proper multiline code
            json_obj = {
                "path": relative_path,
                "code": content.rstrip()
            }
            
            file_objects.append(json_obj)
            
        except (UnicodeDecodeError, OSError) as e:
            print(f"Warning: Skipped {file_path} ({e})")
            continue

    # Write output as pretty-printed JSON array
    # This preserves multiline code without escape characters
    output_content = json.dumps(
        file_objects, 
        ensure_ascii=False, 
        indent=4
    )
    output_path.write_text(output_content, encoding="utf-8")
    
    dart_count = len(dart_files)
    android_count = len(android_files)
    cloudfare_count = len(cloudfare_files)
    total = len(file_objects)
    
    print(f"✓ Consolidated {total} files:")
    print(f"  • Dart files: {dart_count}")
    print(f"  • Android files: {android_count}")
    print(f"  • Cloudfare files: {cloudfare_count}")

    if android_files:
        kotlin_package_files = [
            path for path in android_files
            if "/kotlin/com/" in path.as_posix()
        ]

        if kotlin_package_files:
            print(f"✓ Kotlin package files included ({len(kotlin_package_files)}):")
            for kotlin_file in kotlin_package_files:
                rel_path = kotlin_file.relative_to(repo_root).as_posix()
                print(f"  • {rel_path}")

        print("✓ Important Android files included:")
        for android_file in android_files:
            rel_path = android_file.relative_to(repo_root).as_posix()
            if android_file.suffix == ".kts":
                print(f"  • {rel_path} (user .kts)")
            elif android_file.suffix == ".json":
                print(f"  • {rel_path} (JSON)")
            else:
                print(f"  • {rel_path}")

    if cloudfare_files:
        print("✓ Cloudfare files included:")
        for cloudfare_file in cloudfare_files:
            rel_path = cloudfare_file.relative_to(repo_root).as_posix()
            print(f"  • {rel_path}")

    print(f"✓ Output: {output_path}")
    print(f"✓ Format: JSON array with multiline code blocks")
    
    return 0


if __name__ == "__main__":
    raise SystemExit(main())