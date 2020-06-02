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

 public struct LazyComponent: ServerDrivenComponent, AutoInitiableAndDecodable {
    
    // MARK: - Public Properties
    
    public let path: String
    public let initialState: ServerDrivenComponent

// sourcery:inline:auto:LazyComponent.Init
    public init(
        path: String,
        initialState: ServerDrivenComponent
    ) {
        self.path = path
        self.initialState = initialState
    }
// sourcery:end
}

extension LazyComponent: Renderable {
    public func toView(context: BeagleContext, dependencies: RenderableDependencies) -> UIView {
        let view = initialState.toView(context: context, dependencies: dependencies)
        view.lazyLoad(path, context: context)
        return view
    }
}

extension UIView {
    fileprivate func lazyLoad(_ url: String, context: BeagleContext) {
        context.dependencies.repository.fetchComponent(url: url, additionalData: nil) {
            [weak context] result in guard let context = context else { return }
            switch result {
            case .success(let component):
                self.update(to: component, context: context)
            case .failure(let error):
                context.screenState = .failure(.lazyLoad(error))
            }
        }
    }
    
    private func update(to component: ServerDrivenComponent, context: BeagleContext) {
        let updatable = self as? OnStateUpdatable
        let updated = updatable?.onUpdateState(component: component) ?? false

        if updated && flex.isEnabled {
            flex.markDirty()
        } else if !updated {
            replace(with: component, context: context)
        }
        context.applyLayout()
    }
    
    private func replace(with component: ServerDrivenComponent, context: BeagleContext) {
        guard let superview = superview else { return }
        let view = component.toView(context: context, dependencies: context.dependencies)
        view.frame = frame
        superview.insertSubview(view, belowSubview: self)
        removeFromSuperview()

        if flex.isEnabled && !view.flex.isEnabled {
            view.flex.isEnabled = true
        }
    }
}
