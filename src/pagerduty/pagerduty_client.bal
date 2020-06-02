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

# The `pagerduty:Account` is used to initiate the contact with the pagerDuty API and create all the sub clients.
# + pagerduty - The `Account` for PagerDuty
# + userClient - The `UserClient` client
# + escalationPolicyClient - The `EscalationPolicyClient` client
# + scheduleClient - The `ScheduleClient` client
# + extensionClient - The `ExtensionClient` client
# + incidentClient - The `IncidentClient` client
public type Account object {

    private http:Client pagerduty;
    private UserClient userClient;
    private EscalationPolicyClient escalationPolicyClient;
    private ScheduleClient scheduleClient;
    private ServiceClient serviceClient;
    private ExtensionClient extensionClient;
    private IncidentClient incidentClient;

    public function __init(string apiToken) {
        oauth2:OutboundOAuth2Provider oauth2Provider = new({accessToken: apiToken});
        TokenAuthHandler oauth2Handler = new(oauth2Provider);
        http:ClientConfiguration accountConfig = {
            auth: {
                authHandler: oauth2Handler
            }
        };
        self.pagerduty = new(BASE_URL, config = {auth: {authHandler: oauth2Handler}});

        // Sets the logged-in email ID to the `pagerDuty:UserClient`, `pagerDuty:EscalationPolicies`, and
        // `pagerDuty:Incidents` clients.
        string emailId = "";
        string path = CURRENT_USER_PATH;
        json|Error resp = get(self.pagerduty, path);
        if (resp is json) {
            map<json> mapJsonRes = <map<json>> resp;
            map<json> user = <map<json>>(mapJsonRes[USER].cloneReadOnly());
            emailId = user[EMAIL].toString();
        } else {
            log:printError("Error occurred while getting the logged-in user email ID" , resp);
        }

        self.userClient = new(self.pagerduty, emailId);
        self.escalationPolicyClient = new(self.pagerduty, emailId);
        self.scheduleClient = new(self.pagerduty);
        self.serviceClient = new(self.pagerduty);
        self.extensionClient = new(self.pagerduty);
        self.incidentClient = new(self.pagerduty, emailId);
    }

    # Retrieves the `pagerduty:UserClient`.
    # ```ballerina
    # pagerduty:UserClient userClient = pagerduty.getUserClient();
    # ```
    #
    # + return - The `pagerduty:UserClient`
    public function getUserClient() returns UserClient {
        return self.userClient;
    }

    # Retrieves the `pagerduty:EscalationPolicyClient`.
    # ```ballerina
    # pagerduty:EscalationPolicyClient escalationClient = pagerduty.getEscalationPolicyClient();
    # ```
    #
    # + return - The `pagerduty:EscalationPolicyClient`
    public function getEscalationPolicyClient() returns EscalationPolicyClient {
        return self.escalationPolicyClient;
    }

    # Retrieves the `pagerduty:ScheduleClient`.
    # ```ballerina
    # pagerduty:ScheduleClient scheduleClient = pagerduty.getScheduleClient();
    # ```
    #
    # + return - The `pagerduty:ScheduleClient`
    public function getScheduleClient() returns ScheduleClient {
        return self.scheduleClient;
    }

    # Retrieves the `pagerduty:ServiceClient`.
    # ```ballerina
    # pagerduty:ServiceClient serviceClient = pagerduty.getServiceClient();
    # ```
    #
    # + return - The `pagerduty:ServiceClient`
    public function getServiceClient() returns ServiceClient {
        return self.serviceClient;
    }

    # Retrieves the `pagerduty:ExtensionClient`.
    # ```ballerina
    # pagerduty:ExtensionClient extensionClient = pagerduty.getExtensionClient();
    # ```
    #
    # + return - The `pagerduty:ExtensionClient`
    public function getExtensionClient() returns ExtensionClient {
        return self.extensionClient;
    }

    # Retrieves the `pagerduty:IncidentClient`.
    # ```ballerina
    # pagerduty:IncidentClient incidentClient = pagerduty.getIncidentClient();
    # ```
    #
    # + return - The `pagerduty:IncidentClient`
    public function getIncidentClient() returns IncidentClient {
        return self.incidentClient;
    }
};

