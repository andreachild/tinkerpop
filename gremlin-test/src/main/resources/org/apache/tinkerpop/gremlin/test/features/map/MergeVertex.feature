# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

@StepClassMap @StepMergeV
Feature: Step - mergeV()

  Scenario: g_mergeVXemptyX_optionXonMatch_nullX
    Given the empty graph
    And the graph initializer of
      """
      g.addV("person").property("name", "marko").property("age", 29)
      """
    And the traversal of
      """
      g.mergeV([:]).option(Merge.onMatch, null)
      """
    When iterated to list
    Then the result should have a count of 1
    And the graph should return 1 for count of "g.V().has(\"person\",\"name\",\"marko\").has(\"age\",29)"

  Scenario: g_V_mergeVXemptyX_optionXonMatch_nullX
    Given the empty graph
    And the graph initializer of
      """
      g.addV("person").property("name", "marko").property("age", 29)
      """
    And the traversal of
      """
      g.V().mergeV([:]).option(Merge.onMatch, null)
      """
    When iterated to list
    Then the result should have a count of 1
    And the graph should return 1 for count of "g.V().has(\"person\",\"name\",\"marko\").has(\"age\",29)"

  Scenario: g_mergeVXnullX_optionXonCreate_label_null_name_markoX
    Given the empty graph
    And the graph initializer of
      """
      g.addV("person").property("name", "marko").property("age", 29)
      """
    And using the parameter xx1 defined as "m[{\"t[label]\": null, \"name\":\"marko\"}]"
    And the traversal of
      """
      g.mergeV(xx1)
      """
    When iterated to list
    Then the traversal will raise an error

  Scenario: g_V_mergeVXnullX_optionXonCreate_label_null_name_markoX
    Given the empty graph
    And the graph initializer of
      """
      g.addV("person").property("name", "marko").property("age", 29)
      """
    And using the parameter xx1 defined as "m[{\"t[label]\": null, \"name\":\"marko\"}]"
    And the traversal of
      """
      g.V().mergeV(xx1)
      """
    When iterated to list
    Then the traversal will raise an error

  Scenario: g_mergeVXlabel_person_name_stephenX_optionXonCreate_nullX
    Given the empty graph
    And the graph initializer of
      """
      g.addV("person").property("name", "marko").property("age", 29)
      """
    And using the parameter xx1 defined as "m[{\"t[label]\": \"person\", \"name\":\"stephen\"}]"
    And the traversal of
      """
      g.mergeV(xx1).option(Merge.onCreate, null)
      """
    When iterated to list
    Then the result should have a count of 1
    And the graph should return 2 for count of "g.V()"
    And the graph should return 1 for count of "g.V().has(\"person\",\"name\",\"marko\")"
    And the graph should return 1 for count of "g.V().has(\"person\",\"name\",\"stephen\")"

  Scenario: g_V_mergeVXlabel_person_name_stephenX_optionXonCreate_nullX
    Given the empty graph
    And the graph initializer of
      """
      g.addV("person").property("name", "marko").property("age", 29)
      """
    And using the parameter xx1 defined as "m[{\"t[label]\": \"person\", \"name\":\"stephen\"}]"
    And the traversal of
      """
      g.V().mergeV(xx1).option(Merge.onCreate, null)
      """
    When iterated to list
    Then the result should have a count of 1
    And the graph should return 2 for count of "g.V()"
    And the graph should return 1 for count of "g.V().has(\"person\",\"name\",\"marko\")"
    And the graph should return 1 for count of "g.V().has(\"person\",\"name\",\"stephen\")"

  Scenario: g_mergeVXnullX_optionXonCreate_emptyX
    Given the empty graph
    And the graph initializer of
      """
      g.addV("person").property("name", "marko").property("age", 29)
      """
    And the traversal of
      """
      g.mergeV(null).option(Merge.onCreate,[:])
      """
    When iterated to list
    Then the result should have a count of 1
    And the graph should return 1 for count of "g.V()"

  Scenario: g_V_mergeVXnullX_optionXonCreate_emptyX
    Given the empty graph
    And the graph initializer of
      """
      g.addV("person").property("name", "marko").property("age", 29)
      """
    And the traversal of
      """
      g.V().mergeV(null).option(Merge.onCreate,[:])
      """
    When iterated to list
    Then the result should have a count of 1
    And the graph should return 1 for count of "g.V()"

  Scenario: g_mergeVXemptyX_no_existing
    Given the empty graph
    And the traversal of
      """
      g.mergeV([:])
      """
    When iterated to list
    Then the result should have a count of 1
    And the graph should return 1 for count of "g.V()"

  Scenario: g_injectX0X_mergeVXemptyX_no_existing
    Given the empty graph
    And the traversal of
      """
      g.inject(0).mergeV([:])
      """
    When iterated to list
    Then the result should have a count of 1
    And the graph should return 1 for count of "g.V()"

  Scenario: g_mergeVXemptyX
    Given the empty graph
    And the graph initializer of
      """
      g.addV("person").property("name", "marko").property("age", 29)
      """
    And the traversal of
      """
      g.mergeV([:])
      """
    When iterated to list
    Then the result should have a count of 1
    And the graph should return 1 for count of "g.V().has(\"person\",\"name\",\"marko\").has(\"age\",29)"

  Scenario: g_V_mergeVXemptyX_two_exist
    Given the empty graph
    And the graph initializer of
      """
      g.addV("person").property("name", "marko").property("age", 29).
        addV("person").property("name", "vadas").property("age", 27)
      """
    And the traversal of
      """
      g.V().mergeV([:])
      """
    When iterated to list
    Then the result should have a count of 4
    And the graph should return 2 for count of "g.V()"
    And the graph should return 1 for count of "g.V().has(\"person\",\"name\",\"marko\").has(\"age\",29)"
    And the graph should return 1 for count of "g.V().has(\"person\",\"name\",\"vadas\").has(\"age\",27)"

  Scenario: g_mergeVXnullX
    Given the empty graph
    And the graph initializer of
      """
      g.addV("person").property("name", "marko").property("age", 29)
      """
    And the traversal of
      """
      g.mergeV(null)
      """
    When iterated to list
    Then the result should have a count of 1
    And the graph should return 1 for count of "g.V()"

  @GremlinGroovyNotSupported
  Scenario: g_mergeVXnullvarX
    Given the empty graph
    And the graph initializer of
      """
      g.addV("person").property("name", "marko").property("age", 29)
      """
    And using the parameter xx1 defined as "null"
    And the traversal of
      """
      g.mergeV(xx1)
      """
    When iterated to list
    Then the result should have a count of 1
    And the graph should return 1 for count of "g.V()"

  Scenario: g_V_mergeVXnullX
    Given the empty graph
    And the graph initializer of
      """
      g.addV("person").property("name", "marko").property("age", 29)
      """
    And the traversal of
      """
      g.V().mergeV(null)
      """
    When iterated to list
    Then the result should have a count of 1
    And the graph should return 1 for count of "g.V()"

  Scenario: g_mergeVXlabel_person_name_stephenX
    Given the empty graph
    And the graph initializer of
      """
      g.addV("person").property("name", "marko").property("age", 29)
      """
    And using the parameter xx1 defined as "m[{\"t[label]\": \"person\", \"name\":\"stephen\"}]"
    And the traversal of
      """
      g.mergeV(xx1)
      """
    When iterated to list
    Then the result should have a count of 1
    And the graph should return 1 for count of "g.V().has(\"person\",\"name\",\"stephen\")"

  Scenario: g_mergeVXlabel_person_name_markoX
    Given the empty graph
    And the graph initializer of
      """
      g.addV("person").property("name", "marko").property("age", 29)
      """
    And using the parameter xx1 defined as "m[{\"t[label]\": \"person\", \"name\":\"marko\"}]"
    And the traversal of
      """
      g.mergeV(xx1)
      """
    When iterated to list
    Then the result should have a count of 1
    And the graph should return 1 for count of "g.V().has(\"person\",\"name\",\"marko\")"

  Scenario: g_mergeVXlabel_person_name_stephenX_optionXonCreate_label_person_name_stephen_age_19X_option
    Given the empty graph
    And the graph initializer of
      """
      g.addV("person").property("name", "marko").property("age", 29)
      """
    And using the parameter xx1 defined as "m[{\"t[label]\": \"person\", \"name\":\"stephen\"}]"
    And using the parameter xx2 defined as "m[{\"t[label]\": \"person\", \"name\":\"stephen\", \"age\": \"d[19].i\"}]"
    And the traversal of
      """
      g.mergeV(xx1).option(Merge.onCreate,xx2)
      """
    When iterated to list
    Then the result should have a count of 1
    And the graph should return 1 for count of "g.V().has(\"person\",\"name\",\"stephen\").has(\"age\", 19)"

  Scenario: g_mergeVXlabel_person_name_markoX_optionXonMatch_age_19X_option
    Given the empty graph
    And the graph initializer of
      """
      g.addV("person").property("name", "marko").property("age", 29)
      """
    And using the parameter xx1 defined as "m[{\"t[label]\": \"person\", \"name\":\"marko\"}]"
    And using the parameter xx2 defined as "m[{\"age\": \"d[19].i\"}]"
    And the traversal of
      """
      g.mergeV(xx1).option(Merge.onMatch,xx2)
      """
    When iterated to list
    Then the result should have a count of 1
    And the graph should return 1 for count of "g.V().has(\"person\",\"name\",\"marko\").has(\"age\", 19)"

  Scenario: g_withSideEffectXc_label_person_name_stephenX_withSideEffectXm_label_person_name_stephen_age_19X_mergeVXselectXcXX_optionXonCreate_selectXmXX_option
    Given the empty graph
    And the graph initializer of
      """
      g.addV("person").property("name", "marko").property("age", 29)
      """
    And using the parameter xx1 defined as "m[{\"t[label]\": \"person\", \"name\":\"stephen\"}]"
    And using the parameter xx2 defined as "m[{\"t[label]\": \"person\", \"name\":\"stephen\", \"age\": \"d[19].i\"}]"
    And the traversal of
      """
      g.withSideEffect("c", xx1).
        withSideEffect("m", xx2).
        mergeV(__.select("c")).option(Merge.onCreate, __.select("m"))
      """
    When iterated to list
    Then the result should have a count of 1
    And the graph should return 1 for count of "g.V().has(\"person\",\"name\",\"stephen\").has(\"age\", 19)"

  Scenario: g_withSideEffectXc_label_person_name_markoX_withSideEffectXm_age_19X_mergeVXselectXcXX_optionXonMatch_selectXmXX_option
    Given the empty graph
    And the graph initializer of
      """
      g.addV("person").property("name", "marko").property("age", 29)
      """
    And using the parameter xx1 defined as "m[{\"t[label]\": \"person\", \"name\":\"marko\"}]"
    And using the parameter xx2 defined as "m[{\"age\": \"d[19].i\"}]"
    And the traversal of
      """
      g.withSideEffect("c", xx1).
        withSideEffect("m", xx2).
        mergeV(__.select("c")).option(Merge.onMatch, __.select("m"))
      """
    When iterated to list
    Then the result should have a count of 1
    And the graph should return 1 for count of "g.V().has(\"person\",\"name\",\"marko\").has(\"age\", 19)"

  @MetaProperties
  Scenario: g_mergeVXlabel_person_name_markoX_propertyXname_vadas_acl_publicX
    Given the empty graph
    And the graph initializer of
      """
      g.addV("person").property("name", "marko").property("age", 29)
      """
    And using the parameter xx1 defined as "m[{\"t[label]\": \"person\", \"name\":\"marko\"}]"
    And the traversal of
      """
      g.mergeV(xx1).property("name","vadas","acl","public")
      """
    When iterated to list
    Then the result should have a count of 1
    And the graph should return 1 for count of "g.V().properties(\"name\").hasValue(\"vadas\").has(\"acl\",\"public\")"

  Scenario: g_injectX0X_mergeVXlabel_person_name_stephenX
    Given the empty graph
    And the graph initializer of
      """
      g.addV("person").property("name", "marko").property("age", 29)
      """
    And using the parameter xx1 defined as "m[{\"t[label]\": \"person\", \"name\":\"stephen\"}]"
    And the traversal of
      """
      g.inject(0).mergeV(xx1)
      """
    When iterated to list
    Then the result should have a count of 1
    And the graph should return 1 for count of "g.V().has(\"person\",\"name\",\"stephen\")"

  Scenario: g_injectX0X_mergeVXlabel_person_name_markoX
    Given the empty graph
    And the graph initializer of
      """
      g.addV("person").property("name", "marko").property("age", 29)
      """
    And using the parameter xx1 defined as "m[{\"t[label]\": \"person\", \"name\":\"marko\"}]"
    And the traversal of
      """
      g.inject(0).mergeV(xx1)
      """
    When iterated to list
    Then the result should have a count of 1
    And the graph should return 1 for count of "g.V().has(\"person\",\"name\",\"marko\")"

  Scenario: g_injectX0X_mergeVXlabel_person_name_stephenX_optionXonCreate_label_person_name_stephen_age_19X_option
    Given the empty graph
    And the graph initializer of
      """
      g.addV("person").property("name", "marko").property("age", 29)
      """
    And using the parameter xx1 defined as "m[{\"t[label]\": \"person\", \"name\":\"stephen\"}]"
    And using the parameter xx2 defined as "m[{\"t[label]\": \"person\", \"name\":\"stephen\", \"age\": \"d[19].i\"}]"
    And the traversal of
      """
      g.inject(0).mergeV(xx1).option(Merge.onCreate,xx2)
      """
    When iterated to list
    Then the result should have a count of 1
    And the graph should return 1 for count of "g.V().has(\"person\",\"name\",\"stephen\").has(\"age\", 19)"

  Scenario: g_injectX0X_mergeVXlabel_person_name_markoX_optionXonMatch_age_19X_option
    Given the empty graph
    And the graph initializer of
      """
      g.addV("person").property("name", "marko").property("age", 29)
      """
    And using the parameter xx1 defined as "m[{\"t[label]\": \"person\", \"name\":\"marko\"}]"
    And using the parameter xx2 defined as "m[{\"age\": \"d[19].i\"}]"
    And the traversal of
      """
      g.inject(0).mergeV(xx1).option(Merge.onMatch,xx2)
      """
    When iterated to list
    Then the result should have a count of 1
    And the graph should return 1 for count of "g.V().has(\"person\",\"name\",\"marko\").has(\"age\", 19)"

  Scenario: g_withSideEffectXc_label_person_name_stephenX_withSideEffectXm_label_person_name_stephen_age_19X_injectX0X_mergeVXselectXcXX_optionXonCreate_selectXmXX_option
    Given the empty graph
    And the graph initializer of
      """
      g.addV("person").property("name", "marko").property("age", 29)
      """
    And using the parameter xx1 defined as "m[{\"t[label]\": \"person\", \"name\":\"stephen\"}]"
    And using the parameter xx2 defined as "m[{\"t[label]\": \"person\", \"name\":\"stephen\", \"age\": \"d[19].i\"}]"
    And the traversal of
      """
      g.withSideEffect("c", xx1).
        withSideEffect("m", xx2).
        inject(0).mergeV(__.select("c")).option(Merge.onCreate, __.select("m"))
      """
    When iterated to list
    Then the result should have a count of 1
    And the graph should return 1 for count of "g.V().has(\"person\",\"name\",\"stephen\").has(\"age\", 19)"

  Scenario: g_withSideEffectXc_label_person_name_markoX_withSideEffectXm_age_19X_injectX0X_mergeVXselectXcXX_optionXonMatch_selectXmXX_option
    Given the empty graph
    And the graph initializer of
      """
      g.addV("person").property("name", "marko").property("age", 29)
      """
    And using the parameter xx1 defined as "m[{\"t[label]\": \"person\", \"name\":\"marko\"}]"
    And using the parameter xx2 defined as "m[{\"age\": \"d[19].i\"}]"
    And the traversal of
      """
      g.withSideEffect("c", xx1).
        withSideEffect("m", xx2).
        inject(0).mergeV(__.select("c")).option(Merge.onMatch, __.select("m"))
      """
    When iterated to list
    Then the result should have a count of 1
    And the graph should return 1 for count of "g.V().has(\"person\",\"name\",\"marko\").has(\"age\", 19)"

  @MetaProperties
  Scenario: g_injectX0X_mergeVXlabel_person_name_markoX_propertyXname_vadas_acl_publicX
    Given the empty graph
    And the graph initializer of
      """
      g.addV("person").property("name", "marko").property("age", 29)
      """
    And using the parameter xx1 defined as "m[{\"t[label]\": \"person\", \"name\":\"marko\"}]"
    And the traversal of
      """
      g.inject(0).mergeV(xx1).property("name","vadas","acl","public")
      """
    When iterated to list
    Then the result should have a count of 1
    And the graph should return 1 for count of "g.V().properties(\"name\").hasValue(\"vadas\").has(\"acl\",\"public\")"

  Scenario: g_injectXlabel_person_name_marko_label_person_name_stephenX_mergeVXidentityX
    Given the empty graph
    And the graph initializer of
      """
      g.addV("person").property("name", "marko").property("age", 29)
      """
    And using the parameter xx1 defined as "m[{\"t[label]\": \"person\", \"name\":\"marko\"}]"
    And using the parameter xx2 defined as "m[{\"t[label]\": \"person\", \"name\":\"stephen\"}]"
    And the traversal of
      """
      g.inject(xx1, xx2).mergeV(__.identity())
      """
    When iterated to list
    Then the result should have a count of 2
    And the graph should return 1 for count of "g.V().has(\"person\",\"name\",\"stephen\")"
    And the graph should return 1 for count of "g.V().has(\"person\",\"name\",\"marko\")"
    And the graph should return 2 for count of "g.V()"

  Scenario: g_injectXlabel_person_name_marko_label_person_name_stephenX_mergeV
    Given the empty graph
    And the graph initializer of
      """
      g.addV("person").property("name", "marko").property("age", 29)
      """
    And using the parameter xx1 defined as "m[{\"t[label]\": \"person\", \"name\":\"marko\"}]"
    And using the parameter xx2 defined as "m[{\"t[label]\": \"person\", \"name\":\"stephen\"}]"
    And the traversal of
      """
      g.inject(xx1, xx2).mergeV()
      """
    When iterated to list
    Then the result should have a count of 2
    And the graph should return 1 for count of "g.V().has(\"person\",\"name\",\"stephen\")"
    And the graph should return 1 for count of "g.V().has(\"person\",\"name\",\"marko\")"
    And the graph should return 2 for count of "g.V()"

  @MultiProperties
  Scenario: g_mergeVXlabel_person_name_stephenX_propertyXlist_name_steveX
    Given the empty graph
    And the graph initializer of
      """
      g.addV("person").property(list, "name", "stephen")
      """
    And using the parameter xx1 defined as "m[{\"t[label]\": \"person\", \"name\":\"stephen\"}]"
    And the traversal of
      """
      g.mergeV(xx1).property(Cardinality.list,"name","steve")
      """
    When iterated to list
    Then the result should have a count of 1
    And the graph should return 1 for count of "g.V()"
    And the graph should return 1 for count of "g.V().properties(\"name\").hasValue(\"steve\")"
    And the graph should return 1 for count of "g.V().properties(\"name\").hasValue(\"stephen\")"
    And the graph should return 2 for count of "g.V().properties(\"name\")"

  Scenario: g_mergeXlabel_person_name_vadasX_optionXonMatch_age_35X
    Given the empty graph
    And the graph initializer of
      """
      g.addV("person").property("name", "vadas").property("age", 29).
        addV("person").property("name", "vadas").property("age", 27)
      """
    And using the parameter xx1 defined as "m[{\"t[label]\": \"person\", \"name\":\"vadas\"}]"
    And using the parameter xx2 defined as "m[{\"age\":\"d[35].i\"}]"
    And the traversal of
      """
      g.mergeV(xx1).option(Merge.onMatch, xx2)
      """
    When iterated to list
    Then the result should have a count of 2
    And the graph should return 2 for count of "g.V().has(\"age\",35)"
    And the graph should return 2 for count of "g.V()"

  Scenario: g_V_mapXmergeXlabel_person_name_joshXX
    Given the empty graph
    And the graph initializer of
      """
      g.addV("person").property("name", "vadas").property("age", 29).
        addV("person").property("name", "stephen").property("age", 27)
      """
    And using the parameter xx1 defined as "m[{\"t[label]\": \"person\", \"name\":\"josh\"}]"
    And the traversal of
      """
      g.V().map(__.mergeV(xx1))
      """
    When iterated to list
    Then the result should have a count of 2
    And the graph should return 1 for count of "g.V().has(\"person\",\"name\",\"josh\")"
    And the graph should return 3 for count of "g.V()"

  @MultiProperties
  Scenario: g_withSideEffectXc_label_person_name_markoX_withSideEffectXm_age_19X_mergeVXselectXcXX_optionXonMatch_sideEffectXpropertiesXageX_dropX_selectXmXX_option
    Given the empty graph
    And the graph initializer of
      """
      g.addV("person").property("name", "marko").property(Cardinality.list, "age", 29).property(Cardinality.list, "age", 31).property(Cardinality.list, "age", 32)
      """
    And using the parameter xx1 defined as "m[{\"t[label]\": \"person\", \"name\":\"marko\"}]"
    And using the parameter xx2 defined as "m[{\"age\": \"d[19].i\"}]"
    And the traversal of
      """
      g.withSideEffect("c", xx1).
        withSideEffect("m", xx2).
        mergeV(__.select("c")).
          option(Merge.onMatch, __.sideEffect(__.properties("age").drop()).select("m"))
      """
    When iterated to list
    Then the result should have a count of 1
    And the graph should return 1 for count of "g.V().has(\"person\",\"name\",\"marko\").has(\"age\", 19)"
    And the graph should return 1 for count of "g.V().has(\"person\",\"name\",\"marko\").has(\"age\")"

  @MultiProperties
  Scenario: g_withSideEffectXm_age_19X_V_hasXperson_name_markoX_mergeVXselectXcXX_optionXonMatch_sideEffectXpropertiesXageX_dropX_selectXmXX_option
    Given the empty graph
    And the graph initializer of
      """
      g.addV("person").property("name", "marko").property(Cardinality.list, "age", 29).property(Cardinality.list, "age", 31).property(Cardinality.list, "age", 32)
      """
    And using the parameter xx1 defined as "m[{\"age\": \"d[19].i\"}]"
    And the traversal of
      """
      g.withSideEffect("m", xx1).
        V().has("person", "name", "marko").
        mergeV([:]).
          option(Merge.onMatch, __.sideEffect(__.properties("age").drop()).select("m"))
      """
    When iterated to list
    Then the result should have a count of 1
    And the graph should return 1 for count of "g.V().has(\"person\",\"name\",\"marko\").has(\"age\", 19)"
    And the graph should return 1 for count of "g.V().has(\"person\",\"name\",\"marko\").properties(\"age\")"

  # onCreate inheritance from merge
  @UserSuppliedVertexIds
  Scenario: g_mergeV_onCreate_inheritance_existing
    Given the empty graph
    And the graph initializer of
      """
      g.addV("person").property("name", "mike").property(T.id, "1")
      """
    And using the parameter xx1 defined as "m[{\"t[id]\": \"1\"}]"
    And using the parameter xx2 defined as "m[{\"t[label]\": \"person\", \"name\":\"mike\"}]"
    And the traversal of
      """
      g.mergeV(xx1).option(Merge.onCreate, xx2)
      """
    When iterated to list
    Then the result should have a count of 1
    And the graph should return 1 for count of "g.V()"
    And the graph should return 1 for count of "g.V(\"1\").has(\"person\",\"name\",\"mike\")"

  # onCreate inheritance from merge
  @UserSuppliedVertexIds
  Scenario: g_mergeV_onCreate_inheritance_new_1
    Given the empty graph
    And using the parameter xx1 defined as "m[{\"t[id]\": \"1\"}]"
    And using the parameter xx2 defined as "m[{\"t[label]\": \"person\", \"name\":\"mike\"}]"
    And the traversal of
      """
      g.mergeV(xx1).option(Merge.onCreate, xx2)
      """
    When iterated to list
    Then the result should have a count of 1
    And the graph should return 1 for count of "g.V()"
    And the graph should return 1 for count of "g.V(\"1\").has(\"person\",\"name\",\"mike\")"

  # onCreate inheritance from merge
  @UserSuppliedVertexIds
  Scenario: g_mergeV_onCreate_inheritance_new_2
    Given the empty graph
    And using the parameter xx1 defined as "m[{\"t[label]\": \"person\", \"name\":\"mike\"}]"
    And using the parameter xx2 defined as "m[{\"t[id]\": \"1\"}]"
    And the traversal of
      """
      g.mergeV(xx1).option(Merge.onCreate, xx2)
      """
    When iterated to list
    Then the result should have a count of 1
    And the graph should return 1 for count of "g.V()"
    And the graph should return 1 for count of "g.V(\"1\").has(\"person\",\"name\",\"mike\")"

  # cannot override T.label in onCreate
  Scenario: g_mergeV_label_override_prohibited
    Given the empty graph
    And using the parameter xx1 defined as "m[{\"t[label]\": \"a\"}]"
    And using the parameter xx2 defined as "m[{\"t[label]\": \"b\"}]"
    And the traversal of
      """
      g.mergeV(xx1).option(onCreate, xx2)
      """
    When iterated to list
    Then the traversal will raise an error with message containing text of "option(onCreate) cannot override values from merge() argument"

  # cannot override T.id in onCreate
  @UserSuppliedVertexIds
  Scenario: g_mergeV_id_override_prohibited
    Given the empty graph
    And using the parameter xx1 defined as "m[{\"t[id]\": \"1\"}]"
    And using the parameter xx2 defined as "m[{\"t[id]\": \"2\"}]"
    And the traversal of
      """
      g.mergeV(xx1).option(onCreate, xx2)
      """
    When iterated to list
    Then the traversal will raise an error with message containing text of "option(onCreate) cannot override values from merge() argument"

  # cannot use hidden namespace for id key
  Scenario: g_mergeV_hidden_id_key_prohibited
    Given the empty graph
    And using the parameter xx1 defined as "m[{\"~id\": \"1\"}]"
    And the traversal of
      """
      g.mergeV(xx1)
      """
    When iterated to list
    Then the traversal will raise an error

  # cannot use hidden namespace for label key
  Scenario: g_mergeV_hidden_label_key_prohibited
    Given the empty graph
    And using the parameter xx1 defined as "m[{\"~label\":\"vertex\"}]"
    And the traversal of
      """
      g.mergeV(xx1)
      """
    When iterated to list
    Then the traversal will raise an error

  # cannot use hidden namespace for label value
  Scenario: g_mergeV_hidden_label_value_prohibited
    Given the empty graph
    And using the parameter xx1 defined as "m[{\"t[label]\":\"~vertex\"}]"
    And the traversal of
      """
      g.mergeV(xx1)
      """
    When iterated to list
    Then the traversal will raise an error

  # cannot use hidden namespace for id key for onCreate
  Scenario: g_mergeV_hidden_id_key_onCreate_prohibited
    Given the empty graph
    And using the parameter xx1 defined as "m[{\"~id\": 1}]"
    And the traversal of
      """
      g.mergeV([:]).option(Merge.onCreate, xx1)
      """
    When iterated to list
    Then the traversal will raise an error with message containing text of "Property key can not be a hidden key: ~id"

  # cannot use hidden namespace for label key for onCreate
  Scenario: g_mergeV_hidden_label_key_onCreate_prohibited
    Given the empty graph
    And using the parameter xx1 defined as "m[{\"~label\":\"vertex\"}]"
    And the traversal of
      """
      g.mergeV([:]).option(Merge.onCreate, xx1)
      """
    When iterated to list
    Then the traversal will raise an error with message containing text of "Property key can not be a hidden key: ~label"

  # cannot use hidden namespace for label value for onCreate
  Scenario: g_mergeV_hidden_label_value_onCreate_prohibited
    Given the empty graph
    And using the parameter xx1 defined as "m[{\"t[label]\":\"~vertex\"}]"
    And the traversal of
      """
      g.mergeV([:]).option(Merge.onCreate, xx1)
      """
    When iterated to list
    Then the traversal will raise an error with message containing text of "Label can not be a hidden key: ~vertex"

  # cannot use hidden namespace for id key for onMatch
  Scenario: g_mergeV_hidden_id_key_onMatch_matched_prohibited
    Given the empty graph
    And the graph initializer of
      """
      g.addV("vertex")
      """
    And using the parameter xx1 defined as "m[{\"~id\": 1}]"
    And the traversal of
      """
      g.mergeV([:]).option(Merge.onMatch, xx1)
      """
    When iterated to list
    Then the traversal will raise an error with message containing text of "Property key can not be a hidden key: ~id"

  # cannot use hidden namespace for label key for onMatch
  Scenario: g_mergeV_hidden_label_key_matched_onMatch_matched_prohibited
    Given the empty graph
    And the graph initializer of
      """
      g.addV("vertex")
      """
    And using the parameter xx1 defined as "m[{\"~label\":\"vertex\"}]"
    And the traversal of
      """
      g.mergeV([:]).option(Merge.onMatch, xx1)
      """
    When iterated to list
    Then the traversal will raise an error with message containing text of "Property key can not be a hidden key: ~label"

  @MultiProperties
  Scenario: g_mergeVXname_markoX_optionXonMatch_age_listX33XX
    Given the empty graph
    And the graph initializer of
      """
      g.addV("person").property("name", "marko").property(Cardinality.list, "age", 29).property(Cardinality.list, "age", 31).property(Cardinality.list, "age", 32)
      """
    And the traversal of
      """
      g.mergeV([name: "marko"]).
          option(Merge.onMatch, [age: Cardinality.list(33)])
      """
    When iterated to list
    Then the result should have a count of 1
    And the graph should return 1 for count of "g.V().has(\"person\",\"name\",\"marko\").has(\"age\", 33)"
    And the graph should return 1 for count of "g.V().has(\"person\",\"name\",\"marko\").has(\"age\")"
    And the graph should return 4 for count of "g.V().has(\"person\",\"name\",\"marko\").properties(\"age\")"

  @MultiProperties
  Scenario: g_mergeVXname_markoX_optionXonMatch_age_setX33XX
    Given the empty graph
    And the graph initializer of
      """
      g.addV("person").property("name", "marko").property(Cardinality.list, "age", 29).property(Cardinality.list, "age", 31).property(Cardinality.list, "age", 32)
      """
    And the traversal of
      """
      g.mergeV([name: "marko"]).
          option(Merge.onMatch, [age: Cardinality.set(33)])
      """
    When iterated to list
    Then the result should have a count of 1
    And the graph should return 1 for count of "g.V().has(\"person\",\"name\",\"marko\").has(\"age\", 33)"
    And the graph should return 1 for count of "g.V().has(\"person\",\"name\",\"marko\").has(\"age\")"
    And the graph should return 4 for count of "g.V().has(\"person\",\"name\",\"marko\").properties(\"age\")"

  @MultiProperties
  Scenario: g_mergeVXname_markoX_optionXonMatch_age_setX31XX
    Given the empty graph
    And the graph initializer of
      """
      g.addV("person").property("name", "marko").property(Cardinality.list, "age", 29).property(Cardinality.list, "age", 31).property(Cardinality.list, "age", 32)
      """
    And the traversal of
      """
      g.mergeV([name: "marko"]).
          option(Merge.onMatch, [age: Cardinality.set(31)])
      """
    When iterated to list
    Then the result should have a count of 1
    And the graph should return 1 for count of "g.V().has(\"person\",\"name\",\"marko\").has(\"age\", 31)"
    And the graph should return 1 for count of "g.V().has(\"person\",\"name\",\"marko\").has(\"age\")"
    And the graph should return 3 for count of "g.V().has(\"person\",\"name\",\"marko\").properties(\"age\")"

  @MultiProperties
  Scenario: g_mergeVXname_markoX_optionXonMatch_age_singleX33XX
    Given the empty graph
    And the graph initializer of
      """
      g.addV("person").property("name", "marko").property(Cardinality.list, "age", 29).property(Cardinality.list, "age", 31).property(Cardinality.list, "age", 32)
      """
    And the traversal of
      """
      g.mergeV([name: "marko"]).
          option(Merge.onMatch, [age: Cardinality.single(33)])
      """
    When iterated to list
    Then the result should have a count of 1
    And the graph should return 1 for count of "g.V().has(\"person\",\"name\",\"marko\").has(\"age\", 33)"
    And the graph should return 1 for count of "g.V().has(\"person\",\"name\",\"marko\").has(\"age\")"
    And the graph should return 1 for count of "g.V().has(\"person\",\"name\",\"marko\").properties(\"age\")"

  @MultiProperties
  Scenario: g_mergeVXname_markoX_optionXonMatch_age_33_singleX
    Given the empty graph
    And the graph initializer of
      """
      g.addV("person").property("name", "marko").property(Cardinality.list, "age", 29).property(Cardinality.list, "age", 31).property(Cardinality.list, "age", 32)
      """
    And the traversal of
      """
      g.mergeV([name: "marko"]).
          option(Merge.onMatch, [age: 33], Cardinality.single)
      """
    When iterated to list
    Then the result should have a count of 1
    And the graph should return 1 for count of "g.V().has(\"person\",\"name\",\"marko\").has(\"age\", 33)"
    And the graph should return 1 for count of "g.V().has(\"person\",\"name\",\"marko\").has(\"age\")"
    And the graph should return 1 for count of "g.V().has(\"person\",\"name\",\"marko\").properties(\"age\")"

  @MultiProperties
  Scenario: g_mergeVXname_markoX_optionXonMatch_name_allen_age_setX31X_singleX
    Given the empty graph
    And the graph initializer of
      """
      g.addV("person").property("name", "marko").property(Cardinality.list, "age", 29).property(Cardinality.list, "age", 31).property(Cardinality.list, "age", 32)
      """
    And the traversal of
      """
      g.mergeV([name: "marko"]).
          option(Merge.onMatch, [name: "allen", age: Cardinality.set(31)], single)
      """
    When iterated to list
    Then the result should have a count of 1
    And the graph should return 0 for count of "g.V().has(\"person\",\"name\",\"marko\")"
    And the graph should return 1 for count of "g.V().has(\"person\",\"name\",\"allen\").has(\"age\", 31)"
    And the graph should return 1 for count of "g.V().has(\"person\",\"name\",\"allen\").has(\"age\")"
    And the graph should return 3 for count of "g.V().has(\"person\",\"name\",\"allen\").properties(\"age\")"

  @MultiProperties
  Scenario: g_mergeVXname_markoX_optionXonMatch_name_allen_age_singleX31X_singleX
    Given the empty graph
    And the graph initializer of
      """
      g.addV("person").property("name", "marko").property(Cardinality.list, "age", 29).property(Cardinality.list, "age", 31).property(Cardinality.list, "age", 32)
      """
    And the traversal of
      """
      g.mergeV([name: "marko"]).
          option(Merge.onMatch, [name: "allen", age: Cardinality.single(31)], single)
      """
    When iterated to list
    Then the result should have a count of 1
    And the graph should return 0 for count of "g.V().has(\"person\",\"name\",\"marko\")"
    And the graph should return 0 for count of "g.V().has(\"person\",\"name\",\"allen\").has(\"age\", 33)"
    And the graph should return 1 for count of "g.V().has(\"person\",\"name\",\"allen\").has(\"age\", 31)"
    And the graph should return 1 for count of "g.V().has(\"person\",\"name\",\"allen\").has(\"age\")"
    And the graph should return 1 for count of "g.V().has(\"person\",\"name\",\"allen\").properties(\"age\")"

  @MultiProperties
  Scenario: g_mergeVXname_aliceX_optionXonCreate_age_singleX81XX
    Given the empty graph
    And the traversal of
      """
      g.mergeV([name: "alice", (T.label): "person"]).
          option(Merge.onCreate, [age: Cardinality.single(81)])
      """
    When iterated to list
    Then the result should have a count of 1
    And the graph should return 1 for count of "g.V().has(\"person\",\"name\",\"alice\").has(\"age\", 81)"
    And the graph should return 1 for count of "g.V().has(\"person\",\"name\",\"alice\").has(\"age\")"
    And the graph should return 1 for count of "g.V().has(\"person\",\"name\",\"alice\").properties(\"age\")"

  @MultiProperties
  Scenario: g_mergeVXname_aliceX_optionXonCreate_age_setX81XX
    Given the empty graph
    And the traversal of
      """
      g.mergeV([name: "alice", (T.label): "person"]).
          option(Merge.onCreate, [age: Cardinality.set(81)])
      """
    When iterated to list
    Then the result should have a count of 1
    And the graph should return 1 for count of "g.V().has(\"person\",\"name\",\"alice\").has(\"age\", 81)"
    And the graph should return 1 for count of "g.V().has(\"person\",\"name\",\"alice\").has(\"age\")"
    And the graph should return 1 for count of "g.V().has(\"person\",\"name\",\"alice\").properties(\"age\")"

  @MultiProperties
  Scenario: g_mergeVXname_aliceX_optionXonCreate_age_singleX81X_age_81_setX
    Given the empty graph
    And the traversal of
      """
      g.mergeV([name: "alice", (T.label): "person"]).
          option(Merge.onCreate, [age: 81], Cardinality.set)
      """
    When iterated to list
    Then the result should have a count of 1
    And the graph should return 1 for count of "g.V().has(\"person\",\"name\",\"alice\").has(\"age\", 81)"
    And the graph should return 1 for count of "g.V().has(\"person\",\"name\",\"alice\").has(\"age\")"
    And the graph should return 1 for count of "g.V().has(\"person\",\"name\",\"alice\").properties(\"age\")"

  # cannot use hidden namespace for label key for onMatch
  Scenario: g_mergeV_hidden_label_key_onMatch_matched_prohibited
    Given the empty graph
    And using the parameter xx1 defined as "m[{\"~label\":\"vertex\"}]"
    And the traversal of
      """
      g.mergeV([:]).option(Merge.onMatch, xx1)
      """
    When iterated to list
    Then the traversal will raise an error with message containing text of "Property key can not be a hidden key: ~label"

  Scenario: g_injectXlist1_list2X_mergeVXlimitXlocal_1XX_optionXonCreate_rangeXlocal_1_2X_optionXonMatch_tailXlocalXX_to_match
    Given the empty graph
    And the graph initializer of
      """
      g.addV("person").property("name", "marko").property("age", 29)
      """
    And using the parameter xx1 defined as "m[{\"t[label]\": \"person\", \"name\":\"marko\"}]"
    And using the parameter xx2 defined as "m[{\"created\": \"N\"}]"
    And the traversal of
      """
      g.inject(xx1, xx1, xx2).
        fold().as("m").
        mergeV(__.select("m").limit(Scope.local,1)).
          option(Merge.onCreate, __.select("m").range(Scope.local, 1, 2)).
          option(Merge.onMatch, __.select("m").tail(Scope.local))
      """
    When iterated to list
    Then the result should have a count of 1
    And the graph should return 1 for count of "g.V().has(\"person\",\"name\",\"marko\").has(\"created\",\"N\")"
    And the graph should return 1 for count of "g.V()"

  Scenario: g_injectXlist1_list2X_mergeVXlimitXlocal_1XX_optionXonCreate_rangeXlocal_1_2X_optionXonMatch_tailXlocalXX_to_create
    Given the empty graph
    And the graph initializer of
      """
      g.addV("person").property("name", "marko").property("age", 29)
      """
    And using the parameter xx1 defined as "m[{\"t[label]\": \"person\", \"name\":\"stephen\"}]"
    And using the parameter xx2 defined as "m[{\"created\": \"N\"}]"
    And the traversal of
      """
      g.inject(xx1, xx1, xx2).
        fold().as("m").
        mergeV(__.select("m").limit(Scope.local,1)).
          option(Merge.onCreate, __.select("m").range(Scope.local, 1, 2)).
          option(Merge.onMatch, __.select("m").tail(Scope.local))
      """
    When iterated to list
    Then the result should have a count of 1
    And the graph should return 1 for count of "g.V().has(\"person\",\"name\",\"stephen\").hasNot(\"created\")"
    And the graph should return 2 for count of "g.V()"

  @AllowNullPropertyValues
  Scenario: g_mergeVXlabel_person_name_marko_age_29X_optionXonMatch_age_nullX_allowed
    Given the empty graph
    And using the parameter xx1 defined as "m[{\"t[label]\": \"person\", \"name\":\"marko\"}]"
    And using the parameter xx2 defined as "m[{\"age\": null}]"
    And the graph initializer of
      """
      g.addV("person").property("name", "marko").property("age", 29)
      """
    And the traversal of
      """
      g.mergeV(xx1).option(Merge.onMatch, xx2)
      """
    When iterated to list
    Then the result should have a count of 1
    And the graph should return 1 for count of "g.V()"
    And the graph should return 1 for count of "g.V().has(\"person\",\"name\",\"marko\").has(\"age\",null)"

  @DisallowNullPropertyValues
  Scenario: g_mergeVXlabel_person_name_marko_age_29X_optionXonMatch_age_nullX
    Given the empty graph
    And using the parameter xx1 defined as "m[{\"t[label]\": \"person\", \"name\":\"marko\"}]"
    And using the parameter xx2 defined as "m[{\"age\": null}]"
    And the graph initializer of
      """
      g.addV("person").property("name", "marko").property("age", 29)
      """
    And the traversal of
      """
      g.mergeV(xx1).option(Merge.onMatch, xx2)
      """
    When iterated to list
    Then the result should have a count of 1
    And the graph should return 1 for count of "g.V()"
    And the graph should return 0 for count of "g.V().has(\"person\",\"name\",\"marko\").has(\"age\")"