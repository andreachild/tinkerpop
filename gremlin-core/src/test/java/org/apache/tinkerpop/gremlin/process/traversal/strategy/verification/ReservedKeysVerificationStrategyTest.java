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
package org.apache.tinkerpop.gremlin.process.traversal.strategy.verification;

import nl.altindag.log.LogCaptor;
import org.apache.tinkerpop.gremlin.process.traversal.Traversal;
import org.apache.tinkerpop.gremlin.process.traversal.TraversalStrategies;
import org.apache.tinkerpop.gremlin.process.traversal.dsl.graph.__;
import org.apache.tinkerpop.gremlin.process.traversal.util.DefaultTraversalStrategies;
import org.apache.tinkerpop.gremlin.structure.T;
import org.junit.AfterClass;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.Parameterized;

import java.util.Arrays;
import java.util.HashSet;
import java.util.function.Predicate;
import java.util.regex.Pattern;

import static org.hamcrest.MatcherAssert.assertThat;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.fail;

/**
 * @author Stephen Mallette (http://stephen.genoprime.com)
 */
@RunWith(Parameterized.class)
public class ReservedKeysVerificationStrategyTest {

    private final static Predicate<String> MSG_PREDICATE = Pattern.compile(
            ".*that is setting a property key to a reserved word.*")
            .asPredicate();

    private static LogCaptor logCaptor;

    @BeforeClass
    public static void setupLogCaptor() {
        logCaptor = LogCaptor.forClass(AbstractWarningVerificationStrategy.class);
    }

    @Before
    public void resetLogs() {
        logCaptor.clearLogs();
    }

    @AfterClass
    public static void tearDown() {
        logCaptor.close();
    }

    @Parameterized.Parameters(name = "{0}")
    public static Iterable<Object[]> data() {
        return Arrays.asList(new Object[][]{
                {__.addV().property("id", 123), false},
                {__.addE("knows").property("id", 123), false},
                {__.addV().property(T.id, 123), true},
                {__.addE("knows").property(T.label, "blah"), true},
                {__.addV().property("label", "xyz"), false},
                {__.addE("knows").property("id", "xyz"), false},
                {__.addV().property("x", "xyz", "label", "xxx"), false},
                {__.addV().property("x", "xyz", "not-label", "xxx"), true},
                {__.addV().property("x", "xyz", "not-allowed", "xxx"), false},
        });
    }

    @Parameterized.Parameter(value = 0)
    public Traversal.Admin traversal;

    @Parameterized.Parameter(value = 1)
    public boolean allow;

    @Test
    public void shouldIgnore() {
        final TraversalStrategies strategies = new DefaultTraversalStrategies();
        strategies.addStrategies(ReservedKeysVerificationStrategy.build().create());
        final Traversal traversal = this.traversal.asAdmin().clone();
        traversal.asAdmin().setStrategies(strategies);
        traversal.asAdmin().applyStrategies();
        assertEquals(0, logCaptor.getLogs().size());
    }

    @Test
    public void shouldOnlyThrow() {
        final String repr = traversal.getGremlinLang().getGremlin("__");
        final TraversalStrategies strategies = new DefaultTraversalStrategies();
        final ReservedKeysVerificationStrategy.Builder builder = ReservedKeysVerificationStrategy.build().throwException();
        if (repr.equals("__.addV().property(\"x\",\"xyz\",\"not-allowed\",\"xxx\")"))
            builder.reservedKeys(new HashSet<>(Arrays.asList("id", "label", "not-allowed")));
        strategies.addStrategies(builder.create());
        final Traversal traversal = this.traversal.asAdmin().clone();
        traversal.asAdmin().setStrategies(strategies);
        if (allow) {
            traversal.asAdmin().applyStrategies();
        } else {
            try {
                traversal.asAdmin().applyStrategies();
                fail("The strategy should not allow vertex steps with unspecified edge labels: " + repr);
            } catch (VerificationException ise) {
                assertThat(repr, MSG_PREDICATE.test(ise.getMessage()));
            }
        }
        assertEquals(0, logCaptor.getLogs().size());
    }

    @Test
    public void shouldOnlyLog() {
        final String repr = traversal.getGremlinLang().getGremlin("__");
        final TraversalStrategies strategies = new DefaultTraversalStrategies();
        final ReservedKeysVerificationStrategy.Builder builder = ReservedKeysVerificationStrategy.build().logWarning();
        if (repr.equals("__.addV().property(\"x\",\"xyz\",\"not-allowed\",\"xxx\")"))
            builder.reservedKeys(new HashSet<>(Arrays.asList("id", "label", "not-allowed")));
        strategies.addStrategies(builder.create());
        final Traversal traversal = this.traversal.asAdmin().clone();
        traversal.asAdmin().setStrategies(strategies);
        traversal.asAdmin().applyStrategies();
        if (!allow) {
            assertThat(String.format("Expected log entry not found in %s for %s", logCaptor.getLogs(), repr),
                    logCaptor.getLogs().stream().anyMatch(MSG_PREDICATE));
        }
    }

    @Test
    public void shouldThrowAndLog() {
        final String repr = traversal.getGremlinLang().getGremlin("__");
        final TraversalStrategies strategies = new DefaultTraversalStrategies();
        final ReservedKeysVerificationStrategy.Builder builder = ReservedKeysVerificationStrategy.build().
                throwException().logWarning();
        if (repr.equals("__.addV().property(\"x\",\"xyz\",\"not-allowed\",\"xxx\")"))
            builder.reservedKeys(new HashSet<>(Arrays.asList("id", "label", "not-allowed")));
        strategies.addStrategies(builder.create());
        final Traversal traversal = this.traversal.asAdmin().clone();
        traversal.asAdmin().setStrategies(strategies);
        if (allow) {
            traversal.asAdmin().applyStrategies();
            assertEquals(0, logCaptor.getLogs().size());
        } else {
            try {
                traversal.asAdmin().applyStrategies();
                fail("The strategy should not allow vertex steps with unspecified edge labels: " + repr);
            } catch (VerificationException ise) {
                assertThat(repr, MSG_PREDICATE.test(ise.getMessage()));
            }
            assertThat(String.format("Expected log entry not found in %s for %s", logCaptor.getLogs(), repr),
                    logCaptor.getLogs().stream().anyMatch(MSG_PREDICATE));
        }
    }
}