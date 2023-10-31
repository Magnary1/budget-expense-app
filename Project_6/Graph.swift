//
//  Other.swift
//  6_Project
//
//  Created by jonathan school on 10/19/23.
//
import SwiftUI

struct GraphView: View {
    @EnvironmentObject var sharedData: SharedData

    var body: some View {
        let totalIncome = (sharedData.totalIncome, Color.red)
        let totalExpenses = (sharedData.totalExpenses, Color.blue)
        let incomeLeft = (sharedData.incomeLeft, Color.green)
        let data = [totalIncome, totalExpenses, incomeLeft]
        
        let total = data.reduce(0) { $0 + $1.0 }
        let percentages = data.map { $0.0 / total }
        
        return VStack {
            TitleBarView(title: "Graph")
                .background(Color.secondary.opacity(0.1))
            Spacer()
            
            VStack {
                ColorBox(color: .red, text: "= Total Income", percentage: percentages[0])
                ColorBox(color: .blue, text: "= Total Expenses", percentage: percentages[1])
                ColorBox(color: .green, text: "= Income Left", percentage: percentages[2])
            }
            
            PieChartView(slices: data)
            Spacer()
        }
    }
}

struct ColorBox: View {
    let color: Color
    let text: String
    let percentage: Double // Add percentage property

    var body: some View {
        HStack {
            Rectangle()
                .fill(color)
                .frame(width: 20, height: 20)

            Text("\(text) \(String(format: "%.1f%%", percentage * 100))") // Display percentage
                .multilineTextAlignment(.center)
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