# The `pagerduty:UserClient` is used to create/get/delete the `User`/`Contact method`/ `Notification rule`.
#
# + userClient - The `pagerduty:UserClient`
# + emailId - The email ID of the logged-in user
public type UserClient client object {

    private http:Client userClient;
    private string emailId = "";

    function __init(http:Client pagerDuty, string emailId) {
        self.userClient = pagerDuty;
        self.emailId = emailId;
    }

    # Creates a new user.
    # ```ballerina
    # pagerduty:User user = {'type: "user", name: "", email: ""};
    # pagerduty:User|pagerduty:Error response = userClient->createUser(user);
    # ```
    #
    # + user - The user to be created
    # + return - A `pagerduty:User` or else a `pagerduty:Error` if any error occurred
    public remote function createUser(User user) returns User|Error {
        if (self.emailId == "") {
            return <@untainted> Error(message = "Can't access the `createUser` operation without " +
                                      "logged-in user email id", cause = getError());
        }
        return <@untainted> createUser(self.userClient, user, self.emailId);
    }

    # Creates a new contact method for the user.
    # ```ballerina
    # pagerduty:ContactMethod contactMethod = {'type: "sms", address: ""};
    # pagerduty:ContactMethod|pagerduty:Error response = userClient->createContactMethod(contactMethod);
    # ```
    #
    # + contactMethod - The contact method to be created
    # + userId -  The ID of the user
    # + return - A `pagerduty:ContactMethod` or else a `pagerduty:Error` if any error occurred
    public remote function createContactMethod(string userId, ContactMethod contactMethod)
                                               returns ContactMethod|Error {
        return <@untainted> createContactMethod(self.userClient, userId, contactMethod);
    }

    # Creates a user notification rule.
    # ```ballerina
    # pagerduty:NotificationRule rule = { startDelayInMinutes: 1, contactMethod: populatedContactMethod,
    #                                     urgency: "high", 'type: "assignmentNotificationRule"};
    # pagerduty:NotificationRule|pagerduty:Error response = userClient->createNotificationRule(rule);
    # ```
    #
    # + rule - The notification rule to be created
    # + userId - The ID of the user to be added to the notification rule
    # + return - A `pagerduty:NotificationRule` or else a `pagerduty:Error` if any error occurred
    public remote function createNotificationRule(string userId, NotificationRule rule) returns NotificationRule|Error {
        return <@untainted> createNotificationRule(self.userClient, userId, rule);
    }

    # Retrieves all contact methods for a given user.
    # ```ballerina
    # pagerduty:ContactMethod[]|pagerduty:Error response = userClient->getContactMethods(<USER_ID>);
    # ```
    #
    # + userId - The ID of the user to be added to the contact details
    # + return - The list of `pagerduty:ContactMethod`s or else a `pagerduty:Error` if any error occurred
    public remote function getContactMethods(string userId) returns ContactMethod[]|Error {
        return <@untainted> getContactMethods(self.userClient, userId);
    }

    # Retrieves all notification rules for a given user.
    # ```ballerina
    # pagerduty:NotificationRule[]:pagerduty:Error response = userClient->getUserNotificationRules(<USER_ID>);
    # ```
    #
    # + userId - The ID of the user
    # + return - A list of `pagerduty:NotificationRule`s or else a `pagerduty:Error` if any error occurred
    public remote function getUserNotificationRules(string userId) returns NotificationRule[]|Error {
        return <@untainted> getUserNotificationRules(self.userClient, userId);
    }

    # Retrieves all users who are filtered optionally by a query and `teamId`s.
    # ```ballerina
    # pagerduty:User[]|pagerduty:Error response = userClient->getUsers();
    # ```
    #
    # + query - The string value (e.g., “john” ,“asd@gmail.com” or “k”), which is used to filter the users whose
    #           names or email addresses match the query
    # + teamIds - The set of values of team IDs as a `string`(eg: "P45PSCE,PC6BQII"), which is used to filter the
    #             users who are related to these teams
    # + return - A set of `pagerduty:User`s or else a `pagerduty:Error` if any error occured
    public remote function getUsers(string query = "", public string? teamIds = ()) returns User[]|Error {
        return <@untainted> getUsers(self.userClient, query, teamIds);
    }

    # Retrieves the details about a given user.
    # ```ballerina
    # pagerduty:User|pagerduty:Error response = userClient->getUserById(<USER_ID>);
    # ```
    #
    # + userId - The ID of the user
    # + return - A `pagerduty:User` or else a `pagerduty:Error` if any error  occurred
    public remote function getUserById(string userId) returns User|Error {
        return <@untainted> getUserById(self.userClient, userId);
    }

    # Retrieves the details about a given contact method ID, which is associated with the given user ID.
    # ```ballerina
    # pagerduty:ContactMethod|pagerduty:Error response = userClient->getUserContactMethodById(<CONTACT_METHOD_ID>,
    #                                                                                         <USER_ID>);
    # ```
    #
    # + contactMethodId - The ID of the contact method
    # + userId - The ID of the user
    # + return - A `pagerduty:ContactMethod` or else a `pagerduty:Error` if any error  occurred
    public remote function getUserContactMethodById(string contactMethodId, string userId) returns ContactMethod|Error {
        return <@untainted> getUserContactMethodById(self.userClient, contactMethodId, userId);
    }

    # Retrieves the notification rule of a given notification rule ID, which is associated with the given user ID.
    # ```ballerina
    # pagerduty:NotificationRule|pagerduty:Error response = userClient->getUserNotificationRuleById(
    #                                                                            <NOTIFICATION_RULE_ID>, <USER_ID>);
    # ```
    #
    # + notificationRuleId - The ID of the notification rule
    # + userId - The ID of the user
    # + return - A `pagerduty:NotificationRule` or else a `pagerduty:Error` if any error  occurred
    public remote function getUserNotificationRuleById(string notificationRuleId, string userId) returns
                                                    NotificationRule|Error {
        return <@untainted> getUserNotificationRuleById(self.userClient, notificationRuleId, userId);
    }

    # Removes an existing user.
    # ```ballerina
    # pagerduty:Error? response = userClient->deleteUser(<USER_ID>);
    # ```
    #
    # + userId - The ID of the user
    # + return - A `pagerduty:Error` if any error occurred or else `()`
    public remote function deleteUser(string userId) returns Error? {
        string path = USERS_PATH + BACK_SLASH + userId;
        return <@untainted> delete(self.userClient, path);
    }

    # Removes an existing particular `ContactMethod` of the given user.
    # ```ballerina
    # pagerduty:Error? response = userClient->deleteContactMethod(<CONTACT_METHOD_ID>, <USER_ID>);
    # ```
    #
    # + contactMethodId -  The ID of the contact method
    # + userId - The ID of the user
    # + return - A `pagerduty:Error` if any error occurred or else `nil`
    public remote function deleteContactMethod(string contactMethodId, string userId) returns Error? {
        string path = USERS_PATH + BACK_SLASH + userId + BACK_SLASH + CONTACT_METHODS_VAR + BACK_SLASH +
                      contactMethodId;
        return <@untainted> delete(self.userClient, path);
    }

    # Removes an existing particular `NotificationRule` of the given user.
    # ```ballerina
    # pagerduty:Error? response = userClient->deleteNotificationRule(<NOTIFICATION_RULE_ID>, <USER_ID>);
    # ```
    #
    # + notificationRuleId - The ID of the notification rule
    # + userId - The ID of the user
    # + return - A `pagerduty:Error` if any error occurred or else `()`
    public remote function deleteNotificationRule(string notificationRuleId, string userId) returns Error? {
        string path = USERS_PATH + BACK_SLASH + userId + BACK_SLASH + NOTIFICATION_RULES_VAR + BACK_SLASH +
                                      notificationRuleId;
        return <@untainted> delete(self.userClient, path);
    }
};

