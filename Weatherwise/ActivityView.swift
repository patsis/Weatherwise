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
