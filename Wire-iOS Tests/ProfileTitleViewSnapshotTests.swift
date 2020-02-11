// Wire
// Copyright (C) 2020 Wire Swiss GmbH
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see http://www.gnu.org/licenses/.
//

import XCTest
@testable import Wire
import SnapshotTesting

final class ProfileTitleViewSnapshotTests: XCTestCase {

    var sut: ProfileTitleView!
    var mockUser: SwiftMockUser!

    override func setUp() {
        super.setUp()
        sut = ProfileTitleView(frame: .init(origin: .zero, size: CGSize(width: 320, height: 44)))

        mockUser = SwiftMockUser()

        mockUser.name = "Bill Chan"
    }

    override func tearDown() {
        sut = nil
        mockUser = nil
        super.tearDown()
    }

    func testForDarkScheme() {
        sut.configure(with: mockUser, variant: .dark)
        verify(matching: sut)
    }

    func testForLightScheme() {
        sut.configure(with: mockUser, variant: .light)
        verify(matching: sut)
    }
}
