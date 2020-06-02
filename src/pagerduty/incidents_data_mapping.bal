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

function incidentToPayload(Incident|json input) returns @tainted map<json> {
    map<json>|Incident incident = {};
    if (input is json && input != ()) {
        incident = <map<json>>input;
    } else if (input is Incident) {
        incident = input;
    }
    map<json> payload = {};
    var value = incident[TYPE];
    if (value == INCIDENT) {
        payload[TYPE] = INCIDENT;
    } else if (value == INCIDENT_REFERENCE) {
        payload[TYPE] = INCIDENT_REFERENCE_VAR;
    }
    addStringToPayload(incident[TITLE], payload, TITLE);
    addStringToPayload(incident[ID], payload, ID);
    addStringToPayload(incident[SUMMARY], payload, SUMMARY);
    addStringToPayload(incident[URL], payload, SELF);
    addStringToPayload(incident[INCIDENT_KEY], payload, INCIDENT_KEY_VAR);
    addStringToPayload(incident[STATUS], payload, STATUS);
    addStringToPayload(incident[ASSIGNED_VIA], payload, ASSIGNED_VIA_VAR);
    addIntToPayload(incident[INCIDENT_NUMBER], payload, INCIDENT_NUMBER_VAR);
    addStringToPayload(incident[HTML_URL], payload, HTML_URL_VAR);
    addStringToPayload(incident[RESOLUTION], payload, RESOLUTION);
    addStringToPayload(incident[DESCRIPTION], payload, DESCRIPTION);
    var policy = incident[ESCALATION_POLICY];
    if (policy is EscalationPolicy) {
        payload[ESCALATION_POLICY_VAR] = escalationPolicyToPayload(policy);
    }
    map<json> conferenceBridge = {};
    addStringToPayload(incident[CONFERENCE_URL], conferenceBridge, CONFERENCE_URL_VAR);
    addStringToPayload(incident[CONFERENCE_NUMBER], conferenceBridge, CONFERENCE_NUMBER_VAR);
    if (conferenceBridge.length() > 0) {
        payload[CONFERENCE_BRIDGE_VAR] = conferenceBridge;
    }
    addStringTime(incident[CREATED_AT], payload, CREATED_AT_VAR);
    addStringTime(incident[LAST_CHANGES], payload, LAST_CHANGES_VAR);
    map<json> alertCount = {};
    addIntToPayload(incident[TRIGERED_COUNT], alertCount, TRIGERED);
    addIntToPayload(incident[RESOLVED_COUNT], alertCount, RESOLVED);
    addIntToPayload(incident[ALL_COUNT], alertCount, ALL);
    var triggerCount = incident[TRIGERED_COUNT];
    if (alertCount.length() > 0) {
        payload[ALERT_COUNTS] = alertCount;
    }
    var serv = incident[SERVICE];
    payload[SERVICE] = serviceToPayload(serv);
    map<json>? priority = commonToPayload(incident[PRIORITY]);
    if (priority is map<json>) {
        payload[PRIORITY] = commonToPayload(incident[PRIORITY]);
    }
    var assignments = incident[ASSIGNMENTS];
    if (assignments is Assignment[] && assignments != []) {
        assignmentsToPayload(assignments, payload, ASSIGNMENTS);
    } else {
        json[]|error assignmentValue = json[].constructFrom(assignments);
        if (assignmentValue is json[]) {
            assignmentsToPayload(assignmentValue, payload, ASSIGNMENTS);
        }
    }
    payload[LAST_STATUS_CHANGE_BY_VAR] = commonToPayload(incident[LAST_STATUS_CHANGE_BY]);
    payload[FIRST_TRIGGER_LOG_ENTRY_VAR] = commonToPayload(incident[FIRST_TRIGGER_LOG_ENTRY]);
    commonsOrJsonToPayload(incident[TEAMS], payload, TEAMS);
    commonsOrJsonToPayload(incident[IMPACTED_SERVICES], payload, IMPACTED_SERVICES_VAR);
    var acknowledgements = incident[ACKNOWLEDGEMENTS];
    if (acknowledgements is Acknowledgement[] && acknowledgements != []) {
        acknowledgementsToPayload(acknowledgements, payload, ACKNOWLEDGEMENTS);
    } else {
        json[]|error acknowledgementValue = json[].constructFrom(acknowledgements);
        if (acknowledgementValue is json[]) {
            acknowledgementsToPayload(acknowledgementValue, payload, ACKNOWLEDGEMENTS);
        }
    }
    var body = incident[BODY];
    if (body is Body) {
        map<json> result = {};
        if (body[TYPE] == INCIDENT_BODY) {
            result[TYPE] =  INCIDENT_BODY_VAR;
        }
        result[DETAILS] = body[DETAILS];
        payload[BODY] = result;
    }
    addUrgencyToPayload(incident[URGENCY], payload, URGENCY);
    return payload;
}