# The `pagerduty:EscalationPolicyClient` is used to create/get/update/delete the escalation policy.
#
# + escalationPolicyClient - The `pagerduty:EscalationPolicyClient`
# + emailId - The email ID of the logged-in user
public type EscalationPolicyClient client object {

    private http:Client escalationPolicyClient;
    private string emailId = "";

    function __init(http:Client pagerDuty, string emailId) {
        self.escalationPolicyClient = pagerDuty;
        self.emailId = emailId;
    }

    # Creates a new escalation policy.
    # ```ballerina
    # pagerduty:EscalationPolicy escalationPolicy = { 'type: "escalationPolicy", name: "Test",
    #                                                  escalationRules: [{ "escalationDelayInMinutes": 30, users: [
    #                                                  {'type: "user", name: "asha", email: "asha@gmail.com"}]}]};
    # pagerduty:EscalationPolicy|pagerduty:Error response = escalationPolicyClient->create(escalationPolicy);
    # ```
    #
    # + escalationPolicy - The escalation policy to be created.
    # + return - A `pagerduty:EscalationPolicy` or else a `pagerduty:Error` if any error  occurred
    public remote function create(EscalationPolicy escalationPolicy) returns EscalationPolicy|Error {
        if (self.emailId == "") {
            return Error(message = "Can't access the `createEscalationPolicy` operation without logged-in user" +
                         " email id", cause = getError());
        }
        return <@untainted> createEscalationPolicy(self.escalationPolicyClient, escalationPolicy, self.emailId);
    }

    # Gets information about a given existing escalation policy and its rules.
    # ```ballerina
    # pagerduty:EscalationPolicy|pagerduty:Error response = escalationPolicyClient->getById(<POLICY_ID>);
    # ```
    #
    # + escalationPolicyId - The escalation policy ID to be updated
    # + return - A `pagerduty:EscalationPolicy` or else a `pagerduty:Error` if any error occurred
    public remote function getById(string escalationPolicyId) returns EscalationPolicy|Error {
        return <@untainted> getEscalationPolicyById(self.escalationPolicyClient, escalationPolicyId);
    }

    # Updates an existing escalation policy and its rules.
    # ```ballerina
    # pagerduty:EscalationPolicy|pagerduty:Error response = escalationPolicyClient->update(<POLICY_ID>,
    #                                                                                       <ESCALATION_POLICY>);
    # ```
    #
    # + escalationPolicyId - The escalation policy ID to be updated
    # + escalationPolicy - The escalation policy details to be updated
    # + return - A `pagerduty:EscalationPolicy` or else a `pagerduty:Error` if any error occurred
    public remote function update(string escalationPolicyId, EscalationPolicy escalationPolicy)
                                 returns EscalationPolicy|Error {
        return <@untainted> updateEscalationPolicy(self.escalationPolicyClient, escalationPolicyId, escalationPolicy);
    }

    # Removes an existing `EscalationPolicy`.
    # ```ballerina
    # pagerduty:Error? response = escalationPolicyClient->delete(<POLICY_ID>);
    # ```
    #
    # + escalationPolicyId - The escalation policy ID to be updated
    # + return - A `pagerduty:Error` if any error occurred or `()`
    public remote function delete(string escalationPolicyId) returns Error? {
        string path = ESCALATION_POLICES_PATH + BACK_SLASH + escalationPolicyId;
        return <@untainted> delete(self.escalationPolicyClient, path);
    }

};

