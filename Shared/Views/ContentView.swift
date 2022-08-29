//
//  ContentView.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

import AllocData

import FlowUI
import FlowBase
import FlowWorthLib

// smallest is 1024 x 600
let minAppWidth: CGFloat = 1200  // NOTE may cause crash (when clicking on birdseye) if narrower than this
let minAppHeight: CGFloat = 695 // 640 normally // use 695 to generate 1280x790 screenshots
let idealAppWidth: CGFloat = 1440
let idealAppHeight: CGFloat = 800
let minSidebarWidth: CGFloat = 230

let baseModelEntities: [SidebarMenuIDs] = [
    .modelStrategies,
    .modelAccounts,
    .modelAssets,
    .modelSecurities,
    .modelHoldings,
    .modelTxns,
]

struct ContentView: View {
    @AppStorage(UserDefShared.userAgreedTermsAt.rawValue) var userAgreedTermsAt: String = ""
    @AppStorage(UserDefShared.timeZoneID.rawValue) var timeZoneID: String = ""
    @AppStorage(UserDefShared.defTimeOfDay.rawValue) var defTimeOfDay: TimeOfDayPicker.Vals = .useDefault
    
    @EnvironmentObject private var infoMessageStore: InfoMessageStore
    @Environment(\.undoManager) var undoManager
    
    @Binding var document: WorthDocument
    
    // MARK: - Locals
    
    static let utiImportFile = "public.file-url"
    
    @State private var dragOver = false
    @State private var dropDelegate = URLDropDelegate(utiImportFile: ContentView.utiImportFile, milliseconds: 250) //750)
    
    // Shared
    private let checkTermsPublisher = NotificationCenter.default.publisher(for: .checkTerms)
    private let importURLsPublisher = NotificationCenter.default.publisher(for: .importURLs) // uses ImportPayload
    private let refreshContextPublisher = NotificationCenter.default.publisher(for: .refreshContext)
    private let infoMessagePublisher = NotificationCenter.default.publisher(for: .infoMessage) // uses InfoMessagePayload
    
    // Worth-specific
    private let refreshResultPublisher = NotificationCenter.default.publisher(for: .refreshWorthResult)
    private let commitBuilderPublisher = NotificationCenter.default.publisher(for: .commitBuilder)
    private let clearBuilderPublisher = NotificationCenter.default.publisher(for: .clearBuilder)
    
    var body: some View {
        if infoMessageStore.hasMessages(modelID: document.model.id) {
            InfoBanner(modelID: document.model.id, accent: document.accent)
                .frame(minHeight: 120, idealHeight: 250)
                .padding(.horizontal, 40)
        }
        
        NavigationView {
            SidebarView(topContent: topSidebarContent,
                        bottomContent: dataModelSection,
                        tradingHoldingsSummary: tradingAccountsSummary,
                        nonTradingHoldingsSummary: nontradingAccountsSummary,
                        strategySummary: { _ in strategyAccountsSummary },
                        accountSummary: accountSummary,
                        model: $document.model,
                        ax: document.context,
                        fill: document.accentFill,
                        assetColorMap: document.assetColorMap,
                        activeStrategyKey: $document.modelSettings.activeStrategyKey,
                        activeSidebarMenuKey: $document.displaySettings.activeSidebarMenuKey,
                        strategyAssetValues: strategyAssetValues,
                        fetchAssetValues: getAccountAssetValues)
                
                // to provide access to key document in sidebar
                .keyWindow(WorthDocument.self, $document)
                .frame(minWidth: minSidebarWidth, idealWidth: 250, maxWidth: 300)
            
            WelcomeView() {
                GettingStarted(document: $document)
            }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(windowBackgroundColor)            
        }
        .navigationViewStyle(DoubleColumnNavigationViewStyle())
        .toolbar {
            ToolbarItem(placement: .navigation) { SidebarToggleButton() }
        }
        .modify {
            #if os(macOS)
            $0
                //.navigationSubtitle(quotedTitle)
                .frame(minWidth: minAppWidth,
                       idealWidth: idealAppWidth,
                       maxWidth: .infinity,
                       minHeight: minAppHeight,
                       idealHeight: idealAppHeight,
                       maxHeight: .infinity)
            #else
            $0
            #endif
        }
        
        // drag and drop related handlers
        .border(dragOver ? document.accent : Color.clear)
        .onDrop(of: [ContentView.utiImportFile], delegate: dropDelegate)
        .onReceive(dropDelegate.debouncedURLs.didChange) {
            guard dropDelegate.debouncedURLs.value.count > 0 else { return }
            let urls = dropDelegate.purge()
            importAction(urls: urls)
        }
        
        .onReceive(importURLsPublisher) { payload in
            
            // import, but only for current document
            if let importPayLoad = payload.object as? ImportPayload,
               importPayLoad.modelID == document.model.id,
               importPayLoad.urls.count > 0
            {
                importAction(urls: importPayLoad.urls)
            }
        }
        .onReceive(refreshContextPublisher) { payload in
            
            // refresh, but only for current document
            if let modelID = payload.object as? UUID,
               modelID == document.model.id
            {
                refreshContextAction()
            }
        }
        .onReceive(infoMessagePublisher) { payload in
            if let msgPayload = payload.object as? InfoMessagePayload,
               msgPayload.modelID == document.model.id,
               msgPayload.messages.count > 0
            {
                infoMessageStore.add(contentsOf: msgPayload.messages, modelID: document.model.id)
            }
        }
        .onReceive(refreshResultPublisher) { payload in
            // refresh, but only for current document
            if let modelID = payload.object as? UUID,
               modelID == document.model.id
            {
                refreshResultAction()
            }
        }
        .onReceive(commitBuilderPublisher) { payload in
            // refresh, but only for current document
            if let modelID = payload.object as? UUID,
               modelID == document.model.id
            {
                document.commitBuilderData(infoMessageStore: infoMessageStore, timeZoneID: timeZoneID)
            }
        }
        .onReceive(clearBuilderPublisher) { payload in
            // refresh, but only for current document
            if let modelID = payload.object as? UUID,
               modelID == document.model.id
            {
                document.clearBuilderDataAndRefresh(timeZoneID: timeZoneID)
            }
        }
        .onChange(of: document.model) { _ in
            //print("ContentView: detected MODEL change -- forcing refresh of context")
            guard userAcknowledgedTerms else { return }
            refreshContextAction()
        }
        .onChange(of: document.modelSettings) { _ in
            //print("ContentView: detected MODEL SETTINGS change -- forcing refresh of context")
            guard userAcknowledgedTerms else { return }
            refreshContextAction()
        }
        .onAppear {
            guard userAcknowledgedTerms else { return }
            refreshContextAction()
        }
        
        BaseSheets()
    }
    
