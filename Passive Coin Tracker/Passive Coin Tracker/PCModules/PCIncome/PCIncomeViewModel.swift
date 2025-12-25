//
//  PCIncomeViewModel.swift
//  Passive Coin Tracker
//
//

import Foundation

final class PCIncomeViewModel: ObservableObject {
    @Published var goal: Decimal = 0 {
        didSet {
            saveGoal()
        }
    }
    
    @Published var incomes: [Income] = [
        Income(source: .apartmentRental, date: .now, amount: 500),
        Income(source: .royalties, date: .now, amount: 1500),
    ]
    
    init() {
        loadGoal()
    }
    
    private let userDefaultsGoalKey = "goalKey"
    
    
    
    
    func saveGoal() {
        if let encodedData = try? JSONEncoder().encode(goal) {
            UserDefaults.standard.set(encodedData, forKey: userDefaultsGoalKey)
        }
        
    }
    
    func loadGoal() {
        if let savedData = UserDefaults.standard.data(forKey: userDefaultsGoalKey),
           let loadedItem = try? JSONDecoder().decode(Decimal.self, from: savedData) {
            goal = loadedItem
        } else {
            print("No saved data found")
        }
    }
    
    func setGoal(goal: String) {
        let goalAmount = Decimal(string: goal) ?? 0
        self.goal = goalAmount
    }
    
    func addIncome(_ income: Income) {
        incomes.append(income)
    }
    
    func getIncomeSum() -> Decimal {
        var sum: Decimal = 0
        for income in incomes {
            sum += income.amount
        }
        return sum
    }
    
    func monthlyProgress(goal: Decimal, income: Decimal) -> CGFloat {
        guard goal > 0 else { return 0 }
        let fraction = income / goal
        return min(max(fraction.cgFloatValue, 0), 1)
    }
    
    func progressPercent(goal: Decimal, income: Decimal) -> Decimal {
        guard goal > 0 else { return 0 }
        let fraction = income / goal
        return min(max(fraction, 0), 1)
    }
}


extension Decimal {
    var cgFloatValue: CGFloat {
        CGFloat(NSDecimalNumber(decimal: self).doubleValue)
    }
}
