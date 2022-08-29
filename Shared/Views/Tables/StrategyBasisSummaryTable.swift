//
//  StrategyBasisSummaryTable.swift
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

struct StrategyBasisSummaryTable: View {
    @Binding var document: WorthDocument
    @State var tableData: [TableRow]
    
    struct TableRow: Hashable, Identifiable {
        internal init(strategyKey: StrategyKey, begTB: Double, endTB: Double, deltaTB: Double, deltaPercent: Double? = nil) {
            self.id = strategyKey
            self.strategyKey = strategyKey
            self.begTB = begTB
            self.endTB = endTB
            self.deltaTB = deltaTB
            self.deltaPercent = deltaPercent
        }
        
        var id: StrategyKey
        var strategyKey: StrategyKey
        var begTB: Double
        var endTB: Double
        var deltaTB: Double
        var deltaPercent: Double?
    }
    
    private let gridItems: [GridItem] = [
        GridItem(.flexible(minimum: 170), spacing: columnSpacing),
        GridItem(.fixed(170), spacing: columnSpacing),
        GridItem(.fixed(170), spacing: columnSpacing),
        GridItem(.fixed(170), spacing: columnSpacing),
        GridItem(.fixed(170), spacing: columnSpacing),
    ]
    
    @State var hovered: TableRow.ID? = nil
    
    var body: some View {
        TablerStack(.init(rowSpacing: flowRowSpacing, onHover: hoverAction),
                    header: header,
                    row: row,
                    rowBackground: rowBackground,
                    results: tableData)
    }
    
    typealias Sort = TablerSort<TableRow>
    typealias Context = TablerContext<TableRow>
    
    private func header(_ ctx: Binding<Context>) -> some View {
        LazyVGrid(columns: gridItems, alignment: .leading, spacing: flowColumnSpacing) {
            Sort.columnTitle("Strategy (ID)", ctx, \.strategyKey)
                .modifier(HeaderCell())
                .onTapGesture {
                    tablerSort(ctx, &tableData, \.strategyKey, { $0.strategyKey < $1.strategyKey })
                }
            Sort.columnTitle("Begin Total Basis", ctx, \.begTB)
                .modifier(HeaderCell())
                .onTapGesture {
                    tablerSort(ctx, &tableData, \.begTB, { $0.begTB < $1.begTB })
                }
            Sort.columnTitle("End Total Basis", ctx, \.endTB)
                .modifier(HeaderCell())
                .onTapGesture {
                    tablerSort(ctx, &tableData, \.endTB, { $0.endTB < $1.endTB })
                }
            Sort.columnTitle("\(WorthDocument.deltaCurrencySymbol)", ctx, \.deltaTB)
                .modifier(HeaderCell())
                .onTapGesture {
                    tablerSort(ctx, &tableData, \.deltaTB, { $0.deltaTB < $1.deltaTB })
                }
            Sort.columnTitle("\(WorthDocument.deltaPercentSymbol)", ctx, \.deltaPercent)
                .modifier(HeaderCell())
                .onTapGesture {
                    tablerSort(ctx, &tableData, \.deltaPercent, { ($0.deltaPercent ?? 0) < ($1.deltaPercent ?? 0) })
                }
        }
    }
    
    private func row(_ item: TableRow) -> some View {
        LazyVGrid(columns: gridItems, alignment: .leading, spacing: flowColumnSpacing) {
            Text(MStrategy.getStrategyTitleID(item.strategyKey, ax.strategyMap, withID: true) ?? "")
                .lineLimit(1)
                .mpadding()
            CurrencyLabel(value: Double(item.begTB), style: .whole)
                .mpadding()
            CurrencyLabel(value: Double(item.endTB), style: .whole)
                .mpadding()
            CurrencyLabel(value: Double(item.deltaTB), style: .whole)
                .mpadding()

            if let dp = item.deltaPercent {
                PercentLabel(value: dp)
                    .mpadding()
            } else {
                Text("n/a")
                    .mpadding()
            }
        }
    }
    
    public func rowBackground(_ item: TableRow) -> some View {
        RoundedRectangle(cornerRadius: 5)
            .fill(Color.accentColor.opacity(hovered == item.id ? 0.2 : 0.0))
    }
    
    // MARK: - Properties
    
    private var ax: WorthContext {
        document.context
    }
    
    private var ms: ModelSettings {
        document.modelSettings
    }
    
    // MARK: - Helpers
    
    // MARK: - Actions
    
    private func hoverAction(itemID: TableRow.ID, isHovered: Bool) {
        if isHovered { hovered = itemID } else { hovered = nil }
    }
}
