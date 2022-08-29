//
//  StrategySummaryTable.swift
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

public struct StrategySummaryTable: View {
    @Binding var document: WorthDocument
    @ObservedObject var psum: PeriodSummary

    public var body: some View {
        switch document.displaySettings.periodSummarySelection {
        case .deltaMarketValue:
            StrategyDeltaSummaryTable(document: $document, tableData: tableData0)
        case .deltaTotalBasis:
            StrategyBasisSummaryTable(document: $document, tableData: tableData1)
        case .modifiedDietz:
            StrategyDietzSummaryTable(document: $document, tableData: tableData2)
        }
    }
    
    // convert matrix to the idiosyncratic data format required by this table
    private var tableData0: [StrategyDeltaSummaryTable.TableRow] {
        psum.strategyKeySet.sorted().reduce(into: []) { array, strategyKey in
            let begMV = psum.begStrategyMV[strategyKey] ?? 0
            let endMV = psum.endStrategyMV[strategyKey] ?? 0
            let deltaMV = endMV - begMV
            let deltaPercent: Double? = begMV > 0 ? deltaMV / begMV : nil
            array.append(.init(strategyKey: strategyKey, begMV: begMV, endMV: endMV, deltaMV: deltaMV, deltaPercent: deltaPercent))
        }
    }

    // convert matrix to the idiosyncratic data format required by this table
    private var tableData1: [StrategyBasisSummaryTable.TableRow] {
        psum.strategyKeySet.sorted().reduce(into: []) { array, strategyKey in
            let begTB = psum.begStrategyTB[strategyKey] ?? 0
            let endTB = psum.endStrategyTB[strategyKey] ?? 0
            let deltaTB = endTB - begTB
            let deltaPercent: Double? = begTB > 0 ? deltaTB / begTB : nil
            array.append(.init(strategyKey: strategyKey, begTB: begTB, endTB: endTB, deltaTB: deltaTB, deltaPercent: deltaPercent))
        }
    }
    
    // convert matrix to the idiosyncratic data format required by this table
    private var tableData2: [StrategyDietzSummaryTable.TableRow] {
        psum.strategyKeySet.sorted().reduce(into: []) { array, strategyKey in
            let md = psum.strategyDietz[strategyKey]
            array.append(.init(strategyKey: strategyKey,
                               gainLoss: md?.gainOrLoss ?? 0,
                               performance: md?.performance ?? 0,
                               netCashflowTotal: md?.netCashflowTotal ?? 0,
                               adjustedNetCashflow: md?.adjustedNetCashflow ?? 0))
        }
    }
}