function assignmentsToPayload(Assignment[]|json[] assignments,  @tainted map<json> payload, string fieldName) {
     int i = 0;
     json[] list = [];
     while (i < assignments.length()) {
         map<json> assign = {};
         map<json>|error assignment = map<json>.constructFrom(assignments[i]);
         if (assignment is map<json>) {
             var assignee = assignment[ASSIGNEE];
             assign[ASSIGNEE] = userToPayload(assignee);
             addStringTime(assignment[AT], assign, AT);
             list[i] = assign;
             i = i + 1;
         }
     }
     if (list != []) {
        payload[fieldName] = list;
     }
}

function acknowledgementsToPayload(Acknowledgement[]|json[] acknowledgements, map<json> payload, string fieldName) {
     int i = 0;
     json[] list = [];
     map<json> output = {};
     while (i < acknowledgements.length()) {
         map<json>|error assignment = map<json>.constructFrom(acknowledgements[i]);
         if (assignment is map<json>) {
             var value = assignment[ACKNOWLEDGER];
             output[ACKNOWLEDGER] = commonToPayload(value);
             addStringTime(assignment[AT], output, AT);
             list[i] = output;
             i = i + 1;
         }
     }
     if (list != []) {
        payload[fieldName] = list;
     }
}

function pendiingActionsToPayload(PendingAction[] pendiingActions, map<json> payload, string fieldName) {
     int i = 0;
     json[] list = [];
     map<json> output = {};
     while (i < pendiingActions.length()) {
         PendingAction pendingAction = pendiingActions[i];
         addStringTime(pendingAction[AT], output, AT);
         string value = pendingAction[TYPE].toString();
         if (value == URGENCY_CHANGE) {
             output[TYPE] = URGENCY_CHANGE_VAR;
         } else {
              output[TYPE] = <Type>value;
         }
         list[i] = output;
         i = i + 1;
     }
     payload[fieldName] = list;
}

function convertToIncidents(map<json> input, string key) returns @tainted Incident[] {
    int i = 0;
    Incident[] incidents = [];
    json[] targetList = <json[]>input[key];
    while (i < targetList.length()) {
        incidents[i] = convertToIncident(<map<json>>targetList[i]);
        i = i + 1;
    }
    return incidents;
}

