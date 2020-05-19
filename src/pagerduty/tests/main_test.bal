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

import ballerina/test;
import ballerina/time;

Configuration pagerdutyConfig = {
    oauth2Config: {
        accessToken: "mL7WHpakjRZshG7qJiey"
    }
};

Account pagerduty = new(pagerdutyConfig);
Users users = pagerduty.getUsers();
EscalationPolicies escalations = pagerduty.getEscalationPolicies();
Schedules schedules = pagerduty.getSchedules();
Services services = pagerduty.getServices();
Extensions extensions = pagerduty.getExtensions();
Incidents incidents = pagerduty.getIncidents();

string userId = "";
string contactId = "";
string ruleId = "";
string policyId = "";
string serviceId = "";
string scheduleId = "";
string integrationId = "";
string incidentId = "";
string extensionId = "";
User populatedUser = {"type": "user", "name": "peter", "email": "ashacffedf@gmail.com"};
ContactMethod populatedContactMethod = {"type": "sms", "address": ""};
EscalationPolicy populatedEscalationPolicy = {"type": "sms", "id": "", "name": "", "escalationRules": []};
Service populatedService = { "name": "service", "escalationPolicy": populatedEscalationPolicy};
Integration populatedIntegration = { "type": "keynoteInboundIntegration"};
Incident populatedIncident = { "type": "extension", "title": "", "service": {"name": "service",
                              "escalationPolicy": {"type": "sms", "id": "", "name": "", "escalationRules": []}}};
Extension populatedExtension = {"type": "extension", "name": "", "services": [], "extensionSchema": {
    "type": "extension", "id": ""}};

@test:Config {}
function testCreateUser() {
    User user =  {"type": "user", "name": "peter", "email": "ashakalai@gmail.com"};
    var response = users->createUser(<@untained> user);
    if(response is error) {
        test:assertFail(msg = response.toString());
    } else {
        userId = <@untained> user.get("id").toString();
        populatedUser = <@untained> user;
        test:assertTrue(userId.length() > 0);
    }
}

@test:Config {
    dependsOn: ["testCreateUser"]
}
function testCreateContactMethod() {
    ContactMethod contactMethod = { "type": "sms","summary": "Home","label": "home","countryCode": 1,
                                    "address": "5766792895"};
    var response = users->createContactMethod(userId, <@untained> contactMethod);
    if (response is Error) {
        test:assertFail(msg = response.toString());
    } else {
        populatedContactMethod = <@untained> contactMethod;
        contactId = <@untained>  contactMethod.get("id").toString();
        test:assertTrue(contactId.length() > 0);
    }
}

