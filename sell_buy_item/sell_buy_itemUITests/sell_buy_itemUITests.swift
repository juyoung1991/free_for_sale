//
//  sell_buy_itemUITests.swift
//  sell_buy_itemUITests
//
//  Created by Ju Young Kim on 2016. 10. 31..
//  Copyright © 2016년 Ju Young Kim. All rights reserved.
//

import XCTest
import Firebase
import FirebaseStorage

class sell_buy_itemUITests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        XCUIApplication().launch()
        continueAfterFailure = false
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    /**
     Testing if user can be added to database after registration
     */
    func testUserDatabase() {
        FIRApp.configure()
        let rootref = FIRDatabase.database().reference()
        rootref.child("users").child("user_id_test").setValue(["userEmail": "testing@test.com", "first name": "Ju Young", "last name": "Kim", "password": "12345678"])
        rootref.child("users").child("user_id_test").observeSingleEvent(of: .value, with: { (snapshot) in
            let user_info_arr = snapshot.value! as! Dictionary<String, String>
            XCTAssert(user_info_arr["userEmail"] == "testing@test.com")
            XCTAssert(user_info_arr["first name"] == "Ju Young")
            XCTAssert(user_info_arr["last name"] == "Kim")
        })
        rootref.child("users").child("user_id_test").removeValue()
    }
    
    /**
     Testing if item information can be added to database after registration
     */
    func testItemDatabase() {
        let rootref = FIRDatabase.database().reference()
        rootref.child("items").child("Electronics").child("Desktop").child("user_id_test").setValue(["item_name": "Alienware", "item_price": "30", "item_descp": "mint condition", "user_addr": "506 East Clark", "item_image": ""])
        rootref.child("items").child("Electronics").child("Desktop").child("user_id_test").observeSingleEvent(of: .value, with: { (snapshot) in
            let user_info_arr = snapshot.value! as! Dictionary<String, String>
            print(user_info_arr)
            XCTAssert(user_info_arr["item_name"] == "Alienware")
            XCTAssert(user_info_arr["item_price"] == "30")
            XCTAssert(user_info_arr["user_addr"] == "506 East Clark")
        })
        rootref.child("items").child("Electronics").child("Desktop").child("user_id_test").removeValue()
    }
    
}
