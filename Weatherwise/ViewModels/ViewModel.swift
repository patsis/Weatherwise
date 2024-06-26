//
//  WeatherModel.swift
//  Weatherwise
//
//  Created by Harry Patsis on 21/6/24.
//

import SwiftUI

// Custom error types for more specific error handling
enum FetchWeatherError: Error {
   case invalidURL
   case unknownError
   case networkError(Error)
   case serverError(Int)
   case decodingError(Error)
}

// api url strings
enum FetchWeatherEndPoint: String {
   case daily = "https://test.dev.datawise.ai/daily"
   case hourly = "https://test.dev.datawise.ai/hourly"
}

@Observable
public class ViewModel {
   
   // observable arrays
   var dailyForecast: [WeatherForecast] = []
   var hourlyForecast: [WeatherForecast] = []

   // hourly JSON for debug
   private let hourlyJson = """
[{"date":"2024-06-23T10:11:23.604Z","temperature":17,"realFeel":19,"uvIndex":10,"chanceOfRain":79,"windSpeed":19,"condition":"Sunny"},{"date":"2024-06-23T09:11:23.604Z","temperature":39,"realFeel":38,"uvIndex":4,"chanceOfRain":58,"windSpeed":5,"condition":"Sunny"},{"date":"2024-06-23T08:11:23.604Z","temperature":29,"realFeel":30,"uvIndex":3,"chanceOfRain":42,"windSpeed":16,"condition":"Cloudy"},{"date":"2024-06-23T07:11:23.604Z","temperature":28,"realFeel":29,"uvIndex":6,"chanceOfRain":18,"windSpeed":24,"condition":"Rainy"},{"date":"2024-06-23T06:11:23.604Z","temperature":25,"realFeel":24,"uvIndex":9,"chanceOfRain":67,"windSpeed":20,"condition":"Cloudy"},{"date":"2024-06-23T05:11:23.604Z","temperature":26,"realFeel":27,"uvIndex":1,"chanceOfRain":75,"windSpeed":24,"condition":"Sunny"},{"date":"2024-06-23T04:11:23.604Z","temperature":18,"realFeel":20,"uvIndex":3,"chanceOfRain":63,"windSpeed":15,"condition":"Sunny"},{"date":"2024-06-23T03:11:23.604Z","temperature":11,"realFeel":11,"uvIndex":10,"chanceOfRain":90,"windSpeed":6,"condition":"Cloudy"},{"date":"2024-06-23T02:11:23.604Z","temperature":36,"realFeel":38,"uvIndex":5,"chanceOfRain":14,"windSpeed":22,"condition":"Sunny"},{"date":"2024-06-23T01:11:23.604Z","temperature":17,"realFeel":15,"uvIndex":0,"chanceOfRain":37,"windSpeed":19,"condition":"Rainy"},{"date":"2024-06-23T00:11:23.604Z","temperature":33,"realFeel":33,"uvIndex":3,"chanceOfRain":37,"windSpeed":20,"condition":"Rainy"},{"date":"2024-06-22T23:11:23.604Z","temperature":16,"realFeel":15,"uvIndex":10,"chanceOfRain":51,"windSpeed":23,"condition":"Sunny"},{"date":"2024-06-22T22:11:23.604Z","temperature":27,"realFeel":26,"uvIndex":9,"chanceOfRain":23,"windSpeed":24,"condition":"Snowy"},{"date":"2024-06-22T21:11:23.604Z","temperature":37,"realFeel":39,"uvIndex":1,"chanceOfRain":28,"windSpeed":15,"condition":"Rainy"},{"date":"2024-06-22T20:11:23.604Z","temperature":11,"realFeel":9,"uvIndex":5,"chanceOfRain":43,"windSpeed":16,"condition":"Rainy"},{"date":"2024-06-22T19:11:23.604Z","temperature":33,"realFeel":31,"uvIndex":3,"chanceOfRain":40,"windSpeed":10,"condition":"Sunny"},{"date":"2024-06-22T18:11:23.604Z","temperature":22,"realFeel":21,"uvIndex":5,"chanceOfRain":92,"windSpeed":12,"condition":"Sunny"},{"date":"2024-06-22T17:11:23.604Z","temperature":23,"realFeel":24,"uvIndex":0,"chanceOfRain":70,"windSpeed":19,"condition":"Rainy"},{"date":"2024-06-22T16:11:23.604Z","temperature":39,"realFeel":40,"uvIndex":1,"chanceOfRain":64,"windSpeed":9,"condition":"Snowy"},{"date":"2024-06-22T15:11:23.604Z","temperature":12,"realFeel":11,"uvIndex":10,"chanceOfRain":43,"windSpeed":14,"condition":"Cloudy"},{"date":"2024-06-22T14:11:23.604Z","temperature":27,"realFeel":28,"uvIndex":9,"chanceOfRain":5,"windSpeed":9,"condition":"Snowy"},{"date":"2024-06-22T13:11:23.604Z","temperature":32,"realFeel":31,"uvIndex":8,"chanceOfRain":71,"windSpeed":21,"condition":"Snowy"},{"date":"2024-06-22T12:11:23.604Z","temperature":25,"realFeel":26,"uvIndex":10,"chanceOfRain":59,"windSpeed":7,"condition":"Cloudy"},{"date":"2024-06-22T11:11:23.604Z","temperature":36,"realFeel":10,"uvIndex":3,"chanceOfRain":48,"windSpeed":24,"condition":"Cloudy"}]
"""
   // daily JSON for debug
   private let dailyJson = """
[{"date":"2024-06-23T10:15:41.002Z","temperature":36,"realFeel":36,"uvIndex":6,"chanceOfRain":37,"windSpeed":15,"condition":"Snowy"},{"date":"2024-06-24T10:15:41.002Z","temperature":33,"realFeel":35,"uvIndex":1,"chanceOfRain":1,"windSpeed":11,"condition":"Sunny"},{"date":"2024-06-25T10:15:41.002Z","temperature":21,"realFeel":22,"uvIndex":2,"chanceOfRain":20,"windSpeed":24,"condition":"Snowy"},{"date":"2024-06-26T10:15:41.002Z","temperature":25,"realFeel":27,"uvIndex":0,"chanceOfRain":32,"windSpeed":9,"condition":"Snowy"},{"date":"2024-06-27T10:15:41.002Z","temperature":35,"realFeel":34,"uvIndex":6,"chanceOfRain":21,"windSpeed":23,"condition":"Rainy"},{"date":"2024-06-28T10:15:41.002Z","temperature":35,"realFeel":33,"uvIndex":6,"chanceOfRain":98,"windSpeed":11,"condition":"Rainy"},{"date":"2024-06-29T10:15:41.002Z","temperature":12,"realFeel":13,"uvIndex":5,"chanceOfRain":22,"windSpeed":7,"condition":"Stormy"}]
"""
   
