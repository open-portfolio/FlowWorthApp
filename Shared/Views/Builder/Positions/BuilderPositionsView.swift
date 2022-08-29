//
//  BuilderPositionsView.swift
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

struct BuilderPositionsView: View {
    @Binding var document: WorthDocument
    var now: Date

    var body: some View {
        BaseBuilderView(document: $document, now: now, viewName: "Positions", subTitle: subTitle) {
            TabView(selection: $document.displaySettings.builderPositionsTab) {
                BuilderHoldingsTable(document: $document) // NOTE: ps.holdings will be filtered by excludedHoldingMap
                    .tabItem { Text("\(hasImportedHoldings ? bullet : "")Imported Holdings") }
                    .tag(TabsPositionsBuilder.holdings)
                
                BuilderPositionsTable(document: $document, positions: document.pendingSnapshot.nuPositions)
                    .tabItem { Text("\(hasPendingPositions ? bullet : "")New Positions") }
                    .tag(TabsPositionsBuilder.positions)
                
                BuilderPositionsTable(document: $document, positions: document.pendingSnapshot.previousPositions)
                    .tabItem { Text("\(hasPreviousPositions ? bullet : "")Most Recent Snapshot") }
                    .tag(TabsPositionsBuilder.previousPositions)
            }
        }
    }
    
    // MARK: - Properties
    
    private var bullet: String {
        "•"
    }
    
    private var hasImportedHoldings: Bool {
        document.model.holdings.count > 0
    }
    
    private var hasPendingPositions: Bool {
        ps.nuPositions.count > 0
    }
    
    private var hasPreviousPositions: Bool {
        ps.previousPositions.count > 0
    }
    
    private var subTitle: String {
        "Positions to be included in the new Snapshot valuation."
    }
    
    private var ps: PendingSnapshot {
        document.pendingSnapshot
    }
        
    private var ax: WorthContext {
        document.context
    }
}
