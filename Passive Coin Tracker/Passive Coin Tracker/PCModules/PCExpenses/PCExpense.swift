//
//  PCExpense.swift
//  Passive Coin Tracker
//
//

import SwiftUI

struct Expense: Codable, Hashable {
    var id = UUID()
    var category: ExpenseCategory
    var description: String
    var date: Date
    var amount: Decimal
}

enum ExpenseCategory: String, CaseIterable, Codable {
    case housing = "Housing"
    case food = "Food"
    case medicine = "Medicine"
    case transport = "Transport"
    case internet = "Internet"
    case other = "Other"
    
    var title: String {
        self.rawValue
    }
    
    var color: Color {
        switch self {
        case .housing:
                .expensesAccent
        case .food:
                .accent
        case .medicine:
                .orange
        case .transport:
                .expensesBlue
        case .internet:
                .pink
        case .other:
                .purple
        }
    }
}
