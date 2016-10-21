import UIKit

extension UIView {
	
	func addSubviews(views: [String: Any], constrainedBy visualFormats: [String]) {
		views.values.map { $0 as? UIView }.flatMap { $0 }.forEach {
			self.addSubview($0)
			$0.translatesAutoresizingMaskIntoConstraints = false
		}
		let constraints = visualFormats
			.map { NSLayoutConstraint.constraints(withVisualFormat: $0, options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views) }
			.flatMap { $0 }
		addConstraints(constraints)
	}
}

extension Array {
	
	func take(_ count: Int) -> [Element] {
		let i = Swift.min(count, self.count)
		let lim = startIndex.advanced(by: i)
		return Array(self[0..<lim])
	}
}


class InsetTextField: UITextField {
	
	var inset = CGSize.zero
	
	override func textRect(forBounds bounds: CGRect) -> CGRect {
		return rect(forBounds: bounds)
	}
	
	override func editingRect(forBounds bounds: CGRect) -> CGRect {
		return rect(forBounds: bounds)
	}
	
	private func rect(forBounds bounds: CGRect) -> CGRect {
		return bounds.insetBy(dx: inset.width, dy: inset.height)
	}
}



extension UIButton {
	
	static func buttonWithLocationImage(ofLength length: CGFloat) -> UIButton {
		let b = UIButton(type: .custom)
		let img = UIImage.pointyLocationImage(length: length, color: .white)
		b.setImage(img, for: .normal)
		b.adjustsImageWhenHighlighted = false
		b.backgroundColor = b.tintColor
		return b
	}
}

extension UIImage {
	
	static func image(ofSize size: CGSize, opaque: Bool = false, actions: (CGContext)->()) -> UIImage? {
		
		UIGraphicsBeginImageContextWithOptions(size, opaque, 0)
		guard let c = UIGraphicsGetCurrentContext() else { return nil }
		
		actions(c)
		
		let img = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		
		return img
	}
	
	static func pointyLocationImage(length: CGFloat, color: UIColor) -> UIImage? {
		
		let l = length
		let l2 = l/2
		let points = [(l, 0), (l2, l), (l2, l2), (0, l2)].map { CGPoint(x: $0.0, y: $0.1) }
		
		return image(ofSize: CGSize(width: length, height: length)) { ctx in
			
			ctx.move(to: points[0])
			for p in points[1..<points.endIndex] {
				ctx.addLine(to: p)
			}
			ctx.addLine(to: points[0])
			ctx.setFillColor(color.cgColor)
			ctx.fillPath()
		}
	}
}
