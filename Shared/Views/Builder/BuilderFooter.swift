//
//  BuilderFooter.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

import AllocData

import FlowBase
import FlowWorthLib
import FlowUI

struct BuilderFooter: View {
    @Binding var document: WorthDocument
    
    private static let dfShort: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .short
        df.timeStyle = .short
        return df
    }()

    var body: some View {
        HStack(spacing: 10) {
            StatsBoxView(title: "Snapshots") {
                StatusDisplay(title: nil,
                              value: document.model.valuationSnapshots.count,
                              format: { String($0) })
            }
            .frame(maxWidth: 90)
            StatsBoxView(title: "Most Recent Snapshot") {
                StatusDisplay(title: nil,
                              value: previousSnapshotFormatted,
                              format: { $0 },
                              textStyle: .title3)
                    .foregroundColor(ax.lastSnapshotCapturedAt != nil ? .primary : .secondary)
            }
            StatsBoxView(title: "Positions (market value)") {
                StatusDisplay(title: nil,
                              value: positionsFormatted,
                              format: { $0 })
                    .foregroundColor(ps.nuPositions.count > 0 ? .primary : .secondary)
            }
            StatsBoxView(title: "Cash Flow (net)") {
                StatusDisplay(title: nil,
                              value: netCashflowFormatted,
                              format: { $0 })
                    .foregroundColor(ps.nuCashflows.count > 0 ? .primary : .secondary)
            }
            
            if document.displaySettings.periodSummarySelection == .modifiedDietz {
                StatsBoxView(title: "\(WorthDocument.rSymbol) (period)") {
                    StatusDisplay(title: nil,
                                  value: psum?.dietz!.performance ?? 0,
                                  format: { "\($0.toPercent1(leadingPlus: true))" })
                }
            }
        }
    }
    
    // MARK: - Properties
    
    private var ax: WorthContext {
        document.context
    }

    private var ps: PendingSnapshot {
        document.pendingSnapshot
    }
    
    private var psum: PeriodSummary? {
        document.pendingSnapshot.periodSummary
    }
    
    private var previousSnapshotFormatted: String {
        if let capturedAt = ax.lastSnapshotCapturedAt {
            return BuilderFooter.dfShort.string(from: capturedAt)
        } else {
            return "None"
        }
    }
    
    private var positionsFormatted: String {
        guard ps.nuPositions.count > 0 else { return "None" }
        return "\(ps.nuPositions.count) @ \(ps.nuMarketValue.toCurrency(style: .compact))"
    }
    
    private var netCashflowFormatted: String {
        guard ps.nuCashflows.count > 0 else { return "None" }
        return "\(ps.nuCashflows.count) @ \(ps.netCashflowTotal.toCurrency(style: .compact))"
    }
}

