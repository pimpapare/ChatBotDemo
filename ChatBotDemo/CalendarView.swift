//
//  CalendarView.swift
//  ChatBotDemo
//
//  Created by pimpaporn chaichompoo on 3/5/2561 BE.
//  Copyright © 2561 pimpaporn chaichompoo. All rights reserved.
//

import UIKit

class CalendarView: UIView {

    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var textTitle: UILabel!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    override func awakeFromNib() {
        self.backgroundColor = UIColor.clear
    }
}
