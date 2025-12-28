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
    
    @Published var incomes: [Income] = [] {
        didSet {
            saveIncomes()
        }
    }
    
    var currentMonthIncomes: [Income] {
        let cal = Calendar.current
        return incomes.filter { income in
            cal.isDate(income.date, equalTo: Date(), toGranularity: .month)
        }
    }
    
    var currentYearIncomes: [Income] {
        let cal = Calendar.current
        return incomes.filter { income in
            cal.isDate(income.date, equalTo: Date(), toGranularity: .year)
        }
    }
    
    @Published var expenses: [Expense] = [] {
        didSet {
            saveExpenses()
        }
    }
    
    var currentMonthExpenses: [Expense] {
        let cal = Calendar.current
        return expenses.filter { expense in
            cal.isDate(expense.date, equalTo: Date(), toGranularity: .month)
        }
    }
    
    var currentYearExpenses: [Expense] {
        let cal = Calendar.current
        return expenses.filter { expense in
            cal.isDate(expense.date, equalTo: Date(), toGranularity: .year)
        }
    }
    
    init() {
        loadGoal()
        loadIncomes()
        loadExpenses()
    }
    
    private let userDefaultsGoalKey = "goalKey"
    private let userDefaultsIncomesKey = "incomesKey"
    private let userDefaultsExpensesKey = "expensesKey"

    // MARK: GOAL
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
            print("No saved data found: goal")
        }
    }
    
    // MARK: INCOMES
    
    func saveIncomes() {
        if let encodedData = try? JSONEncoder().encode(incomes) {
            UserDefaults.standard.set(encodedData, forKey: userDefaultsIncomesKey)
        }
        
    }
    
    func loadIncomes() {
        if let savedData = UserDefaults.standard.data(forKey: userDefaultsIncomesKey),
           let loadedItem = try? JSONDecoder().decode([Income].self, from: savedData) {
            incomes = loadedItem
        } else {
            print("No saved data found: incomes")
        }
    }
    
    // MARK: EXPENSES
    
    func saveExpenses() {
        if let encodedData = try? JSONEncoder().encode(expenses) {
            UserDefaults.standard.set(encodedData, forKey: userDefaultsExpensesKey)
        }
        
    }
    
    func loadExpenses() {
        if let savedData = UserDefaults.standard.data(forKey: userDefaultsExpensesKey),
           let loadedItem = try? JSONDecoder().decode([Expense].self, from: savedData) {
            expenses = loadedItem
        } else {
            print("No saved data found: expenses")
        }
    }
    
    func setGoal(goal: String) {
        let goalAmount = Decimal(string: goal) ?? 0
        self.goal = goalAmount
    }
    
    func addIncome(_ income: Income) {
        incomes.append(income)
    }
    
    func editIncome(income: Income, source: IncomeSource, date: Date, amount: Decimal) {
        if let index = incomes.firstIndex(where: { $0.id == income.id }) {
            incomes[index].source = source
            incomes[index].date = date
            incomes[index].amount = amount
        }
    }
    
    func delete(income: Income) {
        guard let index = incomes.firstIndex(where: { $0.id == income.id }) else { return }
        incomes.remove(at: index)
    }
    
    func getIncomeSum() -> Decimal {
        var sum: Decimal = 0
        for income in currentMonthIncomes {
            sum += income.amount
        }
        return sum
    }
    
    func getExpenseSum() -> Decimal {
        var sum: Decimal = 0
        for expense in currentMonthExpenses {
            sum += expense.amount
        }
        return sum
    }
    
    func getIncomeSumYear() -> Decimal {
        var sum: Decimal = 0
        for income in currentYearIncomes {
            sum += income.amount
        }
        return sum
    }
    
    func getExpenseSumYear() -> Decimal {
        var sum: Decimal = 0
        for expense in currentYearExpenses {
            sum += expense.amount
        }
        return sum
    }
    
    func calculateFI() -> Decimal {
        return (getExpenseSum() * 12 / 0.04)
    }
    
    func addExpense(_ expense: Expense) {
        expenses.append(expense)
    }
    
    func editExpense(expense: Expense, category: ExpenseCategory, description: String, date: Date, amount: Decimal) {
        if let index = expenses.firstIndex(where: { $0.id == expense.id }) {
            expenses[index].category = category
            expenses[index].description = description
            expenses[index].date = date
            expenses[index].amount = amount
        }
    }
    
    func delete(expense: Expense) {
        guard let index = expenses.firstIndex(where: { $0.id == expense.id }) else { return }
        expenses.remove(at: index)
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
    
    func abbreviateEN(_ value: Decimal, maxFractionDigits: Int = 1) -> String {
        let absValue = value < 0 ? -value : value
        
        let thousand: Decimal = 1_000
        let million:  Decimal = 1_000_000
        let billion:  Decimal = 1_000_000_000
        
        let (divisor, suffix): (Decimal, String) = {
            if absValue >= billion  { return (billion, " Billion") }
            if absValue >= million  { return (million, " Million") }
            if absValue >= thousand { return (thousand, "K") }
            return (1, "")
        }()
        
        let scaled = value / divisor
        
        let f = NumberFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.numberStyle = .decimal
        f.minimumFractionDigits = 0
        f.maximumFractionDigits = suffix.isEmpty ? 0 : maxFractionDigits
        
        let text = f.string(from: NSDecimalNumber(decimal: scaled))
        ?? NSDecimalNumber(decimal: scaled).stringValue
        
        return text + suffix
    }
}


extension Decimal {
    var cgFloatValue: CGFloat {
        CGFloat(NSDecimalNumber(decimal: self).doubleValue)
    }
}
