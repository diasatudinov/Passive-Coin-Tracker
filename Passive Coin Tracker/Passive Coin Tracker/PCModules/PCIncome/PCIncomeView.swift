//
//  PCIncomeView.swift
//  Passive Coin Tracker
//
//

import SwiftUI

enum StateIncome {
    case create, edit
}

struct PCIncomeView: View {
    @ObservedObject var viewModel: PCIncomeViewModel
    @State private var showEditGoal = false
    @State private var showAddIncome = false
    @State private var showIncomeSources = false
    @State private var showEditIncome = false
    @State private var source: IncomeSource = .other
    @State private var currentIncome: Income?
    @State private var goal = ""
    @State private var amount = ""
    @State private var state: StateIncome = .create
    @State private var date: Date = Date.now
    @State private var didLoadInitialData = false
    
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
                showAddIncome = true
                source = .other
                date = .now
                amount = ""
                state = .create
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
                        if viewModel.currentMonthIncomes.isEmpty {
                            Text("No income sources this month")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundStyle(.description)
                                .frame(maxWidth: .infinity)
                                .padding(26)
                                .background(.secondaryBlack)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        } else {
                            ForEach(viewModel.currentMonthIncomes, id: \.id) { income in
                                PCIncomeCell(income: income)
                                    .onTapGesture {
                                        
                                        currentIncome = income
                                        showEditIncome = true
                                        state = .edit
                                        DispatchQueue.main.async {
                                            if let income = currentIncome {
                                                source = income.source
                                                date = income.date
                                                amount = "\(income.amount)"
                                            }
                                        }
                                    }
                            }
                        }
                    }.padding(.bottom, 100)
                }
            }
            
        }
        .padding(.horizontal, 16).padding(.top, 32)
        .background(.black)
        .titledSheet(
            image: .goalIconPC,
            title: "Set Goal",
            isPresented: $showEditGoal,
            content: incomeSheetContent)
        .titledSheet(
            title: "Add Income",
            isPresented: $showAddIncome,
            content: addIncomeContent)
        .titledSheet(
            title: "Source",
            isPresented: $showIncomeSources,
            content: incomeSourcesContent)
        .titledSheet(
            title: "Edit Income",
            isPresented: $showEditIncome,
            content: editIncomeContent)
        
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
                                    .foregroundStyle(.progressSecondary)
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
    
    private func addIncomeContent() -> some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Source")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Button {
                        showAddIncome = false
                        showIncomeSources = true
                    } label: {
                        HStack {
                            Text(source.title)
                                .font(.system(size: 16, weight: .regular))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Image(systemName: "chevron.down")
                                .resizable()
                                .scaledToFit()
                                .foregroundStyle(.white)
                                .frame(height: 5)
                                .bold()
                        }
                        .padding(.vertical, 17).padding(.horizontal, 17)
                        .overlay {
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(lineWidth: 1)
                                .foregroundStyle(.progressSecondary)
                        }
                        .allowsHitTesting(false)
                    }
                    
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Date")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack(alignment: .center) {
                        DatePicker(
                            "",
                            selection: $date,
                            displayedComponents: .date
                        )
                        .tint(.yellow)
                        .labelsHidden()
                        
                        Spacer()
                        
                        Image(systemName: "calendar")
                            .foregroundStyle(.white)
                            .frame(height: 20)
                    }
                    .padding(.vertical, 5).padding(.horizontal, 16)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(lineWidth: 1)
                            .foregroundStyle(.progressSecondary)
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Amount ($)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    TextField("", text: $amount)
                        .keyboardType(.decimalPad)
                        .foregroundStyle(.white)
                        .padding()
                        .overlay {
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(lineWidth: 1)
                                .foregroundStyle(.progressSecondary)
                        }
                        .overlay {
                            if amount.isEmpty {
                                Text("0")
                                    .font(.system(size: 16, weight: .regular))
                                    .foregroundStyle(.white.opacity(0.5))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.vertical, 17).padding(.leading, 17)
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(lineWidth: 1)
                                            .foregroundStyle(.progressSecondary)
                                    }
                                    .allowsHitTesting(false)
                            }
                        }
                }
            }
            
            Button {
                let incomeAmount = Decimal(string: amount) ?? 0
                let income = Income(source: source, date: date, amount: incomeAmount)
                save(income: income)
                
                source = .other
                date = .now
                amount = ""
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
    
    private func editIncomeContent() -> some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Source")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Button {
                        showEditIncome = false
                        showIncomeSources = true
                    } label: {
                        HStack {
                            Text(source.title)
                                .font(.system(size: 16, weight: .regular))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Image(systemName: "chevron.down")
                                .resizable()
                                .scaledToFit()
                                .foregroundStyle(.white)
                                .frame(height: 5)
                                .bold()
                        }
                        .padding(.vertical, 17).padding(.horizontal, 17)
                        .overlay {
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(lineWidth: 1)
                                .foregroundStyle(.progressSecondary)
                        }
                        .allowsHitTesting(false)
                    }
                    
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Date")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack(alignment: .center) {
                        DatePicker(
                            "",
                            selection: $date,
                            displayedComponents: .date
                        )
                        .tint(.yellow)
                        .labelsHidden()
                        
                        Spacer()
                        
                        Image(systemName: "calendar")
                            .foregroundStyle(.white)
                            .frame(height: 20)
                    }
                    .padding(.vertical, 5).padding(.horizontal, 16)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(lineWidth: 1)
                            .foregroundStyle(.progressSecondary)
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Amount ($)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    TextField("", text: $amount)
                        .keyboardType(.decimalPad)
                        .foregroundStyle(.white)
                        .padding()
                        .overlay {
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(lineWidth: 1)
                                .foregroundStyle(.progressSecondary)
                        }
                        .overlay {
                            if amount.isEmpty {
                                Text("0")
                                    .font(.system(size: 16, weight: .regular))
                                    .foregroundStyle(.white.opacity(0.5))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.vertical, 17).padding(.leading, 17)
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(lineWidth: 1)
                                            .foregroundStyle(.progressSecondary)
                                    }
                                    .allowsHitTesting(false)
                            }
                        }
                }
            }
            
            HStack {
                Button {
                    guard let income = currentIncome else { return }
                    let incomeAmount = Decimal(string: amount) ?? 0
                    viewModel.editIncome(income: income, source: source, date: date, amount: incomeAmount)
                    
                    source = .other
                    date = .now
                    amount = ""
                    showEditIncome = false
                } label: {
                    Text("Save")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding(14)
                        .background(.accent)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }.buttonStyle(.plain)
                
                Button {
                    guard let income = currentIncome else { return }
                    viewModel.delete(income: income)
                    showEditIncome = false
                } label: {
                    Image(systemName: "trash")
                        .foregroundStyle(.white)
                        .frame(width: 20)
                        .padding(.horizontal, 18).padding(.vertical, 14)
                        .background(.progressSecondary)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                        
                }.buttonStyle(.plain)
            }
        }
    }
    
    private func incomeSourcesContent() -> some View {
        VStack(alignment: .leading, spacing: 24) {
            ForEach(IncomeSource.allCases, id: \.self) { source in
                Button {
                    self.source = source
                    showIncomeSources = false
                    if state == .edit {
                        if let income = currentIncome {
                            showEditIncome = true
                        }
                    } else {
                        showAddIncome = true
                    }
                    
                } label: {
                    Text(source.title)
                        .font(.system(size: 16, weight: .regular))
                        .foregroundStyle(source == self.source ? .accent : .white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                
            }
            
        }.padding(.horizontal, 12)
            .onAppear {
                if let income = currentIncome {
                    source = income.source
                }
            }
    }
    
    private func save(goal: String) {
        guard !self.goal.isEmpty else { return }
        viewModel.setGoal(goal: goal)
        showEditGoal = false
    }
    
    private func save(income: Income) {
        guard !self.amount.isEmpty else { return }
        viewModel.addIncome(income)
        showAddIncome = false
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
