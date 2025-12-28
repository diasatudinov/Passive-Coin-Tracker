//
//  PCExpenseCell.swift
//  Passive Coin Tracker
//
//

import SwiftUI

struct PCExpenseCell: View {
    let expense: Expense
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .top ,spacing: 12) {
                Circle()
                    .fill(.expensesAccent)
                    .frame(width: 12, height: 12)
                
                Text("\(expense.description)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text("$\(expense.amount)")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.expensesAccent)
                
                
            }
            
            HStack {
                Circle()
                    .fill(.accent)
                    .frame(width: 12, height: 12)
                    .opacity(0)
                
                Text("\(expense.category.title)")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.description)
                
            }
            
            HStack {
                Circle()
                    .fill(.accent)
                    .frame(width: 12, height: 12)
                    .opacity(0)
                
                HStack {
                    Image(systemName: "calendar")
                        .foregroundStyle(.description)
                        .frame(height: 12)
                    
                    Text("\(monthTitle(for: expense.date))")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.description)
                }
                
            }
            
        }
        .padding(16)
        .background(.secondaryBlack)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private func monthTitle(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.LL"
        return formatter.string(from: date).capitalized
    }
}

#Preview {
    PCExpenseCell(expense: Expense(category: .food, description: "Rent", date: .now, amount: 200))
}
