//
//  SnapshotNavPicker.swift
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
import FlowUI
import FlowWorthLib

struct SnapshotNavPicker: View {
    
    var model: BaseModel
    var ax: WorthContext
    @Binding var snapshotKey: SnapshotKey
    var range: DateInterval

    var body: some View {
        KeyedPicker(elements: filteredSnapshots, key: $snapshotKey, getTitle: getTitle) {}
            .modify {
                #if os(macOS)
                $0.pickerStyle(DefaultPickerStyle())
                    .labelsHidden()
                #else
                $0.pickerStyle(MenuPickerStyle())
                    .foregroundColor(.primary) // to contrast with the background accent color when selected
                #endif
            }
    }
    
    func getTitle(_ snapshot: MValuationSnapshot) -> String {
        let index = ax.snapshotIndexes[snapshot.primaryKey] ?? -1
        return "#\(index + 1): \(snapshot.titleID)"
    }
    
    /// filter INCLUSIVE of range
    var filteredSnapshots: [MValuationSnapshot] {
        ax.orderedSnapshots.filter { range.start <= $0.capturedAt && $0.capturedAt <= range.end }
    }
}

