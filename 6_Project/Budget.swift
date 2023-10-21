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
    @State private var selectedCategory: Category?
    @EnvironmentObject var sharedData: SharedData

    var body: some View {
        VStack {
            List {
                ForEach(sharedData.categories) { category in
                    CategoryRowView(category: category, selectedCategory: $selectedCategory)
                        .listRowSeparator(.hidden)
                }
                .onDelete(perform: deleteCategory)
            }
            .listStyle(PlainListStyle())
        }
        .sheet(isPresented: $showingAddForm, content: {
            EditCategoryView(showingForm: $showingAddForm)
                .environmentObject(sharedData)
        })
        .sheet(item: $selectedCategory) { category in
            EditCategoryView(showingForm: .constant(true), category: category)
                .environmentObject(sharedData)
        }
    }

    func deleteCategory(at offsets: IndexSet) {
        sharedData.categories.remove(atOffsets: offsets)
    }
}

struct CategoryRowView: View {
    var category: Category
    @Binding var selectedCategory: Category?
    
    var body: some View {
        HStack {
            Text(category.type)
            Spacer()
            Text("$\(String(format: "%.2f", category.budget))")
        }
        .padding()
        .contentShape(Rectangle())  // Make entire row tappable
        .onTapGesture {
            selectedCategory = category
        }
    }
}

struct EditCategoryView: View {
    @Binding var showingForm: Bool
    @State private var categoryType: String
    @State private var categoryAmount: String
    @EnvironmentObject var sharedData: SharedData
    @Environment(\.presentationMode) var presentationMode

    var categoryToEdit: Category?
    
    init(showingForm: Binding<Bool>, category: Category? = nil) {
        _showingForm = showingForm
        _categoryType = State(initialValue: category?.type ?? "")
        _categoryAmount = State(initialValue: category?.budget.description ?? "")
        categoryToEdit = category
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Text(categoryToEdit == nil ? "Add Category" : "Edit Category")
                .font(.largeTitle)
                .fontWeight(.bold)
            Spacer()

            TextField("Category Type", text: $categoryType)
                .padding()
                .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))
            
            TextField("Amount", text: $categoryAmount)
                .keyboardType(.decimalPad)
                .padding()
                .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))
            Spacer()

            Button(action: {
                if let amount = Double(categoryAmount) {
                    if let existingCategory = categoryToEdit {
                        if let index = sharedData.categories.firstIndex(where: { $0.id == existingCategory.id }) {
                            sharedData.categories[index].type = categoryType
                            sharedData.categories[index].budget = amount
                        }
                    } else {
                        let newCategory = Category(type: categoryType, budget: amount)
                        sharedData.categories.append(newCategory)
                    }
                    presentationMode.wrappedValue.dismiss()
                }
            }) {
                Text(categoryToEdit == nil ? "Add" : "Update")
                    .font(.headline)
                    .fontWeight(.bold)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.2)))
            }
        }
        .padding(20)
        Spacer()
    }
}
