# Crash Reporter Server

Flask-based web service for receiving crash reports from the tankgame app and automatically creating GitHub issues.

## Features

- Receives crash reports via HTTP POST endpoint
- Automatically triggers GitHub Actions workflow to create issues
- Containerized with Docker for easy deployment
- Health check endpoint for monitoring
- Production-ready with Gunicorn

## Setup

### Environment Variables

Required:
- `GITHUB_TOKEN` - GitHub personal access token with `workflow` and `repo` permissions

Optional:
- `GITHUB_REPO` - Repository in format `owner/repo` (default: `joshspicer/tankgame`)
- `PORT` - Port to run the server on (default: `5000`)

### Running with Docker Compose

1. Create a `.env` file with your GitHub token:
```bash
echo "GITHUB_TOKEN=your_github_token_here" > .env
```

2. Start the server:
```bash
docker-compose up -d
```

3. Check the logs:
```bash
docker-compose logs -f
```

4. Stop the server:
```bash
docker-compose down
```

### Running Locally (Development)

1. Install dependencies:
```bash
pip install -r requirements.txt
```

2. Set environment variables:
```bash
export GITHUB_TOKEN="your_github_token_here"
```

3. Run the server:
```bash
python app.py
```

## API Endpoints

### POST /crash

Receives crash reports and triggers GitHub issue creation.

**Request Body:**
```json
{
  "timestamp": "2025-11-23T18:00:00Z",
  "exception_name": "NSGenericException",
  "exception_reason": "Test crash",
  "call_stack": ["0x1234...", "0x5678..."],
  "app_version": "1.0",
  "app_build": "1",
  "os_version": "iOS 18.0",
  "device_model": "iPhone14,2",
  "user_email": "user@example.com"
}
```

**Response (Success):**
```json
{
  "success": true,
  "message": "Crash report submitted successfully"
}
```

**Response (Error):**
```json
{
  "success": false,
  "error": "Error message"
}
```

### GET /health

Health check endpoint.

**Response:**
```json
{
  "status": "healthy",
  "github_token_configured": true
}
```

## Deployment

### Production Deployment

1. Set up the server at `https://tankgame.spicer.dev`
2. Configure environment variables in your hosting environment
3. Use the provided Docker Compose configuration
4. Ensure HTTPS is enabled (handled by reverse proxy/CDN)

### Scaling

The default configuration uses 2 Gunicorn workers. Adjust in the Dockerfile:
```dockerfile
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "4", "--timeout", "30", "app:app"]
```

## Security Considerations

- GitHub token should be stored securely (environment variable, secrets manager)
- Server should run behind HTTPS (reverse proxy with SSL/TLS)
- Consider rate limiting to prevent abuse
- Monitor logs for suspicious activity

## Testing

Test the server locally:

```bash
curl -X POST http://localhost:5000/crash \
  -H "Content-Type: application/json" \
  -d '{
    "timestamp": "2025-11-23T18:00:00Z",
    "exception_name": "TestException",
    "exception_reason": "Testing crash reporting",
    "call_stack": ["frame1", "frame2"],
    "app_version": "1.0",
    "app_build": "1",
    "os_version": "iOS 18.0",
    "device_model": "iPhone14,2"
  }'
```

Check health:
```bash
curl http://localhost:5000/health
```
