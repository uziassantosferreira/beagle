//
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
import SnapshotTesting
@testable import BeagleUI

final class NavigateTests: XCTestCase {
    
    func test_whenDecodingJson_thenItShouldReturnOpenExternalUrl() throws {
        let action: Navigate = try actionFromJsonFile(fileName: "openexternalurl")
        assertSnapshot(matching: action, as: .dump)
    }
    
    func test_whenDecodingJson_thenItShouldReturnOpenNativeRoute() throws {
        let action: Navigate = try actionFromJsonFile(fileName: "opennativeroute")
        assertSnapshot(matching: action, as: .dump)
    }
    
    func test_whenDecodingJson_thenItShouldReturnResetApplication() throws {
        let action: Navigate = try actionFromJsonFile(fileName: "resetapplication")
        assertSnapshot(matching: action, as: .dump)
    }
    
    func test_whenDecodingJson_thenItShouldReturnResetStack() throws {
        let action: Navigate = try actionFromJsonFile(fileName: "resetstack")
        assertSnapshot(matching: action, as: .dump)
    }
    
    func test_whenDecodingJson_thenItShouldReturnPushStack() throws {
        let action: Navigate = try actionFromJsonFile(fileName: "pushstack")
        assertSnapshot(matching: action, as: .dump)
    }
    
    func test_whenDecodingJson_thenItShouldReturnPopStack() throws {
        let action: Navigate = try actionFromJsonFile(fileName: "popstack")
        assertSnapshot(matching: action, as: .dump)
    }
    
    func test_whenDecodingJson_thenItShouldReturnPushView() throws {
        let action: Navigate = try actionFromJsonFile(fileName: "pushview")
        assertSnapshot(matching: action, as: .dump)
    }
    
    func test_whenDecodingJson_thenItShouldReturnPopView() throws {
        let action: Navigate = try actionFromJsonFile(fileName: "popview")
        assertSnapshot(matching: action, as: .dump)
    }
    
    func test_whenDecodingJson_thenItShouldReturnPopToView() throws {
        let action: Navigate = try actionFromJsonFile(fileName: "poptoview")
        assertSnapshot(matching: action, as: .dump)
    }
    
    
    
    
    func test_open_valid_ExternalURL() {
        // Given
        let action = Navigate.openExternalURL("https://localhost:8080")
        let opener = URLOpenerDumb()
        let context = BeagleContextStub()
        context.dependencies = BeagleScreenDependencies(opener: opener)
        
        // When
        action.execute(context: context, sender: self)
        
        // Then
        XCTAssert(opener.hasInvokedTryToOpen == true)
    }
    
    func test_openNativeRoute_shouldNotPushANativeScreenToNavigationWhenDeepLinkHandlerItsNotSet() {
        // Given
        let action = Navigate.openNativeRoute("https://example.com/screen.json")
        let context = BeagleContextStub()
        let navigation = BeagleNavigationController(rootViewController: context.screenController)
        
        // When
        action.execute(context: context, sender: self)
        
        //Then
        XCTAssert(navigation.viewControllers.count == 1)
    }
    
    func test_openNativeRoute_shouldPushANativeScreenWithData() {
        // Given
        let data = ["uma": "uma", "dois": "duas"]
        let path = "https://example.com/screen.json"
        let action = Navigate.openNativeRoute(path, data: data)
        let deepLinkSpy = DeepLinkHandlerSpy()
        let context = BeagleContextStub()
        let navigation = BeagleNavigationController(rootViewController: context.screenController)
        context.dependencies = BeagleScreenDependencies(deepLinkHandler: deepLinkSpy)
        
        // When
        action.execute(context: context, sender: self, animated: false)
        
        //Then
        XCTAssertEqual(2, navigation.viewControllers.count)
        XCTAssertEqual(data, deepLinkSpy.calledData)
        XCTAssertEqual(path, deepLinkSpy.calledPath)
    }
    
    func test_resetApplication_shouldReplaceApplicationStackWithRemoteScreen() {
        // Given
        let resetRemote = Navigate.resetApplication(.remote("https://example.com/screen.json"))
        let windowMock = WindowMock()
        let windowManager = WindowManagerDumb(window: windowMock)
        let context = BeagleContextStub()
        context.dependencies = BeagleScreenDependencies(windowManager: windowManager)
        
        // When
        resetRemote.execute(context: context, sender: self)
        
        // Then
        XCTAssert(windowMock.hasInvokedReplaceRootViewController)
    }
    
