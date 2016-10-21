import UIKit
import MapKit

class LocalSearchCompletionView: UIControl {
	
	let completion: MKLocalSearchCompletion
	
	private	let titleLabel = UILabel()
	
	private let subtitleLabel: UILabel = {
		let l = UILabel()
		l.font = UIFont.systemFont(ofSize: 12)
		l.textColor = UIColor.lightGray
		return l
	}()
	
	init(completion: MKLocalSearchCompletion) {
		self.completion = completion
		super.init(frame: .zero)
		
		backgroundColor = .white
		
		titleLabel.text = completion.title
		subtitleLabel.text = completion.subtitle
		
		let views: [String: Any] = [
			"t": titleLabel,
			"s": subtitleLabel
		]
		
		let fmts = [
			"V:|-[t]-(2)-[s]",
			"H:|-[t]-|",
			"H:|-[s]-|",
			]
		
		addSubviews(views: views, constrainedBy: fmts)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func draw(_ rect: CGRect) {
		guard let c = UIGraphicsGetCurrentContext() else { return }
		c.move(to: CGPoint(x: 0, y: rect.height))
		c.addLine(to: CGPoint(x: rect.width, y: rect.height))
		c.setStrokeColor(UIColor.lightGray.cgColor)
		c.strokePath()
	}
}
