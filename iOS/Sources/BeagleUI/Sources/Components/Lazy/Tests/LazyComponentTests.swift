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

final class LazyComponentTests: XCTestCase {
    
    func test_initWithInitialStateBuilder_shouldReturnExpectedInstance() {
        // Given / When
        let sut = LazyComponent(
            path: "component",
            initialState: Text("text")
        )

        // Then
        XCTAssert(sut.path == "component")
        XCTAssert(sut.initialState is Text)
    }
    
    func test_lazyLoad_shouldReplaceTheInitialContent() {
        let sut = LazyComponent(path: "", initialState: Text("Loading..."))
        let repository = LazyRepositoryStub()
        let dependecies = BeagleDependencies()
        dependecies.repository = repository
        
        let screenController = BeagleScreenViewController(viewModel: .init(
            screenType: .declarative(Screen(child: sut)),
            dependencies: dependecies)
        )
        
        let size = CGSize(width: 100, height: 25)
        assertSnapshotImage(screenController, size: size)
        
        repository.componentCompletion?(.success(Text("Lazy Loaded")))
        assertSnapshotImage(screenController, size: size)
    }

    func test_lazyLoad_withUpdatableView_shouldCallUpdate() {
        let sut = LazyComponent(path: "", initialState: OnStateUpdatableComponent())
        let repository = LazyRepositoryStub()
        let context = BeagleContextStub()
        context.dependencies = BeagleScreenDependencies(repository: repository)
        
        let view = sut.toView(context: context, dependencies: context.dependencies)
        repository.componentCompletion?(.success(ComponentDummy()))
        
        XCTAssertTrue((view as? OnStateUpdatableViewSpy)?.didCallOnUpdateState ?? false)
    }
    
    func test_whenLoadFail_shouldSetNotifyTheScreen() {
        let sut = LazyComponent(path: "", initialState: ComponentDummy())
        let repository = LazyRepositoryStub()
        let context = BeagleContextStub()
        context.dependencies = BeagleScreenDependencies(repository: repository)
        
        _ = sut.toView(context: context, dependencies: context.dependencies)
        repository.componentCompletion?(.failure(.urlBuilderError))
        
        switch context.screenState {
        case .failure(let error):
            switch error {
            case .lazyLoad: break
            default: XCTFail("Expected .lazyLoad error but found \(error)")
            }
        default: XCTFail("Expected state .failure but found \(context.screenState)")
        }
    }
}

class LazyRepositoryStub: Repository {

    var componentCompletion: ((Result<ServerDrivenComponent, Request.Error>) -> Void)?
    var formCompletion: ((Result<Action, Request.Error>) -> Void)?
    var imageCompletion: ((Result<Data, Request.Error>) -> Void)?

    func fetchComponent(url: String, additionalData: RemoteScreenAdditionalData?, completion: @escaping (Result<ServerDrivenComponent, Request.Error>) -> Void) -> RequestToken? {
        componentCompletion = completion
        return nil
    }

    func submitForm(url: String, additionalData: RemoteScreenAdditionalData?, data: Request.FormData, completion: @escaping (Result<Action, Request.Error>) -> Void) -> RequestToken? {
        formCompletion = completion
        return nil
    }

    func fetchImage(url: String, additionalData: RemoteScreenAdditionalData?, completion: @escaping (Result<Data, Request.Error>) -> Void) -> RequestToken? {
        imageCompletion = completion
        return nil
    }
}

private struct OnStateUpdatableComponent: ServerDrivenComponent {
    func toView(context: BeagleContext, dependencies: RenderableDependencies) -> UIView {
        return OnStateUpdatableViewSpy()
    }
}

private class OnStateUpdatableViewSpy: UIView, OnStateUpdatable {
    private(set) var didCallOnUpdateState = false
    
    func onUpdateState(component: ServerDrivenComponent) -> Bool {
        didCallOnUpdateState = true
        return true
    }
}
