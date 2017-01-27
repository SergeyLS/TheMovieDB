//
//  PopularTableViewCell.swift
//  TheMovieDB
//
//  Created by Sergey Leskov on 1/26/17.
//  Copyright © 2017 Sergey Leskov. All rights reserved.
//

import UIKit

class PopularTableViewCell: UITableViewCell {

    @IBOutlet weak var photo: UIImageView!

    /* CODEREVIEW_2
     Я предпочитаю прятать доступ к UI-ым элементам и оставлять публичные проперти к значениям, которые нужно будет менять.
     В таком случае нельзя изменить саму лэйблу, можно только ее текст
     */
    @IBOutlet private weak var name: UILabel!
    
    public var title: String? {
        get {
            return name.text
        }
        set {
            name.text = newValue
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    /* CODEREVIEW_3
     Когда cell-а попадает в очередь TableView на переиспользование нужно установленные значения устанавливать в дефолтные
     В cell-е лучше также хранить ссылку на таск по загрузке картинки, чтобы в prepareForReuse его останавливать
     */
    override func prepareForReuse() {
        photo.image = nil
        name.text = nil
    }
}
