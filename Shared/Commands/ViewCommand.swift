//
//  ViewCommand.swift
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

struct ViewCommand: View {
    @KeyWindowValueBinding(WorthDocument.self)
    var document: WorthDocument?

    let defaultEventModifier: EventModifiers = [.control, .command]

    var body: some View {

        returnsItems

        Divider()
        
        snapshotItems
        
        Divider()
        
        builderItems
        
        Divider()

        DataModelCommands(baseTableViewCommands: getBaseDataModelViewCommand(baseModelEntities),
                          onSelect: { document?.displaySettings.activeSidebarMenuKey = $0 },
                          auxTableViewCommands: auxTableViewCommands)
    }

    private var auxTableViewCommands: [DataModelViewCommand] {
        [
            DataModelViewCommand(id: WorthSidebarMenuIDs.modelValuationSnapshots.rawValue,
                              title: WorthSidebarMenuIDs.modelValuationSnapshots.title),
            
            DataModelViewCommand(id: WorthSidebarMenuIDs.modelValuationPositions.rawValue,
                              title: WorthSidebarMenuIDs.modelValuationPositions.title),
            
            DataModelViewCommand(id: WorthSidebarMenuIDs.modelValuationCashflow.rawValue,
                              title: WorthSidebarMenuIDs.modelValuationCashflow.title)
        ]
    }
    
    @ViewBuilder
    var snapshotItems: some View {
        Button(action: {
            document?.displaySettings.activeSidebarMenuKey = WorthSidebarMenuIDs.snapshotSummary.rawValue
        }, label: {
            Text("Valuation Snapshots")
        })
            .keyboardShortcut("v", modifiers: defaultEventModifier)
    }
    
    @ViewBuilder
    var returnsItems: some View {
        Text("Returns")
        
        Button(action: {
            document?.displaySettings.activeSidebarMenuKey = WorthSidebarMenuIDs.birdsEyeChart.rawValue
        }, label: {
            Text("Portfolio")
        })
            .keyboardShortcut("0", modifiers: defaultEventModifier)

        Button(action: {
            document?.displaySettings.activeSidebarMenuKey = SidebarMenuIDs.activeStrategy.rawValue
        }, label: {
            Text("Active Strategy")
        })
            .keyboardShortcut(.return, modifiers: defaultEventModifier)
        
        Button(action: {
            document?.displaySettings.activeSidebarMenuKey = SidebarMenuIDs.tradingAccountsSummary.rawValue
        }, label: {
            Text("Trading Accounts")
        })
            .keyboardShortcut("t", modifiers: defaultEventModifier)

        Button(action: {
            document?.displaySettings.activeSidebarMenuKey = SidebarMenuIDs.nonTradingAccountsSummary.rawValue
        }, label: {
            Text("Non-Trading Accounts")
        })
            .keyboardShortcut("n", modifiers: defaultEventModifier)
    }

    @ViewBuilder
    var builderItems: some View {
        Text("Builder")
        
        Button(action: {
            document?.displaySettings.activeSidebarMenuKey = WorthSidebarMenuIDs.builderSummary.rawValue
        }, label: {
            Text("Summary")
        })
            .keyboardShortcut("b", modifiers: defaultEventModifier)
        
        Button(action: {
            document?.displaySettings.activeSidebarMenuKey = WorthSidebarMenuIDs.builderPositions.rawValue
        }, label: {
            Text("Positions")
        })
            .keyboardShortcut("p", modifiers: defaultEventModifier)

        Button(action: {
            document?.displaySettings.activeSidebarMenuKey = WorthSidebarMenuIDs.builderCashflow.rawValue
        }, label: {
            Text("Cash Flow")
        })
            .keyboardShortcut("c", modifiers: defaultEventModifier)
    }
    
   
}
