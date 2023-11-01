//
//  Common.swift
//  6_Project
//
//  Created by jonathan school on 10/18/23.
//

import Foundation
import SwiftUI

struct TitleBarView: View {
    var title: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            Spacer()
        }
         
    }
}

struct TabBarView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "house.fill")
                }
            
            MergedBudgetExpenseView()
                .tabItem {
                    Label("Money?", systemImage: "dollarsign.circle.fill")
                }
            
            GraphView()
                .tabItem {
                    Label("Graph", systemImage: "list.bullet")
                }
        }
         
    }
}


struct MergedBudgetExpenseView: View {
    @State private var selectedView: ViewType = .budget
    @State private var showingAddForm = false
    @State private var activeSheet: ActiveSheet?
    enum ViewType {
        case budget, expense
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                TitleBarView(title: selectedView == .budget ? "Budget" : "Expenses")
                Spacer()
                Button(action: {
                    switch selectedView {
                    case .budget:
                        showingAddForm.toggle()
                    case .expense:
                        activeSheet = .addExpense
                    }
                }, label: {
                    Image(systemName: "plus")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .padding()
                })
            }
             
            .background(Color.secondary.opacity(0.1))

            Picker("", selection: $selectedView) {
                Text("Budget").tag(ViewType.budget)
                Text("Expenses").tag(ViewType.expense)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
             

            switch selectedView {
            case .budget:
                BudgetView(showingAddForm: $showingAddForm)
            case .expense:
                ExpenseView(activeSheet: $activeSheet)
            }
        }
         
    }
}
