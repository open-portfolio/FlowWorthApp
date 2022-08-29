//
//  AccountCommand.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Combine
import SwiftUI

import KeyWindow

import AllocData
import FlowWorthLib
import FlowBase
import FlowUI

struct AccountCommand: View {
    @KeyWindowValueBinding(WorthDocument.self)
    var document: WorthDocument?

    let defaultEventModifier: EventModifiers = [.control, .option]
    let altEventModifier: EventModifiers = [.option, .command]

    var body: some View {
        Text("Returns")
        
        if let accounts = document?.activeAccounts, accounts.count > 0 {
            ForEach(0 ..< accounts.count, id: \.self) { n in
                SettingsMenuItemKeyed(keyPath: \WorthDocument.displaySettings.activeSidebarMenuKey,
                                      keyToMatch: accounts[n].primaryKey.accountNormID,
                                      desc: accounts[n].titleID,
                                      onSelect: { _ in self.setReturnsView(accounts[n].primaryKey) })
                    .modifier(NumericKeyShortCutModifier(n: n + 1, modifiers: defaultEventModifier))
            }
        }

        Divider()
        
        SettingsMenuItemBool(keyPath: \WorthDocument.displaySettings.showSecondary,
                             desc: "Inspector")
            .keyboardShortcut("0", modifiers: [.option, .command])
    }
    
    private func setReturnsView(_ accountKey: AccountKey?) {
        guard let _accountKey = accountKey else { return }
        document?.modelSettings.activeStrategyKey = MStrategy.emptyKey
        document?.displaySettings.activeSidebarMenuKey = _accountKey.accountNormID
    }
}
