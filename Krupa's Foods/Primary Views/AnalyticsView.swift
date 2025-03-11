//
//  AnalyticsView.swift
//  Krupa's Foods
//
//  Created by Om Chachad on 11/25/24.
//

import SwiftUI
import Charts
import SwiftData

/// This view displays the analytics for a specific product. It shows the revenue and profits over a period of time.
struct AnalyticsView: View {
    var product: Product
    @Query var orders: [Order]
    
    /// Initializes the analytics view with a specific product.
    /// - Parameter product: The product for which analytics are to be displayed.
    init(product: Product) {
        self.product = product
        let id = product.id
        self._orders = Query(
            filter: #Predicate<Order> { order in
                order.product?.id == id
            },
            sort: \.date,
            order: .forward,
            animation: .default
        )
    }
    
    var body: some View {
        Form {
            // Revenue section.
            Section("Revenue") {
                ChartView(orders: orders, chartType: .revenue)
            }
            
            // Show Profits only if data about inventory is available.
            if !product.isMadeToDelivery {
                Section("Profits") {
                    ChartView(orders: orders, chartType: .profit)
                }
            }
        }
        #if targetEnvironment(macCatalyst)
        .padding(.top, 65)
        #else
        .padding(.top, 50)
        #endif
    }
}

extension Date {
    // Function for checking if a specified date is the same as the another date.
    func isSameDay(as otherDate: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(self, inSameDayAs: otherDate)
    }
    
    // Function for formatting the day in the MMM d format.
    var formattedMonthDay: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d" // "Nov 24" format
        return formatter.string(from: self)
    }
}

struct ChartView: View {
    /// Use this enum to choose between a revenue or profit chart for ChartView.
    enum ChartType {
        case revenue
        case profit
    }
    
    // Parameters to be passed to the ChartView from the parent view.
    let orders: [Order]
    let chartType: ChartType
    
    // Date range parameters for analytics
    @State private var selectedTimeFrame: TimeFrame = .lastWeek
    @State private var startDate: Date = Date.now.addingTimeInterval(-86400 * 7)
    @State private var endDate: Date = Date.now
    @State private var currentHoverDate: Date? = nil
    
    /// TimeFrame enum for selecting the time frame for analytics
    enum TimeFrame: Hashable {
        case lastWeek, lastMonth, custom
        
        var title: String {
            switch self {
            case .lastWeek: return "7 Days"
            case .lastMonth: return "30 Days"
            case .custom: return "Custom"
            }
        }
    }
    
    /// Computer property for date range based on "selectedTimeFrame"
    private var dateRange: (start: Date, end: Date) {
        switch selectedTimeFrame {
        case .lastWeek:
            let start = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date.now
            return (start, Date.now)
        case .lastMonth:
            let start = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date.now
            return (start, Date.now)
        case .custom:
            return (startDate, endDate)
        }
    }
    
    // Computer property for date range array based on "dateRange"
    private var dateRangeArray: [Date] {
        let (start, end) = dateRange
        guard start <= end else { return [] }
        
        var dates: [Date] = []
        var current = start
        let calendar = Calendar.current
        
        while current <= end {
            dates.append(current)
            guard let next = calendar.date(byAdding: .day, value: 1, to: current) else { break }
            current = next
        }
        return dates
    }
    
    /// Computes the total (revenue or profit) over the selected time frame.
    private var totalForTimePeriod: Double {
        orders
            .filter { $0.date >= dateRange.start && $0.date <= dateRange.end }
            .reduce(0.0) { partialResult, order in
                partialResult + (chartType == .revenue
                                   ? order.amountPaid
                                   : (order.amountPaid - order.totalCost))
            }
    }
    
    /// Computes an array of daily totals for use with the chart’s Y‑axis.
    private var dailyValues: [Double] {
        dateRangeArray.map { date in
            let dailyOrders = orders.filter { $0.date.isSameDay(as: date) }
            return dailyOrders.reduce(0.0) { result, order in
                result + (chartType == .revenue
                          ? order.amountPaid
                          : (order.amountPaid - order.totalCost))
            }
        }
    }
    
