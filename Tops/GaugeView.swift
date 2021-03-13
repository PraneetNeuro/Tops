//
//  GaugeView.swift
//  Tops
//
//  Created by Praneet S on 13/03/21.
//

import Foundation
import SwiftUI

struct CPUView: View {
    @Binding var value: Double
    var body: some View {
        VStack {
            GaugeView(coveredRadius: 225, maxValue: 100, steperSplit: 10, value: $value)
        }
    }
}

struct Needle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.height/2))
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        return path
    }
}

struct GaugeView: View {
    func colorMix(percent: Int) -> Color {
        let p = Double(percent)
        let tempG = (100.0-p)/100
        let g: Double = tempG < 0 ? 0 : tempG
        let tempR = 1+(p-100.0)/100.0
        let r: Double = tempR < 0 ? 0 : tempR
        return Color.init(red: r, green: g, blue: 0)
    }
    
    
    func tick(at tick: Int, totalTicks: Int) -> some View {
        let percent = (tick * 100) / totalTicks
        let startAngle = coveredRadius/2 * -1
        let stepper = coveredRadius/Double(totalTicks)
        let rotation = Angle.degrees(startAngle + stepper * Double(tick))
        return VStack {
                   Rectangle()
                    .fill(colorMix(percent: percent))
                       .frame(width: tick % 2 == 0 ? 5 : 3,
                              height: tick % 2 == 0 ? 20 : 10) //alternet small big dash
                   Spacer()
           }.rotationEffect(rotation)
    }
    
    let coveredRadius: Double // 0 - 360°
    let maxValue: Int
    let steperSplit: Int
    
    private var tickCount: Int {
        return maxValue/steperSplit
    }
    
    @Binding var value: Double
    var body: some View {
        ZStack {
            Text("\(value, specifier: "%0.0f")")
                .font(.system(size: 40, weight: Font.Weight.bold))
                .foregroundColor(Color.orange)
                .offset(x: 0, y: 40)
            ForEach(0..<tickCount*2 + 1) { tick in
                self.tick(at: tick,
                          totalTicks: self.tickCount*2)
            }
            Needle()
                .fill(Color.red)
                .frame(width: 100, height: 6)
                .offset(x: -70, y: 0)
                .rotationEffect(.init(degrees: getAngle(value: value)), anchor: .center)
                .animation(.linear)
            Circle()
                .frame(width: 20, height: 20)
                .foregroundColor(.red)
        }.frame(width: 300, height: 225, alignment: .center)
    }
    
    func getAngle(value: Double) -> Double {
        let util = value > 100 ? 100 : value
        return (util / Double(maxValue))*coveredRadius - coveredRadius/2 + 90
    }
}
