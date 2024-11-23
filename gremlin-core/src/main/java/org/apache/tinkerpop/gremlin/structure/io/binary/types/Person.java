package org.apache.tinkerpop.gremlin.structure.io.binary.types;

import org.apache.commons.lang3.builder.ToStringBuilder;

@ProviderDefined(includedFields = {"name", "age", "address"})
public class Person {
    private String name;
    private int age;
    private Address address;
    private String passport;

    public Person() {
    }

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

    public String toString() {
        return ToStringBuilder.reflectionToString(this);
    }
}
