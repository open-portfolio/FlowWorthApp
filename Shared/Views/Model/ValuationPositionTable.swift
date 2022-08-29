//
//  ValuationPositionTable.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

import Detailer
import DetailerMenu
import AllocData
import Tabler

import FlowBase
import FlowUI
import FlowWorthLib

public struct ValuationPositionTable: View {
    
    // MARK: - Parameters
    
    @Binding private var model: BaseModel
    private let ax: BaseContext
    private let snapshot: MValuationSnapshot? // if nil, show positions for all snapshots
    private let account: MAccount? // if nil, show positions for all accounts
    
    public init(model: Binding<BaseModel>, ax: BaseContext, snapshot: MValuationSnapshot?, account: MAccount?) {
        _model = model
        self.ax = ax
        self.snapshot = snapshot
        self.account = account
    }
    
    // MARK: - Field Metadata
    
    private var gridItems: [GridItem] = [
        GridItem(.flexible(minimum: 140), spacing: columnSpacing, alignment: .leading),
        GridItem(.flexible(minimum: 140), spacing: columnSpacing, alignment: .leading),
        GridItem(.flexible(minimum: 100), spacing: columnSpacing, alignment: .leading),
        GridItem(.flexible(minimum: 70), spacing: columnSpacing, alignment: .leading),
        GridItem(.flexible(minimum: 70), spacing: columnSpacing, alignment: .leading),
    ]
    
    // MARK: - Views
    
    typealias Context = TablerContext<MValuationPosition>
    
    private func header(_ ctx: Binding<Context>) -> some View {
        LazyVGrid(columns: gridItems, alignment: .leading, spacing: flowColumnSpacing) {
            Sort.columnTitle("Snapshot ID", ctx, \.snapshotID)
                .onTapGesture { tablerSort(ctx, &model.valuationPositions, \.snapshotID) { $0.snapshotKey < $1.snapshotKey } }
                .modifier(HeaderCell())
            Sort.columnTitle("Account (Number)", ctx, \.accountID)
                .onTapGesture { tablerSort(ctx, &model.valuationPositions, \.accountID) { $0.accountKey < $1.accountKey } }
                .modifier(HeaderCell())
            Sort.columnTitle("Asset Class", ctx, \.assetID)
                .onTapGesture { tablerSort(ctx, &model.valuationPositions, \.assetID) { $0.assetKey < $1.assetKey } }
                .modifier(HeaderCell())
            Sort.columnTitle("Total Basis", ctx, \.totalBasis)
                .onTapGesture { tablerSort(ctx, &model.valuationPositions, \.totalBasis) { $0.totalBasis < $1.totalBasis } }
                .modifier(HeaderCell())
            Sort.columnTitle("Market Value", ctx, \.marketValue)
                .onTapGesture { tablerSort(ctx, &model.valuationPositions, \.marketValue) { $0.marketValue < $1.marketValue } }
                .modifier(HeaderCell())
        }
    }
    
    private func row(_ element: MValuationPosition) -> some View {
        LazyVGrid(columns: gridItems, alignment: .leading, spacing: flowColumnSpacing) {
            if let _snapshot = ax.snapshotMap[element.snapshotKey] {
                DateLabel(_snapshot.capturedAt, withTime: true)
                    .mpadding()
            } else {
                Text("Not Found")
                    .mpadding()
            }
            AccountTitleLabel(model: model, ax: ax, accountKey: element.accountKey, withID: true)
                .mpadding()
            AssetTitleLabel(assetKey: element.assetKey, assetMap: ax.assetMap, withID: true)
                .mpadding()
            CurrencyLabel(value: element.totalBasis, style: .whole)
                .mpadding()
            CurrencyLabel(value: element.marketValue, style: .whole)
                .mpadding()
        }
        .modifier(EditDetailerContextMenu(element, onDelete: deleteAction, onEdit: { toEdit = $0 }))
    }
    
