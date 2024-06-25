//
//  TopBar.swift
//  Weatherwise
//
//  Created by Harry Patsis on 24/6/24.
//

import SwiftUI

struct TopBar: View {
   let sizeClass: UserInterfaceSizeClass?
   
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
               .foregroundStyle(.white)
         }
         
         Spacer()
         
         if sizeClass == .compact {
            // show user thumbnail on iphones
            Image("userThumbnail")
               .resizable()
               .scaledToFit()
               .frame(width: sizeClass == .compact ? 30 : 60)
         }
      } // top HStack
      .padding(.horizontal)
   }
}

