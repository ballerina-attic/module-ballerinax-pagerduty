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

import ballerina/time;

# Represents a PagerDuty user.
#
# + name - The name of the user
# + email - The user's email address
# + type - The type of the object:`user` or `userReference`. The default value is `user`
# + id - The ID of the user
# + timeZone - The preferred time zone name (e.g., Asia/Colombo). If '()', the account's time zone will be used
# + color - The schedule color
# + avatarUrl - The URL of the user’s avatar
# + url - A URL at which the object is accessible
# + description - The user's bio
# + role - The user role: `admin`, `limitedUser`, `observer`, `owner`, `readOnlyUser`, `restrictedAccess`,
#          `readOnlyLimitedUser`, or `user`
# + invitationSent - If true, the user has an outstanding invitation
# + jobTitle - The user's job title
# + htmlUrl - A URL at which the entity is uniquely displayed in the Web app
# + summary -  A short-form, server-generated string that provides succinct, important information about an
#              object suitable for primary labeling of an entity in a client
# + teams - The list of teams to which the user belongs
# + contactMethods - The list of contact methods of this user
# + notificationRules - The list of notification rules of this user
# + coordinatedIncidents - The list of incidents of this user
public type User record {|
    string name;
    string email;
    Type 'type?;
    string id?;
    string timeZone?;
    string color?;
    string url?;
    Role role?;
    string avatarUrl?;
    string description?;
    boolean invitationSent?;
    string jobTitle?;
    string htmlUrl?;
    string summary?;
    CommonRecord[] teams?;
    ContactMethod[] contactMethods?;
    NotificationRule[] notificationRules?;
    Incident[] coordinatedIncidents?;
|};

# Represents a common Pager Duty property.
#
# + type  - A string, which determines the schema of the object
# + id - The ID of the object
# + summary -  A short-form, server-generated string, which provides succinct, important information about an
#              object suitable for primary labeling of an entity in a client
# + url - A URL by which the object is accessible
# + htmlUrl - A URL by which the entity is displayed uniquely in the Web app
public type CommonRecord record {|
    Type 'type;
    string id;
    string summary?;
    string url?;
    string htmlUrl?;
|};

# Represents a Pager Duty contact method.
#
# + type  - A string, which determines the schema of the object:`email`, `phone`, `pushNotification`, or `sms`
# + address - The "address" to deliver: email, phone number, etc. depending on the type.
# + id - The ID of the contact method
# + label -  The label, which can take `work`, `mobile`, `home`, or `skype`
# + countryCode - A country code of the phone number
# + summary -  A short-form, server-generated string, which provides succinct, important information about an
#              object suitable for primary labeling of an entity in a client
# + url - A URL by which the object is accessible
# + htmlUrl - A URL by which the entity is displayed uniquely in the Web app
# + enabled - If true, this phone is capable of receiving SMS messages
# + blacklisted - If true, this phone has been blacklisted by PagerDuty and no messages will be sent to it
# + sendShortEmail - if true, send an abbreviated email message instead of the standard email output
public type ContactMethod record {|
    Type 'type;
    string address;
    string id?;
    Label label?;
    int countryCode?;
    string summary?;
    string url?;
    string htmlUrl?;
    string enabled?;
    string blacklisted?;
    boolean sendShortEmail?;
|};

# Represents a Pager Duty notification rule.
#
# + startDelayInMinutes - The delay before firing the rule in minutes.
# + contactMethod - A contact method
# + type  - A string, which determines the schema of the object. Must be set to `assignmentNotificationRule`
# + id - The ID of the notification rule
# + urgency - The urgency of the incident:`high` or `low`
# + summary -  A short-form, server-generated string, which provides succinct, important information about an
#              object suitable for primary labeling of an entity in a client
# + url - A URL by which the object is accessible
# + htmlUrl - A URL by which the entity is displayed uniquely in the Web app
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

# Represents a Pager Duty escalation policy.
#
# + name - The name of the escalation policy
# + escalationRules - An `EscalationRule`
# + type  - The type of the `EscalationPolicy`: an `escalationPolicy` value
# + id - The ID of the notification rule
# + summary -  A short-form, server-generated string, which provides succinct, important information about an
#              object suitable for primary labeling of an entity in a client
# + url - A URL by which the object is accessible
# + description - A human-friendly description of the escalation policy
# + htmlUrl - A URL by which the entity is displayed uniquely in the Web app
# + numberOfloops - The number of times the escalation policy will repeat after reaching the end of its escalation
# + services - The list of services
# + teams - Teams associated with the policy. The teams of the account must have the ability to use this parameter
# + onCallHandoffNotifications - Determines the frequency of sending the on-call, handoff notifications for users
#                                of the escalation policy: `ifHasServices` or `always`).
#                                The default value is  `ifHasServices`
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
      OnCallHandoffNotifications onCallHandoffNotifications?;
      Service[] services?;
      CommonRecord[] teams?;
