//
//  OnboardingResultResponse.swift
//  Scora
//
//  Created by Errol DMello on 11/25/25.
//

import Foundation

struct OnboardingResultResponse: Decodable {
    let status: String
    let data: OnboardingResultData
}

struct OnboardingResultData: Decodable {
    let screens: [OnboardingScreen]
}
