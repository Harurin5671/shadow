//
//  ChatView.swift
//  shadow
//
//  Created by Frank Erick Santos Gonzales on 6/03/26.
//

import SwiftUI

struct ChatView: View {

    let roomCode: String
    @Environment(AppRouter.self) private var router
    @State private var viewModel: ChatViewModel
    
    init(roomCode: String) {
        self.roomCode = roomCode
        self._viewModel = State(initialValue: ChatViewModel(roomCode: roomCode))
    }

    var body: some View {
        ZStack {
            Color.bgPrimary.ignoresSafeArea()

            VStack {
                Text("Room Code: \(roomCode)")
                    .font(.headline)
                    .foregroundStyle(Color.textPrimary)
                    .padding(.top)

                if viewModel.isLoading {
                    Spacer()
                    ProgressView()
                        .tint(.textPrimary)
                    Spacer()
                } else if let error = viewModel.errorMessage {
                    Spacer()
                    Text(error)
                        .foregroundStyle(.red)
                    Spacer()
                } else if viewModel.messages.isEmpty {
                    Spacer()
                    Text("No messages yet...")
                        .foregroundStyle(.gray)
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.messages) { message in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(message.senderAlias)
                                        .font(.caption)
                                        .foregroundStyle(.gray)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    Text(message.encryptedPayload)
                                        .padding()
                                        .background(Color.white.opacity(0.1))
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                        .foregroundStyle(Color.textPrimary)
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.vertical)
                    }
                }
            }
        }
        .onAppear {
            viewModel.onAppear()
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    router.returnToHome()
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(Color.textPrimary)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ChatView(roomCode: "X7KQ")
            .environment(AppRouter())
    }
}
