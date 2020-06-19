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

import ballerina/http;

function createUser(http:Client userClient, User user, string emailId) returns User|Error {
    map<json>|error payload = <@untainted> userToPayload(user).cloneWithType(MapJson);
    if (payload is error) {
        return createTypeCastError(payload, user.toString());
    } else {
        string path = USERS_PATH;
        http:Request request = new;
        request.setHeader(FROM, emailId);
        setJsonPayload(payload, request, USER);
        map<json>|error resp = post(userClient, request, path);
        if (resp is error) {
            return <@untainted> createResError(resp);
        } else {
            return <@untainted> convertToUser(resp[USER]);
        }
    }
}

function createContactMethod(http:Client userClient, string userId, ContactMethod contactMethod)
                returns ContactMethod|Error {
    map<json>|error payload = contactMethodToPayload(contactMethod).cloneWithType(MapJson);
    if (payload is error) {
        return createTypeCastError(payload, contactMethod.toString());
    } else {
        string path = USERS_PATH + BACK_SLASH + userId + BACK_SLASH + CONTACT_METHODS_VAR;
        http:Request request = new;
        setJsonPayload(payload, request, CONTACT_METHOD_VAR);
        map<json>|error resp = post(userClient, request, path);
        if (resp is error) {
            return <@untainted> createResError(resp);
        } else {
            return <@untainted> convertToContactMethod(resp[CONTACT_METHOD_VAR]);
        }
    }
}

function createNotificationRule(http:Client userClient, string userId, NotificationRule rule)
                returns NotificationRule|Error {
    map<json>|error payload = notificationRuleToPayload(rule).cloneWithType(MapJson);
    if (payload is error) {
        return createTypeCastError(payload, rule.toString());
    } else {
        string path = USERS_PATH + BACK_SLASH + userId + BACK_SLASH + NOTIFICATION_RULES_VAR;
        http:Request request = new;
        setJsonPayload(payload, request, NOTIFICATION_RULE_VAR);
        map<json>|error resp = post(userClient, request, path);
        if (resp is error) {
            return <@untainted> createResError(resp);
        } else {
            return <@untainted> convertToNotificationRule(resp[NOTIFICATION_RULE_VAR]);
        }
    }
}

function getContactMethods(http:Client userClient, string userId) returns ContactMethod[]|Error {
    string path = USERS_PATH + BACK_SLASH + userId + BACK_SLASH + CONTACT_METHODS_VAR;
    json|error jsonResponse = get(userClient, path);
    if (jsonResponse is error) {
         return <@untainted> createResError(jsonResponse);
    } else {
         map<json> res = <map<json>>jsonResponse;
         return <@untainted> convertToContactMethods(res);
    }
}

function getUserNotificationRules(http:Client userClient, string userId) returns NotificationRule[]|Error {
    string path = USERS_PATH + BACK_SLASH + userId + BACK_SLASH + NOTIFICATION_RULES_VAR;
    json|error jsonResponse = get(userClient, path);
    if (jsonResponse is error) {
         return <@untainted> createResError(jsonResponse);
    } else {
         map<json> res = <map<json>>jsonResponse;
         return <@untainted> convertToNotificationRules(res);
    }
}

function getUsers(http:Client userClient, string query = "", string? teamIds = ()) returns User[]|Error {
    string path = USERS_PATH;
    if (teamIds is string) {
        path = path + QUERY + query + TEAM_IDS + teamIds;
    } else {
        path = path + QUERY + query;
    }
    json|error jsonResponse = get(userClient, path);
    if (jsonResponse is error) {
        return <@untainted> createResError(jsonResponse);
    } else {
        map<json> res = <map<json>>jsonResponse;
        return <@untainted> convertToUsers(res);
    }
}

