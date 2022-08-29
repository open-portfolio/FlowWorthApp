//
//  DietzSnapshotTable.swift
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
import ModifiedDietz

struct DietzSnapshotTable: View {
    @Binding var document: WorthDocument
    @ObservedObject var mr: MatrixResult
    
    private let gridItems: [GridItem] = [
        GridItem(.flexible(minimum: 120), spacing: columnSpacing),
        GridItem(.flexible(minimum: 110), spacing: columnSpacing),
        GridItem(.flexible(minimum: 110), spacing: columnSpacing),
        GridItem(.flexible(minimum: 80), spacing: columnSpacing),
        GridItem(.flexible(minimum: 80), spacing: columnSpacing),
    ]
    
    @State var hovered: DietzSnapshotInfo.ID? = nil
    
    var body: some View {
        TablerStack(.init(rowSpacing: flowRowSpacing, onHover: hoverAction),
                    header: header,
                    row: row,
                    rowBackground: rowBackground,
                    results: hasCashflow ? dietzItems : [])
            .sideways(minWidth: 500, showIndicators: true)
        HStack { Spacer(); Text("*period to date").font(.footnote) }
    }
    
    typealias Context = TablerContext<DietzSnapshotInfo>
    
    private func header(_ ctx: Binding<Context>) -> some View {
        LazyVGrid(columns: gridItems, alignment: .leading, spacing: flowColumnSpacing) {
            Text("Captured At")
                .modifier(HeaderCell())
            Text("Market Value")
                .modifier(HeaderCell())
            Text("Net Cash Flow")
                .modifier(HeaderCell())
            Text("\(WorthDocument.rSymbol)")
                .modifier(HeaderCell())
            Text("\(WorthDocument.rSymbol)*")
                .modifier(HeaderCell())
        }
    }
    
    private func row(_ item: DietzSnapshotInfo) -> some View {
        LazyVGrid(columns: gridItems, alignment: .leading, spacing: flowColumnSpacing) {
            DateLabel(item.capturedAt, withTime: false)
                .mpadding()
            CurrencyLabel(value: item.marketValue, style: .compact)
                .mpadding()
            CurrencyLabel(value: item.netCashflow, style: .compact)
                .mpadding()
            PercentLabel(value: item.r, leadingPlus: true)
                .mpadding()
            PercentLabel(value: item.rToDate, leadingPlus: true)
                .mpadding()
        }
    }
    
    public func rowBackground(_ item: DietzSnapshotInfo) -> some View {
        RoundedRectangle(cornerRadius: 5)
            .fill(Color.accentColor.opacity(hovered == item.id ? 0.2 : 0.0))
    }
    
    // MARK: - Properties
    
    private var dietzItems: [DietzSnapshotInfo] {
        DietzSnapshotInfo.getDietzSnapshots(mr)
    }
    
    private var hasCashflow: Bool {
        mr.hasCashflow
    }
    
    // MARK: - Actions
    
    private func hoverAction(itemID: DietzSnapshotInfo.ID, isHovered: Bool) {
        if isHovered { hovered = itemID } else { hovered = nil }
    }
}

