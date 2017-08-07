//
//  ISS.swift
//  ARGlobe
//
//  Created by Ryan Pasecky on 8/5/17.
//  Copyright © 2017 Ryan Pasecky. All rights reserved.
//

import Foundation
import SceneKit

class ISS {
    
    var positions = [Position]()
    
    struct Position: Codable {
        let name : String
        let id : Int
        let latitude : Float
        let longitude : Float
        let altitude : Float
        let velocity : Float
        let visibility : String
        let footprint : Float
        let timestamp : Int
        let daynum : Float
        let solar_lat : Float
        let solar_lon : Float
        let units : String
    }
    
    init() {
        getISSPositions()
    }
    
    func makeISSLeadNode() -> SCNNode {
        let boxNode = SCNNode(geometry: SCNBox(width: 0.05, height: 0.05, length: 0.05, chamferRadius: 0))
        boxNode.geometry?.firstMaterial?.diffuse.contents = UIColor.red
        
        let pulseSize:CGFloat = 0.1
        let pulsePlane = SCNPlane(width: pulseSize, height: pulseSize)
        pulsePlane.firstMaterial?.isDoubleSided = true
        pulsePlane.firstMaterial?.diffuse.contents = UIColor.blue
        let pulseNode = SCNNode(geometry: pulsePlane)
    
        let pulseShaderModifier =
        "#pragma transparent; \n" +
        "vec4 originalColour = _surface.diffuse; \n" +
        "vec4 transformed_position = u_inverseModelTransform * u_inverseViewTransform * vec4(_surface.position, 1.0); \n" +
        "vec2 xy = vec2(transformed_position.x, transformed_position.y); \n" +
        "float xyLength = length(xy); \n" +
        "float xyLengthNormalised = xyLength/" + String(describing: pulseSize / 2) + "; \n" +
        "float speedFactor = 1.5; \n" +
        "float maxDist = fmod(u_time, speedFactor) / speedFactor; \n" +
        "float distbasedalpha = step(maxDist, xyLengthNormalised); \n" +
        "distbasedalpha = max(distbasedalpha, maxDist); \n" +
        "_surface.diffuse = mix(originalColour, vec4(0.0), distbasedalpha);"
    
        pulsePlane.firstMaterial?.shaderModifiers = [SCNShaderModifierEntryPoint.surface:pulseShaderModifier]
        boxNode.addChildNode(pulseNode)
        
        return boxNode
    }
    

    
    func makeURL() -> URL {
        
        let currentEpochTime = Date().timeIntervalSince1970
        
        //let urlString = "https://api.wheretheiss.at/v1/satellites/25544/positions?timestamps=\(currentEpochTime),\(currentEpochTime - 100),\(currentEpochTime - 200),\(currentEpochTime - 300),\(currentEpochTime - 400),\(currentEpochTime - 500),\(currentEpochTime - 600)&units=miles"
        
        let urlString = "https://api.wheretheiss.at/v1/satellites/25544/positions?timestamps=\(currentEpochTime)&units=miles"
        
        print(urlString)
        
        return URL(string: urlString)!
    }
    
    func getISSPositions() {
        
        let url = makeURL()
        var request = URLRequest(url: url)
        
        request.httpMethod = "GET"
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: request) { (responseData, response, responseError) in
            DispatchQueue.main.async {
                guard responseError == nil else {
                    return
                }
                guard let jsonData = responseData else {
                    let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "Data was not retrieved from request"]) as Error
                    return
                }
                
                let decoder = JSONDecoder()
                
                do {
                    
                    let position = try decoder.decode([Position].self, from: jsonData)
                    
                    if let returnedPosition = position.first {
                        self.positions.append(returnedPosition)
                    }
                    //let posts = try? decoder.decode([Post].self, from: jsonData)
                
                    } catch {
                }
            }
        }
        task.resume()
        
    }
    
    func getCurrentStoredPositions() -> [Position] {
        return self.positions
    }
}
