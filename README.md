## Module Overview

The `ballerinax/pagerduty` module allows you to work with PagerDuty users, escalationPolicies, services, schedules, and incidents through the PagerDuty Rest API. 

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

The following groups are provided by Ballerina to interact with different API groups of the pagerDuty REST API. 
1. **pagerDuty:Account** - The `Account` used to initiate the contact with the pagerDuty API and create all the associated sub groups with the operations.
2. **pagerDuty:Users** - The `Users`, which will be used to create/get/delete the User/Contact method/ Notification rule.
3. **pagerDuty:EscalationPolicies** - The `EscalationPolicies`, which will be used to create/get/update/delete the escalation policy.
4. **pagerDuty:Schedules** - The `Schedules`, which will be used to create/get/delete the schedule.
5. **pagerDuty:Services** - The `Services`, which will be used to create/update|delete the services/integration. 
6. **pagerDuty:Extensions** - The `Extensions`, which will be used to create/get/update/delete the extension.   
7. **pagerDuty:Incidents** - The `Incidents`, which will be used to create/get/update/manage/delete/snooze the incidents and add the note into that.

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

pagerduty:Configuration pagerdutyConfig = {
    oauth2Config: {
        accessToken: <API_TOKEN>
    }
};

public function main() {
    pagerduty:Account pagerduty = new(pagerdutyConfig);
    pagerduty:Users users = pagerduty.getUsers();
    pagerduty:EscalationPolicies escalations = pagerduty.getEscalationPolicies();
    pagerduty:Schedules schedules = pagerduty.getSchedules();
    pagerduty:Services services = pagerduty.getServices();
    pagerduty:Extensions extensions = pagerduty.getExtensions();
    pagerduty:Incidents incidents = pagerduty.getIncidents();

    string userId = "";
    pagerduty:User user =  { "type": "user", "name": "peter", "email": "kalai@gmail.com", "role": "admin"};
    pagerduty:ContactMethod contactMethod = { "type": "sms","summary": "Home","label": "home","countryCode": 1,
                                              "address": "5766792895"};
    pagerduty:EscalationPolicy createdEscalationPolicy = { "type": "sms", "id": "", "name": "", "escalationRules": []};
    pagerduty:Service createdService = { "name": "service", "escalationPolicy": createdEscalationPolicy};

    pagerduty:Error? response = users->createUser(<@untained> user);
    if (response is pagerduty:Error) {
        io:println("Error" + response.toString());
    } else {
        userId = user.get("id").toString();
        io:println("User id " + userId);
    }

    response = users->createContactMethod(<@untained> userId, <@untained> contactMethod);
    if (response is pagerduty:Error) {
        io:println("Error" + response.toString());
    } else {
        io:println("Contact method id " + contactMethod.get("id").toString());
    }

    pagerduty:NotificationRule rule = { "startDelayInMinutes": 1, "contactMethod" : contactMethod, "urgency": "high",
                              'type: "assignmentNotificationRule"};
    response = users->createNotificationRule(<@untained> userId, <@untained> rule);
    if (response is pagerduty:Error) {
        io:println("Error" + response.toString());
    } else {
        io:println("Notification rule id " + rule.get("id").toString());
    }

    pagerduty:EscalationPolicy escalationPolicy = { "type": "escalationPolicy", "name": "Escalation Policy for Test",
                                          "escalationRules": [{ "escalationDelayInMinutes": 30,
                                          "targets": [{"id": userId, "type": "user"}]}]
                                        };
    response = escalations->createEscalationPolicy(escalationPolicy);
    if (response is pagerduty:Error) {
        io:println("Error" + response.toString());
    } else {
        createdEscalationPolicy = escalationPolicy;
        io:println("EscalationPolicy id " + escalationPolicy.get("id").toString());
    }

    time:Time time = time:currentTime();
    pagerduty:Schedule schedule = { "type": "schedule", "timeZone": "Asia/Colombo",
                                    "scheduleLayers": [{ "start": time, "rotationTurnLengthInSeconds": 86400,
                                                         "rotationVirtualStart": time, "users": [user]
                                                         }]
                                   };
    response = schedules->createSchedule(schedule);
    if (response is pagerduty:Error) {
       io:println("Error" + response.toString());
    } else {
        io:println("Schedule id " + schedule.get("id").toString());
    }

    pagerduty:Service serv = { "name": "New services", "escalationPolicy": createdEscalationPolicy};
    response = services->createService(serv);
    if (response is pagerduty:Error) {
        io:println("Error" + response.toString());
    } else {
        createdService = serv;
        io:println("Service id " + serv.get("id").toString());

    }

    pagerduty:Extension extension = { "type": "extension", "name": "webhook",
                                       "endpointUrl": "http://8bac231a.ngrok.io/webhooks", 
                                       "extensionSchema": {"id": "PJFWPEP", "type": "extensionSchemaReference",
                                       "summary": "Generic V2 Webhook"}, "services": [createdService]
                                    };
    response = extensions->createExtension(extension);
    if (response is pagerduty:Error) {
        io:println("Error" + response.toString());
    } else {
        io:println("Extension id " + extension.get("id").toString());
    }

    pagerduty:Incident incident = {"type": "incident", "title": "Test", "service": createdService};
    response = incidents->createIncident(incident);
    if (response is pagerduty:Error) {
        io:println("Error" + response.toString());
    } else {
        io:println("Incident id " + incident.get("id").toString());
    }
}

```
