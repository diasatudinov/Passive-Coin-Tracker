//
//  PCExpensesView.swift
//  Passive Coin Tracker
//
//

import SwiftUI

struct PCExpensesView: View {
    @ObservedObject var viewModel: PCIncomeViewModel
    @State private var showAddExpense = false
    @State private var showExpenseSources = false
    @State private var showEditExpense = false
    @State private var category: ExpenseCategory = .other
    @State private var description = ""
    @State private var currentExpense: Expense?
    @State private var amount = ""
    @State private var state: StateIncome = .create
    @State private var date: Date = Date.now
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    
                    Text("Minimum for living")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(.description)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("$\(viewModel.getExpenseSum())/month")
                        .font(.system(size: 24, weight: .regular))
                        .foregroundStyle(.expensesAccent)
                    
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("💡 Point of financial independence")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(.description)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("FI = $\(viewModel.abbreviateEN(viewModel.calculateFI()))")
                        .font(.system(size: 18, weight: .regular))
                        .foregroundStyle(.expensesBlue)
                    
                    Text("(\(viewModel.getExpenseSum()) × 12 / 0.04)")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(.description)
                }
                .padding()
                .background(.progressSecondary)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                
            }
            .padding()
            .background(.secondaryBlack)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            
            Button {
                showAddExpense = true
                category = .other
                description = ""
                date = .now
                amount = ""
                state = .create
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "plus")
                    Text("Add expense")
                }
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(19)
                .background(.expensesAccent)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }.buttonStyle(.plain)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Expenses")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(.description)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {
                        if viewModel.currentMonthExpenses.isEmpty {
                            Text("No expenses")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundStyle(.description)
                                .frame(maxWidth: .infinity)
                                .padding(26)
                                .background(.secondaryBlack)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        } else {
                            ForEach(viewModel.currentMonthExpenses, id: \.id) { expense in
                                PCExpenseCell(expense: expense)
                                    .onTapGesture {
                                        currentExpense = expense
                                        showEditExpense = true
                                        state = .edit
                                        DispatchQueue.main.async {
                                            if let expense = currentExpense {
                                                category = expense.category
                                                description = expense.description
                                                date = expense.date
                                                amount = "\(expense.amount)"
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
            title: "Add Expense",
            isPresented: $showAddExpense,
            content: addExpenseContent)
        .titledSheet(
            title: "Source",
            isPresented: $showExpenseSources,
            content: incomeSourcesContent)
        .titledSheet(
            title: "Edit expense",
            isPresented: $showEditExpense,
            content: editExpenseContent)
        
    }
        
    private func addExpenseContent() -> some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Category")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Button {
                        showAddExpense = false
                        showExpenseSources = true
                    } label: {
                        HStack {
                            Text(category.title)
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
                    Text("Description")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    TextField("", text: $description)
                        .keyboardType(.decimalPad)
                        .foregroundStyle(.white)
                        .padding()
                        .overlay {
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(lineWidth: 1)
                                .foregroundStyle(.progressSecondary)
                        }
                        .overlay {
                            if description.isEmpty {
                                Text("For example: Rent")
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
                let expense = Expense(category: category, description: description, date: date, amount: incomeAmount)
                save(expense: expense)
                
                category = .other
                description = ""
                date = .now
                amount = ""
            } label: {
                Text("Save")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.white).frame(maxWidth: .infinity)
                    .padding(19)
                    .background(.expensesAccent)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }.buttonStyle(.plain)
            
        }
    }
    
    private func editExpenseContent() -> some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Category")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Button {
                        showEditExpense = false
                        showExpenseSources = true
                    } label: {
                        HStack {
                            Text(category.title)
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
                    Text("Description")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    TextField("", text: $description)
                        .keyboardType(.decimalPad)
                        .foregroundStyle(.white)
                        .padding()
                        .overlay {
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(lineWidth: 1)
                                .foregroundStyle(.progressSecondary)
                        }
                        .overlay {
                            if description.isEmpty {
                                Text("For example: Rent")
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
                    guard let expense = currentExpense, !self.amount.isEmpty && !self.description.isEmpty else { return }
                    let expenseAmount = Decimal(string: amount) ?? 0
                    viewModel.editExpense(expense: expense, category: category, description: description, date: date, amount: expenseAmount)
                    
                    category = .other
                    description = ""
                    date = .now
                    amount = ""
                    showEditExpense = false
                } label: {
                    Text("Save")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(14)
                        .background(.expensesAccent)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }.buttonStyle(.plain)
                
                Button {
                    guard let expense = currentExpense else { return }
                    viewModel.delete(expense: expense)
                    showEditExpense = false
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
            ForEach(ExpenseCategory.allCases, id: \.self) { category in
                Button {
                    self.category = category
                    showExpenseSources = false
                    if state == .edit {
                        if let expense = currentExpense {
                            showEditExpense = true
                        }
                    } else {
                        showAddExpense = true
                    }
                    
                } label: {
                    Text(category.title)
                        .font(.system(size: 16, weight: .regular))
                        .foregroundStyle(category == self.category ? .accent : .white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                
            }
            
        }.padding(.horizontal, 12)
            .onAppear {
                if let expense = currentExpense {
                    category = expense.category
                }
            }
    }
    
    private func save(expense: Expense) {
        guard !self.amount.isEmpty && !self.description.isEmpty else { return }
        viewModel.addExpense(expense)
        showAddExpense = false
    }
    
}

#Preview {
    PCExpensesView(viewModel: PCIncomeViewModel())
}
