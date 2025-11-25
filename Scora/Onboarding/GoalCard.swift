//
//  GoalCard.swift
//  Scora
//
//  Created by Errol DMello on 11/23/25.
//


import SwiftUI

struct GoalCard: View {
    let goal: Goal
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Text("\(goal.number)")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .background(AppColors.primary)
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(goal.title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)
                
                Text(goal.details)
                    .font(.system(size: 15))
                    .foregroundColor(AppColors.textSecondary)
            }
            
            Spacer()
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(12)
    }
}

struct DailyInstructionsScreen: View {
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
            
            VStack(alignment: .leading, spacing: 16) {
                ForEach(screen.steps ?? []) { step in
                    HStack(alignment: .top, spacing: 12) {
                        Text("\(step.number)")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(AppColors.primary)
                            .frame(width: 28, height: 28)
                            .background(AppColors.primary.opacity(0.2))
                            .cornerRadius(14)
                        
                        Text(step.text)
                            .font(.system(size: 16))
                            .foregroundColor(AppColors.textPrimary)
                        
                        Spacer()
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

struct FinalSummaryScreen: View {
    let screen: OnboardingScreen
    let onComplete: () -> Void
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            Text(screen.title ?? "")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(AppColors.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            VStack(alignment: .leading, spacing: 20) {
                ForEach(screen.benefits ?? []) { benefit in
                    HStack(alignment: .top, spacing: 16) {
                        Image(systemName: iconForBenefit(benefit.icon))
                            .font(.system(size: 20))
                            .foregroundColor(AppColors.primary)
                            .frame(width: 32)
                        
                        Text(benefit.text)
                            .font(.system(size: 16))
                            .foregroundColor(AppColors.textPrimary)
                        
                        Spacer()
                    }
                }
            }
            .padding(.horizontal, 32)
            
            Spacer()
            
            PrimaryButton(title: screen.buttonText ?? "Start", action: onComplete)
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
        }
    }
    
    func iconForBenefit(_ icon: String) -> String {
        switch icon {
        case "heartbeat": return "waveform.path.ecg"
        case "leaf": return "leaf.fill"
        case "heart": return "heart.fill"
        default: return "star.fill"
        }
    }
}
