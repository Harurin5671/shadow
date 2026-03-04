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
    var isGoingForward: Bool = true

    enum Step: Int, CaseIterable {
        case one = 1
        case two = 2
        case three = 3
    }

    func nextStep() {
        switch currentStep {
        case .one:
            isGoingForward = true
            currentStep = .two
        case .two:
            isGoingForward = true
            currentStep = .three
        case .three: break
        }
    }

    func previousStep() {
        switch currentStep {
        case .one: break
        case .two:
            isGoingForward = false
            currentStep = .one
        case .three:
            isGoingForward = false
            currentStep = .two
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
                    .transition(stepTransition)
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
                    .transition(stepTransition)
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
                    .transition(stepTransition)
                    .id("step3")
                }
            }
            .padding(.horizontal, 24)
        }
        .safeAreaInset(edge: .top) {
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
        }
    }

    private var stepTransition: AnyTransition {
        let edge: Edge = vm.isGoingForward ? .trailing : .leading
        let removeEdge: Edge = vm.isGoingForward ? .leading : .trailing

        return .asymmetric(
            insertion: .move(edge: edge).combined(with: .opacity),
            removal: .move(edge: removeEdge).combined(with: .opacity)
        )
    }
}

#Preview {
    OnboardingView()
        .environment(AppRouter())
}
