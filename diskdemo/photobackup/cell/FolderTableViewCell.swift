//
//  FolderTableViewCell.swift
//  diskdemo
//
//  Created by macliu on 2021/3/12.
//

import UIKit
import SnapKit


class FolderTableViewCell: UITableViewCell {

    var NameLabel: UILabel = UILabel()
    var iconView: UIImageView = UIImageView()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.lauoutUI()
    }
    func lauoutUI() {
        self.contentView.addSubview(NameLabel)
        self.contentView.addSubview(iconView)
        NameLabel.snp_makeConstraints { (make) in
            make.top.equalTo(5)
            make.left.equalTo(80)
            make.height.equalTo(30)
            make.width.equalTo(260)
        }
        iconView.snp_makeConstraints { (make) in
            make.top.equalTo(10)
            make.left.equalTo(20)
            make.height.equalTo(50)
            make.width.equalTo(50)
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

}
