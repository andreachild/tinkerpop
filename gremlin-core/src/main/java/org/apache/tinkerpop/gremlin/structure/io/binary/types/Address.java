package org.apache.tinkerpop.gremlin.structure.io.binary.types;

import org.apache.commons.lang3.builder.ToStringBuilder;

@ProviderDefined(name = "addy", excludedFields = {"secret"})
public class Address {
    private int number;
    private String street;
    private String secret;

    public Address() {
    }

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

    public String toString() {
        return ToStringBuilder.reflectionToString(this);
    }
}