    var topSidebarContent: some View {
        WorthSidebar(document: $document, mrBirdsEye: mrBirdsEye, isEmpty: isEmpty)
    }
    
    var strategyAccountsSummary: some View {
        BaseReturnsSummary(document: $document,
                           title: "‘\(strategyTitle)’ Returns",
                           mr: mrStrategy)
    }
    
    var tradingAccountsSummary: some View {
        BaseReturnsSummary(document: $document,
                           title: "Trading Accounts Returns",
                           mr: mrStrategyTrading)
    }
    
    var nontradingAccountsSummary: some View {
        BaseReturnsSummary(document: $document,
                           title: "Non-trading Accounts Returns",
                           mr: mrStrategyNonTrading)
    }
    
    private func accountSummary(account: MAccount) -> some View {
        AccountSummary(document: $document,
                       account: account)
    }
    
    private var windowBackgroundColor: Color {
        #if os(macOS)
        Color(.windowBackgroundColor)
        #else
        Color.secondary
        #endif
    }
    
    // MARK: - Data Model Helper Views
    
    private var dataModelSection: some View {
        SidebarDataModelSection(model: $document.model,
                                ax: ax,
                                activeSidebarMenuKey: $document.displaySettings.activeSidebarMenuKey,
                                baseModelEntities: baseModelEntities,
                                fill: document.accentFill,
                                warningCounts: warningCounts,
                                showGainLoss: false,
                                warnMissingSharePrice: true,
                                auxTableViewInfos: auxTableViewInfos)
    }
    
    private var auxTableViewInfos: [DataModelViewInfo] {
        [
            DataModelViewInfo(id: WorthSidebarMenuIDs.modelValuationSnapshots.rawValue,
                              tableView: ValuationSnapshotTable(model: $document.model, ax: ax).eraseToAnyView(),
                              title: WorthSidebarMenuIDs.modelValuationSnapshots.title,
                              count: document.model.valuationSnapshots.count),
            
            DataModelViewInfo(id: WorthSidebarMenuIDs.modelValuationPositions.rawValue,
                              tableView: ValuationPositionTable(model: $document.model, ax: ax, snapshot: nil, account: nil).eraseToAnyView(),
                              title: WorthSidebarMenuIDs.modelValuationPositions.title,
                              count: document.model.valuationPositions.count),
            
            DataModelViewInfo(id: WorthSidebarMenuIDs.modelValuationCashflow.rawValue,
                              tableView: ValuationCashflowTable(model: $document.model, ax: ax, account: nil).eraseToAnyView(),
                              title: WorthSidebarMenuIDs.modelValuationCashflow.title,
                              count: document.model.valuationCashflows.count)
        ]
    }
    
