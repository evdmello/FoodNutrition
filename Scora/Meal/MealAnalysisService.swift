//
//  MealAnalysisService.swift
//  Scora
//
//  Created by Errol DMello on 11/25/25.
//

import Foundation
import UIKit

struct MealAnalysisResponse: Codable {
    let meal: Meal
    let overallScore: Double
    let proteinScore: ProteinScore
    let fatScore: FatScore
    let carbScore: CarbScore
    let micronutrientScore: MicronutrientScore
    let pillars: Pillars
    let flags: Flags
}

struct Meal: Codable {
    let status: String
    let analysisMetadata: AnalysisMetadata
    let mealId: String?
    let totalWeightG: Double?
    let totalCalories: Double?
    let foodItems: [FoodItem]
    let mealSummary: MealSummary
    let dataQualityFlags: DataQualityFlags
    let recommendations: Recommendations
    let version: String
}

struct AnalysisMetadata: Codable {
    let inputSources: InputSources
    let confidenceLevel: String
    let imageQuality: String
    let analysisMethod: String
    let analysisLimitations: [String]
    let timestamp: Int64
}

struct InputSources: Codable {
    let imageProvided: Bool?
    let descriptionProvided: Bool?
    let descriptionContent: String?
}

struct FoodItem: Codable {
    let name: String
    let identificationSource: String
    let identificationConfidence: String
    let quantityG: Double
    let quantitySource: String
    let quantityMethod: String?
    let discrepancies: String?
    let foodGroup: String
    let processingLevel: String
    let nutrients: Nutrients
    let proteinQuality: ProteinQuality?
    let notes: String
}

struct Nutrients: Codable {
    let dataSource: String
    let dataReliability: String
    let caloriesPer100g: Double
    let proteinG: Double
    let totalFatG: Double
    let saturatedFatG: Double
    let monounsaturatedFatG: Double
    let polyunsaturatedFatG: Double
    let transFatG: Double
    let omega3EpaDhaMg: Double
    let totalCarbsG: Double
    let fiberG: Double
    let addedSugarsG: Double
    let sodiumMg: Double
    let potassiumMg: Double
    let ironMg: Double
    let ironType: String
    let zincMg: Double
    let calciumMg: Double
    let vitaminARae: Double
    let vitaminCMg: Double
    let folateMcg: Double?
    let vitaminB12Mcg: Double?
    let glycemicIndex: Double?
}

struct ProteinQuality: Codable {
    let diaasScore: Double?
    let pdcaasScore: Double?
    let leucineMg: Double
    let lysineMg: Double
    let methionineMg: Double
    let dataAvailability: String
}

struct MealSummary: Codable {
    let dataCompleteness: String
    let totalProteinG: Double
    let totalFatG: Double
    let totalCarbsG: Double
    let totalFiberG: Double
    let totalSodiumMg: Double
    let wholeGrainRatio: Double
    let plantDiversityCount: Int
    let estimatedGlycemicLoad: Double
}

struct DataQualityFlags: Codable {
    let imageDescriptionDiscrepancies: [String]
    let invisibleIngredients: [String]
    let unclearFoods: [String]
    let quantityAssumptions: [String]
    let uncertainQuantities: [String]
    let missingNutrients: [String]
    let preparationAssumptions: String?
    let brandSpecifications: [String]
    let databaseGaps: [String]
}

struct Recommendations: Codable {
    let dataImprovement: [String]
    let alternativeAnalysis: [String]
}

struct ProteinScore: Codable {
    let score: Double
    let method: String
    let diaasValue: Double
    let pdcaasValue: Double
    let leucineBonus: Double
}

struct FatScore: Codable {
    let score: Double
    let sfaPenalty: Double
    let tfaPenalty: Double
    let omega3Bonus: Double
    let ldlImpact: Double
}

struct CarbScore: Codable {
    let score: Double
    let fiberComponent: Double
    let giComponent: Double
    let wholeGrainComponent: Double
    let solidCarbComponent: Double
    let sugarPenalty: Double
}

struct MicronutrientScore: Codable {
    let score: Double
    let nrf93Score: Double
    let bioavailabilityAdjusted: Bool
}

struct Pillars: Codable {
    let metabolic: Double
    let heart: Double
    let brain: Double
    let gut: Double
}

struct Flags: Codable {
    let usedDiaas: Bool
    let usedPdcaas: Bool
    let usedEaaProxy: Bool
    let giMissing: Bool
    let bioavailabilityAdjusted: Bool
    let imputedNutrients: [String]
}

class MealAnalysisService {
    static let shared = MealAnalysisService()
    private let baseURL = "https://api.biteapp.co.in/valinor"

    private init() {}

    func analyzeImage(image: UIImage, description: String = "", completion: @escaping (Result<MealAnalysisResponse, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/analyze-image") else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1)))
            return
        }

        let boundary = UUID().uuidString
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(.failure(NSError(domain: "Image conversion failed", code: -1)))
            return
        }

        var body = Data()

        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"description\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(description)\r\n".data(using: .utf8)!)

        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"meal.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)

        // Close boundary
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = body

        // Perform the request
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "No data received", code: -1)))
                }
                return
            }

            // Try to decode the response
            do {
                let analysisResponse = try JSONDecoder().decode(MealAnalysisResponse.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(analysisResponse))
                }
            } catch {
                // If decoding fails, print the raw response for debugging
                if let rawResponse = String(data: data, encoding: .utf8) {
                    print("Raw API response: \(rawResponse)")
                }
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
}
