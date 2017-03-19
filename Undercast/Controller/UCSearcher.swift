//
//  UCSearcher.swift
//  Undercast
//
//  Created by Malij on 3/18/17.
//  Copyright © 2017 Coybit. All rights reserved.
//

import UIKit

protocol UCSearcher {

    func Seach(term:String, callback:@escaping ([Podcast])->Void );
    
}