@test:Config {
    dependsOn: ["testCreateContactMethod"]
}
function testCreateNotificationRule() {
    NotificationRule rule = { "startDelayInMinutes": 1,
                              "contactMethod" : populatedContactMethod,
                              "urgency": "high",
                              'type: "assignmentNotificationRule"};
    var response = users->createNotificationRule(userId, <@untained> rule);
    if (response is Error) {
        test:assertFail(msg = response.toString());
    } else {
        ruleId = <@untained> rule.get("id").toString();
        test:assertTrue(<@untained> ruleId.length() > 0);
    }
}

@test:Config {
    dependsOn: ["testCreateContactMethod"]
}
function testGetContactMethods() {
    var response = users->getContactMethods(userId);
    if (response is ContactMethod[]) {
        test:assertTrue(<@untained> response.length() > 1);
    } else {
        test:assertFail(msg = response.toString());
    }
}

@test:Config {
    dependsOn: ["testCreateContactMethod"]
}
function testGetUseNotificationRules() {
    var response = users->getUserNotificationRules(userId);
    if (response is NotificationRule[]) {
        test:assertTrue(<@untained> response.length() > 0);
    } else {
        test:assertFail(msg = response.toString());
    }
}

@test:Config {
    dependsOn: ["testCreateUser"]
}
function testGetUsers() {
    var response = users->getUsers();
    if (response is User[]) {
        test:assertTrue(<@untained> response.length() > 0);
    } else {
        test:assertFail(msg = response.toString());
    }
}

@test:Config {
    dependsOn: ["testCreateUser"]
}
function testGetUserById() {
    var response = users->getUserById(userId);
    if (response is User) {
        test:assertTrue(<@untained> response.length() > 0);
    } else {
        test:assertFail(msg = response.toString());
    }
}

@test:Config {
    dependsOn: ["testCreateContactMethod"]
}
function testGetContactMethodById() {
    var response = users->getUserContactMethodById(contactId, userId);
    if (response is Error) {
       test:assertFail(msg = response.toString());
    }
}

@test:Config {
    dependsOn: ["testGetUseNotificationRules"]
}
function testGetNotificationRuleById() {
    var response = users->getUserNotificationRuleById(ruleId, userId);
    if (response is Error) {
        test:assertFail(msg = response.toString());
    }
}

@test:Config {
    dependsOn: ["testGetUseNotificationRules"]
}
function testCreateEscalationPolicy() {
    EscalationPolicy escalationPolicy = { "type": "escalationPolicy",
                                           "name": "Escalation Policyeed for Test",
                                           "escalationRules": [{
                                                    "escalationDelayInMinutes": 30,
                                                    "targets": [{"id": userId, "type": "user"}]
                                           }]
                                        };
    var response = escalations->createEscalationPolicy(<@untained> escalationPolicy);
    if (response is Error) {
        test:assertFail(msg = response.toString());
    } else {
        policyId = <@untained> escalationPolicy.get("id").toString();
        populatedEscalationPolicy = <@untained> escalationPolicy;
        test:assertTrue(policyId.length() > 0);
    }
}

@test:Config {
    dependsOn: ["testCreateEscalationPolicy"]
}
function testGetEscalationPolicyById() {
    var response = escalations->getEscalationPolicyById(<@untained> policyId);
    if (response is EscalationPolicy) {
        test:assertEquals(response.name, populatedEscalationPolicy.name);
    } else {
        test:assertFail(msg = response.toString());
    }
}

@test:Config {
    dependsOn: ["testGetEscalationPolicyById"]
}
function testUpdateEscalationPolicy() {
    populatedEscalationPolicy.description = "Update escalateionee policy";
    populatedEscalationPolicy.name = "Updated escalationeee policy";
    EscalationPolicy input = populatedEscalationPolicy;
    var response = escalations->updateEscalationPolicy(policyId, <@untained> input);
    if (response is Error) {
       test:assertFail(msg = response.toString());
    }
}

@test:Config {
    dependsOn: ["testCreateUser"]
}
function testCreateSchedule() {
    time:Time time = time:currentTime();
    Schedule schedule = {"type": "schedule",
                         "timeZone": "Asia/Colombo",
                         "scheduleLayers": [
                             {
                                "start": time,
                                "rotationTurnLengthInSeconds": 86400,
                                "rotationVirtualStart": time,
                                 "users": [populatedUser]
                             }
                         ]};
    var response = schedules->createSchedule(<@untained> schedule);
    if (response is Error) {
       test:assertFail(msg = response.toString());
    } else {
        scheduleId = <@untained> schedule.get("id").toString();
    }
}

@test:Config {
    dependsOn: ["testCreateSchedule"]
}
function testGetSchedules() {
    var response = schedules->getSchedules();
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
    var response = schedules->getScheduleById(scheduleId);
    if (response is Error) {
        test:assertFail(msg = response.toString());
    }
}

@test:Config {
    dependsOn: ["testUpdateEscalationPolicy"]
}
function testCreateService() {
    Service serv = { "name": "New seeeervices",
                     "escalationPolicy":
                            populatedEscalationPolicy
                     };
    var response = services->createService(<@untained> serv);
    if (response is Error) {
        test:assertFail(msg = response.toString());
    } else {
        serviceId = <@untained> serv.get("id").toString();
        populatedService = <@untained> serv;
        test:assertTrue(serviceId.length() > 0);
    }
}

@test:Config {
    dependsOn: ["testCreateService"]
}
function testUpdateService() {
    populatedService.name ="Updated seeeervices";
    Service updateService = populatedService;
    var response = services->updateService(serviceId, <@untained> updateService);
    if (response is Error) {
        test:assertFail(msg = response.toString());
    }
}

@test:Config {
    dependsOn: ["testCreateService"]
}
function testCreateIntegration() {
    Integration integration = {
                   "type": "keynoteInboundIntegration",
                   "email": "test@wso34.pagerduty.com"
                 };
    var response = services->createIntegration(serviceId, <@untained> integration);
    if (response is Error) {
        test:assertFail(msg = response.toString());
    } else {
        integrationId = <@untained> integration.get("id").toString();
        populatedIntegration = <@untained> integration;
        test:assertTrue(integrationId.length() > 0);
    }
}

@test:Config {
    dependsOn: ["testCreateIntegration"]
}
function testUpdateIntegration() {
    populatedIntegration.email = "test4e1@wso34.pagerduty.com";
    Integration updateIntegration = populatedIntegration;
    var response = services->updateIntegration(integrationId, serviceId, <@untained> updateIntegration);
    if (response is Error) {
        test:assertFail(msg = response.toString());
    }
}

@test:Config {
    dependsOn: ["testCreateService"]
}
function testCreateExtension() {
    Service updateService = populatedService;
    Extension extension = {
                               "type": "extension",
                               "name": "webhook",
                               "endpointUrl": "http://8bac231a.ngrok.io/webhooks",
                               "extensionSchema": {
                                    "id": "PJFWPEP",
                                    "type": "extensionSchemaReference",
                                    "summary": "Generic V2 Webhook"
                               },
                               "services": [
                                    populatedService
                               ]
                            };
    var response = extensions->createExtension(<@untained> extension);
    if (response is Error) {
        test:assertFail(msg = response.toString());
    } else {
        extensionId = <@untained> extension.get("id").toString();
        populatedExtension = <@untained> extension;
        test:assertTrue(extensionId.length() > 0);
    }
}

@test:Config {
    dependsOn: ["testCreateExtension"]
}
function testUpdateExtension() {
    populatedExtension.name = "New Webhook";
    Extension updateExtension = populatedExtension;
    var response = extensions->updateExtension(extensionId, <@untained> updateExtension);
    if (response is Error) {
        test:assertFail(msg = response.toString());
    }
}

@test:Config {
    dependsOn: ["testCreateExtension"]
}
function testGetExtensionById() {
    var response = extensions->getExtensionById(extensionId);
    if (response is Error) {
        test:assertFail(msg = response.toString());
    }
}

@test:Config {
    dependsOn: ["testCreateService"]
}
function testCreateIncident() {
    Service updateService = populatedService;
    Incident incident = {
                          "type": "incident",
                          "title": "Test",
                          "service": updateService};
    var response = incidents->createIncident(<@untained> incident);
    if (response is Error) {
        test:assertFail(msg = response.toString());
    } else {
        incidentId = <@untained> incident.get("id").toString();
        populatedIncident = <@untained> incident;
        test:assertTrue(incidentId.length() > 0);
    }
}

@test:Config {
    dependsOn: ["testCreateIncident"]
}
function testGetIncidentById() {
    var response = incidents->getIncidentById(incidentId);
    if (response is Error) {
        test:assertFail(msg = response.toString());
    }
}

@test:Config {
     dependsOn: ["testCreateIncident"]
 }
 function testManageIncidents() {
     populatedIncident.status = "acknowledged";
     populatedIncident.assignments[1].assignee = populatedUser;
     Incident[] incident = [populatedIncident];
     var response = incidents->manageIncidents(incident);
     if (response is Error) {
         test:assertFail(msg = response.toString());
     }
 }

@test:Config {
  dependsOn: ["testCreateIncident"]
}
function testAddNote() {
    Note note = {"content": "Firefighters are on the scene."};
    var response = incidents->addNote(incidentId, <@untained> note);
    if (response is Error) {
        test:assertFail(msg = response.toString());
    }
}

 @test:Config {
     dependsOn: ["testManageIncidents"]
 }
 function testSnoozeIncident() {
     var response = incidents->snoozeIncident(incidentId, 3600);
     if (response is Error) {
         test:assertFail(msg = response.toString());
     }
 }

@test:Config {
    dependsOn: ["testSnoozeIncident"]
}
function testUpdateIncidents() {
    populatedIncident.status = "resolved";
    Incident incident = populatedIncident;
    var response = incidents->updateIncident(incidentId, incident);
    if (response is Error) {
        test:assertFail(msg = response.toString());
    }
}

@test:Config {
    dependsOn: ["testUpdateIncidents", "testCreateNotificationRule", "testGetUserById", "testGetContactMethodById",
                "testGetNotificationRuleById", "testGetUseNotificationRules"]
}
function tesDeleteNotificationRule() {
    var response = users->deleteNotificationRule(ruleId, userId);
    if (response is Error) {
        test:assertFail(msg = response.toString());
    }
}

@test:Config {
    dependsOn: ["testDeleteUser", "testUpdateIntegration"]
}
function testDeleteService() {
    var response = services->deleteService(serviceId);
    if (response is Error) {
        test:assertFail(msg = response.toString());
    }
}

@test:Config {
    dependsOn: ["testGetSchedules", "testCreateSchedule", "testGetScheduleById"]
}
function tesDeleteSchedule() {
    var response = schedules->deleteSchedule(scheduleId);
    if (response is Error) {
        test:assertFail(msg = response.toString());
    }
}

@test:Config {
    dependsOn: ["testGetExtensionById", "testUpdateExtension"]
}
function tesDeleteExtension() {
    var response = extensions->deleteExtension(extensionId);
    if (response is Error) {
        test:assertFail(msg = response.toString());
    }
}

@test:Config {
  dependsOn: ["testUpdateIncidents", "testCreateNotificationRule", "testGetUserById", "testGetContactMethodById",
                "testGetNotificationRuleById", "tesDeleteNotificationRule", "testGetContactMethods"]
}
function TestDeleteContactMethod() {
    var response = users->deleteContactMethod(contactId, userId);
    if (response is Error) {
        test:assertFail(msg = response.toString());
    }
}

@test:Config {
    dependsOn: ["testUpdateIncidents", "testCreateNotificationRule", "testGetUserById", "testGetContactMethodById",
                "testGetNotificationRuleById", "tesDeleteNotificationRule", "TestDeleteContactMethod",
                "testGetUseNotificationRules", "tesDeleteNotificationRule", "testCreateSchedule"]
}
function testDeleteUser() {
    var response = users->deleteUser(userId);
    if (response is Error) {
        test:assertFail(msg = response.toString());
    }
}

@test:Config {
    dependsOn: ["testDeleteService", "testUpdateService", "testUpdateExtension", "testCreateSchedule"]
}
function testDeleteEscalationPolicy() {
    var response = escalations->deleteEscalationPolicy(policyId);
    if (response is Error) {
        test:assertFail(msg = response.toString());
    }
}
