//
//  DeltaSnapshotTable.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//


import SwiftUI

import Tabler
import AllocData

import FlowBase
import FlowUI
import FlowWorthLib

struct DeltaSnapshotTable: View {
    @Binding var document: WorthDocument
    @ObservedObject var mr: MatrixResult
    
    private let futureValueMaxCount = 10
    private let futureValuesMultiplier = 1.5
    
    // simple struct needed with ForEach
    struct DeltaSnapshotInfo: Hashable, Identifiable {
        let id: Double
        var capturedAt: Date
        var marketValue: Double
        var gainLoss: Double
        var accumGainLoss: Double
        
        internal init(capturedAt: Date, marketValue: Double, gainLoss: Double, accumGainLoss: Double) {
            self.id = capturedAt.timeIntervalSinceReferenceDate
            self.capturedAt = capturedAt
            self.marketValue = marketValue
            self.gainLoss = gainLoss
            self.accumGainLoss = accumGainLoss
        }
        
        var accumSnapshotReturn: Double {
            (marketValue / (marketValue - accumGainLoss)) - 1
        }
        
        func getDistance(mr: MatrixResult) -> Double? {
            guard let first = mr.capturedAts.first else { return nil }
            return first.distance(to: capturedAt)
        }
        
        func getDaily(mr: MatrixResult) -> Double? {
            guard let distance = getDistance(mr: mr) else { return nil }
            let totalDays = distance / 24 / 60 / 60
            return accumGainLoss / totalDays
        }
    }
    
    private let gridItems: [GridItem] = [
        GridItem(.flexible(minimum: 120), spacing: columnSpacing),
        GridItem(.flexible(minimum: 110), spacing: columnSpacing),
        GridItem(.flexible(minimum: 80), spacing: columnSpacing),
        GridItem(.flexible(minimum: 80), spacing: columnSpacing),
        GridItem(.flexible(minimum: 80), spacing: columnSpacing),
    ]
    
    @State var hovered: DeltaSnapshotInfo.ID? = nil

    var body: some View {
        TablerStack(.init(rowSpacing: flowRowSpacing, onHover: hoverAction),
                    header: header,
                    row: row,
                    rowBackground: rowBackground,
                    results: getDeltaSnapshots())
            .sideways(minWidth: 500, showIndicators: true)
        HStack { Spacer(); Text("*period to date").font(.footnote) }
    }
    
    typealias Context = TablerContext<DeltaSnapshotInfo>
    
    private func header(_ ctx: Binding<Context>) -> some View {
        LazyVGrid(columns: gridItems, alignment: .leading, spacing: flowColumnSpacing) {
            Text("Captured At")
                .modifier(HeaderCell())
            Text("Market Value")
                .modifier(HeaderCell())
            Text("\(WorthDocument.deltaSymbol)")
                .modifier(HeaderCell())
            Text("%\(WorthDocument.deltaSymbol)*")
                .modifier(HeaderCell())
            Text("\(WorthDocument.deltaSymbol)(daily)*")
                .modifier(HeaderCell())
        }
    }
    
    private func row(_ item: DeltaSnapshotInfo) -> some View {
        LazyVGrid(columns: gridItems, alignment: .leading, spacing: flowColumnSpacing) {
            DateLabel(item.capturedAt, withTime: false)
                .mpadding()
            CurrencyLabel(value: item.marketValue, style: .compact)
                .mpadding()
            CurrencyLabel(value: item.gainLoss, style: .compact, leadingPlus: true)
                .mpadding()
            Group {
                if mr.periodSummary?.singlePeriodReturn != nil {
                    PercentLabel(value: item.accumSnapshotReturn, leadingPlus: true)
                        .mpadding()
                } else {
                    Text("n/a")
                        .mpadding()
                }
            }
            Group {
                let daily = item.getDaily(mr: mr) ?? 0
                CurrencyLabel(value: daily, style: .whole)
                    .mpadding()
            }
        }
    }
    
    public func rowBackground(_ item: DeltaSnapshotInfo) -> some View {
        RoundedRectangle(cornerRadius: 5)
            .fill(Color.accentColor.opacity(hovered == item.id ? 0.2 : 0.0))
    }

    // MARK: - Properties
    
    private var ax: WorthContext {
        document.context
    }
    
    // generate a nice set of future values, skipping those that are less than current MV
    private func getDeltaSnapshots() -> [DeltaSnapshotInfo] {
        var lastMarketValue: Double = 0
        var accumGainLoss: Double = 0
        return mr.orderedSnapshots.enumerated().reduce(into: []) { array, entry in
            let (n, snapshot) = entry
            guard let mv = mr.snapshotMarketValueMap[snapshot.primaryKey] else { return }
            let gainLoss = mv - lastMarketValue
            if n > 0 {
                accumGainLoss += gainLoss
            }
            array.append(DeltaSnapshotInfo(capturedAt: snapshot.capturedAt,
                                           marketValue: mv,
                                           gainLoss: gainLoss,
                                           accumGainLoss: accumGainLoss))
            lastMarketValue = mv
        }
    }
    
    // MARK: - Actions
    
    private func hoverAction(itemID: FutureValueInfo.ID, isHovered: Bool) {
        if isHovered { hovered = itemID } else { hovered = nil }
    }
}

