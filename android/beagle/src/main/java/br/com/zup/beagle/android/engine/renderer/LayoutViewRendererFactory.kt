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

package br.com.zup.beagle.android.engine.renderer

import br.com.zup.beagle.core.ServerDrivenComponent
import br.com.zup.beagle.android.engine.renderer.layout.FormViewRenderer
import br.com.zup.beagle.widget.form.Form

internal class LayoutViewRendererFactory : AbstractViewRendererFactory {

    @Throws(IllegalArgumentException::class)
    override fun make(component: ServerDrivenComponent): ViewRenderer<*> {

        return when (component) {
            is Form -> FormViewRenderer(component)
            else -> throw IllegalArgumentException("$component is not a Layout Widget.")
        }
    }
}
