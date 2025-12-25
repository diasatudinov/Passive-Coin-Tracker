//
//  PCMenuView.swift
//  Passive Coin Tracker
//
//

import SwiftUI

struct PCMenuContainer: View {
    @AppStorage("firstOpenPC") var firstOpen: Bool = true
    var body: some View {
        NavigationStack {
            ZStack {
                AWMenuView()
                
            }
        }
    }
}

struct AWMenuView: View {
    @State var selectedTab = 0
    @StateObject var viewModel = PCIncomeViewModel()
    private let tabs = ["My dives", "Calendar", "Stats"]
    
    var body: some View {
        ZStack {
            
            switch selectedTab {
            case 0:
                PCIncomeView(viewModel: viewModel)
            case 1:
                Color.red.ignoresSafeArea()
            case 2:
                Color.yellow.ignoresSafeArea()
            default:
                Text("default")
            }
            
            VStack {
                Spacer()
                
                HStack {
                    ForEach(0..<tabs.count) { index in
                        Button(action: {
                            selectedTab = index
                        }) {
                            VStack(spacing: 4) {
                                Image(selectedTab == index ? selectedIcon(for: index) : icon(for: index))
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 24)
                                
                                Text(text(for: index))
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundStyle(selectedTab == index ? .accent : .description)
                            }
                            .frame(maxWidth: .infinity)
                            
                        }
                    }
                }
                .padding(.horizontal, 16).padding(.vertical, 12)
                .background(.secondaryBlack)
            }
            .padding(.bottom, 24)
            .ignoresSafeArea()
            
            
        }
    }
    
    private func icon(for index: Int) -> String {
        switch index {
        case 0: return "tab1IconPC"
        case 1: return "tab2IconPC"
        case 2: return "tab3IconPC"
        default: return ""
        }
    }
    
    private func selectedIcon(for index: Int) -> String {
        switch index {
        case 0: return "tab1IconSelectedPC"
        case 1: return "tab2IconSelectedPC"
        case 2: return "tab3IconSelectedPC"
        default: return ""
        }
    }
    
    private func text(for index: Int) -> String {
        switch index {
        case 0: return "Income"
        case 1: return "Expenses"
        case 2: return "Statistics"
        default: return ""
        }
    }
}

#Preview {
    AWMenuView()
}
