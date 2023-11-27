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
    init() {
        UITabBar.appearance().backgroundColor = UIColor(
            red: Double(98) / 255.0,
            green: Double(130) / 255.0,
            blue: Double(84) / 255.0,
            alpha: 0.1
        )
    }

    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "house.fill")
                }

            MergedBudgetExpenseView()
                .tabItem {
                    Label("Money", systemImage: "dollarsign.circle.fill")
                }

            GraphView()
                .tabItem {
                    Label("Graph", systemImage: "chart.bar")
                }
        }
        .accentColor(Color(red: 12 / 255.0, green: 69 / 255.0, blue: 42 / 255.0))
    }
}

struct MergedBudgetExpenseView: View {
    @State private var selectedView: ViewType = .budget
    @State private var showingAddForm = false
    @State private var activeSheet: ActiveSheet?
    enum ViewType {
        case budget, expense
    }

    let customBackgroundColor = Color(
        red: Double(178) / 255.0,
        green: Double(210) / 255.0,
        blue: Double(164) / 255.0
    )

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
            .foregroundColor(Color.white)
            .background(Color(red: 12 / 255.0, green: 69 / 255.0, blue: 42 / 255.0))
            .background(Color.secondary.opacity(0.1))

            Picker("", selection: $selectedView) {
                Text("Budget").tag(ViewType.budget)
                    .foregroundColor(Color.white)
                Text("Expenses").tag(ViewType.expense)
                    .foregroundColor(Color.white)
            }
            .colorMultiply(customBackgroundColor)
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            switch selectedView {
            case .budget:
                BudgetView(showingAddForm: $showingAddForm)
            case .expense:
                ExpenseView(activeSheet: $activeSheet)
            }
        }
        .foregroundColor(Color.black)
        .background(Color(red: 12 / 255.0, green: 69 / 255.0, blue: 42 / 255.0))
    }
}
