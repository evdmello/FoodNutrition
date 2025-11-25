//
//  ScoresView.swift
//  Scora
//
//  Created by Errol DMello on 11/23/25.
//


import SwiftUI

struct ScoresView: View {
    @StateObject private var viewModel = ScoresViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Time period selector
                        TimePeriodSelector(selectedPeriod: $viewModel.selectedPeriod)
                        
                        // Biology Impact Chart
//                        BiologyImpactChart(data: viewModel.scoreHistory)
                        
                        // Detailed Metrics
                        DetailedMetricsSection(metrics: viewModel.detailedMetrics)
                        
                        // Score Breakdown
                        ScoreBreakdownSection(breakdown: viewModel.scoreBreakdown)
                    }
                    .padding()
                }
            }
            .navigationTitle("Your Scores")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct TimePeriodSelector: View {
    @Binding var selectedPeriod: TimePeriod
    
    var body: some View {
        HStack(spacing: 12) {
            ForEach(TimePeriod.allCases, id: \.self) { period in
                Button(action: { selectedPeriod = period }) {
                    Text(period.rawValue)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(selectedPeriod == period ? .white : AppColors.textSecondary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(selectedPeriod == period ? AppColors.primary : AppColors.cardBackground)
                        .cornerRadius(8)
                }
            }
        }
    }
}

enum TimePeriod: String, CaseIterable {
    case day = "Day"
    case week = "Week"
    case month = "Month"
}

struct BiologyImpactChart: View {
    let data: [ScoreDataPoint]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Biology Impact Trend")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(AppColors.textPrimary)
            
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppColors.cardBackground)
                    .frame(height: 200)
                
                VStack {
                    Text("Chart")
                        .foregroundColor(AppColors.textSecondary)
                    Text("Use Swift Charts or custom drawing")
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.textSecondary)
                }
            }
        }
    }
}

struct DetailedMetricsSection: View {
    let metrics: [DetailedMetric]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Detailed Breakdown")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(AppColors.textPrimary)
            
            VStack(spacing: 12) {
                ForEach(metrics) { metric in
                    DetailedMetricRow(metric: metric)
                }
            }
        }
    }
}

struct DetailedMetricRow: View {
    let metric: DetailedMetric
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: metric.icon)
                        .foregroundColor(AppColors.primary)
                    Text(metric.name)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(AppColors.textPrimary)
                }
                
                Spacer()
                
                Text(metric.value)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(metricColor(metric.status))
            }
            
            ProgressView(value: metric.percentage, total: 100)
                .progressViewStyle(LinearProgressViewStyle(tint: metricColor(metric.status)))
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(12)
    }
    
    func metricColor(_ status: MetricStatus) -> Color {
        switch status {
        case .excellent: return AppColors.primary
        case .good: return .orange
        case .needsWork: return .red
        }
    }
}

struct ScoreBreakdownSection: View {
    let breakdown: ScoreBreakdown
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Score Components")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(AppColors.textPrimary)
            
            VStack(spacing: 12) {
                ScoreComponent(title: "Meal Quality", score: breakdown.mealQuality)
                ScoreComponent(title: "Nutrient Balance", score: breakdown.nutrientBalance)
                ScoreComponent(title: "Timing", score: breakdown.timing)
                ScoreComponent(title: "Hydration", score: breakdown.hydration)
            }
        }
    }
}

struct ScoreComponent: View {
    let title: String
    let score: Int
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 15))
                .foregroundColor(AppColors.textSecondary)
            
            Spacer()
            
            Text("\(score)")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(AppColors.textPrimary)
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(12)
    }
}

struct ScoreDataPoint: Identifiable {
    let id: String
    let date: Date
    let score: Int
}

struct DetailedMetric: Identifiable {
    let id: String
    let name: String
    let icon: String
    let value: String
    let percentage: Double
    let status: MetricStatus
}

enum MetricStatus {
    case excellent, good, needsWork
}

struct ScoreBreakdown {
    let mealQuality: Int
    let nutrientBalance: Int
    let timing: Int
    let hydration: Int
}

struct ScoresView_Previews: PreviewProvider {
    static var previews: some View {
        ScoresView()
            .preferredColorScheme(.dark)
    }
}