|};

# Represents a Pager Duty escalation rule.
#
# + escalationDelayInMinutes - The number of minutes before an unacknowledged incident escalates from this rule
# + targets - The list of `CommonRecord`s type: `user`, `schedule`, `userReference`, or `scheduleReference`
# + id - An ID of the notification rule
public type EscalationRule record {|
    int escalationDelayInMinutes;
    CommonRecord[] targets;
    string id?;
|};

# Represents a Pager Duty schedule.
#
# + type - The type of the schedule object: `schedule` or `scheduleReference`
# + timeZone - The time zone of the schedule (e.g., Asia/Colombo)
# + scheduleLayers - A list of schedule layers
# + id - An ID of the notification rule
# + name - The name of the schedule
# + summary -  A short-form, server-generated string, which provides succinct, important information about an
#              object suitable for primary labeling of an entity in a client
# + url - A URL by which the object is accessible
# + htmlUrl - A URL by which the entity is displayed uniquely in the Web app
# + description - The description of the schedule
# + escalationPolicies - An array of all of the escalation policies, which use this schedule
# + finalSchedule - The final layer is a special layer, which contains the result of all of the previous layers put
#                   together.
# + overridesSubschedule - The override layer is a special layer in which all of the override entries are stored
# + users - An array of all of the users of the schedule
# + teams - An array of all of the teams of the schedule
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
    CommonRecord[] teams?;
|};

# Represents a Pager Duty schedule layer.
#
# + start - The start time of this layer
# + users - The ordered list of users of this layer. The position of the user on the list determines
#           its order in the layer
# + rotationVirtualStart - The effective start time of the layer
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

# Represents a Pager Duty restriction.
#
# + type - The type of the restriction: `dailyRestriction` or `weeklyRestriction`
# + startDayOfWeek - The number of the day on when the restriction starts (e.g., from 1 to 7 where 1 is Monday
#                    and 7 is Sunday). This is required only to be used with a `weeklyRestriction`
# + durationInSeconds - The duration of the restriction in seconds
# + startTimeOfDay - The start time in the 'HH:mm:ss' format
public type Restriction record {|
    Type 'type;
    time:Time startTimeOfDay;
    int durationInSeconds;
    int startDayOfWeek?;
|};

# Represents a Pager dDuty final schedule.
#
# + name - The name of the sub-schedule: `finalSchedule` or `overrides`
# + renderedScheduleEntries - This is a list of entries on the computed layer for the current time range
# + renderedCoveragePercentage - The percentage of the time range covered by this layer
public type FinalSchedule record {|
    Name name;
    RenderedScheduleEntry[] renderedScheduleEntries?;
    int renderedCoveragePercentage?;
|};

# Represents the schedule entries that are rendered by Pager Duty.
#
# + start - The start time of this entry
# + end -  The end time of this entry. If '()', the entry does not end
# + user - The user
public type RenderedScheduleEntry record {|
    time:Time 'start;
    time:Time end;
    User user?;
|};

