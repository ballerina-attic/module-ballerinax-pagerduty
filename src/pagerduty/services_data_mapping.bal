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

import ballerina/time;

function serviceToPayload(Service|json input) returns @tainted map<json> {
    map<json>|Service serv = {};
    if (input is Service) {
        serv = input;
    } else if (input != ()) {
        serv = <map<json>>input;
    }
    map<json> payload = {};
    var value = serv[TYPE];
    if (value == SERVICE_REFERENCE) {
        payload[TYPE] = SERVICE_REFERENCE_VAR;
    } else if (value == SERVICE) {
        payload[TYPE] = SERVICE;
    }
    addStringToPayload(serv[ID], payload, ID);
    addStringToPayload(serv[NAME], payload, NAME);
    addStringToPayload(serv[STATUS], payload, STATUS);
    addStringToPayload(serv[DESCRIPTION], payload, DESCRIPTION);
    addIntToPayload(serv[AUTO_RESOLVE_TIMEOUT], payload, AUTO_RESOLVE_TIME_OUT_VAR);
    addIntToPayload(serv[ACKNOWLEDGEMENT_TIMEOUT], payload, ACKNOWLEDGEMENT_TIMEOUT_VAR);
    addStringTime(serv[CREATED_AT], payload, CREATED_AT_VAR);
    addStringTime(serv[UPDATED_AT], payload, UPDATED_AT_VAR);
    addStringTime(serv[TIME_STAMP], payload, TIME_STAMP_VAR);
    addStringToPayload(serv[SUMMARY], payload, SUMMARY);
    addStringToPayload(serv[HTML_URL], payload, HTML_URL_VAR);
    addStringToPayload(serv[URL], payload, SELF);
    var policy = serv[ESCALATION_POLICY];
    payload[ESCALATION_POLICY_VAR] = escalationPolicyToPayload(serv[ESCALATION_POLICY]);
    var teams = serv[TEAMS];
    if (teams is CommonRecord[]) {
        commonsOrJsonToPayload(serv[TEAMS], payload, TEAMS);
    }
    var integrations = serv[INTEGRATIONS];
    if (integrations is Integration[]) {
       integrationsToPayload(integrations, payload, INTEGRATIONS);
    }
    var urgencyRules = serv[INCIDENT_URGENCY_RULE];
    map<json>? rule = {};
    if (urgencyRules is IncidentUrgencyRule) {
       rule = incidentUrgencyRuleToPayload(urgencyRules);
    } else if (urgencyRules != ()) {
        rule = incidentUrgencyRuleToPayload(<map<json>>urgencyRules);
    }
    if (rule is map<json> && rule != {}) {
        payload[INCIDENT_URGENCY_RULE_VAR] = rule;
    }
    var supportHours = serv[SUPPORT_HOURS];
    map<json>? hours = {};
    if (supportHours is SupportHour) {
       hours = supportHoursToPayload(supportHours);
    } else if (supportHours != ()) {
        hours = supportHoursToPayload(<map<json>>supportHours);
    }
    if (hours is map<json> && hours != {}) {
        payload[SUPPORT_HOURS_VAR] = hours;
    }
    int i = 0;
    json[] list = [];
    ScheduledAction[]?|json? scheduledActions = serv[SCHEDULED_ACTIONS];
    if (scheduledActions is ScheduledAction[]) {
       while (i < scheduledActions.length()) {
           list[i] = scheduledActionToPayload(scheduledActions[i]);
           i = i + 1;
       }
    } else if (scheduledActions != ()) {
        json[] actions = <json[]>scheduledActions;
        while (i < actions.length()) {
            list[i] = escalationRuleToPayload(actions[i]);
            i = i + 1;
        }
    }
    if (list != []) {
         payload[SCHEDULED_ACTIONS_VAR] = list;
    }
    commonsOrJsonToPayload(serv[ADDONS], payload, ADDONS);
    string alertCreation = serv[ALERT_CREATION].toString();
    if (alertCreation != "") {
        if (value == CREATE_INCIDENTS) {
            payload[ALERT_CREATION_VAR] = CREATE_INCIDENTS_VAR;
        } else {
            payload[ALERT_CREATION_VAR] = CREATE_ALERT_INCIDENTS_VAR;
        }
    }
    var group = serv[ALERT_GROUPING];
    if (group is Group) {
        payload[ALERT_GROUPING_VAR] = group.toString();
    }
    addIntToPayload(serv[ALERT_GROUPING_TIME_VAR], payload, ALERT_GROUPING_TIME);
    return payload;
}