   private func fetchForecast(type: FetchWeatherEndPoint) async throws -> [WeatherForecast] {
      // try to create the URL from url string
      // this shouldn't fail with hardcoded url strings
      guard let url = URL(string: type.rawValue) else {
         throw FetchWeatherError.invalidURL
      }
      
      do {
         // try to fetch data and response from server
         let (data, response) = try await URLSession.shared.data(from: url)
         
         // check response: convert to HTTPURLResponse
         guard let httpResponse = response as? HTTPURLResponse else {
            throw FetchWeatherError.unknownError
         }
         
         // check http status code: if not success, throw error
         guard httpResponse.statusCode == 200 else {
            throw FetchWeatherError.serverError(httpResponse.statusCode)
         }
         
         // create a JSONDecoder for our data
         let jsonDecoder = JSONDecoder()
         let dateFormatter = DateFormatter()
         // set the correct date format used in JSON
         dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
         jsonDecoder.dateDecodingStrategy = .formatted(dateFormatter)
         
         do {
            // try to decode JSON data to [WeatherForecast]
            return try jsonDecoder.decode([WeatherForecast].self, from: data).sorted { $0.date < $1.date }
         } catch {
            // something went wrong decoding
            throw FetchWeatherError.decodingError(error)
         }
      } catch {
         // something went wront downloading
         throw FetchWeatherError.networkError(error)
      }
   }
   
   // used only for debug to avoid continuously fetching data from servers. Uses hardcoded JSON
   private func fromJSON(type: FetchWeatherEndPoint) throws -> [WeatherForecast] {
      let jsonData = type == .daily ? dailyJson.data(using: .utf8)! : hourlyJson.data(using: .utf8)!
      let jsonDecoder = JSONDecoder()
      let dateFormatter = DateFormatter()
      // set the correct date format used in JSON
      dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
      jsonDecoder.dateDecodingStrategy = .formatted(dateFormatter)
      
      do {
         return try jsonDecoder.decode([WeatherForecast].self, from: jsonData).sorted { $0.date < $1.date }
      } catch {
         throw FetchWeatherError.decodingError(error)
      }
   }
   
   func update() async throws {
      // detect xcode preview
      if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
         // use these when in preview to avoid continuously fetching data from servers.
          dailyForecast = try fromJSON(type: .daily)
          hourlyForecast = try fromJSON(type: .hourly)
         return
      }
      
      dailyForecast = try await fetchForecast(type: .daily)
      hourlyForecast = try await fetchForecast(type: .hourly)

   }
}


