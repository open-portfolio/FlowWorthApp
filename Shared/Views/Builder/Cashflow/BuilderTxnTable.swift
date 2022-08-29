//
//  BuilderTxnTable.swift
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

struct BuilderTxnTable: View {
    
    @AppStorage(UserDefShared.timeZoneID.rawValue) var timeZoneID: String = ""
    
    @Binding var document: WorthDocument
    
    private static let dfShort: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .short
        df.timeStyle = .short
        return df
    }()
    
    private let gridItems: [GridItem] = [
        GridItem(.fixed(40), spacing: columnSpacing),
        GridItem(.flexible(minimum: 60), spacing: columnSpacing),
        GridItem(.flexible(minimum: 90), spacing: columnSpacing),
        GridItem(.flexible(minimum: 150), spacing: columnSpacing),
        GridItem(.flexible(minimum: 70), spacing: columnSpacing),
        GridItem(.flexible(minimum: 50), spacing: columnSpacing),
        GridItem(.flexible(minimum: 70), spacing: columnSpacing),
        GridItem(.flexible(minimum: 70), spacing: columnSpacing),
    ]
    
    var body: some View {
        VStack {
            TablerList(
                header: header,
                row: row,
                rowBackground: rowBackground,
                results: document.model.transactions)
            .sideways(minWidth: 1050, showIndicators: true)
            HStack { Spacer(); Text("*times may be approximate, depending on source data.").font(.footnote) }
        }
    }
    
    typealias Context = TablerContext<MTransaction>
    
    private func header(_ ctx: Binding<Context>) -> some View {
        LazyVGrid(columns: gridItems, alignment: .leading, spacing: flowColumnSpacing) {
            Text("✓")
                .modifier(HeaderCell())
                .onTapGesture { headerCheckAction() }
            Text("Action")
                .modifier(HeaderCell())
            Text("Transacted At*")
                .modifier(HeaderCell())
            Text("Account (Number)")
                .modifier(HeaderCell())
            Text("Security (Asset)")
                .modifier(HeaderCell())
            Text("Lot")
                .modifier(HeaderCell())
            Text("Share Count")
                .modifier(HeaderCell())
            Text("Share Price")
                .modifier(HeaderCell())
        }
    }
    
    private func row(_ item: MTransaction) -> some View {
        let assetKey = getAssetKey(item)
        return LazyVGrid(columns: gridItems, alignment: .leading, spacing: flowColumnSpacing) {
            if let _onCheck = checkAction, let _isChecked = isCheckedAction {
                CheckControl(element: item, onCheck: _onCheck, isChecked: _isChecked)
            }
            
            Text(item.action.displayDescription)
                .mpadding()
            Text(formattedDate(item.transactedAt))
                .mpadding()
            Text(MAccount.getTitleID(item.accountKey, ax.accountMap, withID: true) ?? "")
                .lineLimit(1)
                .mpadding()
            VStack {
                if item.securityKey.isValid {
                    Text(MSecurity.getTitleID(item.securityKey, ax.securityMap, ax.assetMap, withAssetID: true) ?? "")
                        .lineLimit(1)
                } else {
                    Text("(assumed cash)")
                }
            }
            .mpadding()
            Text(item.lotID)
                .mpadding()
            SharesLabel(value: item.shareCount, style: .default_)
                .mpadding()
            Group {
                if let price = item.sharePrice {
                    CurrencyLabel(value: price, style: .full)
                } else {
                    Text("MISSING")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .foregroundColor(.white)
                        .background(Color.red)
                }
            }
            .mpadding()
        }
        .foregroundColor(getColorCode(assetKey).0)
    }
    
    private func rowBackground(_ item: MTransaction) -> some View {
        let assetKey = getAssetKey(item)
        return document.getBackgroundFill(assetKey)
    }
    
    
    // MARK: - Properties
    
    private var ax: WorthContext {
        document.context
    }
    
    private var ds: DisplaySettings {
        document.displaySettings
    }
    
    // MARK: - Actions
    
    private func checkAction(_ txns: [MTransaction], _ nuValue: Bool) {
        txns.forEach { txn in
            //let txn = orderedTxns[n]
            let key = txn.primaryKey
            document.displaySettings.pendingExcludedTxnMap[key] = nuValue
        }
        
        document.refreshWorthResult(timeZoneID: timeZoneID) // refresh PendingSnapshot
    }
    
    private func isCheckedAction(_ txn: MTransaction) -> Bool {
        //let txn = orderedTxns[n]
        let key = txn.primaryKey
        return document.displaySettings.pendingExcludedTxnMap[key] ?? false
    }
    
    private func headerCheckAction() {
        if document.displaySettings.pendingExcludedTxnMap.first(where: { $0.value }) != nil {
            document.displaySettings.pendingExcludedTxnMap.removeAll()
        } else {
            document.model.transactions.forEach {
                document.displaySettings.pendingExcludedTxnMap[$0.primaryKey] = true
            }
        }
    }
    
    // MARK: - Helpers
    
    private func formattedDate(_ date: Date?) -> String {
        guard let _date = date else { return "unknown" }
        return BuilderTxnTable.dfShort.string(from: _date)
    }
    
    private func getAssetKey(_ item: MTransaction) -> AssetKey {
        item.getAssetKey(securityMap: ax.securityMap) ?? MAsset.cashAssetKey
    }
    
    private func getColorCode(_ assetKey: AssetKey) -> ColorPair {
        document.assetColorMap[assetKey] ?? (Color.primary, Color.clear)
    }
}
