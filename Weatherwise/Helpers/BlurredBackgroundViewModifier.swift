//
//  BlurredBackgroundViewModifier.swift
//  Weatherwise
//
//  Created by Harry Patsis on 25/6/24.
//

import SwiftUI

/// Blurred background view modifier to be used in various elements
/// Use: .modifier(BlurredBackgroundModifier(sizeClass: sizeClass))
struct BlurredBackgroundModifier: ViewModifier {
    let sizeClass: UserInterfaceSizeClass?
    
    func body(content: Content) -> some View {
       let corner: CGFloat = sizeClass == .compact ? 20 : 40 // different radius on different devices
        content
          .background(.ultraThinMaterial) // blur background
          .overlay(RoundedRectangle(cornerRadius: corner)
            .stroke(Color("strokeColor"), lineWidth: 2)// strokeColor from Assets
            .opacity(0.5)
          )
          .cornerRadius(corner)
    }
}
