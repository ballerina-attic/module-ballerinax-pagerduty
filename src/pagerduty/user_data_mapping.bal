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

function userToPayload(User|json input) returns @tainted map<json> {
    map<json> payload = {};
    map<json>|User user = {};
    if (input is json && input != ()) {
        user = <map<json>>input;
    } else if (input is User) {
        user = input;
    }
    addStringToPayload(user[TIME_ZONE], payload, TIME_ZONE_VAR);
    addStringToPayload(user[NAME], payload, NAME);
    addStringToPayload(user[EMAIL], payload, EMAIL);
    addStringToPayload(user[ID], payload, ID);
    addStringToPayload(user[AVATAR_URL], payload, AVATAR_URL_VAR);
    addStringToPayload(user[HTML_URL], payload, HTML_URL_VAR);
    addStringToPayload(user[URL], payload, SELF);
    addStringToPayload(user[COLOR], payload, COLOR);
    addStringToPayload(user[DESCRIPTION], payload, DESCRIPTION);
    addStringToPayload(user[JOB_TITLE], payload, JOB_TITLE_VAR);
    addStringToPayload(user[SUMMARY], payload, SUMMARY);
    var methods  = user[CONTACT_METHODS];
    if (methods is ContactMethod[]) {
        addContactMethodsToPayload(methods, payload);
    } else  {
        json[]|error methodsValue = methods.cloneWithType(JsonArray);
        if (methodsValue is json[]) {
            addContactMethodsToPayload(methodsValue, payload);
        }
    }
    var rules  = user[NOTIFICATION_RULES];
    if (rules is NotificationRule[]) {
        addNotificationRulesToPayload(rules, payload);
    } else  {
        json[]|error rulesValue = rules.cloneWithType(JsonArray);
        if (rulesValue is json[]) {
            addNotificationRulesToPayload(rulesValue, payload);
        }
    }
    commonsOrJsonToPayload(user[TEAMS], payload, TEAMS);
    var incidents = user[COORDINATED_INCIDENTS];
    if (incidents is Incident[]) {
        payload[COORDINATED_INCIDENTS_VAR] = incidentsToPayload(incidents);
    } else if (incidents != ()){
        json[]|error incidentsValue = incidents.cloneWithType(JsonArray);
        if (incidentsValue is json[]) {
            payload[COORDINATED_INCIDENTS_VAR] =incidentsToPayload(incidentsValue);
        }
    }
    addUserRoleToPayload(user, payload);
    string value = user[TYPE].toString();
    if (value == USER) {
        payload[TYPE] = value;
    } else {
        payload[TYPE] = USER_REFERENCE_VAR;
    }
    var invitationSent = user[INVITATION_SENT];
    if (invitationSent is boolean) {
        payload[INVITATION_SENT_VAR] = invitationSent;
    }
    return payload;
}

function addUserRoleToPayload(User|map<json> user, map<json> payload) {
    var role = user[ROLE];
    if (role is Role) {
        string value = role.toString();
        if (value == LIMITED_USER) {
            value = LIMITED_USER_VAR;
        } else if (value == READ_ONLY_USER) {
            value = READ_ONLY_USER_VAR;
        } else if (value == RESTRICTED_ACCESS) {
            value = RESTRICTED_ACCESS_VAR;
        } else if (value == READ_ONLY_LIMITED_USER) {
            value = READ_ONLY_LIMITED_USER_VAR;
        }
        payload[ROLE] = value;
    }
}

