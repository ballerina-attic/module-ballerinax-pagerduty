# PagerDuty Module

The Ballerina pagerduty connector allows you to work with pagerDuty users, escalationPolicies, services , schedules, services and incidents through the pagerduty Rest API. 
It handles the API Token Authentication. Following tokens are using under this mechanism:

* Account API token - It can access to all of the data on an account, and can either be granted read-only access or full access to read, write, update, and delete. 
Only account administrators have the ability to generate account API tokens
* User API token - It can access to all of the data that the associated user account has access to

>Note: According to the account's role permission, The user API token can access all the functionality what we have but
> the account API token can't access the operations which to be need the `from email Id`. They are `createUser`, `createIncident`, `createEscalationPolicy`, `createSchedule`, `manageIncidents`, `updateIncident` and `addNote`.

Following groups are provided by Ballerina to interact with different API groups of the pagerDuty REST API. 
- **pagerDuty:Account** - The `Account` used to initiate the contact with pagerDuty API and create all the associated sub groups with the operations.
- **pagerDuty:Users** - The `Users` will be used to create/get/delete the Users/Contact methods/ Notification rules.
- **pagerDuty:EscalationPolicies** - The `EscalationPolicies` will be used to create/get/update/delete the escalation policies.
- **pagerDuty:Schedules** - This `Schedules` will be used to create/get/delete the schedules.
- **pagerDuty:Services** - This `Services` will be used to create/update|delete the services/integrations. 
- **pagerDuty:Extensions** - This `Extensions` will be used to create/get/update/delete the extensions.
- **pagerDuty:Incidents** - The `Incidents` used to create/get/update/manage/delete/snooze the incidents and add notes into that.

## Compatibility

|                             |           Version           |
|:---------------------------:|:---------------------------:|
| Ballerina Language          |            1.2.X            |
| PagerDuty REST API          |            v2               |

## Sample

**Generating tokens**

* Get the [pagerDuty account](https://www.pagerduty.com/).
* Generates the one of the API token
    * User API token
        * Go to Configuration->Users->User setting-> Create API user token
    * Account API token
        * Go to Configuration->API Access->Create New API Key
        
>Note: The user API token supports all the functionality belongs the role permission which we have but the account API token can't access the operations which to be need the `from email Id`(`createUser`, `createIncident`, `createEscalationPolicy`, `createSchedule`, `manageIncidents`, `updateIncident` and `addNote`).

**Create the `pagerduty:Accoun`t**

First, execute the below command to import the `ballerinax/pagerduty` module into the Ballerina project.
```ballerina
import ballerinax/pagerduty;
```
Instantiate the `pagerduty:Account` by giving token authentication details in the `pagerduty:Configuration`. 

You can define the pagerduty configuration and create the account as follows. 
```ballerina
Configuration pagerdutyConfig = {
    oauth2Config: {
        accessToken: <API_TOKEN>
    }
};
// Create the pagerduty account.
Account pagerduty = new(pagerdutyConfig);
```

**Pagerduty operations related to `Users`**

The `createUser` remote function can be used to create the user in a pagerDuty `Users`. 

```ballerina
Users users = pagerduty.getUsers();
User user =  {"type": "user", "name": "peter", "email": "kalai@gmail.com", "role": "admin"};
pagerduty:Error? response = users->createUser(<@untained> user);
if (response is Error) {    
    io:println("Error" + response.toString());
} else {
    io:println("User id " + user.get("id"));
}
```

**Pagerduty operations related to `EscalationPolicies`**

The `createEscalationPolicy` remote function can be used to create the escalation policy in a pagerDuty `Escalation Policies`. 

```ballerina
EscalationPolicies escalations = pagerduty.getEscalationPolicies();
EscalationPolicy escalationPolicy = { "type": "escalationPolicy",
                                      "name": "Escalation Policy for Test",
                                      "escalationRules": [{ "escalationDelayInMinutes": 30,
                                                            "users": [createdUser]
                                                          }]
                                     };
pagerduty:Error? response = escalations->createEscalationPolicy(<@untained> escalationPolicy);
if (response is Error) {
    test:assertFail(msg = response.toString());
} else {
    io:println("EscalationPolicy id " + escalationPolicy.get("id"));
}
```

**Pagerduty operations related to `Schedules`**

The `createSchedule` remote function can be used to create the schedule in a pagerDuty `Schedules`. 

```ballerina
Schedules schedules = pagerduty.getSchedules();
Schedule schedule = {"type": "schedule",
                     "timeZone": "Asia/Colombo",
                     "scheduleLayers": [
                         {
                            "start": time,
                            "rotationTurnLengthInSeconds": 86400,
                            "rotationVirtualStart": time,
                             "users": [createdUser]
                         }
                     ]};
pagerduty:Error? response = schedules->createSchedule(schedule);
if (response is Error) {
    test:assertFail(msg = response.toString());
} else {
    io:println("Schedule id " + schedule.get("id"));
}
```

**Pagerduty operations related to `Services`**

The `createService` remote function can be used to create the Services in a pagerDuty `Services`. 

```ballerina
Services services = pagerduty.getServices();
Service serv = { "name": "New services",
                 "escalationPolicy":createdEscalationPolicy
                };
pagerduty:Error? response = services->createService(<@untained> serv);
if (response is Error) {    
    io:println("Error" + response.detail()?.message.toString());
} else {
    io:println("Service id " + serv.get("id"));
}
```

**Pagerduty operations related to `Extensions`**

The `createExtension` remote function can be used to create the extension in a pagerDuty `Extensions`. 

```ballerina
Extensions extensions = pagerduty.getExtensions();
Extension extension = { "type": "extension",
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
pagerduty:Error? response = extensions->createExtension(<@untained> extension);
if (response is Error) {    
    io:println("Error" + response.detail()?.message.toString());
} else {
    io:println("Extension id " +  extension.get("id"));
}
```

**Pagerduty operations related to `Incidents`**

The `createIncident` remote function can be used to create the incident in a pagerDuty `Incidents`. 

```ballerina
Incidents incidents = pagerduty.getIncidents();
Incident incident = { "type": "incident",
                      "title": "Test",
                      "service": createdService};
pagerduty:Error? response = incidents->createIncident(<@untained> incident);
if (response is Error) {    
    io:println("Error" + response.detail()?.message.toString());
} else {
    io:println("Incident id " + incident.get("id"));
}
```
