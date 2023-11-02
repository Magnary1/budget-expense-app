//
//  __ProjectApp.swift
//  6_Project
//
//  Created by jonathan school on 10/18/23.
//

import SwiftUI
let uuids = (1 ... 5).map { _ in UUID() }

struct SavingsGoal {
    var label: String = ""
    var totalAmount: Double = 0.0
    var savedAmount: Double = 0.0
}

class SharedData: ObservableObject {
    @Published var categories: [Category] = [
        Category(id: uuids[0], type: "Living", budget: 1200.00),
        Category(id: uuids[1], type: "Groceries", budget: 250.00),
        Category(id: uuids[2], type: "Utilities", budget: 150.00),
        Category(id: uuids[3], type: "Entertainment", budget: 75.00),
    ]

    @Published var expenses: [Expense] = [
        Expense(expenseName: "H-E-B", categoryUUID: uuids[1], date: Date(), amount: 100.50),
        Expense(expenseName: "Rent", categoryUUID: uuids[0], date: Date(), amount: 1000.00),
        Expense(expenseName: "Electricity", categoryUUID: uuids[2], date: Date(), amount: 200.75),
        Expense(expenseName: "Movie", categoryUUID: uuids[3], date: Date(), amount: 50.25),
        Expense(expenseName: "Concert", categoryUUID: uuids[3], date: Date(), amount: 175.00),
    ]

    @Published var totalIncome: Double = 2000.00
    @Published var savingsGoal: SavingsGoal = .init()

    var incomeLeft: Double {
        let sumOfCategoryBudgets = categories.reduce(0) { result, category -> Double in
            result + category.budget
        }
        return totalIncome - sumOfCategoryBudgets
    }

    func getCategoryTypeForExpense(_ expense: Expense) -> String {
        if let category = categories.first(where: { $0.id == expense.categoryUUID }) {
            return category.type
        }
        return "None"
    }

    func checkIfCategoryIsUsedByExpense(categoryId: UUID) -> Bool {
        for expense in expenses {
            if expense.categoryUUID == categoryId {
                return true
            }
        }
        return false
    }

    var totalExpenses: Double {
        return expenses.reduce(0) { $0 + $1.amount }
    }
}

@main
struct __ProjectApp: App {
    @StateObject private var sharedData = SharedData()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(sharedData) // Allow sharedData to be accessed everywhere.
        }
    }
}
