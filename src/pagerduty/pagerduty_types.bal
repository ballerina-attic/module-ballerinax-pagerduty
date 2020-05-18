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
import ballerina/time;

# Holds the parameters used to create a `Client`.
#
# + oauth2Config - OAuth2 client configuration
public type Configuration record {|
   oauth2:DirectTokenConfig oauth2Config;
|};

# Represents a pager duty user.
# + name - The name of the user
# + email - The user's email address
# + type - The type of the object(valid options: `user` or `userReference`).Default value is `user`
# + id - The ID of the user
# + timeZone - The preferred time zone name(e.g Europe/Berlin). If null, the account's time zone will be used
# + color - The schedule color
# + avatarUrl - The url of the user’s avatar
# + description - The user's bio
# + role - The user role (Valid options: `admin`, `limitedUser`, `observer`, `owner`, `readOnlyUser`,
#          `restrictedAccess`, `readOnlyLimitedUser` or `user`)
# + invitationSent - If true, the user has an outstanding invitation
# + jobTitle - The user's job title
# + teams - The list of teams to which the user belongs
# + contactMethods - The list of contact methods for the user
# + notificationRules - The list of notification rules for the user
public type User record {|
    string name;
    string email;
    Type 'type?;
    string id?;
    string timeZone?;
    string color?;
    Role role?;
    string avatarUrl?;
    string description?;
    boolean invitationSent?;
    string jobTitle?;
    Common[] teams?;
    ContactMethod[] contactMethods?;
    NotificationRule[] notificationRules?;
|};

# Represents a common pager duty property. 
# + type  - A string that determines the schema of the object
# + id - The ID of the object
# + summary -  A short-form, server-generated string that provides succinct, important information about an
#              object suitable for primary labeling of an entity in a client
# + url - A URL at which the object is accessible
# + htmlUrl - A URL at which the entity is uniquely displayed in the Web app
public type Common record {|
    Type 'type;
    string id;
    string summary?;
    string url?;
    string htmlUrl?;
|};

# Represents a pager duty contact method.
# + type  - A string that determines the schema of the object(Valid options: `email`, `phone`, `pushNotification` or
#           `sms`)
# + address - The "address" to deliver to: email, phone number, etc., depending on the type.
# + id - The ID of the contact method
# + label -  The label(Valid options: `work`, `mobile`, `home` or `skype`)
# + countryCode - A country code of the phone number
# + summary -  A short-form, server-generated string that provides succinct, important information about an
#              object suitable for primary labeling of an entity in a client
# + url - A URL at which the object is accessible
# + htmlUrl - A URL at which the entity is uniquely displayed in the Web app
public type ContactMethod record {|
    Type 'type;
    string address;
    string id?;
    Label label?;
    int countryCode?;
    string summary?;
    string url?;
    string htmlUrl?;
|};

# Represents a pager duty notification rule.
# + startDelayInMinutes - The delay before firing the rule in minutes.
# + contactMethod - A contact method
# + type  - A string that determines the schema of the object.Must be set to `assignmentNotificationRule`
# + id - The ID of the notification rule
# + urgency - The urgency of the incident (Valid options: `high` or `low`).
# + summary -  A short-form, server-generated string that provides succinct, important information about an
#              object suitable for primary labeling of an entity in a client
# + url - A URL at which the object is accessible
# + htmlUrl - A URL at which the entity is uniquely displayed in the Web app
public type NotificationRule record {|
    int startDelayInMinutes;
    ContactMethod contactMethod;
    Type 'type?;
    string id?;
    Urgency urgency;
    string summary?;
    string url?;
    string htmlUrl?;
|};

# Represents a pager duty escalation policy.
# + name - The name of the escalation policy
# + escalationRules - An `EscalationRule`. The Escalation rule defined below
# + type  - The type of `EscalationPolicy`
# + id - The ID of the notification rule
# + summary -  A short-form, server-generated string that provides succinct, important information about an
#              object suitable for primary labeling of an entity in a client
# + url - A URL at which the object is accessible
# + description - A human-friendly description of the escalation policy
# + htmlUrl - A URL at which the entity is uniquely displayed in the Web app
# + numberOfloops - The number of times the escalation policy will repeat after reaching the end of its escalation
# + services - The list of services
# + teams - Teams associated with the policy. Account must have the teams ability to use this parameter
# + onCallHandoffNotification - Determines how on call handoff notifications will be sent for users
#                               on the escalation policy. Defaults to "if_has_services"
public type EscalationPolicy record {|
      string name;
      EscalationRule[] escalationRules;
      Type 'type?;
      string id?;
      string summary?;
      string url?;
      string description?;
      string htmlUrl?;
      int numberOfloops?;
      OnCallHandoffNotifications onCallHandoffNotification?;
      Service[] services?;
      Common[] teams?;
|};

