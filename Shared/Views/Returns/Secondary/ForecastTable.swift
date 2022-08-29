//
//  ForecastTable.swift
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

struct ForecastTable: View {

    @Binding var document: WorthDocument
    @ObservedObject var fr: ForecastResult
    
    let milestoneCount = 30
    
    private let gridItems: [GridItem] = [
        GridItem(.flexible(minimum: 120), spacing: columnSpacing),
        GridItem(.flexible(minimum: 100), spacing: columnSpacing),
        GridItem(.flexible(minimum: 100), spacing: columnSpacing, alignment: .center),
    ]
    
    @State var hovered: FutureValueInfo.ID? = nil

    var body: some View {
        TablerStack(.init(rowSpacing: flowRowSpacing, onHover: hoverAction),
            header: header,
            row: row,
            rowBackground: rowBackground,
            results: futureValues.sorted())
    }
    
    typealias Context = TablerContext<FutureValueInfo>

    private func header(_ ctx: Binding<Context>) -> some View {
        LazyVGrid(columns: gridItems, alignment: .leading, spacing: flowColumnSpacing) {
            Text("Date")
                .modifier(HeaderCell())
            Text("Market Value")
                .modifier(HeaderCell())
            Text("From Now")
                .modifier(HeaderCell())
       }
    }
    
    private func row(_ item: FutureValueInfo) -> some View {
        LazyVGrid(columns: gridItems, alignment: .leading, spacing: flowColumnSpacing) {
            DateLabel(item.estimatedDate, withTime: false)
                .mpadding()
            CurrencyLabel(value: item.futureValue, style: .whole)
                .mpadding()
            RelativeDateLabel(timeInterval: item.estimatedDate.timeIntervalSince(Date()))
                .mpadding()
        }
    }
    
    public func rowBackground(_ item: FutureValueInfo) -> some View {
        RoundedRectangle(cornerRadius: 5)
            .fill(Color.accentColor.opacity(hovered == item.id ? 0.2 : 0.0))
    }

    // MARK: - Properties
    
    private var begInterval: TimeInterval? {
        fr.hm.begInterval
    }
    
    private var milestoneValues: [Double] {
        guard let lr = fr.lr,
              let ns = FutureValueInfo.getNiceScale(lr: lr, multiplier: 2.5),
              let first = ns.tickValues.first
        else { return [] }
        let last = first + (Double(milestoneCount) * ns.tickInterval)
        return Array(stride(from: first, through: last, by: ns.tickInterval))
    }
    
    private var futureValues: [FutureValueInfo] {
        guard let lr = fr.lr,
              let _begInterval = begInterval
        else { return [] }
        return FutureValueInfo.getFutureValues(milestoneValues, begInterval: _begInterval, lr: lr)
    }
    
    // MARK: - Actions
    
    private func hoverAction(itemID: FutureValueInfo.ID, isHovered: Bool) {
        if isHovered { hovered = itemID } else { hovered = nil }
    }
}

