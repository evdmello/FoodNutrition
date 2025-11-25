//
//  FeaturesOverviewScreen.swift
//  Scora
//
//  Created by Errol DMello on 11/23/25.
//


import SwiftUI

struct FeaturesOverviewScreen: View {
    let screen: OnboardingScreen
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 32) {
            Text(screen.title ?? "")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(AppColors.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .padding(.top, 40)

            VStack(spacing: 20) {
                ForEach(screen.items ?? []) { item in
                    ScoreItemCard(item: item)
                }
            }
            .padding(.horizontal, 32)

            Spacer()

            PrimaryButton(title: screen.buttonText ?? "Continue", action: onContinue)
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
        }
    }
}

struct ScoreItemCard: View {
    let item: ScoreItem

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: iconForType(item.icon))
                .font(.system(size: 24))
                .foregroundColor(AppColors.primary)
                .frame(width: 40, height: 40)
                .background(AppColors.primary.opacity(0.1))
                .cornerRadius(8)

            VStack(alignment: .leading, spacing: 4) {
                Text("\(item.number). \(item.name)")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)

                Text(item.description)
                    .font(.system(size: 15))
                    .foregroundColor(AppColors.textSecondary)
            }

            Spacer()
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(12)
    }

    func iconForType(_ type: String) -> String {
        switch type {
        case "leaf": return "leaf.fill"
        case "heartbeat": return "waveform.path.ecg"
        case "heart": return "heart.fill"
        default: return "circle.fill"
        }
    }
}

struct FeatureDetailScreen: View {
    let screen: OnboardingScreen
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 32) {
            Text(screen.title ?? "")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(AppColors.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .padding(.top, 40)

            if let example = screen.example {
                BiologyExampleCard(example: example)
                    .padding(.horizontal, 32)
            }

            Spacer()

            PrimaryButton(title: screen.buttonText ?? "Continue", action: onContinue)
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
        }
    }
}

struct BiologyExampleCard: View {
    let example: BiologyExample

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(example.meal)
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(AppColors.textPrimary)

            VStack(spacing: 12) {
                ForEach(example.metrics) { metric in
                    HStack {
                        Image(systemName: iconForMetric(metric.icon))
                            .foregroundColor(colorForValue(metric.color))

                        Text(metric.name)
                            .font(.system(size: 15))
                            .foregroundColor(AppColors.textSecondary)

                        Spacer()

                        Text(metric.value)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(colorForValue(metric.color))
                    }
                }
            }

            Text(example.suggestion)
                .font(.system(size: 14))
                .foregroundColor(AppColors.textSecondary)
                .padding(.top, 8)
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(12)
    }

    func iconForMetric(_ type: String) -> String {
        switch type {
        case "heart": return "heart.fill"
        case "brain": return "brain.head.profile"
        case "gut": return "leaf.fill"
        case "metabolism": return "flame.fill"
        default: return "circle.fill"
        }
    }

    func colorForValue(_ colorName: String) -> Color {
        switch colorName.lowercased() {
        case "green": return AppColors.primary
        case "orange": return .orange
        case "red": return .red
        default: return AppColors.textSecondary
        }
    }
}

struct ResultsScreen: View {
    let screen: OnboardingScreen
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Text(screen.title ?? "")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(AppColors.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            if let scoreDisplay = screen.scoreDisplay {
                VStack(spacing: 8) {
                    Text("\(scoreDisplay.value)")
                        .font(.system(size: 72, weight: .bold))
                        .foregroundColor(AppColors.primary)

                    Text(scoreDisplay.label)
                        .font(.system(size: 17))
                        .foregroundColor(AppColors.textSecondary)
                }
                .padding(40)
                .background(AppColors.cardBackground)
                .cornerRadius(16)
            }

            if let message = screen.message {
                Text(message)
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Spacer()

            PrimaryButton(title: screen.buttonText ?? "Continue", action: onContinue)
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
        }
    }
}

struct ScoreExplanationScreen: View {
    let screen: OnboardingScreen
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Text(screen.title ?? "")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(AppColors.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            VStack(spacing: 16) {
                ForEach(screen.body ?? []) { bodyText in
                    Text(bodyText.text)
                        .font(.system(size: 16))
                        .foregroundColor(AppColors.textSecondary)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.horizontal, 32)

            Spacer()

            PrimaryButton(title: screen.buttonText ?? "Continue", action: onContinue)
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
        }
    }
}

struct ValuePropositionScreen: View {
    let screen: OnboardingScreen
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Text(screen.title ?? "")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(AppColors.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            VStack(alignment: .leading, spacing: 16) {
                ForEach(screen.body ?? []) { bodyText in
                    switch bodyText.style {
                    case .normal:
                        Text(bodyText.text)
                            .font(.system(size: 16))
                            .foregroundColor(AppColors.textSecondary)
                    case .highlighted:
                        Text(bodyText.text)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppColors.textPrimary)
                            .padding(.top, 8)
                    case .subtitle:
                        Text(bodyText.text)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(AppColors.textSecondary.opacity(0.8))
                    }
                }
            }
            .padding(.horizontal, 32)

            Spacer()

            PrimaryButton(title: screen.buttonText ?? "Continue", action: onContinue)
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
        }
    }
}

struct ConfirmationScreen: View {
    let screen: OnboardingScreen
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Text(screen.title ?? "")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(AppColors.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            if let message = screen.message {
                Text(message)
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Spacer()

            PrimaryButton(title: screen.buttonText ?? "Continue", action: onContinue)
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
        }
    }
}

struct ConceptIntroScreen: View {
    let screen: OnboardingScreen
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Text(screen.title ?? "")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(AppColors.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            VStack(spacing: 16) {
                ForEach(screen.body ?? []) { bodyText in
                    Text(bodyText.text)
                        .font(.system(size: 16))
                        .foregroundColor(AppColors.textSecondary)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.horizontal, 32)

            Spacer()

            PrimaryButton(title: screen.buttonText ?? "Continue", action: onContinue)
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
        }
    }
}

struct ProgramSelectionScreen: View {
    let screen: OnboardingScreen
    let selectedProgram: String?
    let onSelect: (String) -> Void

    var body: some View {
        VStack(spacing: 32) {
            Text(screen.title ?? "")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(AppColors.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .padding(.top, 40)

            if let subtitle = screen.subtitle {
                Text(subtitle)
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            VStack(spacing: 16) {
                ForEach(screen.programs ?? []) { program in
                    ProgramCard(
                        program: program,
                        isSelected: selectedProgram == program.id,
                        onSelect: { onSelect(program.id) }
                    )
                }
            }
            .padding(.horizontal, 32)

            Spacer()
        }
    }
}

struct ProgramCard: View {
    let program: Program
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 8) {
                Text(program.name)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)

                Text(program.description)
                    .font(.system(size: 15))
                    .foregroundColor(AppColors.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? AppColors.primary : Color.gray.opacity(0.3), lineWidth: 2)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(isSelected ? AppColors.primary.opacity(0.1) : AppColors.cardBackground)
                    )
            )
        }
    }
}

struct WeeklyGoalsScreen: View {
    let screen: OnboardingScreen
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 32) {
            Text(screen.title ?? "")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(AppColors.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .padding(.top, 40)

            VStack(spacing: 16) {
                ForEach(screen.goals ?? []) { goal in
                    GoalCard(goal: goal)
                }
            }
            .padding(.horizontal, 32)

            if let message = screen.message {
                Text(message)
                    .font(.system(size: 15))
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .padding(.top, 8)
            }

            Spacer()

            PrimaryButton(title: screen.buttonText ?? "Continue", action: onContinue)
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
        }
    }
}
