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

import ballerina/oauth2;
import ballerina/http;
import ballerina/log;

# The `Account` used to initiate the contact with pagerDuty API and create the all sub clients.
#
# + pagerduty - The `Account` for the pagerduty
# + emailId - The email id for the logged in user
# + users - The `Users` client
# + escalationPolicies - The `EscalationPolicies` client
# + schedules - The `Schedules` client
# + extensions - The `Extensions` client
# + incidents - The `Incidents` client
public type Account object {

    private http:Client pagerduty;
    private Users users;
    private string emailId = "";
    private EscalationPolicies escalationPolicies;
    private Schedules schedules;
    private Services services;
    private Extensions extensions;
    private Incidents incidents;

    public function __init(Configuration config) {
        oauth2:OutboundOAuth2Provider oauth2Provider = new(config.oauth2Config);
        TokenAuthHandler oauth2Handler = new(oauth2Provider);
        http:ClientConfiguration accountConfig = {
            auth: {
                authHandler: oauth2Handler
            }
        };
        self.pagerduty = new(BASE_URL, config = accountConfig);
        self.users = new(self.pagerduty);
        self.escalationPolicies = new(self.pagerduty);
        self.schedules = new(self.pagerduty);
        self.services = new(self.pagerduty);
        self.extensions = new(self.pagerduty);
        self.incidents = new(self.pagerduty);

        string path = CURRENT_USER_PATH;
        json|Error resp = get(self.pagerduty, path);
        if (resp is json) {
            map<json> mapJsonRes = <map<json>> resp;
            map<json> user = <map<json>>mapJsonRes[USER];
            self.users.emailId = user[EMAIL].toString();
            self.escalationPolicies.emailId = user[EMAIL].toString();
            self.incidents.emailId = user[EMAIL].toString();
        } else {
            log:printError("Error occurred while getting the logged-in user email ID: " , resp);
        }
    }

    # Retrieves the `Users` client.
    # ```ballerina
    # Users users = pagerduty.getUsers();
    # ```
    #
    # + return - The `Users` client
    public function getUsers() returns Users {
        return self.users;
    }

    # Retrieves the `EscalationPolicies` client.
    # ```ballerina
    # EscalationPolicies escalations = pagerduty.getEscalationPolicies();
    # ```
    #
    # + return - The `EscalationPolicies` client
    public function getEscalationPolicies() returns EscalationPolicies {
        return self.escalationPolicies;
    }

    # Retrieve the `Schedules` client.
    # ```ballerina
    # Schedules schedules = pagerduty.getSchedules();
    # ```
    #
    # + return - The `Schedules` client
    public function getSchedules() returns Schedules {
        return self.schedules;
    }

    # Retrieves the `Services` client.
    # ```ballerina
    # Services services = pagerduty.getServices();
    # ```
    #
    # + return - The `Services` client
    public function getServices() returns Services {
        return self.services;
    }

    # Retrieves the `Extensions` client.
    # ```ballerina
    # Extensions extensions = pagerduty.getExtensions();
    # ```
    #
    # + return - The `Extensions` client
    public function getExtensions() returns Extensions {
        return self.extensions;
    }

    # Retrieves the `Incidents` client.
    # ```ballerina
    # Incidents incidents = pagerduty.getIncidents();
    # ```
    #
    # + return - The `Incidents` client
    public function getIncidents() returns Incidents {
        return self.incidents;
    }
};

