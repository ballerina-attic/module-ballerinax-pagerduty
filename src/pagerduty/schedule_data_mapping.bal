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

function convertToSchedules(map<json> input) returns @tainted Schedule[] {
    int i = 0;
    Schedule[] schedules = [];
    json[] targetList = <json[]>input[SCHEDULES];
    while (i < targetList.length()) {
        schedules[i] = convertToSchedule(<map<json>>targetList[i]);
        i = i + 1;
    }
    return schedules;
}

function convertToSchedule(map<json> response) returns @tainted Schedule {
    Schedule schedule = {'type: "schedule", timeZone: "",scheduleLayers: []};
    schedule.'type = response[TYPE].toString();
    addString(response[TIME_ZONE_VAR], schedule, TIME_ZONE);
    addString(response[SUMMARY], schedule, SUMMARY);
    addString(response[SELF], schedule, URL);
    addString(response[HTML_URL_VAR], schedule, HTML_URL);
    addString(response[DESCRIPTION], schedule, DESCRIPTION);
    addString(response[NAME], schedule, NAME);
    addString(response[ID], schedule, ID);
    addUsers(response, schedule);
    int i = 0;
    var layers = response[SCHEDULE_LAYERS_VAR];
    if (layers != ()) {
        json[] targetList = <json[]>layers;
        while (i < targetList.length()) {
            ScheduleLayer value = convertToScheduleLayer(<map<json>>targetList[i]);
            schedule.scheduleLayers[i] = value;
            i = i + 1;
        }
    }
    i = 0;
    var policies = response[ESCALATION_POLICIES_VAR];
    if (policies != ()) {
        json[] policyList = <json[]>policies;
        while (i < policyList.length()) {
            schedule.escalationPolicies[i] = convertToEscalationPolicy(<map<json>>policyList[i]);
            i = i + 1;
        }
    }
    var finalSchedule = response[FINAL_SCHEDULE_VAR];
    if (finalSchedule.toString() != "") {
        schedule.finalSchedule = convertToFinalSchedule(<map<json>>finalSchedule);
    }
    var overideSchedule = response[OVERRIDES_SCHEDULE_VAR];
    if (overideSchedule.toString() != "") {
        schedule.overridesSubschedule = convertToFinalSchedule(<map<json>>overideSchedule);
    }
    i = 0;
    var teams = response[TEAMS];
    if (teams != ()) {
        json[] teamList = <json[]>teams;
        while (i < teamList.length()) {
            schedule.teams[i] = convertToCommon(teamList[i]);
            i = i + 1;
        }
     }
    return schedule;
}

function convertToScheduleLayer(map<json> input) returns @tainted ScheduleLayer {
    time:Time time = time:currentTime();
    var output  = time:parse("00:00:00", "HH:mm:ss");
    if (output is time:Time) {
        time = output;
    }
    ScheduleLayer scheduleLayer = { 'start: time, users: [] , rotationVirtualStart: time,
                                    rotationTurnLengthInSeconds: 0};
    setTimeFromString(input[START], scheduleLayer, START);
    setTimeFromString(input[ROTATION_VIRTUAL_START_VAR], scheduleLayer, ROTATION_VIRTUAL_START);
    setTimeFromString(input[END], scheduleLayer, END);
    addUsersToScheduleLayer(input, scheduleLayer);
    addString(input[NAME], scheduleLayer, NAME);
    addString(input[ID], scheduleLayer, ID);
    addInt(input[ROTATION_TURN_LENGTH_VAR], scheduleLayer, ROTATION_TURN_LENGTH);
    addInt(input[RENDERED_COVERAGE_PERCENTAGE_VAR], scheduleLayer, RENDERED_COVERAGE_PERCENTAGE);
    int i = 0;
    json[] entryList = <json[]>input[RENDERED_SCHEDULE_ENTRIES_VAR];
    while (i < entryList.length()) {
        scheduleLayer.renderedScheduleEntries[i] = convertToRenderedSchedule(<map<json>>entryList[i]);
        i = i + 1;
    }
    i = 0;
    json[] restrictionList = <json[]>input[RESTRICTIONS];
    while (i < restrictionList.length()) {
        scheduleLayer.restrictions[i] = convertToRestriction(<map<json>>restrictionList[i]);
        i = i + 1;
    }
    return scheduleLayer;
}

function addUsers(map<json> response, @tainted Schedule output) {
    int i = 0;
    json[] userList = <json[]>response[USERS];
    while (i < userList.length()) {
        output.users[i] = convertToUser(userList[i]);
        i = i + 1;
    }
}

function addUsersToScheduleLayer(map<json> response, @tainted ScheduleLayer output) {
    int i = 0;
    json[] userList = <json[]>response[USERS];
    while (i < userList.length()) {
        map<json> users = <map<json>>userList[i];
        var user = users[USER];
        if (user != ()) {
            output.users[i] = convertToUser(user);
        }
        i = i + 1;
    }
}

function convertToFinalSchedule(map<json> input) returns @tainted FinalSchedule {
    FinalSchedule finalSchedule = {"name": FINAL_SCHEDULE};
    string value = input[NAME].toString();
    if (value != "") {
        if (value == FINAL_SCHEDULE_VAR) {
            finalSchedule.name = FINAL_SCHEDULE;
        } else if (value == OVERIDES) {
            finalSchedule.name = OVERIDES;
        }
    }
    int i = 0;
    json[] targetList = <json[]>input[RENDERED_SCHEDULE_ENTRIES_VAR];
    while (i < targetList.length()) {
        finalSchedule.renderedScheduleEntries[i] = convertToRenderedSchedule(<map<json>>targetList[i]);
        i = i + 1;
    }
    addInt(input[RENDERED_COVERAGE_PERCENTAGE], finalSchedule, RENDERED_COVERAGE_PERCENTAGE);
    return finalSchedule;
}

function convertToRenderedSchedule(map<json> input) returns @tainted RenderedScheduleEntry {
    time:Time time = time:currentTime();
    var output  = time:parse("00:00:00", "HH:mm:ss");
    if (output is time:Time) {
        time = output;
    }
    RenderedScheduleEntry scheduleEntry = { 'start: time, end: time};
    setTimeFromString(input[START], scheduleEntry, START);
    setTimeFromString(input[END], scheduleEntry, END);
    var data = input[USER];
    if (data is USER) {
        scheduleEntry.user = convertToUser(data);
    }
    return scheduleEntry;
}

function convertToRestriction(map<json> input) returns Restriction {
    time:Time time = time:currentTime();
    var output  = time:parse("00:00:00", "HH:mm:ss");
    if (output is time:Time) {
        time = output;
    }
    Restriction restriction = {'type: "dailyRestriction", startTimeOfDay: time, durationInSeconds: 0};
    string value = input[TYPE].toString();
    if(value != "") {
        if (value == DAILY_RESTRICTION_VAR) {
            restriction.'type = DAILY_RESTRICTION;
        } else if (value == WEEKLY_RESTRICTION_VAR) {
            restriction.'type  = WEEKLY_RESTRICTION;
        }
    }
    setTime(input[START_TIME_OF_DAY_VAR], restriction, START_TIME_OF_DAY);
    addInt(input[DURATION_IN_SEC_VAR], restriction, DURATION_IN_SEC);
    addInt(input[START_DAY_OF_WEEK_VAR], restriction, START_DAY_OF_WEEK);
    return restriction;
}

function scheduleToPayload(Schedule schedule) returns @tainted map<json> {
    map<json> payload = {};
    int i = 0;
    payload[TYPE] = schedule[TYPE].toString();
    addStringToPayload(schedule[TIME_ZONE], payload, TIME_ZONE_VAR);
    addStringToPayload(schedule[SUMMARY], payload, SUMMARY);
    addStringToPayload(schedule[URL], payload, SELF);
    addStringToPayload(schedule[DESCRIPTION], payload, DESCRIPTION);
    addStringToPayload(schedule[HTML_URL], payload, HTML_URL_VAR);
    addStringToPayload(schedule[NAME], payload, NAME);
    addStringToPayload(schedule[ID], payload, ID);
    var layers = schedule[SCHEDULE_LAYERS];
    i = 0;
    json[] list = [];
    while (i < layers.length()) {
        list[i] = scheduleLayerToPayload(layers[i]);
        i = i + 1;
    }
    payload[SCHEDULE_LAYERS_VAR] = list;
    var policies = schedule[ESCALATION_POLICIES];
    if (policies is EscalationPolicy[]) {
        i = 0;
        json[] policyList = [];
        while (i < policies.length()) {
            policyList[i] = escalationPolicyToPayload(policies[i]);
            i = i + 1;
        }
        payload[ESCALATION_POLICIES_VAR] = policyList;
    }
    var finalSchedule = schedule[FINAL_SCHEDULE];
    if (finalSchedule is FinalSchedule) {
        payload[FINAL_SCHEDULE_VAR] = finalScheduleToPayload(finalSchedule);
    }
    var overideSchedule = schedule[OVERRIDES_SCHEDULE];
    if (overideSchedule is FinalSchedule) {
        payload[OVERRIDES_SCHEDULE_VAR] = finalScheduleToPayload(overideSchedule);
    }
    addUsersToPayload(schedule[USERS], payload, USERS);
    commonsToPayload(schedule[TEAMS], payload, TEAMS);
    return payload;
}

function scheduleLayerToPayload(ScheduleLayer layer) returns @tainted map<json> {
    map<json> payload = {};
    int i = 0;
    addStringTime(layer[START], payload, START);
    addStringTime(layer[ROTATION_VIRTUAL_START], payload, ROTATION_VIRTUAL_START_VAR);
    addStringTime(layer[END], payload, END);
    addUsersToPayload(layer[USERS], payload, USERS);
    addStringToPayload(layer[NAME], payload, NAME);
    addStringToPayload(layer[ID], payload, ID);
    addIntToPayload(layer[RENDERED_COVERAGE_PERCENTAGE], payload, RENDERED_COVERAGE_PERCENTAGE_VAR);
    addIntToPayload(layer[ROTATION_TURN_LENGTH], payload, ROTATION_TURN_LENGTH_VAR);
    json[] entryList = [];
    var entries = layer[RENDERED_SCHEDULE_ENTRIES];
    if (entries is RenderedScheduleEntry[]) {
        while (i < entries.length()) {
            entryList[i] = renderedScheduleToPayload(entries[i]);
            i = i + 1;
        }
        payload[RENDERED_SCHEDULE_ENTRIES_VAR] = entryList;
    }
    i = 0;
    json[] restrictionList = [];
    var restrictions = layer[RESTRICTIONS];
    if (restrictions is Restriction[]) {
        while (i < restrictions.length()) {
            restrictionList[i] = restrictionToPayload(restrictions[i]);
            i = i + 1;
        }
        payload[RESTRICTIONS] = restrictionList;
    }
    return payload;
}

function finalScheduleToPayload(FinalSchedule input) returns @tainted map<json> {
    map<json> payload = {};
    string value = input[NAME].toString();
    if (value == "") {
        if (value == FINAL_SCHEDULE) {
            payload[NAME] = FINAL_SCHEDULE_VAR;
        } else if (value == OVERIDES) {
            payload[NAME] = OVERIDES;
        }
    }
    int i = 0;
    json[] list = [];
    RenderedScheduleEntry[]? schedules = input[RENDERED_SCHEDULE_ENTRIES];
    if (schedules is RenderedScheduleEntry[]) {
        while (i < schedules.length()) {
            list[i] = renderedScheduleToPayload(schedules[i]);
            i = i + 1;
        }
        payload[RENDERED_SCHEDULE_ENTRIES_VAR] = list;
    }
    addIntToPayload(input[RENDERED_COVERAGE_PERCENTAGE], payload, RENDERED_COVERAGE_PERCENTAGE_VAR);
    return payload;
}

function renderedScheduleToPayload(RenderedScheduleEntry entry) returns @tainted map<json> {
    map<json> payload = {};
    addStringTime(entry[START], payload, START);
    addStringTime(entry[END], payload, END);
    var user = entry[USER];
    if (user is User) {
        payload[USER] = userToPayload(user);
    }
    return payload;
}

function restrictionToPayload(Restriction restriction) returns map<json> {
    map<json> payload = {};
    string value = restriction[TYPE].toString();
    if (value == DAILY_RESTRICTION) {
        payload[TYPE] = DAILY_RESTRICTION_VAR;
    } else if (value == WEEKLY_RESTRICTION) {
        payload[TYPE] = WEEKLY_RESTRICTION_VAR;
    }
    payload[START_TIME_OF_DAY_VAR] = addTime(restriction[START_TIME_OF_DAY]);
    addIntToPayload(restriction[DURATION_IN_SEC], payload, DURATION_IN_SEC_VAR);
    addIntToPayload(restriction[START_DAY_OF_WEEK], payload, START_DAY_OF_WEEK_VAR);
    return payload;
}
