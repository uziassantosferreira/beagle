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

data class ContextData(
    val id: String,
    val value: DynamicObject<*>
) {
    constructor(id: String, value: Any) : this(
        id, value.toDynamicObject()
    )
}

fun Any?.toDynamicObject() : DynamicObject<*> {
    return when (this) {
        is DynamicObject<*> -> this
        is Boolean -> DynamicObject.Boolean(this)
        is Int -> DynamicObject.Int(this)
        is Double -> DynamicObject.Double(this)
        is String -> DynamicObject.String(this)
        is List<*> -> {
            DynamicObject.Array(this.map {
                it.toDynamicObject()
            })
        }
        is Map<*, *> -> DynamicObject.Dictionary(this.map {
            it.key as String to it.value.toDynamicObject()
        }.toMap())
        is Bind<*> -> DynamicObject.String(this.value.toString())
        else -> DynamicObject.Empty()
    }
}
