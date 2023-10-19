//
//  Budget.swift
//  6_Project
//
//  Created by jonathan school on 10/18/23.
//

import Foundation
import SwiftUI

struct Category: Identifiable {
    var id = UUID()
    var type: String
    var budget: Double
}

struct BudgetView: View {
    @Binding var showingAddForm: Bool
    @State private var newCategoryType = ""
    @State private var newCategoryAmount = ""
    @EnvironmentObject var sharedData: SharedData

    var body: some View {
        VStack {
            List {
                ForEach(sharedData.categories) { category in
                    CategoryRowView(category: category)
                        .listRowSeparator(.hidden)
                }
                .onDelete(perform: deleteCategory)
            }
            .listStyle(PlainListStyle())
        }
        .sheet(isPresented: $showingAddForm, content: {
            VStack {
                TextField("Category Type", text: $newCategoryType)
                    .padding()
                    .border(Color.gray)
                TextField("Amount", text: $newCategoryAmount)
                    .keyboardType(.decimalPad)
                    .padding()
                    .border(Color.gray)
                Button("Add") {
                    if let amount = Double(newCategoryAmount) {
                        let newCategory = Category(type: newCategoryType, budget: amount)  // replace with your actual Category struct
                        sharedData.categories.append(newCategory)
                        newCategoryType = ""
                        newCategoryAmount = ""
                        showingAddForm.toggle()
                    }
                }
                .padding()
            }
            .padding()
        })
    }

    func deleteCategory(at offsets: IndexSet) {
        sharedData.categories.remove(atOffsets: offsets)
    }
}

struct CategoryRowView: View {
    var category: Category
    
    var body: some View {
        HStack {
            Text(category.type)
            Spacer()
            Text("$\(String(format: "%.2f", category.budget))")
        }
        .padding()
    }
}
