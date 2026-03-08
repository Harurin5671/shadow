//
//  RoomJoinView.swift
//  shadow
//
//  Created by Frank Erick Santos Gonzales on 6/03/26.
//

import SwiftUI

struct RoomJoinView: View {

    @Environment(AppRouter.self) private var router
    @State private var vm = RoomJoinViewModel()

    var body: some View {
        ZStack {
            Color.bgPrimary.ignoresSafeArea()

            VStack(spacing: 0) {

                // ── Header ───────────────────────────────────
                HStack {
                    Button { router.goBack() } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundStyle(Color.textPrimary)
                            .frame(width: 40, height: 40)
                    }
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 20)

                // ── Contenido ────────────────────────────────
                ScrollView {
                    VStack(alignment: .leading, spacing: 32) {

                        // Título
                        VStack(alignment: .leading, spacing: 16) {
                            Text("JOIN\nROOM")
                                .textStyle(.displayHero, family: .syneBold)
                                .foregroundStyle(Color.textPrimary)

                            Rectangle()
                                .fill(Color.accentYellow)
                                .frame(width: 96, height: 4)
                        }

                        // Código OTP
                        VStack(alignment: .leading, spacing: 12) {
                            Text("ACCESS CODE")
                                .textStyle(.monoMicro, family: .jetbrainsRegular)
                                .foregroundStyle(Color.textMuted)
                                .tracking(3)

                            OTPCodeInput(code: $vm.roomCode)
                        }

                        // Alias
                        VStack(alignment: .leading, spacing: 12) {
                            Text("ALIAS (OPTIONAL)")
                                .textStyle(.monoMicro, family: .jetbrainsRegular)
                                .foregroundStyle(Color.textMuted)
                                .tracking(3)

                            AliasField(alias: $vm.alias)
                        }

                        // Ghost mode
                        GhostModeToggle(isGhost: $vm.isGhost)

                        // Error
                        if let error = vm.errorMessage {
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(Color.danger)
                                    .frame(width: 6, height: 6)
                                Text(error)
                                    .textStyle(.monoMicro, family: .jetbrainsRegular)
                                    .foregroundStyle(Color.danger)
                            }
                            .transition(.opacity)
                        }
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 24)
                }
                .scrollDismissesKeyboard(.interactively)

                // Botón unirse
                AppButton(
                    label: vm.isLoading ? "JOINING..." : "JOIN ROOM",
                    action: { vm.joinRoom() },
                    layout: .center,
                    leadingIcon: vm.isLoading ? nil : "arrow.right"
                )
                .disabled(!vm.canJoin || vm.isLoading)
                .opacity(vm.canJoin && !vm.isLoading ? 1.0 : 0.4)
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
                .padding(.top, 12)
            }
        }
        .navigationBarHidden(true)
        .animation(.easeInOut(duration: 0.2), value: vm.errorMessage)
        .onChange(of: vm.shouldNavigateToChat) { _, shouldNavigate in
            if shouldNavigate, let code = vm.joinedRoomCode {
                router.goToChat(roomCode: code)
            }
        }
    }
}

// MARK: - OTP Code Input

private struct OTPCodeInput: View {

    @Binding var code: String
    @FocusState private var isFocused: Bool

    var body: some View {
        ZStack {
            // Celdas Visuales
            HStack(spacing: 12) {
                ForEach(0..<4, id: \.self) { index in
                    OTPCell(
                        digit: digit(at: index),
                        isFocused: isFocused && (index == min(code.count, 3)),
                        isFilled: index < code.count,
                        isFirst: index == 0,
                        isLast: index == 3
                    )
                }
            }

            // TextField Invisible para manejar ingresos y pegados de manera nativa
            TextField("", text: $code)
                .keyboardType(.asciiCapable)
                .textInputAutocapitalization(.characters)
                .autocorrectionDisabled()
                .focused($isFocused)
                .foregroundStyle(.clear)
                .tint(.clear)
                .onChange(of: code) { _, newValue in
                    let filtered = String(newValue.uppercased().filter { $0.isLetter || $0.isNumber }.prefix(4))
                    if code != filtered {
                        code = filtered
                    }
                }
        }
        .onAppear { isFocused = true }
    }

    private func digit(at index: Int) -> String {
        guard index < code.count else { return "" }
        let charIndex = code.index(code.startIndex, offsetBy: index)
        return String(code[charIndex])
    }
}

private struct OTPCell: View {
    let digit: String
    let isFocused: Bool
    let isFilled: Bool
    let isFirst: Bool
    let isLast: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.bgSurface)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(
                            isFocused ? Color.accentYellow : (isFilled ? Color.accentYellow.opacity(0.5) : Color.borderDefault),
                            lineWidth: isFocused ? 2 : 1
                        )
                )

            // Esquina superior izquierda — primera celda
            if isFirst {
                VStack {
                    HStack {
                        CornerMark(topLeft: true)
                        Spacer()
                    }
                    Spacer()
                }
                .padding(6)
            }

            // Esquina inferior derecha — última celda
            if isLast {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        CornerMark(topLeft: false)
                    }
                }
                .padding(6)
            }

            Text(digit)
                .font(.system(size: 32, weight: .bold, design: .monospaced))
                .foregroundStyle(Color.textPrimary)
        }
        .frame(maxWidth: .infinity)
        .aspectRatio(3/4, contentMode: .fit)
    }
}

private struct CornerMark: View {
    let topLeft: Bool

    var body: some View {
        Canvas { ctx, size in
            var path = Path()
            if topLeft {
                path.move(to: CGPoint(x: 0, y: size.height))
                path.addLine(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: size.width, y: 0))
            } else {
                path.move(to: CGPoint(x: 0, y: size.height))
                path.addLine(to: CGPoint(x: size.width, y: size.height))
                path.addLine(to: CGPoint(x: size.width, y: 0))
            }
            ctx.stroke(path, with: .color(Color.borderDefault), lineWidth: 1)
        }
        .frame(width: 8, height: 8)
    }
}

// MARK: - Alias Field

private struct AliasField: View {
    @Binding var alias: String
    @FocusState private var focused: Bool

    var body: some View {
        HStack {
            TextField("Spectro_01", text: $alias)
                .textStyle(.monoMicro, family: .jetbrainsRegular)
                .foregroundStyle(Color.textPrimary)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .focused($focused)

            Image(systemName: "person.crop.circle")
                .foregroundStyle(Color.textMuted)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(Color.bgSurface)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(focused ? Color.accentYellow : Color.borderDefault, lineWidth: focused ? 2 : 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Ghost Mode Toggle

private struct GhostModeToggle: View {
    @Binding var isGhost: Bool

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(isGhost ? Color.accentYellow.opacity(0.1) : Color.bgSurface)
                    .frame(width: 40, height: 40)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.borderDefault, lineWidth: 1))
                Image(systemName: "eye.slash")
                    .foregroundStyle(isGhost ? Color.accentYellow : Color.textMuted)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("GHOST MODE")
                    .textStyle(.labelSmall, family: .syneBold)
                    .foregroundStyle(Color.textPrimary)
                Text("No read notifications")
                    .textStyle(.monoMicro, family: .jetbrainsRegular)
                    .foregroundStyle(Color.textMuted)
            }

            Spacer()

            Toggle("", isOn: $isGhost)
                .tint(Color.accentYellow)
                .labelsHidden()
        }
        .padding(16)
        .background(Color.bgSurface)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isGhost ? Color.accentYellow.opacity(0.3) : Color.borderDefault, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .animation(.easeInOut(duration: 0.2), value: isGhost)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        RoomJoinView()
            .environment(AppRouter())
    }
}
