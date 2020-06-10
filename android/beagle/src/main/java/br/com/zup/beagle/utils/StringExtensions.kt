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

package br.com.zup.beagle.utils

import android.graphics.Color

internal fun String.toAndroidColor(): Int {
    val hexColor = if (this.startsWith("#")) this else "#$this"
    return Color.parseColor(hexColor)
}

internal fun String.getExpressions(): List<String> {
    val patterns = this.substringAfter("@{").split("@{")
    return patterns.map { pattern ->
        pattern.substring(0, pattern.indexOfFirst { it == '}' })
    }
}