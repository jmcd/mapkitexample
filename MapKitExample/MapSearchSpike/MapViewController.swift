import UIKit
import MapKit


class MapViewController: UIViewController {
	
	var maxResultCount = 4
	var didGetSearchResponse = { (response: MKLocalSearchResponse, mapView: MKMapView) in }
	var didRequestLocation = { (mapView: MKMapView) in }
	
	private let completer = MKLocalSearchCompleter()
	private var completerDelegate: MKLocalSearchCompleterDelegate?
	private var currentSearch: MKLocalSearch?
	
	private let queryTextField = InsetTextField()
	private var completionViewContainer: UIView?
	
	private static let completionViewHeight = CGFloat(55)
	
	override func loadView() {
		view = MKMapView()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = .white
		
		completerDelegate = LocalSearchCompleterDelegate {
			let limitedResults = $0.take(self.maxResultCount)
			self.replaceResults(completions: limitedResults)
		}
		
		completer.delegate = completerDelegate
		completer.filterType = .locationsOnly
		
		queryTextField.inset = CGSize(width: 10, height: 10)
		queryTextField.placeholder = "Search for a place"
		queryTextField.autocorrectionType = .no
		queryTextField.backgroundColor = .white
		queryTextField.addTarget(self, action: #selector(textChanged), for: .editingChanged)
		
		let locationButton = UIButton.buttonWithLocationImage(ofLength: 25)
		locationButton.addTarget(self, action: #selector(locationButtonTapped), for: .touchUpInside)
		
		let views: [String: Any] = [
			"tlg": topLayoutGuide,
			"qtf": queryTextField,
			"lbtn": locationButton,
			"blg": bottomLayoutGuide]
		
		let fmts = [
			"V:[tlg]-[qtf]",
			"H:|-[qtf]-|",
			"V:[lbtn(44)]-[blg]",
			"H:[lbtn(44)]-|"
		]
		
		view.addSubviews(views: views, constrainedBy: fmts)
	}
	
	func replaceResults(completions: [MKLocalSearchCompletion]) {
		
		self.completionViewContainer?.removeFromSuperview()
		self.completionViewContainer = nil
		
		guard completions.count > 0 else { return }
		
		let completionViewContainer = makeViewContainingCompletionViews(completions: completions)
		self.completionViewContainer = completionViewContainer
		
		let containerHeight = MapViewController.completionViewHeight * CGFloat(completions.count)
		
		let views: [String: Any] = [
			"qtf": queryTextField,
			"cvc": completionViewContainer
		]
		
		let fmts = [
			"V:[qtf]-[cvc(\(containerHeight))]",
			"H:|-[cvc]-|",
			]
		
		view.addSubviews(views: views, constrainedBy: fmts)
	}
	
	private func makeViewContainingCompletionViews(completions: [MKLocalSearchCompletion]) -> UIView {
		
		let completionViews = completions.map { (completion: MKLocalSearchCompletion) -> LocalSearchCompletionView in
			let cv = LocalSearchCompletionView(completion: completion)
			cv.addTarget(self, action: #selector(completionViewTapped), for: .touchUpInside)
			return cv
		}
		
		let stackView = UIStackView(arrangedSubviews: completionViews)
		stackView.axis = .vertical
		stackView.distribution = .fillEqually
		
		return stackView
	}
	
	// MARK - callbacks
	
	@objc
	func textChanged(sender: UITextField) {
		guard let queryFragment = sender.text else { return }
		completer.queryFragment = queryFragment
	}
	
	@objc
	func completionViewTapped(sender: LocalSearchCompletionView) {
		replaceResults(completions: [])
		queryTextField.resignFirstResponder()
		let request = MKLocalSearchRequest(completion: sender.completion)
		let search = MKLocalSearch(request: request)
		search.start { (response: MKLocalSearchResponse?, error: Error?) in
			guard let response = response, let mapView = self.view as? MKMapView, error == nil else { return }
			self.didGetSearchResponse(response, mapView)
		}
		currentSearch?.cancel()
		currentSearch = search
	}
	
	@objc
	func locationButtonTapped(sender: UIButton) {
		guard let mapView = view as? MKMapView else { return }
		didRequestLocation(mapView)
	}
}



