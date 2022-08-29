//
//  SecondaryReturns.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

import AllocData

import FlowBase
import FlowUI
import FlowWorthLib

struct SecondaryReturns: View {

    @Binding var document: WorthDocument
    @ObservedObject var mr: MatrixResult
    @ObservedObject var fr: ForecastResult
    var account: MAccount?

    // MARK: Views
    
    var body: some View {
        TabView(selection: $document.displaySettings.secondaryReturnsTab) {
            AssetsList(document: $document, mr: mr)
                .tabItem { Text("Asset Classes") }
                .tag(TabsSecondaryReturns.assets)
            if account == nil {
                AccountsList(document: $document, mr: mr)
                    .tabItem { Text("Accounts") }
                    .tag(TabsSecondaryReturns.accounts)
            }
            DeltaSecondary(document: $document, mr: mr)
                .tabItem { Text("\(WorthDocument.deltaSymbol)") }
                .tag(TabsSecondaryReturns.delta)
            DietzSecondary(document: $document, mr: mr)
                .tabItem { Text("\(WorthDocument.rSymbol)") }
                .tag(TabsSecondaryReturns.dietz)
            ForecastSecondary(document: $document, fr: fr)
                .tabItem { Text("Forecast") }
                .tag(TabsSecondaryReturns.forecast)
        }
    }
}

