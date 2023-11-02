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
    var categoryUUID: UUID
    var date: Date
    var amount: Double
}

enum ActiveSheet: Identifiable {
    case addExpense, editExpense(Expense)

    var id: Int {
        switch self {
        case .addExpense:
            return 0
        case .editExpense:
            return 1
        }
    }
}

struct ExpenseView: View {
    @EnvironmentObject var sharedData: SharedData
    @Binding var activeSheet: ActiveSheet?
    
    let customBackgroundColor = Color(
        red: Double(178) / 255.0,
        green: Double(210) / 255.0,
        blue: Double(164) / 255.0
    )

    var body: some View {
        VStack {
            List {
                ForEach(sharedData.expenses.indices, id: \.self) { index in
                    ExpenseRowView(expense: sharedData.expenses[index])
                        .listRowSeparator(.hidden)
                        .contentShape(Rectangle())  // Make entire row tappable
                        .onTapGesture {
                            self.activeSheet = .editExpense(sharedData.expenses[index])
                        }
                        .listRowBackground(customBackgroundColor)
                        .environmentObject(sharedData)
                }
                .onDelete(perform: deleteExpense)
            }
            
            .listStyle(PlainListStyle())
        }
        .background(customBackgroundColor)
         
        .sheet(item: $activeSheet) { item in
            switch item {
            case .addExpense:
                EditView(showingForm: .constant(true))
                    .environmentObject(sharedData)
            case .editExpense(let expense):
                EditView(showingForm: .constant(true), expense: expense)
                    .environmentObject(sharedData)
            }
        }
    }

    func deleteExpense(at offsets: IndexSet) {
        sharedData.expenses.remove(atOffsets: offsets)
    }
}

struct ExpenseRowView: View {
    var expense: Expense
    @EnvironmentObject var sharedData: SharedData

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(expense.expenseName)
                Text(sharedData.getCategoryTypeForExpense(expense))
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
             
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text("$\(String(format: "%.2f", expense.amount))")
                Text(dateFormatter.string(from: expense.date))
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
             
        }
         
        .padding()
    }
        
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd"
        return formatter
    }
}

struct EditView: View {
    @Binding var showingForm: Bool
    @State private var expenseName: String
    @State private var expenseAmount: String
    @State private var selectedCategoryIndex: Int
    @State private var expenseDate: Date
    @EnvironmentObject var sharedData: SharedData
    @State private var editingExpense: Expense?
    @Environment(\.presentationMode) var presentationMode
    
    let customBackgroundColor = Color(
        red: Double(178) / 255.0,
        green: Double(210) / 255.0,
        blue: Double(164) / 255.0
    )

    init(showingForm: Binding<Bool>) {
        _showingForm = showingForm
        _expenseName = State(initialValue: "")
        _expenseAmount = State(initialValue: "")
        _selectedCategoryIndex = State(initialValue: 0)
        _expenseDate = State(initialValue: Date())
        _editingExpense = State(initialValue: nil) 
    }
    
    init(showingForm: Binding<Bool>, expense: Expense) {
        _showingForm = showingForm
        _expenseName = State(initialValue: expense.expenseName)
        _expenseAmount = State(initialValue: String(expense.amount))
        _selectedCategoryIndex = State(initialValue: 0)
        _expenseDate = State(initialValue: expense.date)
        _editingExpense = State(initialValue: expense)  // Set the expense being edited
    }
    var body: some View {
        
        
        VStack(spacing: 20) {
            Spacer()
            Text(editingExpense == nil ? "Add Expense" : "Edit Expense")
                .font(.largeTitle)
                .fontWeight(.bold)
            Spacer()
            TextField("Expense Name", text: $expenseName, prompt: Text("Expense Name").foregroundColor(Color(red: 12 / 255.0, green: 69 / 255.0, blue: 42 / 255.0)))
                .padding()
                .foregroundColor(Color.white)
                .background(RoundedRectangle(cornerRadius: 10).stroke(Color(red: 12 / 255.0, green: 69 / 255.0, blue: 42 / 255.0), lineWidth: 1))

            TextField("Amount", text: $expenseAmount, prompt: Text("Amount").foregroundColor(Color(red: 12 / 255.0, green: 69 / 255.0, blue: 42 / 255.0)))
                .keyboardType(.decimalPad)
                .padding()
                .foregroundColor(Color.white)
                .background(RoundedRectangle(cornerRadius: 10).stroke(Color(red: 12 / 255.0, green: 69 / 255.0, blue: 42 / 255.0), lineWidth: 1))
            
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color(red: 12 / 255.0, green: 69 / 255.0, blue: 42 / 255.0), lineWidth: 1)
                    .frame(height: 50)
                    .frame(maxWidth: .infinity) // Make sure it takes up all available width
                
                Picker(selection: $selectedCategoryIndex, label: Text("Category")) {
                    ForEach(sharedData.categories.indices, id: \.self) { index in
                        Text(sharedData.categories[index].type).tag(index)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .onAppear {
                    selectedCategoryIndex = sharedData.categories.firstIndex { $0.id == editingExpense?.categoryUUID } ?? 0
                }

            DatePicker("Date", selection: $expenseDate, displayedComponents: [.date])
                .font(.headline)
                .padding()
                .labelsHidden()
            Spacer()
            Button(action: {
                if let amount = Double(expenseAmount) {
                    if let editingExpense = editingExpense, let index = sharedData.expenses.firstIndex(where: { $0.id == editingExpense.id }) {
                        // Update the existing expense
                        sharedData.expenses[index].expenseName = expenseName
                        sharedData.expenses[index].amount = amount
                        sharedData.expenses[index].categoryUUID = sharedData.categories[selectedCategoryIndex].id
                        sharedData.expenses[index].date = expenseDate
                    } else {
                        // Add a new expense
                        let newExpense = Expense(expenseName: expenseName, categoryUUID: sharedData.categories[selectedCategoryIndex].id, date: expenseDate, amount: amount)
                        sharedData.expenses.append(newExpense)
                    }
                    
                    // Reset the form
                    expenseName = ""
                    expenseAmount = ""
                    expenseDate = Date()
                    editingExpense = nil  // Reset the editingExpense state
                    presentationMode.wrappedValue.dismiss()
                }
            }) {
                Text("Save")
                    .font(.headline)
                    .fontWeight(.bold)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.2)))
            }
        }
        .background(customBackgroundColor)
        .foregroundColor(Color(red: 12 / 255.0, green: 69 / 255.0, blue: 42 / 255.0))
        
         
        //.padding(20)
        //Spacer()
    }

}
