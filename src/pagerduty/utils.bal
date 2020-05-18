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

function get(http:Client pagerdutyClient, string path) returns @tainted map<json>|Error {
    http:Response|error response = pagerdutyClient->get(path);
    return handleResponse(response);
}

function put(http:Client pagerdutyClient, http:Request req, string path) returns @tainted map<json>|Error {
    http:Response|error response = pagerdutyClient->put(path, req);
    return handleResponse(response);
}

function post(http:Client pagerdutyClient, http:Request req, string path) returns @tainted map<json>|Error {
    http:Response|error response = pagerdutyClient->post(path, req);
    if (response is error) {
        return createResError(response);
    } else {
        if(response.getHeader(RES_STATUS) == CREATED) {
            return <map<json>>response.getJsonPayload();
        } else {
            return createError(response);
        }
    }
}

function delete(http:Client pagerdutyClient, string path) returns @tainted Error? {
    http:Response|error response = pagerdutyClient->delete(path);
    if (response is error) {
        return createResError(response);
    } else {
        if(response.getHeader(RES_STATUS) != DELETED) {
            return createError(response);
        }
    }
}

function  handleResponse(http:Response|error response) returns @tainted map<json>|Error {
	 if (response is error) {
         return createResError(response);
     } else {
         if(response.getHeader(RES_STATUS) == OK) {
             return <map<json>>response.getJsonPayload();
         } else {
             return createError(response);
         }
     }
}

function createResError(error errorResponse) returns Error {
    return Error(message = "Error received from the pagerduty server", cause = errorResponse);
}

function createError(http:Response resp) returns  @tainted Error {
    map<json> output = <map<json>>resp.getJsonPayload();
    return Error(message =  "Error received from the pagerduty server ", cause = error(PAGERDUTY_ERROR,
                 message = output["error"].toString());
}

function setJsonPayload(map<json>|error|json[] data, http:Request request, string key) {
    map<json> payload = {};
	if (data is map<json>|json[]) {
	    payload[key] = data;
        json|error jsonPayload = json.constructFrom(payload);
        if (jsonPayload is json) {
            request.setJsonPayload(jsonPayload);
        }
    }
}
