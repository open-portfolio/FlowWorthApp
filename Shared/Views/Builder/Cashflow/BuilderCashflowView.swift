//
//  BuilderCashflowView.swift
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

struct BuilderCashflowView: View {
    @Binding var document: WorthDocument
    var now: Date

    var body: some View {
        BaseBuilderView(document: $document, now: now, viewName: "Cash Flow", subTitle: subTitle) {
            TabView(selection: $document.displaySettings.builderCashflowTab) {
                BuilderTxnTable(document: $document) // NOTE: ps.history will be filtered by excludedTxnMap
                    .tabItem { Text("\(hasImportedTransactions ? bullet : "")Imported Transactions") }
                    .tag(TabsCashflowBuilder.transactions)
                
                BuilderCashflowTable(document: $document, cashflows: document.pendingSnapshot.nuCashflows) //, reconExcludeMode: false, showReconColumn: false)
                    .tabItem { Text("\(hasNuCashflows ? bullet : "")New Cash Flow") }
                    .tag(TabsCashflowBuilder.nuCashflow)
                
                BuilderCashflowTable(document: $document, cashflows: document.pendingSnapshot.previousCashflows) //, reconExcludeMode: false, showReconColumn: false)
                    .tabItem { Text("\(hasPrevCashflows ? bullet : "")Most Recent Snapshot") }
                    .tag(TabsCashflowBuilder.prevCashflow)
            }
        }
    }
    
    // MARK: - Properties
    
    private var bullet: String {
        "•"
    }
    
    private var hasImportedTransactions: Bool {
        document.model.transactions.count > 0
    }
    
    private var hasNuCashflows: Bool {
        ps.nuCashflows.count > 0
    }
    
    private var hasPrevCashflows: Bool {
        ps.previousCashflows.count > 0
    }
    
    private var subTitle: String {
        "Cash flows to be included in the new Snapshot valuation."
    }
    
    private var ps: PendingSnapshot {
        document.pendingSnapshot
    }
        
    private var ax: WorthContext {
        document.context
    }
}
