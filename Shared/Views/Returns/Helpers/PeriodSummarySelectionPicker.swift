//
//  PeriodSummarySelectionPicker.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

import FlowWorthLib

struct PeriodSummarySelectionPicker: View {
    @Binding var document: WorthDocument
    
    var body: some View {
        PeriodSummarySelection.picker(periodSummarySelection: $document.displaySettings.periodSummarySelection)
    }
}

extension PeriodSummarySelection {
    var description: String {
        switch self {
        case .deltaMarketValue:
            return "Change in Market Value (\(WorthDocument.deltaSymbol))"
        case .deltaTotalBasis:
            return "Change in Total Basis (B)"
        case .modifiedDietz:
            return "Performance (\(WorthDocument.rSymbol))"
        }
    }
    
    var fullDescription: String {
        "\(description)"
    }
    
    var systemImage: (String, String) {
        switch self {
        case .deltaMarketValue:
            return ("arrowtriangle.up", "arrowtriangle.up.fill")
        case .deltaTotalBasis:
            return ("b.square", "b.square.fill")
        case .modifiedDietz:
            return ("r.square", "r.square.fill")
        }
    }
    
    var keyboardShortcut: KeyEquivalent {
        switch self {
        case .deltaMarketValue:
            return "d"
        case .deltaTotalBasis:
            return "b"
        case .modifiedDietz:
            return "r"
        }
    }
    
    private static func myLabel(selection: Binding<PeriodSummarySelection>, en: PeriodSummarySelection) -> some View {
        let isSelected = selection.wrappedValue == en
        return Image(systemName: isSelected ? en.systemImage.1 : en.systemImage.0)
    }
    
    static func picker(periodSummarySelection: Binding<PeriodSummarySelection>) -> some View {
        Picker(selection: periodSummarySelection, label: EmptyView()) {
            myLabel(selection: periodSummarySelection, en: PeriodSummarySelection.deltaMarketValue)
                .tag(PeriodSummarySelection.deltaMarketValue)
            myLabel(selection: periodSummarySelection, en: PeriodSummarySelection.deltaTotalBasis)
                .tag(PeriodSummarySelection.deltaTotalBasis)
            myLabel(selection: periodSummarySelection, en: PeriodSummarySelection.modifiedDietz)
                .tag(PeriodSummarySelection.modifiedDietz)
        }
        .pickerStyle(SegmentedPickerStyle())
        .help(periodSummarySelection.wrappedValue.fullDescription)
    }
}
