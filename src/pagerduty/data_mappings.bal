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

function userToPayload(User user) returns map<json> {
    map<json> payload = {};
    addStringToPayload(user[TIMEZONE], payload, TIME_ZONE);
    addStringToPayload(user[NAME], payload, NAME);
    addStringToPayload(user[EMAIL], payload, EMAIL);
    addStringToPayload(user[ID], payload, ID);
    addStringToPayload(user[AVATARURL], payload, AVATAR_URL);
    addStringToPayload(user[COLOR], payload, COLOR);
    addStringToPayload(user[DESCRIPTION], payload, DESCRIPTION);
    addStringToPayload(user[JOBTITLE], payload, JOB_TITLE);
    addContactMethodsToPayload(user[CONTACTMETHODS], payload);
    addNotificationRulesToPayload(user[NOTIFICATIONRULES], payload);
    commonsToPayload(user[TEAMS], payload, TEAMS);
    addUserRoleToPayload(user, payload);
    string value = user[TYPE].toString();
    if (value == USER) {
        payload[TYPE] = value;
    } else {
        payload[TYPE] = USER_REFERENCE;
    }
    var invitationSent = user[INVITATIONSENT];
    if (invitationSent is boolean) {
        payload[INVITATION_SENT] = invitationSent;
    }
    return payload;
}

function addUserRoleToPayload(User user, map<json> payload) {
    var role = user[ROLE];
    if (role is Role) {
        string value = role.toString();
        if (value == LIMITEDUSER) {
            value = LIMITED_USER;
        } else if (value == READONLYUSER) {
            value = READ_ONLY_USER;
        } else if (value == RESTRICTEDACCESS) {
            value = RESTRICTED_ACCESS;
        } else if (value == READONLYLIMITEDUSER) {
            value = READ_ONLY_LIMITED_USER;
        }
        payload[ROLE] = value;
    }
}

function convertToUser(json payload, User user) {
    map<json> input = <map<json>>payload;
    var value = input[TYPE];
    if (value == USER_REFERENCE) {
        user.'type = USERREFERENCE;
    } else {
        user.'type = USER;
    }
    addString(input[ID], user, ID);
    addString(input[TIME_ZONE], user, TIMEZONE);
    addString(input[AVATAR_URL], user, AVATARURL);
    addString(input[JOB_TITLE], user, JOBTITLE);
    addString(input[NAME], user, NAME);
    addString(input[EMAIL], user, EMAIL);
    addString(input[COLOR], user, COLOR);
    addString(input[DESCRIPTION], user, DESCRIPTION);
    user.invitationSent = (input[INVITATION_SENT] != ()) ? <boolean>input[INVITATION_SENT] : false;
    addRoleToUser(input, user);
    // Converts to contactMethods
    var contactMethod = input[CONTACT_METHOD];
    if (contactMethod.toString() != "") {
        user.contactMethods = convertToContactMethods(input);
    }
    // Converts to notification rules
    var rules = input[NOTIFICATION_RULES];
    if (rules.toString() != "") {
        user.notificationRules = convertToNotificationRules(input);
    }
    // Converts to teams
    var teams = input[TEAMS];
    if (teams.toString() != "") {
        user.teams = convertToCommons(input, TEAMS);
    }
}

function addRoleToUser(map<json> payload, User user) {
    string role = payload[ROLE].toString();
    if (role != "") {
        if (role == LIMITED_USER) {
            role = LIMITEDUSER;
        } else if (role == READ_ONLY_USER) {
            role = READONLYUSER;
        } else if (role == RESTRICTED_ACCESS) {
            role = RESTRICTEDACCESS;
        } else if (role == READ_ONLY_LIMITED_USER) {
            role = READONLYLIMITEDUSER;
        } else if (role == READ_ONLY_LIMITED_USER) {
            role = READONLYLIMITEDUSER;
        }
        user[ROLE] = <Role>role;
    }
}

function convertToJsonArray(map<json> payload, string key) returns json[] {
    json[] jsonList = [];
    var jsonValue = json[].constructFrom(payload[key]);
    if (jsonValue is json[]) {
        jsonList = jsonValue;
    }
    return jsonList;
}

function addContactMethodsToPayload(ContactMethod[]? methods, map<json> payload) {
    int i =0;
    json[] list = [];
    if (methods is ContactMethod[]) {
        while (i < methods.length()) {
            list[i] = contactMethodToPayload(methods[i]);
            i = i + 1;
        }
        payload[CONTACT_METHODS] = list;
    }
}

function addNotificationRulesToPayload(NotificationRule[]? rules, map<json> payload) {
    int i =0;
    json[] list = [];
    if (rules is NotificationRule[]) {
        while (i < rules.length()) {
            list[i] = notificationRuleToPayload(rules[i]);
            i = i + 1;
        }
        payload[NOTIFICATION_RULES] = list;
    }
}

