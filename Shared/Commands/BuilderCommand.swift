//
//  BuilderCommand.swift
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
import FlowUI

extension TabsPositionsBuilder {
    var description: String {
        switch self {
        case .holdings:
            return "Holdings"
        case .positions:
            return "Positions"
        case .previousPositions:
            return "Previous Positions"
        }
    }
    
    var keyboardShortcut: KeyEquivalent {
        switch self {
        case .holdings:
            return "["
        case .positions:
            return "]"
        case .previousPositions:
            return "\\"
        }
    }
}

extension TabsCashflowBuilder {
    var description: String {
        switch self {
        case .transactions:
            return "Imported Transactions"
        case .nuCashflow:
            return "New Cash Flow"
        case .prevCashflow:
            return "Previous Cash Flow"
        }
    }
    
    var keyboardShortcut: KeyEquivalent {
        switch self {
        case .transactions:
            return "l"
        case .nuCashflow:
            return ";"
        case .prevCashflow:
            return "'"
        }
    }
}

struct BuilderCommand: View {
    @KeyWindowValueBinding(WorthDocument.self)
    var document: WorthDocument?
    
    let defaultEventModifier: EventModifiers = [.option, .command]
    
    var body: some View {
        
        builder
        
        Divider()
                
        Button(action: commitBuilderAction) {
            Text("Create")
        }
        .disabled(!canCommitBuilder)
        .keyboardShortcut("c", modifiers: defaultEventModifier)
        
        Button(action: clearBuilderAction) {
            Text("Clear")
        }
        .keyboardShortcut("e", modifiers: defaultEventModifier)
    }
    
    @ViewBuilder
    private var builder: some View {
        Text("Positions")
        
        ForEach(TabsPositionsBuilder.allCases, id: \.self) { item in
            SettingsMenuItemKeyed(keyPath: \WorthDocument.displaySettings.builderPositionsTab,
                                  keyToMatch: item,
                                  desc: item.description,
                                  onSelect: { _ in self.setBuilderPositionView() })
                .keyboardShortcut(item.keyboardShortcut, modifiers: defaultEventModifier)
        }
        
        Text("Cash Flow")
        
        ForEach(TabsCashflowBuilder.allCases, id: \.self) { item in
            SettingsMenuItemKeyed(keyPath: \WorthDocument.displaySettings.builderCashflowTab,
                                  keyToMatch: item,
                                  desc: item.description,
                                  onSelect: { _ in self.setBuilderCashflowView() })
                .keyboardShortcut(item.keyboardShortcut, modifiers: defaultEventModifier)
        }
    }
    
    // MARK: - helpers
    
    private func setBuilderPositionView() {
        document?.displaySettings.activeSidebarMenuKey = WorthSidebarMenuIDs.builderPositions.rawValue
    }
    
    private func setBuilderCashflowView() {
        document?.displaySettings.activeSidebarMenuKey = WorthSidebarMenuIDs.builderCashflow.rawValue
    }
    
    private func maybeSetView() {
        guard let currentMenuKey = document?.displaySettings.activeSidebarMenuKey else { return }
        let validMenuKeys = [WorthSidebarMenuIDs.builderPositions.rawValue, WorthSidebarMenuIDs.builderCashflow.rawValue]
        if !validMenuKeys.contains(currentMenuKey) {
            setBuilderPositionView()
        }
    }
    
    private var canCommitBuilder: Bool {
        document?.canCommitBuilder ?? false
    }
    
    private func commitBuilderAction() {
        guard let d = document else { return }
        maybeSetView()
        NotificationCenter.default.post(name: .commitBuilder, object: d.model.id)
    }
    
    private func clearBuilderAction() {
        guard let d = document else { return }
        maybeSetView()
        NotificationCenter.default.post(name: .clearBuilder, object: d.model.id)
    }
    
}
