//
//  PCStatisticsView.swift
//  Passive Coin Tracker
//
//

import SwiftUI

enum Period: CaseIterable {
    case month, year
    
    var title: String {
        switch self {
        case .month:
            "Month"
        case .year:
            "Year"
        }
    }
}

struct PCStatisticsView: View {
    @ObservedObject var viewModel: PCIncomeViewModel
    @State private var period: Period = .month
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        ForEach(Period.allCases, id: \.self) { period in
                            Text(period.title)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(self.period == period ? .black : .white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(self.period == period ? .accent : .clear)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .onTapGesture {
                                    withAnimation {
                                        self.period = period
                                    }
                                }
                        }
                    }
                    .padding(4)
                    .background(.secondaryBlack)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(lineWidth: 1)
                            .foregroundStyle(.progressSecondary)
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            
                            Text("Income")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundStyle(.description)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Text("$\(getPeriodIncome())")
                                .font(.system(size: 24, weight: .regular))
                                .foregroundStyle(.accent)
                            
                        }
                        .padding(20)
                        .background(.secondaryBlack)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        
                        VStack(alignment: .leading, spacing: 4) {
                            
                            Text("Expenses")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundStyle(.description)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Text("$\(getPeriodExpense())")
                                .font(.system(size: 24, weight: .regular))
                                .foregroundStyle(.expensesAccent)
                            
                        }
                        .padding(20)
                        .background(.secondaryBlack)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        
                        VStack(alignment: .leading, spacing: 4) {
                            
                            Text("Difference")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundStyle(.description)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Text("\(getPeriodIncome() - getPeriodExpense() > 0 ? "+" : "-")$\(abs(getPeriodIncome() - getPeriodExpense()))")
                                .font(.system(size: 24, weight: .regular))
                                .foregroundStyle(.statisticsGreen)
                            
                        }
                        .padding(20)
                        .background(.secondaryBlack)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    
                    if !getIncome().isEmpty {
                        VStack(alignment: .leading, spacing: 50) {
                            Text("Income by sources")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            IncomePieChart(incomes: getIncome(), lineWidth: 0)
                                .frame(width: 140, height: 140)
                                .frame(maxWidth: .infinity, alignment: .center)
                            
                            
                            let grouped = Dictionary(grouping: getIncome(), by: \.source)
                                .map { (key, values) in
                                    (key, values.reduce(Decimal(0)) { $0 + $1.amount })
                                }
                                .sorted { $0.1.doubleValue > $1.1.doubleValue }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(grouped, id: \.0) { source, sum in
                                    
                                    HStack {
                                        Circle()
                                            .frame(width: 12, height: 12)
                                            .foregroundStyle(source.color)
                                        
                                        Text(source.title)
                                            .foregroundStyle(.white)
                                            .font(.system(size: 12, weight: .regular))
                                    }
                                }
                            }
                            
                            
                            
                        }
                        .padding(20)
                        .background(.secondaryBlack)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    
                    if !getExpenses().isEmpty {
                        VStack(alignment: .leading, spacing: 50) {
                            Text("Expense by sources")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            ExpensePieChart(expenses: getExpenses(), lineWidth: 0)
                                .frame(width: 140, height: 140)
                                .frame(maxWidth: .infinity, alignment: .center)
                            
                            let grouped = Dictionary(grouping: getExpenses(), by: \.category)
                                .map { (key, values) in
                                    (key, values.reduce(Decimal(0)) { $0 + $1.amount })
                                }
                                .sorted { $0.1.doubleValue > $1.1.doubleValue }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(grouped, id: \.0) { source, sum in
                                    HStack {
                                        Circle()
                                            .frame(width: 12, height: 12)
                                            .foregroundStyle(source.color)
                                        
                                        Text(source.title)
                                            .foregroundStyle(.white)
                                            .font(.system(size: 12, weight: .regular))
                                    }
                                }
                            }
                        }
                        .padding(20)
                        .background(.secondaryBlack)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                }.padding(.horizontal, 16).padding(.bottom, 100).padding(.top, 32)
                
            }
        }.background(.black)
    }
    
    func getIncome() -> [Income] {
        switch period {
        case .month:
            viewModel.currentMonthIncomes
        case .year:
            viewModel.currentYearIncomes
        }
    }
        
    func getExpenses() -> [Expense] {
        switch period {
        case .month:
            viewModel.currentMonthExpenses
        case .year:
            viewModel.currentYearExpenses
        }
    }
    
    func getPeriodIncome() -> Decimal {
        period == .month ? viewModel.getIncomeSum() : viewModel.getIncomeSumYear()
    }
    
    func getPeriodExpense() -> Decimal {
        period == .month ? viewModel.getExpenseSum() : viewModel.getExpenseSumYear()
    }
}

#Preview {
    PCStatisticsView(viewModel: PCIncomeViewModel())
}
