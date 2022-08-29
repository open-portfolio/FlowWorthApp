//
//  WorthSidebar.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

import AllocData

import FlowUI
import FlowWorthLib
import FlowBase

enum WorthSidebarMenuIDs: String {
    case snapshotSummary = "BB80F6B8-2A48-4910-8942-22338938D5BA"
    case birdsEyeChart = "53DA1D1D-07DB-4CCF-BAAF-E6A76C4681FD"
    case builderPositions = "22F943B5-FE18-49DD-9D0F-C816D0CCDE18"
    case builderCashflow = "B4920C01-8BD0-46A2-85A1-ED1DE0191AF9"
    case builderSummary = "FFEBBCB7-95BB-4D95-A5F1-567D36DA2899"
    case modelValuationSnapshots = "98363443-B922-4C00-84AC-F04173D4D03C"
    case modelValuationPositions = "B03004CC-AE96-44BB-8557-CCD3FFCEE6D5"
    case modelValuationCashflow = "0856B316-111D-4E20-85E4-8B2072726482"
    case spacer0 = "BA95F986-16B9-4B31-BC8F-D8CB68ABB199"
    case spacer1 = "9E879693-E885-4344-A353-59E720842DC9"
    case spacer2 = "EEF15263-6C82-4159-9198-AD1019C5DA25"
    
    public var title: String {
        switch self {
        case .snapshotSummary:
            return "Snapshot Summary"
        case .birdsEyeChart:
            return "Overview"
        case .builderPositions:
            return "Snapshot Builder Positions"
        case .builderCashflow:
            return "Snapshot Builder Cashflow"
        case .builderSummary:
            return "Snapshot Builder Summary"
        case .modelValuationSnapshots:
            return "Valuation Snapshots"
        case .modelValuationPositions:
            return "Valuation Positions"
        case .modelValuationCashflow:
            return "Valuation Cash Flow"
        default:
            return ""
        }
    }
}

struct WorthSidebar: View {
    @Binding var document: WorthDocument
    @ObservedObject var mrBirdsEye: MatrixResult
    var isEmpty: Bool
    
    private static let shortDF: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .short
        df.timeStyle = .short
        return df
    }()
    
    var body: some View {

        if !isEmpty {
            BirdsEyeSection(document: $document, mrBirdsEye: mrBirdsEye)
        } else {
            AppIcon()
                .scaleEffect(1.5)
                .padding()
        }
        
        spacer(.spacer0)
        
        SnapshotsSection(document: $document, now: now)
        
        spacer(.spacer1)

        BuilderSection(document: $document, now: now)
        
        spacer(.spacer2)
    }
   
    private func spacer(_ menuID: WorthSidebarMenuIDs) -> some View {
        
        // NOTE because of possible SwiftUI bug, making the spacer navigable
        NavigationLink(destination: WelcomeView() { GettingStarted(document: $document) },
                       tag: menuID.rawValue,
                       selection: $document.displaySettings.activeSidebarMenuKey) {
            Spacer()
        }
    }
    
    // MARK: - Properties
    
    private var now: Date {
        Date()
    }
}
