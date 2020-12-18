//
//  extensions.swift
//  quizapp
//
//  Created by Joshua De Matas on 2020-12-06.
//

import Foundation
import UIKit

extension String {
    var htmlDecoded: String? {
        let data = Data(utf8)
        let decodedString = try? NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        return decodedString?.string
    }
}

class AppUIButton: UIButton {

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        backgroundColor =  #colorLiteral(red: 0.09808254987, green: 0.26281178, blue: 0.2842366695, alpha: 1)
        setTitleColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), for: .normal)
        layer.cornerRadius = 3
        
        self.addShadowAndRoundedCorners()
    }
}


//MARK: - UIView
extension UIView {
    /// Adds shadow and rounded corners to the view
    func addShadowAndRoundedCorners(shadowRadius: CGFloat = 2.0,
                                    shadowOpacity: Float = 1.0, backgroundColor: CGColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1))
    {
        layer.cornerRadius = 3
        layer.shadowOpacity = shadowOpacity
        layer.shadowOffset = CGSize.zero
        layer.shadowColor = backgroundColor
        layer.shadowRadius = shadowRadius
    }
    
    func addBlur(_ alpha: CGFloat = 0.5) {
        // Create effect
        let effect = UIBlurEffect(style: .dark)
        let effectView = UIVisualEffectView(effect: effect)
        
        // Set Boundry and Alpha
        effectView.frame = self.bounds
        effectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        effectView.alpha = alpha
        
        self.addSubview(effectView)
    }
    
    
    /**
     Courtesy of 'Adman Waite' for this glorious text block
     
     Usage:
     view.addBorder(edges: [.all]) // All with default arguments
     view.addBorder(edges: [.top], color: .green) // Just Top, green, default thickness
     view.addBorder(edges: [.left, .right, .bottom], color: .red, thickness: 3) // All except Top, red, thickness 3
     */
    
    @discardableResult
    func addBorders(edges: UIRectEdge,
                    color: UIColor,
                    inset: CGFloat = 0.0,
                    thickness: CGFloat = 1.0) -> [UIView] {

        var borders = [UIView]()

        @discardableResult
        func addBorder(formats: String...) -> UIView {
            let border = UIView(frame: .zero)
            border.backgroundColor = color
            border.translatesAutoresizingMaskIntoConstraints = false
            addSubview(border)
            addConstraints(formats.flatMap {
                NSLayoutConstraint.constraints(withVisualFormat: $0,
                                               options: [],
                                               metrics: ["inset": inset, "thickness": thickness],
                                               views: ["border": border]) })
            borders.append(border)
            return border
        }


        if edges.contains(.top) || edges.contains(.all) {
            addBorder(formats: "V:|-0-[border(==thickness)]", "H:|-inset-[border]-inset-|")
        }

        if edges.contains(.bottom) || edges.contains(.all) {
            addBorder(formats: "V:[border(==thickness)]-0-|", "H:|-inset-[border]-inset-|")
        }

        if edges.contains(.left) || edges.contains(.all) {
            addBorder(formats: "V:|-inset-[border]-inset-|", "H:|-0-[border(==thickness)]")
        }

        if edges.contains(.right) || edges.contains(.all) {
            addBorder(formats: "V:|-inset-[border]-inset-|", "H:[border(==thickness)]-0-|")
        }

        return borders
    }

}
