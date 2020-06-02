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
@testable import BeagleUI
import SnapshotTesting

final class TouchableTests: XCTestCase {
    
    func testInitFromDecoder() throws {
        let component: Touchable = try componentFromJsonFile(fileName: "TouchableDecoderTest")
        assertSnapshot(matching: component, as: .dump)
    }

    func testTouchableView() throws {
        let touchable = Touchable(action: Navigate.popView, child: Text("Touchable"))
        let view = touchable.toView(context: BeagleContextDummy(), dependencies: BeagleDependencies())

        assertSnapshotImage(view, size: CGSize(width: 100, height: 80))
    }
    
    func testIfPrefetchWhenActionIsNavigate() {
        let navigateRoute = "touchable-destination"
        let action = Navigate.pushView(.remote(navigateRoute, shouldPrefetch: true))
        let touchable = Touchable(action: action, child: ComponentDummy())
        let context = BeagleContextStub()
        let preFetchHelper = BeaglePrefetchHelpingSpy()
        context.dependencies = BeagleScreenDependencies(preFetchHelper: preFetchHelper)
        
        _ = touchable.toView(context: context, dependencies: context.dependencies)
        
        XCTAssertEqual(preFetchHelper.prefetched, [navigateRoute])
    }
    
    func testIfAnalyticsClickAndActionShouldBeTriggered() {
        // Given
        let action = ActionSpy()
        let analyticsClick = AnalyticsClick(category: "some category")
        let analytics = AnalyticsExecutorSpy()
        let touchable = Touchable(
            action: action,
            clickAnalyticsEvent: analyticsClick,
            child: ComponentDummy()
        )
        let context = BeagleContextStub()
        context.dependencies = BeagleScreenDependencies(analytics: analytics)
        
        // When
        let view = touchable.toView(context: context, dependencies: context.dependencies)
        view.gestureRecognizers?
            .compactMap { $0 as? EventsGestureRecognizer }
            .forEach { context.screenController.handleEvents($0) }
        
        // Then
        XCTAssertEqual(action.executionCount, 1)
        XCTAssertTrue(action.lastContext === context)
        XCTAssertTrue(action.lastSender as AnyObject === view)
        XCTAssertTrue(analytics.didTrackEventOnClick)
    }
}