function getUserById(http:Client userClient, string userId) returns User|Error {
    string path = USERS_PATH + BACK_SLASH + userId;
    json|error jsonResponse = get(userClient, path);
    if (jsonResponse is error) {
         return <@untainted> createResError(jsonResponse);
    } else {
         map<json> res = <map<json>>jsonResponse;
         return <@untainted> convertToUser(res[USER]);
    }
}function getUserContactMethodById(http:Client userClient, string contactMethodId, string userId)
                 returns ContactMethod|Error {
    string path = USERS_PATH + BACK_SLASH + userId + BACK_SLASH + CONTACT_METHODS_VAR + BACK_SLASH + contactMethodId;
    json|error jsonResponse = get(userClient, path);
    if (jsonResponse is error) {
         return <@untainted> createResError(jsonResponse);
    } else {
         map<json> res = <map<json>>jsonResponse;
         return <@untainted> convertToContactMethod(res[CONTACT_METHOD_VAR]);
    }
}

function getUserNotificationRuleById(http:Client userClient, string notificationRuleId, string userId)
                returns NotificationRule|Error {
    string path = USERS_PATH + BACK_SLASH + userId + BACK_SLASH + NOTIFICATION_RULES_VAR + BACK_SLASH +
                  notificationRuleId;
    json|error jsonResponse = get(userClient, path);
    if (jsonResponse is error) {
         return <@untainted> createResError(jsonResponse);
    } else {
         return <@untainted> convertToNotificationRule(<map<json>>jsonResponse);
    }
}

function createEscalationPolicy(http:Client escalationPolicyClient, EscalationPolicy escalationPolicy, string emailId)
               returns EscalationPolicy|Error {
    map<json>|error payload = <@untainted> escalationPolicyToPayload(escalationPolicy).cloneWithType(MapJson);
    if (payload is error) {
        return createTypeCastError(payload, escalationPolicy.toString());
    } else {
        string path = ESCALATION_POLICES_PATH;
        http:Request request = new;
        request.setHeader(FROM, emailId);
        setJsonPayload(payload, request, ESCALATION_POLICY_VAR);
        map<json>|error resp = post(escalationPolicyClient, request, path);
        if (resp is map<json>) {
            return <@untainted> convertToEscalationPolicy(<map<json>>resp[ESCALATION_POLICY_VAR]);
        } else {
            return <@untainted> createResError(resp);
        }
    }
}

function getEscalationPolicyById(http:Client escalationPolicyClient, string escalationPolicyId)
                returns EscalationPolicy|Error {
    string path = ESCALATION_POLICES_PATH + BACK_SLASH + escalationPolicyId;
    map<json>|error response = get(escalationPolicyClient, path);
    if (response is error) {
        return <@untainted> createResError(response);
    } else {
        return <@untainted> convertToEscalationPolicy(<map<json>>response[ESCALATION_POLICY_VAR]);
    }
}

function updateEscalationPolicy(http:Client escalationPolicyClient, string escalationPolicyId,
                                EscalationPolicy escalationPolicy) returns EscalationPolicy|Error {
    map<json>|error payload = <@untainted> escalationPolicyToPayload(escalationPolicy).cloneWithType(MapJson);
    if (payload is error) {
        return createTypeCastError(payload, escalationPolicy.toString());
    } else {
        string path = ESCALATION_POLICES_PATH + BACK_SLASH + escalationPolicyId;
        http:Request request = new;
        setJsonPayload(payload, request, ESCALATION_POLICY);
        map<json>|error resp = put(escalationPolicyClient, request, path);
        if (resp is map<json>) {
            return <@untainted> convertToEscalationPolicy(<map<json>>resp[ESCALATION_POLICY_VAR]);
        } else {
            return <@untainted> createResError(resp);
        }
    }
}

function createSchedule(http:Client scheduleClient, Schedule schedule, boolean overflow)
                returns Schedule|Error {
    map<json>|error payload = <@untainted> scheduleToPayload(schedule).cloneWithType(MapJson);
    if (payload is error) {
        return createTypeCastError(payload, schedule.toString());
    } else {
        string path = SCHEDULE_PATH + OVERFLOW + overflow.toString();
        http:Request request = new;
        setJsonPayload(payload, request, SCHEDULE);
        map<json>|error resp = post(scheduleClient, request, path);
        if (resp is map<json>) {
            map<json> output = <map<json>>resp[SCHEDULE];
            return <@untainted> convertToSchedule(output);
        } else {
            return <@untainted> createResError(resp);
        }
    }
}

