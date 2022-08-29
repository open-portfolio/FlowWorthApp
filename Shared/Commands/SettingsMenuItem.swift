//
//  MenuSettingsBool.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

import KeyWindow

struct SettingsMenuItemBool: View {
    @KeyWindowValueBinding(WorthDocument.self)
    var document: WorthDocument?

    var keyPath: WritableKeyPath<WorthDocument, Bool>
    var desc: String
    var enabled: Bool = true

    var body: some View {
        Button(action: {
            document?[keyPath: keyPath].toggle()
        }) {
            Text("\((document?[keyPath: keyPath] ?? false) ? "✓" : "   ") \(desc)")
        }
            .disabled(!enabled)
    }
}

struct SettingsMenuItemKeyed<T: Equatable>: View {
    @KeyWindowValueBinding(WorthDocument.self)
    var document: WorthDocument?
    var keyPath: WritableKeyPath<WorthDocument, T>
    var keyToMatch: T
    var desc: String
    var onSelect: ((T) -> Void)? = nil
    
    var body: some View {
        Button(action: {
            document?[keyPath: keyPath] = keyToMatch
            onSelect?(keyToMatch)
        }, label: {
            Text("\((document?[keyPath: keyPath] == keyToMatch) ? "✓" : "   ") \(desc)")
        })
    }
}
