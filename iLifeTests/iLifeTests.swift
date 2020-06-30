//
//  iLifeTests.swift
//  iLifeTests
//
//  Created by Mirosław Witkowski.
//  Copyright © 2020 Mirosław Witkowski. All rights reserved.
//

import XCTest
@testable import iLife

class iLifeTests: XCTestCase {

    func testPageInitializationPageSucceeds() {
        
        let nilImage = Page.init(title: "Wycieczka do Buckingham Palace", historyId: 3, date: Date(), localizationName: "Anglia, Londyn", locLon: -0.1257400, locLat: 51.5085300, image: nil, text: "tekst")
        XCTAssertNotNil(nilImage)
        
        let emptyTitle = Page.init(title: "", historyId: 3, date: Date(), localizationName: "Anglia, Londyn", locLon: -0.1257400, locLat: 51.5085300, image: nil, text: "tekst")
        XCTAssertNotNil(emptyTitle)
        
    }
    
    func testPageInitializationHistorySucceeds() {
        
        let zeroId = History.init(name: "test", id: 0)
        XCTAssertNotNil(zeroId)
        
    }
    
    func testPageInitializationHistoryFails() {
        
        let minusId = History.init(name: "", id: -1)
        XCTAssertNil(minusId)
        
        let emptyTitle1 = History.init(name: "")
        XCTAssertNil(emptyTitle1)
        
        let emptyTitle2 = History.init(name: "", id: 2)
        XCTAssertNil(emptyTitle2)
        
    }

}
