//
//  IntroScreen.swift
//  Scora
//
//  Created by Errol DMello on 11/23/25.
//

import SwiftUI

struct IntroScreen: View {
    let screen: OnboardingScreen
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            VStack(spacing: 16) {
                Text(screen.title ?? "")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)
                    .multilineTextAlignment(.center)

                Text(screen.subtitle ?? "")
                    .font(.system(size: 17))
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 32)

            Spacer()

            PrimaryButton(title: screen.buttonText ?? "Continue", action: onContinue)
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
        }
    }
}

struct ProblemStatementScreen: View {
    let screen: OnboardingScreen
    let onContinue: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text(screen.title ?? "")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 40)

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

                Spacer(minLength: 40)

                PrimaryButton(title: screen.buttonText ?? "Continue", action: onContinue)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 40)
            }
        }
    }
}

struct QuestionScreen: View {
    let screen: OnboardingScreen
    let selectedAnswer: String?
    let onSelect: (String) -> Void

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Text(screen.question ?? "")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(AppColors.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            VStack(spacing: 16) {
                ForEach(screen.options ?? [], id: \.self) { option in
                    OptionButton(
                        title: option,
                        isSelected: selectedAnswer == option,
                        action: { onSelect(option) }
                    )
                }
            }
            .padding(.horizontal, 32)

            Spacer()
        }
    }
}
