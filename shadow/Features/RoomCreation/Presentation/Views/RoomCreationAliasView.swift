//
//  RoomCreationAliasView.swift
//  shadow
//
//  Created by Frank Erick Santos Gonzales on 7/03/26.
//

import SwiftUI

struct RoomCreationAliasView: View {

    @Bindable var vm: RoomCreationViewModel
    @FocusState private var aliasFocused: Bool

    var body: some View {
        VStack() {
            ScrollView {
                VStack() {

                    // ── Top bar ──────────────────────────────────────
                    RoomCreationTopBar(
                        title: "Nueva Sala",
                        onBack: { vm.dismiss() }
                    )

                    // ── Contenido ────────────────────────────────────
                    VStack(alignment: .leading, spacing: 40) {

                        // Título
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Tu alias")
                                .textStyle(
                                    .displayHero,
                                    family: .spaceGrotesk,
                                    size: 36
                                )

                            Text(
                                "en esta sala"
                            )
                            .textStyle(
                                .displayHero,
                                family: .spaceGrotesk,
                                color: .color(.accentYellow),
                                size: 36
                            )
                        }

                        // Campo de alias
                        VStack(alignment: .leading, spacing: 8) {
                            ZStack(alignment: .leading) {
                                if vm.alias.isEmpty && !vm.isAnonymous {
                                    HStack(spacing: 0) {
                                        Image(systemName: "at")
                                            .font(.system(size: 16))
                                            .foregroundStyle(Color(hex: "#5A6030"))
                                            .padding(.leading, 16)
                                        
                                        Text("e.g. GhostFox")
                                            .textStyle(.monoMicro, family: .jetbrainsRegular)
                                            .foregroundStyle(Color(hex: "#5A6030"))
                                            .padding(.leading, 8)
                                        
                                        Spacer()
                                    }
                                }

                                HStack(spacing: 0) {
                                    Image(systemName: "at")
                                        .font(.system(size: 16))
                                        .foregroundStyle(
                                            aliasFocused
                                                ? Color.accentYellow
                                                : Color(hex: "#5A6030")
                                        )
                                        .padding(.leading, 16)

                                    TextField("", text: $vm.alias)
                                        .textStyle(.monoMicro, family: .jetbrainsRegular)
                                        .foregroundStyle(
                                            vm.isAnonymous ? Color.textMuted : Color.textPrimary
                                        )
                                        .disabled(vm.isAnonymous)
                                        .focused($aliasFocused)
                                        .autocorrectionDisabled()
                                        .textInputAutocapitalization(.never)
                                        .padding(.leading, 8)
                                }
                                .padding(.vertical, 14)
                                .padding(.trailing, 16)
                            }
                            .background(Color.bgSurface)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(
                                        aliasFocused ? Color.accentYellow : Color.borderDefault,
                                        lineWidth: aliasFocused ? 2 : 1
                                    )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 8))

                            HStack {
                                Spacer()
                                Text("MAX 12 CARACTERES")
                                    .textStyle(
                                        .monoMicro,
                                        family: .jetbrainsRegular,
                                        color: .color(Color(hex: "#5A6030"))
                                    )
                            }
                        }
//                        VStack(alignment: .leading, spacing: 8) {
//                            ZStack(alignment: .leading) {
//                                if vm.alias.isEmpty && !vm.isAnonymous {
//                                    Text("e.g. GhostFox")
//                                        .textStyle(
//                                            .monoMicro,
//                                            family: .jetbrainsRegular
//                                        )
//                                        .foregroundStyle(Color.textDisabled)
//                                }
//
//                                TextField("", text: $vm.alias)
//                                    .textStyle(
//                                        .monoMicro,
//                                        family: .jetbrainsRegular
//                                    )
//                                    .foregroundStyle(
//                                        vm.isAnonymous
//                                            ? Color.textMuted
//                                            : Color.textPrimary
//                                    )
//                                    .disabled(vm.isAnonymous)
//                                    .focused($aliasFocused)
//                                    .autocorrectionDisabled()
//                                    .textInputAutocapitalization(.never)
//                            }
//                            .padding(.horizontal, 16)
//                            .padding(.vertical, 14)
//                            .background(Color.bgSurface)
//                            .overlay(
//                                Rectangle()
//                                    .stroke(
//                                        aliasFocused
//                                            ? Color.accentYellow
//                                            : Color.borderDefault,
//                                        lineWidth: 1
//                                    )
//                            )
//
//                            HStack {
//                                Spacer()
//                                Text("Max 12 caracteres")
//                                    .textStyle(
//                                        .labelSmall,
//                                        family: .jetbrainsRegular,
//                                        color: .color(Color(hex: "#5A6030")),
//                                        uppercase: true
//                                    )
//                            }
//                        }

                        // Toggle modo anónimo
                        VStack(spacing: 16) {
                            HStack {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color(hex: "#343818"))
                                        .frame(width: 44, height: 44)
                                    Image(systemName: "eye.slash.fill")
                                        .foregroundStyle(Color.accentYellow)
                                }

                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Modo anónimo")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundStyle(Color.textPrimary)

                                    Text("BETA")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundStyle(Color.accentYellow)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(
                                            RoundedRectangle(cornerRadius: 2)
                                                .fill(
                                                    Color(hex: "#E7FF47")
                                                        .opacity(0.1)
                                                )
                                        )
                                }

                                Spacer()

                                Toggle("", isOn: $vm.isAnonymous)
                                    .tint(Color.accentYellow)
                                    .labelsHidden()
                            }

                            Divider()
                                .background(Color(hex: "#2a2d15"))

                            Text(
                                "En modo anónimo nadie, ni tú, sabrá quién\ndijo qué. Los metadatos de autoría son\neliminados permanentemente del servidor."
                            )
                            .textStyle(
                                .monoBody,
                                family: .spaceGroteskRegular,
                                color: .color(Color(hex: "#AAB37B"))
                            )
                        }
                        .padding(20)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay {
                            RoundedRectangle(cornerRadius: 8)
                                .strokeBorder(
                                    Color(hex: "#343918"),
                                    lineWidth: 1
                                )
                        }

                        // Preview alias si anónimo
                        if vm.isAnonymous {
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(Color.accentCyan)
                                    .frame(width: 6, height: 6)
                                Text("YOU'LL APPEAR AS: ")
                                    .textStyle(
                                        .monoMicro,
                                        family: .jetbrainsRegular
                                    )
                                    .foregroundStyle(Color.textMuted)
                                Text(vm.displayAlias)
                                    .textStyle(
                                        .monoMicro,
                                        family: .jetbrainsRegular
                                    )
                                    .foregroundStyle(Color.accentCyan)
                            }
                            .transition(.opacity)
                        }
                    }
                    .padding(.horizontal, 24)
                    .animation(.easeInOut(duration: 0.2), value: vm.isAnonymous)

                    Spacer().frame(height: 32)
                }
            }
            .scrollDismissesKeyboard(.interactively)

            // ── Botón continuar — siempre al fondo ──────────────
            AppButton(
                label: "CONTINUE",
                action: { vm.goToConfigure() },
                layout: .center,
                leadingIcon: "arrow.right"
            )
            .disabled(!vm.aliasIsValid)
            .opacity(vm.aliasIsValid ? 1.0 : 0.4)
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .scrollDismissesKeyboard(.interactively)
        //        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

#Preview {
    ZStack {
        Color.bgPrimary.ignoresSafeArea()
        RoomCreationAliasView(vm: RoomCreationViewModel())
    }
}
