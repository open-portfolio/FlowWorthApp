//
//  MatrixResult+Utils.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

import FlowWorthLib
import FlowBase
import FlowUI
import NiceScale

public extension MatrixResult {
    
    func getColors(assetMap: AssetMap, assetKeyFilter: AssetKeyFilter) -> [ColorPair] {
        self.orderedAssetKeys
            .filter(assetKeyFilter)
            .map { assetKey in
                guard let colorCode = assetMap[assetKey]?.colorCode,
                      let pair = colorDict[colorCode]?.first
                else { return ColorPair(.primary, .secondary) }
                return pair
            }
    }
    
    func getAssetNiceScale(returnsExtent: ReturnsExtent) -> NiceScale<Double>? {
        guard let rawER = assetMarketValueExtentRange else { return nil }
        return getNiceScale(returnsExtent: returnsExtent, rawER: rawER)
    }
    func getAccountNiceScale(returnsExtent: ReturnsExtent) -> NiceScale<Double>? {
        guard let rawER = accountMarketValueExtentRange else { return nil }
        return getNiceScale(returnsExtent: returnsExtent, rawER: rawER)
    }
    func getStrategyNiceScale(returnsExtent: ReturnsExtent) -> NiceScale<Double>? {
        guard let rawER = strategyMarketValueExtentRange else { return nil }
        return getNiceScale(returnsExtent: returnsExtent, rawER: rawER)
    }

    private func getNiceScale(returnsExtent: ReturnsExtent, rawER: ClosedRange<Double>) -> NiceScale<Double>? {
        let netER: ClosedRange<Double> = {
            switch returnsExtent {
            case .positiveOnly:
                return rawER.clamped(to: 0...(max(0, rawER.upperBound)))
            case .all:
                return rawER
            case .negativeOnly:
                return rawER.clamped(to: (min(0, rawER.lowerBound))...0)
            }
        }()
        return NiceScale(netER)
    }
}
