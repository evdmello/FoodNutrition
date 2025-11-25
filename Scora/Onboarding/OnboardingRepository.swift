//
//  OnboardingRepository.swift
//  Scora
//
//  Created by Errol DMello on 11/23/25.
//

import Foundation

enum OnboardingDataSource {
    case local
    case remote
}

protocol OnboardingRepositoryProtocol {
    func fetchOnboardingData() async throws -> OnboardingResponse
    func submitAnswers(_ answers: [String]) async throws -> OnboardingResponse
}

final class OnboardingRepository: OnboardingRepositoryProtocol {
    private let dataSource: OnboardingDataSource
    private let localRepository: LocalOnboardingRepository
    private let remoteRepository: RemoteOnboardingRepository

    init(dataSource: OnboardingDataSource = .local) {
        self.dataSource = dataSource
        self.localRepository = LocalOnboardingRepository()
        self.remoteRepository = RemoteOnboardingRepository()
    }

    func fetchOnboardingData() async throws -> OnboardingResponse {
        switch dataSource {
        case .local:
            return try localRepository.fetchOnboardingData()
        case .remote:
            return try await remoteRepository.fetchOnboardingData()
        }
    }

    func submitAnswers(_ answers: [String]) async throws -> OnboardingResponse {
        switch dataSource {
        case .local:
            return try localRepository.submitAnswers(answers)
        case .remote:
            return try await remoteRepository.submitAnswers(answers)
        }
    }
}
