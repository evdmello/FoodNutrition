//
//  ScoresViewModel.swift
//  Scora
//
//  Created by Errol DMello on 11/25/25.
//

import SwiftUI

class ScoresViewModel: ObservableObject {
    @Published var selectedPeriod: TimePeriod = .week
    @Published var scoreHistory: [ScoreDataPoint] = []
    @Published var detailedMetrics: [DetailedMetric] = []
    @Published var scoreBreakdown: ScoreBreakdown = ScoreBreakdown(mealQuality: 85, nutrientBalance: 78, timing: 82, hydration: 70)
    
    init() {
        loadData()
    }
    
    func loadData() {
        detailedMetrics = [
            DetailedMetric(id: "1", name: "Heart Load", icon: "heart.fill", value: "Light", percentage: 85, status: .excellent),
            DetailedMetric(id: "2", name: "Brain Clarity", icon: "brain.head.profile", value: "High", percentage: 90, status: .excellent),
            DetailedMetric(id: "3", name: "Gut Ease", icon: "leaf.fill", value: "Balanced", percentage: 75, status: .good),
            DetailedMetric(id: "4", name: "Metabolic Balance", icon: "flame.fill", value: "Moderate", percentage: 65, status: .good)
        ]
    }
}
