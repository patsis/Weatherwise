//
//  DailyForecastView.swift
//  Weatherwise
//
//  Created by Harry Patsis on 24/6/24.
//

import SwiftUI

// daily forecast view
struct DayForecastView: View {
   @Environment(ViewModel.self) var viewModel
   @Binding var selectedDate: Date?
   var wide = false
   
   var body: some View {
      HStack {
         // left button
         Button {
            // do nothing yet
         } label: {
            Image(systemName: "chevron.left")               
               .font(.title3)
               .foregroundStyle(.white) // or .accent to use the app accent color defined in xcassets
         }
         
         // 5 days/condition view
         // the day is selectable, but selecting doesn't change the current weather info
         ForEach(viewModel.dailyForecast.prefix(5), id: \.date) { daily in
            DayForecastViewCell(forecast: daily, selectedDate: $selectedDate)
               .padding(.horizontal, wide ? 20 : 8)
         }
         
         // right button
         Button {
            // do nothing yet
         } label: {
            Image(systemName: "chevron.right")
               .font(.title3)
               .foregroundStyle(.white) // or .accent to use the app accent color defined in xcassets
         }
      }
   }
}

