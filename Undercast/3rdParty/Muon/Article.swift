import Foundation
public struct Article {
    public let title : String
    public let link : URL?
    public let guid : String?
    public let description : String
    public let published : Date
    public let updated : Date?
    public let content : String
    public let duration : Int;
    
    fileprivate var internalAuthors : [Author]
    public var authors : [Author] { return internalAuthors }

    fileprivate var internalEnclosures : [Enclosure]
    public var enclosures : [Enclosure] { return internalEnclosures }

    fileprivate var internalCategories : [String]
    public var categories : [String] { return internalCategories }
    
    public init(title: String? = nil, link: URL? = nil, duration: Int? = nil, description: String? = nil, content: String? = nil, guid: String? = nil,
                published: Date? = nil, updated: Date? = nil, authors: [Author] = [], enclosures: [Enclosure] = [], categories: [String] = [] ) {
        self.title = title ?? ""
        self.link = link
        self.description = description ?? ""
        self.guid = guid ?? ""
        self.published = published ?? Date()
        self.updated = updated
        self.content = content ?? ""
        self.duration = duration ?? -1;
        
        self.internalAuthors = authors
        self.internalEnclosures = enclosures
        self.internalCategories = categories
    }

    mutating func addAuthor(_ author: Author) {
        self.internalAuthors.append(author)
    }

    mutating func addEnclosure(_ enclosure: Enclosure) {
        self.internalEnclosures.append(enclosure)
    }
}
