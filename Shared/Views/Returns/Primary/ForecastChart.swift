//
//  ForecastChart.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

import AllocData
import Regressor
import NiceScale

import FlowUI
import FlowBase
import FlowWorthLib

struct ForecastChart: View {
    
    @Binding var document: WorthDocument
    @ObservedObject var fr: ForecastResult
    
    var body: some View {
        GeometryReader { geo in
            VStack {
                if let scale = vertScale {
                    SnapshotChart(document: $document,
                                  chartBody: chartBody,
                                  horizontalTicks: getHorizontalTicks(width: geo.size.width),
                                  vertScale: scale)
                        .layoutPriority(1)
                }
            }
        }
    }
    
    private func chartBody(_ scale: NiceScale<Double>) -> some View {
        ForecastChartBody(document: $document,
                          mvData: mvData,
                          lrData: lrData,
                          fr: fr)
    }
    
    // MARK: - Properties
    
    // MARK: - Horizontal
        
    private func getHorizontalTicks(width: CGFloat) -> [HorizontalTick] {
        let timestamps = fr.hm.combinedTimestamps
        let labelWidth: CGFloat = isCompact ? 40 : 70
        let minSpace: CGFloat = 25 // allow plenty of space between labels
        return HorizontalTick.getTicks(timestamps: timestamps,
                                       width: width,
                                       labelWidth: labelWidth,
                                       minSpace: minSpace)
    }
    
    // MARK: - Vertical
    
    // vertical range is based on the NET market value bounds
    // expand the range to allow for extra visual space (and trendline)
    private var vertRange: ClosedRange<Double> {
        guard let mvr = fr.marketValueRange,
              let lr = fr.lr
        else { return 0...0 }
        
        let relativeDistances = fr.hm.combinedDistances
        let firstProjectedValue = lr.yRegression(x: (relativeDistances.first ?? 0))
        let lastProjectedValue = lr.yRegression(x: (relativeDistances.last ?? 0))
        
        let factor = 0.05
        let padding = (mvr.upperBound - mvr.lowerBound) * factor
        let min = [firstProjectedValue, lastProjectedValue, mvr.lowerBound].min()! - padding
        let max = [firstProjectedValue, lastProjectedValue, mvr.upperBound].max()! + padding
        return min ... max
    }
    
    private var vertScale: NiceScale<Double>? {
        NiceScale(vertRange)
    }
    
    // MARK: - Market value data points
    
    // plotting MAIN marketValues in range 0...1
    // using resampled data because the line plotter assumes uniform distances between points
    private var mvData: [CGFloat] {
        guard let scale = vertScale else { return [] }
        return fr.mainResampled.map { CGFloat(scale.scaleToUnit($0)) }
    }
    
    // MARK: - Regression
    
    // data to plot the line across the combined (main + extended) chart area
    private var lrData: [CGFloat] {
        guard let scale = vertScale else { return [] }
        return fr.combinedResampled.map { CGFloat(scale.scaleToUnit($0)) }
    }
    
    // MARK: - Helpers
    
    private var isCompact: Bool {
        document.displaySettings.showSecondary
    }
}


