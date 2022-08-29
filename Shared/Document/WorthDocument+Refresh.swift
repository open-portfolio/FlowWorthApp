//
//  WorthDocument+Refresh.swift
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

// MARK: - Dependency-based refresh routines
extension WorthDocument {
    
    mutating func commitBuilderData(infoMessageStore: InfoMessageStore, timeZoneID: String) {
        do {
            let nuTransactionKeys = pendingSnapshot.transactionKeys
            
            try model.commitPendingSnapshot(pendingSnapshot)
        
            self.displaySettings.pendingExcludedTxnMap.removeAll()

            // The committed history items (which became the cashflow) become the new exclusion list!
            nuTransactionKeys.forEach {
                self.displaySettings.pendingExcludedTxnMap[$0] = true
            }
            
            let dfShort: DateFormatter = {
                let df = DateFormatter()
                df.dateStyle = .short
                df.timeStyle = .short
                return df
            }()
            let formattedTimestamp = dfShort.string(from: pendingSnapshot.snapshot.capturedAt)
            
            infoMessageStore.add("Created snapshot #\(model.valuationSnapshots.count) at time stamp ‘\(formattedTimestamp)’", modelID: self.model.id)
            infoMessageStore.add("Ready to build next snapshot!", modelID: self.model.id)
            
            clearBuilderDataAndRefresh(timeZoneID: timeZoneID)
            
        } catch let error as WorthError {
            infoMessageStore.add(error.description, modelID: self.model.id)
        } catch {
            infoMessageStore.add(error.localizedDescription, modelID: self.model.id)
        }
    }
    
    mutating func clearBuilderDataAndRefresh(timeZoneID: String) {
        //log.info("\(#function) ENTER"); defer { //log.info("\(#function) EXIT") }
        model.clearBuilderDataFromModel()

        self.refreshContext(timeZoneID: timeZoneID)
    }
    
    // refresh the result, without refreshing context (if not needed)
    mutating func refreshWorthResult(timeZoneID: String) {  //investorEntitlement: Bool
        log.info("\(#function) ENTER"); defer { log.info("\(#function) EXIT") }
        
        let ds = self.displaySettings
        
        let timeZone = TimeZone(identifier: timeZoneID) ?? TimeZone.current
        
        if let begSnapshotKey = ds.begSnapshotKey.isValid ? ds.begSnapshotKey : context.firstSnapshotKey,
           let endSnapshotKey = ds.endSnapshotKey.isValid ? ds.endSnapshotKey : context.lastSnapshotKey {
            self.mrCache = MatrixResultCache(ax: context,
                                             begSnapshotKey: begSnapshotKey,
                                             endSnapshotKey: endSnapshotKey,
                                             excludedAccountMap: ds.excludedAccountMap,
                                             orderedAssetKeys: ds.orderedAssetKeys,
                                             trackPerformance: ds.periodSummarySelection.isDietz,
                                             timeZone: timeZone)
        } else {
            self.mrCache = MatrixResultCache(ax: context, timeZone: timeZone)
        }
        
        let userExcludedTxnKeys = ds.pendingExcludedTxnMap.filter { $0.value }.map(\.key)
        
        // NOTE if not refreshing properly, ensure that we're not being called through a notification
        self.pendingSnapshot = PendingSnapshot(timestamp: self.displaySettings.builderCapturedAt,
                                               holdings: model.holdings,
                                               transactions: model.transactions,
                                               previousSnapshot: context.lastSnapshot,
                                               previousPositions: context.lastSnapshotPositions,
                                               previousCashflows: context.lastSnapshotCashflows,
                                               userExcludedTxnKeys: userExcludedTxnKeys,
                                               accountMap: context.accountMap,
                                               assetMap: context.assetMap,
                                               securityMap: context.securityMap,
                                               timeZone: timeZone)
    }
    
    
    // refresh context, even if valid
    mutating func refreshContext(timeZoneID: String) {
        log.info("\(#function) ENTER"); defer { log.info("\(#function) EXIT") }
        
        let timeZone = TimeZone(identifier: timeZoneID) ?? TimeZone.current
        
        let strategyKey: StrategyKey = modelSettings.activeStrategyKey
        let timestamp = Date()
        let ax = WorthContext(model,
                              modelSettings,
                              strategyKey: strategyKey,
                              timestamp: timestamp,
                              timeZone: timeZone)
        
        self.context = ax
        
        self.refreshWorthResult(timeZoneID: timeZoneID) // also resets mrCache & pendingSnapshot
        
        // rebuild SwiftUI-dependent context (that we're storing in document object)
        let colorCodeMap = MAsset.getColorCodeMap(model.assets)
        self.assetColorMap = getAssetColorMap(colorCodeMap: colorCodeMap)
    }
}
