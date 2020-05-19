# PagerDuty Module

The Ballerina PagerDuty connector allows you to work with PagerDuty users, escalationPolicies, services, schedules, and incidents through the PagerDuty Rest API. 
It handles the API Token Authentication. Following tokens are can be used under this mechanism:

*Account API token - It can access all the data in an account and can either be granted read-only access or full access to read, write, update, and delete. 
Only account administrators have the ability to generate account API tokens.
* User API token - It can access all the data that the associated user account has access to.

>**Note:** According to the account's role permission, the user API token can access all the available functionality. However,
> the account API token can't access the operations, which need the `from email Id`. They are `createUser`, `createIncident`, `createEscalationPolicy`, `createSchedule`, `manageIncidents`, `updateIncident`, and `addNote`.

The following groups are provided by Ballerina to interact with the different API groups of the PagerDuty REST API. 
- **pagerDuty:Account** - The `Account`, which is used to initiate the contact with the PagerDuty API and create all the associated sub groups with the operations.   
- **pagerDuty:Users** - The `Users`, which will be used to create/get/delete the Users/Contact methods/ Notification rules.
- **pagerDuty:EscalationPolicies** - The `EscalationPolicies`, which will be used to create/get/update/delete the escalation policies.
- **pagerDuty:Schedules** - The `Schedules`, which will be used to create/get/delete the schedules.
- **pagerDuty:Services** - The `Services`, which will be used to create/update|delete the services/integrations. 
- **pagerDuty:Extensions** - The `Extensions`, which will be used to create/get/update/delete the extensions.
- **pagerDuty:Incidents** - The `Incidents`, which will be used to create/get/update/manage/delete/snooze the incidents and add notes into that.

## Compatibility

|                             |           Version           |
|:---------------------------:|:---------------------------:|
| Ballerina Language          |            1.2.X            |
| PagerDuty REST API          |            v2               |

## Sample

**Generating tokens**

* Create a [PagerDuty account](https://www.pagerduty.com/).
* Generate one of the below API tokens.
    * User API token:
        * Go to Configuration->Users->User setting-> Create API user token
    * Account API token:
        * Go to Configuration->API Access->Create New API Key
        
>**Note:** The user API token supports all the available functionalities of the role permission. However, the account API token can't access the operations, which need the `from email Id`(`createUser`, `createIncident`, `createEscalationPolicy`, `createSchedule`, `manageIncidents`, `updateIncident`, and `addNote`).

>**Create the `pagerduty:Account`**

First, execute the below command to import the `ballerinax/pagerduty` module into the Ballerina project.
```ballerina
import ballerinax/pagerduty;
```
Instantiate the `pagerduty:Account` by giving the token authentication details in the `pagerduty:Configuration`. 

You can define the PagerDuty configuration and create the account as follows. 
```ballerina
Configuration pagerdutyConfig = {
    oauth2Config: {
        accessToken: <API_TOKEN>
    }
};
// Creates the PagerDuty account.
Account pagerduty = new(pagerdutyConfig);
```

**PagerDuty operations related to `Users`**

The `createUser` remote function can be used to create a user in PagerDuty `Users`.  

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

The `createEscalationPolicy` remote function can be used to create the escalation policy in PagerDuty `Escalation Policies`.

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

The `createSchedule` remote function can be used to create the schedule in PagerDuty `Schedules`.  

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

The `createService` remote function can be used to create the Services in PagerDuty `Services`. 

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

The `createExtension` remote function can be used to create the extension in PagerDuty `Extensions`. 

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

The `createIncident` remote function can be used to create the incident in PagerDuty `Incidents`.   

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
