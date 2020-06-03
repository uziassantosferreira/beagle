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

public struct NetworkImage: Widget, AutoInitiableAndDecodable {
    
    // MARK: - Public Properties

    public let path: String
    public let contentMode: ImageContentMode?
    public let placeholder: Image?
    public var widgetProperties: WidgetProperties
    
    // MARK: - Initialization

// sourcery:inline:auto:NetworkImage.Init
    public init(
        path: String,
        contentMode: ImageContentMode? = nil,
        placeholder: Image? = nil,
        widgetProperties: WidgetProperties = WidgetProperties()
    ) {
        self.path = path
        self.contentMode = contentMode
        self.placeholder = placeholder
        self.widgetProperties = widgetProperties
    }
// sourcery:end
}

extension NetworkImage: Renderable {
    public func toView(context: BeagleContext, dependencies: RenderableDependencies) -> UIView {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = (contentMode ?? .fitCenter).toUIKit()
        imageView.beagle.setup(self)
        
        if let placeholder = placeholder {
            let imagePlaceholder = placeholder.toView(context: context, dependencies: dependencies)
            imagePlaceholder.beagle.setup(self)
            context.lazyLoadManager.lazyLoadImage(path: path, placeholderView: imagePlaceholder, imageView: imageView, flex: flex ?? Flex())
            return imagePlaceholder
        }

        dependencies.repository.fetchImage(url: path, additionalData: nil) {
            [weak imageView] result in
            guard let imageView = imageView else { return }
            guard case .success(let data) = result else {
                return
            }
            let image = UIImage(data: data)
            DispatchQueue.main.async {
                imageView.image = image
                imageView.flex.markDirty()
            }
        }
        return imageView
    }
}