function convertToCommon(json resp) returns Common {
    map<json> input = <map<json>>resp;
    Common common = {'type: TEAM, id: input[ID].toString()};
    addString(input[SUMMARY], common, SUMMARY);
    addString(input[SELF], common, URL);
    addString(input[HTML_URL], common, HTMLURL);
    string value = input[TYPE].toString();
    if (value == TEAM) {
        common.'type = TEAM;
    } else if (value == EXTENSION_SCHEMA_REF) {
        common.'type = EXTENSIONSCHEMAREF;
    } else if (value == EXTENSION_SCHEMA) {
        common.'type = EXTENSIONSCHEMA;
    } else if (value == VENDOR) {
        common.'type = VENDOR;
    } else if (value == VENDOR_REFERENCE) {
        common.'type = VENDORREFERENCE;
    } else if (value == TEAM_REFERENCE) {
        common.'type = TEAMREFERENCE;
    } else if (value == FULL_PAGE_ADDONS) {
        common.'type = FULLPAGEADDONS;
    } else if (value == INCIDENT_ADDONS) {
        common.'type = INCIDENTADDONS;
    } else if (value == SERVICE_REFERENCE) {
        common.'type = SERVICEREFERENCE;
    } else if (value == SERVICE) {
        common.'type = SERVICE;
    } else if (value == USER) {
        common.'type = USER;
    } else if (value == USER_REFERENCE) {
        common.'type = USERREFERENCE;
    }
    return common;
}

function commonToPayload(Common common) returns map<json> {
    map<json> payload = {};
    addStringToPayload(common[ID], payload, ID);
    addStringToPayload(common[SUMMARY], payload, SUMMARY);
    addStringToPayload(common[HTMLURL], payload, HTML_URL);
    addStringToPayload(common[URL], payload, SELF);
    string value = common[TYPE].toString();
    if (value == EXTENSIONSCHEMAREF) {
        payload[TYPE] = EXTENSION_SCHEMA_REF;
    } else if (value == EXTENSIONSCHEMA) {
        payload[TYPE] = EXTENSION_SCHEMA;
    } else if (value == TEAM) {
        payload[TYPE] = TEAM;
    } else if (value == VENDOR) {
        payload[TYPE] = VENDOR;
    } else if (value == VENDORREFERENCE) {
        payload[TYPE] = VENDOR_REFERENCE;
    } else if (value == TEAMREFERENCE) {
        payload[TYPE] = TEAM_REFERENCE;
    } else if (value == FULLPAGEADDONS) {
        payload[TYPE] = FULL_PAGE_ADDONS;
    } else if (value == INCIDENTADDONS) {
        payload[TYPE] = INCIDENT_ADDONS;
    } else if (value == SERVICEREFERENCE) {
        payload[TYPE] = SERVICE_REFERENCE;
    } else if (value == SERVICE) {
        payload[TYPE] = SERVICE;
    } else if (value == USER) {
        payload[TYPE] = USER;
    } else if (value == USERREFERENCE) {
        payload[TYPE] = USER_REFERENCE;
    }
    return payload;
}

function contactMethodToPayload(ContactMethod contactMethod) returns map<json> {
    map<json> payload = {};
    string value = "";
    addStringToPayload(contactMethod[HTMLURL], payload, HTML_URL);
    addStringToPayload(contactMethod[SUMMARY], payload, SUMMARY);
    addStringToPayload(contactMethod[URL], payload, SELF);
    addStringToPayload(contactMethod[ADDRESS], payload, ADDRESS);
    addStringToPayload(contactMethod[ID], payload, ID);
    addLabelToContactMethod(contactMethod[LABEL], payload);
    addIntToPayload(contactMethod[COUNTRYCODE], payload, COUNTRY_CODE);
    value = contactMethod[TYPE].toString();
    if (value == EMAIL) {
        payload[TYPE] = EMAIL_CONTACT_METHOD;
    } else if (value == PHONE) {
        payload[TYPE] = PHONE_CONTACT_METHOD;
    } else if (value == SMS) {
        payload[TYPE] = SMS_CONTACT_METHOD;
    } else {
        payload[TYPE] = PHONE_NOTIFICATION_CONTACT_METHOD;
    }
    return payload;
}

function addLabelToContactMethod(string? label, map<json> payload) {
    if (label != "") {
        if (label == INPUT_WORK) {
            payload[LABEL] = WORK;
        } else if (label == INPUT_HOME) {
            payload[LABEL] = HOME;
        } else if (label == INPUT_PHONE) {
          payload[LABEL] = PHONE;
        } else if (label == SKYPE) {
          payload[LABEL] = SKYPE;
        }
    }
}

function convertToContactMethod(json resp, ContactMethod contactMethod) {
    map<json> result = <map<json>>resp;
    addString(result[ID], contactMethod, ID);
    addString(result[SELF], contactMethod, URL);
    addString(result[SUMMARY], contactMethod, SUMMARY);
    addString(result[ADDRESS], contactMethod, ADDRESS);
    addString(result[HTML_URL], contactMethod, HTMLURL);
    string value = result[TYPE].toString();
    if (value != "") {
        if (value == EMAIL_CONTACT_METHOD || value == EMAIL_CONTACT_METHOD_REF ) {
            contactMethod.'type = EMAIL;
        } else if (value == PHONE_CONTACT_METHOD || value == PHONE_CONTACT_METHOD_REF) {
            contactMethod.'type = INPUT_PHONE;
        } else if (value == SMS_CONTACT_METHOD || value == SMS_CONTACT_METHOD_REF) {
            contactMethod.'type = SMS;
        } else {
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
        } else {
          contactMethod.label = INPUT_SKYPE;
        }
    }
    addInt(result[COUNTRY_CODE], contactMethod, COUNTRYCODE);
}

function notificationRuleToPayload(NotificationRule notificationRule) returns map<json> {
    map<json> payload = {};
    addStringToPayload(notificationRule[HTMLURL], payload, HTML_URL);
    addIntToPayload(notificationRule[STARTDELAY], payload, START_DELAY);
    addStringToPayload(notificationRule[SUMMARY], payload, SUMMARY);
    addStringToPayload(notificationRule[URL], payload, SELF);
    addStringToPayload(notificationRule[ID], payload, ID);
    addUrgencyToPayload(notificationRule[URGENCY], payload, URGENCY);
    string value = notificationRule[TYPE].toString();
    if (value != "") {
        if (value == ASSIGNMENTNOTIFICATIONRULE) {
            payload[TYPE] = ASSIGNMENT_NOTIFICATION_RULE;
        }
    }
    ContactMethod? contactMethod = notificationRule[CONTACTMETHOD];
    if (contactMethod is ContactMethod) {
        payload[CONTACT_METHOD] = contactMethodToPayload(contactMethod);
    }
    return payload;
}

function convertToNotificationRule(json resp, NotificationRule rule) {
    map<json> result = <map<json>>resp;
    string value = result[TYPE].toString();
    if (value == ASSIGNMENT_NOTIFICATION_RULE) {
        rule.'type = ASSIGNMENTNOTIFICATIONRULE;
    }
    addString(result[ID], rule, ID);
    addString(result[URL], rule, SELF);
    addString(result[SUMMARY], rule, SUMMARY);
    addString(result[HTML_URL], rule, HTMLURL);
    addUrgency(result[URGENCY], rule);
    // Converts to contactMethods
    if (result[CONTACT_METHOD].toString() != "") {
        ContactMethod outputContactMethod = {'type: "sms", "address": "9876543213"};
        convertToContactMethod(<map<json>>result[CONTACT_METHOD], outputContactMethod);
        rule.contactMethod = outputContactMethod;
    }
    addInt(result[START_DELAY], rule, STARTDELAY);
}

function convertToContactMethods(map<json> payload) returns ContactMethod[] {
    ContactMethod[] contactMethods = [];
    json[] contactMethodList = convertToJsonArray(payload, CONTACT_METHODS);
    int i = 0;
    while (i < contactMethodList.length()) {
        ContactMethod outputContactMethod = {'type: "sms", "address": "9876543213"};
        convertToContactMethod(contactMethodList[i], outputContactMethod);
        contactMethods[i] = outputContactMethod;
        i = i + 1;
    }
    return contactMethods;
}

function convertToNotificationRules(map<json> payload) returns NotificationRule[] {
    NotificationRule[] notificationRules = [];
    json[] notificationRuleList = convertToJsonArray(payload, NOTIFICATION_RULES);
    int i = 0;
    while (i < notificationRuleList.length()) {
        NotificationRule rule = {'type: ASSIGNMENTNOTIFICATIONRULE, startDelayInMinutes: 0,
                    contactMethod: {'type: "sms", "address": "9876543213"}, urgency: HIGH};
        convertToNotificationRule(notificationRuleList[i], rule);
        notificationRules[i] = rule;
        i = i + 1;
    }
    return notificationRules;
}

function convertToUsers(map<json> payload) returns User[] {
    User[] users = [];
    json[] userList = convertToJsonArray(payload, USERS);
    int i = 0;
    while (i < userList.length()) {
        User input = {'type: USER, name: "", email: ""};
        convertToUser(userList[i], input);
        users[i] = input;
        i = i + 1;
    }
    return users;
}

function escalationPolicyToPayload(EscalationPolicy escalationPolicy) returns @tainted map<json> {
    map<json> payload = {};
    addStringToPayload(escalationPolicy[HTMLURL], payload, HTML_URL);
    addStringToPayload(escalationPolicy[NAME], payload, NAME);
    addStringToPayload(escalationPolicy[SUMMARY], payload, SUMMARY);
    addStringToPayload(escalationPolicy[URL], payload, SELF);
    addStringToPayload(escalationPolicy[ID], payload, ID);
    addStringToPayload(escalationPolicy[DESCRIPTION], payload, DESCRIPTION);
    addIntToPayload(escalationPolicy[NUMBER_OF_LOOPS], payload, NUM_LOOPS);
    string value = escalationPolicy[TYPE].toString();
    if (value == ESCALATIONPOLICY) {
        payload[TYPE] = ESCALATION_POLICY;
    }
    value = escalationPolicy[ONCALLHANDOFNOTIFICATION].toString();
    if (value != "") {
        if (value == HAS_SERVICE) {
            value =  IF_HAS_SERVICE;
        } else {
            value = ALWAYS;
        }
        payload[ON_CALL_HAND_OF_NOTIFICATION] = value;
    }
    int i = 0;
    // Sets escalation rules
    var rules = escalationPolicy[ESCALATIONRULES];
    json[] list = [];
    while (i < rules.length()) {
        list[i] = escalationRuleToPayload(rules[i]);
        i = i + 1;
    }
    payload[ESCALATION_RULE] = list;
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
    if (teams is Common[]) {
        commonsToPayload(escalationPolicy[TEAMS], payload, TEAMS);
    }
    return payload;
}

function escalationRuleToPayload(EscalationRule escalationRule) returns map<json> {
    map<json> payload = {};
    addIntToPayload(escalationRule[ESCALATIONDELAYINMINUTES], payload, ESCALATION_DELAY_IN_MINUTES);
    addStringToPayload(escalationRule[ID], payload, ID);
    commonsToPayload(escalationRule[TARGETS], payload, TARGETS);
    return payload;
}

function addUsersToPayload(User[]? users, map<json> payload, string fieldName) {
     int i = 0;
     json[] list = [];
     if (users is User[]) {
         while (i < users.length()) {
             list[i] = userToPayload(users[i]);
             i = i + 1;
         }
     }
     payload[fieldName] = list;
}

function convertToEscalationPolicy(map<json> response, @tainted EscalationPolicy escalationPolicy) {
    string value = response[TYPE].toString();
    if (value == ESCALATION_POLICY) {
       escalationPolicy.'type = ESCALATIONPOLICY;
    }
    addString(response[ID], escalationPolicy, ID);
    addString(response[SELF], escalationPolicy, URL);
    addString(response[NAME], escalationPolicy, NAME);
    addString(response[DESCRIPTION], escalationPolicy, DESCRIPTION);
    addString(response[HTML_URL], escalationPolicy, HTMLURL);
    addInt(response[NUM_LOOPS], escalationPolicy, NUMBER_OF_LOOPS);
    value = response[ON_CALL_HAND_OF_NOTIFICATION].toString();
    if (value != "") {
        if (value == IF_HAS_SERVICE) {
            escalationPolicy.onCallHandoffNotification =  HAS_SERVICE;
        } else {
            escalationPolicy.onCallHandoffNotification = ALWAYS;
        }
    }
    int i = 0;
    json[] targetList = convertToJsonArray(response, ESCALATION_RULE);
    while (i < targetList.length()) {
        EscalationRule escalationRule = {"escalationDelayInMinutes": 0,"targets": []};
        var rules = convertToEscalationRule(<map<json>>targetList[i], escalationRule);
        if (rules is EscalationRule) {
           escalationPolicy.escalationRules[i]= rules;
           i = i + 1;
        }
    }
    i = 0;
    json[] escalationServiceList = convertToJsonArray(response, SERVICES);
    while (i < escalationServiceList.length()) {
        Service serv = {"name": "", "escalationPolicy":{"type": "escalationPolicy", "name": "", "escalationRules": []}};
        convertToService(<map<json>>escalationServiceList[i], serv);
        escalationPolicy.services[i]= serv;
        i = i + 1;
    }
    i = 0;
    json[] teamList = convertToJsonArray(response, TEAMS);
    while (i < teamList.length()) {
        escalationPolicy.teams[i]= convertToCommon(teamList[i]);
        i = i + 1;
    }
}

function convertToEscalationRule(map<json> input, EscalationRule escalationRule) returns EscalationRule? {
    addInt(input[ESCALATION_DELAY_IN_MINUTES], escalationRule, ESCALATIONDELAYINMINUTES);
    addString(input[ID], escalationRule, ID);
    json[] targetList = convertToJsonArray(input, TARGETS);
    int i = 0;
    while (i < targetList.length()) {
        escalationRule.targets[i] = convertToCommon(targetList[i]);
        i = i + 1;
    }
    return escalationRule;
}

function commonsToPayload(Common[]? commons, map<json> payload, string fieldName) {
     int i = 0;
     json[] list = [];
     if (commons is Common[]) {
         while (i < commons.length()) {
             list[i] = commonToPayload(commons[i]);
             i = i + 1;
         }
         payload[fieldName] = list;
     }
}

function convertToSchedules(map<json> input) returns @tainted Schedule[] {
    int i = 0;
    Schedule[] schedules = [];
    json[] targetList = convertToJsonArray(input, SCHEDULES);
    while (i < targetList.length()) {
        Schedule schedule = {"type": "schedule", "timeZone": "", "scheduleLayers": []};
        convertToSchedule(<map<json>>targetList[i], schedule);
        schedules[i] = schedule;
        i = i + 1;
    }
    return schedules;
}

function convertToSchedule(map<json> response, @tainted Schedule schedule) {
    schedule.'type = response[TYPE].toString();
    addString(response[TIME_ZONE], schedule, TIMEZONE);
    addString(response[SUMMARY], schedule, SUMMARY);
    addString(response[SELF], schedule, URL);
    addString(response[DESCRIPTION], schedule, DESCRIPTION);
    addString(response[NAME], schedule, NAME);
    addString(response[ID], schedule, ID);
    addUsers(response, schedule);
    int i = 0;
    json[] targetList = convertToJsonArray(response, SCHEDULE_LAYERS);
    while (i < targetList.length()) {
        ScheduleLayer value = convertToScheduleLayer(<map<json>>targetList[i]);
        schedule.scheduleLayers[i] = value;
        i = i + 1;
    }
    i = 0;
    json[] policyList = convertToJsonArray(response, ESCALATION_POLICIES);
    while (i < policyList.length()) {
        EscalationPolicy escalationPolicy = { "type": "escalationPolicy", "name": "", "escalationRules": []};
        convertToEscalationPolicy(<map<json>>policyList[i], escalationPolicy);
        schedule.escalationPolicies[i] = escalationPolicy;
        i = i + 1;
    }
    var finalSchedule = response[FINAL_SCHEDULE];
    if (finalSchedule.toString() != "") {
        schedule.finalSchedule = convertToFinalSchedule(<map<json>>finalSchedule);
    }
    var overideSchedule = response[OVERRIDES_SCHEDULE];
    if (overideSchedule.toString() != "") {
        schedule.overridesSubschedule = convertToFinalSchedule(<map<json>>overideSchedule);
    }
    i = 0;
    json[] teamList = convertToJsonArray(response, TEAMS);
    while (i < teamList.length()) {
        schedule.teams[i] = convertToCommon(teamList[i]);
        i = i + 1;
    }
}

function addUsers(map<json> response, Schedule|ScheduleLayer output) {
    int i = 0;
    json[] userList = convertToJsonArray(response, USERS);
    while (i < userList.length()) {
        User user = {"type": "user", "name": "peter", "email": "ashacffe@gmail.com"};
        convertToUser(userList[i], user);
        output.users[i] = user;
        i = i + 1;
    }
}

function convertToScheduleLayer(map<json> input) returns ScheduleLayer {
    time:Time time = time:currentTime();
    var output  = time:parse("00:00:00", "HH:mm:ss");
    if (output is time:Time) {
        time = output;
    }
    ScheduleLayer scheduleLayer = {"start": time, "users": [] ,"rotationVirtualStart": time,
                             "rotationTurnLengthInSeconds": 0};
    setTimeFromString(input[START], scheduleLayer, START);
    setTimeFromString(input[ROTATION_VIRTUAL_START], scheduleLayer, ROTATIONVIRTUALSTART);
    setTimeFromString(input[END], scheduleLayer, END);
    addUsers(input, scheduleLayer);
    addString(input[NAME], scheduleLayer, NAME);
    addString(input[ID], scheduleLayer, ID);
    addInt(input[ROTATION_TURN_LENGTH], scheduleLayer, ROTATIONTURNLENGTH);
    addInt(input[RENDERED_COVERAGE_PERCENTAGE], scheduleLayer, RENDEREDCOVERAGEPERCENTAGE);
    int i = 0;
    json[] entryList = convertToJsonArray(input, RENDERED_SCHEDULE_ENTRIES);
    while (i < entryList.length()) {
        scheduleLayer.renderedScheduleEntries[i] = convertToRenderedSchedule(<map<json>>entryList[i]);
        i = i + 1;
    }
    i = 0;
    json[] restrictionList = convertToJsonArray(input, RESTRICTIONS);
    while (i < restrictionList.length()) {
        scheduleLayer.restrictions[i] = convertToRestriction(<map<json>>restrictionList[i]);
        i = i + 1;
    }
    return scheduleLayer;
}

function convertToFinalSchedule(map<json> input) returns FinalSchedule {
    FinalSchedule finalSchedule = {"name": FINALSCHEDULE};
    string value = input[NAME].toString();
    if (value != "") {
        if (value == FINAL_SCHEDULE) {
            finalSchedule.name = FINALSCHEDULE;
        } else if (value == OVERIDES) {
            finalSchedule.name = OVERIDE;
        }
    }
    int i = 0;
    json[] targetList = convertToJsonArray(input, RENDERED_SCHEDULE_ENTRIES);
    while (i < targetList.length()) {
        finalSchedule.renderedScheduleEntries[i] = convertToRenderedSchedule(<map<json>>targetList[i]);
        i = i + 1;
    }
    addInt(input[RENDERED_COVERAGE_PERCENTAGE], finalSchedule, RENDEREDCOVERAGEPERCENTAGE);
    return finalSchedule;
}

function convertToRenderedSchedule(map<json> input) returns RenderedScheduleEntry {
    time:Time time = time:currentTime();
    var output  = time:parse("00:00:00", "HH:mm:ss");
    if (output is time:Time) {
        time = output;
    }
    RenderedScheduleEntry scheduleEntry = { "start": time, "end": time};
    setTimeFromString(input[START], scheduleEntry, START);
    setTimeFromString(input[END], scheduleEntry, END);
    var data = input[USER];
    if (data is USER) {
        User user = {"type": "user", "name": "peter", "email": "ashacffe@gmail.com"};
        convertToUser(data, user);
        scheduleEntry.user = user;
    }
    return scheduleEntry;
}

function convertToRestriction(map<json> input) returns Restriction {
    time:Time time = time:currentTime();
    var output  = time:parse("00:00:00", "HH:mm:ss");
    if (output is time:Time) {
        time = output;
    }
    Restriction restriction = {"type": "dailyRestriction", "startTimeOfDay": time, durationInSeconds: 0};
    string value = input[TYPE].toString();
    if(value != "") {
        if (value == DAILY_RESTRICTION) {
            restriction.'type = DAILYRESTRICTION;
        } else if (value == WEEKLY_RESTRICTION) {
            restriction.'type  = WEEKLYRESTRICTION;
        }
    }
    setTimeFromString(input[START_TIME_OF_DAY], restriction, STARTTIMEOFDAY);
    addInt(input[DURATION_IN_SEC], restriction, DURATIONINSEC);
    addInt(input[START_DAY_OF_WEEK], restriction, STARTDAYOFWEEK);
    return restriction;
}

function scheduleToPayload(Schedule schedule) returns @tainted map<json> {
    map<json> payload = {};
    int i = 0;
    payload[TYPE] = schedule[TYPE].toString();
    addStringToPayload(schedule[TIMEZONE], payload, TIME_ZONE);
    addStringToPayload(schedule[SUMMARY], payload, SUMMARY);
    addStringToPayload(schedule[URL], payload, SELF);
    addStringToPayload(schedule[DESCRIPTION], payload, DESCRIPTION);
    addStringToPayload(schedule[HTMLURL], payload, HTML_URL);
    addStringToPayload(schedule[NAME], payload, NAME);
    addStringToPayload(schedule[ID], payload, ID);
    var layers = schedule[SCHEDULELAYERS];
    i = 0;
    json[] list = [];
    while (i < layers.length()) {
        list[i] = scheduleLayerToPayload(layers[i]);
        i = i + 1;
    }
    payload[SCHEDULE_LAYERS] = list;
    var policies = schedule[ESCALATIONPOLICIES];
    if (policies is EscalationPolicy[]) {
        i = 0;
        json[] policyList = [];
        while (i < policies.length()) {
            policyList[i] = escalationPolicyToPayload(policies[i]);
            i = i + 1;
        }
        payload[ESCALATION_POLICIES] = policyList;
    }
    var finalSchedule = schedule[FINALSCHEDULE];
    if (finalSchedule is FinalSchedule) {
        payload[FINAL_SCHEDULE] = finalScheduleToPayload(finalSchedule);
    }
    var overideSchedule = schedule[OVERRIDESSCHEDULE];
    if (overideSchedule is FinalSchedule) {
        payload[OVERRIDES_SCHEDULE] = finalScheduleToPayload(overideSchedule);
    }
    addUsersToPayload(schedule[USERS], payload, USERS);
    commonsToPayload(schedule[TEAMS], payload, TEAMS);
    return payload;
}

function scheduleLayerToPayload(ScheduleLayer layer) returns map<json> {
    map<json> payload = {};
    int i = 0;
    addStringTime(layer[START], payload, START);
    addStringTime(layer[ROTATIONVIRTUALSTART], payload, ROTATION_VIRTUAL_START);
    addStringTime(layer[END], payload, END);
    addUsersToPayload(layer[USERS], payload, USERS);
    addStringToPayload(layer[NAME], payload, NAME);
    addStringToPayload(layer[ID], payload, ID);
    addIntToPayload(layer[RENDEREDCOVERAGEPERCENTAGE], payload, RENDERED_COVERAGE_PERCENTAGE);
    addIntToPayload(layer[ROTATIONTURNLENGTH], payload, ROTATION_TURN_LENGTH);
    json[] entryList = [];
    var entries = layer[RENDEREDSCHEDULEENTRIES];
    if (entries is RenderedScheduleEntry[]) {
        while (i < entries.length()) {
            entryList[i] = renderedScheduleToPayload(entries[i]);
            i = i + 1;
        }
        payload[RENDERED_SCHEDULE_ENTRIES] = entryList;
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

function finalScheduleToPayload(FinalSchedule input) returns map<json> {
    map<json> payload = {};
    string value = input[NAME].toString();
    if (value == "") {
        if (value == FINALSCHEDULE) {
            payload[NAME] = FINAL_SCHEDULE;
        } else if (value == OVERIDES) {
            payload[NAME] = OVERIDE;
        }
    }
    int i = 0;
    json[] list = [];
    RenderedScheduleEntry[]? schedules = input[RENDEREDSCHEDULEENTRIES];
    if (schedules is RenderedScheduleEntry[]) {
        while (i < schedules.length()) {
            list[i] = renderedScheduleToPayload(schedules[i]);
            i = i + 1;
        }
        payload[RENDERED_SCHEDULE_ENTRIES] = list;
    }
    addIntToPayload(input[RENDEREDCOVERAGEPERCENTAGE], payload, RENDERED_COVERAGE_PERCENTAGE);
    return payload;
}

function renderedScheduleToPayload(RenderedScheduleEntry entry) returns map<json> {
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
    if (value == DAILYRESTRICTION) {
        payload[TYPE] = DAILY_RESTRICTION;
    } else if (value == WEEKLYRESTRICTION) {
        payload[TYPE] = WEEKLY_RESTRICTION;
    }
    addStringTime(restriction[STARTTIMEOFDAY], payload, START_TIME_OF_DAY);
    addIntToPayload(restriction[DURATIONINSEC], payload, DURATION_IN_SEC);
    addIntToPayload(restriction[STARTDAYOFWEEK], payload, START_DAY_OF_WEEK);
    return payload;
}

# Converts `Service` data to `map<json>`
#
# + input - The escalation policies
# + return - The escalation policy as a `map<json>`
function serviceToPayload(Service input) returns @tainted map<json> {
    map<json> payload = {};
    var value = input[TYPE];
    if (value == SERVICEREFERENCE) {
        payload[TYPE] = SERVICE_REFERENCE;
    } else if (value == SERVICE) {
        payload[TYPE] = SERVICE;
    }
    addStringToPayload(input[ID], payload, ID);
    addStringToPayload(input[NAME], payload, NAME);
    addStringToPayload(input[STATUS], payload, STATUS);
    addStringToPayload(input[DESCRIPTION], payload, DESCRIPTION);
    addIntToPayload(input[AUTORESOLVETIMEOUT], payload, AUTO_RESOLVE_TIME_OUT);
    addIntToPayload(input[ACKNOWLEDGEMENTTIMEOUT], payload, ACKNOWLEDGEMENT_TIMEOUT);
    addStringTime(input[CREATEDAT], payload, CREATED_AT);
    addStringTime(input[TIMESTAMP], payload, TIME_STAMP);
    var policy = input[ESCALATIONPOLICY];
    payload[ESCALATION_POLICY] = escalationPolicyToPayload(input[ESCALATIONPOLICY]);
    var teams = input[TEAMS];
    if (teams is Common[]) {
        commonsToPayload(input[TEAMS], payload, TEAMS);
    }
    var integrations = input[INTEGRATIONS];
    if (integrations is Integration[]) {
       integrationsToPayload(integrations, payload, INTEGRATIONS);
    }
    var urgencyRule = input[INCIDENTURGENCYRULE];
    if (urgencyRule is IncidentUrgencyRule) {
        payload[INCIDENT_URGENCY_RULE] = incidentUrgencyRuleToPayload(urgencyRule);
    }
    var hours = input[SUPPORTHOURS];
    if (hours is SupportHour) {
        payload[SUPPORT_HOURS] = input[SUPPORTHOURS].toString();
    }
    int i = 0;
    json[] list = [];
    ScheduledAction[]? scheduledActions = input[SCHEDULEDACTIONS];
    if (scheduledActions is ScheduledAction[]) {
        while (i < scheduledActions.length()) {
            list[i] = scheduledActionToPayload(scheduledActions[i]);
            i = i + 1;
        }
        payload[SCHEDULED_ACTIONS] = list;
    }
    commonsToPayload(input[ADDONS], payload, ADDONS);
    string alertCreation = input[ALERTCREATION].toString();
    if (alertCreation != "") {
        if (value == CREATEINCIDENTS) {
            payload[ALERT_CREATION] = CREATE_INCIDENTS;
        } else {
            payload[ALERT_CREATION] = CREATE_ALERT_INCIDENTS;
        }
    }
    var group = input[ALERTGROUPING];
    if (group is Group) {
        payload[ALERT_GROUPING] = input[ALERTGROUPING].toString();
    }
    addIntToPayload(input[ALERTGROUPINGTIME], payload, ALERT_GROUPING_TIME);
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
    if (value == AWSCLOUD) {
        payload[TYPE] = AWS_CLOUD;
    } else if (value == AWSCLOUDREFERENCE) {
        payload[TYPE] = AWS_CLOUD_REFERENCE;
    } else if (value == CLOUDKICKREFERENCE) {
        payload[TYPE] = CLOUD_KICK_REFERENCE;
    } else if (value == EVENTTRANSFORMERAPIREFERENCE) {
        payload[TYPE] = EVENT_TRANSFORMER_API_REFERENCE;
    } else if (value == EMAILREFERENCE) {
        payload[TYPE] = EMAIL_REFERENCE;
    } else if (value == EVENTSAPIREFERENCE) {
        payload[TYPE] = EVENTS_API_REFERENCE;
    } else if (value == KEYNOTEREFERENCE) {
        payload[TYPE] = KEY_NOTE_REFERENCE;
    } else if (value == NAGIOSREFERENCE) {
        payload[TYPE] = NAGIOS_REFERENCE;
    } else if (value == PINGDOMREFERENCE) {
        payload[TYPE] = PINGDOM_REFERENCE;
    } else if (value == SQLMONITORREFERENCE) {
        payload[TYPE] = SQL_MONITOR_REFERENCE;
    } else if (value == SQLMONITOR) {
        payload[TYPE] = SQL_MONITOR;
    } else if (value == PINGDOMINTEGRATION) {
        payload[TYPE] = PINGDOM_INTEGRATION;
    } else if (value== NAGIOSINTEGRATION) {
        payload[TYPE] = NAGIOS_INTEGRATION;
    } else if (value == KEYNOTE) {
        payload[TYPE] = KEY_NOTE;
    } else if (value == EVENTSAPI) {
        payload[TYPE] = EVENTS_API;
    } else if (value == EMAILINBOUND) {
        payload[TYPE] = EMAIL_INBOUND;
    } else if (value == EVENTTRANSFORMERAPI) {
        payload[TYPE] = EVENT_TRANSFORMER_API;
    } else if (value == AWSCLOUD) {
        payload[TYPE] = AWS_CLOUD;
    } else if (value == EVENTAPIV2) {
        payload[TYPE] = EVENT_API_V2;
    }
    addStringToPayload(integration[ID], payload, ID);
    addStringToPayload(integration[SUMMARY], payload, SUMMARY);
    addStringToPayload(integration[URL], payload, SELF);
    addStringToPayload(integration[HTMLURL], payload, HTML_URL);
    addStringToPayload(integration[EMAIL], payload, INTEGRATION_EMAIL);
    addStringToPayload(integration[KEY], payload, INTEGRATION_KEY);
    var serv = integration[SERVICE];
    if (serv is Service) {
       payload[SERVICE] = serviceToPayload(serv);
    }
    addStringTime(integration[CREATEDAT], payload, CREATED_AT);
    var vendor = integration[VENDOR];
    if (vendor is Common) {
     payload[SERVICE] = commonToPayload(vendor);
    }
    return payload;
}

function incidentUrgencyRuleToPayload(IncidentUrgencyRule rule) returns map<json> {
    map<json> payload = {};
    string value = rule[TYPE].toString();
    if (value == CONSTANT) {
        payload[TYPE] = CONSTANT;
    } else if (value == USESUPPORTHOURS) {
        payload[TYPE] = USE_SUPPORT_HOURS;
    }
    addUrgencyToPayload(rule[URGENCY], payload, URGENCY);
    var hours = rule[DURINGSUPPORTHOURS];
    if (hours is IncidentSupportHour) {
        payload[DURING_SUPPORT_HOURS] = IncidentSupportHoursToPayload(hours);
    }
    var result = rule[OUTSIDESUPPORTHOURS];
    if (result is IncidentSupportHour) {
        payload[OUTSIDE_SUPPORT_HOURS] = IncidentSupportHoursToPayload(result);
    }
    return payload;
}

function IncidentSupportHoursToPayload(IncidentSupportHour supportHours) returns map<json> {
    map<json> payload = {};
    string value = supportHours[TYPE].toString();
    if (value == CONSTANT) {
        payload[TYPE] = CONSTANT;
    } else if (value == USESUPPORTHOURS) {
        payload[TYPE] = USE_SUPPORT_HOURS;
    }
    addUrgencyToPayload(supportHours[URGENCY], payload, URGENCY);
    return payload;
}

function supportHoursToPayload(SupportHour input) returns map<json> {
    map<json> payload = {};
    string value = input[TYPE].toString();
    if (value == FIXEDTIMEPERDAY) {
        payload[TYPE] = FIXED_TIME_PER_DAY;
    }
    addStringToPayload(input[TIMEZONE], payload, TIME_ZONE);
    addStringTime(input[STARTTIME], payload, START_TIME);
    addStringTime(input[ENDTIME], payload, END_TIME);
    return payload;
}

function scheduledActionToPayload(ScheduledAction scheduledAction) returns map<json> {
    map<json> payload = {};
    string value = scheduledAction[TYPE].toString();
    if (value == URGENCYCHANGE) {
        payload[TYPE] = URGENCY_CHANGE;
    }
    atToPayload(scheduledAction[AT], payload);
    addUrgencyToPayload(scheduledAction[URGENCY], payload, TO_URGENCY);
    return payload;
}

function atToPayload(At input, map<json> payload) {
    string value = input[TYPE].toString();
    if (value == NAMEDTIME) {
        payload[NAMEDTIME] = NAMED_TIME;
    }
    addNameToPayload(input[NAME], payload);
}

function convertToService(map<json> input, @tainted Service serv) {
     var time  = time:parse("00:00:00", "HH:mm:ss");
     var value = input[TYPE] ;
     if (value == SERVICE_REFERENCE) {
         serv[TYPE] = SERVICEREFERENCE;
     } else if (value == SERVICE) {
         serv[TYPE] = SERVICE;
     }
     addString(input[ID], serv, ID);
     addString(input[NAME], serv, NAME);
     addString(input[DESCRIPTION], serv, DESCRIPTION);
     addString(input[STATUS], serv, STATUS);
     addInt(input[AUTO_RESOLVE_TIME_OUT], serv, AUTORESOLVETIMEOUT);
     addInt(input[ACKNOWLEDGEMENT_TIMEOUT], serv, ACKNOWLEDGEMENTTIMEOUT);
     setTimeFromString(input[CREATED_AT], serv, CREATEDAT);
     setTimeFromString(input[TIME_STAMP], serv, TIMESTAMP);
     if (input[ESCALATION_POLICY].toString() != "") {
        EscalationPolicy escalationPolicy = { "type": "escalationPolicy", "name": "", "escalationRules": []};
        convertToEscalationPolicy(<map<json>>input[ESCALATION_POLICY], escalationPolicy);
        serv[ESCALATIONPOLICY] = escalationPolicy;
     }
     if (input[TEAMS].toString() != "") {
        serv[TEAMS] = convertToCommons(<map<json>>input, TEAMS);
     }
     if (input[INTEGRATIONS].toString() != "") {
         serv[INTEGRATIONS] = convertToIntegrations(input);
     }
     var urgencyRule = input[INCIDENT_URGENCY_RULE];
    if (urgencyRule.toString() != "") {
      serv[INCIDENTURGENCYRULE] = convertToIncidentUrgencyRule(<map<json>>urgencyRule);
    }
    var supportHour = input[SUPPORT_HOURS];
    if (supportHour.toString() != "") {
        serv[SUPPORTHOURS] = convertToSupportHour(<map<json>>supportHour);
    }
    if (input[SCHEDULED_ACTIONS].toString() != "") {
        serv[SCHEDULEDACTIONS] = convertToScheduledActions(input);
    }
    if (input[ADDONS].toString() != "") {
        serv[ADDONS] = convertToCommons(input, ADDONS);
    }
    string alertCreation = input[ALERT_CREATION].toString();
    if (alertCreation != "") {
        if (alertCreation == CREATE_INCIDENTS) {
            serv[ALERTCREATION] = CREATEINCIDENTS;
        } else {
            serv[ALERTCREATION] = CREATEALERTINCIDENTS;
        }
    }
    if (input[ALERT_GROUPING].toString() != "") {
        serv[ALERTGROUPING] = <Group>value;
    }
    addInt(input[ALERT_GROUPING_TIME], serv, ALERTGROUPINGTIME);
}

function convertToIntegrations(map<json> input) returns @tainted Integration[] {
    int i = 0;
    Integration[] integrations = [];
    json[] targetList = convertToJsonArray(input, INTEGRATION);
    while (i < targetList.length()) {
        Integration integration = {"type": EMAILREFERENCE, "summary": "Test"};
        convertToIntegration(<map<json>>targetList[i], integration);
        integrations[i] = integration;
        i = i + 1;
    }
    return integrations;
}

function convertToIntegration(map<json> input, @tainted Integration integration) {
    var value = input[TYPE];
    if (value == AWS_CLOUD) {
        integration[TYPE] = AWSCLOUD;
    } else if (value == AWS_CLOUD_REFERENCE) {
        integration[TYPE] = AWSCLOUDREFERENCE;
    } else if (value == CLOUD_KICK_REFERENCE) {
        integration[TYPE] = CLOUDKICKREFERENCE;
    } else if (value == EVENT_TRANSFORMER_API_REFERENCE) {
        integration[TYPE] = EVENTTRANSFORMERAPIREFERENCE;
    } else if (value == EMAIL_REFERENCE) {
        integration[TYPE] = EMAILREFERENCE;
    } else if (value == EVENTS_API_REFERENCE) {
        integration[TYPE] = EVENTSAPIREFERENCE;
    } else if (value == KEY_NOTE_REFERENCE) {
        integration[TYPE] = KEYNOTEREFERENCE;
    } else if (value == NAGIOS_REFERENCE) {
        integration[TYPE] = NAGIOSREFERENCE;
    } else if (value == PINGDOM_REFERENCE) {
        integration[TYPE] = PINGDOMREFERENCE;
    } else if (value == SQL_MONITOR_REFERENCE) {
        integration[TYPE] = SQLMONITORREFERENCE;
    } else if (value == SQL_MONITOR) {
        integration[TYPE] = SQLMONITOR;
    } else if (value == PINGDOM_INTEGRATION) {
        integration[TYPE] = PINGDOMINTEGRATION;
    } else if (value == NAGIOS_INTEGRATION) {
        integration[TYPE] = NAGIOSINTEGRATION;
    } else if (value == KEY_NOTE) {
        integration[TYPE] = KEYNOTE;
    } else if (value == EVENTS_API) {
        integration[TYPE] = EVENTSAPI;
    } else if (value == EMAIL_INBOUND) {
     integration[TYPE] = EMAILINBOUND;
    } else if (value == EVENT_TRANSFORMER_API) {
        integration[TYPE] = EVENTTRANSFORMERAPI;
    } else if (value == AWS_CLOUD) {
        integration[TYPE] = AWSCLOUD;
    } else if (value == EVENT_API_V2) {
        integration[TYPE] = EVENTAPIV2;
    }
    addString(input[ID], integration, ID);
    addString(input[INTEGRATION_EMAIL], integration, EMAIL);
    addString(input[INTEGRATION_KEY], integration, KEY);
    addString(input[SUMMARY], integration, SUMMARY);
    addString(input[SELF], integration, URL);
    addString(input[HTML_URL], integration, HTMLURL);
    var serv = input[SERVICE];
    if (input[SERVICE].toString() != "") {
        Service newService = {"name": "schedule", "escalationPolicy": { "type": "escalationPolicy",
              "name": "", "escalationRules": []}};
        convertToService(input, newService);
        integration[SERVICE] = newService;
    }
    setTimeFromString(input[CREATED_AT], integration, CREATEDAT);
    var vendor = input[VENDOR];
    if (vendor.toString() != "") {
        integration[VENDOR] = convertToCommon(vendor);
    }
}

function convertToCommons(map<json> input, string fieldName) returns Common[] {
    int i = 0;
    json[] targetList = convertToJsonArray(input, fieldName);
    Common[] commons = [];
    while (i < targetList.length()) {
        commons[i] = convertToCommon(targetList[i]);
        i = i + 1;
    }
    return commons;
}

function convertToIncidentUrgencyRule(map<json> input) returns IncidentUrgencyRule {
    IncidentUrgencyRule rule = {};
    string value = input[TYPE].toString();
    if (value == CONSTANT) {
        rule[TYPE] = CONSTANT;
    } else if (value == USE_SUPPORT_HOURS) {
        rule[TYPE] = USESUPPORTHOURS;
    }
    addUrgency(input[URGENCY], rule);
    var supportHours = input[DURING_SUPPORT_HOURS];
    if (input[DURING_SUPPORT_HOURS].toString() != "") {
        rule[DURINGSUPPORTHOURS] = convertToIncidentSupportHour(<map<json>>input[DURING_SUPPORT_HOURS]);
    }
    if (input[DURING_SUPPORT_HOURS].toString() != "") {
        rule[OUTSIDESUPPORTHOURS ] = convertToIncidentSupportHour(<map<json>>input[OUTSIDE_SUPPORT_HOURS]);
    }
    return rule;
}

function convertToIncidentSupportHour(map<json> input) returns IncidentSupportHour {
    IncidentSupportHour incidentSupportHour = {};
    string value = input[TYPE].toString();
    if (value == CONSTANT) {
        incidentSupportHour[TYPE] = CONSTANT;
    } else if (value == USE_SUPPORT_HOURS) {
        incidentSupportHour[TYPE] = USESUPPORTHOURS;
    }
    addUrgency(input[URGENCY], incidentSupportHour);
    return incidentSupportHour;
}

function convertToSupportHour(map<json> input) returns SupportHour {
    SupportHour hours = {};
    var time  = time:parse("00:00:00", "HH:mm:ss");
    string value = input[TYPE].toString();
    if (value == FIXED_TIME_PER_DAY) {
        hours[TYPE] = FIXEDTIMEPERDAY;
    }
    addString(input[TIME_ZONE], hours, TIMEZONE);
    var daysOfWeek = input[DAY_OF_WEEK];
    if (daysOfWeek != null) {
        addDaysOfWeek(daysOfWeek, hours);
    }
    setTimeFromString(input[START_TIME], hours, STARTTIME);
    setTimeFromString(input[END_TIME], hours, ENDTIME);
    return hours;
}

function addDaysOfWeek(json input, SupportHour hours)  {
    var days = json[].constructFrom(input);
    if (days is json[]) {
        int[] output = [];
        int i = 0;
        int length = days.length();
        while (i < length) {
            output[i] = <int>days[i];
            i = i + 1;
        }
        hours[DAYOFWEEK] = output;
    }
}

function convertToScheduledActions(map<json> input) returns ScheduledAction[] {
    int i = 0;
    ScheduledAction[] scheduledActions = [];
    json[] targetList = convertToJsonArray(input, SCHEDULED_ACTIONS);
    while (i < targetList.length()) {
        scheduledActions[i] = convertToScheduledAction(<map<json>>targetList[i]);
        i = i + 1;
    }
    return scheduledActions;
}

function convertToScheduledAction(map<json> input) returns ScheduledAction {
    ScheduledAction scheduledAction = {"type": URGENCYCHANGE, "at": {"type" : NAMEDTIME, "name": FINALSCHEDULE},
            "urgency": HIGH};
    string value = input[TYPE].toString();
    if (value == URGENCY_CHANGE) {
        scheduledAction[TYPE] = URGENCYCHANGE;
    }
    json at = input[AT];
    if (at != null) {
        scheduledAction[AT] = convertToAt(<map<json>>at);
    }
    addUrgency(input[TO_URGENCY], scheduledAction);
    return scheduledAction;
}

function convertToAt(map<json> input) returns At {
    At at = {"type" : NAMEDTIME, "name": FINALSCHEDULE};
    string value = input[TYPE].toString();
    if (value ==  NAMED_TIME) {
        at[TYPE] = NAMEDTIME;
    }
    addName(input[NAME], at);
    return at;
}

function convertToExtension(map<json> input, @tainted Extension extension) {
    string value = input[TYPE].toString();
    if (value == CONSTANT) {
        extension[TYPE] = CONSTANT;
    } else if (value == USE_SUPPORT_HOURS) {
        extension[TYPE] = USESUPPORTHOURS;
    }
    addString(input[NAME], extension, NAME);
    addString(input[ID], extension, ID);
    addString(input[ENDPOINT_URL], extension, ENDPOINTURL);
    addString(input[SELF], extension, URL);
    addString(input[HTML_URL], extension, HTMLURL);
    if (input[EXTENSION_OBJECTS].toString() != "") {
        extension[SERVICES] = convertToServices(input, EXTENSION_OBJECTS);
    }
    var extensionSchema = input[EXTENSION_SCHEMA];
    if (extensionSchema.toString() != "") {
        extension[EXTENSIONSCHEMA] = convertToCommon(<map<json>>extensionSchema);
    }
}

function convertToServices(map<json> payload, string fieldName) returns @tainted Service[] {
    Service[] services = [];
    json[] serviceList = convertToJsonArray(payload, fieldName);
    int i = 0;
    while (i < serviceList.length()) {
        Service newService = { "name": "service", "escalationPolicy": {"type": "sms", "id": "", "name": "",
        "escalationRules": []}};
        convertToService(<map<json>>serviceList[i], newService);
        services[i] = newService;
        i = i + 1;
    }
    return services;
}

function extensionToPayload(Extension extension) returns @tainted map<json> {
    map<json> payload = {};
    string value = "";
    value = extension[TYPE].toString();
    if (value == CONSTANT) {
        payload[TYPE] = CONSTANT;
    } else if (value == USE_SUPPORT_HOURS) {
        payload[TYPE] = USESUPPORTHOURS;
    }
    addStringToPayload(extension[NAME], payload, NAME);
    addStringToPayload(extension[ID], payload, ID);
    addStringToPayload(extension[SUMMARY], payload, SUMMARY);
    addStringToPayload(extension[ENDPOINTURL], payload, ENDPOINT_URL);
    addStringToPayload(extension[URL], payload, SELF);
    addStringToPayload(extension[HTMLURL], payload, HTML_URL);
    servicesToPayload(extension[SERVICES], payload, EXTENSION_OBJECTS);
    payload[EXTENSION_SCHEMA] = commonToPayload(extension[EXTENSIONSCHEMA]);
    return payload;
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

function incidentToPayload(Incident incident) returns @tainted map<json> {
    map<json> payload = {};
    var value  = incident[TYPE];
    if (value == INCIDENT) {
        payload[TYPE] = INCIDENT;
    } else if (value == INCIDENTREFERENCE) {
        payload[TYPE] = INCIDENT_REFERENCE;
    }
    addStringToPayload(incident[TITLE], payload, TITLE);
    addStringToPayload(incident[ID], payload, ID);
    addStringToPayload(incident[SUMMARY], payload, SUMMARY);
    addStringToPayload(incident[URL], payload, SELF);
    addStringToPayload(incident[INCIDENTKEY], payload, INCIDENT_KEY);
    addStringToPayload(incident[STATUS], payload, STATUS);
    addStringToPayload(incident[ASSIGNEDVIA], payload, ASSIGNED_VIA);
    addIntToPayload(incident[INCIDENTNUMBER], payload, INCIDENT_NUMBER);
    addStringToPayload(incident[HTMLURL], payload, HTML_URL);
    addStringToPayload(incident[RESOLUTION], payload, RESOLUTION);
    var policy = incident[ESCALATIONPOLICY];
    if (policy is EscalationPolicy) {
        payload[ESCALATION_POLICY] = escalationPolicyToPayload(policy);
    }
    map<json> conferenceBridge = {};
    addStringToPayload(incident[CONFERENCEURL], conferenceBridge, CONFERENCE_URL);
    addStringToPayload(incident[CONFERENCENUMBER], conferenceBridge, CONFERENCE_NUMBER);
    if (conferenceBridge.length() > 0) {
        payload[CONFERENCE_BRIDGE] = conferenceBridge;
    }
    map<json> alertCount = {};
    addIntToPayload(incident[TRIGERED_COUNT], alertCount, TRIGERED);
    addIntToPayload(incident[RESOLVED_COUNT], alertCount, RESOLVED);
    addIntToPayload(incident[ALL_COUNT], alertCount, ALL);
    var triggerCount  = incident[TRIGERED_COUNT];
    if (alertCount.length() > 0) {
        payload[ALERT_COUNTS] = alertCount;
    }
    var serv = incident[SERVICE];
    payload[SERVICE] = serviceToPayload(serv);
    commonsToPayload(incident[PRIORITY], payload, PRIORITY);
    var assignments  = incident[ASSIGNMENTS];
    if (assignments is Assignment[]) {
        assignmentsToPayload(assignments, payload, ASSIGNMENTS);
    }
    commonsToPayload(incident[LASTSTATUSCHANGEBY], payload, LAST_STATUS_CHANGE_BY);
    commonsToPayload(incident[FIRSTTRIGGERLOGENTRY], payload, FIRST_TRIGGER_LOG_ENTRY);
    commonsToPayload(incident[TEAMS], payload, TEAMS);
    var acknowledgements = incident[ACKNOWLEDGEMENTS];
    if (acknowledgements is Acknowledgement[]) {
        acknowledgementsToPayload(acknowledgements, payload, ACKNOWLEDGEMENTS);
    }
    var body = incident[BODY];
    if (body is Body) {
       payload[BODY] = <map<json>>body;
    }
    addUrgencyToPayload(incident[URGENCY], payload, URGENCY);
    return payload;
}

function assignmentsToPayload(Assignment[] assignments, map<json> payload, string fieldName) {
     int i = 0;
     json[] list = [];
     while (i < assignments.length()) {
         map<json> assign = {};
         Assignment assignment = assignments[i];
         var assignee = assignment[ASSIGNEE];
         if (assignee is User) {
            assign[ASSIGNEE] = userToPayload(assignee);
         }
         addStringTime(assignment[AT], assign, AT);
         list[i] = assign;
         i = i + 1;
     }
     payload[fieldName] = list;
}

function acknowledgementsToPayload(Acknowledgement[] acknowledgements, map<json> payload, string fieldName) {
     int i = 0;
     json[] list = [];
     map<json>  output = {};
     while (i < acknowledgements.length()) {
         Acknowledgement acknowledgement = acknowledgements[i];
         var value = acknowledgement[ACKNOWLEDGER];
         if (value is Common) {
            output[ACKNOWLEDGER] = commonToPayload(value);
         }
         addStringTime(acknowledgement[AT], output, AT);
         list[i] = output;
         i = i + 1;
     }
     payload[fieldName] = list;
}

function pendiingActionsToPayload(PendingAction[] pendiingActions, map<json> payload, string fieldName) {
     int i = 0;
     json[] list = [];
     map<json> output = {};
     while (i < pendiingActions.length()) {
         PendingAction pendingAction = pendiingActions[i];
         addStringTime(pendingAction[AT], output, AT);
         string value = pendingAction[TYPE].toString();
         if (value == URGENCYCHANGE) {
             output[TYPE] = URGENCY_CHANGE;
         } else {
              output[TYPE] = <Type>value;
         }
         list[i] = output;
         i = i + 1;
     }
     payload[fieldName] = list;
}

function convertToIncidents(map<json> input, @tainted Incident[] incidents) {
    int i = 0;
    json[] targetList = convertToJsonArray(input, INCIDENTS);
    while (i < targetList.length()) {
        Incident incident = { "type": "extension", "title": "", "service": {"name": "service",
                   "escalationPolicy": {"type": "sms", "id": "", "name": "", "escalationRules": []}}};
        convertToIncident(<map<json>>targetList[i], incident);
        incidents[i] = incident;
        i = i + 1;
    }
}

function convertToIncident(map<json> input, @tainted Incident incident) {
    string value = "";
    value = input[TYPE].toString();
    if (value == INCIDENT) {
        incident[TYPE] = INCIDENT;
    } else if (value == INCIDENTREFERENCE) {
        incident[TYPE] = INCIDENT_REFERENCE;
    }
    addString(input[TITLE], incident, TITLE);
    addString(input[ID], incident, ID);
    addString(input[SELF], incident, URL);
    addString(input[SUMMARY], incident, SUMMARY);
    addString(input[HTML_URL], incident, HTMLURL);
    addInt(input[INCIDENT_NUMBER], incident, INCIDENTNUMBER);
    addString(input[INCIDENT_KEY], incident, INCIDENTKEY);
    addString(input[STATUS], incident, STATUS);
    addString(input[ASSIGNED_VIA], incident, ASSIGNEDVIA);
    addString(input[RESOLUTION], incident, RESOLUTION);
    var policy = input[ESCALATION_POLICY];
    if (policy.toString() != "") {
        EscalationPolicy escalationPolicy = {"type": "sms", "id": "", "name": "", "escalationRules": []};
        convertToEscalationPolicy(<map<json>>policy, escalationPolicy);
        incident[ESCALATIONPOLICY] = escalationPolicy;
    }
    var bridge = input[CONFERENCE_BRIDGE];
    if (bridge.toString() != "") {
        map<json> conferenceBridge = <map<json>>bridge;
        addString(conferenceBridge[CONFERENCE_URL], incident, CONFERENCEURL);
        addString(conferenceBridge[CONFERENCE_NUMBER], incident, CONFERENCENUMBER);
    }
    map<json> alertCount = <map<json>>input[ALERT_COUNTS];
    addInt(alertCount[TRIGERED], incident, TRIGERED_COUNT);
    addInt(alertCount[RESOLVED], incident, RESOLVED_COUNT);
    addInt(alertCount[TRIGERED], incident, TRIGERED_COUNT);
    json serv = input[SERVICE];
    if (serv.toString() != "") {
        Service newService = { "name": "service", "escalationPolicy": {"type": "sms", "id": "", "name": "", "escalationRules": []}};
        convertToService(<map<json>>serv, newService);
        incident[SERVICE] = newService;
    }
    if (input[PRIORITY] != "") {
         incident[PRIORITY] = convertToCommons(input, PRIORITY);
    }
    if (input[ASSIGNMENTS] != "") {
        incident[ASSIGNMENTS] = convertToAssignments(input);
    }
    if (input[LAST_STATUS_CHANGE_BY] != "") {
         incident[LASTSTATUSCHANGEBY]  = convertToCommons(input, LAST_STATUS_CHANGE_BY);
    }
    if (input[FIRST_TRIGGER_LOG_ENTRY] != "") {
         incident[FIRSTTRIGGERLOGENTRY] = convertToCommons(input, FIRST_TRIGGER_LOG_ENTRY);
    }
    if (input[TEAMS].toString() != "") {
         incident[TEAMS] = convertToCommons(input, TEAMS);
    }
    if (input[ACKNOWLEDGEMENTS] != "") {
        incident[ACKNOWLEDGEMENTS] = convertToAcknowledgements(input);
    }
    json body = input[BODY];
    if (body.toString() != "") {
        var output = Body.constructFrom(body);
        if (output is Body) {
            incident[BODY] = output;
        }
    }
    addUrgency(input[URGENCY], incident);
}

function convertToAssignments(map<json> input) returns Assignment[] {
    int i = 0;
    Assignment[] assignments = [];
    json[] targetList = convertToJsonArray(input, ASSIGNMENTS);
    while (i < targetList.length()) {
        map<json> value = <map<json>>targetList[i];
        User user = {"type": "user", "name": "peter", "email": "ashacffe@gmail.com"};
        convertToUser(value[ASSIGNEE], user);
        assignments[i][ASSIGNEE] = user;
        var time = time:parse(value[AT].toString(), "yyyy-MM-dd'T'HH:mm:ss.SSSZ");
        if (time is time:Time) {
            assignments[i][AT] = time;
        }
        i = i + 1;
    }
    return assignments;
}

function convertToAcknowledgements(map<json> input) returns Acknowledgement[] {
    int i = 0;
    Acknowledgement[] acknowledgements = [];
    json[] targetList = convertToJsonArray(input, ACKNOWLEDGEMENTS);
    while (i < targetList.length()) {
        map<json> value = <map<json>>targetList[i];
        acknowledgements[i][ACKNOWLEDGER] = convertToCommon(value[ACKNOWLEDGER]);
        var time = time:parse(value[AT].toString(), "yyyy-MM-dd'T'HH:mm:ss.SSSZ");
        if (time is time:Time) {
            acknowledgements[i][AT] = time;
        }
        i = i + 1;
    }
    return acknowledgements;
}

function convertToPendiingActions(map<json> payload, string fieldName) returns PendingAction[] {
    int i = 0;
    PendingAction[] pendiingActions = [];
    json[] targetList = convertToJsonArray(payload, fieldName);
    while (i < targetList.length()) {
        map<json> result = <map<json>>targetList[i];
        string value = result[TYPE].toString();
        if (value == URGENCYCHANGE) {
            pendiingActions[i][TYPE] = URGENCY_CHANGE;
        } else {
            pendiingActions[i][TYPE] = <Type>value;
        }
        var time = time:parse(result[AT].toString(), "yyyy-MM-dd'T'HH:mm:ss.SSSZ");
        if (time is time:Time) {
            pendiingActions[i][AT] = time;
        }
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
    addStringTime(note[CREATEDAT], payload, CREATED_AT);
    var user = note[USER];
    if (user is Common) {
        payload[USER] =  commonToPayload(user);
    }
    return payload;
}

function convertToNote(map<json> input, Note note) {
    int i = 0;
    json[] list = [];
    addString(input[ID], note, ID);
    addString(input[CONTENT], note, CONTENT);
    setTimeFromString(input[CREATED_AT], note, CREATEDAT);
    var value = input[USER];
    if (value.toString() != "") {
        note[USER] =  convertToCommon(value);
    }
}

function addStringToPayload(string? input, map<json> payload, string key) {
    if (input is string) {
        payload[key] = input;
    }
}

function addString(json? input, Schedule|ScheduleLayer|Schedule|User|SupportHour|Extension|Service|Common|Note|
                   Incident|Integration|EscalationRule|EscalationPolicy|ContactMethod|NotificationRule  output,
                   string userKey) {
    string value = input.toString();
    if (value != "") {
       output[userKey] = value;
    }
}

function addStringTime(time:Time? value, map<json> payload, string key) {
    if (value is time:Time) {
       payload[key] = time:toString(value);
    }
}

function setTimeFromString(json? input, Schedule|RenderedScheduleEntry|ScheduleLayer|Restriction|Service|
                           SupportHour|Integration|Note output, string key) {
    string value = input.toString();
    if (value != "") {
        var time = time:parse(value.toString(), "yyyy-MM-dd'T'HH:mm:ss.SSSZ");
        if (time is time:Time) {
            output[key] = time;
        }
    }
}

function addIntToPayload(int? input, map<json> payload, string key) {
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

function addUrgencyToPayload(Urgency? urgency, map<json> payload, string key) {
    if (urgency is Urgency) {
        if (urgency == HIGH) {
            payload[key] = HIGH;
        } else if (urgency == LOW) {
            payload[key] = LOW;
        } else if (urgency == SUPPRESSED) {
            payload[key] = SUPPRESSED;
        } else {
            payload[key] = SEVERITY_BASED;
        }
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
        } else if (urgency == SEVERITY_BASED) {
            output[URGENCY] = SEVERITYBASED;
        }
    }
}

function addNameToPayload(Name? name, map<json> payload) {
    if (name is Name) {
        if (name == FINALSCHEDULE) {
            payload[NAME] = FINAL_SCHEDULE;
        } else if (name == SUPPORTHOURSSTART) {
            payload[NAME] = SUPPORT_HOURS_START;
        } else if (name == SUPPORTHOURSEND) {
            payload[NAME] = SUPPORT_HOURS_END;
        } else {
            payload[NAME] = SEVERITY_BASED;
        }
    }
}

function addName(json? name, At at) {
    if (name != ()) {
        if (name == FINAL_SCHEDULE) {
            at[NAME] = FINALSCHEDULE;
        } else if (name == SUPPORT_HOURS_START) {
            at[NAME] = SUPPORTHOURSSTART;
        } else if (name == SUPPORT_HOURS_END) {
            at[NAME] = SUPPORTHOURSEND;
        } else {
            at[NAME] = OVERIDE;
        }
    }
}

function incidentsToPayload(Incident[] incidents) returns @tainted json[] {
    int i = 0;
    json[] list = [];
    while (i < incidents.length()) {
        list[i] = incidentToPayload(incidents[i]);
        i = i + 1;
    }
    return list;
}
