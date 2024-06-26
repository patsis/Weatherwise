//
//  DayForecastView.swift
//  Weatherwise
//
//  Created by Harry Patsis on 23/6/24.
//

import SwiftUI

struct DayForecastViewCell: View {
   // WeatherForecast parameter
   var forecast: WeatherForecast
   // selected date binding parameter
   @Binding var selectedDate: Date?
  
   /// daysBewteen() calculates the distance in calendar days between two dates
   private func daysBetween(_ start: Date?, _ end: Date?) -> Int? {
      if let start, let end {
         let calendar = Calendar.current
         // Use Calendar to calculate the difference in days
         let components = calendar.dateComponents([.day], from: calendar.startOfDay(for: start), to: calendar.startOfDay(for: end))
         // Return the number of days or nil
         if let day = components.day {
            return abs(day)
         }
      }
      return nil
   }
   
   // opacity based on day distance
   private func opacity(for days: Int?) -> CGFloat {
      guard let days else {
         return 1.0
      }
      switch days {
         case 0: return 1.0
         case 1: return 0.8
         default: return 0.6
      }
   }
   
   // scale based on day distance
   private func scale(for days: Int?) -> CGFloat {
      guard let days else {
         return 1.0
      }
      switch days {
         case 0: return 1.25
         case 1: return 1.125
         default: return 1.0
      }
   }
   
   var body: some View {
      Button() {
         // animate update selectedDate
         withAnimation {
            selectedDate = forecast.date
         }
      } label: {
         // get dates between selected date and forecast.date
         let daysBetween = daysBetween(forecast.date, selectedDate)
         // and calculate scale
         let scale = scale(for: daysBetween)
         // and opacity
         let opacity = opacity(for: daysBetween)
         
         VStack {
            Text(forecast.dateAbbreviated)
               .font(.body)
               .lineLimit(1)
               .minimumScaleFactor(0.5)
               .foregroundStyle(.white)
            
            Image(systemName: forecast.condition.imageName)
               .font(.title3)
               .foregroundStyle(.white)
         } // VStack
         .scaleEffect(x: scale, y: scale, anchor: .bottom)
         .opacity(opacity)
      } // Button
   }
}