function convertToUser(json payload) returns @tainted User {
    User user = {'type: USER, name: "", email: ""};
    map<json> input = <map<json>>payload;
    var value = input[TYPE];
    if (value == USER_REFERENCE_VAR) {
        user.'type = USER_REFERENCE;
    } else {
        user.'type = USER;
    }
    addString(input[ID], user, ID);
    addString(input[TIME_ZONE_VAR], user, TIME_ZONE);
    addString(input[AVATAR_URL_VAR], user, AVATAR_URL);
    addString(input[HTML_URL_VAR], user, HTML_URL);
    addString(input[SELF], user, URL);
    addString(input[JOB_TITLE_VAR], user, JOB_TITLE);
    addString(input[NAME], user, NAME);
    addString(input[EMAIL], user, EMAIL);
    addString(input[COLOR], user, COLOR);
    addString(input[DESCRIPTION], user, DESCRIPTION);
    addString(input[SUMMARY], user, SUMMARY);
    user.invitationSent = (input[INVITATION_SENT_VAR] != ()) ? <boolean>input[INVITATION_SENT_VAR] : false;
    addRoleToUser(input, user);

    // Converts to contactMethods
    var contactMethods = input[CONTACT_METHODS_VAR];
    if (contactMethods.toString() != "") {
        user.contactMethods = convertToContactMethods(input);
    }
    // Converts to notification rules
    var rules = input[NOTIFICATION_RULES_VAR];
    if (rules.toString() != "") {
        user.notificationRules = convertToNotificationRules(input);
    }
    // Converts to teams
    CommonRecord[]? records = convertToCommons(input, TEAMS);
    if (records is CommonRecord[]) {
         user.teams = records;
    }
    var incidents = input[COORDINATED_INCIDENTS_VAR];
    if (incidents.toString() != "") {
        user.coordinatedIncidents = convertToIncidents(input, COORDINATED_INCIDENTS_VAR);
    }
    return user;
}

function addRoleToUser(map<json> payload, User user) {
    string role = payload[ROLE].toString();
    if (role != "") {
        if (role == LIMITED_USER_VAR) {
            role = LIMITED_USER;
        } else if (role == READ_ONLY_USER_VAR) {
            role = READ_ONLY_USER;
        } else if (role == RESTRICTED_ACCESS_VAR) {
            role = RESTRICTED_ACCESS;
        } else if (role == READ_ONLY_LIMITED_USER_VAR) {
            role = READ_ONLY_LIMITED_USER;
        }
        user[ROLE] = <Role>role;
    }
}

function contactMethodToPayload(ContactMethod|json input) returns map<json> {
    map<json> payload = {};
    map<json>|ContactMethod contactMethod = {};
    if (input is json && input != ()) {
        contactMethod = <map<json>>input;
    } else if (input is ContactMethod) {
        contactMethod = input;
    }
    string value = "";
    addStringToPayload(contactMethod[HTML_URL], payload, HTML_URL_VAR);
    addStringToPayload(contactMethod[SUMMARY], payload, SUMMARY);
    addStringToPayload(contactMethod[URL], payload, SELF);
    addStringToPayload(contactMethod[ADDRESS], payload, ADDRESS);
    addStringToPayload(contactMethod[ID], payload, ID);
    addLabelToContactMethod(contactMethod[LABEL].toString(), payload);
    addIntToPayload(contactMethod[COUNTRY_CODE], payload, COUNTRY_CODE_VAR);
    addIntToPayload(contactMethod[ENABLED], payload, ENABLED);
    addIntToPayload(contactMethod[BLACK_LISTED], payload, BLACK_LISTED);
    var sentShortEmail = contactMethod[SENT_SHORT_EMAIL];
    if (sentShortEmail is boolean) {
        payload[SENT_SHORT_EMAIL_VAR] = sentShortEmail.toString();
    }
    value = contactMethod[TYPE].toString();
    if (value == EMAIL) {
        payload[TYPE] = EMAIL_CONTACT_METHOD;
    } else if (value == PHONE) {
        payload[TYPE] = PHONE_CONTACT_METHOD;
    } else if (value == SMS) {
        payload[TYPE] = SMS_CONTACT_METHOD;
    } else if (value == PUSH_NOTIFICATION) {
        payload[TYPE] = PUSH_NOTIFICATION_CONTACT_METHOD;
    }
    return payload;
}

function convertToContactMethod(json resp) returns ContactMethod {
    ContactMethod contactMethod = {'type: "sms", "address": ""};
    map<json> result = <map<json>>resp;
    addString(result[ID], contactMethod, ID);
    addString(result[SELF], contactMethod, URL);
    addString(result[SUMMARY], contactMethod, SUMMARY);
    addString(result[ADDRESS], contactMethod, ADDRESS);
    addString(result[HTML_URL_VAR], contactMethod, HTML_URL);
    addString(result[ENABLED], contactMethod, ENABLED);
    addString(result[BLACK_LISTED], contactMethod, BLACK_LISTED);
    string sentShortEmail = result[SENT_SHORT_EMAIL_VAR].toString();
    if (sentShortEmail != "") {
        contactMethod[SENT_SHORT_EMAIL] = <boolean>result[SENT_SHORT_EMAIL_VAR];
    }
    string value = result[TYPE].toString();
    if (value != "") {
        if (value == EMAIL_CONTACT_METHOD || value == EMAIL_CONTACT_METHOD_REF) {
            contactMethod.'type = EMAIL;
        } else if (value == PHONE_CONTACT_METHOD || value == PHONE_CONTACT_METHOD_REF) {
            contactMethod.'type = INPUT_PHONE;
        } else if (value == SMS_CONTACT_METHOD || value == SMS_CONTACT_METHOD_REF) {
            contactMethod.'type = SMS;
        } else if (value == PUSH_NOTIFICATION_CONTACT_METHOD || value == PUSH_CONTACT_METHOD_REF) {
            contactMethod.'type = PUSH_NOTIFICATION;
        }
    }
    value = result[LABEL].toString();
    if (value != "") {
        if (value == WORK) {
            contactMethod.label = INPUT_WORK;
        } else if (value == HOME) {
            contactMethod.label = INPUT_HOME ;
        } else if (value == PHONE) {
            contactMethod.label = INPUT_PHONE;
        } else if (value == SKYPE) {
            contactMethod.label = INPUT_SKYPE;
        }
    }
    addInt(result[COUNTRY_CODE_VAR], contactMethod, COUNTRY_CODE);
    return contactMethod;
}

function addLabelToContactMethod(string label, map<json> payload) {
    if (label != "") {
        if (label == INPUT_WORK) {
            payload[LABEL] = WORK;
        } else if (label == INPUT_HOME) {
            payload[LABEL] = HOME;
        } else if (label == INPUT_PHONE) {
            payload[LABEL] = PHONE;
        } else if (label == INPUT_SKYPE) {
            payload[LABEL] = SKYPE;
        }
    }
}

function notificationRuleToPayload(NotificationRule|json input) returns map<json> {
    map<json> payload = {};
    map<json>|NotificationRule notificationRule = {};
    if (input is json && input != ()) {
        notificationRule = <map<json>>input;
    } else if (input is NotificationRule) {
        notificationRule = input;
    }
    addStringToPayload(notificationRule[HTML_URL], payload, HTML_URL_VAR);
    addIntToPayload(notificationRule[START_DELAY], payload, START_DELAY_VAR);
    addStringToPayload(notificationRule[SUMMARY], payload, SUMMARY);
    addStringToPayload(notificationRule[URL], payload, SELF);
    addStringToPayload(notificationRule[ID], payload, ID);
    addUrgencyToPayload(notificationRule[URGENCY], payload, URGENCY);
    string value = notificationRule[TYPE].toString();
    if (value != "") {
        if (value == ASSIGNMENT_NOTIFICATION_RULE) {
            payload[TYPE] = ASSIGNMENT_NOTIFICATION_RULE_VAR;
        }
    }
    payload[CONTACT_METHOD_VAR] = contactMethodToPayload(notificationRule[CONTACT_METHOD]);
    return payload;
}

function convertToNotificationRule(json resp) returns NotificationRule {
    NotificationRule rule = {'type: ASSIGNMENT_NOTIFICATION_RULE, startDelayInMinutes: 0,
                        contactMethod: {'type: "sms", "address": ""}, urgency: HIGH};
    map<json> result = <map<json>>resp;
    string value = result[TYPE].toString();
    if (value == ASSIGNMENT_NOTIFICATION_RULE_VAR) {
        rule.'type = ASSIGNMENT_NOTIFICATION_RULE;
    }
    addString(result[ID], rule, ID);
    addString(result[SELF], rule, URL);
    addString(result[SUMMARY], rule, SUMMARY);
    addString(result[HTML_URL_VAR], rule, HTML_URL);
    addUrgency(result[URGENCY], rule);
    // Converts to contactMethods
    if (result[CONTACT_METHOD_VAR].toString() != "") {
        rule.contactMethod = convertToContactMethod(<map<json>>result[CONTACT_METHOD_VAR]);
    }
    addInt(result[START_DELAY_VAR], rule, START_DELAY);
    return rule;
}

function convertToContactMethods(map<json> payload) returns ContactMethod[] {
    ContactMethod[] contactMethods = [];
    json[] contactMethodList = <json[]>payload[CONTACT_METHODS_VAR];
    int i = 0;
    while (i < contactMethodList.length()) {
        contactMethods[i] = convertToContactMethod(contactMethodList[i]);
        i = i + 1;
    }
    return contactMethods;
}

function convertToNotificationRules(map<json> payload) returns NotificationRule[] {
    NotificationRule[] notificationRules = [];
    json[] notificationRuleList = <json[]>payload[NOTIFICATION_RULES_VAR];
    int i = 0;
    while (i < notificationRuleList.length()) {
        notificationRules[i] = convertToNotificationRule(notificationRuleList[i]);
        i = i + 1;
    }
    return notificationRules;
}

function convertToUsers(map<json> payload) returns User[] {
    User[] users = [];
    json[] userList = <json[]>payload[USERS];
    int i = 0;
    while (i < userList.length()) {
        users[i] = convertToUser(userList[i]);
        i = i + 1;
    }
    return <@untainted> users;
}

function addContactMethodsToPayload(ContactMethod[]?|json[]? methods, map<json> payload) {
    int i =0;
    json[] list = [];
    if (methods is ContactMethod[] || methods is json[]) {
        while (i < methods.length()) {
            list[i] = contactMethodToPayload(methods[i]);
            i = i + 1;
        }
    }
    if (list != []) {
        payload[CONTACT_METHODS] = list;
    }
}

function addNotificationRulesToPayload(NotificationRule[]?|json[]? rules, map<json> payload) {
    int i =0;
    json[] list = [];
    if (rules is NotificationRule[] || rules is json[]) {
        while (i < rules.length()) {
            list[i] = notificationRuleToPayload(rules[i]);
            i = i + 1;
        }
    }
    if (list != []) {
        payload[NOTIFICATION_RULES] = list;
    }
}

function addUsersToPayload(User[]? users, @tainted map<json> payload, string fieldName) {
    int i = 0;
    json[] list = [];
    if (users is User[]) {
        while (i < users.length()) {
            list[i] = userToPayload(users[i]);
            i = i + 1;
        }
    }
    if (list.length() > 0 ) {
        payload[fieldName] = list;
    }
}
