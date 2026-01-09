import unittest
from unittest import mock

import app


class CreateGithubIssueTests(unittest.TestCase):
    def setUp(self):
        self._original_token = app.GITHUB_TOKEN
        self._original_repo = app.GITHUB_REPO

    def tearDown(self):
        app.GITHUB_TOKEN = self._original_token
        app.GITHUB_REPO = self._original_repo

    def test_missing_token_returns_error(self):
        app.GITHUB_TOKEN = None

        success, message = app.create_github_issue({"exception_name": "Boom"}, None)

        self.assertFalse(success)
        self.assertIn("GITHUB_TOKEN not configured", message)

    def test_invalid_repo_format_returns_error(self):
        app.GITHUB_TOKEN = "token"
        app.GITHUB_REPO = "invalid-format"

        success, message = app.create_github_issue({"exception_name": "Boom"}, None)

        self.assertFalse(success)
        self.assertIn("GITHUB_REPO must be in format", message)

    def test_successful_issue_creation_posts_all_requests(self):
        app.GITHUB_TOKEN = "token"
        app.GITHUB_REPO = "owner/repo"

        crash_data = {
            "exception_name": "TestException",
            "exception_reason": "Something went wrong",
            "app_version": "1.0",
            "os_version": "iOS 18.1",
            "timestamp": "2025-11-23T12:00:00Z",
        }

        call_urls = []

        class DummyResponse:
            def __init__(self, status_code=200, json_body=None):
                self.status_code = status_code
                self._json_body = json_body or {}

            def raise_for_status(self):
                if self.status_code >= 400:
                    raise app.requests.exceptions.HTTPError(f"HTTP {self.status_code}")

            def json(self):
                return self._json_body

        def fake_post(url, headers=None, json=None):
            call_urls.append(url)
            if "comments" in url or "assignees" in url:
                return DummyResponse(201, {})
            return DummyResponse(201, {"number": 123})

        with mock.patch("app.requests.post", side_effect=fake_post):
            success, message = app.create_github_issue(crash_data, user_email="user@example.com")

        self.assertTrue(success)
        self.assertIn("#123", message)
        self.assertEqual(
            call_urls,
            [
                "https://api.github.com/repos/owner/repo/issues",
                "https://api.github.com/repos/owner/repo/issues/123/assignees",
                "https://api.github.com/repos/owner/repo/issues/123/comments",
            ],
        )


class HealthEndpointTests(unittest.TestCase):
    def test_health_endpoint_returns_expected_payload(self):
        client = app.app.test_client()

        response = client.get("/health")

        self.assertEqual(response.status_code, 200)
        payload = response.get_json()
        self.assertEqual(payload["status"], "healthy")
        self.assertIn("github_token_configured", payload)


if __name__ == "__main__":
    unittest.main()
