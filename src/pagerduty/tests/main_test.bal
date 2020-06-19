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

import ballerina/config;
import ballerina/system;
import ballerina/test;
import ballerina/time;

string API_TOKEN = system:getEnv("PAGERDUTY_API_TOKEN") == "" ? config:getAsString("PAGERDUTY_API_TOKEN") :
                   system:getEnv("PAGERDUTY_API_TOKEN");
string subDomain = config:getAsString("SUB_DOMAIN") == "" ? "wqs23" : config:getAsString("SUB_DOMAIN");
Account pagerduty = new(API_TOKEN);
UserClient userClient = pagerduty.getUserClient();
EscalationPolicyClient escalationClient = pagerduty.getEscalationPolicyClient();
ScheduleClient scheduleClient = pagerduty.getScheduleClient();
ServiceClient serviceClient = pagerduty.getServiceClient();
ExtensionClient extensionClient = pagerduty.getExtensionClient();
IncidentClient incidentClient = pagerduty.getIncidentClient();

string userId = "";
string contactId = "";
string ruleId = "";
string policyId = "";
string serviceId = "";
string scheduleId = "";
string integrationId = "";
string incidentId = "";
string extensionId = "";
User createdUser = {'type: "user", name: "", email: "example@gmail.com"};
ContactMethod createdContactMethod = {'type: "sms", address: ""};
EscalationPolicy createdEscalationPolicy = {'type: "sms", id: "", name: "", escalationRules: []};
Service createdService = { name: "service", escalationPolicy: createdEscalationPolicy};
Integration createdIntegration = { 'type: "keynoteInboundIntegration"};
Incident createdIncident = { 'type: "extension", title: "", 'service: {name: "service",
                              escalationPolicy: {'type: "sms", id: "", name: "", escalationRules: []}}};
Extension createdExtension = { 'type: "extension", name: "", 'services: [], extensionSchema:
                               {'type: "extension", id: ""}};
@test:Config {}
function testCreateUser() {
    User user =  {'type: "user", name: "John", email: "ex@gmail.com"};
    var response = userClient->createUser(user);
    if(response is error) {
        test:assertFail(msg = response.toString());
    } else {
        userId = response.get("id").toString();
        createdUser = response;
    }
}

@test:Config {
    dependsOn: ["testCreateUser"]
}
function testCreateContactMethod() {
    ContactMethod contactMethod = { 'type: "sms", address: "5678906547"};
    var response = userClient->createContactMethod(userId, contactMethod);
    if (response is Error) {
        test:assertFail(msg = response.toString());
    } else {
        createdContactMethod = response;
        contactId = response.get("id").toString();
    }
}

@test:Config {
    dependsOn: ["testCreateContactMethod"]
}
function testCreateNotificationRule() {
    NotificationRule rule = { startDelayInMinutes: 1,
                              contactMethod : createdContactMethod,
                              urgency: "high",
                              'type: "assignmentNotificationRule"};
    var response = userClient->createNotificationRule(userId, rule);
    if (response is Error) {
        test:assertFail(msg = response.toString());
    } else {
        ruleId = response.get("id").toString();
    }
}

@test:Config {
    dependsOn: ["testCreateContactMethod"]
}
function testGetContactMethods() {
    var response = userClient->getContactMethods(userId);
    if (response is ContactMethod[]) {
        test:assertTrue(response.length() > 1);
    } else {
        test:assertFail(msg = response.toString());
    }
}

@test:Config {
    dependsOn: ["testCreateContactMethod"]
}
function testGetUserNotificationRules() {
    var response = userClient->getUserNotificationRules(userId);
    if (response is NotificationRule[]) {
        test:assertTrue(response.length() > 0);
    } else {
        test:assertFail(msg = response.toString());
    }
}

@test:Config {
    dependsOn: ["testCreateUser"]
}
function testGetUsers() {
    var response = userClient->getUsers();
    if (response is User[]) {
        test:assertTrue(response.length() > 0);
    } else {
        test:assertFail(msg = response.toString());
    }
}

@test:Config {
    dependsOn: ["testCreateUser"]
}
function testGetUserById() {
    var response = userClient->getUserById(userId);
    if (response is User) {
        test:assertTrue(response.length() > 0);
    } else {
        test:assertFail(msg = response.toString());
    }
}

@test:Config {
    dependsOn: ["testCreateContactMethod"]
}
function testGetContactMethodById() {
    var response = userClient->getUserContactMethodById(contactId, userId);
    if (response is Error) {
       test:assertFail(msg = response.toString());
    }
}

@test:Config {
    dependsOn: ["testGetUserNotificationRules"]
}
function testGetNotificationRuleById() {
    var response = userClient->getUserNotificationRuleById(ruleId, userId);
    if (response is Error) {
        test:assertFail(msg = response.toString());
    }
}

@test:Config {
    dependsOn: ["testGetUserNotificationRules"]
}
function testCreateEscalationPolicy() {
    EscalationPolicy escalationPolicy = { 'type: "escalationPolicy",
                                           name: "Escalation Policy for Test",
                                           escalationRules: [{
                                                    escalationDelayInMinutes: 30,
                                                    targets: [{id: userId, 'type: "user"}]
                                           }]
                                        };
    var response = escalationClient->create(escalationPolicy);
    if (response is Error) {
        test:assertFail(msg = response.toString());
    } else {
        policyId = response.get("id").toString();
        createdEscalationPolicy = response;
        test:assertTrue(policyId.length() > 0);
    }
}

@test:Config {
    dependsOn: ["testCreateEscalationPolicy"]
}
function testGetEscalationPolicyById() {
    var response = escalationClient->getById(policyId);
    if (response is Error) {
        test:assertFail(msg = response.toString());
    }
}

@test:Config {
    dependsOn: ["testGetEscalationPolicyById"]
}
function testUpdateEscalationPolicy() {
    createdEscalationPolicy.description = "Update escalation policy";
    createdEscalationPolicy.name = "Updated escalation policy";
    EscalationPolicy input = createdEscalationPolicy;
    var response = escalationClient->update(policyId, input);
    if (response is Error) {
       test:assertFail(msg = response.toString());
    }
}

@test:Config {
    dependsOn: ["testCreateUser"]
}
function testCreateSchedule() {
    time:Time time = time:currentTime();
    Schedule schedule = {'type: "schedule",
                         timeZone: "Asia/Colombo",
                         scheduleLayers: [
                             {
                                'start: time,
                                rotationTurnLengthInSeconds: 86400,
                                rotationVirtualStart: time,
                                users: [createdUser]
                             }
                         ]};
    var response = scheduleClient->create(schedule);
    if (response is Error) {
       test:assertFail(msg = response.toString());
    } else {
        scheduleId = response.get("id").toString();
    }
}

@test:Config {
    dependsOn: ["testCreateSchedule"]
}
function testGetSchedules() {
    var response = scheduleClient->getAll();
    if (response is Schedule[]) {
        test:assertTrue(response.length() > 0);
    } else {
        test:assertFail(msg = response.toString());
    }
}

@test:Config {
    dependsOn: ["testCreateSchedule"]
}
function testGetScheduleById() {
    var response = scheduleClient->getById(scheduleId);
    if (response is Error) {
        test:assertFail(msg = response.toString());
    }
}

@test:Config {
    dependsOn: ["testUpdateEscalationPolicy"]
}
function testCreateService() {
    time:Time time = time:currentTime();
    Service serv = { name: "New service",
                     escalationPolicy:
                            createdEscalationPolicy
                     };
    var response = serviceClient->createService(serv);
    if (response is Error) {
        test:assertFail(msg = response.toString());
    } else {
        serviceId = response.get("id").toString();
        createdService = response;
        test:assertTrue(serviceId.length() > 0);
    }
}

@test:Config {
    dependsOn: ["testCreateService"]
}
function testUpdateService() {
    createdService.name ="Updated services";
    Service updateService = createdService;
    var response = serviceClient->updateService(serviceId, updateService);
    if (response is Error) {
        test:assertFail(msg = response.toString());
    }
}

@test:Config {
    dependsOn: ["testCreateService"]
}
function testCreateIntegration() {
    Integration integration = {
                   'type: "keynoteInboundIntegration",
                   email: "email@" + subDomain + ".pagerduty.com"
                 };
    var response = serviceClient->createIntegration(serviceId, integration);
    if (response is Error) {
        test:assertFail(msg = response.toString());
    } else {
        integrationId = response.get("id").toString();
        createdIntegration = response;
    }
}

@test:Config {
    dependsOn: ["testCreateIntegration"]
}
function testUpdateIntegration() {
    createdIntegration.email = "updateemail@" + subDomain + ".pagerduty.com";
    Integration updateIntegration = createdIntegration;
    var response = serviceClient->updateIntegration(integrationId, serviceId, updateIntegration);
    if (response is Error) {
        test:assertFail(msg = response.toString());
    }
}

@test:Config {
    dependsOn: ["testCreateService"]
}
function testCreateExtension() {
    Service updateService = createdService;
    Extension extension = { 'type: "extension",
                             name: "webhook",
                             endpointUrl: "http://8bac231a.ngrok.io/webhooks",
                             extensionSchema: {
                                    id: "PJFWPEP",
                                    'type: "extensionSchemaReference",
                                    summary: "Generic V2 Webhook"
                             },
                             'services: [
                                    createdService
                             ]
                            };
    var response = extensionClient->create(extension);
    if (response is Error) {
        test:assertFail(msg = response.toString());
    } else {
        extensionId = response.get("id").toString();
        createdExtension = response;
        test:assertTrue(extensionId.length() > 0);
    }
}

@test:Config {
    dependsOn: ["testCreateExtension"]
}
function testUpdateExtension() {
    createdExtension.name = "New Webhook";
    Extension updateExtension = createdExtension;
    var response = extensionClient->update(extensionId, updateExtension);
    if (response is Error) {
        test:assertFail(msg = response.toString());
    }
}

@test:Config {
    dependsOn: ["testCreateExtension"]
}
function testGetExtensionById() {
    var response = extensionClient->getById(extensionId);
    if (response is Error) {
        test:assertFail(msg = response.toString());
    }
}

@test:Config {
    dependsOn: ["testCreateService"]
}
function testCreateIncident() {
    Service updateService = createdService;
    Incident incident = {
                          'type: "incident",
                          title: "Test",
                          'service: updateService};
    var response = incidentClient->createIncident(incident);
    if (response is Error) {
        test:assertFail(msg = response.toString());
    } else {
        incidentId = response.get("id").toString();
        createdIncident = response;
    }
}

@test:Config {
    dependsOn: ["testCreateIncident"]
}
function testGetIncidentById() {
    var response = incidentClient->getIncidentById(incidentId);
    if (response is Error) {
        test:assertFail(msg = response.toString());
    }
}

@test:Config {
     dependsOn: ["testCreateIncident"]
 }
 function testUpdateIncidents() {
     createdIncident.status = "acknowledged";
     createdIncident.assignments[1].assignee = createdUser;
     Incident[] incident = [createdIncident];
     var response = incidentClient->updateIncidents(incident);
     if (response is Error) {
         test:assertFail(msg = response.toString());
     }
 }

@test:Config {
  dependsOn: ["testCreateIncident"]
}
function testAddNote() {
    Note note = {"content": "Firefighters are on the scene."};
    var response = incidentClient->addNote(incidentId, note);
    if (response is Error) {
        test:assertFail(msg = response.toString());
    }
}

 @test:Config {
     dependsOn: ["testUpdateIncidents"]
 }
 function testSnoozeIncident() {
     var response = incidentClient->snoozeIncident(incidentId, 3600);
     if (response is Error) {
         test:assertFail(msg = response.toString());
     }
 }

@test:Config {
    dependsOn: ["testSnoozeIncident"]
}
function testUpdateIncident() {
    createdIncident.status = "resolved";
    Incident incident = createdIncident;
    var response = incidentClient->updateIncident(incidentId, incident);
    if (response is Error) {
        test:assertFail(msg = response.toString());
    }
}

@test:Config {
    dependsOn: ["testUpdateIncidents", "testCreateNotificationRule", "testGetUserById", "testGetContactMethodById",
                "testGetNotificationRuleById", "testGetUserNotificationRules"]
}
function tesDeleteNotificationRule() {
    var response = userClient->deleteNotificationRule(ruleId, userId);
    if (response is Error) {
        test:assertFail(msg = response.toString());
    }
}

@test:Config {
    dependsOn: ["testDeleteUser", "testUpdateIntegration"]
}
function testDeleteService() {
    var response = serviceClient->deleteService(serviceId);
    if (response is Error) {
        test:assertFail(msg = response.toString());
    }
}

@test:Config {
    dependsOn: ["testGetSchedules", "testCreateSchedule", "testGetScheduleById"]
}
function tesDeleteSchedule() {
    var response = scheduleClient->delete(scheduleId);
    if (response is Error) {
        test:assertFail(msg = response.toString());
    }
}

@test:Config {
    dependsOn: ["testGetExtensionById", "testUpdateExtension"]
}
function tesDeleteExtension() {
    var response = extensionClient->delete(extensionId);
    if (response is Error) {
        test:assertFail(msg = response.toString());
    }
}

@test:Config {
  dependsOn: ["testUpdateIncidents", "testCreateNotificationRule", "testGetUserById", "testGetContactMethodById",
                "testGetNotificationRuleById", "tesDeleteNotificationRule", "testGetContactMethods"]
}
function TestDeleteContactMethod() {
    var response = userClient->deleteContactMethod(contactId, userId);
    if (response is Error) {
        test:assertFail(msg = response.toString());
    }
}

@test:Config {
    dependsOn: ["testUpdateIncidents", "testCreateNotificationRule", "testGetUserById", "testGetContactMethodById",
                "testGetNotificationRuleById", "tesDeleteNotificationRule", "TestDeleteContactMethod",
                "testGetUserNotificationRules", "tesDeleteNotificationRule", "testCreateSchedule"]
}
function testDeleteUser() {
    var response = userClient->deleteUser(userId);
    if (response is Error) {
        test:assertFail(msg = response.toString());
    }
}

@test:Config {
    dependsOn: ["testDeleteService", "testUpdateService", "testUpdateExtension", "testCreateSchedule"]
}
function testDeleteEscalationPolicy() {
    var response = escalationClient->delete(policyId);
    if (response is Error) {
        test:assertFail(msg = response.toString());
    }
}
