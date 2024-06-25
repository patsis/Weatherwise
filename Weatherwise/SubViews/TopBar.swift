//
//  TopBar.swift
//  Weatherwise
//
//  Created by Harry Patsis on 24/6/24.
//

import SwiftUI

struct TopBar: View {
   @Environment(\.horizontalSizeClass) var sizeClass
   
   var body: some View {
      HStack {
         Image("location")
            .foregroundStyle(.white)
         
         Text("New York")
            .font(.title2)
            .foregroundStyle(.white)
         
         Button() {
            // no action yet, maybe select location
         } label: {
            Image(systemName: "chevron.down")
               .font(.title3)
               .foregroundStyle(.white) // or .accent to use the app accent color defined in xcassets
         }
         
         // push right
         Spacer()
         
         if sizeClass == .compact {
            // show user thumbnail on iphones
            Image("userThumbnail")
               .resizable()
               .scaledToFit()
               .frame(width: 30)
         }
      } // top HStack
      .padding()
   }
}

