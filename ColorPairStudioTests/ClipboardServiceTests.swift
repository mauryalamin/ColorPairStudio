//
//  ClipboardServiceTests.swift
//  ColorPairStudioTests
//
//  Created by Maury Alamin on 10/2/25.
//

import XCTest
@testable import ColorPairStudio
import ColorPairCore


final class TestPasteboard: Pasteboarding {
    var lastString: String?
    func setString(_ s: String) { lastString = s }
}

final class ClipboardServiceTests: XCTestCase {
    
    final class MockPasteboard: Pasteboarding {
        var last: String?
        func setString(_ s: String) { last = s }
    }
    
    func testCopyHexWritesExpectedString() {
        let mock = MockPasteboard()
        let svc  = ClipboardService(pasteboard: mock)
        
        let c = RGBA(r: 0x4C/255, g: 0x6F/255, b: 0xAF/255, a: 1) // #4C6FAF
        svc.copyHex(c)
        
        XCTAssertEqual(mock.last, c.hexString) // e.g., "#4C6FAF"
    }
    
    func testCopyHexCopiesExpectedString() {
        let pb = TestPasteboard()
        let svc = ClipboardService(pasteboard: pb)
        let rgba = RGBA(r: 0.2, g: 0.4, b: 0.6, a: 1)
        svc.copyHex(rgba)
        XCTAssertEqual(pb.lastString, rgba.hexString)
    }
}
