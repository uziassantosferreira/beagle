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

package br.com.zup.beagle.android.utils

import androidx.lifecycle.ViewModelProvider
import br.com.zup.beagle.android.data.BeagleViewModel
import br.com.zup.beagle.android.engine.renderer.ActivityRootView
import br.com.zup.beagle.android.engine.renderer.FragmentRootView
import br.com.zup.beagle.android.widget.RootView

internal fun RootView.generateViewModelInstance(): BeagleViewModel {
    return when (this) {
        is ActivityRootView -> {
            val activity = this.activity
            ViewModelProvider(activity).get(BeagleViewModel::class.java)
        }
        else -> {
            val fragment = (this as FragmentRootView).fragment
            ViewModelProvider(fragment).get(BeagleViewModel::class.java)
        }
    }
}