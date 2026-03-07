//
//  RoomCreationConfigView.swift
//  shadow
//
//  Created by Frank Erick Santos Gonzales on 7/03/26.
//

import SwiftUI

// Paso 2 — Configurar sala

struct RoomCreationConfigView: View {

    @Bindable var vm: RoomCreationViewModel

    var body: some View {
        VStack(spacing: 0) {

            // ── Top bar ──────────────────────────────────────
            RoomCreationTopBar(
                title: "CONFIGURE",
                onBack: { vm.goBackToAlias() },
            )

            // ── Opciones ─────────────────────────────────────
            ScrollView {
                VStack(spacing: 12) {

                    // Máximo participantes
                    ConfigRow(
                        icon: "person.2",
                        title: "MAX PARTICIPANTS",
                        subtitle: "How many people can join this room"
                    ) {
                        HStack(spacing: 16) {
                            Button {
                                if vm.maxParticipants > 2 { vm.maxParticipants -= 1 }
                            } label: {
                                Image(systemName: "minus")
                                    .foregroundStyle(Color.textPrimary)
                                    .frame(width: 32, height: 32)
                                    .background(Color.bgElevated)
                                    .overlay(Rectangle().stroke(Color.borderDefault, lineWidth: 1))
                            }

                            Text("\(vm.maxParticipants)")
                                .textStyle(.monoMicro, family: .jetbrainsRegular)
                                .foregroundStyle(Color.accentYellow)
                                .frame(minWidth: 24)

                            Button {
                                if vm.maxParticipants < 20 { vm.maxParticipants += 1 }
                            } label: {
                                Image(systemName: "plus")
                                    .foregroundStyle(Color.textPrimary)
                                    .frame(width: 32, height: 32)
                                    .background(Color.bgElevated)
                                    .overlay(Rectangle().stroke(Color.borderDefault, lineWidth: 1))
                            }
                        }
                    }

                    // Contraseña
                    ConfigSection(
                        icon: "lock",
                        title: "PASSWORD",
                        subtitle: "Extra protection beyond the 4-char code",
                        isEnabled: $vm.passwordEnabled
                    ) {
                        SecureField("Enter password", text: $vm.password)
                            .textStyle(.monoMicro, family: .jetbrainsRegular)
                            .foregroundStyle(Color.textPrimary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color.bgElevated)
                            .overlay(Rectangle().stroke(Color.borderSubtle, lineWidth: 1))
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                    }

                    // Dead man's switch
                    ConfigSection(
                        icon: "timer",
                        title: "DEAD MAN'S SWITCH",
                        subtitle: "Room self-destructs if you go silent",
                        isEnabled: $vm.deadManEnabled,
                        accentColor: Color.danger
                    ) {
                        IntervalPicker(
                            selected: $vm.deadManInterval,
                            options: DeadManInterval.allCases,
                            accentColor: Color.danger
                        )
                    }

                    // Burn timer por defecto
                    ConfigSection(
                        icon: "flame",
                        title: "DEFAULT BURN TIMER",
                        subtitle: "Messages auto-delete after being read",
                        isEnabled: $vm.burnTimerEnabled
                    ) {
                        IntervalPicker(
                            selected: $vm.burnTimer,
                            options: BurnTimer.allCases,
                            accentColor: Color.accentYellow
                        )
                    }

                    // Modo fantasma
                    ConfigRow(
                        icon: "eye.slash",
                        title: "GHOST MODE",
                        subtitle: "You can enter rooms invisibly"
                    ) {
                        Toggle("", isOn: $vm.ghostModeEnabled)
                            .tint(Color.accentYellow)
                            .labelsHidden()
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
            }

            // ── Error ────────────────────────────────────────
            if let error = vm.errorMessage {
                Text(error)
                    .textStyle(.monoMicro, family: .jetbrainsRegular)
                    .foregroundStyle(Color.danger)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 8)
            }

            // ── Botón crear ──────────────────────────────────
            AppButton(
                label: vm.isLoading ? "CREATING..." : "CREATE ROOM",
                action: { vm.createRoom() },
                layout: .center,
                leadingIcon: vm.isLoading ? nil : "plus"
            )
            .disabled(vm.isLoading)
            .opacity(vm.isLoading ? 0.6 : 1.0)
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
    }
}

// MARK: - Subcomponentes

// Fila con control a la derecha — sin toggle de activación
private struct ConfigRow<Control: View>: View {
    let icon: String
    let title: String
    let subtitle: String
    @ViewBuilder let control: () -> Control

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(Color.textMuted)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .textStyle(.labelSmall, family: .syneBold)
                    .foregroundStyle(Color.textPrimary)
                Text(subtitle)
                    .textStyle(.monoMicro, family: .jetbrainsRegular)
                    .foregroundStyle(Color.textMuted)
            }

            Spacer()
            control()
        }
        .padding(16)
        .background(Color.bgSurface)
        .overlay(Rectangle().stroke(Color.borderDefault, lineWidth: 1))
    }
}

// Sección con toggle de activación + contenido expandible
private struct ConfigSection<Content: View>: View {
    let icon: String
    let title: String
    let subtitle: String
    @Binding var isEnabled: Bool
    var accentColor: Color = Color.accentYellow
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundStyle(isEnabled ? accentColor : Color.textMuted)
                    .frame(width: 20)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .textStyle(.labelSmall, family: .syneBold)
                        .foregroundStyle(Color.textPrimary)
                    Text(subtitle)
                        .textStyle(.monoMicro, family: .jetbrainsRegular)
                        .foregroundStyle(Color.textMuted)
                }

                Spacer()

                Toggle("", isOn: $isEnabled)
                    .tint(accentColor)
                    .labelsHidden()
            }
            .padding(16)

            if isEnabled {
                content()
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(Color.bgSurface)
        .overlay(Rectangle().stroke(
            isEnabled ? accentColor.opacity(0.3) : Color.borderDefault,
            lineWidth: 1
        ))
        .animation(.easeInOut(duration: 0.2), value: isEnabled)
    }
}

// Picker de intervalos en chips horizontales
private struct IntervalPicker<T: RawRepresentable & CaseIterable & Identifiable>: View
where T.RawValue == Int, T: Hashable {
    @Binding var selected: T
    let options: [T]
    var accentColor: Color

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Array(options as [any Identifiable]) as! [T], id: \.id) { option in
                    let isSelected = selected == option
                    Button {
                        selected = option
                    } label: {
                        Text((option as? DeadManInterval)?.label ?? (option as? BurnTimer)?.label ?? "")
                            .textStyle(.monoMicro, family: .jetbrainsRegular)
                            .foregroundStyle(isSelected ? Color.bgPrimary : Color.textMuted)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(isSelected ? accentColor : Color.bgElevated)
                            .overlay(Rectangle().stroke(
                                isSelected ? accentColor : Color.borderSubtle,
                                lineWidth: 1
                            ))
                    }
                }
            }
        }
    }
}

#Preview {
    ZStack {
        Color.bgPrimary.ignoresSafeArea()
        RoomCreationConfigView(vm: RoomCreationViewModel())
    }
}