# Represents a Pager Duty service.
#
# + name - The name of the service
# + escalationPolicy - The escalation policy used by this service
# + type - The type of service: `service` or `serviceReference`
# + id -  An ID of the service
# + description - The user-provided description of the service
# + autoResolveTimeout - Time in seconds in which an incident is resolved automatically if left open for that long
# + acknowledgementTimeout - Time in seconds in which an incident changes to the triggered state after being
#                            acknowledged
# + createdAt - The date/time when this service was created
# + updatedAt - The date/time when this service was updated
# + status - The current state of the service
# + summary -  A short-form, server-generated string, which provides succinct, important information about an
#              object suitable for primary labeling of an entity in a client
# + url - A URL by which the object is accessible
# + htmlUrl - A URL by which the entity is displayed uniquely in the Web app
# + lastIncidentTimestamp - The date/time when the most recent incident was created for this service
# + teams - The set of teams associated with this service
# + integrations - An array containing the integration objects, which belong to this service
# + incidentUrgencyRule - The default urgency for new incidents
# + supportHours - The support hours for the service. When using type = `useSupportHours` in the `incidentUrgencyRule`,
#                  specify exactly one. Otherwise, this is optional
# + scheduledActions - An array containing the scheduled actions for the service
# + addons -  The array of the add-ons associated with this service
# + alertCreation - Whether a service creates only incidents or both alerts and incidents: `createIncidents` or
#                   `createAlertsAndIncidents`
# + alertGrouping -  Defines how alerts on this service will be automatically grouped into incidents
# + alertGroupingTimeout - The duration (in minutes) within which the incoming alerts will be grouped automatically
public type Service record {|
    string name;
    EscalationPolicy escalationPolicy;
    Type 'type?;
    string id?;
    string description?;
    int autoResolveTimeout? ;
    int acknowledgementTimeout?;
    time:Time createdAt?;
    time:Time updatedAt?;
    Status status?;
    string summary?;
    string url?;
    string htmlUrl?;
    time:Time lastIncidentTimestamp?;
    CommonRecord[] teams?;
    Integration[] integrations?;
    IncidentUrgencyRule  incidentUrgencyRule?;
    SupportHour supportHours?;
    ScheduledAction[] scheduledActions?;
    CommonRecord[] addons?;
    AlertCreation alertCreation?;
    Group alertGrouping?;
    int alertGroupingTimeout?;
|};

# Represents an urgency rule of a Pager Duty incident.
#
# + type -  The type of the incident urgency:`constant` or `useSupportHours`
# + urgency - The incidents' urgency:`high`, `low`, or `severityBased`
# + duringSupportHours - The incidents' urgency during support hours
# + outsideSupportHours - The incidents' urgency outside of support hours
public type IncidentUrgencyRule record {|
    Type 'type?;
    Urgency urgency?;
    IncidentSupportHour duringSupportHours?;
    IncidentSupportHour outsideSupportHours?;
|};

# Represents the support hours of a Pager Duty incident.
#
# + type -  The type of the incident urgency
# + urgency - The incidents' urgency: `high` or `low`
public type IncidentSupportHour record {|
  Type 'type?;
  Urgency urgency?;
|};

# Represents the support hours of Pager Duty .
#
# + type - The type of the support hours: `fixedTimePerDay`
# + timeZone - The time zone of the support hours (e.g., Asia/Colombo)
# + daysOfWeek - Array of the days of the week as integers (valid options: 1 to 7 with 1 being Monday and 7 being Sunday)
# + startTime - The starting time of the day during the support hours (valid format: "HH:mm:00")
# + endTime - The ending time of the day during the support hours (valid format: "HH:mm:00")
public type SupportHour record {|
    string 'type?;
    string timeZone?;
    int[] daysOfWeek?;
    time:Time startTime?;
    time:Time endTime?;
|};

# Represents a schedule action of a Pager Duty.
#
# + type - The type of the scheduled action: `urgencyChange`
# + at - Represents when the scheduled action will occur
# + urgency - The urgency: `high` or `low`
public type ScheduledAction record {|
    Type 'type;
    At at;
    Urgency urgency;
|};

# Represents an at of a Pager Duty.
#
# + type - The type of the schedule action: `namedTime`
# + name - Designates either the start or the end of the scheduled action: `supportHoursStart` or `supportHoursEnd`
public type At record {|
    Type 'type;
    Name name;
|};

# Represents a Pager Duty integration.
#
# + type - The type of the schedule action: `awsCloudwatchInboundIntegration`,
#          `awsCloudwatchInboundIntegrationReference`, `cloudkickInboundIntegration`,
#          `cloudkickInboundIntegrationReference`, `eventTransformerAPIInboundIntegration`,
#          `eventTransformerApiInboundIntegrationReference`, `genericEmailInboundIntegration`,
#          `genericEmailInboundIntegrationReference`, `genericEventsAPIInboundIntegration`,
#          `genericEventsAPIInboundIntegrationReference`, `keynoteInboundIntegration`,
#          `keynoteInboundIntegrationReference`, `nagiosInboundIntegration`, `nagiosInboundIntegrationReference`,
#          `pingdomInboundIntegration`, `pingdomInboundIntegrationReference`, `sqlMonitorInboundIntegration`, or
#          `sqlMonitorInboundIntegrationReference`
# + id - The integration ID
# + summary - A short-form, server-generated string, which provides succinct, important information about an
#              object suitable for primary labeling of an entity in a client
# + email - This is the unique, fully-qualified email address used for routing emails to this integration for processing
# + key - This is the unique key used to route events to this integration when received via the PagerDuty Events API
# + url - the API URL by which the object is accessible
# + htmlUrl - a URL by which the entity is displayed uniquely in the Web app
# + name - The name of this integration
# + service - The service to which the integration belongs
# + createdAt - The date/time when this integration was created
# + vendor - The vendor to integrate with (e.g., Datadog or Amazon Cloudwatch)
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
    CommonRecord vendor?;

