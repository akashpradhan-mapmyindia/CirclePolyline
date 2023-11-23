import UIKit
import MapplsAPICore
import MapplsAPIKit
import MapplsMap
import CoreLocation

class ViewController: UIViewController {
    private let directions: Directions = Directions.shared
    private var mapView: MapplsMapView!
    private let centerButton: UIButton = UIButton()
    private var coordinates : [CLLocationCoordinate2D] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setMapView()
        setCenterButton()
    }
    
    func setMapView(){
        mapView = MapplsMapView(frame: view.frame)
        view.addSubview(mapView)
        mapView.delegate = self
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
        mapView.showAnnotations([MGLPolyline(coordinates: &coordinates, count: UInt(coordinates.count))], animated: true)
    }

    private func setDottedPolyline(){
        let waypoints = [
            Waypoint(coordinate: CLLocationCoordinate2D(latitude: 23.337517053873405, longitude: 85.31862815574387), name: "SomeName"),
            Waypoint(coordinate: CLLocationCoordinate2D(latitude: 23.333273375059115, longitude: 85.32171329787606), name: "name")
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
                        coordinates = route.coordinates!
                        mapView.showAnnotations([MGLPolyline(coordinates: &coordinates, count: UInt(coordinates.count))], animated: true)
                        
                        let source = MGLShapeSource(identifier: "line", shape: MGLPolyline(coordinates: &coordinates, count: UInt(coordinates.count)) , options: nil)
                        mapView.style?.addSource(source)
                        let layer = dotRouteStyleLayer(identifier: "line-dotted", source: source)
                        mapView.style?.addLayer(layer)
                        
                        centerButton.addTarget(self, action: #selector(self.centerMapView), for: .touchUpInside)
                    } else {
                        print("error: \(error!.localizedDescription)")
                    }
                }
            }
        }
    }
    
    public let MBRouteDotSpacingByZoomLevel: [Double: NSExpression] = [
        1: NSExpression(forConstantValue:1.0),
        2: NSExpression(forConstantValue:1.0),
        3: NSExpression(forConstantValue:1.0),
        4: NSExpression(forConstantValue:1.0),
        5: NSExpression(forConstantValue:1.0),
        6: NSExpression(forConstantValue:2.0),
        7: NSExpression(forConstantValue:3.0),
        8: NSExpression(forConstantValue:4.0),
        9: NSExpression(forConstantValue:5.0),
        10: NSExpression(forConstantValue:6.0),
        22: NSExpression(forConstantValue:30.0)
    ]

    func dotRouteStyleLayer(identifier: String, source: MGLSource) -> MGLStyleLayer {
        let shapeLayer = MGLSymbolStyleLayer(identifier: identifier, source: source)
        
        if let style = mapView.style, style.image(forName: "dot-image") == nil,  let image = UIImage(named: "dotImage") {
            style.setImage(image, forName: "dot-image")
        }
        
        shapeLayer.minimumZoomLevel = 3.0
        shapeLayer.iconImageName = NSExpression(forConstantValue: "dot-image")
        
        shapeLayer.iconAllowsOverlap = NSExpression(forConstantValue: true)
        shapeLayer.symbolPlacement =  NSExpression(forConstantValue: NSValue(mglSymbolPlacement: .line))
        //format: "mgl_interpolate:withCurveType:parameters:stops:($zoomLevel, 'linear', nil, %@)", MBRouteDotSpacingByZoomLevel
        shapeLayer.symbolSpacing =  NSExpression(forConstantValue: 2)
        shapeLayer.iconScale = NSExpression(forConstantValue: 0.4)
        
        return shapeLayer
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
        setDottedPolyline()
    }
    
    func didSetMapplsMapStyle(_ mapView: MapplsMapView, isSuccess: Bool, withError error: Error?) {
        print("didSetMapplsMapStyle")
    }
}

