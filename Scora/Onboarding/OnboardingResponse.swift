//
//  OnboardingResponse.swift
//  Scora
//
//  Created by Errol DMello on 11/23/25.
//

import Foundation

struct OnboardingResponse: Decodable {
    let status: String
    let data: OnboardingData
}

struct OnboardingData: Decodable {
    let title: String
    let skipOption: String
    let screens: [OnboardingScreen]
}

struct OnboardingScreen: Decodable, Identifiable {
    let id: Int
    let type: ScreenType
    let title: String?
    let subtitle: String?
    let body: [BodyText]?
    let buttonText: String?
    let question: String?
    let options: [String]?
    let items: [ScoreItem]?
    let example: BiologyExample?
    let scoreDisplay: ScoreDisplay?
    let message: String?
    let programs: [Program]?
    let goals: [Goal]?
    let steps: [Step]?
    let benefits: [Benefit]?

    enum ScreenType: String, Decodable {
        case intro, problemStatement = "problem_statement"
        case valueProposition = "value_proposition"
        case featuresOverview = "features_overview"
        case featureDetail = "feature_detail"
        case scoreExplanation = "score_explanation"
        case question, results, confirmation
        case conceptIntro = "concept_intro"
        case programSelection = "program_selection"
        case weeklyGoals = "weekly_goals"
        case dailyInstructions = "daily_instructions"
        case finalSummary = "final_summary"
    }
}

struct BodyText: Decodable, Identifiable {
    let text: String
    let style: TextStyle
    
    var id: String { text }
    
    enum TextStyle: String, Decodable {
        case normal
        case highlighted
        case subtitle
    }
}



struct ScoreItem: Decodable, Identifiable {
    let number: Int
    let name: String
    let icon: String
    let description: String

    var id: Int { number }
}

struct BiologyExample: Decodable {
    let meal: String
    let metrics: [BiologyMetric]
    let suggestion: String
}

struct BiologyMetric: Decodable, Identifiable {
    let name: String
    let value: String
    let icon: String
    let color: String

    var id: String { name }
}

struct ScoreDisplay: Decodable {
    let value: Int
    let label: String
    let color: String
}

struct Program: Decodable, Identifiable {
    let id: String
    let name: String
    let description: String
}

struct Goal: Decodable, Identifiable {
    let number: Int
    let title: String
    let details: String

    var id: Int { number }
}

struct Step: Decodable, Identifiable {
    let number: Int
    let text: String

    var id: Int { number }
}

struct Benefit: Decodable, Identifiable {
    let icon: String
    let text: String

    var id: String { text }
}
