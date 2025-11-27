//
//  MealAnalysisResultView.swift
//  Scora
//
//  Created by Errol DMello on 11/27/25.
//

import SwiftUI

struct MealAnalysisResultView: View {
    let response: MealAnalysisResponse
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Meal Analysis")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(AppColors.textPrimary)

                        Text("Nutrition Summary")
                            .font(.system(size: 16))
                            .foregroundColor(AppColors.textSecondary)
                    }
                    .padding(.top, 40)

                    // Overall Score
                    VStack(spacing: 12) {
                        Text("Overall Score")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(AppColors.textPrimary)

                        ZStack {
                            Circle()
                                .stroke(Color.gray.opacity(0.2), lineWidth: 8)
                                .frame(width: 120, height: 120)

                            Circle()
                                .trim(from: 0, to: min(response.overallScore / 100, 1.0))
                                .stroke(scoreColor(response.overallScore), lineWidth: 8)
                                .frame(width: 120, height: 120)
                                .rotationEffect(.degrees(-90))

                            VStack {
                                Text(String(format: "%.1f", response.overallScore))
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(scoreColor(response.overallScore))

                                Text("/100")
                                    .font(.system(size: 16))
                                    .foregroundColor(AppColors.textSecondary)
                            }
                        }
                    }

                    // Health Pillars
                    VStack(spacing: 16) {
                        Text("Health Pillars")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(AppColors.textPrimary)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            PillarCard(name: "Metabolic", score: response.pillars.metabolic, icon: "flame.fill")
                            PillarCard(name: "Heart", score: response.pillars.heart, icon: "heart.fill")
                            PillarCard(name: "Brain", score: response.pillars.brain, icon: "brain.head.profile")
                            PillarCard(name: "Gut", score: response.pillars.gut, icon: "cross.case.fill")
                        }
                    }
                    .padding(.horizontal, 24)

                    // Macronutrients
                    VStack(spacing: 16) {
                        Text("Macronutrients")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(AppColors.textPrimary)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        VStack(spacing: 12) {
                            if let totalCalories = response.meal.totalCalories {
                                NutrientRow(label: "Calories", value: String(format: "%.0f kcal", totalCalories), color: .orange)
                            }
                            NutrientRow(label: "Protein", value: String(format: "%.1f g", response.meal.mealSummary.totalProteinG), color: .blue)
                            NutrientRow(label: "Total Fat", value: String(format: "%.1f g", response.meal.mealSummary.totalFatG), color: .purple)
                            NutrientRow(label: "Carbohydrates", value: String(format: "%.1f g", response.meal.mealSummary.totalCarbsG), color: .green)
                            NutrientRow(label: "Fiber", value: String(format: "%.1f g", response.meal.mealSummary.totalFiberG), color: .brown)
                        }
                    }
                    .padding(.horizontal, 24)

                    // Food Items
                    VStack(spacing: 16) {
                        Text("Food Items")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(AppColors.textPrimary)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        VStack(spacing: 12) {
                            ForEach(response.meal.foodItems, id: \.name) { item in
                                FoodItemRow(item: item)
                            }
                        }
                    }
                    .padding(.horizontal, 24)

                    // Component Scores
                    VStack(spacing: 16) {
                        Text("Score Breakdown")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(AppColors.textPrimary)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        VStack(spacing: 12) {
                            ScoreBreakdownRow(label: "Protein Quality", score: response.proteinScore.score, method: response.proteinScore.method)
                            ScoreBreakdownRow(label: "Fat Quality", score: response.fatScore.score, method: nil)
                            ScoreBreakdownRow(label: "Carb Quality", score: response.carbScore.score, method: nil)
                            ScoreBreakdownRow(label: "Micronutrients", score: response.micronutrientScore.score, method: nil)
                        }
                    }
                    .padding(.horizontal, 24)

                    // Additional Info
                    VStack(spacing: 12) {
                        HStack {
                            Label("Plant Diversity", systemImage: "leaf.fill")
                                .font(.system(size: 14))
                                .foregroundColor(AppColors.textSecondary)
                            Spacer()
                            Text("\(response.meal.mealSummary.plantDiversityCount) types")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(AppColors.textPrimary)
                        }

                        HStack {
                            Label("Whole Grain Ratio", systemImage: "circle.grid.cross.fill")
                                .font(.system(size: 14))
                                .foregroundColor(AppColors.textSecondary)
                            Spacer()
                            Text(String(format: "%.0f%%", response.meal.mealSummary.wholeGrainRatio * 100))
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(AppColors.textPrimary)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal, 24)

                    // Done Button
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Done")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(AppColors.primary)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
        }
    }

    private func scoreColor(_ score: Double) -> Color {
        if score >= 70 {
            return .green
        } else if score >= 40 {
            return .orange
        } else {
            return .red
        }
    }
}

struct NutrientRow: View {
    let label: String
    let value: String
    var color: Color = AppColors.primary

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 16))
                .foregroundColor(AppColors.textPrimary)

            Spacer()

            Text(value)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(color)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(8)
    }
}

struct PillarCard: View {
    let name: String
    let score: Double
    let icon: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(pillarColor(score))

