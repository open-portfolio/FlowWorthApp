//
//  AccountSummaryTable.swift
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

public struct AccountSummaryTable: View {
    @Binding var document: WorthDocument
    @ObservedObject var psum: PeriodSummary

    public var body: some View {
        switch document.displaySettings.periodSummarySelection {
        case .deltaMarketValue:
            AccountDeltaSummaryTable(document: $document, tableData: tableData0)
        case .deltaTotalBasis:
            AccountBasisSummaryTable(document: $document, tableData: tableData1)
        case .modifiedDietz:
            AccountDietzSummaryTable(document: $document, tableData: tableData2)
        }
    }
    
    // convert matrix to the idiosyncratic data format required by this table
    private var tableData0: [AccountDeltaSummaryTable.TableRow] {
        psum.accountKeySet.sorted().reduce(into: []) { array, accountKey in
            let begMV = psum.begAccountMV[accountKey] ?? 0
            let endMV = psum.endAccountMV[accountKey] ?? 0
            let deltaMV = endMV - begMV
            let deltaPercent: Double? = begMV > 0 ? deltaMV / begMV : nil
            array.append(.init(accountKey: accountKey, begMV: begMV, endMV: endMV, deltaMV: deltaMV, deltaPercent: deltaPercent))
        }
    }

    // convert matrix to the idiosyncratic data format required by this table
    private var tableData1: [AccountBasisSummaryTable.TableRow] {
        psum.accountKeySet.sorted().reduce(into: []) { array, accountKey in
            let begTB = psum.begAccountTB[accountKey] ?? 0
            let endTB = psum.endAccountTB[accountKey] ?? 0
            let deltaTB = endTB - begTB
            let deltaPercent: Double? = begTB > 0 ? deltaTB / begTB : nil
            array.append(.init(accountKey: accountKey, begTB: begTB, endTB: endTB, deltaTB: deltaTB, deltaPercent: deltaPercent))
        }
    }

    private var tableData2: [AccountDietzSummaryTable.TableRow] {
        psum.accountKeySet.sorted().reduce(into: []) { array, accountKey in
            let md = psum.accountDietz[accountKey]
            array.append(.init(accountKey: accountKey,
                               gainLoss: md?.gainOrLoss ?? 0,
                               performance: md?.performance ?? 0,
                               netCashflowTotal: md?.netCashflowTotal ?? 0,
                               adjustedNetCashflow: md?.adjustedNetCashflow ?? 0))
        }
    }
    
 
}