# The `pagerduty:ScheduleClient`, which is used to create/get/delete the schedule.
#
# + scheduleClient - The `pagerduty:ScheduleClient`
public type ScheduleClient client object {

    private http:Client scheduleClient;

    function __init(http:Client pagerDuty) {
        self.scheduleClient = pagerDuty;
    }

    # Creates a new on-call schedule.
    # ```ballerina
    # pagerduty:Schedule schedule = { 'type: "schedule", timeZone: "Asia/Colombo", scheduleLayers: [{
    #                                 start: time, rotationTurnLengthInSeconds: 86400,
    #                                 rotationVirtualStart: time, users: [{'type: "user", name: "asha",
    #                                 email: "as@gmail.com"}]}]};
    #  pagerduty:Schedule|pagerduty:Error response = scheduleClient->create(schedule);
    # ```
    #
    # + schedule - The schedule to be created
    # + overflow - Any on-call schedule entries that pass the date range bounds will be truncated at the bounds
    #              unless the parameter overflow is passed. If `false` is passed, one schedule entry is returned with a
    #              start of `2020-05-16T10:00:00Z` and end of `2020-05-16T14:00:00Z`. If `true` is passed,
    #              one schedule entry is returned with a start of `2020-05-16T00:00:00Z` and end of
    #              `2020-05-17T00:00:00Z`.
    # + return - A `pagerduty:Schedule` or else a `pagerduty:Error` if any error occurred
    public remote function create(Schedule schedule, public boolean overflow = false) returns Schedule|Error {
        return <@untainted> createSchedule(self.scheduleClient, schedule, overflow);
    }

    # Retrieves all the on-call schedules, which are filtered optionally by a query.
    # ```ballerina
    # pagerduty:Schedule[]|pagerduty:Error response = scheduleClient->getAll();
    # ```
    #
    # + query - The string value (e.g., "Schedule" , "s" or etc.), which is used to filter the schedules by the name
    # + return - The lsit of `pagerduty:Schedule`s or else a `pagerduty:Error` if any error occurred
    public remote function getAll(string query = "") returns Schedule[]|Error {
        return <@untainted> getSchedules(self.scheduleClient, query);
    }

    # Gets the information about a given existing escalation policy and its rules.
    # ```ballerina
    # pagerduty:Schedule|pagerduty:Error response = escalationPolicies->getById(<POLICY_ID>);
    # ```
    #
    # + scheduleId - The schedule ID to be updated
    # + return - A `pagerduty:Schedule` or else a `pagerduty:Error` if any error occurred
    public remote function getById(string scheduleId) returns Schedule|Error {
        return <@untainted> getScheduleById(self.scheduleClient, scheduleId);
    }

    # Deletes an existing on-call schedule.
    # ```ballerina
    # pagerduty:Error? response = schedules->delete(<SCHEDULE_ID>);
    # ```
    #
    # + scheduleId - The schedule ID to be updated
    # + return - A `pagerduty:Error` if any error occurred or `()`
    public remote function delete(string scheduleId) returns Error? {
        string path = SCHEDULE_PATH + BACK_SLASH + scheduleId;
        return <@untainted> delete(self.scheduleClient, path);
    }
};

