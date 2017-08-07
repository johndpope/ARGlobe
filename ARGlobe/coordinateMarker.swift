//
//  Coordinate.swift
//  ARGlobe
//
//  Created by Ryan Pasecky on 8/4/17.
//  Copyright © 2017 Ryan Pasecky. All rights reserved.
//

import SceneKit

class coordinateMarker : SCNNode {
    
    var radius : Double
    
    
    init(markerInfo: coordinateData, radius: Double) {
        
        self.radius = radius
        
        super.init()
        
        self.convertLLAtoECEF(coordinateData: markerInfo, radius: radius)
        
        self.geometry = SCNSphere(radius: 0.0015)
        let markerMaterial = SCNMaterial()
        markerMaterial.diffuse.contents = UIColor.red
        
        self.geometry!.materials = [markerMaterial]
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addPoles() {
        /*
        coordinateData(label: "lat0 long0", latitude: 0, longitude: 0, altitude: 0),
        coordinateData(label: "lat0 long90", latitude: 0, longitude: 90, altitude: 0),
        coordinateData(label: "lat0 long-90", latitude: 0, longitude: -90, altitude: 0),
        coordinateData(label: "lat90 long0", latitude: 90, longitude: 0, altitude: 0),
        coordinateData(label: "lat-90 long0", latitude: -90, longitude: 0, altitude: 0),
        coordinateData(label: "lat0 long180", latitude: 0, longitude: 180, altitude: 0)*/
    }
    func convertLLAtoECEF(coordinateData: coordinateData, radius: Double) {
        //Thanks CodingAway https://stackoverflow.com/questions/10473852/convert-latitude-and-longitude-to-point-in-3d-space
        let rad = radius  //6378137.0       //Radius of the Earth (in meters)
        let f = 1.0/298.257223563  // Flattening factor WGS84 Model
        let longRad = (-coordinateData.longitude + 90) * .pi / 180
        let latRad = (coordinateData.latitude) * .pi / 180
        
        let cosLat = cos(latRad)
        let sinLat = sin(latRad)
        let FF     = pow(1.0 - f, 2)
        let C      = 1 / sqrt(pow(cosLat, 2) + FF * pow(sinLat, 2))
        let S      = C * FF
        
        self.position.x = Float((rad * C + coordinateData.altitude) * cosLat * cos(longRad))
        self.position.y = Float((rad * S + coordinateData.altitude) * sinLat)
        self.position.z = Float((rad * C + coordinateData.altitude) * cosLat * sin(longRad))
        
        print("position: \(self.position)")
        
        
    }
}

struct coordinateData {
    
    let label: String
    let latitude: Double
    let longitude: Double
    let altitude: Double
    
    init(label: String, latitude: Double, longitude: Double, altitude: Double) {
        self.label = label
        self.latitude = latitude
        self.longitude = longitude
        self.altitude = altitude
    }
}
