#!/usr/bin/env python3
"""
Flask server for receiving crash reports and automatically creating GitHub issues.

This server receives crash reports from the tankgame app and automatically
triggers the GitHub Actions workflow to create issues.
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


def trigger_crash_workflow(crash_data, user_email=None):
    """
    Trigger the GitHub Actions workflow to create a crash report issue.
    
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
    url = f"https://api.github.com/repos/{owner}/{repo_name}/actions/workflows/crash-report.yml/dispatches"
    
    headers = {
        'Accept': 'application/vnd.github+json',
        'Authorization': f'Bearer {GITHUB_TOKEN}',
        'X-GitHub-Api-Version': '2022-11-28'
    }
    
    payload = {
        'ref': 'main',
        'inputs': {
            'crash_data': json.dumps(crash_data),
            'user_email': user_email or ''
        }
    }
    
    try:
        response = requests.post(url, headers=headers, json=payload)
        response.raise_for_status()
        logger.info(f"Successfully triggered workflow for crash: {crash_data.get('exception_name', 'Unknown')}")
        return True, "Crash report submitted successfully"
    except requests.exceptions.RequestException as e:
        logger.error(f"Failed to trigger workflow: {e}")
        return False, f"Failed to submit crash report: {str(e)}"


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
        
        # Trigger the GitHub Actions workflow
        success, message = trigger_crash_workflow(crash_data, user_email)
        
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
