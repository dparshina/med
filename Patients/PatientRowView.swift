//
//  PatientRowView.swift
//  med
//
//  Created by Parshina Daria on 14.07.2025.
//

// формат ячейки в листе пациентов на главной странице


import SwiftUICore

struct PatientRowView: View {
    let patient: PatientDTO
    let searchText: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(patient.firstName + " " + patient.lastName)
                .font(.headline)
            

            
            Text("Возраст: \(formatAge(from: patient.dateOfBirth))")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
        }
        .padding(.vertical, 2)
    }

    func formatAge(from dateString: String, format: String = "yyyy-MM-dd") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        let birthDate = formatter.date(from: dateString)

        let currentDate = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: birthDate!, to: currentDate)

        let years = components.year ?? 0
        let months = components.month ?? 0
        let days = components.day ?? 0

        var number = 0
        var wordOne = ""
        var wordFew = ""
        var wordMany = ""

        if years >= 1 {
            number = years
            wordOne = "год"
            wordFew = "года"
            wordMany = "лет"
        } else if months >= 1 {
            number = months
            wordOne = "месяц"
            wordFew = "месяца"
            wordMany = "месяцев"
        } else {
            number = days
            wordOne = "день"
            wordFew = "дня"
            wordMany = "дней"
        }

        let lastTwoDigits = number % 100
        let lastDigit = number % 10
        let word: String

        if lastTwoDigits >= 11 && lastTwoDigits <= 14 {
            word = wordMany
        } else if lastDigit == 1 {
            word = wordOne
        } else if lastDigit >= 2 && lastDigit <= 4 {
            word = wordFew
        } else {
            word = wordMany
        }

        return "\(number) \(word)"
    }
}