function getSchedules(http:Client scheduleClient, string query) returns Schedule[]|Error {
    string path = SCHEDULE_PATH + QUERY + query;
    json|error jsonResponse = get(scheduleClient, path);
    if (jsonResponse is error) {
        return <@untainted> createResError(jsonResponse);
    } else {
        return <@untainted> convertToSchedules(<map<json>>jsonResponse);
    }
}

function getScheduleById(http:Client scheduleClient, string scheduleId) returns Schedule|Error {
    string path = SCHEDULE_PATH + BACK_SLASH + scheduleId;
    map<json>|error response = get(scheduleClient, path);
    if (response is error) {
        return <@untainted> createResError(response);
    } else {
        return <@untainted> convertToSchedule(<map<json>>response[SCHEDULE]);
    }
}

function createService(http:Client serviceClient, Service serv) returns Service|Error {
    map<json>|error payload = <@untainted> serviceToPayload(serv).cloneWithType(MapJson);
    if (payload is error) {
        return createTypeCastError(payload, serv.toString());
    } else {
        string path = SERVICES_PATH;
        http:Request request = new;
        setJsonPayload(payload, request, SERVICE);
        map<json>|error resp = post(serviceClient, request, path);
        if (resp is map<json>) {
            return <@untainted> convertToService(<map<json>>resp[SERVICE]);
        } else {
            return <@untainted> createResError(resp);
        }
    }
}

function createIntegration(http:Client serviceClient, string serviceId, Integration integration)
                returns Integration|Error {
    map<json>|error payload = <@untainted> integrationToPayload(integration).cloneWithType(MapJson);
    if (payload is error) {
        return createTypeCastError(payload, integration.toString());
    } else {
        string path = SERVICES_PATH + BACK_SLASH + serviceId + BACK_SLASH + INTEGRATIONS;
        http:Request request = new;
        setJsonPayload(payload, request, INTEGRATION);
        map<json>|error resp = post(serviceClient, request, path);
        if (resp is map<json>) {
            return <@untainted> convertToIntegration(<map<json>>resp[INTEGRATION]);
        } else {
            return <@untainted> createResError(resp);
        }
    }
}

function updateService(http:Client serviceClient, string serviceId, Service updateService) returns Service|Error {
    map<json>|error payload = <@untainted> serviceToPayload(updateService).cloneWithType(MapJson);
    if (payload is error) {
        return createTypeCastError(payload, updateService.toString());
    } else {
        string path = SERVICES_PATH + BACK_SLASH + serviceId;
        http:Request request = new;
        setJsonPayload(payload, request, SERVICE);
        map<json>|error resp = put(serviceClient, request, path);
        if (resp is map<json>) {
            return <@untainted> convertToService(<map<json>>resp[SERVICE]);
        } else {
            return <@untainted> createResError(resp);
        }
    }
}

function updateIntegration(http:Client serviceClient,string integrationId, string serviceId, Integration integration)
               returns Integration|Error {
    map<json>|error payload =<@untainted> integrationToPayload(integration).cloneWithType(MapJson);
    if (payload is error) {
        return createTypeCastError(payload, integration.toString());
    } else {
        string path = SERVICES_PATH + BACK_SLASH + serviceId + BACK_SLASH + INTEGRATIONS + BACK_SLASH +
                             integrationId;
        http:Request request = new;
        setJsonPayload(payload, request, INTEGRATION);
        map<json>|error resp = put(serviceClient, request, path);
        if (resp is map<json>) {
            return <@untainted> convertToIntegration(<map<json>>resp[INTEGRATION]);
        } else {
            return <@untainted> createResError(resp);
        }
    }
}

