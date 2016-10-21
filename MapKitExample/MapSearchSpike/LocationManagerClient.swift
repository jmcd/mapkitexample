import CoreLocation

enum LocationRequestError: Error {
	case restricted
	case denied
	case underlying(Error?)
}

class LocationManagerClient {
	
	private let locman = CLLocationManager()
	private let locmanDelegate = LocationManagerDelegate()
	
	private var currentRequest: (CLLocationCoordinate2D?, LocationRequestError?) -> () = { (_, _) in }
	
	init() {
		locmanDelegate.onChangeStatus = location
		locmanDelegate.onSuccess = { cl in
			self.currentRequest(cl.coordinate, nil)
		}
		locmanDelegate.onFail = { error in
			self.currentRequest(nil, .underlying(error))
		}
		locman.delegate = locmanDelegate
	}
	
	func location(completion: @escaping (CLLocationCoordinate2D?, LocationRequestError?) -> ()) {
		currentRequest = completion
		location(status: CLLocationManager.authorizationStatus())
	}
	
	private func location(status: CLAuthorizationStatus) {
		
		switch status {
		case .notDetermined:
			locman.requestWhenInUseAuthorization()
		case .restricted:
			currentRequest(nil, .restricted)
		case .denied:
			currentRequest(nil, .denied)
		case .authorizedAlways:
			fallthrough
		case .authorizedWhenInUse:
			locman.requestLocation()
		}
	}
}

private class LocationManagerDelegate: NSObject, CLLocationManagerDelegate {
	
	var onChangeStatus: (CLAuthorizationStatus)->() = { _ in }
	var onSuccess: (CLLocation)->() = { _ in }
	var onFail: (Error?)->() = { _ in }
	
	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		onChangeStatus(status)
	}
	
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		guard let loc = locations.first else {
			self.onFail(nil)
			return
		}
		self.onSuccess(loc)
	}
	
	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		self.onFail(error)
	}
}
