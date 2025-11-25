//
//  ManualEntryView.swift
//  Scora
//
//  Created by Errol DMello on 11/25/25.
//

import SwiftUI

struct ManualEntryView: View {
    @Environment(\.dismiss) var dismiss
    @State private var mealName = ""
    @State private var ingredients = ""

    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Meal Name")
                                .font(.system(size: 15))
                                .foregroundColor(AppColors.textSecondary)

                            TextField("e.g., Grilled chicken salad", text: $mealName)
                                .font(.system(size: 17))
                                .foregroundColor(AppColors.textPrimary)
                                .padding()
                                .background(AppColors.cardBackground)
                                .cornerRadius(12)
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Ingredients & Portions")
                                .font(.system(size: 15))
                                .foregroundColor(AppColors.textSecondary)

                            TextEditor(text: $ingredients)
                                .font(.system(size: 17))
                                .foregroundColor(AppColors.textPrimary)
                                .frame(height: 200)
                                .padding()
                                .background(AppColors.cardBackground)
                                .cornerRadius(12)
                        }

                        PrimaryButton(title: "Analyze Meal") {
                            // Analyze logic
                            dismiss()
                        }
                    }
                    .padding(24)
                }
            }
            .navigationTitle("Manual Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(AppColors.textSecondary)
                }
            }
        }
    }
}
