//
//  WorthDocument.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI
import UniformTypeIdentifiers

import AllocData
import FlowWorthLib
import FlowUI
import FlowBase

extension WorthContext: ObservableObject {}
extension PendingSnapshot: ObservableObject {}
extension MatrixResultCache: ObservableObject {}
extension MatrixResult: ObservableObject {}

struct WorthDocument {
    var model: BaseModel
    var modelSettings: ModelSettings // requiring context reset
    var displaySettings: DisplaySettings // NOT requiring context reset
    
    @ObservedObject var context: WorthContext
    
    var assetColorMap: AssetColorMap
    
    @ObservedObject var mrCache: MatrixResultCache
    @ObservedObject var pendingSnapshot: PendingSnapshot
    
    // schemas to package/unpackage
    static var schemas: [AllocSchema] = [
        .allocStrategy,
        .allocAsset,
        .allocHolding,
        .allocAccount,
        .allocSecurity,
        .allocTransaction,
        .allocValuationSnapshot,
        .allocValuationPosition,
        .allocValuationCashflow,
    ]

    init() {
        let _model = BaseModel.getDefaultModel()
        let _modelSettings = ModelSettings()
        let _context = WorthContext(_model, _modelSettings)

        model = _model
        modelSettings = _modelSettings
        displaySettings = DisplaySettings()
        context = _context
        assetColorMap = AssetColorMap()
        mrCache = MatrixResultCache(ax: _context)
        pendingSnapshot = PendingSnapshot()
    }
}

extension UTType {
    static let worthDocument = UTType(exportedAs: "app.flowallocator.worth.portfolio")
}

extension WorthDocument: FileDocument {
    
    static var readableContentTypes: [UTType] { [.worthDocument] }
    static var writableContentTypes: [UTType] { [.worthDocument] }
    
    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        
        let _model = BaseModel()
        let _modelSettings = ModelSettings()
        let _context = WorthContext(_model, _modelSettings)

        model = _model
        modelSettings = _modelSettings
        displaySettings = DisplaySettings()
        context = _context
        assetColorMap = AssetColorMap()
        mrCache = MatrixResultCache(ax: _context)
        pendingSnapshot = PendingSnapshot()
       
        try model.unpackage(data: data,
                            schemas: WorthDocument.schemas,
                            modelSettings: &modelSettings,
                            displaySettings: &displaySettings)
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = try model.package(schemas: WorthDocument.schemas,
                                     modelSettings: modelSettings,
                                     displaySettings: displaySettings)
        return .init(regularFileWithContents: data)
    }
}