# The `pagerduty:ServiceClient` is used to create/update|delete the service/integration.
#
# + serviceClient - The `pagerduty:ServiceClient`
public type ServiceClient client object {

    private http:Client serviceClient;

    function __init(http:Client pagerduty) {
        self.serviceClient = pagerduty;
    }

    # Creates a new service.
    # ```ballerina
    # pagerduty:Service 'service = { name: "service", escalationPolicy:{ "type": "escalationPolicy",
    #                            name: "Test", escalationRules: [{ escalationDelayInMinutes: 30, users: [
    #                            {'type: "user", name: "asha", email: "as@gmail.com"}};
    # pagerduty:Service|pagerduty:Error response = serviceClient->createService('service);
    # ```
    #
    # + service - The service to be created
    # + return - A `pagerduty:Service` or else a `pagerduty:Error` if any error occurred
    public remote function createService(Service 'service) returns Service|Error {
       return <@untainted> createService(self.serviceClient, 'service);
    }

    # Creates a new integration belonging to a service.
    # ```ballerina
    # pagerduty:Integration integration = { 'type: "keynoteInboundIntegration", email: "test@wso34.pagerduty.com"};
    # agerduty:Integration|pagerduty:Error response = serviceClient->createIntegration(serviceId, integration);
    # ```
    #
    # + serviceId - The service ID to be created for the integration
    # + integration - The integration to be created
    # + return - A `pagerduty:Integration ` or else a `pagerduty:Error` if any error occurred
    public remote function createIntegration(string serviceId, Integration integration) returns Integration|Error {
       return <@untainted> createIntegration(self.serviceClient, serviceId, integration);
    }

    # Updates an existing service.
    # ```ballerina
    # pagerduty:Service|pagerduty:Error response = serviceClient->updateService(<SERVICE_ID>, <UPDATE_SERVICE>);
    # ```
    #
    # + serviceId - The service ID to be updated
    # + service - The service details to be updated
    # + return - A `pagerduty:Error` if any error occurred or else `()`
    public remote function updateService(string serviceId, Service 'service) returns Service|Error {
        return <@untainted> updateService(self.serviceClient, serviceId, 'service);
    }

    # Updates an integration belonging to a service.
    # ```ballerina
    # pagerduty:Integration|pagerduty:Error response = serviceClient->updateIntegration(<INTEGRATION_ID>, <SERVICE_ID>,
    #                                                                                   <UPDATE_INTEGRATION>);
    # ```
    #
    # + integrationId - The integration ID to be updated
    # + serviceId - The service ID to be updated
    # + integration - The integration details to be updated
    # + return - A `pagerduty:Error` if any error occurred or else `()`
    public remote function updateIntegration(string integrationId, string serviceId, Integration integration)
                                 returns Integration|Error {
        return <@untainted> updateIntegration(self.serviceClient, integrationId, serviceId, integration);
    }

    # Deletes an existing service.
    # ```ballerina
    # pagerduty:Error? response = services->deleteService(<SERVICE_ID>);
    # ```
    #
    # + serviceId - The service ID to be deleted
    # + return - A `pagerduty:Error` if any error occurred or else `()`
    public remote function deleteService(string serviceId) returns Error? {
        string path = SERVICES_PATH + BACK_SLASH + serviceId;
        return <@untainted> delete(self.serviceClient, path);
    }
};

# The `pagerduty:ExtensionClient` is used to create/get/update/delete the extension.
#
# + extensionClient - The `pagerduty:ExtensionClient`
public type ExtensionClient client object {

    private http:Client extensionClient;

    function __init(http:Client pagerDuty) {
       self.extensionClient = pagerDuty;
    }

    # Creates a new Extension.
    # ```ballerina
    # pagerduty:Extension extension = { 'type: "extension", name: "webhook",
    #                                   endpointUrl: "http://8bac231a.ngrok.io/webhooks",
    #                                   extensionSchema: {id: "PJFWPEP", 'type: "extensionSchemaReference",
    #                                   summary: "Generic V2 Webhook"}, 'services: [populatedService]};
    # pagerduty:Extension|pagerduty:Error response = extensionClient->create(extension);
    # ```
    #
    # + extension - The extension to be created
    # + return - A `pagerduty:Extension` or else a `pagerduty:Error` if any error occurred
    public remote function create(Extension extension) returns Extension|Error {
        return <@untainted> createExtension(self.extensionClient, extension);
    }

    # Updates an existing extension.
    # ```ballerina
    # pagerduty:Extension|pagerduty:Error response = extensionClient->update(<EXTENSION_ID>, <UPDATE_EXTENSION>);
    # ```
    #
    # + extensionId - The extension ID to be updated
    # + extension - The extension details to be updated
    # + return - A `pagerduty:Extension` or else a `pagerduty:Error` if any error occurred
    public remote function update(string extensionId, Extension extension) returns Extension|Error {
        return <@untainted> updateExtension(self.extensionClient, extensionId, extension);
    }

    # Gets the details about any given existing extension.
    # ```ballerina
    # pagerduty:Error|pagerduty:Extension response = extensionClient->getById(<EXTENSION_ID>);
    # ```
    #
    # + extensionId - The ID of the extension
    # + return - A `pagerduty:Extension` or else a `pagerduty:Error` if any error occurred
    public remote function getById(string extensionId) returns Extension|Error {
        return <@untainted> getExtensionById(self.extensionClient, extensionId);
    }

    # Deletes an existing extension.
    # ```ballerina
    # pagerduty:Error? response = extensionClient->delete(<EXTENSION_ID>);
    # ```
    #
    # + extensionId -  The ID of the extension to be deleted
    # + return - A `pagerduty:Error` if any error occurred or else `()`
    public remote function delete(string extensionId) returns Error? {
        string path = EXTENSION_PATH + BACK_SLASH + extensionId;
        return <@untainted> delete(self.extensionClient, path);
    }
};

# The `pagerduty:IncidentClient` is used to create/get/update/manage/delete/snooze the incidents and
# add a note into that.
#
# + incidentClient - The `pagerduty:IncidentClient` client
# + emailId - The email ID of the logged-in user
public type IncidentClient client object {

    private http:Client incidentClient;
    private string emailId = "";

    function __init(http:Client pagerDuty, string emailId) {
       self.incidentClient = pagerDuty;
       self.emailId = emailId;
    }

    # Creates a new incident.
    # ```ballerina
    # pagerduty:Incident incident = { 'type: "incident", title: "Test", service: { name: "service",
    #                                 escalationPolicy:{ 'type: "escalationPolicy",
    #                                 name: "Test", escalationRules: [{ escalationDelayInMinutes: 30, users: [
    #                                 { 'type: "user", name: "asha", email: "as@gmail.com"}};
    # pagerduty:Incident|pagerduty:Error response = incidentClient->createIncident(incident);
    # ```
    #
    # + incident - The incident to be created
    # + return - A `pagerduty:Incident` or else a `pagerduty:Error` if any error occurred
    public remote function createIncident(Incident incident) returns Incident|Error {
        if (self.emailId == "") {
            return <@untainted> Error(message = "Can't access the `createIncident` operation without logged-in" +
                                      " user email id", cause = getError());
        }
        return <@untainted> createIncident(self.incidentClient, incident, self.emailId);
    }

    # Retrieves an incident by the ID.
    # ```ballerina
    # pagerduty:Incident|pagerduty:Error response = incidentClient->getIncidentById(<INCIDENT_ID>);
    # ```
    #
    # + incidentId - Either the ID or number of the incident to be retrieved
    # + return - A `pagerduty:Incident` or else a `pagerduty:Error` if any error occurred
    public remote function getIncidentById(string incidentId) returns Incident|Error {
        return <@untainted> getIncidentById(self.incidentClient, incidentId);
    }

    # Acknowledges, resolves, escalates, or reassigns one or more incidents.
    # ```ballerina
    # UpdateIncident[] incidents = [{'type: "incidentReference", status: "acknowledged"}];
    # pagerduty:Incident[]|pagerduty:Error response = incidentClient->updateIncidents(incidents);
    # ```
    #
    # + incident - An array of incidents, which include the parameters to update
    # + return - A list of `pagerduty:Incident`s or else a `pagerduty:Error` if any error occurred
    public remote function updateIncidents(Incident[]|json[] incident) returns Incident[]|Error {
        if (self.emailId == "") {
            return <@untainted> Error(message = "Can't access the `updateIncidents` operation without logged-in " +
                                      "user email id", cause = getError());
        }
        return <@untainted> updateIncidents(self.incidentClient, incident, self.emailId);
    }

    # Updates an incident.
    # ```ballerina
    # UpdateIncident incident = {'type: "incidentReference", status: "acknowledged"};
    # pagerduty:Incident|pagerduty:Error response = incidentClient->updateIncident(<UPDATE_INCIDENT>, incident);
    # ```
    #
    # + incident - The incident details to be updated
    # + incidentId - The ID of the incident
    # + return - A `pagerduty:Incident` or else a `pagerduty:Error` if any error occurred
    public remote function updateIncident(string incidentId, Incident|json incident) returns Incident|Error {
        if (self.emailId == "") {
            return <@untainted> Error(message = "Can't access the `updateIncident` operation without " +
                                      "logged-in user email id", cause = getError());
        }
       return <@untainted> updateIncident(self.incidentClient, incidentId, incident, self.emailId);
    }

    # Creates a new note for the specified incident.
    # ```ballerina
    # pagerduty:Note note = {content: "Firefighters are on the scene."};
    # pagerduty:Note|pagerduty:Error response = incidentClient->addNote(<INCIDENT_ID>, note);
    # ```
    #
    # + incidentId - The incident ID
    # + note - The note to be created
    # + return - A `pagerduty:Note` or else a `pagerduty:Error` if any error occurred
    public remote function addNote(string incidentId, Note note) returns Note|Error {
        if (self.emailId == "") {
            return <@untainted> Error(message = "Can't access the `addNote` operation without logged-in user email id",
                                      cause = getError());
        }
        return <@untainted> addNote(self.incidentClient, incidentId, note, self.emailId);
    }

    # Snoozes a given incident at a certain time.
    # ```ballerina
    # pagerduty:Incident|pagerduty:Error response = incidentClient->snoozeIncident(<INCIDENT_ID>, <DURATION>);
    # ```
    #
    # + incidentId - The incident ID
    # + durationInSeconds - The amount of time in seconds to snooze the incident
    # + return - A `pagerduty:Incident` or else a `pagerduty:Error` if any error occurred
    public remote function snoozeIncident(string incidentId, int durationInSeconds) returns Incident|Error {
        if (self.emailId == "") {
            return <@untainted> Error(message = "Can't access the `snoozeIncident` operation without logged-in " +
                                      "user email id", cause = getError());
        }
        return <@untainted> snoozeIncident(self.incidentClient, incidentId, durationInSeconds, self.emailId);
    }
};
