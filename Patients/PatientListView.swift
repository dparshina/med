//
//  PatientListView.swift
//  med
//
//  Created by Parshina Daria on 13.07.2025.
//

// Лист с пациентами

import SwiftUI

struct PatientListView: View {
    @ObservedObject var viewModel: PatientViewModel
    @State private var searchText = ""
    @State private var isSearchActive = false
    @State private var showingAddPatient = false
    
    var body: some View {
        NavigationView {
            VStack {
                
                if viewModel.isLoading && viewModel.patients.isEmpty {
                    ProgressView("Загрузка пациентов...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.patients.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "person.3.sequence")
                            .font(.system(size: 50))
                            .foregroundColor(.secondary)
                        
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(viewModel.patients) { patient in
                            NavigationLink(destination: PatientDetailView(patient: patient)) {
                                PatientRowView(patient: patient, searchText: searchText)
                            }
                            .onAppear {
                                
                                if !isSearchActive && patient.id == viewModel.patients.last?.id {
                                    Task {
                                        await viewModel.loadNextPage()
                                    }
                                }
                            }
                        }
                        .onDelete(perform: deletePatients)
                        
                        if viewModel.isLoading {
                            HStack {
                                Spacer()
                                ProgressView()
                                Spacer()
                            }
                        }
                    }
                    .refreshable {
                            await viewModel.refreshPatients()
                    }
                }
                
                
                if let errorMessage = viewModel.errorMessage {
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding()
                }
            }
            .navigationTitle("Пациенты")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Добавить") {
                        showingAddPatient = true
                    }
                }
            }
            .sheet(isPresented: $showingAddPatient) {
                AddPatientView(viewModel: viewModel)
            }
            .task {
                await viewModel.loadPatients()
            }
        }
    }
    
    private func deletePatients(offsets: IndexSet) {
        for index in offsets {
            let patient = viewModel.patients[index]
            Task {
                await viewModel.deletePatient(id: patient.id)
            }
        }
    }
}

