//
//  BuilderPositionSummaryTable.swift
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

public struct BuilderPositionsTable: View {
    @Binding var document: WorthDocument
    var positions: [MValuationPosition]
    
    private let gridItems: [GridItem] = [
        GridItem(.flexible(minimum: 100), spacing: columnSpacing),
        GridItem(.flexible(minimum: 100), spacing: columnSpacing),
        GridItem(.flexible(minimum: 70), spacing: columnSpacing),
        GridItem(.flexible(minimum: 70), spacing: columnSpacing),
    ]
    
    public var body: some View {
        TablerStack(.init(rowSpacing: flowRowSpacing),
                    header: header,
                    row: row,
                    rowBackground: rowBackground,
                    results: positions)
            .sideways(minWidth: 500, showIndicators: true)
    }
    
    typealias Context = TablerContext<MValuationPosition>
    typealias Sort = TablerSort<MValuationPosition>
    
    private func header(_ ctx: Binding<Context>) -> some View {
        LazyVGrid(columns: gridItems, alignment: .leading, spacing: flowColumnSpacing) {
            Sort.columnTitle("Account (Number)", ctx, \.accountID)
                .modifier(HeaderCell())
            Sort.columnTitle("Asset Class", ctx, \.assetID)
                .modifier(HeaderCell())
            Sort.columnTitle("Total Basis", ctx, \.totalBasis)
                .modifier(HeaderCell())
            Sort.columnTitle("Market Value", ctx, \.marketValue)
                .modifier(HeaderCell())
        }
    }
    
    private func row(_ item: MValuationPosition) -> some View {
        LazyVGrid(columns: gridItems, alignment: .leading, spacing: flowColumnSpacing) {
            
            Text(MAccount.getTitleID(item.accountKey, ax.accountMap, withID: true) ?? "")
                .lineLimit(1)
                .mpadding()
            Text(MAsset.getTitleID(item.assetKey, ax.assetMap, withID: true) ?? "")
                .lineLimit(1)
                .mpadding()
            CurrencyLabel(value: item.totalBasis, style: .whole)
                .mpadding()
            CurrencyLabel(value: item.marketValue, style: .whole)
                .mpadding()
        }
        .foregroundColor(getColorCode(item.assetKey).0)
    }
    
    private func rowBackground(_ item: MValuationPosition) -> some View {
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