            Text(name)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(AppColors.textPrimary)

            Text(String(format: "%.1f", score))
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(pillarColor(score))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(pillarColor(score).opacity(0.3), lineWidth: 2)
        )
    }

    private func pillarColor(_ score: Double) -> Color {
        if score >= 70 {
            return .green
        } else if score >= 40 {
            return .orange
        } else {
            return .red
        }
    }
}

struct FoodItemRow: View {
    let item: FoodItem

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(formatFoodName(item.name))
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)

                Spacer()

                Text(String(format: "%.0f g", item.quantityG))
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppColors.textSecondary)
            }

            HStack(spacing: 12) {
                Label(item.foodGroup, systemImage: "tag.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.blue)

                Label(processingLevelText(item.processingLevel), systemImage: "gearshape.fill")
                    .font(.system(size: 12))
                    .foregroundColor(processingLevelColor(item.processingLevel))
            }

            if !item.notes.isEmpty {
                Text(item.notes)
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.textSecondary)
                    .lineLimit(2)
            }
        }
        .padding(12)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(8)
    }

    private func formatFoodName(_ name: String) -> String {
        return name.replacingOccurrences(of: "_", with: " ").capitalized
    }

    private func processingLevelText(_ level: String) -> String {
        switch level.lowercased() {
        case "minimal":
            return "Minimal Processing"
        case "moderate":
            return "Moderate Processing"
        case "ultra-processed":
            return "Ultra-Processed"
        default:
            return level.capitalized
        }
    }

    private func processingLevelColor(_ level: String) -> Color {
        switch level.lowercased() {
        case "minimal":
            return .green
        case "moderate":
            return .orange
        case "ultra-processed":
            return .red
        default:
            return .gray
        }
    }
}

struct ScoreBreakdownRow: View {
    let label: String
    let score: Double
    let method: String?

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text(label)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppColors.textPrimary)

                if let method = method {
                    Text("(\(method))")
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.textSecondary)
                }

                Spacer()

                Text(String(format: "%.1f", score))
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(scoreColor(score))
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 6)
                        .cornerRadius(3)

                    Rectangle()
                        .fill(scoreColor(score))
                        .frame(width: max(0, min(geometry.size.width * CGFloat(score / 100), geometry.size.width)), height: 6)
                        .cornerRadius(3)
                }
            }
            .frame(height: 6)
        }
        .padding(.vertical, 8)
    }

    private func scoreColor(_ score: Double) -> Color {
        if score >= 70 {
            return .green
        } else if score >= 40 {
            return .orange
        } else {
            return .red
        }
    }
}

struct MealAnalysisResultView_Previews: PreviewProvider {
    static var previews: some View {
        // Mock data for preview
        let mockResponse = MealAnalysisResponse(
            meal: Meal(
                status: "success",
                analysisMetadata: AnalysisMetadata(
                    inputSources: InputSources(imageProvided: true, descriptionProvided: false, descriptionContent: nil),
                    confidenceLevel: "high",
                    imageQuality: "good",
                    analysisMethod: "AI",
                    analysisLimitations: [],
                    timestamp: 1732742400
                ),
                mealId: "123",
                totalWeightG: 300,
                totalCalories: 450,
                foodItems: [],
                mealSummary: MealSummary(
                    dataCompleteness: "complete",
                    totalProteinG: 25.0,
                    totalFatG: 15.0,
                    totalCarbsG: 50.0,
                    totalFiberG: 5.0,
                    totalSodiumMg: 800,
                    wholeGrainRatio: 0.5,
                    plantDiversityCount: 3,
                    estimatedGlycemicLoad: 25
                ),
                dataQualityFlags: DataQualityFlags(
                    imageDescriptionDiscrepancies: [],
                    invisibleIngredients: [],
                    unclearFoods: [],
                    quantityAssumptions: [],
                    uncertainQuantities: [],
                    missingNutrients: [],
                    preparationAssumptions: nil,
                    brandSpecifications: [],
                    databaseGaps: []
                ),
                recommendations: Recommendations(
                    dataImprovement: [],
                    alternativeAnalysis: []
                ),
                version: "1.0"
            ),
            overallScore: 75.0,
            proteinScore: ProteinScore(score: 80, method: "DIAAS", diaasValue: 85, pdcaasValue: 75, leucineBonus: 5),
            fatScore: FatScore(score: 70, sfaPenalty: 10, tfaPenalty: 0, omega3Bonus: 5, ldlImpact: 0),
            carbScore: CarbScore(score: 75, fiberComponent: 10, giComponent: 5, wholeGrainComponent: 15, solidCarbComponent: 10, sugarPenalty: 5),
            micronutrientScore: MicronutrientScore(score: 80, nrf93Score: 85, bioavailabilityAdjusted: true),
            pillars: Pillars(metabolic: 75, heart: 70, brain: 80, gut: 75),
            flags: Flags(usedDiaas: true, usedPdcaas: false, usedEaaProxy: false, giMissing: false, bioavailabilityAdjusted: true, imputedNutrients: [])
        )

        MealAnalysisResultView(response: mockResponse)
    }
}
