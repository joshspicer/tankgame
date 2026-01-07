#!/usr/bin/env python3
"""
Xcode Project File Updater

This script adds new Swift files from 'tankgame Shared/' to the exception lists
in the Xcode project.pbxproj file for all three targets (iOS, macOS, tvOS).

Usage:
    python3 update_xcode_project.py [--dry-run]

Options:
    --dry-run    Show what would be changed without modifying the file
    --help       Show this help message

The script:
1. Reads the current project.pbxproj file
2. Finds all three exception list sections
3. Adds missing files in alphabetical order
4. Preserves formatting and indentation
5. Creates a backup before modifying
"""

import re
import sys
import os
from pathlib import Path
from typing import List, Set, Tuple

# Files that need to be added to exception lists
NEW_FILES = [
    'GameEngine.swift',
    'GameGrid.swift',
    'NetworkManager.swift',
    'NetworkMessage.swift',
    'Player.swift',
    'Position.swift',
]

def read_project_file() -> str:
    """Read the project.pbxproj file."""
    project_path = Path('tankgame.xcodeproj/project.pbxproj')
    if not project_path.exists():
        raise FileNotFoundError(f"Project file not found: {project_path}")
    return project_path.read_text()

def write_project_file(content: str, dry_run: bool = False) -> None:
    """Write the updated content to project.pbxproj."""
    project_path = Path('tankgame.xcodeproj/project.pbxproj')
    
    if dry_run:
        print("\n" + "="*80)
        print("DRY RUN - Changes that would be made:")
        print("="*80)
        print("\nNew file content would be written to:", project_path)
        return
    
    # Create backup
    backup_path = Path('tankgame.xcodeproj/project.pbxproj.backup')
    project_path.rename(backup_path)
    print(f"✓ Created backup: {backup_path}")
    
    # Write new content
    project_path.write_text(content)
    print(f"✓ Updated: {project_path}")

def extract_exception_section(content: str, target_name: str) -> Tuple[str, int, int]:
    """
    Extract an exception section for a specific target.
    Returns (section_content, start_index, end_index)
    """
    # Pattern to find the exception section
    pattern = rf'(0AEBC8[0-9A-F]{{2}}2EB14C4300890CC1 /\* Exceptions for "tankgame Shared" folder in "tankgame {target_name}" target \*/.*?membershipExceptions = \((.*?)\);)'
    
    match = re.search(pattern, content, re.DOTALL)
    if not match:
        raise ValueError(f"Could not find exception section for {target_name}")
    
    return match.group(0), match.start(), match.end()

def extract_file_list(section: str) -> List[str]:
    """Extract the list of files from an exception section."""
    # Find the membershipExceptions array
    match = re.search(r'membershipExceptions = \((.*?)\);', section, re.DOTALL)
    if not match:
        return []
    
    array_content = match.group(1)
    
    # Extract all .swift files (ignoring .sks and .xcassets)
    files = []
    for line in array_content.split('\n'):
        line = line.strip()
        if line.endswith('.swift,'):
            files.append(line[:-1])  # Remove trailing comma
    
    return files

def add_files_to_list(existing_files: List[str], new_files: List[str]) -> List[str]:
    """
    Add new files to existing list, maintaining alphabetical order.
    Returns the combined list.
    """
    # Combine and sort
    all_files = list(set(existing_files + new_files))
    all_files.sort()
    return all_files

def rebuild_exception_section(section: str, updated_files: List[str]) -> str:
    """Rebuild an exception section with updated file list."""
    # Find the membershipExceptions array
    match = re.search(r'(.*membershipExceptions = \()(.*?)(\);.*)', section, re.DOTALL)
    if not match:
        raise ValueError("Could not parse exception section")
    
    prefix = match.group(1)
    suffix = match.group(3)
    
    # Get the original array content to preserve non-.swift entries
    original_array = match.group(2)
    
    # Extract non-Swift files (like .sks, .xcassets)
    non_swift_files = []
    for line in original_array.split('\n'):
        line = line.strip()
        if line and not line.endswith('.swift,') and line.endswith(','):
            non_swift_files.append(line)
    
    # Rebuild the array with proper formatting
    array_lines = []
    
    # Add non-Swift files first (Actions.sks, Assets.xcassets)
    for entry in non_swift_files:
        array_lines.append(f'\t\t\t\t{entry}')
    
    # Add Swift files
    for filename in updated_files:
        array_lines.append(f'\t\t\t\t{filename},')
    
    new_array = '\n' + '\n'.join(array_lines) + '\n\t\t\t'
    
    return prefix + new_array + suffix

def update_project_file(dry_run: bool = False) -> None:
    """Main function to update the project file."""
    print("Xcode Project File Updater")
    print("=" * 80)
    
    # Read project file
    print("\n1. Reading project.pbxproj...")
    content = read_project_file()
    print("   ✓ File read successfully")
    
    # Process each target
    targets = ['iOS', 'tvOS', 'macOS']
    updated_content = content
    total_added = 0
    
    for target in targets:
        print(f"\n2. Processing {target} target...")
        
        # Extract section
        section, start_idx, end_idx = extract_exception_section(updated_content, target)
        
        # Get existing files
        existing_files = extract_file_list(section)
        print(f"   ✓ Found {len(existing_files)} existing Swift files")
        
        # Determine which files need to be added
        existing_set = set(existing_files)
        files_to_add = [f for f in NEW_FILES if f not in existing_set]
        
        if not files_to_add:
            print(f"   ✓ All files already present for {target}")
            continue
        
        print(f"   ✓ Adding {len(files_to_add)} new files:")
        for f in files_to_add:
            print(f"     - {f}")
        
        # Add new files
        updated_files = add_files_to_list(existing_files, NEW_FILES)
        
        # Rebuild section
        new_section = rebuild_exception_section(section, updated_files)
        
        # Replace in content
        updated_content = updated_content[:start_idx] + new_section + updated_content[end_idx:]
        total_added += len(files_to_add)
    
    # Write results
    print(f"\n3. Writing results...")
    if total_added > 0:
        write_project_file(updated_content, dry_run)
        print(f"\n✓ Successfully added {total_added} file entries to project.pbxproj")
        
        if not dry_run:
            print("\nNext steps:")
            print("1. Open tankgame.xcodeproj in Xcode")
            print("2. Verify the new files appear in the Project Navigator")
            print("3. Build each target to confirm no errors")
            print("\nIf there are issues, restore from backup:")
            print("  cp tankgame.xcodeproj/project.pbxproj.backup tankgame.xcodeproj/project.pbxproj")
    else:
        print("\n✓ No changes needed - all files already present")

def main():
    """Main entry point."""
    # Check for flags
    dry_run = '--dry-run' in sys.argv
    if '--help' in sys.argv or '-h' in sys.argv:
        print(__doc__)
        sys.exit(0)
    
    # Change to script directory
    script_dir = Path(__file__).parent
    os.chdir(script_dir)
    
    try:
        update_project_file(dry_run)
    except FileNotFoundError as e:
        print(f"\n✗ Error: {e}")
        print("\nMake sure you run this script from the tankgame repository root:")
        print("  cd /path/to/tankgame")
        print("  python3 update_xcode_project.py")
        sys.exit(1)
    except Exception as e:
        print(f"\n✗ Error: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)

if __name__ == '__main__':
    main()
