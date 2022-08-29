//
//  ReturnsFooter.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//


import SwiftUI

import AllocData
import Compactor

import FlowUI
import FlowBase
import FlowWorthLib

private let maxDateRange: ClosedRange<Date> = Date.init(timeIntervalSinceReferenceDate: 0)...Date.init(timeIntervalSinceReferenceDate: TimeInterval.greatestFiniteMagnitude)

struct ReturnsFooter: View {
    @AppStorage(UserDefShared.timeZoneID.rawValue) var timeZoneID: String = ""

    @Binding var document: WorthDocument
    @ObservedObject var mr: MatrixResult
    
    var body: some View {
        VStack {
            upperControls
                .frame(height: 60)
            if document.displaySettings.returnsExpandBottom {
                lowerControls
                    .frame(maxHeight: 50)
                    .padding()
            }
        }
    }
    
    // NOTE crash occurring if hiding upperTrailing based on showSecondary
    private var upperControls: some View {
        HStack(alignment: .center, spacing: 10) {
            upperLeading
            upperTrailing
        }
    }
    
    @ViewBuilder
    private var upperLeading: some View {
        MyToggleButton(value: $document.displaySettings.returnsExpandBottom, imageName: "slider.horizontal.below.rectangle")
            .foregroundColor(controlTextColor)
            .font(.largeTitle)
        
        StatsBoxView(title: "Period") {
            StatusDisplay(title: nil,
                          value: formattedPeriodDuration,
                          format: { $0 })
        }
        
        if document.displaySettings.periodSummarySelection.isDietz {
            StatsBoxView(title: "\(WorthDocument.rSymbol) (period)") {
                StatusDisplay(title: nil,
                              value: mr.periodSummary?.dietz!.performance ?? 0,
                              format: { mr.hasCashflow ? "\($0.toPercent1(leadingPlus: true))" : "n/a" })
            }
            
            StatsBoxView(title: "\(WorthDocument.rSymbol) (annualized)") {
                StatusDisplay(title: nil,
                              value: (mr.periodSummary?.dietz!.performance ?? 0) / (mr.periodSummary?.yearsInPeriod ?? 0),
                              format: { mr.hasCashflow ? "\($0.toPercent1(leadingPlus: true))" : "n/a" })
            }
        } else {
            StatsBoxView(title: "\(WorthDocument.deltaPercentSymbol) (period)") {
                StatusDisplay(title: nil,
                              value: mr.periodSummary?.singlePeriodReturn ?? 0,
                              format: { "\(Double($0).toPercent1(leadingPlus: true))" },
                              enabled: mr.periodSummary?.singlePeriodReturn != nil)
            }
            
            StatsBoxView(title: "\(WorthDocument.deltaSymbol) (annualized)") {
                StatusDisplay(title: nil,
                              value: mr.periodSummary?.marketValueDeltaPerYear ?? 0,
                              format: { "\(Double($0).toCurrency(style: .compact))/yr" })
            }
        }

    }
    
    @ViewBuilder
    private var upperTrailing: some View {
        if document.displaySettings.periodSummarySelection.isDietz,
           let md = mr.periodSummary?.dietz {
            StatsBoxView(title: "Net Cash Flow") {
                StatusDisplay(title: nil,
                              value: md.netCashflowTotal,
                              format: { "\($0.toCurrency(style: .compact))" })
            }
        } else {
            StatsBoxView(title: "\(WorthDocument.deltaSymbol) (daily)") {
                StatusDisplay(title: nil,
                              value: mr.periodSummary?.marketValueDeltaPerDay ?? 0,
                              format: { "\(Double($0).toCurrency(style: .compact))/day" })
            }
        }
        
        StatsBoxView(title: "Market Value") {
            StatusDisplay(title: nil,
                          value: mr.marketValueRange ?? 0...0,
                          format: { "\(Double($0.lowerBound).toCurrency(style: .compact)) … \(Double($0.upperBound).toGeneral(style: .compact))" },
                          textStyle: .title3)
        }
    }
    
    private var lowerControls: some View {
        HStack {
            StatsBoxView(title: "Start") {
                SnapshotNavPicker(model: document.model,
                                  ax: ax,
                                  snapshotKey: $document.displaySettings.begSnapshotKey,
                                  range: startRange)
                    .onChange(of: document.displaySettings.begSnapshotKey,
                              perform: refreshAction)
            }
            
            Button(action: setMaxRangeAction, label: {
                Image(systemName: "arrow.left.and.right")
                    .foregroundColor(controlTextColor)
                    .font(.largeTitle)
            })
            .buttonStyle(BorderlessButtonStyle())
            .help("Expand to maximum range")

            StatsBoxView(title: "End") {
                SnapshotNavPicker(model: document.model,
                                  ax: ax,
                                  snapshotKey: $document.displaySettings.endSnapshotKey,
                                  range: endRange)
                    .onChange(of: document.displaySettings.endSnapshotKey,
                              perform: refreshAction)
            }
        }
    }
    
    // MARK: - Properties
        
    private var controlTextColor: Color {
        #if os(macOS)
        Color(.controlTextColor)
        #else
        Color.primary
        #endif
    }

    private var isCompact: Bool {
        document.displaySettings.showSecondary
    }

    private static var timeCompactor = TimeCompactor(ifZero: "", style: .full)
    
    private var formattedPeriodDuration: String {
        ReturnsFooter.timeCompactor.string(from: mr.periodDuration as NSNumber) ?? ""
    }
    
    private var ax: WorthContext {
        document.context
    }
    
    private var ds: DisplaySettings {
        document.displaySettings
    }
    
    private var earliestCapturedAt: Date {
        ax.firstSnapshotCapturedAt ?? Date.init(timeIntervalSinceReferenceDate: 0)
    }
    
    private var latestCapturedAt: Date {
        ax.lastSnapshotCapturedAt ?? Date.init(timeIntervalSinceReferenceDate: TimeInterval.greatestFiniteMagnitude)
    }
    
    private var startRange: DateInterval {
        let endCapturedAt = ax.snapshotMap[ ds.endSnapshotKey ]?.capturedAt ?? latestCapturedAt
        //return earliestCapturedAt...endCapturedAt
        return DateInterval(start: earliestCapturedAt, end: endCapturedAt)
    }
    
    private var endRange: DateInterval {
        let startCapturedAt = ax.snapshotMap[ ds.begSnapshotKey ]?.capturedAt ?? earliestCapturedAt
        //return startCapturedAt...latestCapturedAt
        return DateInterval(start: startCapturedAt, end: latestCapturedAt)
    }
    
    // MARK: - Actions
    
    private func refreshAction(_ snapshotKey: SnapshotKey) {
        document.refreshWorthResult(timeZoneID: timeZoneID)
    }
    
    private func setMaxRangeAction() {
        guard let earliestKey = ax.firstSnapshotKey,
              let latestKey = ax.lastSnapshotKey
        else { return }
        document.displaySettings.begSnapshotKey = earliestKey
        document.displaySettings.endSnapshotKey = latestKey
    }
}