function createExtension(http:Client extensionClient, Extension extension) returns Extension|Error {
    map<json>|error payload = <@untainted> extensionToPayload(extension).cloneWithType(MapJson);
    if (payload is error) {
        return createTypeCastError(payload, extension.toString());
    } else {
        string path = EXTENSION_PATH;
        http:Request request = new;
        setJsonPayload(payload, request, EXTENSION);
        map<json>|error resp = post(extensionClient, request, path);
        if (resp is map<json>) {
            map<json> output = <map<json>>resp[EXTENSION];
            return <@untainted> convertToExtension(output);
        } else {
            return <@untainted> createResError(resp);
        }
    }
}

function updateExtension(http:Client extensionClient,string extensionId, Extension extension)
               returns Extension|Error {
    map<json>|error payload = <@untainted> extensionToPayload(extension).cloneWithType(MapJson);
    if (payload is error) {
        return createTypeCastError(payload, extension.toString());
    } else {
        string path = EXTENSION_PATH + BACK_SLASH + extensionId;
        http:Request request = new;
        setJsonPayload(payload, request, EXTENSION);
        map<json>|error resp = put(extensionClient, request, path);
        if (resp is map<json>) {
            map<json> output = <map<json>>resp[EXTENSION];
            return <@untainted> convertToExtension(output);
        } else {
            return <@untainted> createResError(resp);
        }
    }
}

function getExtensionById(http:Client extensionClient, string extensionId) returns Extension|Error {
    string path = EXTENSION_PATH + BACK_SLASH + extensionId;
    json|error jsonResponse = get(extensionClient, path);
    if (jsonResponse is error) {
        return <@untainted> createResError(jsonResponse);
    } else {
        map<json> resp = <map<json>>jsonResponse;
        return <@untainted> convertToExtension(<map<json>>resp[EXTENSION]);
    }
}

function createIncident(http:Client incidentClient, Incident incident, string emailId) returns Incident|Error {
    map<json>|error payload = <@untainted> incidentToPayload(incident).cloneWithType(MapJson);
    if (payload is error) {
        return createTypeCastError(payload, incident.toString());
    } else {
        string path = INCIDENT_PATH;
        http:Request request = new;
        request.setHeader(FROM, emailId);
        setJsonPayload(payload, request, INCIDENT);
        map<json>|error resp = post(incidentClient, request, path);
        if (resp is map<json>) {
            return <@untainted> convertToIncident(<map<json>>resp[INCIDENT]);
        } else {
            return <@untainted> createResError(resp);
        }
    }
}

function getIncidentById(http:Client incidentClient, string incidentId) returns Incident|Error {
    string path = INCIDENT_PATH + BACK_SLASH + incidentId;
    map<json>|error resp = get(incidentClient, path);
    if (resp is error) {
       return <@untainted> createResError(resp);
    } else {
       return <@untainted> convertToIncident(<map<json>>resp[INCIDENT]);
    }
}

function updateIncidents(http:Client incidentClient, Incident[]|json[] incident, string emailId)
               returns Incident[]|Error {
    string path = INCIDENT_PATH;
    http:Request request = new;
    request.setHeader(FROM, emailId);
    setJsonPayload(<@untainted> incidentsToPayload(incident), request, INCIDENTS);
    map<json>|error resp = put(incidentClient, request, path);
    if (resp is map<json>) {
        return <@untainted> convertToIncidents(resp, INCIDENTS);
    } else {
        return <@untainted> createResError(resp);
    }
}

function updateIncident(http:Client incidentClient, string incidentId, Incident|json incident, string emailId)
               returns Incident|Error {
    map<json>|error payload = <@untainted> incidentToPayload(incident).cloneWithType(MapJson);
    if (payload is error) {
        return createTypeCastError(payload, incident.toString());
    } else {
        string path = INCIDENT_PATH + BACK_SLASH + incidentId;
        http:Request request = new;
        request.setHeader(FROM, emailId);
        setJsonPayload(payload, request, INCIDENT);
        map<json>|error resp = put(incidentClient, request, path);
        if (resp is map<json>) {
            return <@untainted> convertToIncident(<map<json>>resp[INCIDENT]);
        } else {
            return <@untainted> createResError(resp);
        }
    }
}