    func test_resetApplication_shouldReplaceApplicationStackWithDeclarativeScreen() {
        // Given
        let resetApplication = Navigate.resetApplication(.declarative(Screen(child: Text("Declarative"))))
        let windowMock = WindowMock()
        let windowManager = WindowManagerDumb(window: windowMock)
        let context = BeagleContextStub()
        context.dependencies = BeagleScreenDependencies(windowManager: windowManager)
                
        // When
        resetApplication.execute(context: context, sender: self)
        
        // Then
        XCTAssert(windowMock.hasInvokedReplaceRootViewController)
    }
    
    func test_resetStack_shouldReplaceNavigationStack() {
        let resetStackRemote = Navigate.resetStack(
            .remote("https://example.com/screen.json")
        )
        resetStackTest(resetStackRemote)
        
//        let resetStackDeclarative = Navigate.resetStack(
//            .declarative(Screen(child: Text("Declarative")))
//        )
//        resetStackTest(resetStackDeclarative)
    }
    
    private func resetStackTest(_ navigate: Navigate) {
        let context = BeagleContextStub()
        let navigation = UINavigationController(rootViewController: context.screenController)
        
        navigate.execute(context: context, sender: self, animated: false)
                
        XCTAssertEqual(1, navigation.viewControllers.count)
        XCTAssertNotEqual(navigation.viewControllers.last, context.screenController)
        XCTAssert(navigation.viewControllers.last is BeagleScreenViewController)
    }
    
    func test_pushView_shouldPushScreenInNavigation() {
        let addViewRemote = Navigate.pushView(.remote("https://example.com/screen.json"))
        let addViewDeclarative = Navigate.pushView(.declarative(Screen(child: Text("Declarative"))))
        
        pushViewTest(addViewRemote)
        pushViewTest(addViewDeclarative)
    }
    
    private func pushViewTest(_ navigate: Navigate) {
        let context = BeagleContextStub()
        let navigation = UINavigationController(rootViewController: context.screenController)
        
        navigate.execute(context: context, sender: self, animated: false)
                
        XCTAssertEqual(2, navigation.viewControllers.count)
        XCTAssertNotEqual(navigation.viewControllers.last, context.screenController)
        XCTAssert(navigation.viewControllers.last is BeagleScreenViewController)
    }
    
    func test_popStack_shouldDismissNavigation() {
        // Given
        let action = Navigate.popStack
        let context = BeagleContextStub()
        let screenController = UIViewControllerSpy()
        context.screenController = screenController
        
        // When
        action.execute(context: context, sender: self)
                
        // Then
        XCTAssert(screenController.dismissViewControllerCalled)
    }
    
    func test_popView_shouldPopNavigationScreen() {
        // Given
        let action = Navigate.popView
        let context = BeagleContextStub()
        let vc0 = UIViewController()
        let vc1 = UIViewController()
        let navigation = UINavigationController()
        navigation.viewControllers = [vc0, vc1, context.screenController]
        
        // When
        action.execute(context: context, sender: self, animated: false)
                
        // Then
        XCTAssert(navigation.viewControllers.count == 2)
        XCTAssert(navigation.viewControllers[0] === vc0)
        XCTAssert(navigation.viewControllers[1] === vc1)
    }
    
    func test_popToView_shouldNavigateToDeclarativeScreen() {
        let identifier = "declarative-screen"
        let declarative = BeagleScreenViewController(.declarative(
            Screen(identifier: identifier, child: ComponentDummy()))
        )
        
        let context = BeagleContextStub()
        let navigation = UINavigationController()
        navigation.viewControllers = [
            BeagleScreenViewController(ComponentDummy()),
            declarative,
            BeagleScreenViewController(.remote(.init(url: "url"))),
            context.screenController
        ]
        
        let action = Navigate.popToView(identifier)
        action.execute(context: context, sender: self, animated: false)
        
        // Then
        XCTAssertEqual(navigation.viewControllers.count, 2)
        XCTAssert(navigation.viewControllers.last === declarative)
    }
    
