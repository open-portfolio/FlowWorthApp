//
//  PrimaryReturns.swift
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
import FlowBase
import FlowWorthLib

struct PrimaryReturns: View {
    
    @Binding var document: WorthDocument
    @ObservedObject var mr: MatrixResult
    @ObservedObject var fr: ForecastResult
    var title: String
    
    var body: some View {
        VStack {
            HStack {
                Text(titleWithGrouping)
                    .font(.largeTitle)
                Spacer()
                warningMessage
                HelpButton(appName: "worth", topicName: helpTopicName)
            }
            
            TabView(selection: $document.displaySettings.primaryReturnsTab) {
                ReturnsChart(document: $document, mr: mr)
                    .tabItem { Text("Chart") }
                    .tag(TabsPrimaryReturns.chart)
                
                if let _psum = psum {
                    AssetSummaryTable(document: $document, psum: _psum)
                    .tabItem { Text("Assets") }
                    .tag(TabsPrimaryReturns.assets)
                    
                    AccountSummaryTable(document: $document, psum: _psum)
                    .tabItem { Text("Accounts") }
                    .tag(TabsPrimaryReturns.accounts)
                    
                    StrategySummaryTable(document: $document, psum: _psum)
                    .tabItem { Text("Strategies") }
                    .tag(TabsPrimaryReturns.strategies)
                }
                
                ForecastChart(document: $document, fr: fr)
                    .tabItem { Text("Forecast") }
                    .tag(TabsPrimaryReturns.forecast)
            }
            
            ReturnsFooter(document: $document, mr: mr)
        }
        .padding()
    }
    
    @ViewBuilder
    private var warningMessage: some View {
        if let msg = warningMessageStr {
            Text("(filtered \(msg))")
                .font(.title3)
                .padding(.horizontal, 10)
                .padding(.vertical, 3)
                .foregroundColor(.secondary)
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .fill(document.accent.opacity(0.5)))
        }
    }
    
    // MARK: - Properties
    
    private var ds: DisplaySettings {
        document.displaySettings
    }
    
    private var helpTopicName: String {
        switch document.displaySettings.primaryReturnsTab {
        case .chart:
            return "returnsChart"
        case .assets:
            return "returnsAssets"
        case .accounts:
            return "returnsAccounts"
        case .strategies:
            return "returnsStrategies"
        case .forecast:
            return "returnsForecast"
        }
    }
    
    private var controlTextColor: Color {
        #if os(macOS)
        Color(.controlTextColor)
        #else
        Color.primary
        #endif
    }

    private var isCompact: Bool {
        document.displaySettings.showSecondary
    }

    private var warningMessageStr: String? {
        if partialAssets && partialAccounts {
            return "assets & accounts"
        } else if partialAssets {
            return "assets"
        } else if partialAccounts {
            return "accounts"
        } else {
            return nil
        }
    }
    
    private var partialAssets: Bool {
        ds.excludedAssetMap.values.first(where: { $0 }) != nil
    }
    
    private var partialAccounts: Bool {
        ds.excludedAccountMap.values.first(where: { $0 }) != nil
    }
    
    private var ax: WorthContext {
        document.context
    }
    
    private var psum: PeriodSummary? {
        mr.periodSummary
    }
    
    private var returnsGrouping: ReturnsGrouping {
        document.displaySettings.returnsGrouping
    }
    
    private var returnsColor: ReturnsColor {
        document.displaySettings.returnsColor
    }
    
    private var colors: [ColorPair] {
        mr.getColors(assetMap: ax.assetMap, assetKeyFilter: { _ in true })
    }
    
    private var titleWithGrouping: String {
        let suffix = ds.returnsGrouping.description
        return "\(title) - by \(suffix)"
    }
}
