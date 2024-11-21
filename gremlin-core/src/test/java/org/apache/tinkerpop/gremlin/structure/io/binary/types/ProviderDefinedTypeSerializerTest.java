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

import org.apache.kerby.util.HexUtil;
import org.apache.tinkerpop.gremlin.structure.io.TestBuffer;
import org.apache.tinkerpop.gremlin.structure.io.binary.GraphBinaryReader;
import org.apache.tinkerpop.gremlin.structure.io.binary.GraphBinaryWriter;
import org.junit.Test;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;

public class ProviderDefinedTypeSerializerTest {
    private ProviderDefinedTypeSerializer serializer = new ProviderDefinedTypeSerializer();
    private GraphBinaryWriter writer = new GraphBinaryWriter();
    private GraphBinaryReader reader = new GraphBinaryReader();

    @Test
    public void test() throws Exception {
        TestBuffer buffer = new TestBuffer();
        writer.write(new Point(1, 2), buffer);
        outputHex(buffer);
        final ProviderDefinedType result = reader.read(buffer);
        System.out.println(result);
        assertEquals("Point", result.getName());
        assertEquals(2, result.getProperties().size());
        assertEquals(1, result.getProperties().get("x"));
        assertEquals(2, result.getProperties().get("y"));
    }

    @Test
    public void testNested() throws Exception {
        TestBuffer buffer = new TestBuffer();
        ProviderDefinedType value = new ProviderDefinedType(new Person("Andrea", 123, new Address(1234, "Main St", "shhh..."), "ABC123"));
        writer.write(value, buffer);
        outputHex(buffer);

        final ProviderDefinedType result = reader.read(buffer);
        System.out.println(result);
        assertEquals("Person", result.getName());
        assertEquals(3, result.getProperties().size());
        assertEquals("Andrea", result.getProperties().get("name"));
        assertEquals(123, result.getProperties().get("age"));
        assertTrue(result.getProperties().get("address") instanceof ProviderDefinedType);
        ProviderDefinedType address = (ProviderDefinedType) result.getProperties().get("address");
        assertEquals("addy", address.getName());
        assertEquals(2, address.getProperties().size());
        assertEquals(1234, address.getProperties().get("number"));
        assertEquals("Main St", address.getProperties().get("street"));
    }

    private void outputHex(TestBuffer buffer) {
        byte[] b = new byte[buffer.readableBytes()];
        buffer.readerIndex(0);
        buffer.readBytes(b);
        String hex = HexUtil.bytesToHexFriendly(b);
        System.out.println("hex:" + hex);
        buffer.readerIndex(0);
    }

    @ProviderDefined
    public static class Point {
        private final int x;
        private final int y;

        public Point(int x, int y) {
            this.x = x;
            this.y = y;
        }

        public int getX() {
            return this.x;
        }

        public int getY() {
            return this.y;
        }
    }

    @ProviderDefined(includedFields = {"name", "age", "address"})
    public static class Person {
        private final String name;
        private final int age;
        private final Address address;
        private final String passport;

        public Person(String name, int age, Address address, String passport) {
            this.name = name;
            this.age = age;
            this.address = address;
            this.passport = passport;
        }

        public String getName() {
            return this.name;
        }

        public int getAge() {
            return this.age;
        }

        public Address getAddress() {
            return this.address;
        }

        public String getPassport() {
            return this.passport;
        }
    }

    @ProviderDefined(name = "addy", excludedFields = {"secret"})
    public static class Address {
        private final int number;
        private final String street;
        private final String secret;

        public Address(int number, String street, String secret) {
            this.number = number;
            this.street = street;
            this.secret = secret;
        }

        public String getStreet() {
            return this.street;
        }

        public int getNumber() {
            return this.number;
        }

        public String getSecret() {
            return this.secret;
        }
    }

}