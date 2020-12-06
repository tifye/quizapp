//
//  extensions.swift
//  quizapp
//
//  Created by Joshua De Matas on 2020-12-06.
//

import Foundation

extension String {
    var htmlDecoded: String? {
        let data = Data(utf8)
        let decodedString = try? NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        return decodedString?.string
    }
}