function integrationsToPayload(Integration[] integrations, @tainted map<json> payload, string fieldName) {
    int i = 0;
    json[] list = [];
    while (i < integrations.length()) {
        list[i] = integrationToPayload(integrations[i]);
        i = i + 1;
    }
    payload[fieldName] = list;
}

function integrationToPayload(Integration integration) returns @tainted map<json> {
    map<json> payload = {};
    string value = integration[TYPE].toString();
    if (value == AWS_CLOUD) {
        payload[TYPE] = AWS_CLOUD_VAR;
    } else if (value == AWS_CLOUD_REFERENCE) {
        payload[TYPE] = AWS_CLOUD_REFERENCE_VAR;
    } else if (value == CLOUD_KICK_REFERENCE) {
        payload[TYPE] = CLOUD_KICK_REFERENCE_VAR;
    } else if (value == EVENT_TRANSFORMER_API_REFERENCE) {
        payload[TYPE] = EVENT_TRANSFORMER_API_REFERENCE_VAR;
    } else if (value == EMAIL_REFERENCE) {
        payload[TYPE] = EMAIL_REFERENCE_VAR;
    } else if (value == EVENTS_API_REFERENCE) {
        payload[TYPE] = EVENTS_API_REFERENCE_VAR;
    } else if (value == KEY_NOTE_REFERENCE) {
        payload[TYPE] = KEY_NOTE_REFERENCE_VAR;
    } else if (value == NAGIOS_REFERENCE) {
        payload[TYPE] = NAGIOS_REFERENCE_VAR;
    } else if (value == PINGDOM_REFERENCE) {
        payload[TYPE] = PINGDOM_REFERENCE_VAR;
    } else if (value == SQL_MONITOR_REFERENCE) {
        payload[TYPE] = SQL_MONITOR_REFERENCE_VAR;
    } else if (value == SQL_MONITOR) {
        payload[TYPE] = SQL_MONITOR_VAR;
    } else if (value == PINGDOM_INTEGRATION) {
        payload[TYPE] = PINGDOM_INTEGRATION_VAR;
    } else if (value== NAGIOS_INTEGRATION) {
        payload[TYPE] = NAGIOS_INTEGRATION_VAR;
    } else if (value == KEY_NOTE) {
        payload[TYPE] = KEY_NOTE_VAR;
    } else if (value == EVENTS_API) {
        payload[TYPE] = EVENTS_API_VAR;
    } else if (value == EMAIL_INBOUND) {
        payload[TYPE] = EMAIL_INBOUND_VAR;
    } else if (value == EVENT_TRANSFORMER_API) {
        payload[TYPE] = EVENT_TRANSFORMER_API_VAR;
    } else if (value == EVENT_API_V2) {
        payload[TYPE] = EVENT_API_V2_VAR;
    }
    addStringToPayload(integration[ID], payload, ID);
    addStringToPayload(integration[SUMMARY], payload, SUMMARY);
    addStringToPayload(integration[URL], payload, SELF);
    addStringToPayload(integration[HTML_URL], payload, HTML_URL_VAR);
    addStringToPayload(integration[EMAIL], payload, INTEGRATION_EMAIL);
    addStringToPayload(integration[KEY], payload, INTEGRATION_KEY);
    addStringToPayload(integration[NAME], payload, NAME);
    var serv = integration[SERVICE];
    if (serv is Service) {
       payload[SERVICE] = serviceToPayload(serv);
    }
    addStringTime(integration[CREATED_AT], payload, CREATED_AT_VAR);
    var vendor = integration[VENDOR];
    if (vendor is CommonRecord) {
     payload[VENDOR] = commonToPayload(vendor);
    }
    return payload;
}

