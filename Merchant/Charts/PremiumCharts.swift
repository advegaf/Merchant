// Rules: Advanced data visualization components inspired by Copilot's chart design
// Inputs: Financial data, time series, categorical spending data
// Outputs: Interactive charts with smooth animations and premium styling
// Constraints: 60fps performance, accessibility-compliant, gesture-driven

import SwiftUI
import Charts

/// Premium chart components that make data visualization feel luxurious
struct PremiumCharts {

    // MARK: - Spending Breakdown Chart (Copilot-style)

    struct SpendingBreakdownChart: View {
        let data: [CategorySpending]
        @State private var selectedCategory: CategorySpending?
        @State private var chartAngle: Double = 0

        var body: some View {
            PremiumMaterialCard(style: .premium) {
                VStack(spacing: PremiumDesign.Spacing.xl) {
                    // Header
                    HStack {
                        VStack(alignment: .leading, spacing: PremiumDesign.Spacing.xs) {
                            Text("This Month")
                                .font(PremiumDesign.Typography.labelLarge)
                                .foregroundStyle(PremiumDesign.Colors.gray700)

                            PremiumNumberDisplay(
                                value: "$2,847",
                                label: nil,
                                trend: .down,
                                size: .large
                            )
                        }
                        Spacer()
                    }

                    // Chart
                    Chart(data, id: \.category) { item in
                        SectorMark(
                            angle: .value("Amount", item.amount),
                            innerRadius: .ratio(0.6),
                            angularInset: 2
                        )
                        .foregroundStyle(item.color.gradient)
                        .opacity(selectedCategory == nil || selectedCategory?.category == item.category ? 1.0 : 0.3)
                    }
                    .frame(height: 200)
                    .chartLegend(.hidden)
                    .chartAngleSelection(value: .constant(chartAngle))
                    .animation(PremiumDesign.Animations.gentleSpring, value: selectedCategory)

                    // Legend
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: PremiumDesign.Spacing.lg) {
                        ForEach(data, id: \.category) { item in
                            HStack(spacing: PremiumDesign.Spacing.sm) {
                                Circle()
                                    .fill(item.color)
                                    .frame(width: 12, height: 12)

                                VStack(alignment: .leading, spacing: PremiumDesign.Spacing.xxs) {
                                    Text(item.category)
                                        .font(PremiumDesign.Typography.labelMedium)
                                        .foregroundStyle(PremiumDesign.Colors.gray800)

                                    Text("$\(Int(item.amount))")
                                        .font(PremiumDesign.Typography.numberSmall)
                                        .foregroundStyle(PremiumDesign.Colors.gray900)
                                }

                                Spacer()
                            }
                            .onTapGesture {
                                withAnimation(PremiumDesign.Animations.responsiveSpring) {
                                    selectedCategory = selectedCategory == item ? nil : item
                                }
                            }
                        }
                    }
                }
                .padding(PremiumDesign.Spacing.xxl)
            }
        }
    }

    // MARK: - Trending Chart (Line chart with gradient)

    struct TrendingChart: View {
        let data: [DailySpending]
        @State private var selectedPoint: DailySpending?
        @State private var animateChart = false

        var body: some View {
            PremiumMaterialCard(style: .frosted) {
                VStack(spacing: PremiumDesign.Spacing.xl) {
                    HStack {
                        VStack(alignment: .leading, spacing: PremiumDesign.Spacing.xs) {
                            Text("Daily Spending")
                                .font(PremiumDesign.Typography.labelLarge)
                                .foregroundStyle(PremiumDesign.Colors.gray700)

                            PremiumNumberDisplay(
                                value: "$127",
                                label: "Today",
                                trend: .up,
                                size: .medium
                            )
                        }
                        Spacer()
                    }

                    Chart(data) { item in
                        LineMark(
                            x: .value("Day", item.date),
                            y: .value("Amount", animateChart ? item.amount : 0)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [PremiumDesign.Colors.primaryBlue, PremiumDesign.Colors.primaryPurple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))

                        AreaMark(
                            x: .value("Day", item.date),
                            y: .value("Amount", animateChart ? item.amount : 0)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    PremiumDesign.Colors.primaryBlue.opacity(0.3),
                                    PremiumDesign.Colors.primaryBlue.opacity(0.0)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )

                        if let selectedPoint = selectedPoint {
                            PointMark(
                                x: .value("Day", selectedPoint.date),
                                y: .value("Amount", selectedPoint.amount)
                            )
                            .foregroundStyle(PremiumDesign.Colors.primaryBlue)
                            .symbolSize(80)
                        }
                    }
                    .frame(height: 180)
                    .chartXAxis(.hidden)
                    .chartYAxis(.hidden)
                    .onAppear {
                        withAnimation(PremiumDesign.Animations.easeOutExpo) {
                            animateChart = true
                        }
                    }
                }
                .padding(PremiumDesign.Spacing.xl)
            }
        }
    }

    // MARK: - Metrics Grid (Copilot-style stat cards)

    struct MetricsGrid: View {
        let metrics: [MetricData]

        var body: some View {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: PremiumDesign.Spacing.lg) {
                ForEach(metrics, id: \.title) { metric in
                    PremiumMaterialCard(style: .glass) {
                        VStack(alignment: .leading, spacing: PremiumDesign.Spacing.md) {
                            HStack {
                                Image(systemName: metric.icon)
                                    .font(.title2)
                                    .foregroundStyle(metric.color)
                                Spacer()
                            }

                            Spacer()

                            VStack(alignment: .leading, spacing: PremiumDesign.Spacing.xs) {
                                PremiumNumberDisplay(
                                    value: metric.value,
                                    label: nil,
                                    trend: metric.trend,
                                    size: .medium
                                )

                                Text(metric.title)
                                    .font(PremiumDesign.Typography.labelMedium)
                                    .foregroundStyle(PremiumDesign.Colors.gray700)
                            }
                        }
                        .padding(PremiumDesign.Spacing.xl)
                        .frame(height: 120)
                    }
                }
            }
        }
    }

    // MARK: - Progress Ring (Apple-style)

    struct ProgressRing: View {
        let progress: Double
        let title: String
        let subtitle: String
        @State private var animatedProgress: Double = 0

        var body: some View {
            VStack(spacing: PremiumDesign.Spacing.lg) {
                ZStack {
                    // Background ring
                    Circle()
                        .stroke(PremiumDesign.Colors.gray400, lineWidth: 8)

                    // Progress ring
                    Circle()
                        .trim(from: 0, to: animatedProgress)
                        .stroke(
                            LinearGradient(
                                colors: [PremiumDesign.Colors.primaryBlue, PremiumDesign.Colors.primaryPurple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))

                    // Center content
                    VStack(spacing: PremiumDesign.Spacing.xs) {
                        Text("\(Int(progress * 100))%")
                            .font(PremiumDesign.Typography.numberMedium)
                            .foregroundStyle(PremiumDesign.Colors.gray900)

                        Text("Complete")
                            .font(PremiumDesign.Typography.labelSmall)
                            .foregroundStyle(PremiumDesign.Colors.gray700)
                    }
                }
                .frame(width: 100, height: 100)

                VStack(spacing: PremiumDesign.Spacing.xxs) {
                    Text(title)
                        .font(PremiumDesign.Typography.headlineSmall)
                        .foregroundStyle(PremiumDesign.Colors.gray900)

                    Text(subtitle)
                        .font(PremiumDesign.Typography.labelMedium)
                        .foregroundStyle(PremiumDesign.Colors.gray700)
                        .multilineTextAlignment(.center)
                }
            }
            .onAppear {
                withAnimation(PremiumDesign.Animations.easeOutExpo.delay(0.3)) {
                    animatedProgress = progress
                }
            }
        }
    }
}

