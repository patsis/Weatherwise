//
//  TopBar.swift
//  Weatherwise
//
//  Created by Harry Patsis on 24/6/24.
//

import SwiftUI

struct LeftBar: View {
   @Environment(\.horizontalSizeClass) var sizeClass
   let buttonSize: CGFloat = 40
   
   var body: some View {
      VStack {
         // user button
         Button {
            // do nothing yet
         } label: {
            Image("userThumbnail")
               .resizable()
               .scaledToFit()
               .frame(height: 60)
         }
          .padding(.bottom)
          .frame(maxHeight: .infinity) // equally fill height in VStack
         
         // weather button
         Button {
            // do nothing yet
         } label: {
            VStack(spacing: 2) {
               Image(systemName: "cloud.sun.rain.fill")
                  .resizable()
                  .scaledToFit()
                  .frame(height: buttonSize)
               
               Text("weather")
                  .font(.headline)
            }
            .foregroundStyle(.white)
            .padding(.bottom)
         }
         .frame(maxHeight: .infinity) // equally fill height in VStack
         
         // explore button
         Button {
            // do nothing yet
         } label: {
            VStack(spacing: 2) {
               Image(systemName: "safari.fill")
                  .resizable()
                  .scaledToFit()
                  .frame(height: buttonSize)
               
               Text("explore")
                  .font(.headline)
            }
            .foregroundStyle(.white)
            .padding(.bottom)
         }
         .frame(maxHeight: .infinity) // equally fill height in VStack
         
         // cities button
         Button {
            // do nothing yet
         } label: {
            VStack(spacing: 2) {
               Image("location")
                  .resizable()
                  .scaledToFit()
                  .frame(height: buttonSize)
               
               Text("cities")
                  .font(.headline)
            }
            .foregroundStyle(.white)
         }
         .frame(maxHeight: .infinity) // equally fill height in VStack
         
         // settings button
         Button {
            // do nothing yet
         } label: {
            VStack(spacing: 2) {
               Image(systemName: "gearshape.fill")
                  .resizable()
                  .scaledToFit()
                  .frame(height: buttonSize)
               
               Text("settings")
                  .font(.headline)
            }
            .foregroundStyle(.white)
            .padding(.bottom)
         }
         .frame(maxHeight: .infinity) // equally fill height in VStack

      } // VStack
      .padding()
      .frame(maxHeight: .infinity) // fill height in container
      .modifier(BlurredBackgroundModifier(sizeClass: sizeClass)) // reusable modifier
   }
}

