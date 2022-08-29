//
//  BuilderHoldingsTable.swift
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

extension MHolding {
    var presentValuePlaceHolder: Double { 0 }
}

struct BuilderHoldingsTable: View {
    @Binding var document: WorthDocument
    
    // MARK: - Locals
    
    private let gridItems: [GridItem] = [
        GridItem(.flexible(minimum: 220), spacing: columnSpacing),
        GridItem(.flexible(minimum: 180), spacing: columnSpacing),
        GridItem(.flexible(minimum: 30), spacing: columnSpacing),
        GridItem(.flexible(minimum: 65), spacing: columnSpacing),
        GridItem(.flexible(minimum: 65), spacing: columnSpacing),
        GridItem(.flexible(minimum: 65), spacing: columnSpacing),
        GridItem(.flexible(minimum: 65), spacing: columnSpacing),
    ]

    @State var hovered: DietzSnapshotInfo.ID? = nil
    
    var body: some View {
        TablerStack(.init(rowSpacing: flowRowSpacing),
                    header: header,
                    row: row,
                    rowBackground: rowBackground,
                    results: document.model.holdings)
            .sideways(minWidth: 1050, showIndicators: true)
    }

    typealias Context = TablerContext<MHolding>
    typealias Sort = TablerSort<MHolding>
    
    private func header(_ ctx: Binding<Context>) -> some View {
        LazyVGrid(columns: gridItems, alignment: .leading, spacing: flowColumnSpacing) {
            Sort.columnTitle("Account (Number)", ctx, \.accountID)
                .modifier(HeaderCell())
                .onTapGesture {
                    tablerSort(ctx, &document.model.holdings, \.accountID) { $0.accountKey < $1.accountKey }
                }
            Sort.columnTitle("Security (Asset)", ctx, \.securityID)
                .modifier(HeaderCell())
                .onTapGesture {
                    tablerSort(ctx, &document.model.holdings, \.securityID) { $0.securityKey < $1.securityKey }
                }
            Sort.columnTitle("Lot", ctx, \.lotID)
                .modifier(HeaderCell())
                .onTapGesture {
                    tablerSort(ctx, &document.model.holdings, \.lotID) { $0.lotID < $1.lotID }
                }
            Sort.columnTitle("Share Count", ctx, \.shareCount)
                .modifier(HeaderCell())
                .onTapGesture {
                    tablerSort(ctx, &document.model.holdings, \.shareCount) { ($0.shareCount ?? 0) < ($1.shareCount ?? 0) }
                }
            Sort.columnTitle("Share Basis", ctx, \.shareBasis)
                .modifier(HeaderCell())
                .onTapGesture {
                    tablerSort(ctx, &document.model.holdings, \.shareBasis) { ($0.shareBasis ?? 0) < ($1.shareBasis ?? 0) }
                }
            Sort.columnTitle("Total Basis", ctx, \.costBasis)
                .modifier(HeaderCell())
                .onTapGesture {
                    tablerSort(ctx, &document.model.holdings, \.costBasis) { ($0.costBasis ?? 0) < ($1.costBasis ?? 0) }
                }
            Sort.columnTitle("Market Value", ctx, \.presentValuePlaceHolder)
                .modifier(HeaderCell())
                .onTapGesture {
                    tablerSort(ctx, &document.model.holdings, \.presentValuePlaceHolder) { ($0.getPresentValue(ax.securityMap) ?? 0) < ($1.getPresentValue(ax.securityMap) ?? 0) }
                }
        }
    }

    private func row(_ item: MHolding) -> some View {
        LazyVGrid(columns: gridItems, alignment: .leading, spacing: flowColumnSpacing) {
            Text(MAccount.getTitleID(item.accountKey, ax.accountMap, withID: true) ?? "")
                .lineLimit(1)
                .mpadding()
            Text(MSecurity.getTitleID(item.securityKey, ax.securityMap, ax.assetMap, withAssetID: true) ?? "")
                .lineLimit(1)
                .mpadding()
            Text(item.lotID)
                .mpadding()
            SharesLabel(value: item.shareCount, style: .default_)
                .mpadding()
            CurrencyLabel(value: item.shareBasis ?? 0, style: .full)
                .mpadding()
            CurrencyLabel(value: item.costBasis ?? 0, style: .whole)
                .mpadding()
            CurrencyLabel(value: item.getPresentValue(ax.securityMap) ?? 0, style: .whole)
                .mpadding()
        }
        .foregroundColor(getColorCode(getAssetKey(item)).0)
    }
    
    private func rowBackground(_ item: MHolding) -> some View {
        document.getBackgroundFill(getAssetKey(item))
    }


    // MARK: - Properties
    
    private var ax: WorthContext {
        document.context
    }
    
    private func getAssetKey(_ item: MHolding) -> AssetKey {
        ax.securityMap[item.securityKey]?.assetKey ?? MAsset.emptyKey
    }

    // MARK: - Actions
    
    // MARK: - Helpers

    private func getColorCode(_ assetKey: AssetKey) -> ColorPair {
        document.assetColorMap[assetKey] ?? (Color.primary, Color.clear)
    }
}
