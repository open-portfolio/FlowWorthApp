//
//  DietzSecondary.swift
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

struct DietzSecondary: View {
    @Binding var document: WorthDocument
    @ObservedObject var mr: MatrixResult
    
    let expositoryText = """
    The performance of your assets, independent of cash flows.
    """
    
    var body: some View {
        VStack(spacing: 20) {
            HStack(alignment: .top) {
                Text(expositoryText.replacingOccurrences(of: "\n", with: " "))
                    .font(.callout)
                    .foregroundColor(.secondary)
                
                HelpButton(appName: "worth", topicName: "inspectDietz")
            }
            
            StatsBoxView(title: "Performance (based on ‘Modified Dietz’ method)") {
                HStack {
                    StatusDisplay(title:  "\(WorthDocument.rSymbol) (period)",
                                  value: periodPerformance,
                                  format: { "\(Double($0).toPercent1(leadingPlus: true))" },
                                  textStyle: .title,
                                  enabled: hasCashflow)
                    StatusDisplay(title: "\(WorthDocument.rSymbol) (annualized)",
                                  value: annualizedPerformance,
                                  format: { "\(Double($0).toPercent1(leadingPlus: true))" },
                                  textStyle: .title,
                                  enabled: hasCashflow)
                }
            }
            .frame(maxHeight: 85)

            StatsBoxView(title: "Gain (loss)") {
                HStack {
                    StatusDisplay(title: "Net (period)",
                                  value: periodGain,
                                  format: { "\(Double($0).toCurrency(style: .compact, leadingPlus: true))" },
                                  enabled: hasCashflow)
                    StatusDisplay(title: "Daily (averaged)",
                                  value: gainPerDay,
                                  format: { "\(Double($0).toCurrency(style: .compact, leadingPlus: true))/day" },
                                  enabled: hasCashflow)
                    StatusDisplay(title: "Annualized",
                                  value: gainPerYear,
                                  format: { "\(Double($0).toCurrency(style: .compact, leadingPlus: true))/yr" },
                                  enabled: hasCashflow)
                }
            }
            .frame(maxHeight: 80)
            
            StatsBoxView(title: "Cash Flow") {
                HStack {
                    StatusDisplay(title: "Net (period)",
                                  value: periodNetCashflow,
                                  format: { "\(Double($0).toCurrency(style: .compact, leadingPlus: true))" },
                                  enabled: hasCashflow)
                    StatusDisplay(title: "Daily (averaged)",
                                  value: cashflowPerDay,
                                  format: { "\(Double($0).toCurrency(style: .compact, leadingPlus: true))/day" },
                                  enabled: hasCashflow)
                    StatusDisplay(title: "Annualized",
                                  value: cashflowPerYear,
                                  format: { "\(Double($0).toCurrency(style: .compact, leadingPlus: true))/yr" },
                                  enabled: hasCashflow)
                }
            }
            .frame(maxHeight: 80)

            StatsBoxView(title: "Snapshot Performance") {
                DietzSnapshotTable(document: $document, mr: mr)
            }
        }
        .padding(.vertical)
        .padding(.horizontal, 3)
    }

    private var hasCashflow: Bool {
        mr.hasCashflow
    }
    
    private var periodPerformance: Double {
        mr.periodSummary?.dietz!.performance ?? 0
    }
    
    private var annualizedPerformance: Double {
        (mr.periodSummary?.dietz!.performance ?? 0) / (mr.periodSummary?.yearsInPeriod ?? 0)
    }
    
    private var periodNetCashflow: Double {
        guard let md = mr.periodSummary?.dietz else { return 0 }
        return md.netCashflowTotal
    }
    
    private var daysInPeriod: Double {
        mr.periodDuration / 86400
    }
    
    private var cashflowPerDay: Double {
        periodNetCashflow / daysInPeriod
    }
    
    private var cashflowPerYear: Double {
        cashflowPerDay * 365.25
    }
    
    private var marketValueDelta: Double {
        guard let md = mr.periodSummary?.dietz else { return 0 }
        return md.marketValue.end - md.marketValue.start
    }
    
    private var periodGain: Double {
        marketValueDelta - periodNetCashflow
    }
    
    private var gainPerDay: Double {
        periodGain / daysInPeriod
    }
    
    private var gainPerYear: Double {
        gainPerDay * 365.25
    }
}
