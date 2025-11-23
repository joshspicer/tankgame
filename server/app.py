#!/usr/bin/env python3
"""
Flask server for receiving crash reports and automatically creating GitHub issues.

This server receives crash reports from the tankgame app and directly
creates GitHub issues with the crash details.
"""

from flask import Flask, request, jsonify
import os
import requests
import json
import logging

app = Flask(__name__)

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Configuration
GITHUB_TOKEN = os.environ.get('GITHUB_TOKEN')
GITHUB_REPO = os.environ.get('GITHUB_REPO', 'joshspicer/tankgame')


def create_github_issue(crash_data, user_email=None):
    """
    Create a GitHub issue directly for the crash report.
    
    Args:
        crash_data: Dictionary containing crash report data
        user_email: Optional email of the user reporting the crash
    
    Returns:
        Tuple of (success: bool, message: str)
    """
    if not GITHUB_TOKEN:
        return False, "GITHUB_TOKEN not configured"
    
    # Validate GITHUB_REPO format
    if not GITHUB_REPO or '/' not in GITHUB_REPO:
        return False, "GITHUB_REPO must be in format 'owner/repo'"
    
    parts = GITHUB_REPO.split('/')
    if len(parts) != 2 or not parts[0] or not parts[1]:
        return False, "GITHUB_REPO must be in format 'owner/repo'"
    
    owner, repo_name = parts
    
    # Extract crash information
    exception_name = crash_data.get('exception_name', 'Unknown Exception')
    exception_reason = crash_data.get('exception_reason', 'No reason provided')
    app_version = crash_data.get('app_version', 'Unknown')
    os_version = crash_data.get('os_version', 'Unknown')
    timestamp = crash_data.get('timestamp', 'Unknown')
    call_stack = crash_data.get('call_stack', [])
    
    # Create issue title
    title = f"🐛 Crash: {exception_name}"
    
    # Create issue body
    body = f"""## Crash Report

**Exception:** {exception_name}

**Reason:** {exception_reason}

**App Version:** {app_version}

**OS Version:** {os_version}

**Timestamp:** {timestamp}

### Stack Trace

```json
{json.dumps(crash_data, indent=2)}
```

### Additional Information

{f'**Reported by:** {user_email}' if user_email else 'Reported automatically'}

---

This issue was created automatically by the crash reporting system.
"""
    
    # Create the issue
    issues_url = f"https://api.github.com/repos/{owner}/{repo_name}/issues"
    
    headers = {
        'Accept': 'application/vnd.github+json',
        'Authorization': f'Bearer {GITHUB_TOKEN}',
        'X-GitHub-Api-Version': '2022-11-28'
    }
    
    issue_payload = {
        'title': title,
        'body': body,
        'labels': ['bug', 'crash-report']
    }
    
    try:
        # Create the issue
        response = requests.post(issues_url, headers=headers, json=issue_payload)
        response.raise_for_status()
        issue_data = response.json()
        issue_number = issue_data['number']
        
        logger.info(f"Created issue #{issue_number} for crash: {exception_name}")
        
        # Try to assign to copilot
        try:
            assign_url = f"{issues_url}/{issue_number}/assignees"
            assign_payload = {'assignees': ['copilot']}
            assign_response = requests.post(assign_url, headers=headers, json=assign_payload)
            assign_response.raise_for_status()
            logger.info(f"Assigned issue #{issue_number} to @copilot")
        except requests.exceptions.RequestException as e:
            logger.warning(f"Could not assign to @copilot: {e}")
        
        # Add a comment mentioning copilot
        try:
            comment_url = f"{issues_url}/{issue_number}/comments"
            comment_payload = {'body': '🤖 @copilot please investigate this crash and provide a fix.'}
            comment_response = requests.post(comment_url, headers=headers, json=comment_payload)
            comment_response.raise_for_status()
            logger.info(f"Added comment to issue #{issue_number}")
        except requests.exceptions.RequestException as e:
            logger.warning(f"Could not add comment: {e}")
        
        return True, f"Created issue #{issue_number}"
        
    except requests.exceptions.RequestException as e:
        logger.error(f"Failed to create issue: {e}")
        return False, f"Failed to create issue: {str(e)}"


@app.route('/crash', methods=['POST'])
def receive_crash_report():
    """
    Endpoint to receive crash reports from the app.
    
    Expects JSON payload with crash data.
    """
    try:
        # Get crash data from request
        crash_data = request.get_json()
        
        if not crash_data:
            logger.warning("Received empty crash data")
            return jsonify({
                'success': False,
                'error': 'No crash data provided'
            }), 400
        
        # Log the crash report
        logger.info(f"Received crash report: {crash_data.get('exception_name', 'Unknown')}")
        
        # Extract optional user email if present
        user_email = crash_data.get('user_email')
        
        # Create GitHub issue directly
        success, message = create_github_issue(crash_data, user_email)
        
        if success:
            return jsonify({
                'success': True,
                'message': message
            }), 200
        else:
            return jsonify({
                'success': False,
                'error': message
            }), 500
            
    except Exception as e:
        logger.exception("Error processing crash report")
        return jsonify({
            'success': False,
            'error': f'Internal server error: {str(e)}'
        }), 500


@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint."""
    return jsonify({
        'status': 'healthy',
        'github_token_configured': GITHUB_TOKEN is not None
    }), 200


if __name__ == '__main__':
    # Check configuration on startup
    if not GITHUB_TOKEN:
        logger.warning("GITHUB_TOKEN not configured - crash reporting will not work!")
    
    # Run the app
    port = int(os.environ.get('PORT', 5000))
    app.run(host='0.0.0.0', port=port)