    /// Determines the Y‑axis domain based on the chart type.
    private var yDomain: ClosedRange<Double> {
        if chartType == .revenue {
            let maxVal = dailyValues.max() ?? 0
            return 0...(maxVal + 1000)
        } else {
            let minVal = dailyValues.min() ?? 0
            let maxVal = dailyValues.max() ?? 0
            return (minVal - 100)...(maxVal + 100)
        }
    }
    
    // The number of seconds remaining in the current day.
    private var secondsRemaining: Double {
        86400 - Date.now.timeIntervalSince(Calendar.current.startOfDay(for: Date.now))
    }
    
    // The number of seconds that have passed in the current day.
    private var secondsPast: Double {
        Date.now.timeIntervalSince(Calendar.current.startOfDay(for: Date.now))
    }
    
    /// Determines the X‑axis domain based on the date range.
    private var xDomain: ClosedRange<Date> {
        dateRange.start.advanced(by: -secondsPast)...dateRange.end.advanced(by: secondsRemaining)
    }
    
    var body: some View {
        VStack {
            header
            
            GeometryReader { geo in
                Chart(dateRangeArray, id: \.self) { date in
                    // Get orders for the day.
                    let dailyOrders = orders.filter { $0.date.isSameDay(as: date) }
                    let grouped = Dictionary(grouping: dailyOrders, by: \.paymentStatus)
                    
                    let confirmedTotal = (grouped[.completed] ?? []).reduce(0.0) { result, order in
                        result + (chartType == .revenue
                                  ? order.amountPaid
                                  : (order.amountPaid - order.totalCost))
                    }
                    
                    let unconfirmedTotal = (grouped[.pending] ?? []).reduce(0.0) { result, order in
                        result + (chartType == .revenue
                                  ? order.amountPaid
                                  : (order.amountPaid - order.totalCost))
                    }
                    
                    // First bar: confirmed orders.
                    BarMark(
                        x: .value("Day", date, unit: .day),
                        y: .value(chartType == .revenue ? "Revenue" : "Profits", confirmedTotal)
                    )
                    .foregroundStyle(chartType == .revenue
                                        ? Color.yellow.gradient
                                        : (confirmedTotal >= 0 ? Color.green.gradient : Color.red.gradient))
                    
                    // Second overlayed bar: unconfirmed (pending) orders.
                    BarMark(
                        x: .value("Day", date, unit: .day),
                        y: .value(chartType == .revenue ? "Revenue" : "Profits", unconfirmedTotal)
                    )
                    .foregroundStyle(.gray.gradient)
                    
                    // Show a hover annotation if the day matches.
                    if let currentHoverDate, currentHoverDate.isSameDay(as: date) {
                        let hoverOffset = self.hoverOffset(for: currentHoverDate, in: xDomain, chartCount: dateRangeArray.count)
                        
                        RuleMark(x: .value("Day", currentHoverDate, unit: .day))
                            .foregroundStyle(.gray)
                            .lineStyle(.init(lineWidth: 2, dash: [2], dashPhase: 5))
                            .annotation(position: .top) {
                                VStack(alignment: .leading) {
                                    if !(grouped[.pending] ?? []).isEmpty {
                                        HStack {
                                            Image(systemName: "circle.fill")
                                                .foregroundStyle(chartType == .revenue
                                                                    ? Color.yellow.gradient
                                                                    : (confirmedTotal >= 0 ? Color.green.gradient : Color.red.gradient))
                                            Text("₹\(confirmedTotal.formatted()) \(chartType == .revenue ? "Paid" : "Proceeds")")
                                                .bold()
                                        }
                                        HStack {
                                            Image(systemName: "circle.fill")
                                                .foregroundStyle(.gray.gradient)
                                            Text("₹\(unconfirmedTotal.formatted()) Pending")
                                                .bold()
                                        }
                                        .minimumScaleFactor(0.5)
                                    } else {
                                        Text(confirmedTotal, format: .currency(code: "INR"))
                                            .bold()
                                    }
                                    Divider()
                                    
                                    // Automatic grammar inflection is used to pluralize the word “Orders”.
                                    Text("^[\(dailyOrders.count) Orders](inflect: true)")
                                        .foregroundColor(.secondary)
                                    Text(date.formatted(date: .abbreviated, time: .omitted))
                                        .foregroundColor(.secondary)
                                }
                                .padding(10)
                                .background {
                                    RoundedRectangle(cornerRadius: 15)
                                        .foregroundColor(.invertedPrimary.opacity(0.8))
                                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 15))
                                        .shadow(color: .black.opacity(0.125), radius: 2)
                                }
                                .offset(x: hoverOffset, y: unconfirmedTotal > 0 ? 80 : 60)
                            }
                    }
                }
                .chartXAxis {
                    // Grid line marks for the Chart
                    AxisMarks(values: .stride(by: .day)) { _ in
                        AxisGridLine()
                    }
                    
                    // Stride by day for the X‑axis labels.
                    AxisMarks(
                        values: .stride(
                            by: .day,
                            count: Int(ceil(Double(dateRangeArray.count) / (geo.size.width / 80)))
                        )
                    ) { value in
                        AxisValueLabel(format: .dateTime.month().day())
                    }
                }
                .chartXScale(domain: xDomain)
                .chartYScale(domain: yDomain)
                .chartOverlay { proxy in
                    GeometryReader { _ in
                        Rectangle()
                            .fill(.clear)
                            .contentShape(Rectangle())
                            .gesture(
                                // Drag Gesture allows for hover annotation to display specific details for a selected day.
                                DragGesture()
                                    .onChanged { value in
                                        if let day = proxy.value(atX: value.location.x, as: Date.self) {
                                            currentHoverDate = day
                                        }
                                    }
                                    .onEnded { _ in
                                        currentHoverDate = nil
                                    }
                            )
                    }
                }
            }
            .frame(height: 200)
        }
    }
    
    var header: some View {
        VStack {
            // Top row: total label and time frame picker.
            HStack {
                Text(totalForTimePeriod, format: .currency(code: "INR"))
                    .font(.system(.title, design: .rounded))
                    .bold()
                
                Spacer()
                
                Picker("Time Frame", selection: $selectedTimeFrame) {
                    Text("Last 7 Days").tag(TimeFrame.lastWeek)
                    Text("Last 30 Days").tag(TimeFrame.lastMonth)
                    Text("Custom").tag(TimeFrame.custom)
                }
                .labelsHidden()
            }
            
            // Custom date pickers appear only if “Custom” is selected.
            if selectedTimeFrame == .custom {
                HStack {
                    DatePicker("Start Date", selection: $startDate,
                               in: (orders.first?.date ?? Date.distantPast)...endDate,
                               displayedComponents: [.date])
                        .labelsHidden()
                    
                    Spacer()
                    
                    DatePicker("End Date", selection: $endDate,
                               in: startDate...(orders.last?.date ?? Date.now >= startDate ? orders.last?.date ?? Date() : Date.now),
                               displayedComponents: [.date])
                        .labelsHidden()
                }
            }
        }
    }
    
    /// Computes an x‑offset for the hover annotation if the date is near the edges.
    private func hoverOffset(for date: Date, in domain: ClosedRange<Date>, chartCount: Int) -> CGFloat {
        let totalDays = domain.upperBound.timeIntervalSince(domain.lowerBound) / 86400
        let thresholdDays = ceil(totalDays * 0.1)
        let timeFromStart = ceil(date.timeIntervalSince(domain.lowerBound) / 86400)
        let timeToEnd = ceil(domain.upperBound.timeIntervalSince(date) / 86400)
        let maxOffset: CGFloat = 45
        
        if timeFromStart <= thresholdDays {
            return maxOffset
        } else if timeToEnd <= thresholdDays {
            return -maxOffset
        } else {
            return 0
        }
    }
}
