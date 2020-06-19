## Module Overview

The `ballerinax/pagerduty` module allows you to work with PagerDuty users, escalationPolicies, extensions, services, schedules, and incidents through the PagerDuty Rest API. 

The following sections provide you details on how to use the `pagerduty`.

- [Compatibility](#compatibility)
- [Feature Overview](#feature-overview)
- [Getting Started](#getting-started)
- [Sample](#sample)

## Compatibility

|                             |           Version           |
|:---------------------------:|:---------------------------:|
| Ballerina Language          |           2.0.0            |
| PagerDuty REST API          |            v2               |

## Feature Overview

The following collections are provided by Ballerina to interact with different API groups of the PagerDuty REST API. 
- **pagerDuty:Account** - The `Account`, which is used to initiate the contact with the PagerDuty API and create all the associated sub groups with the operations.   
- **pagerDuty:UserClient** - The `UserClient`, which will be used to create/get/delete the Users/Contact methods/ Notification rules.
- **pagerDuty:EscalationPolicyClient** - The `EscalationPolicyClient`, which will be used to create/get/update/delete the escalation policies.
- **pagerDuty:ScheduleClient** - The `ScheduleClient`, which will be used to create/get/delete the schedules.
- **pagerDuty:ServiceClient** - The `ServiceClient`, which will be used to create/update|delete the services/integrations. 
- **pagerDuty:ExtensionClient** - The `ExtensionClient`, which will be used to create/get/update/delete the extensions.
- **pagerDuty:IncidentClient** - The `IncidentClient`, which will be used to create/get/update/manage/delete/snooze the incidents and add notes into that.

## Getting Started

### Prerequisites

- Download and install [Ballerina](https://ballerinalang.org/downloads/).
- Get the [REST API Key](https://support.pagerduty.com/docs/generating-api-keys#section-rest-api-keys).

>**Note:** According to the account's role permission, the user API token can support all the available functionality. However,
> the account API token can't access the operations, which need the `from email Id`. They are `createUser`, `createIncident`,
> `createEscalationPolicy`, `createSchedule`, `manageIncidents`, `updateIncident`, and `addNote`.

### Pull the Module

Execute the below command to pull the `pagerDuty` module from Ballerina Central:

```ballerina
$ ballerina pull ballerinax/pagerduty
```

## Sample

The following is a simple Ballerina program, which is used to receive notifications on configuring the profile.

```ballerina
import ballerina/io;
import ballerinax/pagerduty;
import ballerina/time;

public function main() {
    pagerduty:Account pagerduty = new("s1tayEadzxp5mXWtuyh5");
    pagerduty:UserClient userClient = pagerduty.getUserClient();
    pagerduty:EscalationPolicyClient escalationClient = pagerduty.getEscalationPolicyClient();
    pagerduty:ScheduleClient scheduleClient = pagerduty.getScheduleClient();
    pagerduty:ServiceClient serviceClient = pagerduty.getServiceClient();
    pagerduty:ExtensionClient extensionClient = pagerduty.getExtensionClient();
    pagerduty:IncidentClient incidentClient = pagerduty.getIncidentClient();
    string userId = "";
    pagerduty:User user =  { 'type: "user", name: "Abisayan", email: "example@gmail.com", role: "admin" };
    pagerduty:ContactMethod contactMethod = { 'type: "sms", summary: "Home", label: "home", countryCode: 1,
                                               address: "5766792895" };
    pagerduty:EscalationPolicy createdPolicy = { 'type: "sms", id: "", name: "", escalationRules: [] };
    pagerduty:Service createdService = { name: "service", escalationPolicy: createdPolicy };
    pagerduty:ContactMethod createdContactMethod = { 'type: "sms", address: "5766792895" };
    pagerduty:User createdUser =  { 'type: "user", name: "", email: "a@gmail.com" };

    // Creates a new user
    pagerduty:Error|pagerduty:User output = userClient->createUser(user);
    if (output is pagerduty:Error) {
        io:println("Error " + output.toString());
    } else {
        userId = output.get("id").toString();
        createdUser = output;
        io:println("User id " + userId);
    }

    // Creates a new contact method
    pagerduty:Error|pagerduty:ContactMethod createdMethod = userClient->createContactMethod(userId, contactMethod);
    if (createdMethod is pagerduty:Error) {
        io:println("Error " + createdMethod.toString());
    } else {
        createdContactMethod = createdMethod;
        io:println("Contact method id " + createdContactMethod.get("id").toString());
    }

    // Creates a new notification rule
    pagerduty:NotificationRule rule = { startDelayInMinutes: 1, contactMethod : createdContactMethod, 
                                        urgency: "high", 'type: "assignmentNotificationRule" };
    pagerduty:Error|pagerduty:NotificationRule createdRule = userClient->createNotificationRule(userId, rule);
    string result = createdRule is pagerduty:Error ? ("Error " + createdRule.toString()) : ("Notification rule id " + createdRule.get("id").toString());
    io:println(result);

    // Creates a new escalation policy
    pagerduty:EscalationPolicy escalationPolicy = { 'type: "escalationPolicy", name: "Escalation Policy for Test",
                                                     escalationRules: [{ escalationDelayInMinutes: 30,
                                                     targets: [{id: userId, 'type: "user"}]}]
                                                  };
    pagerduty:EscalationPolicy|pagerduty:Error response = escalationClient->create(escalationPolicy);
    if (response is pagerduty:Error) {
        io:println("Error " + response.toString());
    } else {
        createdPolicy = response;
        io:println("EscalationPolicy id " + response.get("id").toString());
    }

    // Creates a new schedule
    time:Time time = time:currentTime();
    pagerduty:Schedule schedule = { 'type: "schedule", timeZone: "Asia/Colombo",
                                    scheduleLayers: [{ 'start: time, rotationTurnLengthInSeconds: 86400,
                                                        rotationVirtualStart: time, users: [createdUser]
                                                     }]
                                  };
    pagerduty:Schedule|pagerduty:Error createdSchedule = scheduleClient->create(schedule);
    result = createdSchedule is pagerduty:Error ? ("Error " + createdSchedule.toString()) : ("Schedule id " + createdSchedule.get("id").toString());
    io:println(result);

    // Creates a new service
    pagerduty:Service serv = { name: "New services", escalationPolicy: createdPolicy,
                               alertCreation:"createAlertsAndIncidents" };
    pagerduty:Service|pagerduty:Error resp = serviceClient->createService(serv);
    if (resp is pagerduty:Error) {
        io:println("Error " + resp.toString());
    } else {
        createdService = resp;
        io:println("Service id " + resp.get("id").toString());

    }

    // Creates a new extension
    pagerduty:Extension extension = { 'type: "extension", name: "webhook",
                                       endpointUrl: "http://fc321768.ngrok.io/webhooks",
                                       extensionSchema: {id: "PJFWPEP", 'type: "extensionSchemaReference",
                                       summary: "Generic V2 Webhook"}, services: [createdService]
                                    };
    pagerduty:Extension|pagerduty:Error createdExtension = extensionClient->create(extension);
    result = createdExtension is pagerduty:Error ? ("Error " + createdExtension.toString()) : ("Extension id " + createdExtension.get("id").toString());
    io:println(result);

    // Creates a new incident
    pagerduty:Incident incident = { 'type: "incident", title: "Test", 'service: createdService };
    pagerduty:Incident|pagerduty:Error createdIncident = incidentClient->createIncident(incident);
    result = createdIncident is pagerduty:Error ? ("Error " + createdIncident.toString()) : ("Incident id " + createdIncident.get("id").toString());
    io:println(result);
}
```