function addNote(http:Client incidentClient, string incidentId, Note note, string emailId) returns Note|Error {
    map<json>|error payload = <@untainted> noteToPayload(note).cloneWithType(MapJson);
    if (payload is error) {
        return createTypeCastError(payload, note.toString());
    } else {
        string path = INCIDENT_PATH + BACK_SLASH + incidentId + BACK_SLASH + NOTES;
        http:Request request = new;
        request.setHeader(FROM, emailId);
        setJsonPayload(payload, request, NOTE);
        map<json>|error resp = post(incidentClient, request, path);
        if (resp is map<json>) {
            return <@untainted> convertToNote(<map<json>>resp[NOTE]);
        } else {
            return <@untainted> createResError(resp);
        }
    }
}

function snoozeIncident(http:Client incidentClient, string incidentId, int durationInSeconds, string emailId)
               returns Incident|Error {
    string path = INCIDENT_PATH + BACK_SLASH + incidentId + BACK_SLASH + SNOOZE;
    http:Request request = new;
    request.setHeader(FROM, emailId);
    request.setJsonPayload({"duration": durationInSeconds});
    map<json>|error resp = post(incidentClient, request, path);
    if (resp is map<json>) {
        return <@untainted> convertToIncident(<map<json>>resp[INCIDENT]);
    } else {
        return <@untainted> createResError(resp);
    }
}

function get(http:Client pagerdutyClient, string path) returns map<json>|Error {
    http:Response|error response = pagerdutyClient->get(path);
    return <@untainted> handleResponse(response);
}

function put(http:Client pagerdutyClient, http:Request req, string path) returns map<json>|Error {
    http:Response|error response = pagerdutyClient->put(path, req);
    return <@untainted> handleResponse(response);
}

function post(http:Client pagerdutyClient, http:Request req, string path) returns map<json>|Error {
    http:Response|error response = pagerdutyClient->post(path, req);
    if (response is error) {
        return createResError(response);
    } else {
        if(response.getHeader(RES_STATUS) == CREATED) {
            map<json> payload = <map<json>>response.getJsonPayload();
            return <@untainted> payload;
        } else {
            return <@untainted> createError(response);
        }
    }
}

function delete(http:Client pagerdutyClient, string path) returns Error? {
    http:Response|error response = pagerdutyClient->delete(path);
    if (response is error) {
        return <@untainted> createResError(response);
    } else {
        if(response.getHeader(RES_STATUS) != DELETED) {
            return <@untainted> createError(response);
        }
    }
}

function handleResponse(http:Response|error response) returns map<json>|Error {
    if (response is error) {
        return createResError(response);
    } else {
        if(response.getHeader(RES_STATUS) == OK) {
            map<json> payload = <map<json>>response.getJsonPayload();
            return <@untainted> payload;
        } else {
            return <@untainted> createError(response);
        }
    }
}

function createResError(error errorResponse) returns Error {
    return Error("Error received from the pagerduty server", errorResponse);
}

function createTypeCastError(error errorResponse, string data) returns Error {
    return Error("Error occurred when converting object [" + data + "] to payload", errorResponse);
}

function createError(http:Response resp) returns Error {
    map<json> output = <map<json>>resp.getJsonPayload();
    string message = "";
    if (output["error"] is string) {
        return <@untainted> Error("Error received from the pagerduty server", error(output["error"].toString()));
    } else {
        map<json> err = <map<json>>output["error"];
        if (err.hasKey("errors")) {
            message = err["errors"].toString();
        }
        return <@untainted> Error("Error received from the pagerduty server: " + message,
                                  error(output["error"].message.toString()),
                                  errorCode = <int>(output["error"].code));
    }
}

function setJsonPayload(map<json>|error|json[] data, http:Request request, string key) {
    map<json> payload = {};
	if (data is map<json>|json[]) {
	    payload[key] = data;
        json|error jsonPayload = payload.cloneWithType(json);
        if (jsonPayload is json) {
            request.setJsonPayload(jsonPayload);
        }
    }
}

function getError() returns error {
    return Error("Error occurred while getting the logged-in user email ID: " +
                 "An account-level access token, we were unable to determine the user's identity. " +
                 "Please use a user-level token.");
}
