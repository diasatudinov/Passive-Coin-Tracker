//
//  PCIncomeView.swift
//  Passive Coin Tracker
//
//

import SwiftUI

struct PCIncomeView: View {
    @ObservedObject var viewModel: PCIncomeViewModel
    @State private var showEditGoal = false
    @State private var goal = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 8) {
                        Image(.tab1IconSelectedPC)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 20)
                        
                        Text("Income Goal")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Current Month")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundStyle(.description)
                        
                        Text("$\(viewModel.goal)")
                            .font(.system(size: 24, weight: .regular))
                            .foregroundStyle(.accent)
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Progress")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundStyle(.description)
                        
                        Text("\(Int(Double(viewModel.monthlyProgress(goal: viewModel.goal, income: viewModel.getIncomeSum())) * 100))%")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundStyle(.accent)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    
                    CustomProgressBar(progress: viewModel.monthlyProgress(goal: viewModel.goal, income: viewModel.getIncomeSum()))
                        .frame(maxWidth: .infinity)
                    
                    Text("Goal: $\(viewModel.goal)/month")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundStyle(.description)
                }
                
            }
            .padding()
            .background(.secondaryBlack)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .onTapGesture {
                showEditGoal = true
            }
            
            Button {
                
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "plus")
                    Text("Add Income")
                }
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .padding(19)
                .background(.accent)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }.buttonStyle(.plain)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Income Sources")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(.description)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {
                        if viewModel.incomes.isEmpty {
                            Text("No income sources this month")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundStyle(.description)
                                .frame(maxWidth: .infinity)
                                .padding(26)
                                .background(.secondaryBlack)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        } else {
                            ForEach(viewModel.incomes, id: \.id) { income in
                                PCIncomeCell(income: income)
                            }
                        }
                    }
                }
            }
            
        }
        .padding(.horizontal, 16).padding(.bottom, 50).padding(.top, 32)
        .background(.black)
        .titledSheet(
            image: .goalIconPC,
            title: "Set Goal",
            isPresented: $showEditGoal,
            content: incomeSheetContent)
    }
    
    private func incomeSheetContent() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Monthly Income Goal ($)")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            TextField("", text: $goal)
                .keyboardType(.decimalPad)
                .foregroundStyle(.white)
                .padding()
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(lineWidth: 1)
                        .foregroundStyle(.progressSecondary)
                }
                .overlay {
                    if goal.isEmpty {
                        Text("50000")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundStyle(.white.opacity(0.5))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 17).padding(.leading, 17)
                            .overlay {
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(lineWidth: 1)
                                    .foregroundStyle(.secondaryBlack)
                            }
                            .allowsHitTesting(false)
                    }
                }
            
            VStack(spacing: 20) {
                Text("Specify your desired passive income per month")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(.description)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Button {
                    save(goal: goal)
                } label: {
                    Text("Save")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.black).frame(maxWidth: .infinity)
                        .padding(19)
                        .background(.accent)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }.buttonStyle(.plain)
            }
        }
    }
    
    private func save(goal: String) {
        guard !self.goal.isEmpty else { return }
        viewModel.setGoal(goal: goal)
        showEditGoal = false
    }
}

#Preview {
    PCIncomeView(viewModel: PCIncomeViewModel())
}

struct CustomProgressBar: View {
    var progress: CGFloat
    var height: CGFloat = 16
    var cornerRadius: CGFloat = 8

    var body: some View {
        GeometryReader { geo in
            let clamped = min(max(progress, 0), 1)
            let width = geo.size.width

            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .foregroundStyle(.progressSecondary)

                RoundedRectangle(cornerRadius: cornerRadius)
                    .foregroundStyle(.yellow)
                    .frame(width: width * clamped)
                    .mask(
                        RoundedRectangle(cornerRadius: cornerRadius)
                    )
            }
        }
        .frame(height: height)
    }
}