    func test_popToView_shouldNotNavigateWhenScreenIsNotFound() {
        // Given
        let context = BeagleContextStub()
        let navigation = UINavigationController()
        navigation.viewControllers = [
            BeagleScreenViewController(ComponentDummy()),
            BeagleScreenViewController(.remote(.init(url: "screenURL2"))),
            BeagleScreenViewController(.remote(.init(url: "screenURL3"))),
            context.screenController
        ]
        
        // When
        let action = Navigate.popToView("screenURL1")
        action.execute(context: context, sender: self, animated: false)
        
        // Then
        XCTAssertEqual(navigation.viewControllers.count, 4)
        XCTAssert(navigation.viewControllers.last === context.screenController)
    }
    
//    func test_popToView_shouldRemoveFromStackScreensAfterTargetScreen() {
//        // Given
//        let screenURL1 = "https://example.com/screen1.json"
//        let screenURL2 = "https://example.com/screen2.json"
//        let screenURL3 = "https://example.com/screen3.json"
//        let sut = BeagleNavigator(dependencies: NavigatorDependencies())
//        let action = Navigate.popToView(screenURL2)
//        let vc1 = beagleViewController(screen: .remote(.init(url: screenURL1)))
//        let vc2 = beagleViewController(screen: .remote(.init(url: screenURL2)))
//        let vc3 = beagleViewController(screen: .remote(.init(url: screenURL3)))
//        let vc4 = UIViewController()
//        let navigation = BeagleNavigationController()
//        navigation.viewControllers = [vc1, vc2, vc3, vc4]
//
//        // When
//        sut.navigate(action: action, context: vc3)
//
//        // Then
//        XCTAssert(navigation.viewControllers.count == 2)
//        XCTAssert(navigation.viewControllers.last == vc2)
//    }
//
//    func test_popToView_absoluteURL() {
//        let dependecies = BeagleDependencies()
//        dependecies.urlBuilder.baseUrl = URL(string: "https://server.com/path/")
//        let sut = BeagleNavigator(dependencies: dependecies)
//        let screen = beagleViewController(screen: .remote(.init(url: "/screen")))
//
//        let navigation = BeagleNavigationController()
//        let stack = [screen, BeagleScreenViewController(component: ComponentDummy()), BeagleScreenViewController(component: ComponentDummy())]
//        navigation.viewControllers = stack
//
//        sut.navigate(
//            action: Navigate.popToView("https://server.com/path/screen"),
//            context: screen
//        )
//        XCTAssert(navigation.viewControllers.last == screen)
//
//        navigation.viewControllers = stack
//        sut.navigate(
//            action: Navigate.popToView("/screen"),
//            context: BeagleContextDummy(viewController: stack[2])
//        )
//        XCTAssert(navigation.viewControllers.last == screen)
//    }
//
//    func test_popToView_byIdentifier() {
//        // Given
//        let sut = BeagleNavigator(dependencies: NavigatorDependencies())
//        let vc1 = beagleViewController(screen: .declarative(Screen(identifier: "1", child: Text("Screen 1"))))
//        let vc2 = beagleViewController(screen: .declarative(Screen(identifier: "2", child: Text("Screen 2"))))
//        let vc3 = UIViewController()
//        let vc4 = beagleViewController(screen: .declarative(Screen(identifier: "4", child: Text("Screen 4"))))
//        let action = Navigate.popToView("2")
//
//        let context = BeagleContextDummy(viewController: vc4)
//        let navigation = UINavigationController()
//        navigation.viewControllers = [vc1, vc2, vc3, vc4]
//
//        // When
//        sut.navigate(action: action, context: context)
//
//        // Then
//        XCTAssert(navigation.viewControllers.count == 2)
//        XCTAssert(navigation.viewControllers.last == vc2)
//    }
//
//    func test_pushStack_shouldPresentTheScreen() {
//        let presentViewRemote = Navigate.pushStack(.remote("https://example.com/screen.json"))
//        let presentViewDeclarative = Navigate.pushStack(.declarative(Screen(child: Text("Declarative"))))
//
//        pushStackTest(presentViewRemote)
//        pushStackTest(presentViewDeclarative)
//    }
//
//    private func pushStackTest(_ navigate: Navigate) {
//        let sut = BeagleNavigator(dependencies: NavigatorDependencies())
//        let navigationSpy = UINavigationControllerSpy(
//            viewModel: .init(screenType: .declarative(ComponentDummy().toScreen()))
//        )
//
//        sut.navigate(action: navigate, context: navigationSpy)
//
//        XCTAssert(navigationSpy.presentViewControllerCalled)
//    }
    
}







class DeepLinkHandlerSpy: DeepLinkScreenManaging {
    var calledPath: String?
    var calledData: [String: String]?
    
    func getNativeScreen(with path: String, data: [String: String]?) throws -> UIViewController {
        calledData = data
        calledPath = path
        return UIViewController()
    }
}

class UIViewControllerSpy: UINavigationController {

    private(set) var presentViewControllerCalled = false
    private(set) var dismissViewControllerCalled = false

    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        presentViewControllerCalled = true
        super.present(viewControllerToPresent, animated: flag, completion: completion)
    }
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        dismissViewControllerCalled = true
        super.dismiss(animated: flag, completion: completion)
    }
}
