//
//  IncomePieChart 2.swift
//  Passive Coin Tracker
//
//  Created by Dias Atudinov on 29.12.2025.
//


import SwiftUI

struct IncomePieChart: View {
    let incomes: [Income]
    var lineWidth: CGFloat = 18 // если 0 — будет обычный pie без дырки

    private struct Slice: Identifiable {
        let id = UUID()
        let source: IncomeSource
        let value: Double
        let startAngle: Angle
        let endAngle: Angle
    }

    private var slices: [Slice] {
        // Суммируем по source
        let totals: [(IncomeSource, Double)] = Dictionary(grouping: incomes, by: \.source)
            .map { (key, values) in
                (key, values.reduce(0.0) { $0 + $1.amount.doubleValue })
            }
            .filter { $0.1 > 0 }
            .sorted { $0.1 > $1.1 }

        let total = totals.reduce(0.0) { $0 + $1.1 }
        guard total > 0 else { return [] }

        var current = -Double.pi / 2 // начинаем сверху
        return totals.map { (source, value) in
            let delta = (value / total) * 2 * Double.pi
            let start = current
            let end = current + delta
            current = end
            return Slice(
                source: source,
                value: value,
                startAngle: .radians(start),
                endAngle: .radians(end)
            )
        }
    }

    private var totalValue: Double {
        incomes.reduce(0.0) { $0 + $1.amount.doubleValue }
    }

    var body: some View {
        ZStack {
            if slices.isEmpty {
                Circle()
                    .stroke(.progressSecondary, lineWidth: max(lineWidth, 2))
                Text("No data")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(slices) { slice in
                    PieSliceShape(startAngle: slice.startAngle, endAngle: slice.endAngle)
                        .fill(slice.source.color)
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Income chart")
    }
}