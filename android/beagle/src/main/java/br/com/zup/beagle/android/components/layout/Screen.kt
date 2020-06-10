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

package br.com.zup.beagle.android.components.layout

import br.com.zup.beagle.analytics.ScreenEvent
import br.com.zup.beagle.core.Appearance
import br.com.zup.beagle.core.ServerDrivenComponent
import br.com.zup.beagle.widget.layout.NavigationBar
import br.com.zup.beagle.widget.layout.SafeArea
import br.com.zup.beagle.widget.layout.Screen

open class Screen(override var identifier: String? = null,
                  override val safeArea: SafeArea? = null,
                  override val navigationBar: NavigationBar? = null,
                  override val child: ServerDrivenComponent,
                  override var appearance: Appearance? = null,
                  override val screenAnalyticsEvent: ScreenEvent? = null)
    : Screen(identifier, safeArea, navigationBar, child, appearance, screenAnalyticsEvent)