## Module Overview

The `ballerinax/pagerduty` allows you to work with pagerDuty users, escalationPolicies, services , schedules, services and incidents through the pagerDuty Rest API. 

The following sections provide you details on how to use the `pagerduty`.

- [Compatibility](#compatibility)
- [Feature Overview](#feature-overview)
- [Getting Started](#getting-started)
- [Sample](#sample)

## Compatibility

|                             |           Version           |
|:---------------------------:|:---------------------------:|
| Ballerina Language          |            1.2.X            |
| PagerDuty REST API          |            v2               |

## Feature Overview

Following groups are provided by Ballerina to interact with different API groups of the pagerDuty REST API. 
1. **pagerDuty:Account** - The `Account` used to initiate the contact with pagerDuty API and create all the associated sub groups with the operations.
2. **pagerDuty:Users** - The `Users` will be used to create/get/delete the User/Contact method/ Notification rule.
3. **pagerDuty:EscalationPolicies** - The `EscalationPolicies` will be used to create/get/update/delete the escalation policy
4. **pagerDuty:Schedules** - This `Schedules` will be used to create/get/delete the schedule.
5. **pagerDuty:Services** - This `Services` will be used to create/update|delete the services/integration. 
6. **pagerDuty:Extensions** - This `Extensions` will be used to create/get/update/delete the extension.
6. **pagerDuty:Incidents** - The `Incidents` used to create/get/update/manage/delete/snooze the incidents and add note into that.

## Getting Started

### Prerequisites

- Download and install [Ballerina](https://ballerinalang.org/downloads/).
- Get the [REST API Key](https://support.pagerduty.com/docs/generating-api-keys#section-rest-api-keys).

>Note: According to the account's role permission, The user API token can support all the functionality what we have but
> the account API token can't access the operations which to be need the `from email Id`.They are `createUser`, `createIncident`,
> `createEscalationPolicy`, `createSchedule`, `manageIncidents`, `updateIncident` and `addNote`.

### Pull the Module

Execute the below command to pull the pagerDuty module from Ballerina Central:

```ballerina
$ ballerina pull ballerinax/pagerduty
```

## Sample

The following is a simple Ballerina program that is used to receiving notification from configure the profile.

```ballerina
import ballerinax/io;
import ballerinax/pagerduty;
import ballerina/time;

Configuration pagerdutyConfig = {
    oauth2Config: {
        accessToken: <API_TOKEN>
    }
};

string userId = "";
User user =  {"type": "user", "name": "peter", "email": "kalai@gmail.com", "role": "admin"};
ContactMethod contactMethod = {"type": "sms","summary": "Home","label": "home","countryCode": 1,"address": "5766792895"};
EscalationPolicy createdEscalationPolicy = {"type": "sms", "id": "", "name": "", "escalationRules": []};
Service createdService = { "name": "service", "escalationPolicy": createdEscalationPolicy};

public function main() {
    Account pagerduty = new(pagerdutyConfig);
    Users users = pagerduty.getUsers();
    EscalationPolicies escalations = pagerduty.getEscalationPolicies();
    Schedules schedules = pagerduty.getSchedules();
    Services services = pagerduty.getServices();
    Extensions extensions = pagerduty.getExtensions();
    Incidents incidents = pagerduty.getIncidents();

    pagerduty:Error? response = users->createUser(user);
    if (response is Error) {    
        io:println("Error" + response.toString());
    } else {
        userId = user.get("id");
        io:println("User id " + userId);
    }

    pagerduty:Error? response = users->createContactMethod(userId, contactMethod);
    if (response is Error) {
        io:println("Error" + response.toString());
    } else {
        io:println("Contact method id " + contactMethod.get("id").toString());
    }

    NotificationRule rule = { "startDelayInMinutes": 1, "contactMethod" : createdContactMethod, "urgency": "high",
                              'type: "assignmentNotificationRule"};
    pagerduty:Error? response = users->createNotificationRule(userId, rule);
    if (response is Error) {
        io:println("Error" + response.toString());
    } else {
        io:println("Notification rule id " + rule.get("id").toString());
    }

    EscalationPolicy escalationPolicy = { "type": "escalationPolicy", "name": "Escalation Policy for Test",
                                          "escalationRules": [{ "escalationDelayInMinutes": 30,
                                          "targetss": [{"id": userId, "type": "user"}]}]
                                        };
    pagerduty:Error? response = escalations->createEscalationPolicy(escalationPolicy);
    if (response is Error) {
        io:println("Error" + response.toString());
    } else {
        createdEscalationPolicy = escalationPolicy;
        io:println("EscalationPolicy id " + escalationPolicy.get("id").toString());
    }
    
    time:Time time = time:currentTime();
    Schedule schedule = { "type": "schedule", "timeZone": "Asia/Colombo",
                          "scheduleLayers": [{"start": time, "rotationTurnLengthInSeconds": 86400,
                                             "rotationVirtualStart": time, "users": [user]}
                        ]};
    pagerduty:Error? response = schedules->createSchedule(schedule);
    if (response is Error) {
       io:println("Error" + response.toString());
    } else {
        io:println("Schedule id " + schedule.get("id").toString());
    }

    Service serv = { "name": "New services", "escalationPolicy": createdEscalationPolicy};
    pagerduty:Error? response = services->createService(serv);
    if (response is Error) {
        io:println("Error" + response.toString());
    } else {
        createdService = serv;
        io:println("Service id " + serv.get("id").toString());

    }

    Extension extension = { "type": "extension", "name": "webhook","endpointUrl": "http://8bac231a.ngrok.io/webhooks",
                            "extensionSchema": {"id": "PJFWPEP", "type": "extensionSchemaReference",
                             "summary": "Generic V2 Webhook"}, "services": [createdService]
                           };
    pagerduty:Error? response = extensions->createExtension(extension);
    if (response is Error) {
        io:println("Error" + response.toString());
    } else {
        io:println("Extension id " + extension.get("id").toString());
    }

    Incident incident = {"type": "incident", "title": "Test", "service": createdService};
    pagerduty:Error? response = incidents->createIncident(incident);
    if (response is Error) {
        io:println("Error" + response.toString());
    } else {
        io:println("Incident id " + incident.get("id").toString());
    }
}
```
