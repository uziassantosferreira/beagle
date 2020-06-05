/*
 * Copyright 2020 ZUP IT SERVICOS EM TECNOLOGIA E INOVACAO SA
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import XCTest
@testable import Schema
import SnapshotTesting

class ScreenComponentTests: XCTestCase {

    func test_whenDecodingJson_thenItShouldReturnAScreen() throws {
        let component: ScreenComponent = try componentFromJsonFile(fileName: "screenComponent")
        assertSnapshot(matching: component, as: .dump)
    }
    
    func testScreenComponentSample() {
        // given
        let screen = ScreenComponent(
            screenAnalyticsEvent: AnalyticsScreen(screenName: "Screen Name"),
            child: PageView(
                pages: [
                    WebView(url: "some url", flex: Flex.createMock())
                ],
                pageIndicator: nil
            )
        )
        
        // then
        assertSnapshot(matching: screen, as: .dump)
    }
    
}