|};

# Represents a Pager Duty extension.
#
# + name - The name of the extension
# + id - The extension ID
# + type - The type of the object being created: `extension`
# + endpointUrl - The URL of the extension
# + services - An array of services to which the extension applies
# + extensionSchema - The schema of this extension
# + summary - A short-form, server-generated string, which provides succinct, important information about an
#             object suitable for primary labeling of an entity in a client
# + url - The URL by which the object is accessible
# + htmlUrl - A URL by which the entity is displayed uniquely in the Web app
public type Extension record {|
    string name;
    Type 'type;
    Service[] services;
    CommonRecord extensionSchema;
    string id?;
    string summary?;
    string endpointUrl?;
    string url?;
    string htmlUrl?;
|};

# Represents a Pager Duty incident.
#
# + id - The ID of the incident
# + type - A string, which determines the schema of the object: `incident` or `incidentReference`
# + service - The service to which the incident belongs
# + summary -  A short-form, server-generated string, which provides succinct, important information about an
#              object suitable for primary labeling of an entity in a client
# + url - The URL by which the object is accessible
# + htmlUrl - A URL by which the entity is displayed uniquely in the Web app
# + incidentNumber - The number of the incident
# + createdAt - The date/time the incident was first triggered
# + status - The current status of the incident: `triggered`,`acknowledged`, or `resolved`
# + title - A succinct description of the nature, symptoms, cause, or effect of the incident
# + pendingActions - The list of pending actions of the incident
# + incidentKey - The incident's de-duplication key
# + conferenceNumber - The number of the conference bridge
# + conferenceUrl - The URL of the conference bridge
# + description - The user-provided description of the service
# + triggeredCount - The count of triggered alerts
# + resolvedCount - The count of resolved alerts
# + allCount - The total count of alerts
# + impactedServices - The list of services
# + resolution - The resolution of this incident if status is set to resolved
# + assignments - List of all the assignments of this incident
# + assignedVia - How the current incident assignments were decided
# + acknowledgements - List of all the acknowledgements of this incident
# + lastStatusChangeAt - The time at which the status of the incident was changed last
# + lastStatusChangeBy - The user or service, which is responsible for the incident’s last status change
# + firstTriggerLogEntry -  The first trigger log entry for this incident
# + escalationPolicy - The escalation policy, which the incident is currently following
# + teams - The teams involved in the incident’s lifecycle.
# + priority - The priority for this incident
# + urgency - The current urgency of the incident: `high` or `low`
# + resolveReason - The reason the incident was resolved
# + body - Additional incident details
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
    string description?;
    int triggeredCount?;
    int resolvedCount?;
    int allCount?;
    CommonRecord[] impactedServices?;
    string resolution?;
    Assignment[] assignments?;
    time:Time lastStatusChangeAt?;
    Urgency urgency?;
    PendingAction[] pendingActions?;
    CommonRecord priority?;
    Acknowledgement[] acknowledgements?;
    CommonRecord lastStatusChangeBy?;
    CommonRecord firstTriggerLogEntry?;
    EscalationPolicy escalationPolicy?;
    CommonRecord[] teams?;
    ResolveReason resolveReason?;
    Body body?;
|};

# Represents a Pager Duty pending action.
#
# + type - A string, which determines the schema of the object: `unacknowledge`, `escalate`, `resolve`,
#         or `urgencyChange`
# + at - Time at which the action was created
public type PendingAction record {|
    string 'type;
    time:Time at;
|};

    # Represents the resolved reason of a Pager Duty incident..
#
# + type - The reason the incident was resolved
# + incident -  The list of incidents
public type ResolveReason record {|
    Type 'type;
    CommonRecord[] incident?;
|};

# Represents a Pager Duty acknowledgement.
#
# + at - Time at which the acknowledgement was created
# + acknowledger - The acknowledger represents the entity, which made the acknowledgement for an incident
public type Acknowledgement record {|
    time:Time at?;
    CommonRecord acknowledger?;
|};

