//
//  ForecastSecondary.swift
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

struct ForecastSecondary: View {

    @Binding var document: WorthDocument
    @ObservedObject var fr: ForecastResult
    
    let expositoryText = """
    Forecasting the future value of your assets, net of cash flows.
    """
    
    var body: some View {
        VStack {
            
            // it's net of cash flows, like delta
            HStack(alignment: .top) {
                Text(expositoryText.replacingOccurrences(of: "\n", with: " "))
                    .font(.callout)
                    .foregroundColor(.secondary)
                
                HelpButton(appName: "worth", topicName: "inspectForecast")
            }
            
            StatsBoxView(title: "Performance (based on regression line)") {
                HStack {
                    StatusDisplay(title: "\(WorthDocument.deltaPercentSymbol) (period)",
                                  value: singlePeriodReturn,
                                  format: { "\(Double($0).toPercent1(leadingPlus: true))" },
                                  textStyle: .title)
                    StatusDisplay(title: "\(WorthDocument.deltaPercentSymbol) (annualized)",
                                  value: annualizedReturn,
                                  format: { "\(Double($0).toPercent1(leadingPlus: true))" },
                                  textStyle: .title)
                }
                .frame(maxHeight: 55)
                .padding(.bottom, 5)
                
                HStack {
                    StatusDisplay(title: "\(WorthDocument.deltaSymbol) (period)",
                                  value: periodGain,
                                  format: { "\(Double($0).toCurrency(style: .compact, leadingPlus: true))" })
                    StatusDisplay(title: "\(WorthDocument.deltaSymbol) (daily, averaged)",
                                  value: gainPerDay,
                                  format: { "\(Double($0).toCurrency(style: .compact, leadingPlus: true))/day" })
                    StatusDisplay(title: "\(WorthDocument.deltaSymbol) (annualized)",
                                  value: gainPerYear,
                                  format: { "\(Double($0).toCurrency(style: .compact, leadingPlus: true))/yr" })
                }
                .frame(maxHeight: 50)
            }
            
            VStack {
                StatsBoxView(title: "Forecasted Values*") {
                    ForecastTable(document: $document, fr: fr)
                    //.frame(maxHeight: .infinity)
                    
                }
                HStack { Spacer(); Text("*past performance is no guarantee of future results").font(.footnote) }
            }
            
            StatsBoxView(title: "Regression Line") {
                Text(formattedFormula)
                    .font(.system(.title3, design: .monospaced))
                    .padding(.bottom, 3)
                Text("…where ‘d’ is number of days since the first snapshot.")
                    .font(.footnote)
            }
            
            Spacer(minLength: 0)
        }
        .padding(.vertical)
        .padding(.horizontal, 3)
    }
    
    // MARK: - Properties
    
    private var formattedFormula: String {
        guard let lr = fr.lr else { return "n/a" }
        let slopeInDays = lr.slope * 86400
        guard slopeInDays != 0 else { return "(unavailable)" }
        let m = String(format: "%.1f", slopeInDays)
        let b = String(format: "%.0f", lr.intercept)
        return "marketvalue = d × \(m) + \(b)"
    }
    
    private var periodGain: Double {
        guard let lr = fr.lr else { return 0 }
        return lr.slope * fr.mainDuration
    }
    
    private var singlePeriodReturn: Double {
        guard let lr = fr.lr else { return 0 }
        return periodGain / lr.intercept
    }
    
    private var annualizedReturn: Double {
        singlePeriodReturn / fr.yearsInMainPeriod
    }
    
    private var gainPerDay: Double {
        periodGain / fr.daysInMainPeriod
    }
    
    private var gainPerYear: Double {
        365.25 * gainPerDay
    }
}
