//
//  Weather.swift
//  Weatherwise
//
//  Created by Harry Patsis on 21/6/24.
//

import Foundation

enum WeatherCondition: String, Codable {
   case sunny = "Sunny"
   case rainy = "Rainy"
   case cloudy = "Cloudy"
   case stormy = "Stormy"
   case snowy = "Snowy"
   case other = "Other"
   
   init(from decoder: Decoder) throws {
      let container = try decoder.singleValueContainer()
      let value = try container.decode(String.self)
      self = WeatherCondition(rawValue: value) ?? .other
   }
   
   var imageName: String {
      switch self {
         case .sunny: return "sun.max.fill"
         case .rainy: return "cloud.rain.fill"
         case .cloudy: return "cloud.fill"
         case .snowy: return "cloud.snow.fill"
         case .stormy: return "cloud.bolt.rain.fill"
         default: return "sun.max.fill"
      }
   }
}

struct WeatherForecast: Codable {
    let date: Date
    let temperature: Int
    let realFeel: Int
    let uvIndex: Int
    let chanceOfRain: Int
    let windSpeed: Int
    let condition: WeatherCondition
      
   var dateAbbreviated: String {
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "EEE"
      return dateFormatter.string(from: date).uppercased()
   }
   
}
