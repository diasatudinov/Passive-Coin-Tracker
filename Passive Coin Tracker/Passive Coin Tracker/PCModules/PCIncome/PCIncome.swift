//
//  PCIncome.swift
//  Passive Coin Tracker
//
//

import SwiftUI

struct Income: Codable, Hashable {
    var id = UUID()
    var source: IncomeSource
    var date: Date
    var amount: Decimal
}

enum IncomeSource: String, CaseIterable, Codable {
    case dividends = "Dividends"
    case apartmentRental = "Apartment rental"
    case royalties = "Royalties from the course"
    case bonds = "Bonds"
    case other = "Other"
    
    var title: String {
        self.rawValue
    }
}
