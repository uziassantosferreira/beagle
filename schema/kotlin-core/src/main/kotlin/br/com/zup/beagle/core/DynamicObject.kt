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

package br.com.zup.beagle.core

import java.io.Serializable

sealed class DynamicObject<T> : GenericAttribute<T>, Serializable {

    data class Empty(override val value: Any? = null) : DynamicObject<Any>()
    data class Boolean(override val value: kotlin.Boolean) : DynamicObject<kotlin.Boolean>()
    data class Int(override val value: kotlin.Int) : DynamicObject<kotlin.Int>()
    data class Double(override val value: kotlin.Double) : DynamicObject<kotlin.Double>()
    data class String(override val value: kotlin.String) : DynamicObject<kotlin.String>()
    data class Array(override val value: List<DynamicObject<*>>) : DynamicObject<List<DynamicObject<*>>>()
    data class Dictionary(override val value: Map<kotlin.String, DynamicObject<*>>) :
        DynamicObject<Map<kotlin.String, DynamicObject<*>>>()
}
