//
//  GettingStarted.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

import FlowUI
import FlowBase
import FlowWorthLib
import AllocData

struct GettingStarted: View {
    @Binding var document: WorthDocument

    var body: some View {
        ScrollView {
            GroupBox(label: Text("Getting Started")) {
                VStack(alignment: .leading) {
                    Group {
                        Text("First steps to tracking your portfolio performance:")
                        
                        myText(1, "Create (or import) your accounts")
                        
                        myText(2, "Import holdings for those accounts (e.g, from brokerage positions export)")
                        
                        myText(3, "Ensure each held security is priced and assigned to an asset class")
                        
                        myText(4, "Create the initial valuation snapshot using the Snapshot Builder")
                        
                        Text("At least one day later...")
                        
                        myText(5, "Import updated holdings for your accounts")
                        
                        myText(6, "(Optionally) import transactions (e.g, from brokerage transaction export)")
                        
                        myText(7, "Create the second valuation snapshot using the Snapshot Builder")
                        
                        myText(8, "Review how things changed!")
                    }
                    .font(.title2)
                    .padding(.horizontal)
                    .padding(.vertical, 5)
                }
            }
            
            if document.model.accounts.count == 0 {
                HStack {
                    Text("Or if you just want to explore with fake data...")
                        .font(.title2)
                    Button(action: randomPortfolioAction, label: {
                        Text("Generate Random Portfolio")
                    })
                }
                .padding()
            }
        }
    }

    private func myText(_ n: Int, _ suffix: String) -> some View {
        WelcomeNumberedLabel(n, fill: document.accentFill) { Text(suffix) }
    }
    
    private func randomPortfolioAction() {
        do {
            var factory = BasePopulator(&document.model, includeLiabilities: true)
            try factory.populateRandom(&document.model, snapshotCount: 12)
            document.modelSettings.activeStrategyKey = document.model.strategies.randomElement()?.primaryKey ?? MStrategy.emptyKey
            document.displaySettings.activeSidebarMenuKey = SidebarMenuIDs.activeStrategy.rawValue
        } catch {
            print(error)
        }
    }
}
