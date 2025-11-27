//
//  LocalOnboardingRepository.swift
//  Scora
//
//  Created by Errol DMello on 11/23/25.
//

import Foundation

final class LocalOnboardingRepository {

    enum LocalRepositoryError: Error {
        case fileNotFound
        case invalidData
        case decodingError(Error)
    }

    func fetchOnboardingData() throws -> OnboardingResponse {
        guard let url = Bundle.main.url(forResource: "onboarding", withExtension: "json") else {
            throw LocalRepositoryError.fileNotFound
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(OnboardingResponse.self, from: data)
        } catch let error as DecodingError {
            throw LocalRepositoryError.decodingError(error)
        } catch {
            throw LocalRepositoryError.invalidData
        }
    }

    func submitAnswers(_ answers: [String]) throws -> OnboardingResponse {
        guard let url = Bundle.main.url(forResource: "onboarding-result", withExtension: "json") else {
            throw LocalRepositoryError.fileNotFound
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase

            let resultResponse = try decoder.decode(OnboardingResultResponse.self, from: data)

            return OnboardingResponse(
                status: resultResponse.status,
                data: OnboardingData(
                    title: "",
                    skipOption: "",
                    screens: resultResponse.data.screens
                )
            )
        } catch let error as DecodingError {
            throw LocalRepositoryError.decodingError(error)
        } catch {
            throw LocalRepositoryError.invalidData
        }
    }
}
