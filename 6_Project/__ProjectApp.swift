//
//  __ProjectApp.swift
//  6_Project
//
//  Created by jonathan school on 10/18/23.
//

import SwiftUI

class SharedData: ObservableObject {
    @Published var categories: [Category] = [
        Category(type: "Rent", budget: 1200.00),
        Category(type: "Groceries", budget: 250.00),
        Category(type: "Utilities", budget: 150.00),
        Category(type: "Entertainment", budget: 75.00)
    ]
    
    @Published var expenses: [Expense] = [
        Expense(expenseName: "Groceries", category: "Groceries", date: Date(), amount: 100.50),
        Expense(expenseName: "Rent", category: "Rent", date: Date(), amount: 1500.00),
        Expense(expenseName: "Utilities", category: "Utilities", date: Date(), amount: 200.75),
        Expense(expenseName: "Movie", category: "Entertainment", date: Date(), amount: 50.25),
        Expense(expenseName: "Concert", category: "Entertainment", date: Date(), amount: 75.00)
    ]
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
