//
//  MealAnalysisService.swift
//  Scora
//
//  Created by Errol DMello on 11/25/25.
//

import Foundation
import UIKit

struct MealAnalysisResponse: Codable {
    // Add the expected response fields from your API
    // Update these based on what the API returns
    let success: Bool?
    let data: MealAnalysisData?
    let message: String?
}

struct MealAnalysisData: Codable {
    // Update these fields based on your API response
    let foodItems: [String]?
    let nutrition: NutritionInfo?
    let confidence: Double?
}

struct NutritionInfo: Codable {
    let calories: Double?
    let protein: Double?
    let carbs: Double?
    let fats: Double?
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
