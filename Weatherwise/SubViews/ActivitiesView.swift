//
//  ActivityView.swift
//  Weatherwise
//
//  Created by Harry Patsis on 25/6/24.
//

import SwiftUI

struct ActivityView: View {
   var name: String
   var title: String
   
   var body: some View {
      VStack(alignment: .leading) {
         Image(name)
            .resizable()
            .scaledToFit()
            .clipShape(.rect(cornerRadius: 12))
                     
         Text(title)
      }
      
      //.frame(width: 180)
      //.background(.red)
   }
}

struct ActivitiesView: View {
   @Environment(\.horizontalSizeClass) var sizeClass
   
   var body: some View {
      VStack {
         // title
         Label("Activities in your area", systemImage: "heart.fill")
            .font(.title3)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, alignment: .leading)

         // hardcoded activities list
         HStack(spacing: 10) {
            // activity 1
            ActivityView(name: "activity1", title: "2km away")

            // activity 2
            ActivityView(name: "activity2", title: "1.5km away")
            
            // activity 3
            ActivityView(name: "activity3", title: "3km away")

            // activity 4
            ActivityView(name: "activity4", title: "500m away")
         }
         .padding()
      }
      .padding()
      .frame(maxWidth: .infinity)
      .modifier(BlurredBackgroundModifier(sizeClass: sizeClass)) // reusable modifier
   }
}
