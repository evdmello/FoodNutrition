//
//  OnboardingResultResponse.swift
//  Scora
//
//  Created by Errol DMello on 11/25/25.
//

import Foundation

/// Response structure for the onboarding answer submission API
/// Reuses OnboardingScreen and related structs from OnboardingResponse.swift
struct OnboardingResultResponse: Decodable {
    let status: String
    let data: OnboardingResultData
}

struct OnboardingResultData: Decodable {
    let screens: [OnboardingScreen]
}
