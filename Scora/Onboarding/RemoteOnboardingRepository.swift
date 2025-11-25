//
//  RemoteOnboardingRepository.swift
//  Scora
//
//  Created by Errol DMello on 11/23/25.
//

import Foundation

final class RemoteOnboardingRepository {

    private let baseURL: String
    private let session: URLSession

    enum RemoteRepositoryError: Error {
        case invalidURL
        case networkError(Error)
        case invalidResponse
        case decodingError(Error)
        case serverError(statusCode: Int)
    }

    init(baseURL: String = "https://api.scora.com", session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }

    func fetchOnboardingData() async throws -> OnboardingResponse {
        guard let url = URL(string: "\(baseURL)/v1/onboarding") else {
            throw RemoteRepositoryError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw RemoteRepositoryError.invalidResponse
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                throw RemoteRepositoryError.serverError(statusCode: httpResponse.statusCode)
            }

            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase

            do {
                return try decoder.decode(OnboardingResponse.self, from: data)
            } catch {
                throw RemoteRepositoryError.decodingError(error)
            }

        } catch let error as RemoteRepositoryError {
            throw error
        } catch {
            throw RemoteRepositoryError.networkError(error)
        }
    }

    func submitAnswers(_ answers: [String]) async throws -> OnboardingResponse {
        guard let url = URL(string: "\(baseURL)/v1/onboarding/submit") else {
            throw RemoteRepositoryError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Create request body
        let requestBody: [String: [String]] = ["answers": answers]

        do {
            request.httpBody = try JSONEncoder().encode(requestBody)
        } catch {
            throw RemoteRepositoryError.decodingError(error)
        }

        do {
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw RemoteRepositoryError.invalidResponse
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                throw RemoteRepositoryError.serverError(statusCode: httpResponse.statusCode)
            }

            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase

            do {
                let resultResponse = try decoder.decode(OnboardingResultResponse.self, from: data)

                // Convert OnboardingResultResponse to OnboardingResponse
                return OnboardingResponse(
                    status: resultResponse.status,
                    data: OnboardingData(
                        title: "",
                        skipOption: "",
                        screens: resultResponse.data.screens
                    )
                )
            } catch {
                throw RemoteRepositoryError.decodingError(error)
            }

        } catch let error as RemoteRepositoryError {
            throw error
        } catch {
            throw RemoteRepositoryError.networkError(error)
        }
    }
}