# Represents a pager duty escalation rule.
# + escalationDelayInMinutes - The number of minutes before an unacknowledged incident escalates away from this rule
# + targets - The list of `Common` which type can take `user`, `schedule`, `userReference` or `scheduleReference`
# + id - An ID of the notification rule
public type EscalationRule record {|
    int escalationDelayInMinutes;
    Common[] targets;
    string id?;
|};

# Represents a pager duty schedule.
# + type - The type of object
# + timeZone - The time zone of the schedule(e.g Europe/Berlin)
# + scheduleLayers - A list of schedule layers.
# + id - An ID of the notification rule
# + name - The name of the schedule
# + summary -  A short-form, server-generated string that provides succinct, important information about an
#              object suitable for primary labeling of an entity in a client
# + url - A URL at which the object is accessible
# + htmlUrl - A URL at which the entity is uniquely displayed in the Web app
# + description - The description of the schedule
# + escalationPolicies - An array of all of the escalation policies that uses this schedule
# + finalSchedule - The final layer is a special layer that contains the result of all of the previous layers put
#                   together.
# + overridesSubschedule - The override layer is a special layer where all of the override entries are stored
# + users - An array of all of the users on the schedule.
# + teams - An array of all of the teams on the schedule.
public type Schedule record {|
    string 'type;
    string timeZone;
    ScheduleLayer[] scheduleLayers;
    string id?;
    string name?;
    string description?;
    string summary?;
    string url?;
    string htmlUrl?;
    EscalationPolicy[] escalationPolicies?;
    FinalSchedule finalSchedule?;
    FinalSchedule overridesSubschedule?;
    User[] users?;
    Common[] teams?;
|};

# Represents a pager duty schedule layer.
# + start - The start time of this layer
# + users - The ordered list of users on this layer. The position of the user on the list determines their order in the layer
# + rotationVirtualStart - The effective start time of the layer.\
# + rotationTurnLengthInSeconds - The duration of each on-call shift in seconds
# + name - The name of the schedule layer
# + id - The ID of the schedule layer
# + end - The end time of the schedule layer. If not specified, the layer does not end
# + restrictions - An array of restrictions for the layer
# + renderedCoveragePercentage - The percentage of the time range covered by this layer
# + renderedScheduleEntries - This is a list of entries on the computed layer for the current time range
public type ScheduleLayer record {|
    time:Time 'start;
    User[] users;
    time:Time rotationVirtualStart;
    int rotationTurnLengthInSeconds;
    string name?;
    string id?;
    time:Time end?;
    Restriction[] restrictions?;
    RenderedScheduleEntry[] renderedScheduleEntries?;
    int renderedCoveragePercentage?;
|};

# Represents a pager duty restriction.
# + type - The type of the restriction(valid options: `dailyRestriction`, `weeklyRestriction`)
# + startDayOfWeek - The number of the day when restriction starts(From 1 to 7 where 1 is Monday and 7 is Sunday).
#                    Only required for use with a `weeklyRestriction`
# + durationInSeconds - The duration of the restriction in seconds
# + startTimeOfDay - The start time in HH:mm:ss format
public type Restriction record {|
    Type 'type;
    time:Time startTimeOfDay;
    int durationInSeconds;
    int startDayOfWeek?;
|};

# Represents a pager duty final schedule.
# + name - The name of the subschedule(valid option: finalSchedule, Overrides)
# + renderedScheduleEntries - This is a list of entries on the computed layer for the current time range
# + renderedCoveragePercentage - The percentage of the time range covered by this layer
public type FinalSchedule record {|
    Name name;
    RenderedScheduleEntry[] renderedScheduleEntries?;
    int renderedCoveragePercentage?;
|};

# Represents a pager duty rendered schedule entries.
# + start - The start time of this entry.
# + end -  The end time of this entry. If null, the entry does not end
# + user - The user
public type RenderedScheduleEntry record {|
    time:Time 'start;
    time:Time end;
    User user?;
|};

