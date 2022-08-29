//
//  ForecastChartBody.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//


import SwiftUI
import Accelerate

import Charts

import AllocData

import FlowUI
import FlowBase
import FlowWorthLib

struct ForecastChartBody: View {
    @Binding var document: WorthDocument
    var mvData: [CGFloat]
    var lrData: [CGFloat]
    var fr: ForecastResult
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                
                HStack(spacing: 0) {
                    Rectangle()
                        .frame(width: geo.size.width * useHorizontalFraction)
                        .foregroundColor(.clear)
                        .background(mainGradient.opacity(0.3))
                    Rectangle()
                        .frame(width: geo.size.width * CGFloat(1 - useHorizontalFraction))
                        .foregroundColor(.clear)
                        .background(extendedGradient.opacity(0.3))
                }
                
                Chart(data: mvData)
                    .chartStyle(
                        LineChartStyle(.line, lineColor: .blue, lineWidth: 2) //quadCurve
                    )
                    .frame(width: geo.size.width * useHorizontalFraction)
                
                Chart(data: lrData)
                    .chartStyle(
                        LineChartStyle(.line, lineColor: .green, lineWidth: 2)
                    )
            }
        }
    }
    
    private var fm: ForecastMetrics {
        fr.hm
    }
    
    private var useHorizontalFraction: CGFloat {
        fm.mainFraction ?? 1.0
    }
    
    private var mainGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [.green, .blue]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var extendedGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [.yellow, .blue]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
