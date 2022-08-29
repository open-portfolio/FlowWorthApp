//
//  SnapshotSummary.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

import AllocData

import FlowBase
import FlowWorthLib
import FlowUI

enum TabsSnapshotSummary: Int {
    case positions
    case cashflow
    case assets
    case accounts
    case strategies
    
    static let defaultTab = TabsSnapshotSummary.positions
    static let storageKey = "SnapshotSummaryTab"
}

struct SnapshotSummary: View {
    @AppStorage(TabsSnapshotSummary.storageKey) var tab: TabsSnapshotSummary = .defaultTab
    
    @Binding var document: WorthDocument
    var now: Date
    @Binding var snapshotKey: SnapshotKey

    let title = "Snapshot (valuations)"
    let subtitle = "Review point-in-time valuations of your portfolio."

    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text(title)
                        .font(.title)
                    Text(subtitle)
                        .font(.subheadline)
                }
                
                Spacer()
                
                SummarySnapshotPicker(document: $document, snapshotKey: $snapshotKey)
                    .frame(maxWidth: 400)
            }
            .padding()
            
            TabView(selection: $tab) {
                BuilderPositionsTable(document: $document, positions: endPositions)
                    .tabItem { Text("Positions") }
                    .tag(TabsSnapshotSummary.positions)
                BuilderCashflowTable(document: $document, cashflows: cashflows) //, reconExcludeMode: false, showReconColumn: true)
                    .tabItem { Text("Cash Flow") }
                    .tag(TabsSnapshotSummary.cashflow)
                if let _psum = psum {
                    AssetSummaryTable(document: $document, psum: _psum)
                    .tabItem { Text("Assets") }
                    .tag(TabsSnapshotSummary.assets)
                    
                    AccountSummaryTable(document: $document, psum: _psum)
                    .tabItem { Text("Accounts") }
                    .tag(TabsSnapshotSummary.accounts)
                    
                    StrategySummaryTable(document: $document, psum: _psum)
                    .tabItem { Text("Strategies") }
                    .tag(TabsSnapshotSummary.strategies)
                }
            }

            Spacer()
            
            SummaryFooter(document: $document, positions: endPositions, cashflows: cashflows)
                .frame(maxHeight: 50)
                .padding()
        }
        .padding()
        .toolbar {
            ToolbarItemGroup(placement: .principal) {
                PeriodSummarySelectionPicker(document: $document)
            }
        }
        .onAppear {
            if !snapshotKey.isValid,
               let latestKey = ax.lastSnapshotKey {
                snapshotKey = latestKey
            }
        }
    }
    
    // MARK: - Properties
    
    private var ax: WorthContext {
        document.context
    }

    private var prevSnapshotKey: SnapshotKey? {
        ax.prevSnapshotKeyMap[snapshotKey]
    }
    
    private var begPositions: [MValuationPosition] {
        guard let _prevSnapshotKey = prevSnapshotKey else { return [] }
        return ax.snapshotPositionsMap[_prevSnapshotKey] ?? []
    }

    private var endPositions: [MValuationPosition] {
        ax.snapshotPositionsMap[snapshotKey] ?? []
    }
    
    private var cashflows: [MValuationCashflow] {
        ax.snapshotCashflowsMap[snapshotKey] ?? []
    }
    
    private var period: DateInterval? {
        ax.snapshotDateIntervalMap[snapshotKey]
    }
    
    private var psum: PeriodSummary? {
        guard let _period = period else { return nil }
        return PeriodSummary(period: _period,
                             begPositions: begPositions,
                             endPositions: endPositions,
                             cashflows: cashflows,
                             accountMap: ax.accountMap)
    }
}
