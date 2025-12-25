//
//  PCIncomeCell.swift
//  Passive Coin Tracker
//
//

import SwiftUI

struct PCIncomeCell: View {
    let income: Income
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(.accent)
                .frame(width: 12, height: 12)
            
            Text("\(income.source.title)")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text("$\(income.amount)")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.accent)
                
            
        }
        .padding(16)
        .background(.secondaryBlack)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    PCIncomeCell(income: Income(source: .royalties, date: .now, amount: 1500))
}
