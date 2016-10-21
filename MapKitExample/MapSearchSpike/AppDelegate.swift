import UIKit
import MapKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?
	
	let locprov = LocationManagerClient()

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		
		let vc = MapViewController()
		
		vc.didGetSearchResponse = { (resp, map) in
			guard let item = resp.mapItems.first else { return }
			map.zoomTo(location: item.placemark.coordinate)
		}
		
		vc.didRequestLocation = { map in
			self.locprov.location { (loc, err) in
				guard let loc = loc else { /* your error handlling here */ return }
				map.zoomTo(location: loc)
			}
		}
		
		let w = UIWindow(frame: UIScreen.main.bounds)
		w.rootViewController = vc
		w.makeKeyAndVisible()
		
		window = w		
		
		return true
	}

}

extension MKMapView {
	
	func zoomTo(location: CLLocationCoordinate2D, regionLength: CLLocationDistance = 1000, animated: Bool = true) {
		let region = MKCoordinateRegionMakeWithDistance(location, regionLength/2, regionLength/2)
		setRegion(region, animated: animated)
	}
}
