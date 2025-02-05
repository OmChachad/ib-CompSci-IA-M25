//
//  AnalyticsView.swift
//  Krupa's Foods
//
//  Created by Om Chachad on 11/25/24.
//

import SwiftUI
import Charts
import SwiftData

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
                RevenueChartView(orders: orders)
            }
            
            if !product.isMadeToDelivery {
                Section("Profits") {
                    ProfitChartView(orders: orders)
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


import SwiftUI
import Charts

struct RevenueChartView: View {
    let orders: [Order]
    
    // Independent state variables for the Revenue view
    @State private var selectedTimeFrame: TimeFrame = .lastWeek
    @State private var startDate = Date.now.addingTimeInterval(-86400 * 7)
    @State private var endDate = Date.now
    
    @State private var currentHoverDate: Date?

    enum TimeFrame: Hashable {
        case lastWeek
        case lastMonth
        case custom
        
        var title: String {
            switch self {
            case .lastWeek: return "7 Days"
            case .lastMonth: return "30 Days"
            case .custom:    return "Custom"
            }
        }
    }
    
    private var dateRange: (Date, Date) {
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
        let (startDate, endDate) = dateRange
        guard startDate <= endDate else { return [] }
        
        var dates: [Date] = []
        var currentDate = startDate
        let calendar = Calendar.current
        
        while currentDate <= endDate {
            dates.append(currentDate)
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
            currentDate = nextDate
        }
        return dates
    }
    
    // Total revenue in the selected time frame
    private var totalRevenueForTimePeriod: Double {
        orders
            .filter { order in
                let date = order.date
                return date >= dateRange.0 && date <= dateRange.1
            }
            .reduce(0.0) { $0 + $1.amountPaid }
    }
    
    // For chart's Y-axis range
    private func revenueArray() -> [Date: Double] {
        var revenueDict: [Date: Double] = [:]
        for date in dateRangeArray {
            let dailyOrders = orders.filter { $0.date.isSameDay(as: date) }
            let totalRevenue = dailyOrders.reduce(0.0) { $0 + $1.amountPaid }
            revenueDict[date] = totalRevenue
        }
        return revenueDict
    }
    
    // Extend domain slightly so the hover overlay does not cut off
    private var secondsRemaining: Double {
        86400 - Date.now.timeIntervalSince(Calendar.current.startOfDay(for: Date.now))
    }
    
    private var secondsPast: Double {
        Date.now.timeIntervalSince(Calendar.current.startOfDay(for: Date.now))
    }
    
    private var domain: ClosedRange<Date> {
        dateRange.0.advanced(by: -secondsPast)...dateRange.1.advanced(by: secondsRemaining)
    }
    
    var body: some View {
        VStack {
            // Top-row: total revenue label + timeframe picker
            HStack {
                Text(totalRevenueForTimePeriod, format: .currency(code: "INR"))
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
            
            // Show date pickers if custom timeframe
            if selectedTimeFrame == .custom {
                HStack {
                    DatePicker("Start Date", selection: $startDate,
                               in: (orders.first?.date ?? Date.distantPast) ... endDate,
                               displayedComponents: [.date])
                        .labelsHidden()
                    
                    Spacer()
                    
                    DatePicker("End Date", selection: $endDate,
                               in: startDate ... (orders.last?.date ?? Date()),
                               displayedComponents: [.date])
                        .labelsHidden()
                }
            }
            
            // Revenue Chart
            GeometryReader { geo in
                Chart(dateRangeArray, id: \.self) { date in
                    // Filter orders for that day
                    let dailyOrders = orders.filter { $0.date.isSameDay(as: date) }
                    
                    // Separate pending vs completed
                    let grouped = Dictionary(grouping: dailyOrders, by: \.paymentStatus)
                    let pendingOrders = grouped[.pending] ?? []
                    let completedOrders = grouped[.completed] ?? []
                    
                    let confirmedRevenue = completedOrders.reduce(0.0) { $0 + $1.amountPaid }
                    let unconfirmedRevenue = pendingOrders.reduce(0.0) { $0 + $1.amountPaid }
                    
                    // Bars
                    BarMark(
                        x: .value("Day", date, unit: .day),
                        y: .value("Revenue", confirmedRevenue)
                    )
                    .foregroundStyle(.yellow.gradient)
                    
                    BarMark(
                        x: .value("Day", date, unit: .day),
                        y: .value("Revenue", unconfirmedRevenue)
                    )
                    .foregroundStyle(.gray.gradient)
                    
                    // Hover effect
                    if let currentHoverDate, currentHoverDate.isSameDay(as: date) {
                        // Dynamic offset if near edges
                        let hoverOffset: CGFloat = hoverOffsetFor(date: currentHoverDate, in: domain, chartCount: dateRangeArray.count)
                        
                        RuleMark(x: .value("Day", currentHoverDate, unit: .day))
                            .foregroundStyle(.gray)
                            .lineStyle(.init(lineWidth: 2, dash: [2], dashPhase: 5))
                            .annotation(position: .top) {
                                VStack(alignment: .leading) {
                                    if !pendingOrders.isEmpty {
                                        HStack {
                                            Image(systemName: "circle.fill")
                                                .foregroundStyle(.yellow.gradient)
                                            Text("₹\(confirmedRevenue.formatted()) Paid")
                                                .bold()
                                        }
                                        HStack {
                                            Image(systemName: "circle.fill")
                                                .foregroundStyle(.gray.gradient)
                                            Text("₹\(unconfirmedRevenue.formatted()) Pending")
                                                .bold()
                                        }
                                        .minimumScaleFactor(0.5)
                                    } else {
                                        Text(confirmedRevenue, format: .currency(code: "INR"))
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
                                .offset(x: hoverOffset, y: unconfirmedRevenue > 0 ? 80 : 60)
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
                    ) { date in
                        AxisValueLabel(format: .dateTime.month().day())
                    }
                }
                .chartXScale(domain: domain)
                .chartYScale(domain: 0...(CGFloat(revenueArray().values.max() ?? 0) + 1000))
                .chartOverlay { proxy in
                    GeometryReader { _ in
                        Rectangle().fill(.clear).contentShape(Rectangle())
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
    
    /// Computes a left/right offset for the annotation if near the edges.
    private func hoverOffsetFor(date: Date, in domain: ClosedRange<Date>, chartCount: Int) -> CGFloat {
        // Basic heuristic: check how many days from left/right edge
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

struct ProfitChartView: View {
    let orders: [Order]
    
    // Independent state variables for the Profit view
    @State private var selectedTimeFrame: TimeFrame = .lastWeek
    @State private var startDate = Date.now.addingTimeInterval(-86400 * 7)
    @State private var endDate = Date.now
    
    @State private var currentHoverDate: Date?

    enum TimeFrame: Hashable {
        case lastWeek
        case lastMonth
        case custom
        
        var title: String {
            switch self {
            case .lastWeek: return "7 Days"
            case .lastMonth: return "30 Days"
            case .custom:    return "Custom"
            }
        }
    }
    
    private var dateRange: (Date, Date) {
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
        let (startDate, endDate) = dateRange
        guard startDate <= endDate else { return [] }
        
        var dates: [Date] = []
        var currentDate = startDate
        let calendar = Calendar.current
        
        while currentDate <= endDate {
            dates.append(currentDate)
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
            currentDate = nextDate
        }
        return dates
    }
    
    // Total profit in the selected time frame
    private var totalProfitForTimePeriod: Double {
        orders
            .filter { order in
                let date = order.date
                return date >= dateRange.0 && date <= dateRange.1
            }
            .reduce(0.0) { print($0 + ($1.amountPaid - $1.totalCost))
                return $0 + ($1.amountPaid - ($1.amountPaid - $1.totalCost)) }
    }
    
    // For chart's X domain
    private var secondsRemaining: Double {
        86400 - Date.now.timeIntervalSince(Calendar.current.startOfDay(for: Date.now))
    }
    
    private var secondsPast: Double {
        Date.now.timeIntervalSince(Calendar.current.startOfDay(for: Date.now))
    }
    
    private var domain: ClosedRange<Date> {
        dateRange.0.advanced(by: -secondsPast)...dateRange.1.advanced(by: secondsRemaining)
    }
    
    private func profitArray() -> [Date: Double] {
        var profitDict: [Date: Double] = [:]
        for date in dateRangeArray {
            let dailyOrders = orders.filter { $0.date.isSameDay(as: date) }
            let totalProfit = dailyOrders.reduce(0.0) { $0 + ($1.amountPaid - $1.totalCost) }
            profitDict[date] = totalProfit
        }
        
        return profitDict
    }
    
    var minimumProfit: Double {
        return (profitArray().values.min() ?? 0) - 100
    }
    
    var maximumProfit: Double {
        return (profitArray().values.max() ?? 0) + 100
    }
    
    var body: some View {
        VStack {
            // Top-row: total profit label + timeframe picker
            HStack {
                Text(totalProfitForTimePeriod, format: .currency(code: "INR"))
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
            
            // Show date pickers if custom timeframe
            if selectedTimeFrame == .custom {
                HStack {
                    DatePicker("Start Date", selection: $startDate,
                               in: (orders.first?.date ?? Date.distantPast)...endDate,
                               displayedComponents: [.date])
                        .labelsHidden()
                    
                    Spacer()
                    
                    DatePicker("End Date", selection: $endDate,
                               in: startDate ... (orders.last?.date ?? Date()),
                               displayedComponents: [.date])
                        .labelsHidden()
                }
            }
            
            // Profit Chart
            GeometryReader { geo in
                Chart(dateRangeArray, id: \.self) { date in
                    // Filter orders for that day
                    let dailyOrders = orders.filter { $0.date.isSameDay(as: date) }
                    
                    // Separate pending vs completed
                    let grouped = Dictionary(grouping: dailyOrders, by: \.paymentStatus)
                    let pendingOrders = grouped[.pending] ?? []
                    let completedOrders = grouped[.completed] ?? []
                    
                    let confirmedProfits = completedOrders.reduce(0.0) {
                        $0 + ($1.amountPaid - $1.totalCost)
                    }
                    let unconfirmedProfits = pendingOrders.reduce(0.0) {
                        $0 + ($1.amountPaid - $1.totalCost)
                    }
                    // Bars
                    BarMark(
                        x: .value("Day", date, unit: .day),
                        y: .value("Profits", confirmedProfits)
                    )
                    .foregroundStyle(confirmedProfits >= 0 ? Color.green.gradient : Color.red.gradient)
                    
                    BarMark(
                        x: .value("Day", date, unit: .day),
                        y: .value("Profits", unconfirmedProfits)
                    )
                    .foregroundStyle(.gray.gradient)
                    
                    // Hover effect
                    if let currentHoverDate, currentHoverDate.isSameDay(as: date) {
                        // Dynamic offset if near edges
                        let hoverOffset: CGFloat = hoverOffsetFor(date: currentHoverDate, in: domain, chartCount: dateRangeArray.count)
                        
                        RuleMark(x: .value("Day", currentHoverDate, unit: .day))
                            .foregroundStyle(.gray)
                            .lineStyle(.init(lineWidth: 2, dash: [2], dashPhase: 5))
                            .annotation(position: .top) {
                                VStack(alignment: .leading) {
                                    if !pendingOrders.isEmpty {
                                        HStack {
                                            Image(systemName: "circle.fill")
                                                .foregroundStyle(confirmedProfits > 0 ? Color.green.gradient : Color.red.gradient)
                                            Text("₹\(confirmedProfits.formatted()) Paid")
                                                .bold()
                                        }
                                        HStack {
                                            Image(systemName: "circle.fill")
                                                .foregroundStyle(.gray.gradient)
                                            Text("₹\(unconfirmedProfits.formatted()) Pending")
                                                .bold()
                                        }
                                        .minimumScaleFactor(0.5)
                                    } else {
                                        Text(confirmedProfits, format: .currency(code: "INR"))
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
                                .offset(x: hoverOffset, y: unconfirmedProfits > 0 ? 80 : 60)
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
                    ) { date in
                        AxisValueLabel(format: .dateTime.month().day())
                    }
                }
                .chartXScale(domain: domain)
                .chartYScale(domain: minimumProfit...maximumProfit)  // If needed, you can limit or expand the Y range
                .chartOverlay { proxy in
                    GeometryReader { _ in
                        Rectangle().fill(.clear).contentShape(Rectangle())
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
    
    /// Computes a left/right offset for the annotation if near the edges.
    private func hoverOffsetFor(date: Date, in domain: ClosedRange<Date>, chartCount: Int) -> CGFloat {
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
