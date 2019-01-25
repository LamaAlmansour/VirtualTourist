//
//  API.swift
//  VirtualTourist
//
//  Created by Lama on 12/01/2019.
//  Copyright © 2019 Lama. All rights reserved.
//

import Foundation

struct API {

    static let sharedInstance = API()
    
    func getPhotosforLocation(_ latitude: Double, _ longitude: Double,_ page: Int, _ completion: @escaping (_ success: Bool, _ data: [[String: Any]]? ) -> Void) {
        
        
            var randomPage = 1
            
            if page > 0 {
                randomPage = Int(arc4random_uniform(UInt32(page))) + 1
            }
            
        
        let params = [ParameterKeys.APIKey  : Constants.APIKey,
                      ParameterKeys.Method  : Methods.SearchMethod,
                      ParameterKeys.Extras  : ParameterValues.MediumURL,
                      ParameterKeys.Format  : ParameterValues.ResponseFormat,
                      ParameterKeys.Lat     : String(describing: latitude),
                      ParameterKeys.Lon     : String(describing: longitude),
                      ParameterKeys.Page    : randomPage,
            ParameterKeys.PerPage : "20",
            ParameterKeys.NoJSONCallback : ParameterValues.DisableJSONCallback] as [String : Any]
        
        var components = URLComponents()
        components.scheme = Constants.APIScheme
        components.host = Constants.APIHost
        components.path = Constants.APIPath
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in params {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        let request = URLRequest(url: components.url!)
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            func displayError(_ errorString: String) {
                print(errorString)
                completion(false, nil)
                return
            }
            
            /* GUARD: Error-Checking for this request */
            guard (error == nil) else {
                displayError("There was an error with your request.")
                return
            }
            
            /* GUARD: Check for valid respone code for request */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode , statusCode >= 200 && statusCode < 300 else {
                displayError("Unsuccessful request response retured.")
                return
            }
            
            let parsedData: [String: AnyObject]!
            do {
                parsedData = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: AnyObject]
            } catch {
                displayError("Could not parse data")
                return
            }
            
            guard let photos = parsedData[ResponseKeys.Photos] as! [String: Any]?,
                let photo = photos[ResponseKeys.Photo] as! [[String: Any]]? else {
                    displayError("Could not extract photos and/or photo dict")
                    return
            }
            
            completion(true, photo)
        }
        
        task.resume()
    }
}