# Represents a Pager Duty assignment.
#
# + at - Time at which the assignment was created
# + assignee - User who was assigned
public type Assignment record {|
    time:Time at?;
    User assignee?;
|};

# Represents a Pager Duty body.
#
# + type - A string, which determines the schema of the object
# + details - Additional incident details
public type Body record {|
    Type 'type;
    string details?;
|};

# Represents a Pager Duty note.
#
# + id -The ID of the note
# + user -The user the note was sent to
# + content - The note content
# + createdAt - The time at which the note was submitted
public type Note record {|
    string id?;
    CommonRecord user?;
    string content?;
    time:Time createdAt?;
|};

# Possible types of parameters that can be passed into the `ContactType`.
public type ContactType SMS|EMAIL|INPUT_PHONE|PUSH_NOTIFICATION|CONTACT_METHOD;

# Possible types of parameters that can be passed into the `Label`.
public type Label INPUT_WORK|INPUT_PHONE|INPUT_HOME|INPUT_SKYPE;

# Possible types of parameters that can be passed into the `Urgency`.
public type Urgency HIGH|LOW|SUPPRESSED|SEVERITY_BASED;

# Possible types of parameters that can be passed into the `Urgency`.
public type Role ADMIN|LIMITED_USER|USER|OBSERVER|OWNER|READ_ONLY_USER|RESTRICTED_ACCESS|READ_ONLY_LIMITED_USER;

# Possible types of parameters that can be passed into the `Type`.
public type Type INCIDENT|SCHEDULE|INTEGRATION|TEAM|ASSIGNMENT_NOTIFICATION_RULE|UNACKNOWLEDGE|RESOLVE|ESCALATE|
URGENCY_CHANGE|MERGE_RESOLVE_REASON|INCIDENT_BODY|DAILY_RESTRICTION|WEEKLY_RESTRICTION|NAMED_TIME|CONTACT_METHODS|
NOTIFICATION_RULES|ESCALATION_RULES|EXTENSION_SCHEMA|EXTENSION_OBJECTS|CONSTANT|USE_SUPPORT_HOURS|AWS_CLOUD|
AWS_CLOUD_REFERENCE|CLOUD_KICK|CLOUD_KICK_REFERENCE|EVENT_TRANSFORMER_API|EVENT_TRANSFORMER_API_REFERENCE|KEY_NOTE|
KEY_NOTE_REFERENCE|NAGIOS_REFERENCE|PINGDOM_INTEGRATION|PINGDOM_REFERENCE|SQL_MONITOR|SQL_MONITOR_REFERENCE|
INCIDENT_REFERENCE|TEAM_REFERENCE|SMS|EMAIL|INPUT_PHONE|PUSH_NOTIFICATION|RESOLVE|ESCALATE|ESCALATION_POLICY|
SERVICE_REFERENCE|SERVICES|FIXED_TIME_PER_DAY|USER|EMAIL_REFERENCE|EVENTS_API_REFERENCE|NAGIOS_INTEGRATION|EVENTS_API|
EMAIL_INBOUND|EXTENSION|WEBHOOK|EXTENSION_SCHEMA_REF|EXTENSION_SCHEMA|VENDOR|VENDOR_REFERENCE|INCIDENT_ADDONS|
FULL_PAGE_ADDONS|SERVICE|INCIDENT_REFERENCE|USER_REFERENCE|EVENT_API_V2|PRIORITY_REFERENCE|ESCALATION_POLICY_REFERENCE|
CONTACT_METHOD;

# Possible types of parameters that can be passed into the `Include`.
public type Include CONTACT_METHODS|NOTIFICATION_RULES|TEAMS|ESCALATION_RULES|EXTENSION_SCHEMAS|EXTENSION_OBJECTS;

# Possible types of parameters that can be passed into the `OnCallHandoffNotifications`.
public type OnCallHandoffNotifications HAS_SERVICE|ALWAYS;

# Possible types of parameters that can be passed into the `Name`.
public type Name FINAL_SCHEDULE|OVERIDES|SUPPORT_HOUR_END|SUPPORT_HOURS_START;

# Possible types of parameters that can be passed into the `Group`.
public type Group INTELLIGENT|TIME;

# Possible types of parameters that can be passed into the `Group`.
public type Status ACTIVE|WARNING|CRITICAL|MAINTENANCE|DISABLED;

# Possible types of parameters that can be passed into the `Group`.
public type AlertCreation CREATE_INCIDENTS|CREATE_ALERT_INCIDENTS;
