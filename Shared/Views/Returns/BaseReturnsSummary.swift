//
//  BaseReturnsSummary.swift
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

#if os(macOS)
let toggleColor = Color(.controlTextColor)
#else
let toggleColor = Color.primary
#endif

struct BaseReturnsSummary: View {

    
    @Binding var document: WorthDocument
    var title: String
    var mr: MatrixResult
    var account: MAccount?
    
    var body: some View {
        VStack {
            if document.displaySettings.showSecondary {
                #if os(macOS)
                    HSplitView {
                        primary
                        secondary
                    }
                #else
                    HStack {
                        primary
                        secondary
                    }
                #endif
            } else {
                primary
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .principal) { viewControls }
            
            #if os(macOS)
            ToolbarItemGroup(placement: .primaryAction) { barControls }
            #else
            ToolbarItemGroup(placement: .automatic) { }
            #endif
        }
    }
    
    private var primary: some View {
        PrimaryReturns(document: $document,
                       mr: mr,
                       fr: fr,
                       title: title)
            .frame(minWidth: 600, idealWidth: 800, maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var secondary: some View {
        SecondaryReturns(document: $document,
                         mr: mr,
                         fr: fr,
                         account: account)
            .frame(minWidth: 400, idealWidth: 500, maxWidth: .infinity, maxHeight: .infinity)
    }
    
    @ViewBuilder
    private var viewControls: some View {
        ColoredSystemImageToggle(on: $document.displaySettings.showChartLegend,
                                 color: toggleColor,
                                 systemImageNameOn: "l.square.fill",
                                 systemImageNameOff: "l.square",
                                 enabled: true,
                                 help: "Show Chart Legend")

        Spacer()
        ReturnsExtentPicker(document: $document)
        Spacer()
        ReturnsGroupingPicker(document: $document)
        Spacer()
        ReturnsColorPicker(document: $document)
        Spacer()
        PeriodSummarySelectionPicker(document: $document)
    }
    
    @ViewBuilder
    private var barControls: some View {
        Spacer()

        InspectorToggle(on: $document.displaySettings.showSecondary)
    }
    
    // MARK: - Properties
    
    private var fr: ForecastResult {
        ForecastResult(snapshots: mr.orderedSnapshots,
                       marketvalueMap: mr.snapshotMarketValueMap)
    }
}
