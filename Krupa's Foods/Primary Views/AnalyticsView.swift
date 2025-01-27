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
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    var product: Product
    @Query var orders: [Order]
    @State private var selectedTimeFrame: TimeFrame = .lastWeek
    
    init(product: Product) {
        let id = product.id
        self._orders = Query(filter: #Predicate<Order> { order in
            return order.product?.id == id
        }, sort: \.date, order: .forward, animation: .default)
        
        self.product = product
    }
    
    @State private var startDate = Date.now.addingTimeInterval(-86400 * 7)
    @State private var endDate = Date.now
    
    enum TimeFrame: Hashable {
        case lastWeek
        case lastMonth
        case custom
        
        var title: String {
            switch self {
            case .lastWeek:
                return "7 Days"
            case .lastMonth:
                return "30 Days"
            case .custom:
                return "Custom"
            }
        }
        
    }
    
    private var dateRange: (Date, Date) {
        switch selectedTimeFrame {
        case .lastWeek:
            return (Calendar.current.date(byAdding: .day, value: -7, to: Date())
                    ?? Date.now, Date.now)
        case .lastMonth:
            return (Calendar.current.date(byAdding: .day, value: -30, to: Date())
                    ?? Date.now, Date.now)
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
    
    var filteredOrders: [Order] {
        orders.filter { order in
            let date = order.date
            return date >= dateRange.0 && date <= dateRange.1
        }
    }
    
    var pendingPaymentOrders: [Order] {
        filteredOrders.filter { order in
            return order.paymentStatus == .pending
        }
    }
    
    var pendingRevenue: Double {
        pendingPaymentOrders.reduce(0.0) { $0 + $1.amountPaid }
    }
    
    var completedPaymentOrders: [Order] {
        filteredOrders.filter { order in
            return order.paymentStatus == .completed
        }
    }
    
    var completedRevenue: Double {
        completedPaymentOrders.reduce(0.0) { $0 + $1.amountPaid }
    }
    
    func revenueArray() -> [Date: Double] {
        var revenueDict: [Date: Double] = [:]
        for date in dateRangeArray {
            let dailyOrders = orders.filter { $0.date.isSameDay(as: date) }
            let totalRevenue = dailyOrders.reduce(0.0) { $0 + $1.amountPaid }
            revenueDict[date] = totalRevenue
        }
        return revenueDict
    }
    
    var profitArray: [Date: Double] {
        var profit: [Date: Double] = [:]
        for date in dateRangeArray {
            profit[date] = orders.filter { order in
                return order.date.isSameDay(as: date)
            }.reduce(0.0) { sum, order in
                let totalCost = ((order.wrappedStock.reduce(0.0){ $0 + $1.averageCost })/Double(order.wrappedStock.count)) * order.quantity
                return sum + order.amountPaid - totalCost
            }
        }
        
        return profit
    }
    
    var totalRevenueForTimePeriod: Double {
        orders.filter { order in
            let date = order.date
            return date >= dateRange.0 && date <= dateRange.1
        }.reduce(0.0) { $0 + $1.amountPaid }
    }
    
    @State private var isAnimated = false
    
    @State private var currentHoverDate: Date?
    
    var secondsRemaining: Double {
        return (86400 - Date.now.timeIntervalSince(Calendar.current.startOfDay(for: Date.now)))
    }
    
    var secondsPast: Double {
        return (Date.now.timeIntervalSince(Calendar.current.startOfDay(for: Date.now)))
    }
    
    var domain: ClosedRange<Date> {
        dateRange.0.advanced(by: -secondsPast)...dateRange.1.advanced(by: secondsRemaining)
    }
    
    var body: some View {
        Form {
            VStack {
            }
            .frame(height: 0)
            .listRowInsets(.none)
            .listRowBackground(Color(uiColor: .systemGroupedBackground))
            
            Section("Revenue") {
                VStack {
                    HStack {
                        Text(totalRevenueForTimePeriod, format: .currency(code: "INR"))
                            .font(.system(.largeTitle, design: .rounded))
                            .bold()
                        
                        Spacer()
                        
                        Picker("Time Frame", selection: $selectedTimeFrame) {
                            Text("Last 7 Days")
                                .tag(TimeFrame.lastWeek)
                            
                            Text("Last 30 Days")
                                .tag(TimeFrame.lastMonth)
                            
                            Text("Custom")
                                .tag(TimeFrame.custom)
                        }
                        .labelsHidden()
                    }
                    
                    if selectedTimeFrame == .custom {
                        HStack {
                            DatePicker("Start Date", selection: $startDate, in: orders.first!.date...endDate, displayedComponents: [.date])
                                .labelsHidden()
                        
                            
                            Spacer()
                            
                            DatePicker("End Date", selection: $endDate, in: startDate...orders.last!.date, displayedComponents: [.date])
                                .labelsHidden()
                        }
                    }
                    
                    
                    GeometryReader { geo in
                        Chart(dateRangeArray, id: \.self) { date in
                            // Filter orders by the specified date
                            let dailyOrders = orders.filter { $0.date.isSameDay(as: date) }

                            // Group orders by payment status
                            let groupedOrders = Dictionary(grouping: dailyOrders, by: \.paymentStatus)

                            // Extract pending and completed orders
                            let pendingOrders = groupedOrders[.pending] ?? []
                            let completedOrders = groupedOrders[.completed] ?? []

                            // Calculate revenues
                            let confirmedRevenue = completedOrders.reduce(0.0) { $0 + $1.amountPaid }
                            let unconfirmedRevenue = pendingOrders.reduce(0.0) { $0 + $1.amountPaid }
                            
                            BarMark (x: .value("Day", date, unit: .day), y: .value("Revenue", isAnimated ? confirmedRevenue  : 0))
                                .foregroundStyle(.orange.gradient)
                            BarMark (x: .value("Day", date, unit: .day), y: .value("Revenue", isAnimated ? unconfirmedRevenue : 0))
                                .foregroundStyle(.gray.gradient)
                            
                            if let currentHoverDate, currentHoverDate.isSameDay(as: date) {
                                var hoverDateOffset: CGFloat {
                                    // Calculate the dynamic threshold in seconds based on the range and view width.
                                    let rawThreshold = Double(ceil(Double(dateRangeArray.count))) * 0.1
                                    let thresholdDays = ceil(rawThreshold)
                                    
                                    let timeFromStart = ceil(currentHoverDate.timeIntervalSince(domain.lowerBound) / 86400)
                                    let timeToEnd = ceil(domain.upperBound.timeIntervalSince(currentHoverDate)/86400)
                                    
                                    // Determine if hoverDate is near the start or end based on the threshold
                                    let isNearStart = timeFromStart <= thresholdDays
                                    let isNearEnd = timeToEnd <= thresholdDays
                                    
                                    // Define the maximum offset magnitude
                                    let maxOffset: CGFloat = 45 // Adjust as needed for UI
                                    
                                    if isNearStart {
                                        return maxOffset
                                    } else if isNearEnd {
                                        return -maxOffset
                                    } else {
                                        return 0 // No offset if not near any end
                                    }
                                }
                                
                                RuleMark(x: .value("Day", currentHoverDate, unit: .day))
                                    .foregroundStyle(.gray)
                                    .lineStyle(.init(lineWidth: 2, dash: [2], dashPhase: 5))
                                    .annotation(position: .top) {
                                        VStack(alignment: .leading) {
                                            if !pendingOrders.isEmpty {
                                                HStack {
                                                    Image(systemName: "circle.fill")
                                                        .foregroundStyle(.orange.gradient)
                                                    
                                                    Text("₹\(confirmedRevenue.formatted()) Paid")
                                                        .bold()
                                                }

                                                HStack {
                                                    Image(systemName: "circle.fill")
                                                        .foregroundStyle(.gray.gradient)
                                                    
                                                    Text("₹\(unconfirmedRevenue.formatted()) Pending")
                                                        .bold()
                                                }
                                            } else {
                                                Text(confirmedRevenue, format: .currency(code: "INR"))
                                                    .bold()
                                            }
                                            
                                            Divider()
                                            
                                            Text("^[\(orders.filter{$0.date.isSameDay(as: currentHoverDate)}.count) Orders](inflect: true)")
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
                                        .offset(x: hoverDateOffset, y: unconfirmedRevenue > 0 ? 80 : 60)
                                    }
                            }
                        }
                        .chartXAxis {
                            AxisMarks(values: .stride(by: .day)) { date in
                                AxisGridLine()
                            }
                            AxisMarks(values: .stride(by: .day, count: Int(ceil(Double(dateRangeArray.count) / (geo.size.width / 80))))) { date in
                                AxisValueLabel(format: .dateTime.month().day())
                            }
                        }
                        .chartXScale(domain: domain) // Fixes the hover overlay glitching.
                        .chartYScale(domain: 0...(CGFloat(revenueArray().values.max() ?? 0) + 1000))
                    }
                    .chartOverlay { proxy in
                        GeometryReader { innerProxy in
                            Rectangle()
                                .fill(.clear).contentShape(Rectangle())
                                .gesture (
                                    DragGesture()
                                        .onChanged { value in
                                            let location = value.location
                                            if let day = proxy.value(atX: location.x, as: Date.self) {
                                                currentHoverDate = day
                                            }
                                        }
                                        .onEnded{ value in
                                            currentHoverDate = nil
                                        }
                                )
                        }
                    }
                    .frame(height: 200)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation(.bouncy) {
                                isAnimated = true
                            }
                        }
                    }
                    .onDisappear {
                        isAnimated = false
                    }
                }
            }
        }
    }
    
    func orders(for date: Date) -> [Order] {
        orders.filter { order in
            return order.date.isSameDay(as: date)
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
