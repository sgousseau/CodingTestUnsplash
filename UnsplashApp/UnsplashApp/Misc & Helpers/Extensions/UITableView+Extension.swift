//
//  UITableView+Rx.swift
//  UnsplashApp
//
//  Created by Sébastien Gousseau on 27/06/2019.
//  Copyright © 2019 Sébastien Gousseau. All rights reserved.
//

import Foundation
import RxSwift

extension UITableView {
    func isLastCell(_ indexPath: IndexPath) -> Bool {
        return indexPath.row == (numberOfRows(inSection: indexPath.section) - 1)
    }
}
