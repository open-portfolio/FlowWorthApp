//
//  SnapshotsSection.swift
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

struct SnapshotsSection: View {
    @Binding var document: WorthDocument
    var now: Date
    
    var body: some View {
        SidebarHeaderLabel(title: "Valuation Snapshots", letter: "V", fill: document.accentFill)
            .contentShape(Rectangle()) // to ensure taps work in empty space
            .onTapGesture {
                document.displaySettings.activeSidebarMenuKey = WorthSidebarMenuIDs.snapshotSummary.rawValue
            }
        
        NavigationLink(
            destination: SnapshotSummary(document: $document,
                                         now: now,
                                         snapshotKey: $document.displaySettings.snapshotSummaryKey),
            tag:  WorthSidebarMenuIDs.snapshotSummary.rawValue,
            selection: $document.displaySettings.activeSidebarMenuKey,
            label: {
                SidebarNumberedLabel(document.model.valuationSnapshots.count, fill: document.accentFill) { Text("Snapshots") }
            }
        )
    }
}
