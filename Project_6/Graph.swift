//
//  Other.swift
//  6_Project
//
//  Created by jonathan school on 10/19/23.
//
import Charts
import SwiftUI

struct GraphView: View {
    // .background(Color(red: 12 / 255.0, green: 69 / 255.0, blue: 42 / 255.0))

    let customBackgroundColor = Color(
        red: Double(178) / 255.0,
        green: Double(210) / 255.0,
        blue: Double(164) / 255.0
    )

    var body: some View {
        TabView {
            PView()
            Bview()
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
        .background(customBackgroundColor)
        .foregroundColor(Color.black)
        .edgesIgnoringSafeArea(.top)
    }
}

struct Bview: View {
    @EnvironmentObject var sharedData: SharedData

    var body: some View {
        let totalIncomeData = BarChartData(label: "Total Income", value: sharedData.totalIncome)
        let totalExpensesData = BarChartData(label: "Total Expenses", value: sharedData.totalExpenses)
        let incomeLeftData = BarChartData(label: "Income Left", value: sharedData.incomeLeft)

        let barChartData = [totalIncomeData, totalExpensesData, incomeLeftData]
        VStack {
            TitleBarView(title: "Income Vs Expenses")
                // .foregroundColor(Color.white)
                .background(Color.secondary.opacity(0.1))
                .background(Color(red: 12 / 255.0, green: 69 / 255.0, blue: 42 / 255.0))
                .foregroundColor(Color.white)
            Spacer()
            BarChartView(data: barChartData)
            Spacer()
        }
    }
}

struct BarChartView: View {
    var data: [BarChartData]

    var body: some View {
        HStack {
            ForEach(data, id: \.label) { barData in
                Chart {
                    BarMark(
                        x: .value("Shape Type", barData.label),
                        y: .value("Total Count", barData.value)
                    )
                }
                .foregroundColor(Color(red: 12 / 255.0, green: 69 / 255.0, blue: 42 / 255.0))

                .chartYAxis {
                    AxisMarks(
                        values: .stride(by: 200),
                        stroke: StrokeStyle(
                            lineWidth: 2,
                            lineCap: .butt,
                            lineJoin: .bevel,
                            miterLimit: 1,
                            dash: [],
                            dashPhase: 1
                        )
                    )
                }
                .frame(height: 550)
            }
        }
    }
}

struct BarChartData: Identifiable {
    let id = UUID()
    let label: String
    let value: Double
}

struct PView: View {
    @EnvironmentObject var sharedData: SharedData

    var body: some View {
        let knownCategoryColors: [String: Color] = [
                    "Living": .red,
                    "Groceries": .blue,
                    "Utilities": .yellow,
                    "Entertainment": .purple,
                    "General Savings": .mint,
                ]

                // Maintain a counter for new categories
                var newCategoryCounter = 0

                // Map categories to colors or use a default color for new categories
                let data: [(Double, Color)] = sharedData.categories.map { category in
                    if let color = knownCategoryColors[category.type] {
                        return (category.budget, color)
                    } else {
                        // Assign colors based on the new category counter
                        let newColor: Color
                        switch newCategoryCounter {
                        case 0:
                            newColor = .pink
                        case 1:
                            newColor = .orange
                        case 2:
                            newColor = .gray
                        default:
                            newColor = .pink
                        }

                        // Increment the counter for the next new category
                        newCategoryCounter += 1

                        return (category.budget, newColor)
                    }
                }
        let totalExpenses = sharedData.totalExpenses

        VStack {
            TitleBarView(title: "Expense Categories")

                .background(Color(red: 12 / 255.0, green: 69 / 255.0, blue: 42 / 255.0).ignoresSafeArea(.all, edges: .top))
                .background(Color.secondary.opacity(0.1))
                .foregroundColor(Color.white)

            Spacer()
            VStack(spacing: 5) {
                ForEach(sharedData.categories) { category in
                    LegendItem(color: data.first { $0.0 == category.budget }?.1 ?? .clear, category: category, totalExpenses: totalExpenses)
                }
            }
            .padding(12)

            PieChartView(slices: data)

            Spacer()
        }
    }
}

extension Color {
    static var random: Color {
        let red = Double.random(in: 0 ... 1)
        let green = Double.random(in: 0 ... 1)
        let blue = Double.random(in: 0 ... 1)
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
    @State var slices: [(Double, Color)]

    var body: some View {
        Canvas { context, size in

            // for donut
            let donut = Path { p in
                p.addEllipse(in: CGRect(origin: .zero, size: size))
                p.addEllipse(in: CGRect(x: size.width * 0.25, y: size.height * 0.25, width: size.width * 0.5, height: size.height * 0.5))
            }
            context.clip(to: donut, style: .init(eoFill: true))
            // end donut
            let total = slices.reduce(0) { $0 + $1.0 }
            context.translateBy(x: size.width * 0.5, y: size.height * 0.5)
            var pieContext = context
            pieContext.rotate(by: .degrees(-90))
            let radius = min(size.width, size.height) * 0.48
            var startAngle = Angle.zero
            for (value, color) in slices {
                let angle = Angle(degrees: 360 * (value / total))
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
