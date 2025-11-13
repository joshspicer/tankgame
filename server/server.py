#!/usr/bin/env python3
"""
Simple WebSocket server for Tank Game internet multiplayer.
Manages lobbies based on passphrases and routes messages between connected clients.

Usage:
    python server.py

The server listens on port 8765 by default.
"""

import asyncio
import hashlib
import json
import logging
from typing import Dict, Set
import websockets
from websockets.server import WebSocketServerProtocol

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

# Store active lobbies: passphrase -> set of connected clients
lobbies: Dict[str, Set[WebSocketServerProtocol]] = {}

def hash_passphrase(passphrase: str) -> str:
    """
    Hash passphrase for logging purposes to avoid logging sensitive data.
    
    Note: This is not for authentication - passphrases are meant to be shared between
    players. We use SHA256 purely for obfuscation in logs, not for security.
    """
    return hashlib.sha256(passphrase.encode()).hexdigest()[:8]

async def handle_client(websocket: WebSocketServerProtocol, path: str):
    """Handle a client connection."""
    passphrase = None
    
    try:
        # Wait for initial join message with passphrase
        initial_msg = await websocket.recv()
        data = json.loads(initial_msg)
        
        if data.get('type') != 'join':
            await websocket.send(json.dumps({'type': 'error', 'message': 'First message must be join'}))
            return
        
        passphrase = data.get('passphrase', '').strip().lower()
        
        if not passphrase:
            await websocket.send(json.dumps({'type': 'error', 'message': 'Passphrase required'}))
            return
        
        # Validate passphrase format (verb-noun)
        if '-' not in passphrase or len(passphrase.split('-')) != 2:
            await websocket.send(json.dumps({'type': 'error', 'message': 'Invalid passphrase format. Use: verb-noun'}))
            return
        
        # Add client to lobby
        if passphrase not in lobbies:
            lobbies[passphrase] = set()
        
        lobby = lobbies[passphrase]
        
        # Check if lobby is full (max 2 players)
        if len(lobby) >= 2:
            await websocket.send(json.dumps({'type': 'error', 'message': 'Lobby is full'}))
            return
        
        lobby.add(websocket)
        logger.info(f"Client joined lobby {hash_passphrase(passphrase)}. Lobby size: {len(lobby)}")
        
        # Send join confirmation
        await websocket.send(json.dumps({
            'type': 'joined',
            'passphrase': passphrase,
            'playersInLobby': len(lobby)
        }))
        
        # If lobby now has 2 players, notify both that game can start
        if len(lobby) == 2:
            for client in lobby:
                await client.send(json.dumps({'type': 'ready', 'message': 'Opponent found!'}))
            logger.info(f"Lobby {hash_passphrase(passphrase)} is ready with 2 players")
        
        # Message routing loop
        async for message in websocket:
            try:
                # Forward message to other client in lobby
                for client in lobby:
                    if client != websocket:
                        await client.send(message)
            except Exception as e:
                logger.error(f"Error forwarding message: {e}")
    
    except websockets.exceptions.ConnectionClosed:
        logger.info(f"Client disconnected from lobby {hash_passphrase(passphrase) if passphrase else 'unknown'}")
    except Exception as e:
        logger.error(f"Error handling client: {e}")
    finally:
        # Clean up: remove client from lobby
        if passphrase and passphrase in lobbies:
            lobby = lobbies[passphrase]
            if websocket in lobby:
                lobby.remove(websocket)
                logger.info(f"Removed client from lobby {hash_passphrase(passphrase)}. Remaining: {len(lobby)}")
                
                # Notify remaining client about disconnection
                for client in list(lobby):  # Convert to list to avoid set mutation during iteration
                    try:
                        await client.send(json.dumps({'type': 'opponentDisconnected'}))
                    except:
                        pass
                
                # Remove empty lobbies
                if len(lobby) == 0:
                    del lobbies[passphrase]
                    logger.info(f"Removed empty lobby {hash_passphrase(passphrase)}")

async def main():
    """Start the WebSocket server."""
    port = 8765
    logger.info(f"Starting Tank Game WebSocket server on port {port}")
    
    async with websockets.serve(handle_client, "0.0.0.0", port):
        logger.info(f"Server ready and listening on ws://0.0.0.0:{port}")
        await asyncio.Future()  # Run forever

if __name__ == "__main__":
    asyncio.run(main())
