//
//  ContentView.swift
//  med_new
//
//  Created by Parshina Daria on 14.07.2025.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var patientViewModel: PatientViewModel
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {

            PatientListView(viewModel: patientViewModel)
                .tabItem {
                    Image(systemName: "person.3.fill")
                    Text("Пациенты")
                }
                .tag(0)
            
        }
    }
}

// MARK: - Patient Selection View
struct PatientSelectionView: View {
    @ObservedObject var patientViewModel: PatientViewModel
    let onPatientSelected: (PatientDTO) -> Void
    @State private var searchText = ""
    
    var body: some View {
        if patientViewModel.isLoading && patientViewModel.patients.isEmpty {
            ProgressView("Загрузка пациентов...")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if patientViewModel.patients.isEmpty {
            VStack(spacing: 20) {
                Image(systemName: "person.3.sequence")
                    .font(.system(size: 50))
                    .foregroundColor(.secondary)
                
                Text("Нет пациентов")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Text("Создайте пациента")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            List(patientViewModel.patients) { patient in
                Button(action: {
                    onPatientSelected(patient)
                }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(patient.firstName) \(patient.lastName)")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Text("Возраст: \(patient.age)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text("Дата рождения: \(patient.dateOfBirth)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            .refreshable {
                await patientViewModel.refreshPatients()
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(patientViewModel: PatientViewModel())
    }
}
