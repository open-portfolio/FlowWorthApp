//
//  SummaryFooter.swift
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
import FlowWorthLib
import FlowUI

struct SummaryFooter: View {
    @Binding var document: WorthDocument
    var positions: [MValuationPosition]
    var cashflows: [MValuationCashflow]
    
    private static let dfShort: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .short
        df.timeStyle = .short
        return df
    }()

    var body: some View {
        HStack(spacing: 10) {
            
            StatsBoxView(title: "Assets") {
                StatusDisplay(title: nil,
                              value: assetCount,
                              format: { String($0) })
                    .foregroundColor(assetCount > 0 ? .primary : .secondary)
            }
            .frame(maxWidth: 90)
            
            StatsBoxView(title: "Accounts") {
                StatusDisplay(title: nil,
                              value: accountCount,
                              format: { String($0) })
                    .foregroundColor(accountCount > 0 ? .primary : .secondary)
            }
            .frame(maxWidth: 90)
            
            StatsBoxView(title: "Positions (market value)") {
                StatusDisplay(title: nil,
                              value: marketvalueFormatted,
                              format: { $0 })
                    .foregroundColor(positions.count > 0 ? .primary : .secondary)
            }
            
            StatsBoxView(title: "Positions (basis)") {
                StatusDisplay(title: nil,
                              value: basisFormatted,
                              format: { $0 })
                    .foregroundColor(positions.count > 0 ? .primary : .secondary)
            }

            StatsBoxView(title: "Cash Flow (net)") {
                StatusDisplay(title: nil,
                              value: netCashflowFormatted,
                              format: { $0 })
                    .foregroundColor(cashflows.count > 0 ? .primary : .secondary)
            }
        }
    }
    
    // MARK: - Properties
    
    private var ax: WorthContext {
        document.context
    }
    
    private var marketvalueFormatted: String {
        guard positions.count > 0 else { return "None" }
        let sum = positions.reduce(0) { $0 + $1.marketValue }
        return "\(positions.count) @ \(sum.toCurrency(style: .compact))"
    }
    
    private var basisFormatted: String {
        guard positions.count > 0 else { return "None" }
        let sum = positions.reduce(0) { $0 + $1.totalBasis }
        return "\(positions.count) @ \(sum.toCurrency(style: .compact))"
    }

    private var assetCount: Int {
        let assetKeySet: Set<AssetKey> = positions.reduce(into: Set()) { $0.insert($1.assetKey) }
        return assetKeySet.count
    }
    
    private var accountCount: Int {
        let accountKeySet: Set<AccountKey> = positions.reduce(into: Set()) { $0.insert($1.accountKey) }
        return accountKeySet.count
    }
    
    private var netCashflowFormatted: String {
        guard cashflows.count > 0 else { return "None" }
        let sum = cashflows.reduce(0) { $0 + $1.amount }
        return "\(cashflows.count) @ \(sum.toCurrency(style: .compact))"
    }
}

