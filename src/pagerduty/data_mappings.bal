// Copyright (c) 2020, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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

function addStringToPayload(string?|json? input, map<json> payload, string key) {
    string value = input.toString();
    if (value != "") {
        payload[key] = input;
    }
}

function addString(json? input, Schedule|ScheduleLayer|Schedule|User|SupportHour|Extension|Service|CommonRecord|Note|
                   Incident|Integration|EscalationRule|EscalationPolicy|ContactMethod|NotificationRule output,
                   string key) {
    string value = input.toString();
    if (value != "") {
       output[key] = value;
    }
}

function addStringTime(time:Time?|json? value, map<json> payload, string key) {
    if (value is time:Time) {
       payload[key] = time:toString(value);
    } else if (value != ()){
       payload[key] = value;
    }
}

function addTime(time:Time time) returns string {
    int mins = time:getMinute(time);
    int secs = time:getSecond(time);
    int hour = time:getHour(time);
    string hoursInString = hour < 10 ? "0"+ hour.toString() : hour.toString();
    string minsInString = mins < 10 ? "0"+ mins.toString() :  mins.toString();
    string secsInString = secs < 10 ? "0"+ secs.toString() :  secs.toString();
    return hoursInString + ":" + minsInString + ":" + minsInString;
}

function setTimeFromString(json? input, Schedule|RenderedScheduleEntry|ScheduleLayer|Restriction|Service|
                           SupportHour|Integration|Note|Incident|Assignment|Acknowledgement|PendingAction output,
                           string key) {
    string value = input.toString();
    if (value != "") {
        var time = time:parse(value, "yyyy-MM-dd'T'HH:mm:ssz");
        if (time is time:Time) {
            output[key] = time;
        }
    }
}

function addIntToPayload(int?|json? input, map<json> payload, string key) {
    string value = input.toString();
    if (value != "") {
        payload[key] = input;
    }
}

function addInt(json? value, Schedule|ScheduleLayer|FinalSchedule|Restriction|Service|Note|Incident|ContactMethod|
                Integration|EscalationRule|NotificationRule|EscalationPolicy output, string key) {
    if (value.toString() != "") {
       output[key] = <int>value;
    }
}

function addUrgencyToPayload(Urgency?|json? urgency, map<json> payload, string key) {
    if (urgency == HIGH) {
        payload[key] = HIGH;
    } else if (urgency == LOW) {
        payload[key] = LOW;
    } else if (urgency == SUPPRESSED) {
        payload[key] = SUPPRESSED;
    } else if (urgency is SEVERITY_BASED) {
        payload[key] = SEVERITY_BASED_VAR;
    }
}

function addUrgency(json? urgency, IncidentUrgencyRule|IncidentSupportHour|Incident|ScheduledAction|
                    NotificationRule output) {
    if (urgency != ()) {
        if (urgency == HIGH) {
            output[URGENCY] = HIGH;
        } else if (urgency == LOW) {
            output[URGENCY] = LOW;
        } else if (urgency == SUPPRESSED) {
            output[URGENCY] = SUPPRESSED;
        } else if (urgency == SEVERITY_BASED_VAR) {
            output[URGENCY] = SEVERITY_BASED;
        }
    }
}

function addNameToPayload(Name? name, map<json> payload) {
    if (name is Name) {
        if (name == FINAL_SCHEDULE) {
            payload[NAME] = FINAL_SCHEDULE_VAR;
        } else if (name == SUPPORT_HOURS_START) {
            payload[NAME] = SUPPORT_HOURS_START_VAR;
        } else if (name == SUPPORT_HOUR_END) {
            payload[NAME] = SUPPORT_HOURS_END_VAR;
        } else {
            payload[NAME] = SEVERITY_BASED_VAR;
        }
    }
}

function addName(json? name, At at) {
    if (name != ()) {
        if (name == FINAL_SCHEDULE_VAR) {
            at[NAME] = FINAL_SCHEDULE;
        } else if (name == SUPPORT_HOURS_START_VAR) {
            at[NAME] = SUPPORT_HOURS_START;
        } else if (name == SUPPORT_HOURS_END_VAR) {
            at[NAME] = SUPPORT_HOUR_END;
        } else {
            at[NAME] = OVERIDES;
        }
    }
}

function setTime(json? input, SupportHour output, string key) {
    string value = input.toString();
    if (value != "") {
        var time = time:parse(value, "HH:mm:ss");
        if (time is time:Time) {
            output[key] = time;
        }
    }
}
