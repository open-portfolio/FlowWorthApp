//
//  DeltaSecondary.swift
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

struct DeltaSecondary: View {
    @Binding var document: WorthDocument
    @ObservedObject var mr: MatrixResult
    
    let expositoryText = """
    The value of your assets over time, net of cash flows.
    """

    var body: some View {
        VStack(spacing: 20) {
            
            HStack(alignment: .top) {
                Text(expositoryText.replacingOccurrences(of: "\n", with: " "))
                    .font(.callout)
                    .foregroundColor(.secondary)
                
                HelpButton(appName: "worth", topicName: "inspectDelta")
            }
            
            StatsBoxView(title: "Performance (based on period start and end)") {
                HStack {
                    StatusDisplay(title:  "\(WorthDocument.deltaPercentSymbol) (period)",
                                  value: mr.periodSummary?.singlePeriodReturn ?? 0,
                                  format: { "\(Double($0).toPercent1(leadingPlus: true))" },
                                  textStyle: .title,
                                  enabled: mr.periodSummary?.singlePeriodReturn != nil)
                    StatusDisplay(title:  "\(WorthDocument.deltaPercentSymbol) (annualized)",
                                  value: mr.periodSummary?.annualizedPeriodReturn ?? 0,
                                  format: { "\(Double($0).toPercent1(leadingPlus: true))" },
                                  textStyle: .title,
                                  enabled: mr.periodSummary?.annualizedPeriodReturn != nil)
                }
                .frame(maxHeight: 55)
                .padding(.bottom, 5)
                
                HStack {
                    StatusDisplay(title: "\(WorthDocument.deltaSymbol) (period)",
                                  value: mr.periodSummary?.deltaMarketValue ?? 0,
                                  format: { "\(Double($0).toCurrency(style: .compact, leadingPlus: true))" })
                    StatusDisplay(title: "\(WorthDocument.deltaSymbol) (daily, averaged)",
                                  value: mr.periodSummary?.marketValueDeltaPerDay ?? 0,
                                  format: { "\(Double($0).toCurrency(style: .compact, leadingPlus: true))/day" })
                    StatusDisplay(title: "\(WorthDocument.deltaSymbol) (annualized)",
                                  value: mr.periodSummary?.marketValueDeltaPerYear ?? 0,
                                  format: { "\(Double($0).toCurrency(style: .compact, leadingPlus: true))/yr" })
                }
                .frame(maxHeight: 50)
            }
            
            StatsBoxView(title: "Snapshot Performance") {
                DeltaSnapshotTable(document: $document, mr: mr)
            }
        }
        .padding(.vertical)
        .padding(.horizontal, 3)
    }
}
