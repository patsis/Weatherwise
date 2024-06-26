//
//  ContentView.swift
//  Weatherwise
//
//  Created by Harry Patsis on 21/6/24.
//

import SwiftUI


struct WeatherView: View {
   // get the horizontal sizeClass (.compact, .regular)
   @Environment(\.horizontalSizeClass) var sizeClass
   
   // View Model
   @State private var viewModel = ViewModel()
   
   // State variables
   @State private var networkError = false
   
   // currentForecast can be updated when user does a pull-down refresh
   @State private var currentForecast: WeatherForecast?
   
   // Background image depending on weather conditions
   @State private var backgroundImageName: String = "sunny"
   
   // selectedDate is used on day selection
   @State private var selectedDate: Date? = nil
   
   // Device orientation used in iPad layout, to change what elements can be seen in screen
   @State var orientation: UIDeviceOrientation = .unknown
   
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
   
   // get background image name based on current conditions
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
   
   // format date to look like "Saturday | 22 Jun 2024"
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
            .padding(.horizontal, sizeClass == .compact ? nil : 30) // different padding on defferent devices
         
         // show temperature line and condiions for every 2 hours
         HourForecastView(forecast: viewModel.hourlyForecast)
            .padding(.vertical)
            .padding(.horizontal, sizeClass == .compact ? 25 : 40) // different padding on defferent devices
         
         if sizeClass == .compact {
            // show only on iphone
            Button {
               // action:
               // do nothing yet
            } label: {
               Text("5-day forecast")
                  .foregroundStyle(.white)
                  .padding(12)
                  .frame(minWidth: 200)
                  .background(Capsule().fill(Color("someYellow")))
            }
            .padding()
         }
      }
      .frame(maxWidth: .infinity) // fill width
      .modifier(BlurredBackgroundModifier(sizeClass: sizeClass)) // reusable modifier
   }
   
   // Main Weather conditions for small screens
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
            .frame(height: sizeClass == .compact ? 150: 200)
         
         // temperature
         Text("\(forecast.temperature)℃")
            .font(.system(size: 70))
            .foregroundStyle(.white)
         
         // format date to "Saturday | 22 Jun 2024"
         Text(dateDescription(forecast.date))
            .font(.title3)
            .foregroundStyle(.white)
      }
   }
   
   // Main Weather conditions for large screens
   private func RegularWeatherConditions(forecast: WeatherForecast) -> some View {
      HStack {
         VStack(alignment: .leading) {
            
            // current condition as text
            Text(forecast.condition.rawValue)
               .font(.title)
               .foregroundStyle(.white)
            
            // temperature
            Text("\(forecast.temperature)℃")
               .font(.system(size: 100))
               .minimumScaleFactor(0.5)
               .foregroundStyle(.white)
            
            // format date to "Saturday | 22 Jun 2024"
            Text(dateDescription(forecast.date))
               .font(.title3)
               .foregroundStyle(.white)
         }
         
         // push right
         Spacer()
         
         // weather icon
         Image(systemName: forecast.condition.imageName)
            .resizable()
            .scaledToFit()
            .foregroundStyle(.white)
            .frame(maxHeight: 150)
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
               TopBar()
               
               // push down
               Spacer()
               if sizeClass == .compact {
                  // Layout for small screens
                                    
                  CompactWeatherConditions(forecast: currentForecast)
                  
                  // daily conditions
                  DayForecastView(selectedDate: $selectedDate)
                                       
                  // hourly (temperature line) forecast
                  HourlyForecastView()                  
               } else {
                  // Layout for large screens
                  
                  if orientation.isLandscape {
                     RegularWeatherConditions(forecast: currentForecast)
                        .frame(maxHeight: .infinity)
                  } else {
                     CompactWeatherConditions(forecast: currentForecast)
                     
                     DayForecastView(selectedDate: $selectedDate, wide: true)
                  }
                  
                  // LeftBar, activities, hourly forecast and daily forecast
                  // on tablet we use a different layout
                  HStack(spacing: 20) {
                     
                     // left tool bar pane
                     LeftBar()
                     
                     // VStack with activities and hourly temperature line
                     VStack(spacing: 20) {
                        
                        // show activities in your ares
                        ActivitiesView()
                        
                        // hourly (temperature line) forecast
                        HourlyForecastView()
                     }
                     
                     // RightBar, daily conditions, time and air conditions
                      if orientation.isLandscape {
                        RightBar(selectedDate: $selectedDate)//, orientation: orientation)
                      }
                  }
                  .frame(maxHeight: .infinity)
               }
            } // if
         } // main VStack
         .containerRelativeFrame(.vertical) // make VStack the size of container scrollview
         .padding(.horizontal, sizeClass == .compact ? nil : 30)
      } // ScrollView
      .containerRelativeFrame([.horizontal, .vertical]) // make scroll view fill window / screen
      .background(
         // background based on current weather condittions and screen size
         Image(sizeClass == .compact ? "\(backgroundImageName)-compact" : backgroundImageName)
            .resizable() // can be resized
            .ignoresSafeArea() // full screen
            .scaledToFill() // fill view, not fit
      )
      .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
         // One way to detect device rotation, maybe not the best
         // update rotation based on current device orientation
         self.orientation = UIDevice.current.orientation
      }
      .onAppear {
         // set white color on activity indicator
         UIRefreshControl.appearance().tintColor = .white
         // set initial value to selectedDate
         selectedDate = Date()
         // get data from server
         refresh()
         // set initial orientation
         withAnimation {
            orientation = UIDevice.current.orientation
         }
      }
      .refreshable {
         // pull down to refresh
         // and get data from server
          refresh()
      }
      .environment(viewModel)
      // .environment(\.timeZone, TimeZone(secondsFromGMT: 0)!)

   }
}

#Preview {
   WeatherView()
}
