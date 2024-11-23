package org.apache.tinkerpop.gremlin.structure.io.binary.types;

import org.apache.commons.lang3.builder.ToStringBuilder;

@ProviderDefined
public class Point {
    private Integer x;
    private Integer y;

    public Point() {
    }

    public Point(Integer x, Integer y) {
        this.x = x;
        this.y = y;
    }

    public Integer getX() {
        return this.x;
    }

    public void setX(Integer x) {
        this.x = x;
    }

    public Integer getY() {
        return this.y;
    }

    public void setY(Integer y) {
        this.y = y;
    }

    public String toString() {
        return ToStringBuilder.reflectionToString(this);
    }
}
