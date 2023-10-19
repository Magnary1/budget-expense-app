//
//  Expense.swift
//  6_Project
//
//  Created by jonathan school on 10/18/23.
//

import Foundation
import SwiftUI

struct Expense: Identifiable {
    var id = UUID()
    var expenseName: String
    var category: String
    var date: Date
    var amount: Double
}

struct ExpenseView: View {
    @EnvironmentObject var sharedData: SharedData
    @State private var selectedCategoryIndex = 0  // Added this state to hold the selected category index
    @Binding var showingAddForm: Bool
    @State private var newExpenseName = ""
    @State private var newExpenseCategory = ""
    @State private var newExpenseAmount = ""
    @State private var newExpenseDate = Date()

    var body: some View {
        VStack {
            List {
                ForEach(sharedData.expenses) { expense in
                    ExpenseRowView(expense: expense) // You need to create ExpenseRowView similar to CategoryRowView
                        .listRowSeparator(.hidden)
                }
                .onDelete(perform: deleteExpense)
            }
            .listStyle(PlainListStyle())
        }
        .sheet(isPresented: $showingAddForm, content: {
            VStack {
                TextField("Expense Name", text: $newExpenseName)
                    .padding()
                    .border(Color.gray)
                
                Picker("Category", selection: $selectedCategoryIndex) {
                    ForEach(sharedData.categories.indices, id: \.self) { index in
                        Text(sharedData.categories[index].type).tag(index)
                    }
                }
                    .padding()
                    .border(Color.gray)
                    .pickerStyle(MenuPickerStyle())

                TextField("Amount", text: $newExpenseAmount)
                    .keyboardType(.decimalPad)
                    .padding()
                    .border(Color.gray)
                
                DatePicker("Date", selection: $newExpenseDate, displayedComponents: [.date])
                    .padding()
                
                Button("Add") {
                    if let amount = Double(newExpenseAmount) {
                        let newExpense = Expense(expenseName: newExpenseName, category: newExpenseCategory, date: newExpenseDate, amount: amount)
                        sharedData.expenses.append(newExpense)
                        newExpenseName = ""
                        newExpenseCategory = ""
                        newExpenseAmount = ""
                        newExpenseDate = Date()
                        showingAddForm.toggle()
                    }
                }
                .padding()
            }
            .padding()
        })
    }

    func deleteExpense(at offsets: IndexSet) {
        sharedData.expenses.remove(atOffsets: offsets)
    }
}

struct ExpenseRowView: View {
    var expense: Expense
    
    var body: some View {
        HStack {
            Text(expense.expenseName)
            Spacer()
            Text("$\(String(format: "%.2f", expense.amount))")
        }
        .padding()
    }
}
