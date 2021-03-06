//
//  NKRatingView.swift
//  NKStarViewDemo
//
//  Created by TecOrb on 25/05/18.
//  Copyright © 2018 Nakul Sharma. All rights reserved.
//


import UIKit

@objc public protocol NKRatingViewDelegate {
    /**
     Returns the rating value when touch events end
     */
    func ratingView(ratingView: NKRatingView, didUpdate rating: Double)

    /**
     Returns the rating value as the user pans
     */
    @objc optional func ratingView(ratingView: NKRatingView, isUpdating rating: Double)

}

/**
 A simple rating view that can set whole, half or floating point ratings.
 */
@IBDesignable
public class NKRatingView: UIView {

    // MARK: Rating View properties

    public weak var delegate: NKRatingViewDelegate?

    /**
     Array of empty image views
     */
    private var emptyImageViews: [UIImageView] = []

    /**
     Array of full image views
     */
    private var fullImageViews: [UIImageView] = []

    /**
     Sets the empty image (e.g. a star outline)
     */
    @IBInspectable public var emptyImage: UIImage? {
        didSet {
            // Update empty image views
            for imageView in self.emptyImageViews {
                imageView.image = emptyImage
            }
            self.refresh()
        }
    }

    /**
     Sets the full image that is overlayed on top of the empty image.
     Should be same size and shape as the empty image.
     */
    @IBInspectable public var fullImage: UIImage? {
        didSet {
            // Update full image views
            for imageView in self.fullImageViews {
                imageView.image = fullImage
            }
            self.refresh()
        }
    }

    /**
     Sets the empty and full image view content mode.
     */
    var imageContentMode: UIViewContentMode = UIViewContentMode.scaleAspectFit

    /**
     Minimum rating.
     */
    @IBInspectable public var minRating: Int  = 0 {
        didSet {
            // Update current rating if needed
            if self.rating < Double(minRating) {
                self.rating = Double(minRating)
                self.refresh()
            }
        }
    }

    /**
     Max rating value.
     */
    @IBInspectable public var maxRating: Int = 5 {
        didSet {
            let needsRefresh = maxRating != oldValue

            if needsRefresh {
                self.removeImageViews()
                self.initImageViews()

                // Relayout and refresh
                self.setNeedsLayout()
                self.refresh()
            }
        }
    }

    /**
     Minimum image size.
     */
    @IBInspectable public var minImageSize: CGSize = CGSize(width: 5.0, height: 5.0)

    /**
     Set the current rating.
     */
    @IBInspectable public var rating: Double = 0 {
        didSet {
            if rating != oldValue {
                self.refresh()
            }
        }
    }

    /**
     Sets whether or not the rating view can be changed by panning.
     */
    @IBInspectable public var editable: Bool = true

    /**
     Ratings change by 0.5. Takes priority over floatRatings property.
     */
    @IBInspectable public var halfRatings: Bool = false

    /**
     Ratings change by floating point values.
     */
    @IBInspectable public var floatRatings: Bool = false


    // MARK: Initializations

    required override public init(frame: CGRect) {
        super.init(frame: frame)

        self.initImageViews()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.initImageViews()
    }

    // MARK: Refresh hides or shows full images

    func refresh() {
        for i in 0..<self.fullImageViews.count {
            let imageView = self.fullImageViews[i]

            if self.rating>=Double(i+1) {
                imageView.layer.mask = nil
                imageView.isHidden = false
            }else if self.rating>Double(i) && self.rating<Double(i+1) {
                // Set mask layer for full image
                let maskLayer = CALayer()
                maskLayer.frame = CGRect(x:0,y: 0, width: CGFloat(self.rating-Double(i))*imageView.frame.size.width, height: imageView.frame.size.height)
                maskLayer.backgroundColor = UIColor.black.cgColor
                imageView.layer.mask = maskLayer
                imageView.isHidden = false
            }
            else {
                imageView.layer.mask = nil;
                imageView.isHidden = true
            }
        }
    }

    // MARK: Layout helper classes

    // Calculates the ideal ImageView size in a given CGSize
    func sizeForImage(image: UIImage, inSize size:CGSize) -> CGSize {
        let imageRatio = image.size.width / image.size.height
        let viewRatio = size.width / size.height

        if imageRatio < viewRatio {
            let scale = size.height / image.size.height
            let width = scale * image.size.width

            return CGSize(width:width, height:size.height)
        }
        else {
            let scale = size.width / image.size.width
            let height = scale * image.size.height

            return CGSize(width:size.width,height: height)
        }
    }

