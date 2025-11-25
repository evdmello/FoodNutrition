//
//  LogMealViewModel.swift
//  Scora
//
//  Created by Errol DMello on 11/25/25.
//

import SwiftUI

class LogMealViewModel: ObservableObject {
    @Published var showCamera = false
    @Published var showVoiceLog = false
    @Published var showManualEntry = false

    func openCamera() {
        showCamera = true
    }

    func openVoiceLog() {
        showVoiceLog = true
    }

    func openManualEntry() {
        showManualEntry = true
    }
}
