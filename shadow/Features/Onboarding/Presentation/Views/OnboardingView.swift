//
//  OnboardingView.swift
//  shadow
//
//  Created by Frank Erick Santos Gonzales on 3/03/26.
//

import SwiftUI

@Observable
final class OnboardingViewModel {
    var currentStep: Step = .one

    enum Step: Int, CaseIterable {
        case one = 1
        case two = 2
        case three = 3
    }

    func nextStep() {
        switch currentStep {
        case .one: currentStep = .two
        case .two: currentStep = .three
        case .three: break
        }
    }

    func previousStep() {
        switch currentStep {
        case .one: break
        case .two: currentStep = .one
        case .three: currentStep = .two
        }
    }
}

struct OnboardingView: View {
    @State private var vm = OnboardingViewModel()
    @Environment(AppRouter.self) private var router

    var body: some View {
        ZStack {
            Color.bgPrimary.ignoresSafeArea()
            DotGridBackground()

            VStack {
                OnboardingTopBar(
                    currentStep: vm.currentStep.rawValue,
                    totalSteps: OnboardingViewModel.Step.allCases.count,
                    onBack: vm.currentStep != .one
                        ? {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                vm.previousStep()
                            }
                        }
                        : nil
                )

                ZStack {
                    switch vm.currentStep {
                    case .one:
                        OnboardingStep1View(
                            onNext: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    vm.nextStep()
                                }
                            }
                        )
                        .transition(
                            .asymmetric(
                                insertion: .move(edge: .trailing).combined(
                                    with: .opacity
                                ),
                                removal: .move(edge: .leading).combined(
                                    with: .opacity
                                )
                            )
                        )
                        .id("step1")
                    case .two:
                        OnboardingStep2View(
                            onNext: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    vm.nextStep()
                                }
                            },
                            onPreview: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    vm.previousStep()
                                }
                            }
                        )
                        .transition(
                            .asymmetric(
                                insertion: .move(edge: .trailing).combined(
                                    with: .opacity
                                ),
                                removal: .move(edge: .leading).combined(
                                    with: .opacity
                                )
                            )
                        )
                        .id("step2")
                    case .three:
                        OnboardingStep3View(
                            onFinished: {
                                router.completeOnboarding()
                            },
                            onPreview: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    vm.previousStep()
                                }
                            }
                        )
                        .transition(
                            .asymmetric(
                                insertion: .move(edge: .trailing).combined(
                                    with: .opacity
                                ),
                                removal: .move(edge: .leading).combined(
                                    with: .opacity
                                )
                            )
                        )
                        .id("step3")
                    }
                }
            }
        }
    }
}

struct OnboardingTopBar: View {
    let currentStep: Int
    let totalSteps: Int
    let onBack: (() -> Void)?

    var body: some View {
        HStack {
            // Back button (visible only on step 2 and 3)
            if let onBack {
                Button(action: onBack) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Back")
                            .font(.system(size: 14, weight: .medium))
                    }
                    .foregroundStyle(Color.accentYellow)
                }
                .transition(.opacity.combined(with: .move(edge: .leading)))
            } else {
                // Invisible placeholder to keep layout stable
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .semibold))
                    Text("Back")
                        .font(.system(size: 14, weight: .medium))
                }
                .foregroundStyle(.clear)
            }

            Spacer()

            // Page indicator
            Text("\(currentStep)/\(totalSteps)")
                .font(.system(size: 15, weight: .semibold, design: .monospaced))
                .foregroundStyle(Color.accentYellow)
                .contentTransition(.numericText())
                .animation(.easeInOut(duration: 0.3), value: currentStep)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(Color.bgPrimary)
        .animation(.easeInOut(duration: 0.3), value: onBack == nil)
    }
}

struct DotGridBackground: View {
    var body: some View {
        Canvas { context, size in
            let spacing: CGFloat = 40
            let dotSize: CGFloat = 1.5

            var x: CGFloat = spacing / 2
            while x < size.width {
                var y: CGFloat = spacing / 2
                while y < size.height {
                    context.fill(
                        Path(
                            ellipseIn: CGRect(
                                x: x - dotSize / 2,
                                y: y - dotSize / 2,
                                width: dotSize,
                                height: dotSize
                            )
                        ),
                        with: .color(Color.accentYellow.opacity(0.06))
                    )
                    y += spacing
                }
                x += spacing
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}

struct OnboardingProgressBar: View {

    let current: Int
    let total: Int

    var progreso: Double {
        Double(current) / Double(total)
    }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {

                // Track vacio
                Rectangle()
                    .fill(Color.borderDefault)
                    .frame(height: 2)

                // Progreso lleno
                Rectangle()
                    .fill(Color.accentYellow)
                    .frame(width: geo.size.width * progreso, height: 2)
                    .animation(.easeInOut(duration: 0.3), value: progreso)
            }
        }
        .frame(height: 2)
    }
}

#Preview {
    OnboardingView()
        .environment(AppRouter())
}
