//
//  BuilderSummaryView.swift
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

struct BuilderSummaryView: View {
    @Binding var document: WorthDocument
    var psum: PeriodSummary?
    var now: Date
    
    var body: some View {
        BaseBuilderView(document: $document, now: now, viewName: "Summary", subTitle: subTitle) {
            if let _psum = psum {
                TabView(selection: $document.displaySettings.builderSummaryTab) {
                    AssetSummaryTable(document: $document, psum: _psum)
                        .tabItem { Text("Assets") }
                        .tag(TabsSummaryBuilder.assets)
                    
                    AccountSummaryTable(document: $document, psum: _psum)
                        .tabItem { Text("Accounts") }
                        .tag(TabsSummaryBuilder.accounts)
                    
                    StrategySummaryTable(document: $document, psum: _psum)
                        .tabItem { Text("Strategies") }
                        .tag(TabsSummaryBuilder.strategies)
                }
            }
        }
    }
    
    // MARK: - Properties
    
    private var subTitle: String {
        "Create a new point-in-time valuation of your portfolio."
    }
    
    private var ps: PendingSnapshot {
        document.pendingSnapshot
    }
}
