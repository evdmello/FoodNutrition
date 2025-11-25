//
//  OnboardingViewModel.swift
//  Scora
//
//  Created by Errol DMello on 11/23/25.
//


import SwiftUI

final class OnboardingViewModel: ObservableObject {
    @Published var currentScreenIndex = 0
    @Published var userAnswers: [Int: String] = [:]
    @Published var selectedProgram: String?
    @Published var isComplete = false
    @Published var screens: [OnboardingScreen] = []
    @Published var isLoading = false
    @Published var error: Error?

    private let repository: OnboardingRepositoryProtocol

    var currentScreen: OnboardingScreen {
        guard !screens.isEmpty, currentScreenIndex < screens.count else {
            return OnboardingScreen(
                id: 0,
                type: .intro,
                title: "Loading...",
                subtitle: nil,
                body: nil,
                buttonText: nil,
                question: nil,
                options: nil,
                items: nil,
                example: nil,
                scoreDisplay: nil,
                message: nil,
                programs: nil,
                goals: nil,
                steps: nil,
                benefits: nil
            )
        }
        return screens[currentScreenIndex]
    }

    var progress: Double {
        guard !screens.isEmpty else { return 0 }
        return Double(currentScreenIndex + 1) / Double(screens.count)
    }

    var canGoBack: Bool {
        currentScreenIndex > 0
    }

    init(repository: OnboardingRepositoryProtocol? = nil) {
        // Default to local repository, can be switched to remote
        self.repository = repository ?? OnboardingRepository(dataSource: .local)
    }

    @MainActor
    func loadOnboardingData() async {
        isLoading = true
        error = nil

        do {
            let data = try await repository.fetchOnboardingData()
            screens = data.data.screens
        } catch {
            self.error = error
            print("Error loading onboarding data: \(error)")
        }

        isLoading = false
    }

    func nextScreen() {
        if currentScreenIndex < screens.count - 1 {
            withAnimation {
                currentScreenIndex += 1
            }
        } else {
            isComplete = true
        }
    }

    func previousScreen() {
        if canGoBack {
            withAnimation {
                currentScreenIndex -= 1
            }
        }
    }

    func selectAnswer(screenId: Int, answer: String) {
        userAnswers[screenId] = answer

        // Check if all questions are answered
        let questionScreens = screens.filter { $0.type == .question }
        let allQuestionsAnswered = questionScreens.allSatisfy { screen in
            userAnswers[screen.id] != nil
        }

        // If all questions are answered, submit answers
        if allQuestionsAnswered && userAnswers.count == questionScreens.count {
            Task {
                await submitAnswers()
            }
        } else {
            // Auto-advance for questions
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.nextScreen()
            }
        }
    }

    @MainActor
    func submitAnswers() async {
        isLoading = true
        error = nil

        // Get all question screens in order
        let questionScreens = screens.filter { $0.type == .question }.sorted { $0.id < $1.id }

        // Create answers array in the order of question screens
        let answersArray = questionScreens.compactMap { screen in
            userAnswers[screen.id]
        }

        do {
            let response = try await repository.submitAnswers(answersArray)

            // Find the last question screen index
//            if let lastQuestionIndex = screens.lastIndex(where: { $0.type == .question }) {
//                // Append the new screens from the response
//
//            }
            screens.append(contentsOf: response.data.screens)
            // Move to the next screen (results screen)
            self.nextScreen()
        } catch {
            self.error = error
            print("Error submitting answers: \(error)")
        }

        isLoading = false
    }

    func selectProgram(_ programId: String) {
        selectedProgram = programId
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.nextScreen()
        }
    }
}
