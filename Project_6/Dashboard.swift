//
//  Dashboard.swift
//  6_Project
//
//  Created by jonathan school on 10/18/23.
//

import Foundation
import SwiftUI

struct DashboardView: View {
    var body: some View {
        VStack {
            TitleBarView(title: "Dashboard")
                .background(Color.secondary.opacity(0.1))
            Spacer()
            OverviewView()
            Spacer()
            BudgetCategoriesOverview()
            Spacer()
            OverallBudgetMeter()
            Spacer()
            SavingsTrackerView()
        }
         

    }
}



struct OverallBudgetMeter: View {
    @EnvironmentObject var sharedData: SharedData

    var body: some View {
        VStack(spacing: 10) {
            Text("Budget Meter")
                .font(.title)
            
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
            Text("Remaining: \((category.budget - spentAmount), specifier: "%.2f")")

            // Progress Bar
            ProgressMeter(value: spentAmount / category.budget)
                            .frame(height: 20)
        }
        .padding()
        .background(Color.white)
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
        VStack(spacing: 20) {
            Spacer()
            Text("Savings Goal")
                .font(.largeTitle)
                .fontWeight(.bold)
            Spacer()
            
            TextField("Goal (e.g., Car, Travel)", text: $label)
                .padding()
                .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))

            TextField("Total Amount", text: $totalAmount)
                .keyboardType(.decimalPad)
                .padding()
                .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))
            
            TextField("Add/Remove From Savings", text: $addingAmount)
                .keyboardType(.decimalPad)
                .padding()
                .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))
            
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
        .padding(20)
        .onAppear() {
            label = sharedData.savingsGoal.label
            totalAmount = sharedData.savingsGoal.totalAmount == 0 ? "" : String(sharedData.savingsGoal.totalAmount)
        }
    }
}