    private func editDetail(ctx: DetailerContext<MValuationPosition>, element: Binding<MValuationPosition>) -> some View {
        let disableKey = ctx.originalID != newElement.primaryKey
        return Form {
            SnapshotIDPicker(snapshots: model.valuationSnapshots.sorted(), snapshotID: element.snapshotID) {
                Text("Snapshot")
            }
            .disabled(disableKey)
            .validate(ctx, element, \.snapshotID) { $0.count > 0 }
            
            AccountIDPicker(accounts: model.accounts.sorted(), accountID: element.accountID) {
                Text("Account")
            }
            .disabled(disableKey)
            .validate(ctx, element, \.accountID) { $0.count > 0 }
            
            AssetIDPicker(assets: model.assets.sorted(), assetID: element.assetID) {
                Text("Asset Class")
            }
            .disabled(disableKey)
            .validate(ctx, element, \.assetID) { $0.count > 0 }
            
            CurrencyField("Total Basis", value: element.totalBasis)
            CurrencyField("Market Value", value: element.marketValue)
        }
    }
    
    // MARK: - Locals
    
    private typealias Sort = TablerSort<MValuationPosition>
    private typealias DConfig = DetailerConfig<MValuationPosition>
    private typealias TConfig = TablerStackConfig<MValuationPosition>
    
    private var dconfig: DConfig {
        DConfig(
            onDelete: deleteAction,
            onSave: saveAction,
            titler: { _ in ("Position") })
    }
    
    @State var toEdit: MValuationPosition? = nil
    @State var selected: MValuationPosition.ID? = nil
    @State var hovered: MValuationPosition.ID? = nil
    
    public var body: some View {
        BaseModelTable(
            selected: $selected,
            toEdit: $toEdit,
            onAdd: { newElement },
            onEdit: editAction,
            onClear: clearAction,
            onExport: exportAction,
            onDelete: dconfig.onDelete) {
                TablerStack1(
                    .init(onHover: { if $1 { hovered = $0 } else { hovered = nil } }),
                    header: header,
                    row: row,
                    rowBackground: { MyRowBackground($0, hovered: hovered, selected: selected) },
                    results: model.valuationPositions,
                    selected: $selected)
            }
            .editDetailer(dconfig,
                          toEdit: $toEdit,
                          originalID: toEdit?.id,
                          detailContent: editDetail)
    }
    
    private var assetMap: AssetMap {
        if ax.assetMap.count > 0 {
            return ax.assetMap
        }
        return model.makeAssetMap()
    }
    
    // MARK: - Action Handlers
    
    private func deleteAction(element: MValuationPosition) {
        model.delete(element)
    }
    
    private func editAction(_ id: MValuationPosition.ID?) -> MValuationPosition? {
        guard let _id = id else { return nil }
        return model.valuationPositions.first(where: { $0.id == _id })
    }
    
    private func saveAction(ctx: DetailerContext<MValuationPosition>, element: MValuationPosition) {
        let isNew = ctx.originalID == newElement.primaryKey
        model.save(element,
                   to: \.valuationPositions,
                   originalID: isNew ? nil : ctx.originalID)
    }
    
    private var newElement: MValuationPosition {
        let snapshotID = snapshot?.snapshotID ?? ""
        let accountID = account?.accountID ?? ""
        return MValuationPosition(snapshotID: snapshotID, accountID: accountID, assetID: "")
    }
    
    private func clearAction() {
        var elements = model.valuationPositions
        if let accountKey = account?.primaryKey {
            elements = elements.filter { $0.accountKey == accountKey }
        }
        elements.forEach { model.delete($0) }
    }
    
    private func exportAction() {
        let finFormat = AllocFormat.CSV
        if let data = try? exportData(model.valuationPositions, format: finFormat),
           let ext = finFormat.defaultFileExtension
        {
            let name = MValuationPosition.entityName.plural.replacingOccurrences(of: " ", with: "-")
#if os(macOS)
            NSSavePanel.saveData(data, name: name, ext: ext, completion: { _ in })
#endif
        }
    }
}
