#!/usr/bin/env python3
"""
Submit crash reports to GitHub Actions workflow.

This script reads crash report JSON files and triggers the crash-report workflow
to create GitHub issues automatically.

Usage:
    python3 submit_crash_report.py <crash_report.json> [user_email]
    
Environment variables:
    GITHUB_TOKEN: GitHub personal access token with workflow permissions
    GITHUB_REPO: Repository in format "owner/repo" (default: joshspicer/tankgame)
"""

import json
import sys
import os
import requests
from typing import Optional


def submit_crash_report(
    crash_report_path: str,
    user_email: Optional[str] = None,
    github_token: Optional[str] = None,
    repo: str = "joshspicer/tankgame"
) -> bool:
    """
    Submit a crash report to GitHub Actions.
    
    Args:
        crash_report_path: Path to the crash report JSON file
        user_email: Optional email of the user reporting the crash
        github_token: GitHub personal access token
        repo: GitHub repository in format "owner/repo"
    
    Returns:
        True if successful, False otherwise
    """
    # Read crash report
    try:
        with open(crash_report_path, 'r') as f:
            crash_data = json.load(f)
    except Exception as e:
        print(f"Error reading crash report: {e}")
        return False
    
    # Get GitHub token
    if github_token is None:
        github_token = os.environ.get('GITHUB_TOKEN')
    
    if not github_token:
        print("Error: GITHUB_TOKEN environment variable not set")
        print("Please set it with: export GITHUB_TOKEN=your_token_here")
        return False
    
    # Prepare workflow dispatch payload
    owner, repo_name = repo.split('/')
    url = f"https://api.github.com/repos/{owner}/{repo_name}/actions/workflows/crash-report.yml/dispatches"
    
    headers = {
        'Accept': 'application/vnd.github+json',
        'Authorization': f'Bearer {github_token}',
        'X-GitHub-Api-Version': '2022-11-28'
    }
    
    payload = {
        'ref': 'main',  # or 'master' depending on your default branch
        'inputs': {
            'crash_data': json.dumps(crash_data),
            'user_email': user_email or ''
        }
    }
    
    # Submit to GitHub
    try:
        response = requests.post(url, headers=headers, json=payload)
        response.raise_for_status()
        print(f"✓ Crash report submitted successfully!")
        print(f"  Check the Actions tab in the repository for processing status.")
        return True
    except requests.exceptions.RequestException as e:
        print(f"Error submitting crash report: {e}")
        if hasattr(e.response, 'text'):
            print(f"Response: {e.response.text}")
        return False


def main():
    """Main entry point."""
    if len(sys.argv) < 2:
        print("Usage: python3 submit_crash_report.py <crash_report.json> [user_email]")
        sys.exit(1)
    
    crash_report_path = sys.argv[1]
    user_email = sys.argv[2] if len(sys.argv) > 2 else None
    
    if not os.path.exists(crash_report_path):
        print(f"Error: File not found: {crash_report_path}")
        sys.exit(1)
    
    repo = os.environ.get('GITHUB_REPO', 'joshspicer/tankgame')
    github_token = os.environ.get('GITHUB_TOKEN')
    
    success = submit_crash_report(crash_report_path, user_email, github_token, repo)
    sys.exit(0 if success else 1)


if __name__ == '__main__':
    main()