# The `User` used to create/get the User, Contact method and Notification rule.
#
# + users - The `Users` client
# + emailId - The email id for the logged-in user
public type Users client object {

    private http:Client users;
    public string emailId = "";

    function __init(http:Client pagerDuty) {
        self.users = pagerDuty;
    }

    # Creates a new user.
    # ```ballerina
    # User user = {"type": "user", "name": "peter", "email": "kalai@gmail.com"};
    # pagerduty:Error? response = users->createUser(user);
    # ```
    #
    # + user -  The user which to be created
    # + return - A `pagerduty:Error` if any error occurred or else `nil`
    public remote function createUser(@tainted User user) returns @tainted Error? {
        string path = USERS_PATH;
        http:Request request = new;
        request.setHeader(FROM, self.emailId);
        setJsonPayload(map<json>.constructFrom(userToPayload(user)), request, USER);
        map<json>|Error resp = post(self.users, request, path);
        if (resp is Error) {
            return resp;
        } else {
            convertToUser(resp[USER], user);
        }
    }

    # Creates a new contact method for the User.
    # ```ballerina
    # ContactMethod contactMethod = {"type": "sms", "address": ""};
    # pagerduty:Error? response = users->createContactMethod(contactMethod);
    # ```
    #
    # + contactMethod -  The contact method to be created
    # + userId -  The ID of the user
    # + return - A `pagerduty:Error` if any error occurred or else `nil`
    public remote function createContactMethod(string userId, @tainted ContactMethod contactMethod)
                                               returns @tainted Error? {
        string path = USERS_PATH + BACK_SLASH + userId + BACK_SLASH + CONTACT_METHODS;
        http:Request request = new;
        setJsonPayload(map<json>.constructFrom(contactMethodToPayload(contactMethod)), request, CONTACT_METHOD);
        map<json>|Error resp = post(self.users, request, path);
        if (resp is Error) {
            return resp;
        } else {
            convertToContactMethod(resp[CONTACT_METHOD], contactMethod);
        }
    }

    # Creates a user notification rule.
    # ```ballerina
    # NotificationRule rule = {"startDelayInMinutes": 1,"contactMethod" : populatedContactMethod,"urgency": "high",
    #                          'type: "assignmentNotificationRule"};
    # pagerduty:Error? response = users->createNotificationRule(rule);
    # ```
    #
    # + rule -  The notification rule to be created.
    # + userId -  The ID of the user which to be added the notification rule
    # + return - A `pagerduty:Error` if any error  occurred or else `nil`
    public remote function createNotificationRule(string userId, @tainted NotificationRule rule)
                                                  returns @tainted Error? {
        string path = USERS_PATH + BACK_SLASH + userId + BACK_SLASH + NOTIFICATION_RULES;
        http:Request request = new;
        setJsonPayload(map<json>.constructFrom(notificationRuleToPayload(rule)), request, NOTIFICATION_RULE);
        map<json>|Error resp = post(self.users, request, path);
        if (resp is Error) {
            return resp;
        } else {
            convertToNotificationRule(resp[NOTIFICATION_RULE], rule);
        }
    }

    # Retrieves all contact methods for a given user.
    # ```ballerina
    # pagerduty:Error? response = users->getContactMethods(<USER_ID>);
    # ```
    #
    # + userId -  The ID of the user which to be added contact details
    # + return - The list of contact methods or else a `pagerduty:Error` if any error occurred
    public remote function getContactMethods(string userId) returns @tainted ContactMethod[]|Error {
        string path = USERS_PATH + BACK_SLASH + userId + BACK_SLASH + CONTACT_METHODS;
        json|Error jsonResponse = get(self.users, path);
        if (jsonResponse is Error) {
             return jsonResponse;
        } else {
             map<json> res = <map<json>>jsonResponse;
             return convertToContactMethods(res);
        }
    }

    # Retrieves all notification rules for a given user.
    # ```ballerina
    # pagerduty:Error? response = users->getUserNotificationRules(<USER_ID>);
    # ```
    #
    # + userId -  The ID of the user
    # + return - A list of notification rules or else a `pagerduty:Error` if any error occurred
    public remote function getUserNotificationRules(string userId) returns @tainted NotificationRule[]|Error {
        string path = USERS_PATH + BACK_SLASH + userId + BACK_SLASH + NOTIFICATION_RULES;
        json|Error jsonResponse = get(self.users, path);
        if (jsonResponse is Error) {
             return jsonResponse;
        } else {
             map<json> res = <map<json>>jsonResponse;
             return convertToNotificationRules(res);
        }
    }

    # Retrieves all users, optionally filtered by a query and teamIds.
    # ```ballerina
    # User[]|pagerduty:Error? response = users->getUsers();
    # ```
    #
    # + query - The string value(eg: “john” ,“asd@gmail.com” or “k”) which is used to filter the users whose names or
    #           email addresses match the query
    # + teamIds - The set of  value of team IDs as a `string`(eg: "P45PSCE,PC6BQII") which is used to filter the
    #             users whose related to these teams
    # + return - Users or else a `pagerduty:Error` if any error occured
    public remote function getUsers(string query = "", string? teamIds = ()) returns @tainted User[]|Error {
        string path = USERS_PATH;
        if (teamIds is string) {
            path = path + QUERY + query + TEAM_IDS + teamIds;
        } else {
            path = path + QUERY + query;
        }
        json|Error jsonResponse = get(self.users, path);
        if (jsonResponse is Error) {
            return jsonResponse;
        } else {
            map<json> res = <map<json>>jsonResponse;
            return convertToUsers(res);
        }
    }

    # Retrieves details about an given user.
    # ```ballerina
    # User|pagerduty:Error? response = users->getUserById(<USER_ID>);
    # ```
    #
    # + userId -  The ID of the user
    # + return - The user or else a `pagerduty:Error` if any error  occurred
    public remote function getUserById(string userId) returns @tainted User|Error {
        string path = USERS_PATH + BACK_SLASH + userId;
        json|Error jsonResponse = get(self.users, path);
        if (jsonResponse is Error) {
             return jsonResponse;
        } else {
             map<json> res = <map<json>>jsonResponse;
             User user = {'type: USER, name: "", email: ""};
             convertToUser(res[USER], user);
             return user;
        }
    }

    # Retrieves details about a given contact method id which is associated with the given uesr id.
    # ```ballerina
    # User|pagerduty:Error? response = users->getUserContactMethodById(<CONTACT_METHOD_ID>, <USER_ID>);
    # ```
    #
    # + contactMethodId -  The ID of the contact meyhod
    # + userId -  The ID of the user
    # + return - The contact method or else a `pagerduty:Error` if any error  occurred
    public remote function getUserContactMethodById(string contactMethodId, string userId) returns @tainted
                                                    ContactMethod|Error {
        string path = USERS_PATH + BACK_SLASH + userId + BACK_SLASH + CONTACT_METHODS + BACK_SLASH + contactMethodId;
        json|Error jsonResponse = get(self.users, path);
        if (jsonResponse is Error) {
             return jsonResponse;
        } else {
             map<json> res = <map<json>>jsonResponse;
             ContactMethod contactMethod = {'type: "sms", "address": ""};
             convertToContactMethod(res[CONTACT_METHOD], contactMethod);
             return contactMethod;
        }
    }

    # Retrieves notification rule about a given notification rule id which is associated with the given uesr id.
    # ```ballerina
    # NotificationRule|pagerduty:Error? response = users->getUserNotificationRuleById(<NOTIFICATION_RULE_ID>,
    #                                                                                 <USER_ID>);
    # ```
    #
    # + notificationRuleId -  The ID of the notification rule
    # + userId -  The ID of the user
    # + return - The notification rule or else a `pagerduty:Error` if any error  occurred
    public remote function getUserNotificationRuleById(string notificationRuleId, string userId) returns @tainted
                                                    NotificationRule|Error {
        string path = USERS_PATH + BACK_SLASH + userId + BACK_SLASH + NOTIFICATION_RULES + BACK_SLASH +
                      notificationRuleId;
        json|Error jsonResponse = get(self.users, path);
        if (jsonResponse is Error) {
             return jsonResponse;
        } else {
             NotificationRule rule = { "startDelayInMinutes": 1,"contactMethod": {"type": "sms","address": ""},
                                       "urgency": "high",'type: "assignmentNotificationRule"};
             convertToNotificationRule(<map<json>>jsonResponse, rule);
             return rule;
        }
    }

    # Removes an existing user
    # ```ballerina
    # NotificationRule|pagerduty:Error? response = users->deleteUser(<USER_ID>);
    # ```
    #
    # + userId -  The ID of the user
    # + return -  A `pagerduty:Error` if any error occurred or else `nil`
    public remote function deleteUser(string userId) returns @tainted Error? {
        string path = USERS_PATH + BACK_SLASH + userId;
        return delete(self.users, path);
    }

    # Removes a user's contact method
    # ```ballerina
    # NotificationRule|pagerduty:Error? response = users->deleteContactMethod(<CONTACT_METHOD_ID>, <USER_ID>);
    # ```
    #
    # + contactMethodId -  The ID of the contact meyhod
    # + userId -  The ID of the user
    # + return -  A `pagerduty:Error` if any error occurred or else `nil`
    public remote function deleteContactMethod(string contactMethodId, string userId) returns @tainted Error? {
        string path = USERS_PATH + BACK_SLASH + userId + BACK_SLASH + CONTACT_METHODS + BACK_SLASH + contactMethodId;
        return delete(self.users, path);
    }
    # Retrieves notification rule about a given notification rule id which is associated with the given uesr id.
    # ```ballerina
    # NotificationRule|pagerduty:Error? response = users->deleteNotificationRule(<NOTIFICATION_RULE_ID>, <USER_ID>);
    # ```
    #
    # + notificationRuleId -  The ID of the notification rule
    # + userId -  The ID of the user
    # + return -  A `pagerduty:Error` if any error occurred or else `nil`
    public remote function deleteNotificationRule(string notificationRuleId, string userId) returns @tainted Error? {
        string path = USERS_PATH + BACK_SLASH + userId + BACK_SLASH + NOTIFICATION_RULES + BACK_SLASH +
                                      notificationRuleId;
        return delete(self.users, path);
    }
};

# The `EscalationPolicies` used to create/get/update/delete the escalation policy.
#
# + escalationPolicies - The `EscalationPolicies` client
# + emailId - The email id for the logged-in user
public type EscalationPolicies client object {

    private http:Client escalationPolicies;
    public string emailId = "";

    function __init(http:Client pagerDuty) {
        self.escalationPolicies = pagerDuty;
    }

    # Creates a new escalation policy.
    # ```ballerina
    # EscalationPolicy escalationPolicy = { "type": "escalationPolicy", "name": "Test",
    #                                       "escalationRules": [{ "escalationDelayInMinutes": 30, "users": [
    #                                       {"type": "user", "name": "asha", "email": "asha@gmail.com"}]}]};
    # pagerduty:Error? response = escalations->createEscalationPolicy(<@untained> escalationPolicy);
    # ```
    #
    # + escalationPolicy - The escalation policy to be created.
    # + return - A `pagerduty:Error` if any error occurred or else `nil`
    public remote function createEscalationPolicy(@tainted EscalationPolicy escalationPolicy) returns @tainted Error? {
        string path = ESCALATION_POLICES_PATH;
        http:Request request = new;
        request.setHeader(FROM, self.emailId);
        setJsonPayload(<@untained> map<json>.constructFrom(escalationPolicyToPayload(escalationPolicy)), request,
                        ESCALATION_POLICY);
        map<json>|Error resp = post(self.escalationPolicies, request, path);
        if (resp is map<json>) {
            return convertToEscalationPolicy(<map<json>>resp[ESCALATION_POLICY], escalationPolicy);
        } else {
            return resp;
        }
    }

    # Gets informations about a given existing escalation policy and its rules.
    # ```ballerina
    # EscalationPolicy|pagerduty:Error? response = escalationPolicies->getEscalationPolicyById(<POLICY_ID>);
    # ```
    #
    # + escalationPolicyId -The escalation policy id which to be update
    # + return - The escalation policy or else a `pagerduty:Error` if any error
    #                  occurred
    public remote function getEscalationPolicyById(string escalationPolicyId) returns @tainted EscalationPolicy|Error {
        string path = ESCALATION_POLICES_PATH + BACK_SLASH + escalationPolicyId;
        map<json>|Error response = get(self.escalationPolicies, path);
        if (response is Error) {
            return response;
        } else {
            EscalationPolicy escalationPolicy = { "type": "escalationPolicy", "name": "", "escalationRules": []};
            Error? output = convertToEscalationPolicy(<map<json>>response[ESCALATION_POLICY], escalationPolicy);
            if (output is Error) {
                return  output;
            } else {
                return escalationPolicy;
            }
        }
    }

    # Updates an existing escalation policy and rules.
    # ```ballerina
    # pagerduty:Error? response = escalationPolicies->updateEscalationPolicy(<POLICY_ID>, <ESCALATION_POLICY>);
    # ```
    #
    # + escalationPolicyId -The escalation policy id which to be update
    # + escalationPolicy -The escalation policy details which to be update
    # + return - A `pagerduty:Error` if any error occurred or else `nil`
    public remote function updateEscalationPolicy(string escalationPolicyId, @tainted EscalationPolicy escalationPolicy)
                                                  returns @tainted Error? {
        string path = ESCALATION_POLICES_PATH + BACK_SLASH + escalationPolicyId;
        http:Request request = new;
        setJsonPayload(<@untained> map<json>.constructFrom(escalationPolicyToPayload(escalationPolicy)), request,
                                                           ESCALATION_POLICY);
        map<json>|Error resp = put(self.escalationPolicies, request, path);
        if (resp is map<json>) {
            return convertToEscalationPolicy(<map<json>>resp[ESCALATION_POLICY], escalationPolicy);
        } else {
            return resp;
        }
    }

    # Gets informations about a given existing escalation policy and its rules.
    # ```ballerina
    # EscalationPolicy|pagerduty:Error? response = escalationPolicies->getEscalationPolicyById(<POLICY_ID>);
    # ```
    #
    # + escalationPolicyId -The escalation policy id which to be update
    # + return - The escalation policy or else a `pagerduty:Error` if any error
    #                  occurred
    public remote function deleteEscalationPolicy(string escalationPolicyId) returns @tainted Error? {
        string path = ESCALATION_POLICES_PATH + BACK_SLASH + escalationPolicyId;
        return delete(self.escalationPolicies, path);
    }

};

# The `Schedules` used to create/get/delete the schedule.
#
# + schedules - The `Schedules` client
# + emailId - The email id for the logged-in user
public type Schedules client object {

    private http:Client schedules;
    public string emailId = "";

    function __init(http:Client pagerDuty) {
        self.schedules = pagerDuty;
    }

    # Creates a new on-call schedule.
    # ```ballerina
    # Schedule schedule = {"type": "schedule", "timeZone": "Asia/Colombo", "scheduleLayers": [{ "start": time,
    #                      "rotationTurnLengthInSeconds": 86400, "rotationVirtualStart": time,"users": [
    #                      {"type": "user", "name": "asha", "email": "asha@gmail.com"}]}]};
    # pagerduty:Error? response = schedules->createSchedule(schedule);
    # ```
    #
    # + schedule - The schedule which to be created
    # + overflow - Any on-call schedule entries that pass the date range bounds will be truncated at the bounds,
    #              unless the parameter overflow is passed. If pass to `false`, get one schedule entry returned with a
    #              start of `2020-05-16T10:00:00Z` and end of `2020-05-16T14:00:00Z`. If pass to `true`, get
    #              one schedule entry returned with a start of `2020-05-16T00:00:00Z` and end of `2020-05-17T00:00:00Z`.
    # + return -A `pagerduty:Error` if any error occurred or else `nil`
    public remote function createSchedule(@tainted Schedule schedule, boolean overflow = false) returns @tainted Error? {
        string path = SCHEDULE_PATH + OVERFLOW + overflow.toString();
        http:Request request = new;
        request.setHeader(FROM, self.emailId);
        setJsonPayload(<@untained> map<json>.constructFrom(scheduleToPayload(schedule)), request, SCHEDULE);
        map<json>|Error resp = post(self.schedules, request, path);
        if (resp is map<json>) {
            map<json> output = <map<json>>resp[SCHEDULE];
            return convertToSchedule(output, schedule);
        } else {
            return resp;
        }
    }

    # Retrives the all on-call schedules, optionally filtered by a query.
    # ```ballerina
    # Schedule[]|pagerduty:Error response = schedules->getSchedules();
    # ```
    #
    # + query - The string value (eg: "Schedule" , "s" or etc)  which is used to filter the schedules by name.
    # + return - The lsit of schedules or else a `pagerduty:Error` if any error occurred
    public remote function getSchedules(string query = "") returns @tainted Schedule[]|Error {
        string path = SCHEDULE_PATH + QUERY + query;
        json|Error jsonResponse = get(self.schedules, path);
        if (jsonResponse is Error) {
            return jsonResponse;
        } else {
            return convertToSchedules(<map<json>>jsonResponse);
        }
    }

    # Gets informations about a given existing escalation policy and its rules.
    # ```ballerina
    # EscalationPolicy|pagerduty:Error? response = escalationPolicies->getEscalationPolicyById(<POLICY_ID>);
    # ```
    #
    # + scheduleId - The schedule id which to be update
    # + return - The escalation policy or else a `pagerduty:Error` if any error
    #                  occurred
    public remote function getScheduleById(string scheduleId) returns @tainted Schedule|Error {
        string path = SCHEDULE_PATH + BACK_SLASH + scheduleId;
        map<json>|Error response = get(self.schedules, path);
        if (response is Error) {
            return response;
        } else {
            Schedule schedule = {"type": "schedule", "timeZone": "Asia/Colombo","scheduleLayers": []};
            Error? output =  convertToSchedule(<map<json>>response[SCHEDULE], schedule);
            if (output is Error) {
                return  output;
            } else {
                return schedule;
            }
        }
    }

    # Deletes an on-call schedule.
    # ```ballerina
    # pagerduty:Error? response = schedules->deleteSchedule(<SCHEDULE_ID>);
    # ```
    #
    # + scheduleId - The schedule id which to be update
    # + return - The lsit of schedules or else a `pagerduty:Error` if any error occurred
    public remote function deleteSchedule(string scheduleId) returns @tainted Error? {
        string path = SCHEDULE_PATH + BACK_SLASH + scheduleId;
        return delete(self.schedules, path);
    }
};

# The `Services` used to create/update|delete the services/integration.
#
# + services - The `Services` client
public type Services client object {

    private http:Client services;

    function __init(http:Client pagerduty) {
        self.services = pagerduty;
    }

    # Creates a new service.
    # ```ballerina
    # Service serv = { "name": "service", "escalationPolicy":{ "type": "escalationPolicy",
    #                  "name": "Test", "escalationRules": [{ "escalationDelayInMinutes": 30, "users": [
    #                  {"type": "user", "name": "asha", "email": "asha@gmail.com"}};
    # pagerduty:Error? response = services->createService(serv);
    # ```
    #
    # + serv - The service to be created
    # + return - A `pagerduty:Error` if any error occurred or else `nil`
    public remote function createService(@tainted Service serv) returns @tainted Error? {
       string path = SERVICES_PATH;
       http:Request request = new;
       setJsonPayload(<@untainted> map<json>.constructFrom(serviceToPayload(serv)), request, SERVICE);
       map<json>|Error resp = post(self.services, request, path);
       if (resp is map<json>) {
           convertToService(<map<json>>resp[SERVICE], serv);
       } else {
           return resp;
       }
    }

    # Creates a new integration belonging to a Service.
    # ```ballerina
    # Integration integration = { "type": "keynoteInboundIntegration", "email": "test@wso34.pagerduty.com"};
    # pagerduty:Error? response = services->createIntegration(serviceId, <@untained> integration);
    # ```
    #
    # + serviceId - The service id which to be created integration
    # + integration - The integration to be created
    # + return - A `pagerduty:Error` if any error occurred or else `nil`
    public remote function createIntegration(string serviceId, @tainted Integration integration)
                                             returns @tainted Error? {
        string path = SERVICES_PATH + BACK_SLASH + serviceId + BACK_SLASH + INTEGRATIONS;
        http:Request request = new;
        setJsonPayload(<@untainted> map<json>.constructFrom(integrationToPayload(integration)), request, INTEGRATION);
        map<json>|Error resp = post(self.services, request, path);
        if (resp is map<json>) {
          convertToIntegration(<map<json>>resp[INTEGRATION], integration);
        } else {
          return resp;
        }
    }

    # Updates an existing service.
    # ```ballerina
    # pagerduty:Error? response = services->updateIntegration(<INTEGRATION_ID>, <SERVICE_ID>, <UPDATE_SERVICE>);
    # ```
    #
    # + serviceId -The service id which to be update
    # + updateService -The service details which to be update
    # + return - A `pagerduty:Error` if any error occurred or else `nil`
    public remote function updateService(string serviceId, @tainted Service updateService) returns @tainted Error? {
        string path = SERVICES_PATH + BACK_SLASH + serviceId;
        http:Request request = new;
        setJsonPayload(<@untainted> map<json>.constructFrom(serviceToPayload(updateService)), request, SERVICE);
        map<json>|Error resp = put(self.services, request, path);
        if (resp is map<json>) {
          convertToService(<map<json>>resp[SERVICE], updateService);
        } else {
          return resp;
        }
    }

    # Updates an integration belonging to a Service.
    # ```ballerina
    # pagerduty:Error? response = services->updateIntegration(<INTEGRATION_ID>, <SERVICE_ID>, <UPDATE_INTEGRATION>);
    # ```
    #
    # + integrationId - The integration id which to be update
    # + serviceId - The service id which to be update
    # + integration - The integration details which to be update
    # + return - A `pagerduty:Error` if any error occurred or else `nil`
    public remote function updateIntegration(string integrationId, string serviceId, @tainted Integration integration)
                                             returns @tainted Error? {
       string path = SERVICES_PATH + BACK_SLASH + serviceId + BACK_SLASH + INTEGRATIONS + BACK_SLASH +
                     integrationId;
       http:Request request = new;
       setJsonPayload(<@untainted> map<json>.constructFrom(integrationToPayload(integration)), request, INTEGRATION);
       map<json>|Error resp = put(self.services, request, path);
       if (resp is map<json>) {
         convertToIntegration(<map<json>>resp[INTEGRATION], integration);
       } else {
         return resp;
       }
    }

    # Deletes an existing service.
    # ```ballerina
    # pagerduty:Error? response = services->deleteService(<SERVICE_ID>);
    # ```
    #
    # + serviceId -The service id which to be delete
    # + return - A `pagerduty:Error` if any error occurred or else `nil`
    public remote function deleteService(string serviceId) returns @tainted Error? {
        string path = SERVICES_PATH + BACK_SLASH + serviceId;
        return delete(self.services, path);
    }
};

# The `Extensions` used to create/get/update/delete the extension.
#
# + extensions - The `Extensions` client
public type Extensions client object {

    private http:Client extensions;

    function __init(http:Client pagerDuty) {
       self.extensions = pagerDuty;
    }

    # Creates a new Extension.
    # ```ballerina
    # Extension extension = {"type": "extension","name": "webhook","endpointUrl": "http://8bac231a.ngrok.io/webhooks",
    #                        "extensionSchema": {"id": "PJFWPEP","type": "extensionSchemaReference",
    #                        "summary": "Generic V2 Webhook"},"services": [populatedService]};
    # pagerduty:Error? response = extensions->createExtension(extension);
    # ```
    #
    # + extension -The extension to be created
    # + return - A `pagerduty:Error` if any error occurred or else `nil`
    public remote function createExtension(@tainted Extension extension) returns @tainted Error? {
        string path = EXTENSION_PATH;
        http:Request request = new;
        setJsonPayload(<@untainted> map<json>.constructFrom(extensionToPayload(extension)), request, EXTENSION);
        map<json>|Error resp = post(self.extensions, request, path);
        if (resp is map<json>) {
          map<json> output = <map<json>>resp[EXTENSION];
          return convertToExtension(output, extension);
        } else {
          return resp;
        }
    }

    # Updates an existing extension.
    # ```ballerina
    # pagerduty:Error? response = extensions->updateExtension(<EXTENSION_ID>, <UPDATE_EXTENSION>);
    # ```
    #
    # + extensionId -The extension id which to be update
    # + extension -The extension details which to be update
    # + return - A `pagerduty:Error` if any error occurred or else `nil`
    public remote function updateExtension(string extensionId, @tainted Extension extension) returns @tainted Error? {
        string path = EXTENSION_PATH + BACK_SLASH + extensionId;
        http:Request request = new;
        setJsonPayload(<@untainted> map<json>.constructFrom(extensionToPayload(extension)), request, EXTENSION);
        map<json>|Error resp = put(self.extensions, request, path);
        if (resp is map<json>) {
            map<json> output = <map<json>>resp[EXTENSION];
            return convertToExtension(output, extension);
        } else {
            return resp;
        }
    }

    # Gets details about any given existing extension.
    # ```ballerina
    # pagerduty:Error|Extension response = extensions->getExtensionById(<EXTENSION_ID>);
    # ```
    #
    # + extensionId -  The ID of the extension
    # + return - The extension or else a `pagerduty:Error` if any error  occurred
    public remote function getExtensionById(string extensionId) returns @tainted Extension|Error {
        string path = EXTENSION_PATH + BACK_SLASH + extensionId;
        json|Error jsonResponse = get(self.extensions, path);
        if (jsonResponse is Error) {
            return jsonResponse;
        } else {
            map<json> resp = <map<json>>jsonResponse;
            Extension extension = {"type": "extension", "name": "", "services": [], "extensionSchema":
            {"type": "extension", "id": ""}};
            convertToExtension(<map<json>>resp[EXTENSION], extension);
            return extension;
        }
    }

    # Deletes an existing extension.
    # ```ballerina
    # pagerduty:Error? response = extensions->deleteExtension(<EXTENSION_ID>);
    # ```
    #
    # + extensionId -  The ID of the extension which to be delete
    # + return - A `pagerduty:Error` if any error occurred or else `nil`
    public remote function deleteExtension(string extensionId) returns @tainted Error? {
        string path = EXTENSION_PATH + BACK_SLASH + extensionId;
        return delete(self.extensions, path);
    }
};

# The `Incidents` used to create/get/update/manage/delete/snooze the incidents and add note into that.
#
# + incidents - The `Incidents` client
# + emailId - The email id for the logged-in user
public type Incidents client object {

    private http:Client incidents;
    public string emailId = "";

    function __init(http:Client pagerDuty) {
       self.incidents = pagerDuty;
    }

    # Creates a new incident.
    # ```ballerina
    # Incident incident = {"type": "incident","title": "Test","service": { "name": "service",
    #                      "escalationPolicy":{ "type": "escalationPolicy",
    #                      "name": "Test", "escalationRules": [{ "escalationDelayInMinutes": 30, "users": [
    #                      {"type": "user", "name": "asha", "email": "asha@gmail.com"}};
    # pagerduty:Error? response = incidents->createIncident(<@untained> incident);
    # ```
    #
    # + incident - The incident to be created
    # + return - A `pagerduty:Error` if any error occurred or else `nil`
    public remote function createIncident(@tainted Incident incident) returns @tainted Error? {
        string path = INCIDENT_PATH;
        http:Request request = new;
        request.setHeader(FROM, self.emailId);
        setJsonPayload(<@untained> map<json>.constructFrom(incidentToPayload(incident)), request, INCIDENT);
        map<json>|Error resp = post(self.incidents, request, path);
        if (resp is map<json>) {
            return convertToIncident(<map<json>>resp[INCIDENT], incident);
        } else {
            return resp;
        }
    }

    # Retrieves an incident by the ID.
    # ```ballerina
    # Incident|pagerduty:Error? response = incidents->getIncidentById(<INCIDENT_ID>);
    # ```
    #
    # + incidentId - Either the id or number of the incident to retrieve
    # + return - The incident or else a `pagerduty:Error` if any error occurred
    public remote function getIncidentById(string incidentId) returns @tainted Incident|Error {
        string path = INCIDENT_PATH + BACK_SLASH + incidentId;
        map<json>|Error response = get(self.incidents, path);
        if (response is Error) {
           return response;
        } else {
           Incident incident = { "type": "extension", "title": "", "service": {"name": "service",
           "escalationPolicy": {"type": "sms", "id": "", "name": "", "escalationRules": []}}};
           convertToIncident(<map<json>>response[INCIDENT], incident);
           return incident;
        }
    }

    # Acknowledges, resolves, escalates or reassigns one or more incidents.
    # ```ballerina
    # Incident[]|pagerduty:Error? response = incidents->manageIncidents(<SET_OF_UPDATE_INCEDENTS>);
    # ```
    #
    # + incident - An array of incidents which including the parameters to update.
    # + return -  A list of Incident or else a `pagerduty:Error` if any error occurred
    public remote function manageIncidents(@tainted Incident[] incident) returns @tainted Incident[]|Error {
        string path = INCIDENT_PATH;
        http:Request request = new;
        request.setHeader(FROM, self.emailId);
        setJsonPayload(<@untainted> incidentsToPayload(incident), request, INCIDENTS);
        map<json>|Error resp = put(self.incidents, request, path);
        if (resp is map<json>) {
            Incident[] incidents = [];
            convertToIncidents(resp, incidents);
            return incidents;
        } else {
            return resp;
        }
    }

    # Updates an incident.
    # ```ballerina
    # pagerduty:Error? response = incidents->updateIncident(<UPDATE_INCIDENT>);
    # ```
    #
    # + incident - The Incident details which to be update
    # + incidentId - The id of the incident
    # + return - A `pagerduty:Error` if any error occurred or else `nil`
    public remote function updateIncident(string incidentId, @tainted Incident incident) returns @tainted Error? {
        string path = INCIDENT_PATH + BACK_SLASH + incidentId;
        http:Request request = new;
        request.setHeader(FROM, self.emailId);
        setJsonPayload(<@untained> map<json>.constructFrom(incidentToPayload(incident)), request, INCIDENT);
        map<json>|Error resp = put(self.incidents, request, path);
        if (resp is map<json>) {
            convertToIncident(<map<json>>resp[INCIDENT], incident);
        } else {
            return resp;
        }
    }

    # Creates a new note for the specified incident.
    # ```ballerina
    # Note note = {"content": "Firefighters are on the scene."};
    # pagerduty:Error? response = incidents->addNote(<INCIDENT_ID>, note);
    # ```
    #
    # + incidentId - The Incident id
    # + note - The note which to be created
    # + return - A `pagerduty:Error` if any error occurred or else `nil`
    public remote function addNote(string incidentId, @tainted Note note) returns @tainted Error? {
        string path = INCIDENT_PATH + BACK_SLASH + incidentId + BACK_SLASH + NOTES;
        http:Request request = new;
        request.setHeader(FROM, self.emailId);
        setJsonPayload(map<json>.constructFrom(noteToPayload(note)), request, NOTE);
        map<json>|Error resp = post(self.incidents, request, path);
        if (resp is map<json>) {
            return convertToNote(<map<json>>resp[NOTE], note);
        } else {
            return resp;
        }
    }

    # Snoozes an incident.
    # ```ballerina
    # Incident|pagerduty:Error? response = incidents->snoozeIncident(<INCIDENT_ID>, <DURATION>);
    # ```
    #
    # + incidentId - The Incident id
    # + durationInSeconds - The number of seconds to snooze the incident for
    # + return - A `pagerduty:Error` if any error occurred or else `nil`
    public remote function snoozeIncident(string incidentId, int durationInSeconds) returns @tainted Incident|Error {
        string path = INCIDENT_PATH + BACK_SLASH + incidentId + BACK_SLASH + SNOOZE;
        http:Request request = new;
        request.setHeader(FROM, self.emailId);
        request.setJsonPayload({"duration": durationInSeconds});
        map<json>|Error resp = post(self.incidents, request, path);
        if (resp is map<json>) {
            Incident incident = { "type": "extension", "title": "", "service": {"name": "service",
                       "escalationPolicy": {"type": "sms", "id": "", "name": "", "escalationRules": []}}};
            convertToIncident(<map<json>>resp[INCIDENT], incident);
            return incident;
        } else {
            return resp;
        }
    }
};