// MARK: - Data Models

struct CategorySpending: Equatable {
    let category: String
    let amount: Double
    let color: Color
}

struct DailySpending: Identifiable {
    let date: Date
    let amount: Double
    var id: Date { date }
}

struct MetricData {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let trend: PremiumNumberDisplay.TrendDirection?
}

// MARK: - Preview Data

extension PremiumCharts {
    static let sampleCategorySpending = [
        CategorySpending(category: "Dining", amount: 847, color: PremiumDesign.Colors.primaryOrange),
        CategorySpending(category: "Shopping", amount: 623, color: PremiumDesign.Colors.primaryPurple),
        CategorySpending(category: "Gas", amount: 432, color: PremiumDesign.Colors.primaryBlue),
        CategorySpending(category: "Groceries", amount: 387, color: PremiumDesign.Colors.primaryGreen),
        CategorySpending(category: "Other", amount: 224, color: PremiumDesign.Colors.gray600)
    ]

    static let sampleDailySpending: [DailySpending] = {
        let calendar = Calendar.current
        let today = Date()
        return (0..<30).compactMap { dayOffset in
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) else { return nil }
            let amount = Double.random(in: 50...300)
            return DailySpending(date: date, amount: amount)
        }.reversed()
    }()

    static let sampleMetrics = [
        MetricData(
            title: "This Week",
            value: "$1,247",
            icon: "calendar.badge.plus",
            color: PremiumDesign.Colors.primaryGreen,
            trend: .up
        ),
        MetricData(
            title: "Avg/Day",
            value: "$178",
            icon: "chart.line.uptrend.xyaxis",
            color: PremiumDesign.Colors.primaryBlue,
            trend: .neutral
        ),
        MetricData(
            title: "Best Card",
            value: "3.2×",
            icon: "creditcard.and.123",
            color: PremiumDesign.Colors.primaryPurple,
            trend: nil
        ),
        MetricData(
            title: "Rewards",
            value: "$87",
            icon: "star.fill",
            color: PremiumDesign.Colors.primaryOrange,
            trend: .up
        )
    ]
}
