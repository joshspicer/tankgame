# Internet Multiplayer Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        Tank Game                                │
│                                                                 │
│  ┌──────────────────┐              ┌──────────────────┐        │
│  │   iOS Device 1   │              │   iOS Device 2   │        │
│  │                  │              │                  │        │
│  │  ┌────────────┐  │              │  ┌────────────┐  │        │
│  │  │ Game View  │  │              │  │ Game View  │  │        │
│  │  │ Controller │  │              │  │ Controller │  │        │
│  │  └──────┬─────┘  │              │  └──────┬─────┘  │        │
│  │         │        │              │         │        │        │
│  │  ┌──────▼─────────────┐         │  ┌──────▼─────────────┐   │
│  │  │ InternetMultiplayer│         │  │ InternetMultiplayer│   │
│  │  │     Manager        │         │  │     Manager        │   │
│  │  └──────┬─────────────┘         │  └──────┬─────────────┘   │
│  │         │ WebSocket             │         │ WebSocket       │
│  └─────────┼───────────────────────┘         └─────┼───────────┘
│            │                                       │             │
│            │         ┌─────────────┐              │             │
│            └────────▶│             │◀─────────────┘             │
│                      │  WebSocket  │                            │
│                      │   Server    │                            │
│                      │             │                            │
│                      │  (Python)   │                            │
│                      │             │                            │
│                      │   Port:     │                            │
│                      │    8765     │                            │
│                      │             │                            │
│                      └──────┬──────┘                            │
│                             │                                   │
│                      ┌──────▼──────┐                            │
│                      │   Lobbies   │                            │
│                      │             │                            │
│                      │ "jump-      │                            │
│                      │  rocket"    │                            │
│                      │  [P1, P2]   │                            │
│                      │             │                            │
│                      │ "laser-     │                            │
│                      │  dragon"    │                            │
│                      │  [P1, P2]   │                            │
│                      └─────────────┘                            │
└─────────────────────────────────────────────────────────────────┘
```

## Message Flow

### Connection Phase
```
Device 1                    Server                    Device 2
   │                           │                           │
   │──{join:"jump-rocket"}────▶│                           │
   │◀───{joined, players:1}────│                           │
   │                           │◀──{join:"jump-rocket"}────│
   │                           │───{joined, players:2}────▶│
   │◀──────{ready}─────────────│                           │
   │                           │───────{ready}────────────▶│
   │                           │                           │
```

### Game Phase
```
Device 1                    Server                    Device 2
   │                           │                           │
   │──{playerMove:...}────────▶│                           │
   │                           │───{playerMove:...}───────▶│
   │                           │                           │
   │                           │◀──{playerShoot:...}───────│
   │◀──{playerShoot:...}───────│                           │
   │                           │                           │
```

## Component Responsibilities

### InternetMultiplayerManager.swift
- Manages WebSocket connection to server
- Sends/receives game messages
- Delegates to GameViewController
- Handles connection errors

### server.py
- Accepts WebSocket connections
- Creates/manages lobbies by passphrase
- Routes messages between lobby members
- Handles disconnections gracefully

### GameViewController.swift
- Presents UI for internet multiplayer
- Gets passphrase from user
- Creates InternetMultiplayerManager
- Routes game events to appropriate manager (local or internet)
- Starts game when both players connected

## Security Features

1. **Passphrase Hashing**: All passphrases are hashed (SHA256) in server logs
2. **No Authentication**: Simple passphrase system for casual play
3. **No Data Storage**: All lobbies are in-memory only
4. **Connection Validation**: Server validates passphrase format

## Scalability

Current implementation:
- In-memory lobbies (restarts clear all data)
- No persistent storage
- Single-threaded async Python

For production:
- Add Redis for lobby persistence
- Use load balancer for multiple server instances
- Add authentication/user accounts
- Rate limiting and abuse prevention
- WSS (WebSocket Secure) instead of WS
