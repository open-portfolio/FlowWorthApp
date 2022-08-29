//
//  SnapshotChart.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

import AllocData
import NiceScale

import FlowUI
import FlowBase
import FlowWorthLib


private let fullDF: DateFormatter = {
    let df = DateFormatter()
    df.dateStyle = .short
    df.timeStyle = .none
    return df
}()

struct SnapshotChart<ChartBody: View>: View {
    @Binding var document: WorthDocument
    let chartBody: (NiceScale<Double>) -> ChartBody
    let horizontalTicks: [HorizontalTick]
    let vertScale: NiceScale<Double>
    
    var body: some View {
        HStack {
            VStack(spacing: 0) {
                leadingAxisLabels
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(height: 20)
            }
            .frame(width: leadingAxisWidth)
            
            VStack(spacing: 0) {
                chartGridBody
                bottomAxisLabels
                    .frame(height: 20)
            }
        }
        .padding(.vertical)
        .padding(.horizontal, 30)
    }
    
    private var chartGridBody: some View {
        GeometryReader { geo in
            ZStack(alignment: Alignment(horizontal: .leading, vertical: .top)) {
                if let scale = vertScale {
                    chartBody(scale)
                }
                Group {
                    ForEach(horizontalTicks, id: \.self) { tick in
                        Rectangle()
                            .frame(width: 1, height: geo.size.height, alignment: .leading)
                            .offset(x: geo.size.width * tick.offset, y: 0)
                    }
                    ForEach(0..<vertScale.ticks, id: \.self) { n in
                        Rectangle()
                            .frame(width: geo.size.width, height: 1, alignment: .leading)
                            .offset(x: 0, y: geo.size.height - (CGFloat(n) * intervalHeight(geo: geo)))
                    }
                }
                .background(Color.gray).opacity(0.2)
            }
        }
    }
    
    // MARK: - Axis Labels
    
    private var leadingAxisMargin: CGFloat {
        isCompact ? 10 : 20
    }
    private var leadingAxisWidth: CGFloat {
        isCompact ? 40 : 75
    }
    
    private var leadingAxisLabels: some View {
        VStack {
            GeometryReader { geo in
                ZStack(alignment: Alignment(horizontal: .trailing, vertical: .top)) {
                    ForEach(0..<vertScale.ticks, id: \.self) { n in
                        getLeadingAxisLabel(geo, n)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func getLeadingAxisLabel(_ geo: GeometryProxy, _ n: Int) -> some View {
        let value = vertScale.range.lowerBound + (Double(n) * vertScale.tickInterval)
        let style: CurrencyStyle = isCompact ? .compact : .whole
        return CurrencyLabel(value: value, style: style)
            .font(.caption2)
            .position(x: leadingAxisMargin, y: geo.size.height - (CGFloat(n) * intervalHeight(geo: geo))) // TODO HARDCODED
    }
    
    private var bottomAxisLabels: some View {
        VStack {
            GeometryReader { geo in
                ZStack(alignment: Alignment(horizontal: .leading, vertical: .center)) {
                    ForEach(horizontalTicks, id: \.self) { tick in
                        if tick.showLabel {
                            Text(getFormattedDate(tick.timestamp))
                                .position(x: geo.size.width * tick.offset, y: 15) // TODO HARDCODED
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Properties
    
    private var ax: WorthContext {
        document.context
    }
    
    private var isCompact: Bool {
        document.displaySettings.showSecondary
    }
    
    // MARK: - Helpers
    
    private func getFormattedDate(_ date: Date) -> String {
        fullDF.string(from: date)
    }
    
    private func intervalHeight(geo: GeometryProxy) -> CGFloat {
        geo.size.height / CGFloat(vertScale.ticks - 1)
    }
}

