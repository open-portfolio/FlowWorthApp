//
//  ReturnsGroupingPicker.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

import FlowWorthLib

struct ReturnsGroupingPicker: View {
    @Binding var document: WorthDocument
    
    var body: some View {
        ReturnsGrouping.picker(returnsGrouping: $document.displaySettings.returnsGrouping)
    }
}

extension ReturnsGrouping {
    var description: String {
        switch self {
        case .assets:
            return "Asset Class"
        case .accounts:
            return "Account"
        case .strategies:
            return "Strategy"
        }
    }
    
    var fullDescription: String {
        "Group by \(description)"
    }
    
    var systemImage: (String, String) {
        switch self {
        case .assets:
            return ("a.square", "a.square.fill")
        case .accounts:
            return ("dollarsign.circle", "dollarsign.circle.fill")
        case .strategies:
            return ("s.square", "s.square.fill")
        }
    }
    
    var keyboardShortcut: KeyEquivalent {
        switch self {
        case .assets:
            return "1"
        case .accounts:
            return "2"
        case .strategies:
            return "3"
        }
    }
    
    private static func myLabel(selection: Binding<ReturnsGrouping>, en: ReturnsGrouping) -> some View {
        let isSelected = selection.wrappedValue == en
        return Image(systemName: isSelected ? en.systemImage.1 : en.systemImage.0)
    }
    
    static func picker(returnsGrouping: Binding<ReturnsGrouping>) -> some View {
        Picker(selection: returnsGrouping, label: EmptyView()) {
            myLabel(selection: returnsGrouping, en: ReturnsGrouping.assets)
                .tag(ReturnsGrouping.assets)
            myLabel(selection: returnsGrouping, en: ReturnsGrouping.accounts)
                .tag(ReturnsGrouping.accounts)
            myLabel(selection: returnsGrouping, en: ReturnsGrouping.strategies)
                .tag(ReturnsGrouping.strategies)
        }
        .pickerStyle(SegmentedPickerStyle())
        .help(returnsGrouping.wrappedValue.fullDescription)
    }
}
