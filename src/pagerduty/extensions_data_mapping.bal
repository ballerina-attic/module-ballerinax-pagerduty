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

function convertToExtension(map<json> input) returns @tainted Extension {
    Extension extension = { 'type: "extension", name: "", 'services: [], extensionSchema: {
                            'type: "extension", id: ""}};
    string value = input[TYPE].toString();
    if (value == CONSTANT) {
        extension[TYPE] = CONSTANT;
    } else if (value == USE_SUPPORT_HOURS_VAR) {
        extension[TYPE] = USE_SUPPORT_HOURS;
    }
    addString(input[NAME], extension, NAME);
    addString(input[ID], extension, ID);
    addString(input[ENDPOINT_URL], extension, ENDPOINT_URL_VAR);
    addString(input[SELF], extension, URL);
    addString(input[HTML_URL_VAR], extension, HTML_URL);
    Service[]? services = convertToServices(input, EXTENSION_OBJECTS_VAR);
    if (services is Service[]) {
        extension[SERVICES] = services;
    }
    var extensionSchema = input[EXTENSION_SCHEMA_VAR];
    if (extensionSchema.toString() != "") {
        extension[EXTENSION_SCHEMA] = convertToCommon(<map<json>>extensionSchema);
    }
    return extension;
}

function extensionToPayload(Extension extension) returns @tainted map<json> {
    map<json> payload = {};
    string value = "";
    value = extension[TYPE].toString();
    if (value == CONSTANT) {
        payload[TYPE] = CONSTANT;
    } else if (value == USE_SUPPORT_HOURS_VAR) {
        payload[TYPE] = USE_SUPPORT_HOURS;
    }
    addStringToPayload(extension[NAME], payload, NAME);
    addStringToPayload(extension[ID], payload, ID);
    addStringToPayload(extension[SUMMARY], payload, SUMMARY);
    addStringToPayload(extension[ENDPOINT_URL], payload, ENDPOINT_URL_VAR);
    addStringToPayload(extension[URL], payload, SELF);
    addStringToPayload(extension[HTML_URL], payload, HTML_URL_VAR);
    servicesToPayload(extension[SERVICES], payload, EXTENSION_OBJECTS_VAR);
    payload[EXTENSION_SCHEMA_VAR] = commonToPayload(extension[EXTENSION_SCHEMA]);
    return payload;
}