    // Override to calculate ImageView frames
    override public func layoutSubviews() {
        super.layoutSubviews()

        if let emptyImage = self.emptyImage {
            let desiredImageWidth = self.frame.size.width / CGFloat(self.emptyImageViews.count)
            let maxImageWidth = max(self.minImageSize.width, desiredImageWidth)
            let maxImageHeight = max(self.minImageSize.height, self.frame.size.height)
            let imageViewSize = self.sizeForImage(image: emptyImage, inSize: CGSize(width:maxImageWidth, height:maxImageHeight))
            let imageXOffset = (self.frame.size.width - (imageViewSize.width * CGFloat(self.emptyImageViews.count))) /
                CGFloat((self.emptyImageViews.count - 1))

            for i in 0..<self.maxRating {
                let y: CGFloat = (self.frame.size.height - maxImageHeight)/2
                let imageFrame = CGRect(x:i==0 ? 0:CGFloat(i)*(imageXOffset+imageViewSize.width), y:y, width:imageViewSize.width, height:imageViewSize.height)

                var imageView = self.emptyImageViews[i]
                imageView.frame = imageFrame

                imageView = self.fullImageViews[i]
                imageView.frame = imageFrame
            }

            self.refresh()
        }
    }

    func removeImageViews() {
        // Remove old image views
        for i in 0..<self.emptyImageViews.count {
            var imageView = self.emptyImageViews[i]
            imageView.removeFromSuperview()
            imageView = self.fullImageViews[i]
            imageView.removeFromSuperview()
        }
        self.emptyImageViews.removeAll(keepingCapacity: false)
        self.fullImageViews.removeAll(keepingCapacity: false)
    }

    func initImageViews() {
        if self.emptyImageViews.count != 0 {
            return
        }

        // Add new image views
        for _ in 0..<self.maxRating {
            let emptyImageView = UIImageView()
            emptyImageView.contentMode = self.imageContentMode
            emptyImageView.image = self.emptyImage
            self.emptyImageViews.append(emptyImageView)
            self.addSubview(emptyImageView)

            let fullImageView = UIImageView()
            fullImageView.contentMode = self.imageContentMode
            fullImageView.image = self.fullImage
            self.fullImageViews.append(fullImageView)
            self.addSubview(fullImageView)
        }
    }

    // MARK: Touch events

    // Calculates new rating based on touch location in view
    func handleTouchAtLocation(touchLocation: CGPoint) {
        if !self.editable {
            return
        }

        var newRating: Double = 0
        for i in stride(from: (self.maxRating-1), through: 0, by: -1){
        //for i in (self.maxRating-1).stride(through: 0, by: -1) {
            let imageView = self.emptyImageViews[i]
            if touchLocation.x > imageView.frame.origin.x {
                // Find touch point in image view
                let newLocation = imageView.convert(touchLocation, from:self)

                // Find decimal value for double or half rating
                if imageView.point(inside: newLocation, with: nil) && (self.floatRatings || self.halfRatings) {
                    let decimalNum = Double(newLocation.x / imageView.frame.size.width)
                    newRating = Double(i) + decimalNum
                    if self.halfRatings {
                        newRating = Double(i) + (decimalNum > 0.75 ? 1:(decimalNum > 0.25 ? 0.5:0))
                    }
                }
                    // Whole rating
                else {
                    newRating = Double(i) + 1.0
                }
                break
            }
        }

        // Check min rating
        self.rating = newRating < Double(self.minRating) ? Double(self.minRating):newRating
        // Update delegate
        if let delegate = self.delegate {
            delegate.ratingView?(ratingView: self, isUpdating: self.rating)
        }
    }

    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

        if let touch = touches.first {
            let touchLocation = touch.location(in: self)
            self.handleTouchAtLocation(touchLocation: touchLocation)
        }
    }


    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first  {
            let touchLocation = touch.location(in: self)
            self.handleTouchAtLocation(touchLocation: touchLocation)
        }
    }

    override public func touchesEnded(_
        touches: Set<UITouch>, with event: UIEvent?) {
        // Update delegate
        if let delegate = self.delegate {
            delegate.ratingView(ratingView: self, didUpdate: self.rating)
        }
    }
    
}

