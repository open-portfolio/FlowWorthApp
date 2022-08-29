//
//  ImportCommand.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Combine
import SwiftUI

import KeyWindow

import AllocData

#if os(macOS)
    import Cocoa
#endif

struct ImportPayload {
    var modelID: UUID
    var urls: [URL]
}

struct ImportCommand: View {
    @KeyWindowValueBinding(WorthDocument.self)
    var document: WorthDocument?

    let defaultEventModifier: EventModifiers = [.command] // [.shift, .option, .command]

    var body: some View {
        Button(action: {
            guard let model = document?.model else {
                //print("\(#function) document not available") // TODO: log this
                return
            }

            let modelUUID = model.id

            #if os(macOS)
                NSOpenPanel.importURLs(completion: { result in
                    guard let urls = try? result.get() else {
                        //print("\(#function) no urls available") // TODO: log this
                        return
                    }

                    let payload = ImportPayload(modelID: modelUUID, urls: urls)
                    NotificationCenter.default.post(name: .importURLs, object: payload)
                })
            #endif
        }, label: {
            Text("Import...")
        })
            .keyboardShortcut("i", modifiers: defaultEventModifier)
    }
}