# Represents a pager duty service.
# + name - The name of the service
# + escalationPolicy - The escalation policy used by this service
# + type - The type of service(Valid options: `service` or `serviceReference`)
# + id -  An ID of the service
# + description - The user-provided description of the service
# + autoResolveTimeout - Time in seconds that an incident is automatically resolved if left open for that long
# + acknowledgementTimeout - Time in seconds that an incident changes to the Triggered State after being Acknowledged.
# + createdAt - The date/time when this service was created
# + status - The current state of the service
# + lastIncidentTimestamp - The date/time when the most recent incident was created for this service
# + teams - The set of teams associated with this service
# + integrations - An array containing Integration objects that belong to this service.
# + incidentUrgencyRule - The default urgency for new incidents
# + supportHours - The support hours for the service. When using type = `useSupportHours` in `incidentUrgencyRule`
#                  you must specify exactly one (otherwise optional) `supportHours`
# + scheduledActions - An array containing scheduled actions for the service.
# + addons -  The array of Add-ons associated with this service.
# + alertCreation - Whether a service creates only incidents, or both alerts and incidents
#                   (Valid options: `createIncidents` or `createAlertsAndIncident`)
# + alertGrouping -  Defines how alerts on this service will be automatically grouped into incidents
# + alertGroupingTimeout - The duration in minutes within which to automatically group incoming alerts.
public type Service record {|
    string name;
    EscalationPolicy escalationPolicy;
    Type 'type?;
    string id?;
    string description?;
    int autoResolveTimeout? ;
    int acknowledgementTimeout?;
    time:Time createdAt?;
    Status status?;
    time:Time lastIncidentTimestamp?;
    Common[] teams?;
    Integration[] integrations?;
    IncidentUrgencyRule  incidentUrgencyRule?;
    SupportHour supportHours?;
    ScheduledAction[] scheduledActions?;
    Common[] addons?;
    AlertCreation alertCreation?;
    Group alertGrouping?;
    int alertGroupingTimeout?;
|};

# Represents a pager duty incident urgency rule.
# + type -  The type of incident urgency: whether it's `constant`, or `useSupportHours`)
# + urgency - The incidents' urgency.(Valid options: `high`, `low` or `severityBased`)
# + duringSupportHours - Incidents' urgency during support hours
# + outsideSupportHours - Incidents' urgency outside of support hours
public type IncidentUrgencyRule record {|
    Type 'type?;
    Urgency urgency?;
    IncidentSupportHour duringSupportHours?;
    IncidentSupportHour outsideSupportHours?;
|};

# Represents a pager duty incident support hours.
# + type -  The type of incident urgency
# + urgency - The incidents' urgency (“high”, “low”)
public type IncidentSupportHour record {|
  Type 'type?;
  Urgency urgency?;
|};

# Represents a pager duty support hours.
# + type - The type of support hours. (Valid option: `fixedTimePerDay`)
# + timeZone - The time zone for the support hours
# + dayOfWeek - Array of days of week as integers. 1 to 7, 1 being Monday and 7 being Sunday.
# + startTime - The support hours' starting time of day
# + endTime - The support hours' ending time of day
public type SupportHour record {|
    string 'type?;
    string timeZone?;
    int[] dayOfWeek?;
    time:Time startTime?;
    time:Time endTime?;
|};

# Represents a pager duty incident schedule action.
# + type - The type of scheduled action. (Valid option: `urgencyChange`)
# + at - Represents when scheduled action will occur.
# + urgency - The urgency (`high`, `low`)
public type ScheduledAction record {|
    Type 'type;
    At at;
    Urgency urgency;
|};

# Represents a pager duty incident schedule action.
# + type - The type of schedule action. (valid option: `namedTime`)
# + name - Designates either the start or the end of the scheduled action
#          (valid option: `supportHoursStart` or `supportHoursEnd`)
public type At record {|
    Type 'type;
    Name name;
|};

# Represents a pager duty integration.
# + id - The integration id
# + summary -  A short-form, server-generated string that provides succinct, important information about an
#              object suitable for primary labeling of an entity in a client
# + email - This is the unique fully-qualified email address used for routing emails to this integration for processing
# + key - This is the unique key used to route events to this integration when received via the PagerDuty Events API
# + url - the API show URL at which the object is accessible
# + htmlUrl - a URL at which the entity is uniquely displayed in the Web app
# + type - The type of schedule action. Must be set one of these (`awsCloudwatchInboundIntegration`,
#          `awsCloudwatchInboundIntegrationReference`, `cloudkickInboundIntegration`,
#          `cloudkickInboundIntegrationReference`, `eventTransformerAPIInboundIntegration`,
#          `eventTransformerApiInboundIntegrationReference`, `genericEmailInboundIntegration`,
#          `genericEmailInboundIntegrationReference`, `genericEventsAPIInboundIntegration`,
#          `genericEventsAPIInboundIntegrationReference`, `keynoteInboundIntegration`,
#          `keynoteInboundIntegrationReference`, `nagiosInboundIntegration`, `nagiosInboundIntegrationReference`,
#          `pingdomInboundIntegration`, `pingdomInboundIntegrationReference`, `sqlMonitorInboundIntegration`,
#          `sqlMonitorInboundIntegrationReference`)
# + name - The name of this integration
# + service - The service that the integration belongs to
# + createdAt - The date/time when this integration was created
# + vendor - The vendor of the integration should integrate with (e.g Datadog or Amazon Cloudwatch)
public type Integration record {|
    Type 'type;
    string summary?;
    string email?;
    string key?;
    string id?;
    string url?;
    string htmlUrl?;
    string name?;
    Service 'service?;
    time:Time createdAt?;
    Common vendor?;

|};

