//
//  AssetsList.swift
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

struct AssetsList: View {
    @Binding var document: WorthDocument
    @ObservedObject var mr: MatrixResult
    
    init(document: Binding<WorthDocument>, mr: MatrixResult) {
        _document = document
        self.mr = mr
    }

    private let gridItems: [GridItem] = [
        GridItem(.fixed(40), spacing: columnSpacing, alignment: .center),
        GridItem(.flexible(minimum: 100), spacing: columnSpacing),
    ]
    
    @AppStorage(UserDefShared.timeZoneID.rawValue) var timeZoneID: String = ""
    
    var body: some View {
        VStack {
            HStack {
                Text("Represented Asset Classes")
                    .font(.title2)
                Spacer()
                
                HelpButton(appName: "worth", topicName: "inspectAssets")
            }
            .padding()
            .lineLimit(1)
            
            TablerList(
                .init(onMove: rowMoveAction),
                header: header,
                row: row,
                rowBackground: rowBackground,
                results: mr.orderedAssetKeys)
        }
        .onAppear {
            // TODO is there a better place to put this?
            document.displaySettings.orderedAssetKeys = mr.orderedAssetKeys
        }
    }
    
    typealias Context = TablerContext<AssetKey>
    
    private func header(_ ctx: Binding<Context>) -> some View {
        LazyVGrid(columns: gridItems, alignment: .leading, spacing: flowColumnSpacing) {
            Text("✓")
                .modifier(HeaderCell())
                .onTapGesture { headerCheckAction() }
            Text("Asset Class")
                .modifier(HeaderCell())
        }
    }
    
    private func row(_ assetKey: AssetKey) -> some View {
        LazyVGrid(columns: gridItems, alignment: .leading, spacing: flowColumnSpacing) {
            if let _onCheck = checkAction, let _isChecked = isCheckedAction {
                CheckControl(element: assetKey, onCheck: _onCheck, isChecked: _isChecked)
            }
            Text(MAsset.getTitleID(assetKey, ax.assetMap, withID: true) ?? "")
                .lineLimit(1)
                .mpadding()
        }
        .foregroundColor(getColorCode(assetKey).0)
    }
    
    private func rowBackground(_ assetKey: AssetKey) -> some View {
        document.getBackgroundFill(assetKey)
    }
    
    // MARK: - Properties
    
    private var ax: WorthContext {
        document.context
    }
    
    // MARK: - Actions
    
    private func checkAction(_ assetKeys: [AssetKey], _ nuValue: Bool) {
        assetKeys.forEach { key in
            document.displaySettings.excludedAssetMap[key] = nuValue
        }
        
        // NOTE no need to rebuild matrix with refreshWorthResult()
    }
    
    private func isCheckedAction(_ key: AssetKey) -> Bool {
        //let key = mr.orderedAssetKeys[n]
        return document.displaySettings.excludedAssetMap[key] ?? false
    }
    
    private func headerCheckAction() {
        if document.displaySettings.excludedAssetMap.first(where: { $0.value }) != nil {
            document.displaySettings.excludedAssetMap.removeAll()
        } else {
            mr.orderedAssetKeys.forEach {
                document.displaySettings.excludedAssetMap[$0] = true
            }
        }
    }
    
    // MARK: - Action handlers
    
    private func rowMoveAction(from source: IndexSet, to destination: Int) {
        print("moveAction: from \(source) to \(destination)")
        document.displaySettings.orderedAssetKeys.move(fromOffsets: source, toOffset: destination)
        document.refreshWorthResult(timeZoneID: timeZoneID) // rebuild the MatrixResults
    }
    
    // MARK: - Helpers
    
    /// use title from asset table, if available
    private func getTitle(_ assetKey: AssetKey) -> String {
        ax.assetMap[assetKey]?.titleID ?? assetKey.assetNormID.capitalized
    }
    
    private func getColorCode(_ assetKey: AssetKey) -> ColorPair {
        document.assetColorMap[assetKey] ?? (Color.primary, Color.clear)
    }
}