function convertToIncident(map<json> input) returns @tainted Incident {
    Incident incident = { 'type: "extension", title: "", 'service: { name: "service",
                   escalationPolicy: {'type: "sms", id: "", name: "", escalationRules: []}}};
    string value = "";
    value = input[TYPE].toString();
    if (value == INCIDENT) {
        incident[TYPE] = INCIDENT;
    } else if (value == INCIDENT_REFERENCE_VAR) {
        incident[TYPE] = INCIDENT_REFERENCE;
    }
    addString(input[TITLE], incident, TITLE);
    addString(input[ID], incident, ID);
    addString(input[SELF], incident, URL);
    addString(input[SUMMARY], incident, SUMMARY);
    addString(input[HTML_URL_VAR], incident, HTML_URL);
    addInt(input[INCIDENT_NUMBER_VAR], incident, INCIDENT_NUMBER);
    addString(input[INCIDENT_KEY_VAR], incident, INCIDENT_KEY);
    addString(input[STATUS], incident, STATUS);
    addString(input[ASSIGNED_VIA_VAR], incident, ASSIGNED_VIA);
    addString(input[RESOLUTION], incident, RESOLUTION);
    addString(input[DESCRIPTION], incident, DESCRIPTION);
    var policy = input[ESCALATION_POLICY_VAR];
    if (policy.toString() != "") {
        incident[ESCALATION_POLICY] = convertToEscalationPolicy(<map<json>>policy);
    }
    var bridge = input[CONFERENCE_BRIDGE_VAR];
    if (bridge.toString() != "") {
        map<json> conferenceBridge = <map<json>>bridge;
        addString(conferenceBridge[CONFERENCE_URL_VAR], incident, CONFERENCE_URL);
        addString(conferenceBridge[CONFERENCE_NUMBER_VAR], incident, CONFERENCE_NUMBER);
    }
    map<json> alertCount = <map<json>>input[ALERT_COUNTS];
    addInt(alertCount[TRIGERED], incident, TRIGERED_COUNT);
    addInt(alertCount[RESOLVED], incident, RESOLVED_COUNT);
    addInt(alertCount[ALL], incident, ALL_COUNT);
    setTimeFromString(input[CREATED_AT_VAR], incident, CREATED_AT);
    setTimeFromString(input[LAST_CHANGES_VAR], incident, LAST_CHANGES);
    json serv = input[SERVICE];
    if (serv.toString() != "") {
        incident[SERVICE] = convertToService(<map<json>>serv);
    }
    if (input[PRIORITY].toString() != "") {
        incident[PRIORITY] = convertToCommon(input[PRIORITY]);
    }
    if (input[ASSIGNMENTS].toString() != "") {
        incident[ASSIGNMENTS] = convertToAssignments(input);
    }
    if (input[LAST_STATUS_CHANGE_BY_VAR].toString() != "") {
        incident[LAST_STATUS_CHANGE_BY]  = convertToCommon(input[LAST_STATUS_CHANGE_BY_VAR]);
    }
    if (input[FIRST_TRIGGER_LOG_ENTRY_VAR].toString() != "") {
        incident[FIRST_TRIGGER_LOG_ENTRY] = convertToCommon(input[FIRST_TRIGGER_LOG_ENTRY_VAR]);
    }
    CommonRecord[]? records = convertToCommons(input, TEAMS);
    if (records is CommonRecord[]) {
        incident[TEAMS] = records;
    }
    CommonRecord[]? services = convertToCommons(input, IMPACTED_SERVICES_VAR);
    if (services is CommonRecord[]) {
        incident[IMPACTED_SERVICES] = services;
    }
    if (input[ACKNOWLEDGEMENTS].toString() != "") {
        incident[ACKNOWLEDGEMENTS] = convertToAcknowledgements(input);
    }
    json body = input[BODY];
    if (body != ()) {
        Body result = {'type: INCIDENT_BODY};
        map<json> res = <map<json>>body;
        result[DETAILS] = res[DETAILS].toString();
        incident[BODY] = result;
    }
    addUrgency(input[URGENCY], incident);
    return incident;
}

function convertToAssignments(map<json> input) returns @tainted Assignment[] {
    int i = 0;
    Assignment[] assignments = [];
    json[] targetList = <json[]>input[ASSIGNMENTS];
    while (i < targetList.length()) {
        map<json> value = <map<json>>targetList[i];
        User? user = convertToUser(value[ASSIGNEE]);
        if (user is User) {
            assignments[i][ASSIGNEE] = user;
        }
        setTimeFromString(value[AT], assignments[i], AT);
        i = i + 1;
    }
    return assignments;
}

function convertToAcknowledgements(map<json> input) returns Acknowledgement[] {
    int i = 0;
    Acknowledgement[] acknowledgements = [];
    json[] targetList = <json[]>input[ACKNOWLEDGEMENTS];
    while (i < targetList.length()) {
        map<json> value = <map<json>>targetList[i];
        acknowledgements[i][ACKNOWLEDGER] = convertToCommon(value[ACKNOWLEDGER]);
        setTimeFromString(value[AT], acknowledgements[i], AT);
        i = i + 1;
    }
    return acknowledgements;
}

function convertToPendiingActions(map<json> payload, string key) returns PendingAction[] {
    int i = 0;
    PendingAction[] pendiingActions = [];
    json[] targetList = <json[]>payload[key];
    int length = targetList.length();
    while (i < length) {
        map<json> result = <map<json>>targetList[i];
        string value = result[TYPE].toString();
        if (value == URGENCY_CHANGE) {
            pendiingActions[i][TYPE] = URGENCY_CHANGE_VAR;
        } else {
            pendiingActions[i][TYPE] = <Type>value;
        }
        setTimeFromString(result[AT], pendiingActions[i], AT);
        i = i + 1;
    }
    return pendiingActions;
}

function noteToPayload(Note note) returns map<json> {
    int i = 0;
    json[] list = [];
    map<json> payload = {};
    addStringToPayload(note[ID], payload, ID);
    addStringToPayload(note[CONTENT], payload, CONTENT);
    addStringToPayload(note[CONTENT], payload, CONTENT);
    addStringTime(note[CREATED_AT], payload, CREATED_AT_VAR);
    var user = note[USER];
    if (user is CommonRecord) {
        payload[USER] = commonToPayload(user);
    }
    return payload;
}

function convertToNote(map<json> input) returns Note {
    Note note = {};
    int i = 0;
    json[] list = [];
    addString(input[ID], note, ID);
    addString(input[CONTENT], note, CONTENT);
    setTimeFromString(input[CREATED_AT_VAR], note, CREATED_AT);
    var value = input[USER];
    if (value.toString() != "") {
        note[USER] = convertToCommon(value);
    }
    return note;
}

function incidentsToPayload(Incident[]|json[] incidents) returns @tainted json[] {
    int i = 0;
    json[] list = [];
    while (i < incidents.length()) {
        list[i] = incidentToPayload(incidents[i]);
        i = i + 1;
    }
    return list;
}
