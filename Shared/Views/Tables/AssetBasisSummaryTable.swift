//
//  AssetBasisSummaryTable.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

import AllocData
import Tabler

import FlowBase
import FlowUI
import FlowWorthLib

struct AssetBasisSummaryTable: View {
    @Binding var document: WorthDocument
    @State var tableData: [TableRow]

    struct TableRow: Hashable, Identifiable {
        internal init(assetKey: AssetKey, begTB: Double, endTB: Double, deltaTB: Double, deltaPercent: Double? = nil) {
            id = assetKey
            self.assetKey = assetKey
            self.begTB = begTB
            self.endTB = endTB
            self.deltaTB = deltaTB
            self.deltaPercent = deltaPercent
        }

        var id: AssetKey
        var assetKey: AssetKey
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
        TablerStack(.init(rowSpacing: flowRowSpacing),
                    header: header,
                    row: row,
                    rowBackground: rowBackground,
                    results: tableData)
    }

    typealias Sort = TablerSort<TableRow>
    typealias Context = TablerContext<TableRow>

    private func header(_ ctx: Binding<Context>) -> some View {
        LazyVGrid(columns: gridItems, alignment: .leading, spacing: flowColumnSpacing) {
            Sort.columnTitle("Asset Class", ctx, \.assetKey)
                .modifier(HeaderCell())
                .onTapGesture {
                    tablerSort(ctx, &tableData, \.assetKey) { $0.assetKey < $1.assetKey }
                }
            Sort.columnTitle("Begin Total Basis", ctx, \.begTB)
                .modifier(HeaderCell())
                .onTapGesture {
                    tablerSort(ctx, &tableData, \.begTB) { $0.begTB < $1.begTB }
                }
            Sort.columnTitle("End Total Basis", ctx, \.endTB)
                .modifier(HeaderCell())
                .onTapGesture {
                    tablerSort(ctx, &tableData, \.endTB) { $0.endTB < $1.endTB }
                }
            Sort.columnTitle("\(WorthDocument.deltaCurrencySymbol)", ctx, \.deltaTB)
                .modifier(HeaderCell())
                .onTapGesture {
                    tablerSort(ctx, &tableData, \.deltaTB) { $0.deltaTB < $1.deltaTB }
                }
            Sort.columnTitle("\(WorthDocument.deltaPercentSymbol)", ctx, \.deltaPercent)
                .modifier(HeaderCell())
                .onTapGesture {
                    tablerSort(ctx, &tableData, \.deltaPercent) { ($0.deltaPercent ?? 0) < ($1.deltaPercent ?? 0) }
                }
        }
    }

    private func row(_ item: TableRow) -> some View {
        LazyVGrid(columns: gridItems, alignment: .leading, spacing: flowColumnSpacing) {
            Text(MAsset.getTitleID(item.assetKey, ax.assetMap, withID: true) ?? "")
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
        .foregroundColor(getColorCode(item.assetKey).0)
    }

    private func rowBackground(_ item: TableRow) -> some View {
        document.getBackgroundFill(item.assetKey)
    }

    // MARK: - Properties

    private var ax: WorthContext {
        document.context
    }

    private var ms: ModelSettings {
        document.modelSettings
    }

    // MARK: - Helpers

    private func getColorCode(_ assetKey: AssetKey) -> ColorPair {
        document.assetColorMap[assetKey] ?? (Color.primary, Color.clear)
    }
}