function incidentUrgencyRuleToPayload(IncidentUrgencyRule|map<json> rule) returns map<json>? {
    map<json> payload = {};
    string value = rule[TYPE].toString();
    if (value == CONSTANT) {
        payload[TYPE] = CONSTANT;
    } else if (value == USE_SUPPORT_HOURS) {
        payload[TYPE] = USE_SUPPORT_HOURS_VAR;
    }
    addUrgencyToPayload(rule[URGENCY], payload, URGENCY);
    var hours = rule[DURING_SUPPORT_HOURS];
    if (hours != ()) {
        var result = IncidentSupportHoursToPayload(<map<json>>hours);
        if (result is map<json>) {
            payload[DURING_SUPPORT_HOURS_VAR] = result;
        }
    }
    var result = rule[OUTSIDE_SUPPORT_HOURS];
    if (result != ()) {
        var supportHours = IncidentSupportHoursToPayload(<map<json>>result);
        if (supportHours is map<json>) {
            payload[OUTSIDE_SUPPORT_HOURS_VAR] = supportHours;
        }
    }
    if (payload != {}) {
        return payload;
    }
}

function IncidentSupportHoursToPayload(map<json> supportHours) returns map<json>? {
    map<json> payload = {};
    string value = supportHours[TYPE].toString();
    if (value == CONSTANT) {
        payload[TYPE] = CONSTANT;
    } else if (value == USE_SUPPORT_HOURS) {
        payload[TYPE] = USE_SUPPORT_HOURS_VAR;
    }
    addUrgencyToPayload(supportHours[URGENCY], payload, URGENCY);
    if (payload != {}) {
        return payload;
    }
}

function supportHoursToPayload(SupportHour|map<json> hours) returns map<json>? {
    map<json> payload = {};
    string value = hours[TYPE].toString();
    if (value == FIXED_TIME_PER_DAY) {
        payload[TYPE] = FIXED_TIME_PER_DAY_VAR;
    }
    addStringToPayload(hours[TIME_ZONE], payload, TIME_ZONE_VAR);
    if (hours is SupportHour) {
        time:Time? time = hours[START_TIME];
        if (time is time:Time) {
            payload[START_TIME_VAR] = addTime(time);
        }
        time = hours[END_TIME];
        if (time is time:Time) {
            payload[END_TIME_VAR] = addTime(time);
        }
    } else {
        payload[END_TIME_VAR] = hours[END_TIME].toString();
        payload[START_TIME_VAR] = hours[START_TIME].toString();
    }
    var days = hours[DAYS_OF_WEEK];
    if (days.toString() != "") {
        payload[DAYS_OF_WEEK_VAR] = hours[DAYS_OF_WEEK];
    }
    if (payload != {}) {
        return payload;
    }
}

function scheduledActionToPayload(ScheduledAction scheduledAction) returns map<json> {
    map<json> payload = {};
    string value = scheduledAction[TYPE].toString();
    if (value == URGENCY_CHANGE) {
        payload[TYPE] = URGENCY_CHANGE_VAR;
    }
    payload[AT] = atToPayload(scheduledAction[AT]);
    addUrgencyToPayload(scheduledAction[URGENCY], payload, TO_URGENCY);
    return payload;
}

function atToPayload(At input) returns map<json> {
    string value = input[TYPE].toString();
    map<json> at = {};
    if (value == NAMED_TIME) {
        at[TYPE] = NAMED_TIME_VAR;
    }
    addNameToPayload(input[NAME], at);
    return at;
}

