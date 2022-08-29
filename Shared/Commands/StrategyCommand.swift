//
//  StrategyCommand.swift
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

import FlowWorthLib
import AllocData

import FlowUI
import FlowBase

struct StrategyCommand: View {
    @AppStorage(UserDefShared.timeZoneID.rawValue) var timeZoneID: String = ""
    
    @KeyWindowValueBinding(WorthDocument.self)
    var document: WorthDocument?
    
    let defaultEventModifier: EventModifiers = [.option, .command]
    
    var body: some View {
        Text("Returns")
        
        ForEach(0 ..< strategies.count, id: \.self) { n in
            SettingsMenuItemKeyed(keyPath: \WorthDocument.modelSettings.activeStrategyKey,
                                  keyToMatch: strategies[n].primaryKey,
                                  desc: strategies[n].titleID,
                                  onSelect: { _ in self.setReturnsView(strategies[n].primaryKey) })
                .modifier(NumericKeyShortCutModifier(n: n + 1, modifiers: defaultEventModifier))
        }
        
        Divider()
        
        SettingsMenuItemBool(keyPath: \WorthDocument.displaySettings.showSecondary,
                             desc: "Inspector")
            .keyboardShortcut("0", modifiers: [.option, .command])
    }
    
    private var ax: WorthContext? {
        document?.context
    }
    
    private var strategies: [MStrategy] {
        guard let document_ = document else { return [] }
        return document_.model.strategies.sorted()
    }
    
    private func setReturnsView(_ strategyKey: StrategyKey?) {
        guard let _strategyKey = strategyKey else { return }
        if _strategyKey != (document?.modelSettings.activeStrategyKey ?? MStrategy.emptyKey) {
            document?.modelSettings.activeStrategyKey = _strategyKey
            document?.refreshContext(timeZoneID: timeZoneID)
        }
        
        // TODO For some reason, the context refresh forces view to data model accounts
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            document?.displaySettings.activeSidebarMenuKey = SidebarMenuIDs.activeStrategy.rawValue
        }
    }
}
