//
//  Dashboard.swift
//  6_Project
//
//  Created by jonathan school on 10/18/23.
//

import Foundation
import SwiftUI

struct DashboardView: View {
    let customBackgroundColor = Color(
        red: Double(178) / 255.0,
        green: Double(210) / 255.0,
        blue: Double(164) / 255.0
    )

    var body: some View {
        VStack {
            TitleBarView(title: "Dashboard")
                .background(Color(red: 12 / 255.0, green: 69 / 255.0, blue: 42 / 255.0))
                .background(Color.secondary.opacity(0.1))
                .foregroundColor(Color.white)
            Spacer()
            OverviewView()
            Spacer()
            BudgetCategoriesOverview()
            Spacer()
            OverallBudgetMeter()
            Spacer()
            SavingsTrackerView()
        }
        .background(customBackgroundColor)
    }
}

struct OverallBudgetMeter: View {
    @EnvironmentObject var sharedData: SharedData

    var body: some View {
        VStack(spacing: 10) {
            Text("Budget Meter")
                .font(.title)
                .foregroundColor(Color.white)

            ProgressMeter(value: sharedData.totalExpenses / sharedData.totalIncome)
                .frame(height: 30)
                .padding(.horizontal)
        }
    }
}

struct BudgetCategoryCard: View {
    var category: Category
    @EnvironmentObject var sharedData: SharedData

    var spentAmount: Double {
        return sharedData.expenses
            .filter { $0.categoryUUID == category.id }
            .reduce(0) { $0 + $1.amount }
    }

    var body: some View {
        VStack(spacing: 10) {
            Text(category.type)
                .font(.headline)

            Text("Budgeted: \(category.budget, specifier: "%.2f")")
            Text("Spent: \(spentAmount, specifier: "%.2f")")
            Text("Remaining: \(category.budget - spentAmount, specifier: "%.2f")")

            // Progress Bar
            ProgressMeter(value: spentAmount / category.budget)
                .frame(height: 20)
        }
        .foregroundColor(Color.white)
        .padding()
        .background(Color(red: 12 / 255.0, green: 69 / 255.0, blue: 42 / 255.0))
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}

struct ProgressBar: View {
    var value: Double // value between 0 and 1

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .foregroundColor(Color.gray.opacity(0.2))
                Rectangle()
                    .frame(width: CGFloat(value) * geometry.size.width)
                    .foregroundColor(value >= 1.0 ? Color.red : Color.green)
            }
            .cornerRadius(5)
        }
    }
}

struct BudgetCategoriesOverview: View {
    @EnvironmentObject var sharedData: SharedData

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 15) {
                ForEach(sharedData.categories, id: \.id) { category in
                    BudgetCategoryCard(category: category)
                        .frame(width: 200)
                }
            }

            .padding(.horizontal)
            .padding(.vertical)
        }
    }
}

struct ProgressMeter: View {
    var value: Double // Expected value between 0 and 1, but can go above 1 to indicate overspending

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .foregroundColor(Color.gray.opacity(0.2))

                Rectangle()
                    .frame(width: min(CGFloat(value) * geometry.size.width, geometry.size.width))
                    .foregroundColor(getFillColor(value: value))
            }
            .cornerRadius(5)
        }
    }

    func getFillColor(value: Double) -> Color {
        if value >= 1.0 {
            return .red // Indicates overspending or 100% usage
        } else if value >= 0.75 {
            return .orange
        } else {
            return .green
        }
    }
}

struct OverviewView: View {
    @EnvironmentObject var sharedData: SharedData

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Total Income:")
                    .font(.headline)
                Spacer()
                Text("$\(sharedData.totalIncome, specifier: "%.2f")")
            }

            HStack {
                Text("Total Expenses:")
                    .font(.headline)
                Spacer()
                Text("- $\(sharedData.totalExpenses, specifier: "%.2f")")
            }

            HStack {
                Text("Income Left:")
                    .font(.headline)
                Spacer()
                Text("$\(sharedData.incomeLeft, specifier: "%.2f")")
            }
        }
        .foregroundColor(Color.white)
        .padding()
    }
}

struct SavingsTrackerView: View {
    @EnvironmentObject var data: SharedData
    @State private var showSheet = false

