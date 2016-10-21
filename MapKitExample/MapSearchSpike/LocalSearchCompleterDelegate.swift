import MapKit

class LocalSearchCompleterDelegate: NSObject, MKLocalSearchCompleterDelegate {
	
	let onReceiveResults: ([MKLocalSearchCompletion]) -> ()
	
	init(onReceiveResults: @escaping ([MKLocalSearchCompletion]) -> ()) {
		self.onReceiveResults = onReceiveResults
	}
	
	func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
		onReceiveResults(completer.results)
	}
	
	func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
		onReceiveResults([])
	}
}
