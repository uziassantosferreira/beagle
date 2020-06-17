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

package br.com.zup.beagle.android.data.serializer.adapter

import br.com.zup.beagle.core.DynamicObject
import br.com.zup.beagle.core.toDynamicObject
import com.squareup.moshi.JsonAdapter
import com.squareup.moshi.JsonReader
import com.squareup.moshi.JsonWriter
import com.squareup.moshi.Moshi
import com.squareup.moshi.Types
import java.lang.reflect.Type

internal class DynamicObjectAdapterFactory : JsonAdapter.Factory {

    override fun create(
        type: Type,
        annotations: MutableSet<out Annotation>,
        moshi: Moshi
    ): JsonAdapter<DynamicObject<*>>? {
        return if (Types.getRawType(type) == DynamicObject::class.java) {
            DynamicObjectAdapter()
        } else {
            null
        }
    }
}

internal class DynamicObjectAdapter : JsonAdapter<DynamicObject<*>>() {

    @Suppress("UNCHECKED_CAST")
    override fun fromJson(reader: JsonReader): DynamicObject<*>? {
        return reader.readJsonValue().toDynamicObject()
    }

    override fun toJson(writer: JsonWriter, value: DynamicObject<*>?) {
        when (value) {
            is DynamicObject.Empty -> writer.nullValue()
            is DynamicObject.Boolean -> writer.value(value.value)
            is DynamicObject.Int -> writer.value(value.value)
            is DynamicObject.Double -> writer.value(value.value)
            is DynamicObject.String -> writer.value(value.value)
            is DynamicObject.Array -> {
                writer.beginArray()
                value.value.forEach {
                    toJson(writer, it)
                }
                writer.endArray()
            }
            is DynamicObject.Dictionary -> {
                writer.beginObject()
                value.value.map {
                    writer.name(it.key)
                    toJson(writer, it.value)
                }
                writer.endObject()
            }
        }
    }
}
