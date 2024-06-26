//
//  HourForecastView.swift
//  Weatherwise
//
//  Created by Harry Patsis on 24/6/24.
//

import SwiftUI

fileprivate struct TemperatureNowLine: Shape {

   var point: CGPoint
   var distance: CGFloat = 60

   func path(in rect: CGRect) -> Path {
      var path = Path()
      path.move(to: point)
      path.addLine(to: CGPoint(x: point.x, y: point.y + distance))
      return path
   }
}

fileprivate struct TemperatureCurve: Shape {
   
   // points holds the pre-calculated points of temperature for every hour
   var points: [CGPoint]
   
   /// This function takes as input an array of points (nodes) and creates a smooth cubic bezier path by interpollating the points
   /// It uses the 'hermite interpolation' algorithm for interpollation.
   /// Returns a smooth bezier from temperature values
   func createPathFromValues(points: [CGPoint], rect: CGRect) -> Path {
      var path = Path()
      if points.count > 1 {
         var previousPoint: CGPoint? = nil
         var currentPoint:  CGPoint  = points[0]
         var nextPoint:     CGPoint? = points[1]
         path.move(to: currentPoint)
         for index in 0 ... points.count {
            if let endPoint = nextPoint {
               var mx: CGFloat
               var my: CGFloat
               if previousPoint != nil {
                  mx = (endPoint.x - currentPoint.x) * 0.5 + (currentPoint.x - previousPoint!.x) * 0.5
                  my = (endPoint.y - currentPoint.y) * 0.5 + (currentPoint.y - previousPoint!.y) * 0.5
               } else {
                  mx = (endPoint.x - currentPoint.x) * 0.5
                  my = (endPoint.y - currentPoint.y) * 0.5
               }
               
               let ctrlPt1 = CGPoint(x: currentPoint.x + mx / 3.0, y: currentPoint.y + my / 3.0)
               
               previousPoint = currentPoint
               currentPoint = endPoint
               let nextIndex = index + 2
               nextPoint = nextIndex < points.count ? points[nextIndex] : nil
               if nextPoint != nil {
                  mx = (nextPoint!.x - currentPoint.x) * 0.5 + (currentPoint.x - previousPoint!.x) * 0.5
                  my = (nextPoint!.y - currentPoint.y) * 0.5 + (currentPoint.y - previousPoint!.y) * 0.5
               }
               else {
                  mx = (currentPoint.x - previousPoint!.x) * 0.5
                  my = (currentPoint.y - previousPoint!.y) * 0.5
               }
               let ctrlPt2 = CGPoint(x: currentPoint.x - mx / 3.0, y: currentPoint.y - my / 3.0)
               path.addCurve(to: endPoint, control1: ctrlPt1, control2: ctrlPt2)
            }
         }
      } else {
         path.move(to: CGPoint(x: 0, y: 0.5 * rect.height))
         path.addLine(to: CGPoint(x: rect.width, y: 0.5 * rect.height))
      }
      return path
   }
   
   func path(in rect: CGRect) -> Path {

      // create a smooth cubic bezier path and return it
      let path = createPathFromValues(points: points, rect: rect)
      return path
   }
}

struct HourForecastView: View {
   @Environment(\.horizontalSizeClass) var sizeClass
   
   // hourly forecast
   var forecast: [WeatherForecast]
   
   // temperatures mapped to 0...1
   // where 0 is the minimum temperature
   // and 1 is the maximum temperature of the hourly values
   private var temperaturesMapped: [CGFloat]
   
   // these are the actual points calculated
   @State private var points: [CGPoint] = []
   
   // local variable to keep geometry size
   @State private var size = CGSize.zero
   
   // desiredCellWidth is the width of each cell on the temperature line
   private let desiredCellWidth: CGFloat = 50

   /// init and create locals, needed for temperaturesMapped
   init(forecast: [WeatherForecast]) {
      self.forecast = forecast
      
      // get array of temperatures
      let temperatures = forecast.map { $0.temperature }
      
      // calc min & max temperature so we can then calculate temperaturesMapped (0...1)
      if let minTemperature = temperatures.min(),
         let maxTemperature = temperatures.max(),
         maxTemperature != minTemperature {
         // map the absolute temperatures to 0...1 range,
         self.temperaturesMapped = temperatures.map {
            CGFloat($0 - minTemperature) / CGFloat(maxTemperature - minTemperature)
         }
      } else {
         temperaturesMapped = []
      }
   }
   
   /// calculate points (x, y) for the temperatures that will be shown
   /// these points will be used for creating interpollated temperature line,
   /// and positions for all labels and images
   private func calcPoints(size: CGSize) -> [CGPoint] {
      // count of cells that fit in given size
      let count = min(temperaturesMapped.count - 1, Int(size.width / desiredCellWidth))
      
      // calculate actual cellWidth in order to fit the line in given size
      let cellWidth = size.width / CGFloat(count)
      
      // calculate the array of points
      let points = (0...count).map {
         CGPoint(x: CGFloat($0) * cellWidth, y: size.height - temperaturesMapped[$0] * size.height)
      }
      
      return points
   }
   
   var body: some View {
      VStack {
         ZStack {
            // show the smooth bezier curve
            TemperatureCurve(points: points)
               .stroke(style: StrokeStyle(lineWidth: 2))
               .foregroundStyle(Color("someYellow"))

            if let point0 = points.first {
               // show the vertical dashed line
               TemperatureNowLine(point: point0, distance: 40)
                  .stroke(style: StrokeStyle(lineWidth: 1, dash: [3]))
                  .foregroundStyle(Color("someYellow"))
            }
            
            // ForEach points indices.
            // We can safely use the same indices on self.forecast to show weather info
            ForEach(points.indices, id: \.self) { i in
               // show info for every 2 hours
               if i % 2 == 0 {
                  // show dots
                  Circle()
                     .fill(.white)
                     .frame(width: i == 0 ? 6 : 4, height: i == 0 ? 6 : 4) // just a visual detail, the first dot is larger
                     .position(x: points[i].x, y: points[i].y)
                  
                  // temperature for each cell
                  Text("\(forecast[i].temperature)°")
                     .foregroundStyle(.white)
                     // place above line
                     .position(x: 4 + points[i].x, y:  points[i].y - 15)
                  
                  // show condition icons
                  Image(systemName: forecast[i].condition.imageName)
                     .font(.title)
                     .foregroundStyle(.white)
                     // place below line with a set distance
                     .position(x: points[i].x, y:  points[i].y + 40)
                  
                  if sizeClass == .regular {
                     Text(forecast[i].date, style: .time)
                        .font(.caption2)
                        .foregroundStyle(.white)
                        // place below line with a set distance
                        .position(x: points[i].x, y:  points[i].y + 65)
                  }
               }
            }
         } // ZStack
         .frame(height: 50)
         .background( GeometryReader { (geometry) -> Path in
            DispatchQueue.main.async { // to avoid warning
               size = geometry.size
               points = calcPoints(size: size)
            }
            return Path()
         })
         
         Spacer() // push up
      } // VStack
      .frame(maxHeight: .infinity)
   }
}
