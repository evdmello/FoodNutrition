//
//  OnboardingView.swift
//  Scora
//
//  Created by Errol DMello on 11/23/25.
//


import SwiftUI

struct OnboardingView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    let dismiss: () -> Void

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            if viewModel.isLoading || viewModel.screens.isEmpty {
                LoadingScreen()
            } else {
                VStack(spacing: 0) {
                    OnboardingHeader(
                        progress: viewModel.progress,
                        onSkip: dismiss
                    )

                    TabView(selection: $viewModel.currentScreenIndex) {
                        ForEach(Array(viewModel.screens.enumerated()), id: \.element.id) { index, screen in
                            screenView(for: screen)
                                .tag(index)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .animation(.easeInOut, value: viewModel.currentScreenIndex)
                }
            }
        }
        .onChange(of: viewModel.isComplete) { isComplete in
            if isComplete {
                dismiss()
            }
        }
        .onAppear {
            Task {
                try? await Task.sleep(nanoseconds: 500_000_000)
                await viewModel.loadOnboardingData()
            }
        }
    }

    @ViewBuilder
    func screenView(for screen: OnboardingScreen) -> some View {
        switch screen.type {
        case .intro:
            IntroScreen(screen: screen, onContinue: viewModel.nextScreen)
        case .problemStatement:
            ProblemStatementScreen(screen: screen, onContinue: viewModel.nextScreen)
        case .valueProposition:
            ValuePropositionScreen(screen: screen, onContinue: viewModel.nextScreen)
        case .featuresOverview:
            FeaturesOverviewScreen(screen: screen, onContinue: viewModel.nextScreen)
        case .featureDetail:
            FeatureDetailScreen(screen: screen, onContinue: viewModel.nextScreen)
        case .scoreExplanation:
            ScoreExplanationScreen(screen: screen, onContinue: viewModel.nextScreen)
        case .question:
            QuestionScreen(
                screen: screen,
                selectedAnswer: viewModel.userAnswers[screen.id],
                onSelect: { answer in
                    viewModel.selectAnswer(screenId: screen.id, answer: answer)
                }
            )
        case .results:
            ResultsScreen(screen: screen, onContinue: viewModel.nextScreen)
        case .confirmation:
            ConfirmationScreen(screen: screen, onContinue: viewModel.nextScreen)
        case .conceptIntro:
            ConceptIntroScreen(screen: screen, onContinue: viewModel.nextScreen)
        case .programSelection:
            ProgramSelectionScreen(
                screen: screen,
                selectedProgram: viewModel.selectedProgram,
                onSelect: viewModel.selectProgram
            )
        case .weeklyGoals:
            WeeklyGoalsScreen(screen: screen, onContinue: viewModel.nextScreen)
        case .dailyInstructions:
            DailyInstructionsScreen(screen: screen, onContinue: viewModel.nextScreen)
        case .finalSummary:
            FinalSummaryScreen(screen: screen, onComplete: viewModel.nextScreen)
        }
    }
}

struct OnboardingHeader: View {
    let progress: Double
    let onSkip: () -> Void

    var body: some View {
        HStack {
            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle(tint: AppColors.primary))
                .frame(height: 4)

            Button("Just explore") {
                onSkip()
            }
            .font(.system(size: 15))
            .foregroundColor(AppColors.textSecondary)
            .padding(.leading, 12)
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
}

struct LoadingScreen: View {
    @State private var isAnimating = false

    var body: some View {
        VStack(spacing: 24) {
            Circle()
                .fill(AppColors.primary.opacity(0.2))
                .frame(width: 80, height: 80)
                .overlay(
                    Circle()
                        .trim(from: 0, to: 0.7)
                        .stroke(AppColors.primary, lineWidth: 4)
                        .frame(width: 60, height: 60)
                        .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
                        .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: isAnimating)
                )

            VStack(spacing: 8) {
                Text("Loading Your Journey")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)

                Text("Preparing personalized experience...")
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.textSecondary)
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(dismiss: {})
    }
}
