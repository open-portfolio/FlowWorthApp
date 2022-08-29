//
//  ReturnsChartBody.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

import Charts

import AllocData
import NiceScale

import FlowUI
import FlowBase
import FlowWorthLib

struct ReturnsChartBody: View {
    @Binding var document: WorthDocument
    @ObservedObject var mr: MatrixResult
    var timeSeriesIndiceCount: Int
    var vertScale: NiceScale<Double> // from negative to positive
    var showLegend: Bool
 
    enum ChartValueDisplay {
        case positiveValues
        case negativeValues
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            chartBody
            if showLegend && ds.showChartLegend {
                LegendBar(collections: legendItems)
                    //.animation(.easeInOut, value: ds.showChartLegend)  //TODO not working
                    .padding()
            }
        }
    }
    
    @ViewBuilder
    private var chartBody: some View {
        switch ds.returnsExtent {
        case .positiveOnly:
            Chart(data: chartData(chartValueDisplay: .positiveValues))
                .chartStyle(
                    StackedAreaChartStyle(.line, fills: fills)
                )
        case .negativeOnly:
            Chart(data: chartData(chartValueDisplay: .negativeValues))
                .chartStyle(
                    StackedAreaChartStyle(.line, fills: fills, yMirror: true)
                )
        case .all:
            GeometryReader { geo in
                VStack(spacing: 0) {
                    Chart(data: chartData(chartValueDisplay: .positiveValues))
                        .chartStyle(
                            StackedAreaChartStyle(.line, fills: fills)
                        )
                        .frame(height: geo.size.height * (vertScale.positiveExtentUnit ?? 1))
                    Chart(data: chartData(chartValueDisplay: .negativeValues))
                        .chartStyle(
                            StackedAreaChartStyle(.line, fills: fills, yMirror: true)
                        )
                        .frame(height: geo.size.height * (vertScale.negativeExtentUnit ?? 1))
                }
            }
        }
    }
    
    // MARK: - View Helpers
    
    private var fills: [AnyView] {
        switch returnsGrouping {
        case .assets:
            return assetsFill
        case .accounts:
            return accountsFill
        case .strategies:
            return strategiesFill
        }
    }
    
    private var assetsFill: [AnyView] {
        let pairMap = assetPairMap
        return netAssetKeys.reversed().map {
            let pair = pairMap[$0] ?? (.primary, .secondary)
            return gradient(for: pair.1)
        }
    }
    
    private var accountsFill: [AnyView] {
        let pairMap = accountPairMap
        return mr.orderedAccountKeys.reversed().map {
            let pair = pairMap[$0] ?? (.primary, .secondary)
            return gradient(for: pair.1)
        }
    }
    
    private var strategiesFill: [AnyView] {
        let pairMap = strategyPairMap
        return mr.orderedStrategyKeys.reversed().map {
            let pair = pairMap[$0] ?? (.primary, .secondary)
            return gradient(for: pair.1)
        }
    }
    
    private func gradient(for color: Color) -> AnyView {
        let lite = color.saturate(by: 0.25) //.lighten()
        let dark = color.desaturate(by: 0.25) //.darken()
        return AnyView(
            LinearGradient(gradient: .init(colors: [lite, dark]), startPoint: .top, endPoint: .bottom)
        )
    }
    
    // MARK: - Properties and Misc Helpers
    
    private var ax: WorthContext {
        document.context
    }
    
    private var ds: DisplaySettings {
        document.displaySettings
    }
    
    private var legendItems: [LegendBar.LegendItem] {
        switch returnsGrouping {
        case .assets:
            let pairMap = assetPairMap
            return mr.orderedAssetKeys.compactMap {
                let pair = pairMap[$0] ?? (.primary, .secondary)
                guard let asset = ax.assetMap[$0] else { return nil }
                return LegendBar.LegendItem(title: asset.title, id: asset.assetID, fg: pair.0, bg: pair.1)
            }
        case .accounts:
            let pairMap = accountPairMap
            return mr.orderedAccountKeys.compactMap {
                let pair = pairMap[$0] ?? (.primary, .secondary)
                guard let account = ax.accountMap[$0] else { return nil }
                return LegendBar.LegendItem(title: account.title, id: account.accountID, fg: pair.0, bg: pair.1)
            }
        case .strategies:
            let pairMap = strategyPairMap
            return mr.orderedStrategyKeys.compactMap {
                let pair = pairMap[$0] ?? (.primary, .secondary)
                guard let strategy = ax.strategyMap[$0] else { return nil }
                return LegendBar.LegendItem(title: strategy.title, id: strategy.strategyID, fg: pair.0, bg: pair.1)
            }
        }
    }
    
    private var assetPairMap: [AssetKey: ColorPair] {
        let palette = ds.returnsColor == .color
        ? mr.getColors(assetMap: ax.assetMap, assetKeyFilter: assetKeyFilter) //.reversed()
        : monoPalette(count: netAssetKeys.count)
        return netAssetKeys.enumerated().reduce(into: [:]) { map, entry in
            let (n, key) = entry
            map[key] = palette[n]
        }
    }

    private var accountPairMap: [AccountKey: ColorPair] {
        let palette = ds.returnsColor == .color
        ? [Color.blue, Color.purple, Color.red, Color.orange, Color.yellow, Color.green].map { ColorPair(.primary, Color.componentize($0)) }
        : monoPalette(count: mr.orderedAccountKeys.count)
        return mr.orderedAccountKeys.enumerated().reduce(into: [:]) { map, entry in
            let (n, key) = entry
            map[key] = palette[n % palette.count]
        }
    }
    
    private var strategyPairMap: [StrategyKey: ColorPair] {
        let palette = ds.returnsColor == .color
        ? [Color.blue, Color.purple, Color.red, Color.orange, Color.yellow, Color.green].map { ColorPair(.primary, Color.componentize($0)) }
        : monoPalette(count: mr.orderedStrategyKeys.count)
        return mr.orderedStrategyKeys.enumerated().reduce(into: [:]) { map, entry in
            let (n, key) = entry
            map[key] = palette[ n % palette.count ]
        }
    }
    
    private func monoPalette(count: Int) -> [ColorPair] {
        guard count > 0 else { return [] } // avoid crash if no assets
        let color = document.accent
        let lite = color.lighten(by: 0.15)
        let dark = color.darken(by: 0.35)
        return Color.palette(start: lite, end: dark, steps: count).map { ColorPair(.primary, $0) }
    }
    
    private var returnsGrouping: ReturnsGrouping {
        ds.returnsGrouping
    }
    
    private var returnsColor: ReturnsColor {
        ds.returnsColor
    }
    
    private func chartData(chartValueDisplay: ChartValueDisplay) -> [[CGFloat]] {
        switch returnsGrouping {
        case .assets:
            return getSeriesData(MAsset.self,
                                 allocKeys: mr.orderedAssetKeys,
                                 keyFilter: assetKeyFilter,
                                 resampledData: assetResampledData,
                                 chartValueDisplay: chartValueDisplay)
        case .accounts:
            return getSeriesData(MAccount.self,
                                 allocKeys: mr.orderedAccountKeys,
                                 keyFilter: { _ in true },
                                 resampledData: accountResampledData,
                                 chartValueDisplay: chartValueDisplay)
        case .strategies:
            return getSeriesData(MStrategy.self,
                                 allocKeys: mr.orderedStrategyKeys,
                                 keyFilter: { _ in true },
                                 resampledData: strategyResampledData,
                                 chartValueDisplay: chartValueDisplay)
        }
    }
    
    // convert matrix to the idiosyncratic data format required by this chart
    // convert from marketValues in [AssetKey: [Float]] to normalized (0...1) values in [[CGFloat]]
    // and flip horizontally
    private func getSeriesData<T: AllocKeyed>(_: T.Type,
                                              allocKeys: [T.Key],
                                              keyFilter: (T.Key) -> Bool,
                                              resampledData: AllocKeyValuesMap<T>,
                                              chartValueDisplay: ChartValueDisplay) -> [[CGFloat]] {
        
        let _allocKeys = allocKeys.reversed()
        
        return (0..<timeSeriesIndiceCount).reduce(into: []) { array, n in
            let keyedSeries: [CGFloat] = _allocKeys
                .filter(keyFilter)
                .compactMap {
                    guard let resampledValues = resampledData[$0], n < resampledValues.count else { return nil }
                    let rawValue = resampledValues[n]

                    if chartValueDisplay == .positiveValues {
                        if rawValue > 0 {
                            // to 0...1 in the 'nice' range
                            return CGFloat(vertScale.scaleToUnitPositive(rawValue))
                        }
                        return 0
                    } else  {
                        if rawValue < 0 {
                            // to 0...1 in the 'nice' range
                            return CGFloat(vertScale.scaleToUnitNegative(rawValue))
                        }
                        return 0
                    }
                }
            array.append(keyedSeries)
        }
    }
    
    private var assetResampledData: AssetValuesMap {
        MatrixResult.resample(MAsset.self,
                              timeSeriesIndiceCount: timeSeriesIndiceCount,
                              capturedAts: mr.capturedAts,
                              matrixValues: mr.matrixValuesByAsset)
    }
    
    private var accountResampledData: AccountValuesMap {
        MatrixResult.resample(MAccount.self,
                              timeSeriesIndiceCount: timeSeriesIndiceCount,
                              capturedAts: mr.capturedAts,
                              matrixValues: mr.matrixValuesByAccount)
    }
    
    private var strategyResampledData: StrategyValuesMap {
        MatrixResult.resample(MStrategy.self,
                              timeSeriesIndiceCount: timeSeriesIndiceCount,
                              capturedAts: mr.capturedAts,
                              matrixValues: mr.matrixValuesByStrategy)
    }
    
    // MARK: - Helpers
    
    private var netAssetKeys: [AssetKey] {
        mr.orderedAssetKeys.filter(assetKeyFilter)
    }
    
    private func assetKeyFilter(_ assetKey: AssetKey) -> Bool {
        !ds.excludedAssetMap[assetKey, default: false]
    }
}