    private var warningCounts: [String: Int] {  // [MenuID: Int]
        var map = [String: Int]()
        if case let count = ax.activeTickersMissingSomething.count,
            count > 0 {
            map[SidebarMenuIDs.modelSecurities.rawValue] = count
        }
        if case let count = ax.missingSharePriceTxns.count,
           count > 0 {
            map[SidebarMenuIDs.modelTxns.rawValue] = count
        }
        return map
    }

    // MARK: - Properties
        
    private var ax: WorthContext {
        document.context
    }
    
    private var ds: DisplaySettings {
        document.displaySettings
    }
    
    private var isEmpty: Bool {
        mrBirdsEye.snapshotKeySet.count < 2
    }
    
    private var userAcknowledgedTerms: Bool {
        userAgreedTermsAt.trimmingCharacters(in: .whitespaces).count > 0
    }

    // MARK: - Strategy Helpers
    
    private var strategyKey: StrategyKey {
        document.modelSettings.activeStrategyKey
    }
    
    private var strategyTitle: String {
        ax.strategyMap[strategyKey]?.titleID ?? "Active Strategy"
    }
    
    private var strategyAssetValues: [AssetValue] {
        var assetValues = mrStrategy.endAssetValuesUnit
        if assetValues.count == 0 {
            assetValues = ax.strategyAssetValuesMap[strategyKey] ?? []
        }
        return assetValues.sorted()
    }
    
    // MARK: - Account Helpers
    
    private func getAccountAssetValues(_ accountKey: AccountKey) -> [AssetValue] {
        let accountMR = mrAccount(accountKey)
        return accountMR.endAssetValuesUnit.sorted()
    }
    
    // MARK: - Matrix Result Helpers
    
    private var mrBirdsEye: MatrixResult {
        let mr2 = document.mrCache.mrBirdsEye
        return mr2
    }
    
    // SINGLE strategy
    private var mrStrategy: MatrixResult {
        let mr2 = document.mrCache.getStrategyMR(strategyKey)
        return mr2
    }
    
    private var mrStrategyTrading: MatrixResult {
        let mr2 = document.mrCache.getStrategyTradingMR(strategyKey)
        return mr2
    }

    private var mrStrategyNonTrading: MatrixResult {
        let mr2 = document.mrCache.getStrategyNonTradingMR(strategyKey)
        return mr2
    }
    
    private func mrAccount(_ accountKey: AccountKey) -> MatrixResult {
        let mr2 = document.mrCache.getAccountMR(accountKey)
        return mr2
    }
    
    // MARK: - Actions
    
    private func refreshContextAction() {
        document.refreshContext(timeZoneID: timeZoneID)
    }

    private func refreshResultAction() {
        document.refreshWorthResult(timeZoneID: timeZoneID)
    }

    private func importAction(urls: [URL]) {
        guard urls.count > 0 else { return }
        //log.info("\(#function) ENTER urls=\(urls)"); defer { log.info("\(#function) EXIT") }

        let timeZone = TimeZone(identifier: timeZoneID) ?? TimeZone.current
        let normTimeOfDay: String? = BaseModel.normalizeTimeOfDay(defTimeOfDay.rawValue)
        let results = document.model.importData(urls: urls, timeZone: timeZone, defTimeOfDay: normTimeOfDay)
        
        // if holdings imported, get the exportedAt from metadata, or file creation date (okay if nil)
        if let holdingsResult = results.first(where: { $0.allocSchema == .allocHolding }) {
            
            if let nuDate = holdingsResult.exportedAt ?? getFileCreationDate(holdingsResult.url) {
                
                let clampedDate: Date = {
                    if let latestCapturedAt = ax.lastSnapshotCapturedAt {
                        let lowerBound = latestCapturedAt.addingTimeInterval(86400)
                        if nuDate < lowerBound { return lowerBound }
                    }
                    return nuDate
                }()

                document.displaySettings.builderCapturedAt = clampedDate
            }
        }
        
        if let _ = results.first(where: { $0.allocSchema == .allocTransaction }) {
            // assume the user wishes to track performance
            
            // if previous snapshot, add exclusions to ds.pendingExcludedTxnMap
            let excludeKeys: [TransactionKey] = {
                guard let prevCapturedAt = ax.lastSnapshotCapturedAt else {
                    return document.model.transactions.map(\.primaryKey) // exclude all if first snapshot
                }
                let timeZone = TimeZone(identifier: timeZoneID) ?? TimeZone.current
                let prevBeginningOfDay = getStartOfDay(for: prevCapturedAt, timeZone: timeZone)
                return document.model.transactions.reduce(into: []) { array, txn in
                    if txn.transactedAt < prevBeginningOfDay {
                        array.append(txn.primaryKey)
                    }
                }
            }()

            excludeKeys.forEach {
                document.displaySettings.pendingExcludedTxnMap[$0] = true
            }
        }
        
        infoMessageStore.displayImportResults(modelID: document.model.id, results)
        
        refreshContextAction()
    }
}
