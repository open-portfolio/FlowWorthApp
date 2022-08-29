//
//  ReturnsChart.swift
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

struct ReturnsChart: View {
    @Binding var document: WorthDocument
    @ObservedObject var mr: MatrixResult
    
    let resampleCount = 160
    
    var body: some View {
        if let scale = vertScale {
            GeometryReader { geo in
                SnapshotChart(document: $document,
                              chartBody: chartBody,
                              horizontalTicks: getHorizontalTicks(width: geo.size.width),
                              vertScale: scale)
            }
        } else {
            Text("No data")
                .font(.title)
        }
    }
    
    private func chartBody(_ scale: NiceScale<Double>) -> some View {
        ReturnsChartBody(document: $document,
                         mr: mr,
                         timeSeriesIndiceCount: resampleCount,
                         vertScale: scale,
                         showLegend: true)
    }
    
    // MARK: - Properties
    
    private var ds: DisplaySettings {
        document.displaySettings
    }

    private var isCompact: Bool {
        document.displaySettings.showSecondary
    }
    
    /// return snapshot capturedAt, as ratio of range of snapshots
    private func getHorizontalTicks(width: CGFloat) -> [HorizontalTick] {
        let labelWidth: CGFloat = isCompact ? 40 : 70
        let minSpace: CGFloat = 25 // allow plenty of space between labels
        let ticks = HorizontalTick.getTicks(timestamps: mr.capturedAts,
                                            width: width,
                                            labelWidth: labelWidth,
                                            minSpace: minSpace)
        //print("\(ticks)")
        return ticks
    }
    
    private var vertScale: NiceScale<Double>? {
        switch ds.returnsGrouping {
        case .assets:
            return mr.getAssetNiceScale(returnsExtent: ds.returnsExtent)
        case .accounts:
            return mr.getAccountNiceScale(returnsExtent: ds.returnsExtent)
        case .strategies:
            return mr.getStrategyNiceScale(returnsExtent: ds.returnsExtent)
        }
    }
}

