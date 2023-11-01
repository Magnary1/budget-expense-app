//
//  Other.swift
//  6_Project
//
//  Created by jonathan school on 10/19/23.
//
import SwiftUI

struct GraphView: View {
    

    var body: some View {
        TabView {
            PView()
            Bview()
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
    }
}

struct Bview: View {
    @EnvironmentObject var sharedData: SharedData
    
    var body: some View {
        Text("Hello world")
    }
}



struct PView: View {
    @EnvironmentObject var sharedData: SharedData

    var body: some View {
        let knownCategoryColors: [String: Color] = [
            "Living": .red,
            "Groceries": .blue,
            "Utilities": .yellow,
            "Entertainment": .purple
        ]

        // Map categories to colors or use a default color for new categories
        let data: [(Double, Color)] = sharedData.categories.map { category in
            if let color = knownCategoryColors[category.type] {
                return (category.budget, color)
            } else {
                // You can use a default color for new categories, for example, .pink
                return (category.budget, .pink)
            }
        }

        let totalExpenses = sharedData.totalExpenses

        VStack {
            TitleBarView(title: "Expense Categories")
                .background(Color.secondary.opacity(0.1))
            Spacer()
            VStack(spacing: 5) {
                ForEach(sharedData.categories) { category in
                    LegendItem(color: data.first { $0.0 == category.budget }?.1 ?? .clear, category: category, totalExpenses: totalExpenses)
                }
            }

            PieChartView(slices: data)

            Spacer()
        }
    }
}



extension Color {
    static var random: Color {
        let red = Double.random(in: 0...1)
        let green = Double.random(in: 0...1)
        let blue = Double.random(in: 0...1)
        return Color(red: red, green: green, blue: blue)
    }
}



struct LegendItem: View {
    let color: Color
    let category: Category
    let totalExpenses: Double

    var body: some View {
        HStack {
            Rectangle()
                .fill(color)
                .frame(width: 20, height: 20)
            Text("\(category.type)")
            Spacer()
            Text("$\(String(format: "%.2f", category.budget))")
            Text("(\(String(format: "%.1f%%", (category.budget / totalExpenses) * 100)))")
                .foregroundColor(.secondary)
        }
    }
}





struct PieChartView: View {
    @State var slices:  [(Double, Color)]
    
    var body: some View {
        
        Canvas { context, size in
            
            //for donut
            let donut = Path { p in
                p.addEllipse(in: CGRect(origin: .zero, size: size))
                p.addEllipse(in: CGRect(x: size.width * 0.25, y: size.height * 0.25, width: size.width * 0.5, height: size.height * 0.5))
            }
            context.clip(to: donut, style: .init(eoFill: true))
            //end donut
            let total = slices.reduce(0) {$0 + $1.0}
            context.translateBy(x: size.width * 0.5, y: size.height * 0.5)
            var pieContext = context
            pieContext.rotate(by: .degrees(-90))
            let radius = min(size.width, size.height) * 0.48
            var startAngle = Angle.zero
            for (value, color) in slices {
                let angle = Angle(degrees: 360 * (value /  total))
                let endAngle = startAngle + angle
                let path = Path { p in
                    p.move(to: .zero)
                    p.addArc(center: .zero, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
                    p.closeSubpath()
                    
                }
                pieContext.fill(path, with: .color(color))
                startAngle = endAngle
            }
            
        }
        .aspectRatio(1, contentMode: .fit)
    }
    
}
