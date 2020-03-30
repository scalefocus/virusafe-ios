//
//  LoadingIndicatorManager.swift
//
//  Created by dimitar petrov on 10/21/15.
//  Copyright © 2015 dimitar petrov. All rights reserved.
//

import UIKit

private let ACTIVITY_INDICATOR_TAG_WHOLE_SCREEN     = 100
private let ACTIVITY_INDICATOR_TAG_SPECIFIC_VIEW    = 101

open class LoadingIndicatorManager {
    
    //MARK: - Shared Instance's methods
    
    /// Checks the number of observers, and if it is greater than `0`, the UI is considered blocked; returns `true`
    ///
    /// - Returns: Bool - is the UI blocked
    open func isUIBlocked() -> Bool {
        return numberOfObservers > 0
    }
    
    /// Increments the number of observers and tries to block the UI.
    open func shouldBlockUI() {
        numberOfObservers += 1
        blockUI()
    }
    
    /// Checks if the UI is blocked; and if so: decrements the number of observers and tries to unblock the UI.
    open func shouldUnblockUI() {
        //numberOfObservers Should NOT be less than(<) 0
        if isUIBlocked() {
            numberOfObservers = numberOfObservers - 1
            unblockUI()
        }
    }
    
    //MARK: - Class methods
    
    /// Creates activity indicator in view and start animating it.
    ///
    /// - Parameters:
    ///   - activityIndicatorStyle: Style of the activity indicator
    ///   - view: Parent view that will hold the activity indicator
    ///   - backgroundColor: The dim background color; default is: (red: 0, green: 0, blue: 0, alpha: 0.3)
    open class func startActivityIndicator(_ activityIndicatorStyle:UIActivityIndicatorView.Style,
                                           in view: UIView,
                                           backgroundColor: UIColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.65)) {
        
        //do NOT add second activityIndicator to view that already have subview activityIndicator
        if let _ = view.viewWithTag(ACTIVITY_INDICATOR_TAG_SPECIFIC_VIEW) as? UIActivityIndicatorView { return }
        
        //creates activity indicator and configure it
        let customActivityIndicator = UIActivityIndicatorView()
        customActivityIndicator.style = activityIndicatorStyle
        customActivityIndicator.layer.backgroundColor = backgroundColor.cgColor
        customActivityIndicator.startAnimating()
        customActivityIndicator.tag = ACTIVITY_INDICATOR_TAG_SPECIFIC_VIEW
        
        //add the activity indicator in the view
        view.addSubview(customActivityIndicator)
        customActivityIndicator.translatesAutoresizingMaskIntoConstraints = false
        LoadingIndicatorManager.addConstraintsFill(inView: view, withActivityIndicatorView: customActivityIndicator)
    }
    
    /// Removes activity indicator from view.
    ///
    /// - Parameter view: The parent view of the activity indicator.
    open class func stopActivityIndicator(in view:UIView) {
        if let customActivityIndicator = view.viewWithTag(ACTIVITY_INDICATOR_TAG_SPECIFIC_VIEW) as? UIActivityIndicatorView {
            customActivityIndicator.stopAnimating()
            customActivityIndicator.removeFromSuperview()
        }
    }
    
    //MARK: - Activity Indicator
    
    /// Field holding the number of observers. Starts with `0` - no observers. Should not go below 0. Reaching 0 means that there should be no activity indicator.
    private var numberOfObservers: Int = 0
    /// The default whole screen blocking UI activity indicator.
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.style = UIActivityIndicatorView.Style.gray
        activityIndicator.hidesWhenStopped = true
        
        activityIndicator.tag = ACTIVITY_INDICATOR_TAG_WHOLE_SCREEN
        activityIndicator.layer.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.65).cgColor
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        return activityIndicator
        }()
    
    /// Blocks the UI and starts activity indicator, if needed.
    private func blockUI() {
         if let keyWindow = UIApplication.shared.keyWindow {
            //do nothing if the UI has already been blocked: check if there is view with this tag of type Activity indicator
            if let _ = keyWindow.viewWithTag(ACTIVITY_INDICATOR_TAG_WHOLE_SCREEN) as? UIActivityIndicatorView { return }
            
            //start activity indicator and add it to the `keyWindow`
            activityIndicator.startAnimating()
            keyWindow.addSubview(activityIndicator)
            LoadingIndicatorManager.addConstraintsFill(inView: keyWindow, withActivityIndicatorView: activityIndicator)
        }
    }
    
    /// Unblocks the UI and stops the activity indicator, if needed.
    private func unblockUI() {
        //check if there are no more UI blockers
        if isUIBlocked() == false {
            activityIndicator.stopAnimating()
            activityIndicator.removeFromSuperview()
        }
    }
    
    //MARK: - Singleton
    public static let sharedInstance = LoadingIndicatorManager()
    private init() {}
    
    //MARK: - Constraints Convenience Methods
    
    /// Adds [top, right, bot, left] constaints' dependancies between superview and activity indicator.
    class private func addConstraintsFill(inView superview:UIView, withActivityIndicatorView activityIndicator:UIActivityIndicatorView) {
        LoadingIndicatorManager.addConstraint(item: activityIndicator, attibute: .top, toItem: superview)
        LoadingIndicatorManager.addConstraint(item: activityIndicator, attibute: .bottom, toItem: superview)
        LoadingIndicatorManager.addConstraint(item: activityIndicator, attibute: .left, toItem: superview)
        LoadingIndicatorManager.addConstraint(item: activityIndicator, attibute: .right, toItem: superview)
    }
    
    /// Adds single constraint dependancy
    class private func addConstraint(item activityIndicator: UIActivityIndicatorView, attibute: NSLayoutConstraint.Attribute, toItem superview: UIView) {
        superview.addConstraint(NSLayoutConstraint(item: activityIndicator, attribute: attibute, relatedBy: .equal, toItem: superview, attribute: attibute, multiplier: 1, constant: 0))
    }
}

