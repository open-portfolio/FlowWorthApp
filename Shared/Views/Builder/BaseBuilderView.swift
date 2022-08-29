//
//  BaseBuilderView.swift
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
import FlowWorthLib
import FlowUI

struct BaseBuilderView<Content>: View where Content: View {
    @Binding var document: WorthDocument
    let now: Date
    let viewName: String
    let subTitle: String

    @ViewBuilder let content: () -> Content
        
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text(title)
                        .font(.title)
                    Text(subTitle)
                        .font(.subheadline)
                }
                
                Spacer()
                
                Group {
                    if let msg = canCommitMessage {
                        Text(msg.0)
                            .foregroundColor(msg.1 ? .red : .primary)
                    } else {
                        Text("Ready to create new Snapshot!")
                    }
                }
                .font(.title3)
            
                Spacer()

                HelpButton(appName: "worth", topicName: "snapshotBuilder")
            }
            .padding()
            
            content()
            
            Spacer()
            
            BuilderFooter(document: $document)
                .frame(maxHeight: 50)
                .padding()
        }
        .padding()
        .toolbar {
            ToolbarItemGroup(placement: .automatic) {
                builderControls
            }
        }
    }
    
    @ViewBuilder
    private var builderControls: some View {
        PeriodSummarySelectionPicker(document: $document)
        
        Spacer(minLength: 60)
        
        MyDatePicker(date: $document.displaySettings.builderCapturedAt,
                     minimumDate: ps.minimumDate,
                     now: now,
                     onChange: dateChangeAction)
        
        Spacer(minLength: 60)
        
        Button(action: clearAction, label: {
            Text("Clear")
        })
        
        Button(action: createSnapshotAction, label: {
            Text("Create Snapshot")
        })
            .disabled(!canCommit)
    }
    
    // MARK: - Properties
    
    private var ax: WorthContext {
        document.context
    }

    private var ps: PendingSnapshot {
        document.pendingSnapshot
    }

    private var title: String {
        "Snapshot Builder (\(viewName))"
    }
    
    private var canCommitMessage: (String, Bool)? {
        ps.canCommit(ax: ax, nuCapturedAt: document.displaySettings.builderCapturedAt)
    }
    
    private var canCommit: Bool {
        canCommitMessage == nil
    }
    
    // MARK: - Actions
    
    private func createSnapshotAction() {
        NotificationCenter.default.post(name: .commitBuilder, object: document.model.id)
    }
    
    private func clearAction() {
        NotificationCenter.default.post(name: .clearBuilder, object: document.model.id)
    }
    
    // MARK: - Actions
    
    private func dateChangeAction(_: Date) {
        // this should also reset document.pendingSnapshot
        NotificationCenter.default.post(name: .refreshWorthResult, object: ax.model.id)
    }

}
