//
//  HomeView.swift
//  Scora
//
//  Created by Errol DMello on 11/23/25.
//


import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()

    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        HeaderSection()

                        TodayScoreCard(score: viewModel.todayScore)

                        BioAgeCard(bioAge: viewModel.bioAge, chronologicalAge: viewModel.chronologicalAge)

                        WeeklyGoalsSection(goals: viewModel.weeklyGoals)

                        RecentMealsSection(meals: viewModel.recentMeals)
                    }
                    .padding()
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct HeaderSection: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Good morning")
                    .font(.system(size: 15))
                    .foregroundColor(AppColors.textSecondary)

                Text("Ready to log your first meal?")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)
            }

            Spacer()

            Button(action: {}) {
                Image(systemName: "bell.fill")
                    .foregroundColor(AppColors.textSecondary)
                    .font(.system(size: 20))
            }
        }
        .padding(.top, 8)
    }
}

struct TodayScoreCard: View {
    let score: Int

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Today's Biology Impact")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)

                Spacer()

                Text("Target: 80+")
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.textSecondary)
            }

            ZStack {
                Circle()
                    .stroke(AppColors.cardBackground, lineWidth: 12)
                    .frame(width: 140, height: 140)

                Circle()
                    .trim(from: 0, to: CGFloat(score) / 100)
                    .stroke(scoreColor(score), style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .frame(width: 140, height: 140)
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 4) {
                    Text("\(score)")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(scoreColor(score))

                    Text(scoreLabel(score))
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.textSecondary)
                }
            }

            FlexiblePillLayout(metrics: BiologyMetricType.allCases, itemsPerRow: 3) { metric in
                MetricPill(metric: metric)
            }
        }
        .padding(24)
        .background(AppColors.cardBackground)
        .cornerRadius(16)
    }

    func scoreColor(_ score: Int) -> Color {
        if score >= 80 { return AppColors.primary }
        else if score >= 60 { return .orange }
        else { return .red }
    }

    func scoreLabel(_ score: Int) -> String {
        if score >= 80 { return "Excellent" }
        else if score >= 60 { return "Good" }
        else { return "Needs Work" }
    }
}

enum BiologyMetricType: String, CaseIterable {
    case heart = "Heart"
    case brain = "Brain"
    case gut = "Gut"
    case metabolism = "Metabolism"

    var icon: String {
        switch self {
        case .heart: return "heart.fill"
        case .brain: return "brain.head.profile"
        case .gut: return "leaf.fill"
        case .metabolism: return "flame.fill"
        }
    }
}

struct MetricPill: View {
    let metric: BiologyMetricType

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: metric.icon)
                .font(.system(size: 12))
            Text(metric.rawValue)
                .font(.system(size: 12))
        }
        .foregroundColor(AppColors.textSecondary)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(AppColors.background)
        .cornerRadius(12)
    }
}

struct FlexiblePillLayout<Item: Hashable, Content: View>: View {
    let items: [Item]
    let itemsPerRow: Int
    let horizontalSpacing: CGFloat
    let verticalSpacing: CGFloat
    let content: (Item) -> Content

    init(
        metrics: [Item],
        itemsPerRow: Int = 3,
        horizontalSpacing: CGFloat = 12,
        verticalSpacing: CGFloat = 8,
        @ViewBuilder content: @escaping (Item) -> Content
    ) {
        self.items = metrics
        self.itemsPerRow = itemsPerRow
        self.horizontalSpacing = horizontalSpacing
        self.verticalSpacing = verticalSpacing
        self.content = content
    }

    var body: some View {
        VStack(spacing: verticalSpacing) {
            ForEach(0..<numberOfRows, id: \.self) { rowIndex in
                HStack(spacing: horizontalSpacing) {
                    ForEach(itemsInRow(rowIndex), id: \.self) { item in
                        content(item)
                    }
                }
            }
        }
    }

    private var numberOfRows: Int {
        (items.count + itemsPerRow - 1) / itemsPerRow
    }

    private func itemsInRow(_ rowIndex: Int) -> [Item] {
        let startIndex = rowIndex * itemsPerRow
        let endIndex = min(startIndex + itemsPerRow, items.count)
        return Array(items[startIndex..<endIndex])
    }
}

