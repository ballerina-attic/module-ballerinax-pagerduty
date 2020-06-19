// Copyright (c) 2020 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

function escalationPolicyToPayload(EscalationPolicy|json input) returns @tainted map<json> {
    map<json>|EscalationPolicy escalationPolicy = {};
    if (input is EscalationPolicy) {
        escalationPolicy = input;
    } else {
        escalationPolicy = <map<json>>input;
    }
    map<json> payload = {};
    addStringToPayload(escalationPolicy[HTML_URL], payload, HTML_URL_VAR);
    addStringToPayload(escalationPolicy[NAME], payload, NAME);
    addStringToPayload(escalationPolicy[SUMMARY], payload, SUMMARY);
    addStringToPayload(escalationPolicy[URL], payload, SELF);
    addStringToPayload(escalationPolicy[ID], payload, ID);
    addStringToPayload(escalationPolicy[DESCRIPTION], payload, DESCRIPTION);
    addIntToPayload(escalationPolicy[NUMBER_OF_LOOPS], payload, NUM_LOOPS);
    string value = escalationPolicy[TYPE].toString();
    if (value == ESCALATION_POLICY) {
        payload[TYPE] = ESCALATION_POLICY_VAR;
    } else if (value == ESCALATION_POLICY_REFERENCE) {
        payload[TYPE] = ESCALATION_POLICY_REFERENCE_VAR;
    }
    value = escalationPolicy[ON_CALL_HAND_OF_NOTIFICATION].toString();
    if (value != "") {
        if (value == HAS_SERVICE) {
            value = IF_HAS_SERVICE;
        } else {
            value = ALWAYS;
        }
        payload[ON_CALL_HAND_OF_NOTIFICATION_VAR] = value;
    }
    int i = 0;
    // Sets escalation rules
    json[] list = [];
    var rules = escalationPolicy[ESCALATION_RULES];
    if (rules is EscalationRule[] && rules != []) {
        while (i < rules.length()) {
            list[i] = escalationRuleToPayload(rules[i]);
            i = i + 1;
        }
                payload[ESCALATION_RULE_VAR] = list;
    } else {
        json[] escalationRule = <json[]>rules;
        while (i < escalationRule.length()) {
            list[i] = escalationRuleToPayload(escalationRule[i]);
            i = i + 1;
        }
        payload[ESCALATION_RULE_VAR] = list;
    }
    // Sets service
    var serv = escalationPolicy[SERVICES];
    if (serv is Service[]) {
        i = 0;
        json[] serviceList = [];
        while (i < serv.length()) {
            serviceList[i] = serviceToPayload(serv[i]);
            i = i + 1;
        }
        payload[SERVICES] = serviceList;
    }
    var teams = escalationPolicy[TEAMS];
    commonsOrJsonToPayload(escalationPolicy[TEAMS], payload, TEAMS);
    return payload;
}

function escalationRuleToPayload(EscalationRule|json input) returns map<json> {
    map<json>|EscalationRule escalationRule = {};
    if (input is EscalationRule) {
        escalationRule = input;
    } else if (input != ()) {
        escalationRule = <map<json>>input;
    }
    map<json> payload = {};
    addIntToPayload(escalationRule[ESCALATION_DELAY_IN_MINUTES], payload, ESCALATION_DELAY_IN_MINUTES_VAR);
    addStringToPayload(escalationRule[ID], payload, ID);
    commonsOrJsonToPayload(escalationRule[TARGETS], payload, TARGETS);
    return payload;
}

function convertToEscalationPolicy(map<json> response) returns @tainted EscalationPolicy {
    EscalationPolicy escalationPolicy = { 'type: "escalationPolicy", name: "", escalationRules: []};
    string value = response[TYPE].toString();
    if (value == ESCALATION_POLICY_VAR) {
       escalationPolicy.'type = ESCALATION_POLICY;
    } else if (value == ESCALATION_POLICY_REFERENCE_VAR) {
       escalationPolicy.'type = ESCALATION_POLICY_REFERENCE;
    }
    addString(response[ID], escalationPolicy, ID);
    addString(response[SELF], escalationPolicy, URL);
    addString(response[NAME], escalationPolicy, NAME);
    addString(response[DESCRIPTION], escalationPolicy, DESCRIPTION);
    addString(response[HTML_URL_VAR], escalationPolicy, HTML_URL);
    addInt(response[NUM_LOOPS], escalationPolicy, NUMBER_OF_LOOPS);
    value = response[ON_CALL_HAND_OF_NOTIFICATION_VAR].toString();
    if (value != "") {
        if (value == IF_HAS_SERVICE) {
            escalationPolicy.onCallHandoffNotifications = HAS_SERVICE;
        } else {
            escalationPolicy.onCallHandoffNotifications = ALWAYS;
        }
    }
    int i = 0;
    var rulesValue = response[ESCALATION_RULE_VAR];
    if (rulesValue != ()) {
        json[] escalationRuleList = <json[]>rulesValue;
        escalationPolicy.escalationRules = [];
        EscalationRule[] rules = [];
        int length = escalationRuleList.length();
        if (length > 0) {
            while (i < length) {
                EscalationRule escalationRule = {escalationDelayInMinutes: 0, targets: []};
                convertToEscalationRule(<map<json>>escalationRuleList[i], escalationRule);
                rules[i] = escalationRule;
                i = i + 1;
            }
            escalationPolicy.escalationRules = rules;
        }
    }
    Service[]? services = convertToServices(response, SERVICES);
    if (services is Service[]) {
        escalationPolicy.services = services;
    }
    CommonRecord[]? records = convertToCommons(response, TEAMS);
    if (records is CommonRecord[]) {
        escalationPolicy.teams = records;
    }
    return escalationPolicy;
}

function convertToEscalationRule(map<json> input, EscalationRule escalationRule) {
    addInt(input[ESCALATION_DELAY_IN_MINUTES_VAR], escalationRule, ESCALATION_DELAY_IN_MINUTES);
    addString(input[ID], escalationRule, ID);
    CommonRecord[]? records = convertToCommons(input, TARGETS);
    if (records is CommonRecord[]) {
        escalationRule.targets = records;
    }
}
