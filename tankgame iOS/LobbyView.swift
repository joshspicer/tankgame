//
//  LobbyView.swift
//  tankgame iOS
//
//  SwiftUI lobby for multiplayer setup

import SwiftUI
import MultipeerConnectivity

struct LobbyView: View {
    @ObservedObject var viewModel: GameViewModel
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Tank Game")
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(.white)
            
            VStack(spacing: 15) {
                Button(action: { viewModel.hostGame() }) {
                    Text("Host Game")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                Button(action: { viewModel.joinGame() }) {
                    Text("Join Game")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding(.horizontal, 40)
            
            if !viewModel.availablePeers.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Available Players:")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    ForEach(viewModel.availablePeers, id: \.displayName) { peer in
                        Button(action: { viewModel.invitePeer(peer) }) {
                            HStack {
                                Text(peer.displayName)
                                    .foregroundColor(.white)
                                Spacer()
                                Image(systemName: "plus.circle")
                                    .foregroundColor(.green)
                            }
                            .padding()
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(8)
                        }
                    }
                }
                .padding(.horizontal, 40)
            }
            
            if viewModel.isHost {
                Button(action: { Task { await viewModel.startGame() } }) {
                    Text("Start Game")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 40)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.ignoresSafeArea())
    }
}
