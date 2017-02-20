//
//  CombineAnimationTests.swift
//  Macaw
//
//  Created by Victor Sukochev on 20/02/2017.
//  Copyright © 2017 Exyte. All rights reserved.
//

import XCTest
@testable import Macaw

class CombineAnimationTests: XCTestCase {
    
    var testView: MacawView!
    var testGroup: Group!
    
    override func setUp() {
        super.setUp()
       
        testGroup = [Shape(form:Rect(x: 0.0, y: 0.0, w: 0.0, h: 0.0))].group()
        testView = MacawView(node: testGroup, frame: CGRect.zero)
    }
    
    func testStates() {
        let anim1 = testGroup.placeVar.animation(to: Transform.move(dx: 1.0, dy: 1.0), during: 1000.0) as! TransformAnimation
        let anim2 = testGroup.opacityVar.animation(to: 0.0, during: 1000.0) as! OpacityAnimation
        let anim3 = testGroup.contentsVar.animation ({ t -> [Node] in
            return [Shape(form:Rect(x: 0.0, y: 0.0, w: t, h: t))]
        }, during: 1000.0) as! ContentsAnimation
        
        let animation = [
            anim1,
            anim2,
            anim3
        ].combine() as! CombineAnimation
        
        animation.play()
        
        // PAUSE
        let pauseExpectation = expectation(description: "pause expectation")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            pauseExpectation.fulfill()
        }
        
        self.waitForExpectations(timeout: 2.0) { error in
            XCTAssertNil(error, "Async test failed")
        }
        
        animation.pause()
        
        XCTAssert(animation.paused && anim1.paused && anim2.paused && anim3.paused, "Inner animations incorrect state: pause")
        XCTAssert(!animation.manualStop && !anim1.manualStop && !anim2.manualStop && !anim3.manualStop, "Inner animations incorrect state: pause")
        XCTAssert(testGroup.place.dx != 0.0, "Transform animation wrong node state on pause")
        
        animation.play()
        animation.stop()
        
        // STOP
        let stopExpectation = expectation(description: "stop expectation")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            stopExpectation.fulfill()
        }
        
        self.waitForExpectations(timeout: 2.0) { error in
            XCTAssertNil(error, "Async test failed")
        }
        
        XCTAssert(animation.manualStop && anim1.manualStop && anim2.manualStop && anim3.manualStop, "Inner animations incorrect state: stop")
        XCTAssert(!animation.paused && !anim1.paused && !anim2.paused && !anim3.paused, "Inner animations incorrect state: stop")
        XCTAssert(testGroup.place.dx == 0.0, "Transform animation wrong node state on stop")
    }
    
}