# Represents a pager duty extension.
# + name - The name of the extension
# + id - The extension id
# + type - The type of object being created
# + endpointUrl - The url of the extension
# + services - An array of service for which the extension applies
# + extensionSchema - This is the schema for this extension
# + summary -  A short-form, server-generated string that provides succinct, important information about an
#              object suitable for primary labeling of an entity in a client
# + url - The URL at which the object is accessible
# + htmlUrl - A URL at which the entity is uniquely displayed in the Web app
public type Extension record {|
    string name;
    Type 'type;
    Service[] services;
    Common extensionSchema;
    string id?;
    string summary?;
    string endpointUrl?;
    string url?;
    string htmlUrl?;
|};

# Represents a pager duty incident.
# + id - The ID of the incident
# + type - A string that determines the schema of the object (valid options: `incident` or `incidentReference`)
# + summary -  A short-form, server-generated string that provides succinct, important information about an
#              object suitable for primary labeling of an entity in a client
# + url - The URL at which the object is accessible
# + htmlUrl - A URL at which the entity is uniquely displayed in the Web app
# + incidentNumber - The number of the incident
# + createdAt - The date/time the incident was first triggered
# + status - The current status of the incident (valid options: `triggered`,`acknowledged` or `resolved`)
# + title - A succinct description of the nature, symptoms, cause, or effect of the incident
# + pendingActions - The list of pending_actions on the incident
# + incidentKey - The incident's de-duplication key
# + service - The service that the incident belongs to
# + conferenceNumber - An URL for the conference bridge
# + conferenceUrl - An URL for the conference bridge
# + triggeredCount - The count of triggered alerts
# + resolvedCount - The count of resolved alerts
# + allCount - The total count of alerts
# + resolution - The resolution for this incident if status is set to resolved.
# + assignments - List of all assignments for this incident
# + assignedVia - How the current incident assignments were decided
# + acknowledgements - List of all acknowledgements for this incident
# + lastStatusChangeAt - The time at which the status of the incident last changed
# + lastStatusChangeBy - The user or service which is responsible for the incident’s last status change
# + firstTriggerLogEntry -  The first trigger log entry for this incident
# + escalationPolicy - The escalation policy that the incident is currently following
# + teams - The teams involved in the incident’s lifecycle.
# + priority - The priority for this incident
# + urgency - The current urgency of the incident. (valid options: `high` or `low`)
# + resolveReason - The reason the incident was resolved
# + body - String describing the incident
public type Incident record {|
    string title;
    Type 'type ;
    Service 'service;
    string id?;
    string summary?;
    string url?;
    string htmlUrl?;
    int incidentNumber?;
    time:Time createdAt?;
    string status?;
    string incidentKey?;
    string assignedVia?;
    string conferenceNumber?;
    string conferenceUrl?;
    int triggeredCount?;
    int resolvedCount?;
    int allCount?;
    string resolution?;
    Assignment[] assignments?;
    Common lastStatusChangeAt?;
    Urgency urgency?;
    PendingAction[] pendingActions?;
    Common[] priority?;
    Acknowledgement[] acknowledgements?;
    Common[] lastStatusChangeBy?;
    Common[] firstTriggerLogEntry?;
    EscalationPolicy escalationPolicy?;
    Common[] teams?;
    ResolveReason resolveReason?;
    Body body?;
|};

# Represents a pager duty pending action.
# + type - A string that determines the schema of the object(Valid options: `unacknowledge`, `escalate`, `resolve`
#          ,`urgencyChange`)
# + at - Time at which the action was created
public type PendingAction record {|
    string 'type;
    time:Time at;
|};

