//
//  SearchResultTableViewCell.swift
//  UnsplashApp
//
//  Created by Sébastien Gousseau on 26/06/2019.
//  Copyright © 2019 Sébastien Gousseau. All rights reserved.
//

import UIKit
import RxSwift

class SearchResultTableViewCell: UITableViewCell {
    
    @IBOutlet weak var thumbnailImageView: UIImageView!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    var bag: DisposeBag! = DisposeBag()
    
    var downloadableImage: Observable<DownloadableImage>?{
        didSet{
            let disposeBag = DisposeBag()
            
            self.downloadableImage?
                .asDriver(onErrorJustReturn: DownloadableImage.offlinePlaceholder)
                .drive(thumbnailImageView.rx.downloadableImageAnimated(CATransitionType.fade.rawValue))
                .disposed(by: disposeBag)
            
            self.bag = disposeBag
        }
    }
}
