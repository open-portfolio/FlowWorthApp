//
//  BirdsEyeSection.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

import AllocData

import FlowUI
import FlowWorthLib
import FlowBase
import NiceScale

struct BirdsEyeSection: View {
    @Binding var document: WorthDocument
    @ObservedObject var mrBirdsEye: MatrixResult

    var body: some View {
        NavigationLink(
            destination: portfolioSummary,
            tag: WorthSidebarMenuIDs.birdsEyeChart.rawValue,
            selection: $document.displaySettings.activeSidebarMenuKey,
            label: {
                if let scale = vertScale {
                    birdsEyeChart(scale)
                }
            }
        )
    }
    
    private func birdsEyeChart(_ scale: NiceScale<Double>) -> some View {
        ReturnsChartBody(document: $document,
                         mr: mrBirdsEye,
                         timeSeriesIndiceCount: 20,
                         vertScale: scale,
                         showLegend: false)
            .aspectRatio(contentMode: .fit)
            .overlay(
                VStack(spacing: 8) {
                    Text(birdsEndMarketValue.toCurrency(style: .compact))
                        .font(.system(.title, design: .monospaced))
                    
                    birdsPerf
                        .font(.system(.title3, design: .monospaced))
                }
                    .lineLimit(1)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.5))
                    .cornerRadius(5)
            )
    }
    
    private var portfolioSummary: some View {
        BaseReturnsSummary(document: $document,
                           title: "Portfolio Returns",
                           mr: mrBirdsEye)
    }

    private var birdsPerf: some View {
        let tuple: (String, String) = {
            switch ds.periodSummarySelection {
            case .deltaMarketValue:
                if let d = mrBirdsEye.periodSummary?.singlePeriodReturn {
                    return (d.toPercent1(leadingPlus: true), WorthDocument.deltaSymbol)
                } else {
                    let mv = mrBirdsEye.periodSummary?.deltaMarketValue ?? 0
                    return (mv.toCurrency(style: .compact, leadingPlus: true), WorthDocument.deltaSymbol)
                }
            case .deltaTotalBasis:
                if let d = mrBirdsEye.periodSummary?.singlePeriodBasisReturn {
                    return (d.toPercent1(leadingPlus: true), WorthDocument.deltaSymbol)
                } else {
                    let tb = mrBirdsEye.periodSummary?.deltaTotalBasis ?? 0
                    return (tb.toCurrency(style: .compact, leadingPlus: true), WorthDocument.deltaSymbol)
                }
            case .modifiedDietz:
                if let r = mrBirdsEye.periodSummary?.dietz!.performance {
                    return (r.toPercent1(leadingPlus: true), WorthDocument.rSymbol)
                } else {
                    return ("n/a", WorthDocument.rSymbol)
                }
            }
        }()
     
        return Text("\(tuple.0) \(tuple.1)")
    }

    // MARK: - Properties
    
    private var ds: DisplaySettings {
        document.displaySettings
    }
    
    private var birdsEndMarketValue: Double {
        mrBirdsEye.periodSummary?.endMarketValue ?? 0
    }
    
    private var vertScale: NiceScale<Double>? {
        if ds.returnsGrouping == .accounts {
            return mrBirdsEye.getAccountNiceScale(returnsExtent: ds.returnsExtent)
        } else {
            return mrBirdsEye.getAssetNiceScale(returnsExtent: ds.returnsExtent)
        }
    }
}

