/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

package org.apache.tinkerpop.gremlin.structure.io.binary.types;

import java.util.Collections;
import java.util.HashMap;
import java.util.Map;
import org.apache.kerby.util.HexUtil;
import org.apache.tinkerpop.gremlin.structure.io.TestBuffer;
import org.apache.tinkerpop.gremlin.structure.io.binary.GraphBinaryReader;
import org.apache.tinkerpop.gremlin.structure.io.binary.GraphBinaryWriter;
import org.junit.Test;

import static org.junit.Assert.*;

public class ProviderDefinedTypeSerializerTest {
    private ProviderDefinedTypeSerializer serializer = new ProviderDefinedTypeSerializer();
    private GraphBinaryWriter writer = new GraphBinaryWriter();
    private GraphBinaryReader reader = new GraphBinaryReader();

    @Test
    public void test() throws Exception{
        TestBuffer buffer = new TestBuffer();
        Map<String, Integer> m = new HashMap<>();
        m.put("x", 1);
        m.put("y", 2);
        writer.write(new ProviderDefinedType("Point", m), buffer);

        byte[] b = new byte[buffer.readableBytes()];
        buffer.readerIndex(0);
        buffer.readBytes(b);
        String hex = HexUtil.bytesToHexFriendly(b);
        System.out.println("hex:" + hex);


        buffer.readerIndex(0);
        final Object result = reader.read(buffer);
        System.out.println(result);

    }

}