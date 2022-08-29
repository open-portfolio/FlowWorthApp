//
//  AssetSummaryTable.swift
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

public struct AssetSummaryTable: View {
    @Binding var document: WorthDocument
    @ObservedObject var psum: PeriodSummary
 
    public var body: some View {
        switch document.displaySettings.periodSummarySelection {
        case .deltaMarketValue:
            AssetDeltaSummaryTable(document: $document, tableData: tableData0)
        case .deltaTotalBasis:
            AssetBasisSummaryTable(document: $document, tableData: tableData1)
        case .modifiedDietz:
            AssetDietzSummaryTable(document: $document, tableData: tableData2)
        }
    }
    
    // convert matrix to the idiosyncratic data format required by this table
    private var tableData0: [AssetDeltaSummaryTable.TableRow] {
        psum.assetKeySet.sorted().reduce(into: []) { array, assetKey in
            let begMV = psum.begAssetMV[assetKey] ?? 0
            let endMV = psum.endAssetMV[assetKey] ?? 0
            let deltaMV = endMV - begMV
            let deltaPercent: Double? = begMV > 0 ? deltaMV / begMV : nil
            array.append(.init(assetKey: assetKey, begMV: begMV, endMV: endMV, deltaMV: deltaMV, deltaPercent: deltaPercent))
        }
    }

    // convert matrix to the idiosyncratic data format required by this table
    private var tableData1: [AssetBasisSummaryTable.TableRow] {
        psum.assetKeySet.sorted().reduce(into: []) { array, assetKey in
            let begTB = psum.begAssetTB[assetKey] ?? 0
            let endTB = psum.endAssetTB[assetKey] ?? 0
            let deltaTB = endTB - begTB
            let deltaPercent: Double? = begTB > 0 ? deltaTB / begTB : nil
            array.append(.init(assetKey: assetKey, begTB: begTB, endTB: endTB, deltaTB: deltaTB, deltaPercent: deltaPercent))
        }
    }

    // convert matrix to the idiosyncratic data format required by this table
    private var tableData2: [AssetDietzSummaryTable.TableRow] {
        psum.assetKeySet.sorted().reduce(into: []) { array, assetKey in
            let md = psum.assetDietz[assetKey]
            array.append(.init(assetKey: assetKey,
                               gainLoss: md?.gainOrLoss ?? 0,
                               performance: md?.performance ?? 0,
                               netCashflowTotal: md?.netCashflowTotal ?? 0,
                               adjustedNetCashflow: md?.adjustedNetCashflow ?? 0))
        }
    }
}
