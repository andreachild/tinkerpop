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
package org.apache.tinkerpop.gremlin.process.traversal.step.map;

import org.apache.tinkerpop.gremlin.process.traversal.Traversal;
import org.apache.tinkerpop.gremlin.process.traversal.Traverser;
import org.apache.tinkerpop.gremlin.process.traversal.step.Configuring;
import org.apache.tinkerpop.gremlin.process.traversal.step.Writing;
import org.apache.tinkerpop.gremlin.process.traversal.step.stepContract.AddEdgeStepInterface;
import org.apache.tinkerpop.gremlin.process.traversal.step.util.Parameters;
import org.apache.tinkerpop.gremlin.process.traversal.step.util.event.CallbackRegistry;
import org.apache.tinkerpop.gremlin.process.traversal.step.util.event.Event;
import org.apache.tinkerpop.gremlin.process.traversal.step.util.event.EventUtil;
import org.apache.tinkerpop.gremlin.process.traversal.step.util.event.ListCallbackRegistry;
import org.apache.tinkerpop.gremlin.process.traversal.traverser.TraverserRequirement;
import org.apache.tinkerpop.gremlin.structure.Edge;
import org.apache.tinkerpop.gremlin.structure.Graph;
import org.apache.tinkerpop.gremlin.structure.T;
import org.apache.tinkerpop.gremlin.structure.Vertex;
import org.apache.tinkerpop.gremlin.structure.util.Attachable;
import org.apache.tinkerpop.gremlin.structure.util.StringFactory;
import org.apache.tinkerpop.gremlin.structure.util.empty.EmptyGraph;
import org.apache.tinkerpop.gremlin.structure.util.reference.ReferenceVertex;

