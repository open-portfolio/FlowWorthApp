//
//  AccountDietzSummaryTable.swift
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

struct AccountDietzSummaryTable: View {
    @Binding var document: WorthDocument
    @State var tableData: [TableRow]

    struct TableRow: Hashable, Identifiable {
        var id: AccountKey
        var accountKey: AccountKey
        var gainLoss: Double
        var performance: Double
        var netCashflowTotal: Double
        var adjustedNetCashflow: Double

        internal init(accountKey: AccountKey, gainLoss: Double, performance: Double, netCashflowTotal: Double, adjustedNetCashflow: Double) {
            id = accountKey
            self.accountKey = accountKey
            self.gainLoss = gainLoss
            self.performance = performance
            self.netCashflowTotal = netCashflowTotal
            self.adjustedNetCashflow = adjustedNetCashflow
        }
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
            Sort.columnTitle("Account (number)", ctx, \.accountKey)
                .modifier(HeaderCell())
                .onTapGesture {
                    tablerSort(ctx, &tableData, \.accountKey) { $0.accountKey < $1.accountKey }
                }
            Sort.columnTitle("Gain/Loss", ctx, \.gainLoss)
                .modifier(HeaderCell())
                .onTapGesture {
                    tablerSort(ctx, &tableData, \.gainLoss) { $0.gainLoss < $1.gainLoss }
                }
            Sort.columnTitle("\(WorthDocument.rSymbol) (period)", ctx, \.performance)
                .modifier(HeaderCell())
                .onTapGesture {
                    tablerSort(ctx, &tableData, \.performance) { $0.performance < $1.performance }
                }
            Sort.columnTitle("Net Cash Flow", ctx, \.netCashflowTotal)
                .modifier(HeaderCell())
                .onTapGesture {
                    tablerSort(ctx, &tableData, \.netCashflowTotal) { $0.netCashflowTotal < $1.netCashflowTotal }
                }
            Sort.columnTitle("Adj Net Cash Flow", ctx, \.adjustedNetCashflow)
                .modifier(HeaderCell())
                .onTapGesture {
                    tablerSort(ctx, &tableData, \.adjustedNetCashflow) { $0.adjustedNetCashflow < $1.adjustedNetCashflow }
                }
        }
    }

    private func row(_ item: TableRow) -> some View {
        LazyVGrid(columns: gridItems, alignment: .leading, spacing: flowColumnSpacing) {
            Text(MAccount.getTitleID(item.accountKey, ax.accountMap, withID: true) ?? "")
                .lineLimit(1)
                .mpadding()
            CurrencyLabel(value: Double(item.gainLoss), style: .whole)
                .mpadding()
            PercentLabel(value: Double(item.performance))
                .mpadding()
            CurrencyLabel(value: item.netCashflowTotal, style: .whole)
                .mpadding()
            CurrencyLabel(value: item.adjustedNetCashflow, style: .whole)
                .mpadding()
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
