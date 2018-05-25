# NKRatingView

This repo is made for a custom rating view to use in iOS.

To use this control
- Pick file NKRatingView.swift from the cloned directory
- Drag to your project 
- Take a UIView and set class NKRatingView
- Customize properties as per need
- Create an @IBOutlet and use it

Protocol added: NKRatingViewDelegate
Added methods:
    func ratingView(ratingView: NKRatingView, didUpdate rating: Double)
  //Returns the rating value when touch events end
and
   optional func ratingView(ratingView: NKRatingView, isUpdating rating: Double)
//Returns the rating value as the user pans









