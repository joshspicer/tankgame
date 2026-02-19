#!/usr/bin/env python3
"""
Script to bump the minor version in the Xcode project.
Updates MARKETING_VERSION in project.pbxproj file.
"""

import re
import sys
from pathlib import Path


def parse_version(version_str):
    """Parse a version string like '1.0' into major and minor components."""
    parts = version_str.split('.')
    if len(parts) != 2:
        raise ValueError(f"Invalid version format: {version_str}")
    return int(parts[0]), int(parts[1])


def bump_minor_version(version_str):
    """Bump the minor version number."""
    major, minor = parse_version(version_str)
    return f"{major}.{minor + 1}"


def update_project_version(project_path):
    """Update MARKETING_VERSION in the Xcode project file."""
    project_file = Path(project_path)

    if not project_file.exists():
        print(f"Error: Project file not found at {project_path}")
        sys.exit(1)

    # Read the project file
    with open(project_file, 'r') as f:
        content = f.read()

    # Find all MARKETING_VERSION entries
    pattern = r'MARKETING_VERSION = ([0-9]+\.[0-9]+);'
    matches = re.findall(pattern, content)

    if not matches:
        print("Error: No MARKETING_VERSION found in project file")
        sys.exit(1)

    # Check all versions are the same
    unique_versions = set(matches)
    if len(unique_versions) > 1:
        print(f"Warning: Found multiple different versions: {unique_versions}")
        print("Will update all to match the bumped version of the first one found")

    current_version = matches[0]
    new_version = bump_minor_version(current_version)

    print(f"Current version: {current_version}")
    print(f"New version: {new_version}")

    # Replace all occurrences
    new_content = re.sub(
        pattern,
        f'MARKETING_VERSION = {new_version};',
        content
    )

    # Write back to file
    with open(project_file, 'w') as f:
        f.write(new_content)

    print(f"Successfully updated version from {current_version} to {new_version}")


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python bump_version.py <path/to/project.pbxproj>")
        sys.exit(1)

    project_path = sys.argv[1]
    update_project_version(project_path)
