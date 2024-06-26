//
//  TopBar.swift
//  Weatherwise
//
//  Created by Harry Patsis on 24/6/24.
//

import SwiftUI

struct RightBar: View {
   @Environment(\.horizontalSizeClass) var sizeClass
   @Environment(ViewModel.self) var viewModel
   @Binding var selectedDate: Date?
   
   var body: some View {
      VStack {
         // daily conditions
         DayForecastView(selectedDate: $selectedDate)
            .padding()
         
         HStack {
            Image(systemName: "clock.fill")
            Text(Date.now, style: .time)
         }
         .font(.title3)
         .foregroundStyle(.white)
         
         Spacer()
         
         // Air-conditions
         if let currentConditions = viewModel.dailyForecast.first {
            // we need a ZStack to place the VStack of air-conditions
            // above mountain image
            ZStack(alignment: .bottom) {
               VStack(alignment: .leading) {
                  Text("AIR CONDITIONS")
                     .font(.subheadline)
                  
                  // Real Feel
                  HStack {
                     // thermometer icon
                     Image(systemName: "thermometer.sun.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24)
                     
                     // label and value
                     VStack(alignment: .leading) {
                        Text("Real Feel")
                        Text("\(currentConditions.realFeel)°")
                     }
                     .font(.subheadline)
                  } // Real Feel
                  .frame(maxHeight: .infinity) // equally fill height in VStack
                  
                  // Wind
                  HStack {
                     // Wind icon
                     Image(systemName: "wind")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24)
                     
                     VStack(alignment: .leading) {
                        Text("Wind")
                        Text("\(currentConditions.windSpeed) km/h")
                     }
                     .font(.subheadline)
                  } // Wind
                  .frame(maxHeight: .infinity) // equally fill height in VStack
                  
                  // chance of rain
                  HStack {
                     // water drop icon
                     Image(systemName: "drop.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                     
                     VStack(alignment: .leading) {
                        Text("Chance of rain")
                        Text("\(currentConditions.chanceOfRain) %")
                     }
                     .font(.subheadline)
                  } // chance of rain
                  .frame(maxHeight: .infinity) // equally fill height in VStack
                  
                  // UV Index
                  HStack {
                     // sun icon
                     Image(systemName: "sun.max.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24)
                     
                     VStack(alignment: .leading) {
                        Text("UV Index")
                        Text("\(currentConditions.uvIndex)")
                     }
                     .font(.subheadline)
                  } // chance of rain
                  .frame(maxHeight: .infinity) // equally fill height in VStack
                  
               } // inner VStack
               .padding()
               .frame(maxWidth: .infinity, alignment: .leading)
               
               Image("mountains")
                  .resizable()
                  .scaledToFit()
                  .foregroundStyle(.white)
                  .opacity(0.5)
            } // AIR_CONDITIONS ZStack
         } // if currentConditions
      } // VStack
      .foregroundStyle(.white)
      .frame(maxWidth: 350)
      .modifier(BlurredBackgroundModifier(sizeClass: sizeClass)) // reusable modifier
   }
}

