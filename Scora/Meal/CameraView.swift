//
//  CameraView.swift
//  Scora
//
//  Created by Errol DMello on 11/25/25.
//

import SwiftUI

struct CameraView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            VStack {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(AppColors.textPrimary)
                            .font(.system(size: 20))
                            .padding()
                    }

                    Spacer()
                }

                Spacer()

                // Camera preview placeholder
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.gray.opacity(0.3))
                    .aspectRatio(3/4, contentMode: .fit)
                    .overlay(
                        Image(systemName: "camera.fill")
                            .font(.system(size: 60))
                            .foregroundColor(AppColors.textSecondary)
                    )
                    .padding()

                Spacer()

                // Capture button
                Button(action: {}) {
                    Circle()
                        .stroke(AppColors.primary, lineWidth: 4)
                        .frame(width: 70, height: 70)
                        .overlay(
                            Circle()
                                .fill(AppColors.primary)
                                .frame(width: 60, height: 60)
                        )
                }
                .padding(.bottom, 40)
            }
        }
    }
}
