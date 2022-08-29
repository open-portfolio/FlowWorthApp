//
//  LegendBar.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//


import SwiftUI

struct LegendBar: View {
    
    struct LegendItem: Hashable {
        let title: String?
        let id: String?
        let fg: Color
        let bg: Color
    }
    
    var collections: [LegendItem]
    @State private var scrollViewContentSize: CGSize = .zero
    
    var body: some View {
        HStack {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(collections, id: \.self) { collection in
                        //Text(collection)
                        legendBadge(collection)
                    }
                }
                .background(
                    GeometryReader { geo -> Color in
                        DispatchQueue.main.async {
                            scrollViewContentSize = geo.size
                        }
                        return Color.clear
                    }
                )
            }
            .frame(
                maxWidth: scrollViewContentSize.width
            )
        }
    }
    
    private func legendBadge(_ item: LegendItem) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(item.bg)
            VStack {
                Text(item.title ?? item.id ?? "Unknown")
                    .lineLimit(1)
                    .font(.caption)
                if let id = item.id {
                    Text("(\(id))")
                        .lineLimit(1)
                        .font(.caption2)
                }
            }
            .shadow(radius: 0.5)
            .foregroundColor(item.fg)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
        }
        .compositingGroup()
        .frame(maxHeight: 40)
    }
    
}
