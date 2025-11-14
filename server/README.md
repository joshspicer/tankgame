# Tank Game Server

Simple WebSocket server for internet multiplayer in Tank Game.

## Setup

1. Install Python 3.7 or higher
2. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

## Running the Server

```bash
python server.py
```

The server will start on port 8765.

## How It Works

1. Players connect to the server using a WebSocket client
2. Upon connection, players send a `join` message with a passphrase (format: `verb-noun`)
3. Players with the same passphrase are matched together in a lobby
4. When 2 players join the same lobby, the game starts
5. All game messages are relayed between the two players in the lobby

## Protocol

### Client -> Server

**Join a lobby:**
```json
{
  "type": "join",
  "passphrase": "jump-rocket"
}
```

**Game messages:**
All game messages (move, shoot, etc.) are forwarded to the opponent as-is.

### Server -> Client

**Join confirmation:**
```json
{
  "type": "joined",
  "passphrase": "jump-rocket",
  "playersInLobby": 1
}
```

**Ready to play:**
```json
{
  "type": "ready",
  "message": "Opponent found!"
}
```

**Error:**
```json
{
  "type": "error",
  "message": "Error description"
}
```

**Opponent disconnected:**
```json
{
  "type": "opponentDisconnected"
}
```

## Deployment

For production use, consider:
- Using a process manager like systemd or supervisor
- Setting up HTTPS/WSS with a reverse proxy (nginx, caddy)
- Adding rate limiting and connection limits
- Implementing authentication if needed
