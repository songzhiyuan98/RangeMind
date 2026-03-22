import SwiftUI
import Charts

struct VPIPTrendChart: View {
    let data: [DayVPIP]

    var body: some View {
        Chart(data) { day in
            BarMark(
                x: .value("VPIP", day.vpip),
                y: .value("Day", day.label)
            )
            .foregroundStyle(Color.vtAccent.gradient)
            .cornerRadius(2)
        }
        .chartXScale(domain: 0...40)
        .chartXAxis {
            AxisMarks(values: [0, 20, 40]) { value in
                AxisValueLabel {
                    if let intValue = value.as(Int.self) {
                        Text("\(intValue)%")
                            .font(.system(size: 9, design: .monospaced))
                            .foregroundColor(.vtDim)
                    }
                }
            }
        }
        .chartYAxis {
            AxisMarks { _ in
                AxisValueLabel()
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundStyle(Color.vtMuted)
            }
        }
        .frame(height: CGFloat(data.count * 28 + 20))
    }
}

#Preview {
    ZStack {
        Color.vtBlack.ignoresSafeArea()
        VPIPTrendChart(data: [
            DayVPIP(label: "Mon", vpip: 19),
            DayVPIP(label: "Tue", vpip: 23),
            DayVPIP(label: "Wed", vpip: 21),
            DayVPIP(label: "Thu", vpip: 27),
            DayVPIP(label: "Fri", vpip: 20),
        ])
        .padding()
    }
}
