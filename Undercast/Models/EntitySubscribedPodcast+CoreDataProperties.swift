//
//  EntitySubscribedPodcast+CoreDataProperties.swift
//  Undercast
//
//  Created by coybit on 9/16/16.
//  Copyright © 2016 Coybit. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension EntitySubscribedPodcast {

    @NSManaged var ptitle: String?
    @NSManaged var pdescription: String?
    @NSManaged var pfeedUrl: String?
    @NSManaged var pcover: Data?
    @NSManaged var plastfeed: String?

}
