//
//  med_newApp.swift
//  med_new
//
//  Created by Parshina Daria on 14.07.2025.
//

import SwiftUI

@main
struct med_newApp: App {
    @StateObject private var patientViewModel = PatientViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView(patientViewModel: PatientViewModel())
        }
    }
}
