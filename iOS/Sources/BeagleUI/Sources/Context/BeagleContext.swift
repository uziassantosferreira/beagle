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

import UIKit

public enum Event {
    case action(Action)
    case analytics(AnalyticsClick)
}

public enum ScreenState {
    case initialized
    case loading
    case success
    case failure(ServerDrivenState.Error)
}

/// Interface to access application specific operations
public protocol BeagleContext: AnyObject {

    var dependencies: BeagleDependenciesProtocol { get }
    
    var screenController: UIViewController { get }
    
    var screenState: ScreenState { get set }

    func applyLayout()
    
}

extension BeagleScreenViewController: BeagleContext {
    
    public var screenController: UIViewController {
        return self
    }
    
    public var screenState: ScreenState {
        get { return viewModel.state }
        set { viewModel.state = newValue }
    }

    public func applyLayout() {
        (contentController as? ScreenController)?.layoutManager?.applyLayout()
    }
    
}
