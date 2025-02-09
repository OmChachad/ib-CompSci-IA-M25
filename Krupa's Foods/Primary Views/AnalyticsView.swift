//
//  AnalyticsView.swift
//  Krupa's Foods
//
//  Created by Om Chachad on 11/25/24.
//

import SwiftUI
import Charts
import SwiftData

struct AnalyticsView: View {
    var product: Product
    @Query var orders: [Order]
    
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
            VStack { }
                .frame(height: 0)
                .listRowInsets(.none)
                .listRowBackground(Color(uiColor: .systemGroupedBackground))
            
            
            Section("Revenue") {
                ChartView(orders: orders, chartType: .revenue)
            }
            
            if !product.isMadeToDelivery {
                Section("Profits") {
                    ChartView(orders: orders, chartType: .profit)
                }
            }
        }
    }
}

extension Date {
    func isSameDay(as otherDate: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(self, inSameDayAs: otherDate)
    }
    
    var formattedMonthDay: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d" // "Nov 24" format
        return formatter.string(from: self)
    }
}

struct ChartView: View {
    /// Use this enum to choose between a revenue or profit chart.
    enum ChartType {
        case revenue
        case profit
    }
    
    // MARK: - Input
    let orders: [Order]
    let chartType: ChartType
    
    // MARK: - Common State
    @State private var selectedTimeFrame: TimeFrame = .lastWeek
    @State private var startDate: Date = Date.now.addingTimeInterval(-86400 * 7)
    @State private var endDate: Date = Date.now
    @State private var currentHoverDate: Date? = nil
    
    // MARK: - Time Frame Enum
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
    
    // MARK: - Date Range Helpers
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
    
    // MARK: - Computed Totals
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
    
    // MARK: - X-Axis Domain Helpers
    private var secondsRemaining: Double {
        86400 - Date.now.timeIntervalSince(Calendar.current.startOfDay(for: Date.now))
    }
    
    private var secondsPast: Double {
        Date.now.timeIntervalSince(Calendar.current.startOfDay(for: Date.now))
    }
    
    private var xDomain: ClosedRange<Date> {
        dateRange.start.advanced(by: -secondsPast)...dateRange.end.advanced(by: secondsRemaining)
    }
    
    // MARK: - Body
    var body: some View {
        VStack {
            header
            
            // MARK: - Chart
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
                    
                    // Second bar: unconfirmed (pending) orders.
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
                    AxisMarks(values: .stride(by: .day)) { _ in
                        AxisGridLine()
                    }
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
                               in: startDate...(orders.last?.date ?? Date()),
                               displayedComponents: [.date])
                        .labelsHidden()
                }
            }
        }
    }
    
    // MARK: - Helpers
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
