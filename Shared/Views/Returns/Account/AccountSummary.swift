//
//  AccountSummary.swift
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

struct AccountSummary: View {

    @Binding var document: WorthDocument
    var account: MAccount
        
    var body: some View {
        BaseReturnsSummary(document: $document,
                           title: title,
                           mr: mr,
                           account: account)
    }
    
    // MARK: - Properties
    
    private var ds: DisplaySettings {
        document.displaySettings
    }
    
    private var ax: WorthContext {
        document.context
    }

    private var accountKey: AccountKey {
        account.primaryKey
    }
    
    private var title: String {
        "‘\(account.titleID)’ Returns"
    }
    
    private var mr: MatrixResult {
        mrAccount(accountKey)
    }
    
    private func mrAccount(_ accountKey: AccountKey) -> MatrixResult {
        let mr2 = document.mrCache.getAccountMR(accountKey)
        return mr2
    }
}
