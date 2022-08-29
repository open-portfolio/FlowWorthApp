//
//  SummarySnapshotPicker.swift
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

struct SummarySnapshotPicker: View {
    @Binding var document: WorthDocument
    @Binding var snapshotKey: SnapshotKey
    
    var body: some View {
        HStack {
            SnapshotNavPicker(model: document.model,
                              ax: document.context,
                              snapshotKey: $snapshotKey,
                              range: startRange)
            
            Button(action: { document.displaySettings.snapshotSummaryKey = ax.firstSnapshotKey ?? MValuationSnapshot.Key.empty }, label: {
                Text("Earliest")
            })
            .buttonStyle(LinkButtonStyle())
            .disabled(ax.firstSnapshotCapturedAt == nil)
            
            Button(action: { document.displaySettings.snapshotSummaryKey = ax.lastSnapshotKey ?? MValuationSnapshot.Key.empty }, label: {
                Text("Latest")
            })
            .buttonStyle(LinkButtonStyle())
            .disabled(ax.lastSnapshotCapturedAt == nil)
        }
    }
    
    // MARK: - Properties/Helpers
    
    private var ax: WorthContext {
        document.context
    }

    private var startRange: DateInterval {
        DateInterval(start: earliestCapturedAt, end: latestCapturedAt)
    }
    
    private var earliestCapturedAt: Date {
        ax.firstSnapshotCapturedAt ?? Date.init(timeIntervalSinceReferenceDate: 0)
    }
    
    private var latestCapturedAt: Date {
        ax.lastSnapshotCapturedAt ?? Date.init(timeIntervalSinceReferenceDate: TimeInterval.greatestFiniteMagnitude)
    }
}

