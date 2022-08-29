//
//  ReturnsColorPicker.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

import FlowWorthLib

struct ReturnsColorPicker: View {
    @Binding var document: WorthDocument
    
    var body: some View {
        ReturnsColor.picker(returnsColor: $document.displaySettings.returnsColor)
    }
}

extension ReturnsColor {
    var description: String {
        switch self {
        case .color:
            return "Color"
        case .mono:
            return "Monochrome"
        }
    }
    
    var fullDescription: String {
        "Render in \(description)"
    }
    
    var systemImage: (String, String) {
        switch self {
        case .color:
            return ("c.square", "c.square.fill")
        case .mono:
            return ("m.square", "m.square.fill")
        }
    }
    
    var keyboardShortcut: KeyEquivalent {
        switch self {
        case .color:
            return "7"
        case .mono:
            return "8"
        }
    }
    
    private static func myLabel(selection: Binding<ReturnsColor>, en: ReturnsColor) -> some View {
        let isSelected = selection.wrappedValue == en
        return
            Image(systemName: isSelected ? en.systemImage.1 : en.systemImage.0)
    }
    
    static func picker(returnsColor: Binding<ReturnsColor>) -> some View {
        Picker(selection: returnsColor, label: EmptyView()) {
            myLabel(selection: returnsColor, en: ReturnsColor.mono)
                .tag(ReturnsColor.mono)
            myLabel(selection: returnsColor, en: ReturnsColor.color)
                .tag(ReturnsColor.color)
        }
        .pickerStyle(SegmentedPickerStyle())
        .help(returnsColor.wrappedValue.fullDescription)
    }
}