function convertToService(map<json> input) returns Service {
    Service serv = {name: "", escalationPolicy:{'type: "escalationPolicy", name: "", escalationRules: []}};
    var value = input[TYPE] ;
    if (value == SERVICE_REFERENCE_VAR) {
        serv[TYPE] = SERVICE_REFERENCE;
    } else if (value == SERVICE) {
        serv[TYPE] = SERVICE;
    }
    addString(input[ID], serv, ID);
    addString(input[NAME], serv, NAME);
    addString(input[DESCRIPTION], serv, DESCRIPTION);
    addString(input[STATUS], serv, STATUS);
    addInt(input[AUTO_RESOLVE_TIME_OUT_VAR], serv, AUTO_RESOLVE_TIMEOUT);
    addInt(input[ACKNOWLEDGEMENT_TIMEOUT_VAR], serv, ACKNOWLEDGEMENT_TIMEOUT);
    setTimeFromString(input[CREATED_AT_VAR], serv, CREATED_AT);
    setTimeFromString(input[UPDATED_AT_VAR], serv, UPDATED_AT);
    addString(input[SUMMARY], serv, SUMMARY);
    addString(input[SELF], serv, URL);
    addString(input[HTML_URL_VAR], serv, HTML_URL);
    setTimeFromString(input[TIME_STAMP_VAR], serv, TIME_STAMP);
    if (input[ESCALATION_POLICY_VAR].toString() != "") {
        serv[ESCALATION_POLICY] = convertToEscalationPolicy(<map<json>>input[ESCALATION_POLICY_VAR]);
    }
    CommonRecord[]? teams = convertToCommons(input, TEAMS);
    if (teams is CommonRecord[]) {
         serv[TEAMS] = teams;
    }
    Integration[]? integrations = convertToIntegrations(input);
    if (integrations is Integration[]) {
        serv[INTEGRATIONS] = integrations;
    }
    var urgencyRule = input[INCIDENT_URGENCY_RULE_VAR];
    if (urgencyRule.toString() != "") {
      serv[INCIDENT_URGENCY_RULE] = convertToIncidentUrgencyRule(<map<json>>urgencyRule);
    }
    var supportHour = input[SUPPORT_HOURS_VAR];
    if (supportHour.toString() != "") {
        serv[SUPPORT_HOURS] = convertToSupportHour(<map<json>>supportHour);
    }
    ScheduledAction[] result= convertToScheduledActions(input);
    if (result.length() > 0) {
        serv[SCHEDULED_ACTIONS] = result;
    }
    CommonRecord[]? records = convertToCommons(input, ADDONS);
    if (records is CommonRecord[]) {
        serv[ADDONS] = records;
    }
    string alertCreation = input[ALERT_CREATION_VAR].toString();
    if (alertCreation != "") {
        if (alertCreation == CREATE_INCIDENTS_VAR) {
            serv[ALERT_CREATION] = CREATE_INCIDENTS;
        } else {
            serv[ALERT_CREATION] = CREATE_ALERT_INCIDENTS;
        }
    }
    string group = input[ALERT_GROUPING_VAR].toString();
    if (group != "") {
        serv[ALERT_GROUPING] = <Group>group;
    }
    addInt(input[ALERT_GROUPING_TIME_VAR], serv, ALERT_GROUPING_TIME);
    return <@untainted> serv;
}

function convertToIntegrations(map<json> input) returns Integration[]? {
    int i = 0;
    Integration[] integrations = [];
    var value = input[INTEGRATION];
    if (value != ()) {
        json[] targetList = <json[]>value;
        while (i < targetList.length()) {
            integrations[i] = convertToIntegration(<map<json>>targetList[i]);
            i = i + 1;
        }
        return <@untainted> integrations;
    }
}

function convertToIntegration(map<json> input) returns Integration {
    Integration integration = {'type: "awsCloudwatchInboundIntegration"};
    var value = input[TYPE];
    if (value == AWS_CLOUD_VAR) {
        integration[TYPE] = AWS_CLOUD;
    } else if (value == AWS_CLOUD_REFERENCE_VAR) {
        integration[TYPE] = AWS_CLOUD_REFERENCE;
    } else if (value == CLOUD_KICK_REFERENCE_VAR) {
        integration[TYPE] = CLOUD_KICK_REFERENCE;
    } else if (value == EVENT_TRANSFORMER_API_REFERENCE_VAR) {
        integration[TYPE] = EVENT_TRANSFORMER_API_REFERENCE;
    } else if (value == EMAIL_REFERENCE_VAR) {
        integration[TYPE] = EMAIL_REFERENCE;
    } else if (value == EVENTS_API_REFERENCE_VAR) {
        integration[TYPE] = EVENTS_API_REFERENCE;
    } else if (value == KEY_NOTE_REFERENCE_VAR) {
        integration[TYPE] = KEY_NOTE_REFERENCE;
    } else if (value == NAGIOS_REFERENCE_VAR) {
        integration[TYPE] = NAGIOS_REFERENCE;
    } else if (value == PINGDOM_REFERENCE_VAR) {
        integration[TYPE] = PINGDOM_REFERENCE;
    } else if (value == SQL_MONITOR_REFERENCE_VAR) {
        integration[TYPE] = SQL_MONITOR_REFERENCE;
    } else if (value == SQL_MONITOR_VAR) {
        integration[TYPE] = SQL_MONITOR;
    } else if (value == PINGDOM_INTEGRATION_VAR) {
        integration[TYPE] = PINGDOM_INTEGRATION;
    } else if (value == NAGIOS_INTEGRATION_VAR) {
        integration[TYPE] = NAGIOS_INTEGRATION;
    } else if (value == KEY_NOTE_VAR) {
        integration[TYPE] = KEY_NOTE;
    } else if (value == EVENTS_API_VAR) {
        integration[TYPE] = EVENTS_API;
    } else if (value == EMAIL_INBOUND_VAR) {
     integration[TYPE] = EMAIL_INBOUND;
    } else if (value == EVENT_TRANSFORMER_API_VAR) {
        integration[TYPE] = EVENT_TRANSFORMER_API;
    } else if (value == EVENT_API_V2_VAR) {
        integration[TYPE] = EVENT_API_V2;
    }
    addString(input[ID], integration, ID);
    addString(input[NAME], integration, NAME);
    addString(input[INTEGRATION_EMAIL], integration, EMAIL);
    addString(input[INTEGRATION_KEY], integration, KEY);
    addString(input[SUMMARY], integration, SUMMARY);
    addString(input[SELF], integration, URL);
    addString(input[HTML_URL_VAR], integration, HTML_URL);
    var serv = input[SERVICE];
    if (input[SERVICE].toString() != "") {
        integration[SERVICE] =  convertToService(<map<json>>serv);
    }
    setTimeFromString(input[CREATED_AT_VAR], integration, CREATED_AT);
    var vendor = input[VENDOR];
    if (vendor.toString() != "") {
        integration[VENDOR] = convertToCommon(vendor);
    }
    return <@untainted> integration;
}

function convertToIncidentUrgencyRule(map<json> input) returns IncidentUrgencyRule {
    IncidentUrgencyRule rule = {};
    string value = input[TYPE].toString();
    if (value == CONSTANT) {
        rule[TYPE] = CONSTANT;
    } else if (value == USE_SUPPORT_HOURS_VAR) {
        rule[TYPE] = USE_SUPPORT_HOURS;
    }
    addUrgency(input[URGENCY], rule);
    var supportHours = input[DURING_SUPPORT_HOURS_VAR];
    if (input[DURING_SUPPORT_HOURS_VAR].toString() != "") {
        rule[DURING_SUPPORT_HOURS] = convertToIncidentSupportHour(<map<json>>supportHours);
    }
    if (input[OUTSIDE_SUPPORT_HOURS_VAR].toString() != "") {
        rule[OUTSIDE_SUPPORT_HOURS] = convertToIncidentSupportHour(<map<json>>input[OUTSIDE_SUPPORT_HOURS_VAR]);
    }
    return rule;
}

function convertToIncidentSupportHour(map<json> input) returns IncidentSupportHour {
    IncidentSupportHour incidentSupportHour = {};
    string value = input[TYPE].toString();
    if (value == CONSTANT) {
        incidentSupportHour[TYPE] = CONSTANT;
    } else if (value == USE_SUPPORT_HOURS_VAR) {
        incidentSupportHour[TYPE] = USE_SUPPORT_HOURS;
    }
    addUrgency(input[URGENCY], incidentSupportHour);
    return incidentSupportHour;
}

function convertToSupportHour(map<json> input) returns SupportHour {
    SupportHour hours = {};
    string value = input[TYPE].toString();
    if (value == FIXED_TIME_PER_DAY_VAR) {
        hours[TYPE] = FIXED_TIME_PER_DAY;
    }
    addString(input[TIME_ZONE_VAR], hours, TIME_ZONE);
    var daysOfWeek = input[DAYS_OF_WEEK_VAR];
    addDaysOfWeek(daysOfWeek, hours);
    setTime(input[START_TIME_VAR], hours, START_TIME);
    setTime(input[END_TIME_VAR], hours, END_TIME);
    return hours;
}

function addDaysOfWeek(json input, SupportHour hours)  {
    int[] output = [];
    var days = input.cloneWithType(JsonArray);
    if (days is json[]) {
        int i = 0;
        int length = days.length();
        while (i < length) {
            output[i] = <int>days[i];
            i = i + 1;
        }
        hours[DAYS_OF_WEEK] = output;
    }
}

function convertToScheduledActions(map<json> input) returns ScheduledAction[] {
    int i = 0;
    ScheduledAction[] scheduledActions = [];
    json actions = input[SCHEDULED_ACTIONS_VAR];
    if (actions != ()) {
        json[] targetList = <json[]>actions;
        while (i < targetList.length()) {
            scheduledActions[i] = convertToScheduledAction(<map<json>>targetList[i]);
            i = i + 1;
        }
    }
    return scheduledActions;
}

function convertToScheduledAction(map<json> input) returns ScheduledAction {
    ScheduledAction scheduledAction = {'type: URGENCY_CHANGE, at: {'type : NAMED_TIME,
                                       name: FINAL_SCHEDULE}, urgency: HIGH};
    string value = input[TYPE].toString();
    if (value == URGENCY_CHANGE_VAR) {
        scheduledAction[TYPE] = URGENCY_CHANGE;
    }
    json at = input[AT];
    if (at.toString() != "") {
        scheduledAction[AT] = convertToAt(<map<json>>at);
    }
    addUrgency(input[TO_URGENCY], scheduledAction);
    return scheduledAction;
}

function convertToAt(map<json> input) returns At {
    At at = {'type : NAMED_TIME, name: FINAL_SCHEDULE};
    string value = input[TYPE].toString();
    if (value ==  NAMED_TIME_VAR) {
        at[TYPE] = NAMED_TIME;
    }
    addName(input[NAME], at);
    return at;
}

function convertToServices(map<json> payload, string key) returns Service[]? {
    Service[] services = [];
    var value = payload[key];
    if (value != ()) {
        json[] serviceList = <json[]>value;
        int i = 0;
        while (i < serviceList.length()) {
            services[i] = convertToService(<map<json>>serviceList[i]);
            i = i + 1;
        }
        if (services.length() > 0) {
            return services;
        }
    }
}

function servicesToPayload(Service[] servs, @tainted map<json> payload, string fieldName) {
    int i = 0;
    json[] list = [];
    while (i < servs.length()) {
        list[i] = serviceToPayload(servs[i]);
        i = i + 1;
    }
    payload[fieldName] = list;
}
