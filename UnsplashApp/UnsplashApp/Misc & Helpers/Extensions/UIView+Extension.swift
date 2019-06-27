//
//  UIView+Extension.swift
//  UnsplashApp
//
//  Created by Sébastien Gousseau on 26/06/2019.
//  Copyright © 2019 Sébastien Gousseau. All rights reserved.
//

import Foundation

import UIKit

extension UIView {
    func fade(duration: TimeInterval = 0.1) -> Self {
        self.layer.fade(duration: duration)
        return self
    }
    
    func scale(duration: TimeInterval = 0.1) -> Self {
        self.layer.scale(duration: duration)
        return self
    }
}
