//
//  HudView.swift
//  MyLocations
//
//  Created by Daniel Kwiatkowski on 2015-06-16.
//  Copyright (c) 2015 Daniel Kwiatkowski. All rights reserved.
//

import UIKit

class HudView: UIView {
    var text = ""
    
    class func hudInView(view: UIView, animated:Bool) -> HudView{
        //making an instance of the hud view
        let hudView = HudView(frame: view.bounds)
        hudView.opaque = false
        hudView.showAnimated(animated)
        
        view.opaque = false
        
        view.addSubview(hudView)
        view.userInteractionEnabled = false
        
        return hudView
    }
    
    override func drawRect(rect: CGRect) {
        //this is the rectangular frame
        let boxWidth: CGFloat = 96
        let boxHeight: CGFloat = 96
        //this is the position of the rectangle
        let boxRect = CGRect(x: round((bounds.size.width - boxWidth)/2), y: round((bounds.size.height - boxHeight)/2), width: boxWidth, height: boxHeight)
        //good for drawing round rectangle without the fuzziness
        let roundRect = UIBezierPath(roundedRect: boxRect, cornerRadius: 10)
        UIColor(white: 0.3, alpha: 0.8).setFill()
        roundRect.fill()
        // loads the checkmark into the UIImage object, it calculates the position for that image based on the center coordinate of the HUD view
        if let image = UIImage(named: "Checkmark"){
            //put the position of the checkmark
            let imagePoint = CGPoint(x: center.x - round(image.size.width / 2), y: center.y - round(image.size.height / 2) - boxHeight/8)
            image.drawAtPoint(imagePoint)
        }
        //change the the font using UIFont the you use for text, with helvetica neue with a dictionary value
        let attribs = [NSFontAttributeName:UIFont.systemFontOfSize(16.0), NSForegroundColorAttributeName: UIColor.whiteColor()]
        //this is to format the text
        let textSize = text.sizeWithAttributes(attribs)
        //postioning of the text
        let textPoint = CGPoint(x: center.x - round(textSize.width / 2), y: center.y - round(textSize.height / 2) + boxHeight / 4)
        //draws the text with attributes
        text.drawAtPoint(textPoint, withAttributes: attribs)
    }
    
    func showAnimated(animated:Bool){
        if animated{
            //make it transparent
            alpha = 0
            //this stretches out the inital view
            transform = CGAffineTransformMakeScale(1.3, 1.3)
            //animation that is nto executed the right way, UIKit will animate the properties tha you change from their intial state to the final state
            //spring animation
            UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: UIViewAnimationOptions(0), animations: {
                self.alpha = 1
                self.transform = CGAffineTransformIdentity
                }, completion: nil)        }
        
    }
}