    var body: some View {
        VStack(spacing: 20) {
            Text("Savings Goal: \(data.savingsGoal.label)")
                .font(.title)
                .foregroundColor(Color.white)

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .frame(width: geometry.size.width, height: 30)
                        .opacity(0.3)
                        .foregroundColor(.blue)

                    Rectangle()
                        .frame(width: progressWidth(for: geometry.size.width), height: 30)
                        .foregroundColor(.blue)
                        .opacity(progressOpacity())
                }
            }
            .frame(height: 30)
            .cornerRadius(15)
            .padding(.horizontal)
            .onTapGesture {
                self.showSheet.toggle()
            }

            Text(String(format: "%.2f/%.2f", data.savingsGoal.savedAmount, data.savingsGoal.totalAmount))
                .font(.caption)
        }
        .sheet(isPresented: $showSheet) {
            SavingsGoalSheet()
                .environmentObject(data)
        }
    }

    func progressWidth(for totalWidth: CGFloat) -> CGFloat {
        if data.savingsGoal.totalAmount == 0 {
            return 0
        } else {
            return CGFloat(data.savingsGoal.savedAmount / data.savingsGoal.totalAmount) * totalWidth
        }
    }

    func progressOpacity() -> Double {
        if data.savingsGoal.savedAmount == 0 && data.savingsGoal.totalAmount == 0 {
            return 0.3
        }
        return 1.0
    }
}

struct SavingsGoalSheet: View {
    @EnvironmentObject var sharedData: SharedData
    @Environment(\.presentationMode) var presentationMode

    @State private var label: String = ""
    @State private var addingAmount: String = ""
    @State private var totalAmount: String = ""

    var body: some View {
        let customBackgroundColor = Color(
            red: Double(178) / 255.0,
            green: Double(210) / 255.0,
            blue: Double(164) / 255.0
        )

        VStack(spacing: 20) {
            Spacer()
            Text("Savings Goal")
                .font(.largeTitle)
                .fontWeight(.bold)
            Spacer()

            TextField("Goal (e.g., Car, Travel)", text: $label, prompt: Text("Goal (e.g., Car, Travel)").foregroundColor(Color(red: 12 / 255.0, green: 69 / 255.0, blue: 42 / 255.0)))
                .padding()
                .foregroundColor(Color.white)
                .background(RoundedRectangle(cornerRadius: 10).stroke(Color(red: 12 / 255.0, green: 69 / 255.0, blue: 42 / 255.0), lineWidth: 1))

            TextField("Total Amount", text: $totalAmount, prompt: Text("Total Amount").foregroundColor(Color(red: 12 / 255.0, green: 69 / 255.0, blue: 42 / 255.0)))
                .keyboardType(.decimalPad)
                .padding()
                .foregroundColor(Color.white)
                .background(RoundedRectangle(cornerRadius: 10).stroke(Color(red: 12 / 255.0, green: 69 / 255.0, blue: 42 / 255.0), lineWidth: 1))

            TextField("Add/Remove From Savings", text: $addingAmount, prompt: Text("Add/Remove From Savings").foregroundColor(Color(red: 12 / 255.0, green: 69 / 255.0, blue: 42 / 255.0)))
                .keyboardType(.decimalPad)
                .padding()
                .foregroundColor(Color.white)
                .background(RoundedRectangle(cornerRadius: 10).stroke(Color(red: 12 / 255.0, green: 69 / 255.0, blue: 42 / 255.0), lineWidth: 1))

            Spacer()

            Button(action: {
                if let total = Double(totalAmount), let addAmount = Double(addingAmount) {
                    sharedData.savingsGoal.label = label
                    sharedData.savingsGoal.totalAmount = total
                    sharedData.savingsGoal.savedAmount += addAmount
                    presentationMode.wrappedValue.dismiss()
                }
            }) {
                Text("Update Savings Goal")
                    .font(.headline)
                    .fontWeight(.bold)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.2)))
            }
            Spacer()
        }
        .foregroundColor(Color(red: 12 / 255.0, green: 69 / 255.0, blue: 42 / 255.0))
        .background(customBackgroundColor)
        // .padding(20)
        .onAppear {
            label = sharedData.savingsGoal.label
            totalAmount = sharedData.savingsGoal.totalAmount == 0 ? "" : String(sharedData.savingsGoal.totalAmount)
        }
    }
}
