//
//  LobbyView.swift
//  tankgame iOS
//
//  Complete rewrite - SwiftUI lobby
//

import SwiftUI

struct LobbyView: View {
    @ObservedObject var viewModel: LobbyViewModel

    var body: some View {
        VStack(spacing: 30) {
            Text("Tank Game")
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(.white)

            if !viewModel.isHosting && !viewModel.isBrowsing {
                // Initial state
                VStack(spacing: 20) {
                    Button(action: { viewModel.hostGame() }) {
                        Text("Host Game")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }

                    Button(action: { viewModel.joinGame() }) {
                        Text("Join Game")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal, 40)

            } else if viewModel.isHosting {
                // Hosting view
                VStack(spacing: 20) {
                    Text("Waiting for players...")
                        .font(.title3)
                        .foregroundColor(.white)

                    Text("Connected: \(viewModel.connectedPeers.count + 1)/6")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.8))

                    if !viewModel.connectedPeers.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(viewModel.connectedPeers) { peer in
                                HStack {
                                    Circle()
                                        .fill(Color.green)
                                        .frame(width: 12, height: 12)
                                    Text(peer.name)
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(10)
                    }

                    Spacer()

                    Button(action: { viewModel.startGame() }) {
                        Text("Start Game")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(viewModel.canStartGame ? Color.orange : Color.gray)
                            .cornerRadius(10)
                    }
                    .disabled(!viewModel.canStartGame)

                    Button(action: { viewModel.cancel() }) {
                        Text("Cancel")
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                .padding(.horizontal, 40)

            } else {
                // Browsing view
                VStack(spacing: 20) {
                    Text("Available Games")
                        .font(.title3)
                        .foregroundColor(.white)

                    if viewModel.availablePeers.isEmpty && viewModel.connectedPeers.isEmpty {
                        Text("Searching...")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.6))
                            .padding()
                    }

                    if !viewModel.connectedPeers.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Connected:")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.6))

                            ForEach(viewModel.connectedPeers) { peer in
                                HStack {
                                    Circle()
                                        .fill(Color.green)
                                        .frame(width: 12, height: 12)
                                    Text(peer.name)
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(10)
                    }

                    if !viewModel.availablePeers.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(viewModel.availablePeers) { peer in
                                Button(action: { viewModel.invitePeer(peer) }) {
                                    HStack {
                                        Circle()
                                            .fill(Color.blue)
                                            .frame(width: 12, height: 12)
                                        Text(peer.name)
                                            .foregroundColor(.white)
                                        Spacer()
                                        Text("Join")
                                            .font(.caption)
                                            .foregroundColor(.blue)
                                    }
                                    .padding()
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(8)
                                }
                            }
                        }
                    }

                    Spacer()

                    Button(action: { viewModel.cancel() }) {
                        Text("Cancel")
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                .padding(.horizontal, 40)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 0.2, green: 0.2, blue: 0.25))
    }
}
