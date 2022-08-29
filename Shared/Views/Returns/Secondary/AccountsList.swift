//
//  AccountsList.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

import Tabler
import AllocData

import FlowBase
import FlowUI
import FlowWorthLib

struct AccountsList: View {
    @Binding var document: WorthDocument
    @ObservedObject var mr: MatrixResult
    
    init(document: Binding<WorthDocument>, mr: MatrixResult) {
        _document = document
        self.mr = mr
    }

    private let gridItems: [GridItem] = [
        GridItem(.fixed(40), spacing: columnSpacing, alignment: .center),
        GridItem(.flexible(minimum: 100), spacing: columnSpacing),
    ]
    
    @AppStorage(UserDefShared.timeZoneID.rawValue) var timeZoneID: String = ""
    @State var hovered: AccountKey.ID? = nil

    var body: some View {
        VStack {
            HStack {
                Text("Represented Accounts")
                    .font(.title2)
                Spacer()
                
                HelpButton(appName: "worth", topicName: "inspectAccounts")
            }
            .padding()
            .lineLimit(1)

            TablerList(
                .init(onHover: { if $1 { hovered = $0 } else { hovered = nil } }),
                header: header,
                row: row,
                rowBackground: { MyRowBackground($0, hovered: hovered, selected: nil) },
                results: availableAccountKeys)
        }
    }
    
    typealias Context = TablerContext<AccountKey>
    
    private func header(_ ctx: Binding<Context>) -> some View {
        LazyVGrid(columns: gridItems, alignment: .leading, spacing: flowColumnSpacing) {
            Text("✓")
                .modifier(HeaderCell())
                .onTapGesture { headerCheckAction() }
            Text("Account (Number)")
                .modifier(HeaderCell())
        }
    }
    
    private func row(_ accountKey: AccountKey) -> some View {
        
        LazyVGrid(columns: gridItems, alignment: .leading, spacing: flowColumnSpacing) {
            if let _onCheck = checkAction, let _isChecked = isCheckedAction {
                CheckControl(element: accountKey, onCheck: _onCheck, isChecked: _isChecked)
            }
            Text(MAccount.getTitleID(accountKey, ax.accountMap, withID: true) ?? "")
                .lineLimit(1)
                .mpadding()
        }
    }

    // MARK: - Properties
    
    private var ax: WorthContext {
        document.context
    }
    
    private var availableAccountKeys: [AccountKey] {
        mr.accountFilteredMap.map(\.key).sorted()
    }
    
    // MARK: - Actions
    
    private func checkAction(_ accountKeys: [AccountKey], _ nuValue: Bool) {
        accountKeys.forEach { key in
            document.displaySettings.excludedAccountMap[key] = nuValue
        }
        
        document.refreshWorthResult(timeZoneID: timeZoneID) // refresh PendingSnapshot
    }
    
    private func isCheckedAction(_ key: AccountKey) -> Bool {
        document.displaySettings.excludedAccountMap[key] ?? false
    }

    private func headerCheckAction() {
        if document.displaySettings.excludedAccountMap.first(where: { $0.value }) != nil {
            document.displaySettings.excludedAccountMap.removeAll()
        } else {
            availableAccountKeys.forEach {
                document.displaySettings.excludedAccountMap[$0] = true
            }
        }
    }
    
    // MARK: - Helpers
    
    private func getTitle(_ accountKey: AccountKey) -> String {
        ax.accountMap[accountKey]?.titleID ?? accountKey.accountNormID.uppercased()
    }
}
