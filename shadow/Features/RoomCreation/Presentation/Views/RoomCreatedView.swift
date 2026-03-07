//
//  RoomCreatedView.swift
//  shadow
//
//  Created by Frank Erick Santos Gonzales on 7/03/26.
//

import SwiftUI

// Paso 3 — Sala creada: código + huella + compartir

struct RoomCreatedView: View {

    let vm: RoomCreationViewModel
    let onDone: () -> Void

    @State private var codeCopied: Bool = false

    var body: some View {
        VStack(spacing: 0) {

            // ── Top bar ──────────────────────────────────────
            RoomCreationTopBar(
                title: "ROOM CREATED",
            )

            VStack(spacing: 32) {

                // ── Código de sala ───────────────────────────
                VStack(spacing: 12) {
                    Text("SHARE THIS CODE")
                        .textStyle(.monoMicro, family: .jetbrainsRegular)
                        .foregroundStyle(Color.textMuted)

                    // Código grande
                    HStack(spacing: 12) {
                        ForEach(Array(vm.roomCode.enumerated()), id: \.offset) { _, char in
                            Text(String(char))
                                .font(.system(size: 40, weight: .black, design: .monospaced))
                                .foregroundStyle(Color.accentYellow)
                                .frame(width: 60, height: 72)
                                .background(Color.bgSurface)
                                .overlay(Rectangle().stroke(Color.borderDefault, lineWidth: 1))
                        }
                    }

                    // Botones copiar + compartir
                    HStack(spacing: 12) {
                        Button {
                            UIPasteboard.general.string = vm.roomCode
                            withAnimation { codeCopied = true }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation { codeCopied = false }
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: codeCopied ? "checkmark" : "doc.on.doc")
                                Text(codeCopied ? "COPIED" : "COPY CODE")
                                    .textStyle(.labelSmall, family: .syneBold)
                            }
                            .foregroundStyle(codeCopied ? Color.accentCyan : Color.textPrimary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.bgSurface)
                            .overlay(Rectangle().stroke(
                                codeCopied ? Color.accentCyan : Color.borderDefault,
                                lineWidth: 1
                            ))
                        }

                        ShareLink(item: "Join my Shadow room with code: \(vm.roomCode)") {
                            HStack(spacing: 6) {
                                Image(systemName: "square.and.arrow.up")
                                Text("SHARE")
                                    .textStyle(.labelSmall, family: .syneBold)
                            }
                            .foregroundStyle(Color.textPrimary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.bgSurface)
                            .overlay(Rectangle().stroke(Color.borderDefault, lineWidth: 1))
                        }
                    }
                }
                .padding(20)
                .background(Color.bgSurface)
                .overlay(Rectangle().stroke(Color.borderDefault, lineWidth: 1))

                // ── Huella de sala ───────────────────────────
                VStack(spacing: 12) {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color.accentCyan)
                            .frame(width: 6, height: 6)
                        Text("ROOM FINGERPRINT")
                            .textStyle(.monoMicro, family: .jetbrainsRegular)
                            .foregroundStyle(Color.accentCyan)
                        Spacer()
                        Text("VERIFY WITH PARTICIPANTS")
                            .textStyle(.monoMicro, family: .jetbrainsRegular)
                            .foregroundStyle(Color.textMuted)
                    }

                    // 8 emojis en dos filas de 4
                    VStack(spacing: 8) {
                        HStack(spacing: 8) {
                            ForEach(0..<4, id: \.self) { i in
                                if i < vm.roomFingerprint.count {
                                    fingerprintCell(vm.roomFingerprint[i])
                                }
                            }
                        }
                        HStack(spacing: 8) {
                            ForEach(4..<8, id: \.self) { i in
                                if i < vm.roomFingerprint.count {
                                    fingerprintCell(vm.roomFingerprint[i])
                                }
                            }
                        }
                    }

                    Text("All participants must see the same emojis.\nIf they differ, someone may be intercepting.")
                        .textStyle(.monoMicro, family: .jetbrainsRegular)
                        .foregroundStyle(Color.textMuted)
                        .multilineTextAlignment(.center)
                }
                .padding(16)
                .background(Color.bgSurface)
                .overlay(Rectangle().stroke(Color.accentCyan.opacity(0.2), lineWidth: 1))
            }
            .padding(.horizontal, 24)

            Spacer()

            // ── Botón entrar ─────────────────────────────────
            AppButton(
                label: "ENTER ROOM",
                action: onDone,
                layout: .center,
                leadingIcon: "arrow.right"
            )
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
    }

    private func fingerprintCell(_ emoji: String) -> some View {
        Text(emoji)
            .font(.system(size: 22))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(Color.bgElevated)
            .overlay(Rectangle().stroke(Color.borderSubtle, lineWidth: 1))
    }
}

#Preview {
    let vm = RoomCreationViewModel()
    ZStack {
        Color.bgPrimary.ignoresSafeArea()
        RoomCreatedView(vm: vm, onDone: {})
            .onAppear {
                vm.roomCode = "X7KQ"
                vm.roomFingerprint = ["🔐","🛡️","⚡","🌑","🔮","💀","🕷️","🗝️"]
            }
    }
}
