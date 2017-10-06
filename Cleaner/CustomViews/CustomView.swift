//
//  File2.swift
//  Cleaner
//
//  Created by Hao on 10/2/17.
//  Copyright © 2017 BaBaBiBo. All rights reserved.
//

import UIKit

@IBDesignable
class CustomView: UIView {
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    private var proxyView: CustomView?
    
    @IBInspectable public var title: String = "" {
        didSet {
            self.proxyView!.titleLabel.text = title
        }
    }
    
    @IBInspectable public var avatarImage: UIImage = UIImage() {
        didSet {
            let size = self.avatarImage.size
            let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
            let path = UIBezierPath(ovalIn: rect)
            path.addClip()
            self.avatarImage.draw(in: rect)
            
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            self.proxyView!.avatarImageView.image = image
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let view = self.loadNib()
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleBottomMargin, .flexibleHeight, .flexibleRightMargin, .flexibleLeftMargin, .flexibleTopMargin, .flexibleWidth]
        self.proxyView = view
        self.addSubview(self.proxyView!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func awakeAfterUsingCoder(aDecoder: NSCoder!) -> AnyObject! {
        if self.subviews.count == 0 {
            let view = self.loadNib()
            view.translatesAutoresizingMaskIntoConstraints = false
            let contraints = self.constraints
            self.removeConstraints(contraints)
            view.addConstraints(contraints)
            view.proxyView = view
            return view
        }
        return self
    }
    
    private func loadNib() -> CustomView {
        let bundle = Bundle(for: type(of: self))
        let view = bundle.loadNibNamed("CustomView", owner: nil, options: nil)?[0] as! CustomView
        return view
    }
}

