//
//  ReturnsCommand.swift
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

extension TabsPrimaryReturns {
    var description: String {
        switch self {
        case .chart:
            return "Chart"
        case .assets:
            return "Assets"
        case .accounts:
            return "Accounts"
        case .strategies:
            return "Strategies"
        case .forecast:
            return "Forecast"
        }
    }

    var keyboardShortcut: KeyEquivalent {
        switch self {
        case .chart:
            return "j"
        case .assets:
            return "k"
        case .accounts:
            return "l"
        case .strategies:
            return ";"
        case .forecast:
            return "f"
        }
    }
}

extension TabsSecondaryReturns {
    var description: String {
        switch self {
        case .delta:
            return "\(WorthDocument.deltaSymbol)"
        case .dietz:
            return "R"
        case .assets:
            return "Assets"
        case .accounts:
            return "Accounts"
        case .forecast:
            return "Forecast"
        }
    }

    var keyboardShortcut: KeyEquivalent {
        switch self {
        case .delta:
            return "d"
        case .dietz:
            return "r"
        case .assets:
            return "e"
        case .accounts:
            return "k"
        case .forecast:
            return "f"
        }
    }
}


struct ReturnsCommand: View {
    @KeyWindowValueBinding(WorthDocument.self)
    var document: WorthDocument?

    let defaultEventModifier: EventModifiers = [.command]
    let altEventModifier: EventModifiers = [.shift, .command]

    var body: some View {

        primary
        
        Divider()
        
        SettingsMenuItemBool(keyPath: \WorthDocument.displaySettings.showSecondary,
                             desc: "Inspector")
            //            .keyboardShortcut("0", modifiers: defaultEventModifier)
            .keyboardShortcut("0", modifiers: [.option, .command])

        SettingsMenuItemBool(keyPath: \WorthDocument.displaySettings.returnsExpandBottom,
                             desc: "Period Range")
            .keyboardShortcut("y", modifiers: defaultEventModifier)
        
        Divider()
        
        secondary

        Divider()
        
        chartItems
        
        Divider()
        
        periodSummary
    }
    
    @ViewBuilder
    private var periodSummary: some View {
        Text("Period Summary")
        ForEach(PeriodSummarySelection.allCases, id: \.self) { item in
            SettingsMenuItemKeyed(keyPath: \WorthDocument.displaySettings.periodSummarySelection,
                                  keyToMatch: item,
                                  desc: item.fullDescription)
                .keyboardShortcut(item.keyboardShortcut, modifiers: defaultEventModifier)
        }
    }
    
    @ViewBuilder
    private var chartItems: some View {
        chartGrouping

        Divider()
        
        chartColor
        
        Divider()
        
        chartExtent
        
        Divider()
        
        SettingsMenuItemBool(keyPath: \WorthDocument.displaySettings.showChartLegend,
                             desc: "Chart Legend")
            .keyboardShortcut("g", modifiers: defaultEventModifier)
    }
    
    @ViewBuilder
    private var chartGrouping: some View {
        Text("Chart Grouping")
        
        ForEach(ReturnsGrouping.allCases, id: \.self) { item in
            SettingsMenuItemKeyed(keyPath: \WorthDocument.displaySettings.returnsGrouping,
                                  keyToMatch: item,
                                  desc: item.description)
                .keyboardShortcut(item.keyboardShortcut, modifiers: defaultEventModifier)
        }
    }
    
    @ViewBuilder
    private var chartColor: some View {
        Text("Chart Color")
        
        ForEach(ReturnsColor.allCases, id: \.self) { item in
            SettingsMenuItemKeyed(keyPath: \WorthDocument.displaySettings.returnsColor,
                                  keyToMatch: item,
                                  desc: item.description)
                .keyboardShortcut(item.keyboardShortcut, modifiers: defaultEventModifier)
        }
    }
    
    @ViewBuilder
    private var chartExtent: some View {
        Text("Chart Extent")
        
        ForEach(ReturnsExtent.allCases, id: \.self) { item in
            SettingsMenuItemKeyed(keyPath: \WorthDocument.displaySettings.returnsExtent,
                                  keyToMatch: item,
                                  desc: item.description)
                .keyboardShortcut(item.keyboardShortcut, modifiers: defaultEventModifier)
        }
    }

    
    @ViewBuilder
    private var primary: some View {
        //Text("Primary")
        
        ForEach(TabsPrimaryReturns.allCases, id: \.self) { item in
            SettingsMenuItemKeyed(keyPath: \WorthDocument.displaySettings.primaryReturnsTab,
                                  keyToMatch: item,
                                  desc: item.description,
                                  onSelect: { _ in self.maybeSetView() })
                .keyboardShortcut(item.keyboardShortcut, modifiers: defaultEventModifier)
        }
    }

    @ViewBuilder
    private var secondary: some View {
        Text("Inspector")
        
        ForEach(TabsSecondaryReturns.allCases, id: \.self) { item in
            SettingsMenuItemKeyed(keyPath: \WorthDocument.displaySettings.secondaryReturnsTab,
                                  keyToMatch: item,
                                  desc: item.description,
                                  onSelect: { _ in self.maybeSetView(); self.enableInspector() })
                .keyboardShortcut(item.keyboardShortcut, modifiers: altEventModifier)
        }
    }
    
    private func maybeSetView() {
        guard let currentMenuKey = document?.displaySettings.activeSidebarMenuKey else { return }
        let validMenuKeys = [WorthSidebarMenuIDs.birdsEyeChart.rawValue,
                             SidebarMenuIDs.tradingAccountsSummary.rawValue,
                             SidebarMenuIDs.nonTradingAccountsSummary.rawValue,
                             SidebarMenuIDs.activeStrategy.rawValue]
        if !validMenuKeys.contains(currentMenuKey) && !isValidAccountKey(currentMenuKey) {
            setBirdsEyeView()
        }
    }
    
    private func isValidAccountKey(_ currentMenuKey: String?) -> Bool {
        guard let key = currentMenuKey else { return false }
        let maybeAccountKey = MAccount.Key(accountID: key)
        return document?.context.accountMap[maybeAccountKey] != nil
    }
    
    private func setBirdsEyeView() {
        document?.displaySettings.activeSidebarMenuKey = WorthSidebarMenuIDs.birdsEyeChart.rawValue
    }
    
    private func enableInspector() {
        document?.displaySettings.showSecondary = true
    }
}



