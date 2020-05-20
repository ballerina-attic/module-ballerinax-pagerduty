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

function convertToCommon(json resp) returns CommonRecord {
    map<json> input = <map<json>>resp;
    CommonRecord common = {'type: TEAM, id: ""};
    addString(input[SUMMARY], common, SUMMARY);
    addString(input[SELF], common, URL);
    addString(input[HTML_URL_VAR], common, HTML_URL);
    addString(input[ID], common, ID);
    string value = input[TYPE].toString();
    if (value == TEAM) {
        common.'type = TEAM;
    } else if (value == EXTENSION_SCHEMA_REF_VAR) {
        common.'type = EXTENSION_SCHEMA_REF;
    } else if (value == EXTENSION_SCHEMA_VAR) {
        common.'type = EXTENSION_SCHEMA;
    } else if (value == VENDOR) {
        common.'type = VENDOR;
    } else if (value == VENDOR_REFERENCE_VAR) {
        common.'type = VENDOR_REFERENCE;
    } else if (value == TEAM_REFERENCE_VAR) {
        common.'type = TEAM_REFERENCE;
    } else if (value == FULL_PAGE_ADDONS_VAR) {
        common.'type = FULL_PAGE_ADDONS;
    } else if (value == INCIDENT_ADDONS_VAR) {
        common.'type = INCIDENT_ADDONS;
    } else if (value == SERVICE_REFERENCE_VAR) {
        common.'type = SERVICE_REFERENCE;
    } else if (value == SERVICE) {
        common.'type = SERVICE;
    } else if (value == USER) {
        common.'type = USER;
    } else if (value == USER_REFERENCE_VAR) {
        common.'type = USER_REFERENCE;
    } else if (value == PRIORITY_REFERENCE_VAR) {
        common.'type = PRIORITY_REFERENCE;
    }
    return common;
}

function commonToPayload(CommonRecord|json input) returns map<json>? {
    map<json>|CommonRecord commonRecord = {};
    if (input is json && input != ()) {
        commonRecord = <map<json>>input;
    } else if (input is CommonRecord){
        commonRecord = input;
    }
    if (commonRecord != {}) {
        map<json> payload = {};
        addStringToPayload(commonRecord[ID], payload, ID);
        addStringToPayload(commonRecord[SUMMARY], payload, SUMMARY);
        addStringToPayload(commonRecord[HTML_URL], payload, HTML_URL_VAR);
        addStringToPayload(commonRecord[URL], payload, SELF);
        string value = commonRecord[TYPE].toString();
        if (value == EXTENSION_SCHEMA_REF) {
            payload[TYPE] = EXTENSION_SCHEMA_REF_VAR;
        } else if (value == EXTENSION_SCHEMA) {
            payload[TYPE] = EXTENSION_SCHEMA_VAR;
        } else if (value == TEAM) {
            payload[TYPE] = TEAM;
        } else if (value == VENDOR) {
            payload[TYPE] = VENDOR;
        } else if (value == VENDOR_REFERENCE) {
            payload[TYPE] = VENDOR_REFERENCE_VAR;
        } else if (value == TEAM_REFERENCE) {
            payload[TYPE] = TEAM_REFERENCE_VAR;
        } else if (value == FULL_PAGE_ADDONS) {
            payload[TYPE] = FULL_PAGE_ADDONS_VAR;
        } else if (value == INCIDENT_ADDONS) {
            payload[TYPE] = INCIDENT_ADDONS_VAR;
        } else if (value == SERVICE_REFERENCE) {
            payload[TYPE] = SERVICE_REFERENCE_VAR;
        } else if (value == SERVICE) {
            payload[TYPE] = SERVICE;
        } else if (value == USER) {
            payload[TYPE] = USER;
        } else if (value == USER_REFERENCE) {
            payload[TYPE] = USER_REFERENCE_VAR;
        } else if (value == PRIORITY_REFERENCE) {
            payload[TYPE] = PRIORITY_REFERENCE_VAR;
        }
        return payload;
    }
}

function commonsToPayload(CommonRecord[]?|json[] commonRecords, map<json> payload, string fieldName) {
     int i = 0;
     json[] list = [];
     if (commonRecords is CommonRecord[]|json[]) {
         while (i < commonRecords.length()) {
             list[i] = commonToPayload(commonRecords[i]);
             i = i + 1;
         }
     }
     if (list != []) {
         payload[fieldName] = list;
     }
}

function convertToCommons(map<json> input, string key) returns CommonRecord[]? {
    int i = 0;
    CommonRecord[] commonRecords = [];
    var value = input[key];
    if (value != ()) {
        json[] list = <json[]>value;
        int length = list.length();
        while (i < length) {
            commonRecords[i] = convertToCommon(list[i]);
            i = i + 1;
        }
        if (commonRecords.length() > 0) {
            return commonRecords;
        }
    }
}

function commonsOrJsonToPayload(json|CommonRecord[] commonRecords, map<json> payload, string key) {
    if (commonRecords is json && commonRecords != ()) {
        commonsToPayload(<json[]>commonRecords, payload, key);
    } else if (commonRecords is CommonRecord[]){
        commonsToPayload(commonRecords, payload, key);
    }
}
