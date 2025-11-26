//
//  LogMealViewModel.swift
//  Scora
//
//  Created by Errol DMello on 11/25/25.
//

import SwiftUI

class LogMealViewModel: ObservableObject {
    @Published var navigateToCamera = false
    @Published var showVoiceLog = false
    @Published var showManualEntry = false

    func openCamera() {
        navigateToCamera = true
    }

    func openVoiceLog() {
        showVoiceLog = true
    }

    func openManualEntry() {
        showManualEntry = true
    }
}