struct BioAgeCard: View {
    let bioAge: Int
    let chronologicalAge: Int

    var body: some View {
        HStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Your BioAge")
                    .font(.system(size: 15))
                    .foregroundColor(AppColors.textSecondary)

                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(bioAge)")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(AppColors.primary)

                    Text("years")
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.textSecondary)
                }

                Text("\(abs(bioAge - chronologicalAge)) years younger")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppColors.primary)
            }

            Spacer()

            VStack(spacing: 8) {
                Image(systemName: "arrow.down.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(AppColors.primary)

                Text("Trending younger")
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.textSecondary)
            }
        }
        .padding(20)
        .background(AppColors.cardBackground)
        .cornerRadius(16)
    }
}

struct WeeklyGoalsSection: View {
    let goals: [WeeklyGoal]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("This Week's Goals")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(AppColors.textPrimary)

            VStack(spacing: 12) {
                ForEach(goals) { goal in
                    WeeklyGoalRow(goal: goal)
                }
            }
        }
    }
}

struct WeeklyGoalRow: View {
    let goal: WeeklyGoal

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: goal.isCompleted ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 24))
                .foregroundColor(goal.isCompleted ? AppColors.primary : AppColors.textSecondary)

            VStack(alignment: .leading, spacing: 4) {
                Text(goal.title)
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.textPrimary)

                Text("\(goal.currentCount)/\(goal.targetCount) days")
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.textSecondary)
            }

            Spacer()

            ProgressView(value: Double(goal.currentCount), total: Double(goal.targetCount))
                .progressViewStyle(LinearProgressViewStyle(tint: AppColors.primary))
                .frame(width: 60)
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(12)
    }
}

struct RecentMealsSection: View {
    let meals: [MealLog]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recent Meals")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)

                Spacer()

                Button("View All") {}
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.primary)
            }

            VStack(spacing: 12) {
                ForEach(meals) { meal in
                    MealLogRow(meal: meal)
                }
            }
        }
    }
}

struct MealLogRow: View {
    let meal: MealLog

    var body: some View {
        HStack(spacing: 16) {
            RoundedRectangle(cornerRadius: 12)
                .fill(AppColors.cardBackground)
                .frame(width: 60, height: 60)
                .overlay(
                    Image(systemName: "fork.knife")
                        .foregroundColor(AppColors.textSecondary)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(meal.name)
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.textPrimary)

                Text(meal.time)
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.textSecondary)
            }

            Spacer()

            Text("\(meal.score)")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(scoreColor(meal.score))
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(12)
    }

    func scoreColor(_ score: Int) -> Color {
        if score >= 80 { return AppColors.primary }
        else if score >= 60 { return .orange }
        else { return .red }
    }
}

class HomeViewModel: ObservableObject {
    @Published var todayScore: Int = 77
    @Published var bioAge: Int = 32
    @Published var chronologicalAge: Int = 38
    @Published var weeklyGoals: [WeeklyGoal] = []
    @Published var recentMeals: [MealLog] = []

    init() {
        loadData()
    }

    func loadData() {
        weeklyGoals = [
            WeeklyGoal(id: "1", title: "Protein-first breakfast", currentCount: 3, targetCount: 5, isCompleted: false),
            WeeklyGoal(id: "2", title: "No late-night snacking", currentCount: 2, targetCount: 2, isCompleted: true)
        ]

        recentMeals = [
            MealLog(id: "1", name: "Avocado toast with eggs", time: "8:30 AM", score: 85),
            MealLog(id: "2", name: "Grilled chicken salad", time: "1:15 PM", score: 92),
            MealLog(id: "3", name: "Pasta with vegetables", time: "7:00 PM", score: 68)
        ]
    }
}

struct WeeklyGoal: Identifiable {
    let id: String
    let title: String
    let currentCount: Int
    let targetCount: Int
    let isCompleted: Bool
}

struct MealLog: Identifiable {
    let id: String
    let name: String
    let time: String
    let score: Int
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .preferredColorScheme(.dark)
    }
}
