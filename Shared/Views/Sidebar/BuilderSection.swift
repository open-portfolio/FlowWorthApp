//
//  BuilderSection.swift
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

struct BuilderSection: View {
    @Binding var document: WorthDocument
    var now: Date
    
    var body: some View {
        
        NavigationLink(destination: BuilderSummaryView(document: $document, psum: psum, now: now),
                       tag:  WorthSidebarMenuIDs.builderSummary.rawValue,
                       selection: $document.displaySettings.activeSidebarMenuKey,
                       label: {
            SidebarHeaderLabel(title: "Snapshot Builder", letter: "B", fill: document.accentFill)
        })
        
        Group {

            NavigationLink(
                destination: BuilderPositionsView(document: $document, now: now),
                tag:  WorthSidebarMenuIDs.builderPositions.rawValue,
                selection: $document.displaySettings.activeSidebarMenuKey,
                label: {
                    SidebarNumberedLabel(ps.nuPositions.count, fill: document.accentFill) { Text("Positions") }
                }
            )
            
            NavigationLink(
                destination: BuilderCashflowView(document: $document, now: now),
                tag:  WorthSidebarMenuIDs.builderCashflow.rawValue,
                selection: $document.displaySettings.activeSidebarMenuKey,
                label: {
                    SidebarNumberedLabel(ps.nuCashflows.count, fill: document.accentFill) { Text("Cash Flow") }
                }
            )            
        }
        .listRowBackground(mainGradient)
    }
    
    private var mainGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [.clear , (hasPending ? document.accent : .clear)]),
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    // MARK: - Properties
    
    private var ps: PendingSnapshot {
        document.pendingSnapshot
    }
    
    private var psum: PeriodSummary? {
        ps.periodSummary
    }
    
    private var hasPending: Bool {
        ps.nuPositions.count > 0 || ps.nuCashflows.count > 0
    }
}
