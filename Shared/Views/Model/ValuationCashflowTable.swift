//
//  ValuationCashflowTable.swift
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

public struct ValuationCashflowTable: View {
    
    // MARK: - Parameters
    
    @Binding private var model: BaseModel
    private let ax: BaseContext
    private let account: MAccount? // if nil, show cash flows for all accounts
    
    public init(model: Binding<BaseModel>, ax: BaseContext, account: MAccount?) {
        _model = model
        self.ax = ax
        self.account = account
    }
    
    // MARK: - Field Metadata
    
    private var gridItems: [GridItem] = [
        GridItem(.flexible(minimum: 100), spacing: columnSpacing, alignment: .leading),
        GridItem(.flexible(minimum: 140), spacing: columnSpacing, alignment: .leading),
        GridItem(.flexible(minimum: 100), spacing: columnSpacing, alignment: .leading),
        GridItem(.flexible(minimum: 70), spacing: columnSpacing, alignment: .leading),
    ]
    
    // MARK: - Views
    
    typealias Context = TablerContext<MValuationCashflow>
    
    private func header(_ ctx: Binding<Context>) -> some View {
        LazyVGrid(columns: gridItems, alignment: .leading, spacing: flowColumnSpacing) {
            Sort.columnTitle("Transacted At", ctx, \.transactedAt)
                .onTapGesture { tablerSort(ctx, &model.valuationCashflows, \.transactedAt) { $0.transactedAt < $1.transactedAt } }
                .modifier(HeaderCell())
            Sort.columnTitle("Account (Number)", ctx, \.accountID)
                .onTapGesture { tablerSort(ctx, &model.valuationCashflows, \.accountID) { $0.accountKey < $1.accountKey } }
                .modifier(HeaderCell())
            Sort.columnTitle("Asset Class", ctx, \.assetID)
                .onTapGesture { tablerSort(ctx, &model.valuationCashflows, \.assetID) { $0.assetKey < $1.assetKey } }
                .modifier(HeaderCell())
            Sort.columnTitle("Amount", ctx, \.amount)
                .onTapGesture { tablerSort(ctx, &model.valuationCashflows, \.amount) { $0.amount < $1.amount } }
                .modifier(HeaderCell())
        }
    }
    
    private func row(_ element: MValuationCashflow) -> some View {
        LazyVGrid(columns: gridItems, alignment: .leading, spacing: flowColumnSpacing) {
            DateLabel(element.transactedAt, withTime: true)
                .mpadding()
            AccountTitleLabel(model: model, ax: ax, accountKey: element.accountKey, withID: true)
                .mpadding()
            AssetTitleLabel(assetKey: element.assetKey, assetMap: ax.assetMap, withID: true)
                .mpadding()
            CurrencyLabel(value: element.amount, style: .whole)
                .mpadding()
        }
        .modifier(EditDetailerContextMenu(element, onDelete: deleteAction, onEdit: { toEdit = $0 }))
    }
    
    private func editDetail(ctx: DetailerContext<MValuationCashflow>, element: Binding<MValuationCashflow>) -> some View {
        let disableKey = ctx.originalID != newElement.primaryKey
        return Form {
            DatePicker(selection: element.transactedAt) {
                Text("Transacted At:")
            }
            .disabled(disableKey)
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
            
            CurrencyField("Amount", value: element.amount)
        }
    }
    
    // MARK: - Locals
    
    private typealias Sort = TablerSort<MValuationCashflow>
    private typealias DConfig = DetailerConfig<MValuationCashflow>
    private typealias TConfig = TablerStackConfig<MValuationCashflow>
    
    private var dconfig: DConfig {
        DConfig(
            onDelete: deleteAction,
            onSave: saveAction,
            titler: { _ in ("Cash flow") })
    }
    
    @State var toEdit: MValuationCashflow? = nil
    @State var selected: MValuationCashflow.ID? = nil
    @State var hovered: MValuationCashflow.ID? = nil
    
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
                    results: model.valuationCashflows,
                    selected: $selected)
            }
            .editDetailer(dconfig,
                          toEdit: $toEdit,
                          originalID: toEdit?.id,
                          detailContent: editDetail)
    }
    
    private func toolbarContent() -> AnyView {
#if CONSOLIDATE
        Button(action: consolidateAction) {
            Text("Consolidate Cash Flows")
        }
        .eraseToAnyView()
#else
        EmptyView().eraseToAnyView()
#endif
    }
    
    // MARK: - Helpers
    
    private var assetMap: AssetMap {
        if ax.assetMap.count > 0 {
            return ax.assetMap
        }
        return model.makeAssetMap()
    }
    
    // MARK: - Action Handlers
    
    private func deleteAction(element: MValuationCashflow) {
        model.delete(element)
    }
    
    private func editAction(_ id: MValuationCashflow.ID?) -> MValuationCashflow? {
        guard let _id = id else { return nil }
        return model.valuationCashflows.first(where: { $0.id == _id })
    }
    
    private func saveAction(ctx: DetailerContext<MValuationCashflow>, element: MValuationCashflow) {
        let isNew = ctx.originalID == newElement.primaryKey
        model.save(element,
                   to: \.valuationCashflows,
                   originalID: isNew ? nil : ctx.originalID)
    }
    
    private var newElement: MValuationCashflow {
        let accountID = account?.accountID ?? ""
        let transactedAt = Date.init(timeIntervalSince1970: 0)
        return MValuationCashflow(transactedAt: transactedAt, accountID: accountID, assetID: "")
    }
    
    private func clearAction() {
        var elements = model.valuationCashflows
        if let accountKey = account?.primaryKey {
            elements = elements.filter { $0.accountKey == accountKey }
        }
        elements.forEach { model.delete($0) }
    }
    
    private func exportAction() {
        let finFormat = AllocFormat.CSV
        if let data = try? exportData(model.valuationCashflows, format: finFormat),
           let ext = finFormat.defaultFileExtension
        {
            let name = MValuationCashflow.entityName.plural.replacingOccurrences(of: " ", with: "-")
#if os(macOS)
            NSSavePanel.saveData(data, name: name, ext: ext, completion: { _ in })
#endif
        }
    }
    
#if CONSOLIDATE
    private func consolidateAction() {
        guard let wx = ax as? WorthContext else { return }
        let baseline = MValuationCashflow.getSnapshotBaselineMap(snapshotKeys: wx.orderedSnapshotKeys,
                                                                 snapshotDateIntervalMap: wx.snapshotDateIntervalMap,
                                                                 snapshotPositionsMap: wx.snapshotPositionsMap,
                                                                 snapshotCashflowsMap: wx.snapshotCashflowsMap)
        if baseline.count > 0 {
            model.consolidateCashflow(snapshotBaselineMap: baseline, accountMap: ax.accountMap, assetMap: ax.assetMap)
            NotificationCenter.default.post(name: .refreshContext, object: model.id)
        }
    }
#endif
}
