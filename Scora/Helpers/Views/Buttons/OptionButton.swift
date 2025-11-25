//
//  OptionButton.swift
//  Scora
//
//  Created by Errol DMello on 11/25/25.
//

import SwiftUI

struct OptionButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 17))
                .foregroundColor(AppColors.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected ? AppColors.primary : Color.gray.opacity(0.3), lineWidth: 2)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(isSelected ? AppColors.primary.opacity(0.1) : AppColors.cardBackground)
                        )
                )
        }
    }
}