# Represents a pager duty resolve reason.
# + type - The reason the incident was resolved
# + incident -  The list of  incident
public type ResolveReason record {|
    Type 'type;
    Common[] incident?;
|};

# Represents a pager duty acknowledgement.
# + at - Time at which the acknowledgement was created
# + acknowledger -The acknowledger represents the entity that made the acknowledgement for an incident
public type Acknowledgement record {|
    time:Time at?;
    Common acknowledger?;
|};

# Represents a pager duty assignment.
# + at - Time at which the assignment was created
# + assignee - User that was assigned
public type Assignment record {|
    time:Time at?;
    User assignee?;
|};

# Represents a pager duty body.
# + type - A string that determines the schema of the object
# + details - Additional incident details
public type Body record {|
    Type 'type;
    string details?;
|};

# Represents a pager duty note.
# + id -The ID of the note
# + user -The user the note was sent to
# + content - The note content
# + createdAt - The time at which the note was submitted
public type Note record {|
    string id?;
    Common user?;
    string content?;
    time:Time createdAt?;
|};

# Possible type of parameters that can be passed into the `ContactType`.
public type ContactType SMS|EMAIL|INPUT_PHONE|PUSH_NOTIFICATION;

# Possible type of parameters that can be passed into the `Label`.
public type Label INPUT_WORK|INPUT_PHONE|INPUT_HOME|INPUT_SKYPE;

# Possible type of parameters that can be passed into the `Urgency`.
public type Urgency HIGH|LOW|SUPPRESSED|SEVERITYBASED;

# Possible type of parameters that can be passed into the `Role`.
public type Role ADMIN|LIMITEDUSER|USER|OBSERVER|OWNER|READONLYUSER|RESTRICTEDACCESS|READONLYLIMITEDUSER;

# Possible type of parameters that can be passed into the `Type`.
public type Type INCIDENT|SCHEDULE|INTEGRATION|TEAM|ASSIGNMENTNOTIFICATIONRULE|UNACKNOWLEDGE|RESOLVE|ESCALATE|
URGENCYCHANGE|MERGERESOLVEREASON|INCIDENTBODY|DAILYRESTRICTION|WEEKLYRESTRICTION|NAMEDTIME|CONTACTMETHODS|
NOTIFICATIONRULES|ESCALATIONRULES|EXTENSION_SCHEMA|EXTENSIONOBJECTS|CONSTANT|USESUPPORTHOURS|AWSCLOUD|
AWSCLOUDREFERENCE|CLOUD_KICK|CLOUDKICKREFERENCE|EVENTTRANSFORMERAPI|EVENTTRANSFORMERAPIREFERENCE|KEYNOTE|
KEYNOTEREFERENCE|NAGIOSREFERENCE|PINGDOMINTEGRATION|PINGDOMREFERENCE|SQLMONITOR|SQLMONITORREFERENCE|
INCIDENT_REFERENCE|TEAMREFERENCE|SMS|EMAIL|INPUT_PHONE|PUSH_NOTIFICATION|RESOLVE|ESCALATE|ESCALATIONPOLICY|
SERVICEREFERENCE|SERVICES|FIXEDTIMEPERDAY|USER|EMAILREFERENCE|EVENTSAPIREFERENCE|NAGIOSINTEGRATION|EVENTSAPI|
EMAILINBOUND|EXTENSION|WEBHOOK|EXTENSIONSCHEMAREF|EXTENSIONSCHEMA|VENDOR|VENDORREFERENCE|INCIDENTADDONS|FULLPAGEADDONS|
SERVICE|INCIDENTREFERENCE|USERREFERENCE|EVENTAPIV2;

# Possible type of parameters that can be passed into the `Include`.
public type Include CONTACTMETHODS|NOTIFICATIONRULES|TEAMS|ESCALATIONRULES|EXTENSION_SCHEMAS|EXTENSION_OBJECTS;

# Possible type of parameters that can be passed into the `OnCallHandoffNotifications`.
public type OnCallHandoffNotifications HAS_SERVICE|ALWAYS;

# Possible type of parameters that can be passed into the `Name`.
public type Name FINALSCHEDULE|OVERIDE|SUPPORTHOURSEND|SUPPORTHOURSSTART;

# Possible type of parameters that can be passed into the `Group`.
public type Group INTELLIGENT|TIME;

# Possible type of parameters that can be passed into the `Status`.
public type Status ACTIVE|WARNING|CRITICAL|MAINTENANCE|DISABLED;

# Possible type of parameters that can be passed into the `AlertCreation`.
public type AlertCreation CREATEINCIDENTS|CREATEALERTINCIDENTS;
