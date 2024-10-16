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

@StepClassIntegrated
Feature: Step - CountStrategy

  @WithCountStrategy
  Scenario: g_withStrategiesXCountStrategyX_V_whereXoutE_count_isX0XX
    Given the modern graph
    And the traversal of
      """
      g.withStrategies(CountStrategy).V().where(outE().count().is(0))
      """
    When iterated to list
    Then the result should be unordered
      | result |
      | v[vadas] |
      | v[lop] |
      | v[ripple]  |

  Scenario: g_withoutStrategiesXCountStrategyX_V_whereXoutE_count_isX0XX
    Given the modern graph
    And the traversal of
      """
      g.withoutStrategies(CountStrategy).V().where(outE().count().is(0))
      """
    When iterated to list
    Then the result should be unordered
      | result |
      | v[vadas] |
      | v[lop] |
      | v[ripple]  |