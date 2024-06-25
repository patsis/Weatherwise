//
//  ContentView.swift
//  Weatherwise
//
//  Created by Harry Patsis on 21/6/24.
//

import SwiftUI

/// Blurred background view modifier to be used in various elements
/// Use: .modifier(BlurredBackgroundModifier(sizeClass: sizeClass))
struct BlurredBackgroundModifier: ViewModifier {
    let sizeClass: UserInterfaceSizeClass?
    
    func body(content: Content) -> some View {
       let corner: CGFloat = sizeClass == .compact ? 20 : 40
        content
          .background(.ultraThinMaterial) // blur background
          .overlay(RoundedRectangle(cornerRadius: corner)
             .stroke(.white, lineWidth: 2)
             .opacity(0.5)
          )
          .cornerRadius(corner)
    }
}


struct WeatherView: View {
   // get the horizontal sizeClass (.compact, .regular)
   @Environment(\.horizontalSizeClass) var sizeClass
   
   // View Model
   @State private var viewModel = ViewModel()
   
   // State variables
   @State private var networkError = false
   
   // currentForecast can be updated when user does a pull-down refresh
   @State private var currentForecast: WeatherForecast?
   
   // background image depending on weather conditions
   @State private var backgroundImageName: String = "sunny"
   
   // selectedDate is used on day selection
   @State private var selectedDate: Date? = nil
   
   private func refresh() {
      // refresh onAppear or respond to user pull down gesture
      // needs to be in a task because viewModel.update() is an async function
      Task {
         do {
            try await viewModel.update()
            currentForecast = viewModel.hourlyForecast.first
            networkError = false
         } catch {
            // something went wrong, tell user
            networkError = true
            currentForecast = nil
         }
         // animate image change
         withAnimation {
            backgroundImageName = getBackgroundImageName()
         }
      }
   }
   
   private func getBackgroundImageName() -> String {
      if let currentForecast {
         switch currentForecast.condition {
            case .sunny: return "sunny"
            case .rainy: return "rainy"
            case .snowy: return "rainy"
            case .cloudy: return "cloudy"
            case .stormy: return "stormy"   
            case .other: return "sunny"
         }
      }
      return "sunny"
   }
   
   private func dateDescription(_ date: Date) -> String {
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "EEEE | dd MMM yyyy"
      dateFormatter.locale = .current//
      return dateFormatter.string(from: date)
   }

   
   // Hourly forecast view
   private func HourlyForecastView() -> some View {
      VStack {
         // top label
         Label("24-hour forecast", systemImage: "clock.fill")
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical)
            .padding(.horizontal, sizeClass == .compact ? nil : 30)
         
         // show temperature line and condiions for every 2 hours
         HourForecastView(forecast: viewModel.hourlyForecast)
            .padding(.vertical)
            .padding(.horizontal, sizeClass == .compact ? 25 : 40)
         
         if sizeClass == .compact {
            // show only on iphone
            Button {
               // action:
               // do nothing yet
            } label: {
               Text("5-day forecast")
                  .foregroundStyle(.white)
                  .padding()
                  .background(Capsule().fill(Color("someYellow")))
            }
            .padding()
         }
      }
      .frame(maxWidth: .infinity) // fill width
//      .frame(height: sizeClass == .compact ? 280 : nil) // maximum height
      .modifier(BlurredBackgroundModifier(sizeClass: sizeClass)) // reusable modifier
   }
   
   private func CompactWeatherConditions(forecast: WeatherForecast) -> some View {
      VStack {
         // current condition
         Text(forecast.condition.rawValue)
            .font(.title)
            .foregroundStyle(.white)
         
         // weather icon
         Image(systemName: forecast.condition.imageName)
            .resizable()
            .scaledToFit()
            .foregroundStyle(.white)
            .frame(height: 150)
         
         // temperature
         Text("\(forecast.temperature)℃")
            .font(.system(size: 70))
            .foregroundStyle(.white)
         
         // day
         Text(dateDescription(forecast.date))
            .font(.title3)
            .foregroundStyle(.white)
      }
   }
   
   private func RegularWeatherConditions(forecast: WeatherForecast) -> some View {
      HStack {
         VStack(alignment: .leading) {
            // current condition
            Text(forecast.condition.rawValue)
               .font(.title)
               .foregroundStyle(.white)
            
            Spacer()
            
            // temperature
            Text("\(forecast.temperature)℃")
               .font(.system(size: 70))
               .foregroundStyle(.white)
            
            // day
            Text(dateDescription(forecast.date))
               .font(.title3)
               .foregroundStyle(.white)
         }
         
         Spacer()
         
         // weather icon
         Image(systemName: forecast.condition.imageName)
            .resizable()
            .scaledToFit()
            .foregroundStyle(.white)
            .frame(width: 150)
      }
      .padding()
   }
   
   var body: some View {
      ScrollView {
         VStack {
            if networkError {
               Text("Error fetching data")
                  .font(.title)
                  .foregroundStyle(.white)
                  .frame(maxWidth: .infinity)
               
               Text("Try again later...")
                  .font(.title3)
                  .foregroundStyle(.white)
                  .frame(maxWidth: .infinity)
               
            }
            
            if let currentForecast {
               TopBar(sizeClass: sizeClass)
               
               Spacer()
               
               // current condition
               if sizeClass == .compact {
                  CompactWeatherConditions(forecast: currentForecast)
                  
                  // daily conditions
                  DailyForecastView(selectedDate: $selectedDate)
                     .padding(.vertical)
                  
                  // hourly (temperature line) forecast
                  HourlyForecastView()                  
               } else {
                  RegularWeatherConditions(forecast: currentForecast)
                  
                  // LeftBar, activities, hourly forecast and daily forecast
                  // on tablet we use a different layout
                  HStack(spacing: 20) {
                     
                     // left tool bar pane
                     LeftBar(sizeClass: sizeClass)
                     
                     // VStack with activities and hourly temperature line
                     VStack(spacing: 20) {
                        // show activities in your ares
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
//                        .frame(height: 180)
                        .frame(maxWidth: .infinity)
                        .modifier(BlurredBackgroundModifier(sizeClass: sizeClass)) // reusable modifier
                        
                        // hourly (temperature line) forecast
                        HourlyForecastView()
                     }
                     
                     // RightBar, daily conditions, time and air conditions
                     RightBar(selectedDate: $selectedDate)
                     
                     
                  }
                  .frame(maxHeight: .infinity)
               }

            } // if
         } // main VStack
         .containerRelativeFrame(.vertical)
         .padding(.horizontal, sizeClass == .compact ? nil : 30)
         .frame(maxWidth: .infinity)
      } // ScrollView
      .background(
         Image(sizeClass == .compact ? "\(backgroundImageName)-compact" : backgroundImageName)
            .resizable()
            .ignoresSafeArea()
            .scaledToFill()
      )
      .onAppear {
         UIRefreshControl.appearance().tintColor = .white
         refresh()
         selectedDate = Date()
      }
      .refreshable {
          refresh()
      }
      .environment(viewModel)

   }
}

#Preview("iPhone", traits: .portrait) {
   WeatherView()
}
