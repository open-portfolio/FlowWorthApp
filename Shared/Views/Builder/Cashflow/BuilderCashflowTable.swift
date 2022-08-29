//
//  CashflowSummaryTable.swift
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

struct BuilderCashflowTable: View {
    @Binding var document: WorthDocument
    var cashflows: [MValuationCashflow]
    
    private static let dfShort: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .short
        df.timeStyle = .short
        return df
    }()
    
    private let gridItems: [GridItem] = [
        GridItem(.flexible(minimum: 100), spacing: columnSpacing),
        GridItem(.flexible(minimum: 140), spacing: columnSpacing),
        GridItem(.flexible(minimum: 100), spacing: columnSpacing),
        GridItem(.flexible(minimum: 70), spacing: columnSpacing),
    ]
    
    @State var hovered: DietzSnapshotInfo.ID? = nil
    
    var body: some View {
        TablerStack(.init(rowSpacing: flowRowSpacing),
                    header: header,
                    row: row,
                    rowBackground: rowBackground,
                    results: cashflows)
            .sideways(minWidth: 500, showIndicators: true)
    }
    
    typealias Context = TablerContext<MValuationCashflow>
    
    private func header(_ ctx: Binding<Context>) -> some View {
        LazyVGrid(columns: gridItems, alignment: .leading, spacing: flowColumnSpacing) {
        Text("Transacted At")
                .modifier(HeaderCell())
        Text("Account (Number)")
                .modifier(HeaderCell())
        Text("Asset Class")
                .modifier(HeaderCell())
        Text("Amount")
                .modifier(HeaderCell())
        }
    }
    
    private func row(_ item: MValuationCashflow) -> some View {
        LazyVGrid(columns: gridItems, alignment: .leading, spacing: flowColumnSpacing) {
                
            Text(BuilderCashflowTable.dfShort.string(from: item.transactedAt))
                .lineLimit(1)
                .mpadding()
            Text(MAccount.getTitleID(item.accountKey, ax.accountMap, withID: true) ?? "")
                .lineLimit(1)
                .mpadding()
            Text(MAsset.getTitleID(item.assetKey, ax.assetMap, withID: true) ?? "")
                .lineLimit(1)
                .mpadding()
            CurrencyLabel(value: item.amount, style: .whole)
                .mpadding()
        }
        .foregroundColor(getColorCode(item.assetKey).0)
    }
    
    private func rowBackground(_ item: MValuationCashflow) -> some View {
        document.getBackgroundFill(item.assetKey)
    }

    // MARK: - Helpers
    
    private var ax: WorthContext {
        document.context
    }

    private func getColorCode(_ assetKey: AssetKey) -> ColorPair {
        document.assetColorMap[assetKey] ?? (Color.primary, Color.clear)
    }
}
