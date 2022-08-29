//
//  ReturnsExtentPicker.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

import FlowWorthLib

struct ReturnsExtentPicker: View {
    @Binding var document: WorthDocument
    
    var body: some View {
        ReturnsExtent.picker(returnsExtent: $document.displaySettings.returnsExtent)
    }
}

extension ReturnsExtent {
    var description: String {
        switch self {
        case .all:
            return "Both Negative and Positive"
        case .positiveOnly:
            return "Positive Only"
        case .negativeOnly:
            return "Negative Only"
        }
    }
    
    var fullDescription: String {
        "Chart extent: \(description)"
    }
    
    var toolbarText: String {
        switch self {
        case .all:
            return "Both"
        case .positiveOnly:
            return "Positive"
        case .negativeOnly:
            return "Negative"
        }
    }
    
    var toolbarImage: String {
        switch self {
        case .all:
            return "plusminus"
        case .positiveOnly:
            return "plus"
        case .negativeOnly:
            return "minus"
        }
    }
    
    var keyboardShortcut: KeyEquivalent {
        switch self {
        case .all:
            return "0"
        case .positiveOnly:
            return "="
        case .negativeOnly:
            return "-"
        }
    }
    
    private static func myLabel(selection: Binding<ReturnsExtent>, en: ReturnsExtent) -> some View {
        Label(title: { Text(en.toolbarText) }, icon: { Image(systemName: en.toolbarImage) })
    }
    
    static func picker(returnsExtent: Binding<ReturnsExtent>) -> some View {
        Picker(selection: returnsExtent, label: EmptyView()) {
            myLabel(selection: returnsExtent, en: ReturnsExtent.all)
                .tag(ReturnsExtent.all)
            myLabel(selection: returnsExtent, en: ReturnsExtent.positiveOnly)
                .tag(ReturnsExtent.positiveOnly)
            myLabel(selection: returnsExtent, en: ReturnsExtent.negativeOnly)
                .tag(ReturnsExtent.negativeOnly)
        }
        .pickerStyle(SegmentedPickerStyle())
        .help(returnsExtent.wrappedValue.fullDescription)
    }
}