import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * @author Marko A. Rodriguez (http://markorodriguez.com)
 * @author Stephen Mallette (http://stephen.genoprime.com)
 */
public class AddEdgeStep<S> extends ScalarMapStep<S, Edge>
        implements AddEdgeStepInterface<S>, Configuring {

    private static final String FROM = Graph.Hidden.hide("from");
    private static final String TO = Graph.Hidden.hide("to");

    private Parameters parameters = new Parameters();
    private CallbackRegistry<Event.EdgeAddedEvent> callbackRegistry;

    public AddEdgeStep(final Traversal.Admin traversal, final String edgeLabel) {
        super(traversal);
        this.parameters.set(this, T.label, edgeLabel);
    }

    public AddEdgeStep(final Traversal.Admin traversal, final Traversal.Admin<S,String> edgeLabelTraversal) {
        super(traversal);
        this.parameters.set(this, T.label, edgeLabelTraversal);
    }

    @Override
    public <S, E> List<Traversal.Admin<S, E>> getLocalChildren() {
        return this.parameters.getTraversals();
    }

    @Override
    public Parameters getParameters() {
        return this.parameters;
    }

    @Override
    public Set<String> getScopeKeys() {
        return this.parameters.getReferencedLabels();
    }

    @Override
    public void configure(final Object... keyValues) {
        this.parameters.set(this, keyValues);
    }

    @Override
    public void addTo(final Traversal.Admin<?, ?> toObject) {
        this.parameters.set(this, TO, toObject);
    }

    @Override
    public void addFrom(final Traversal.Admin<?, ?> fromObject) {
        this.parameters.set(this, FROM, fromObject);
    }

    @Override
    public Object getElementId() {
        return this.parameters.get(T.id, null);
    }

    @Override
    public void setElementId(Object elementId) {
        configure(T.id, elementId);
    }

    @Override
    protected Edge map(final Traverser.Admin<S> traverser) {
        final String edgeLabel = this.parameters.get(traverser, T.label, () -> Edge.DEFAULT_LABEL).get(0);

        Object theTo;
        try {
            theTo = this.parameters.get(traverser, TO, traverser::get).get(0);
            if (theTo != null && !(theTo instanceof Vertex)) {
                theTo = new ReferenceVertex(theTo);
            }
        } catch (IllegalArgumentException e) { // as thrown by TraversalUtil.apply()
            throw new IllegalStateException(String.format(
                    "addE(%s) failed because the to() traversal (which should give a Vertex) failed with: %s",
                    edgeLabel, e.getMessage()));
        }

        if (theTo == null)
            throw new IllegalStateException(String.format(
                    "The value given to addE(%s).to() must resolve to a Vertex or the ID of a Vertex present in the graph, but null was specified instead", edgeLabel));

        Object theFrom;
        try {
            theFrom  = this.parameters.get(traverser, FROM, traverser::get).get(0);
            if (theFrom != null && !(theFrom instanceof Vertex)) {
                theFrom = new ReferenceVertex(theFrom);
            }
        } catch (IllegalArgumentException e) { // as thrown by TraversalUtil.apply()
            throw new IllegalStateException(String.format(
                    "addE(%s) failed because the from() traversal (which should give a Vertex) failed with: %s",
                    edgeLabel, e.getMessage()), e);
        }

        if (theFrom == null)
            throw new IllegalStateException(String.format(
                    "The value given to addE(%s).from() must resolve to a Vertex or the ID of a Vertex present in the graph, but null was specified instead", edgeLabel));

        Vertex toVertex = (Vertex) theTo;
        Vertex fromVertex = (Vertex) theFrom;

        try {
            if (toVertex instanceof Attachable)
                toVertex = ((Attachable<Vertex>) toVertex)
                        .attach(Attachable.Method.get(this.getTraversal().getGraph().orElse(EmptyGraph.instance())));
        }
        catch (IllegalArgumentException e) {
            throw new IllegalStateException(String.format(
                    "The value given to addE(%s).to() must resolve to a Vertex or the ID of a Vertex present in the graph. The provided value does not match any vertices in the graph", edgeLabel));
        }

        try {
            if (fromVertex instanceof Attachable)
                fromVertex = ((Attachable<Vertex>) fromVertex)
                        .attach(Attachable.Method.get(this.getTraversal().getGraph().orElse(EmptyGraph.instance())));
        }
        catch (IllegalArgumentException e) {
            throw new IllegalStateException(String.format(
                    "The value given to addE(%s).from() must resolve to a Vertex or the ID of a Vertex present in the graph. The provided value does not match any vertices in the graph", edgeLabel));
        }


        final Edge edge = fromVertex.addEdge(edgeLabel, toVertex, this.parameters.getKeyValues(traverser, TO, FROM, T.label));
        EventUtil.registerEdgeCreation(callbackRegistry, getTraversal(), edge);
        return edge;
    }

    @Override
    public Set<TraverserRequirement> getRequirements() {
        return this.getSelfAndChildRequirements(TraverserRequirement.OBJECT);
    }

    @Override
    public CallbackRegistry<Event.EdgeAddedEvent> getMutatingCallbackRegistry() {
        if (null == this.callbackRegistry) this.callbackRegistry = new ListCallbackRegistry<>();
        return this.callbackRegistry;
    }

    @Override
    public int hashCode() {
        return super.hashCode() ^ this.parameters.hashCode();
    }

    @Override
    public String toString() {
        return StringFactory.stepString(this, this.parameters.toString());
    }

    @Override
    public void setTraversal(final Traversal.Admin<?, ?> parentTraversal) {
        super.setTraversal(parentTraversal);
        this.parameters.getTraversals().forEach(this::integrateChild);
    }

    @Override
    public AddEdgeStep<S> clone() {
        final AddEdgeStep<S> clone = (AddEdgeStep<S>) super.clone();
        clone.parameters = this.parameters.clone();
        return clone;
    }

    @Override
    public String getLabel() {
        return parameters.get(T.label, ()->"Edge").get(0);
    }

    @Override
    public void addProperty(Object key, Object value) {
        configure(key, value);
    }

    @Override
    public Map<Object, List<Object>> getProperties() {
        return parameters.getRaw(T.label, TO, FROM); //TODO:: any more exclusions needed?
    }

    @Override
    public void removeProperty(Object k) {
        parameters.remove(k);
    }

    @Override
    public Vertex getFrom() {
        return (Vertex) parameters.get(FROM, ()->null).get(0);
    }

    @Override
    public Vertex getTo() {
        return (Vertex) parameters.get(TO, ()->null).get(0);
    }
}
