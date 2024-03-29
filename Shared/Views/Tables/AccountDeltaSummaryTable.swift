//
//  AccountDeltaSummaryTable.swift
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

struct AccountDeltaSummaryTable: View {
    @Binding var document: WorthDocument
    @State var tableData: [TableRow]

    struct TableRow: Hashable, Identifiable {
        internal init(accountKey: AccountKey, begMV: Double, endMV: Double, deltaMV: Double, deltaPercent: Double? = nil) {
            id = accountKey
            self.accountKey = accountKey
            self.begMV = begMV
            self.endMV = endMV
            self.deltaMV = deltaMV
            self.deltaPercent = deltaPercent
        }

        var id: AccountKey
        var accountKey: AccountKey
        var begMV: Double
        var endMV: Double
        var deltaMV: Double
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
            Sort.columnTitle("Account (number)", ctx, \.accountKey)
                .modifier(HeaderCell())
                .onTapGesture {
                    tablerSort(ctx, &tableData, \.accountKey) { $0.accountKey < $1.accountKey }
                }
            Sort.columnTitle("Begin Market Value", ctx, \.begMV)
                .modifier(HeaderCell())
                .onTapGesture {
                    tablerSort(ctx, &tableData, \.begMV) { $0.begMV < $1.begMV }
                }
            Sort.columnTitle("End Market Value", ctx, \.endMV)
                .modifier(HeaderCell())
                .onTapGesture {
                    tablerSort(ctx, &tableData, \.endMV) { $0.endMV < $1.endMV }
                }
            Sort.columnTitle("\(WorthDocument.deltaCurrencySymbol)", ctx, \.deltaMV)
                .modifier(HeaderCell())
                .onTapGesture {
                    tablerSort(ctx, &tableData, \.deltaMV) { $0.deltaMV < $1.deltaMV }
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
            Text(MAccount.getTitleID(item.accountKey, ax.accountMap, withID: true) ?? "")
                .lineLimit(1)
                .mpadding()
            CurrencyLabel(value: Double(item.begMV), style: .whole)
                .mpadding()
            CurrencyLabel(value: Double(item.endMV), style: .whole)
                .mpadding()
            CurrencyLabel(value: Double(item.deltaMV), style: .whole)
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
