//
//  ValuationSnapshotTable.swift
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

public struct ValuationSnapshotTable: View {
    
    // MARK: - Parameters
    
    @Binding private var model: BaseModel
    private let ax: BaseContext
    
    public init(model: Binding<BaseModel>, ax: BaseContext) {
        _model = model
        self.ax = ax
    }
    
    // MARK: - Field Metadata
        
    private var gridItems: [GridItem] = [
        GridItem(.flexible(minimum: 200), spacing: columnSpacing, alignment: .leading),
        GridItem(.flexible(minimum: 110), spacing: columnSpacing, alignment: .leading),
    ]
    
    // MARK: - Views
    
    typealias Context = TablerContext<MValuationSnapshot>
    
    private func header(_ ctx: Binding<Context>) -> some View {
        LazyVGrid(columns: gridItems, alignment: .leading, spacing: flowColumnSpacing) {
            Sort.columnTitle("Snapshot ID", ctx, \.snapshotID)
                .onTapGesture { tablerSort(ctx, &model.valuationSnapshots, \.snapshotID) { $0.primaryKey < $1.primaryKey } }
                .modifier(HeaderCell())
            Sort.columnTitle("Captured At", ctx, \.capturedAt)
                .onTapGesture { tablerSort(ctx, &model.valuationSnapshots, \.capturedAt) { $0.capturedAt < $1.capturedAt } }
                .modifier(HeaderCell())
         }
    }
    
    private func row(_ element: MValuationSnapshot) -> some View {
        LazyVGrid(columns: gridItems, alignment: .leading, spacing: flowColumnSpacing) {
            Text(element.snapshotID)
                .mpadding()
            DateLabel(element.capturedAt, withTime: true)
                .mpadding()
        }
        .modifier(EditDetailerContextMenu(element, onDelete: deleteAction, onEdit: { toEdit = $0 }))
    }
    
    private func editDetail(ctx: DetailerContext<MValuationSnapshot>, element: Binding<MValuationSnapshot>) -> some View {
        let disableKey = ctx.originalID != newElement.primaryKey
        return Form {
            TextField("Snapshot ID", text: element.snapshotID)
                .disabled(disableKey)
                .validate(ctx, element, \.snapshotID) { $0.count > 0 }
            
            DatePicker(selection: element.capturedAt) { Text("Captured At:") }
        }
    }
    
    // MARK: - Locals
    
    private typealias Sort = TablerSort<MValuationSnapshot>
    private typealias DConfig = DetailerConfig<MValuationSnapshot>
    private typealias TConfig = TablerStackConfig<MValuationSnapshot>
    
    private var dconfig: DConfig {
        DConfig(
            onDelete: deleteAction,
            onSave: saveAction,
            titler: { _ in ("Snapshot") })
    }
    
    @State var toEdit: MValuationSnapshot? = nil
    @State var selected: MValuationSnapshot.ID? = nil
    @State private var hovered: MValuationSnapshot.ID? = nil
    
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
                    results: model.valuationSnapshots,
                    selected: $selected)
            }
            .editDetailer(dconfig,
                          toEdit: $toEdit,
                          originalID: toEdit?.id,
                          detailContent: editDetail)
    }
    
    // MARK: - Action Handlers
    
    private func deleteAction(element: MValuationSnapshot) {
        model.delete(element)
    }
    
    private func editAction(_ id: MValuationSnapshot.ID?) -> MValuationSnapshot? {
        guard let _id = id else { return nil }
        return model.valuationSnapshots.first(where: { $0.id == _id })
    }
    
    private func saveAction(ctx: DetailerContext<MValuationSnapshot>, element: MValuationSnapshot) {
        let isNew = ctx.originalID == newElement.primaryKey
        model.save(element,
                   to: \.valuationSnapshots,
                   originalID: isNew ? nil : ctx.originalID)
    }
    
    private var newElement: MValuationSnapshot {
        MValuationSnapshot(snapshotID: "", capturedAt: Date.init(timeIntervalSince1970: 0))
    }
    
    private func clearAction() {
        model.valuationSnapshots.forEach { model.delete($0) }
    }
    
    private func exportAction() {
        let finFormat = AllocFormat.CSV
        if let data = try? exportData(model.valuationSnapshots, format: finFormat),
           let ext = finFormat.defaultFileExtension
        {
            let name = MValuationSnapshot.entityName.plural.replacingOccurrences(of: " ", with: "-")
#if os(macOS)
            NSSavePanel.saveData(data, name: name, ext: ext, completion: { _ in })
#endif
        }
    }
}
