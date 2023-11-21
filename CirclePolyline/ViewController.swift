//
//  ViewController.swift
//  CirclePolyline
//
//  Created by MMI on 16/11/23.
//

import UIKit
import MapplsAPICore
import MapplsAPIKit
import MapplsMap

class ViewController: UIViewController {
    private let directions: Directions = Directions.shared
    private var mapView: MapplsMapView!
    private let centerButton: UIButton = UIButton()
    private var polyineAnnotations: MGLPolyline!
    private var coordinates: [CLLocationCoordinate2D] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setMapView()
        setCenterButton()
    }
    
    func setMapView(){
        mapView = MapplsMapView(frame: view.frame)
        view.addSubview(mapView)
        mapView.delegate = self
        let waypoints = [
            Waypoint(coordinate: CLLocationCoordinate2D(latitude: 23.337517053873405, longitude: 85.31862815574387), name: "SomeName"),
            Waypoint(coordinate: CLLocationCoordinate2D(latitude: 23.333273375059115, longitude: 85.32171329787606), name: "name"),
        ]

        let options = RouteOptions(waypoints: waypoints, resourceIdentifier: .routeAdv, profileIdentifier: .driving)
        options.includesSteps = true

        _ = directions.calculate(options) { (waypoints, routes, error) in
            guard error == nil else {
                print("Error calculating directions: \(error!)")
                return
            }
            
            if let route = routes?.first, let _ = route.legs.first {
                MapplsMapAuthenticator.sharedManager().initializeSDKSession {[self] isSucess, error in
                    if isSucess {
                        polyineAnnotations = MGLPolyline(coordinates: route.coordinates!, count: UInt(route.coordinates!.count))
                        
                        coordinates = route.coordinates!
                        centerButton.addTarget(self, action: #selector(self.centerMapView), for: .touchUpInside)
                    } else {
                        print("error: \(error!.localizedDescription)")
                    }
                }
            }
        }
    }
    
    func setCenterButton(){
        view.addSubview(centerButton)
        centerButton.translatesAutoresizingMaskIntoConstraints = false
        
        centerButton.layer.cornerRadius = 12
        centerButton.backgroundColor = .gray.withAlphaComponent(0.8)
        centerButton.setTitle("Center", for: .normal)
        
        NSLayoutConstraint.activate([
            centerButton.heightAnchor.constraint(equalToConstant: 40),
            centerButton.widthAnchor.constraint(equalToConstant: 100),
            centerButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            centerButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
        ])
    }
    
    @objc func centerMapView(){
        mapView.showAnnotations([polyineAnnotations], animated: true)
    }

    private func setDottedPolyline(){
        
    }
    
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if ((cString.count) != 6) {
            return UIColor.gray
        }

        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}

extension ViewController : MapplsMapViewDelegate {
    func mapView(_ mapView: MGLMapView, regionWillChangeAnimated animated: Bool) {
        
    }
    
    func mapViewDidFinishLoadingMap(_ mapView: MGLMapView) {
        print("mapViewDidFinishLoadingMap")
        if let polyineAnnotations = polyineAnnotations {
            var someFeature: [MGLPointFeature] = []
            mapView.showAnnotations([polyineAnnotations], animated: true)
            for coordinate in coordinates {
                let point = MGLPointFeature()
                point.coordinate = coordinate
                someFeature.append(point)
            }
            let source = MGLShapeSource(identifier: "line", features: someFeature, options: [
                .clustered : true,
                .clusterRadius: 15
            ])
            mapView.style?.addSource(source)
            
            let circleLayer = MGLCircleStyleLayer(identifier: "circle", source: source)
            circleLayer.circleStrokeColor = NSExpression(forConstantValue: UIColor.black)
            circleLayer.circleStrokeOpacity = NSExpression(forConstantValue: 1)
            circleLayer.circleStrokeWidth = NSExpression(forConstantValue: 1)
            circleLayer.circleColor = NSExpression(forConstantValue: hexStringToUIColor(hex: "#03adfc"))
            circleLayer.circleRadius = NSExpression(forConstantValue: 4)
            circleLayer.circleOpacity = NSExpression(forConstantValue: 1)
            
            mapView.style?.addLayer(circleLayer)
        } else {
            let action = UIAlertController(title: "Connection error", message: "", preferredStyle: .alert)
            action.isSpringLoaded = true
            action.addAction(UIAlertAction(title: "Dismiss", style: .default))
            self.present(action, animated: true)
        }
    }
    
    func didSetMapplsMapStyle(_ mapView: MapplsMapView, isSuccess: Bool, withError error: Error?) {
        print("didSetMapplsMapStyle")
    }
}
