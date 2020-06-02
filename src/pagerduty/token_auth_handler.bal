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

import ballerina/auth;
import ballerina/http;
import ballerina/log;

# Representation of the Token Auth header handler for outbound HTTP traffic.
#
# + authProvider - The `http:OutboundAuthProvider` instance
public type TokenAuthHandler object {

    *http:OutboundAuthHandler;

    public auth:OutboundAuthProvider authProvider;

    public function __init(auth:OutboundAuthProvider authProvider) {
      self.authProvider = authProvider;
    }

    # Prepares the request with the Token Auth header.
    #
    # + req - The`Request` instance
    # + return - Returns the updated `http:Request` instance or the `http:AuthenticationError` in case of an error
    public function prepare(http:Request req) returns http:Request|http:AuthenticationError {
        auth:OutboundAuthProvider authProvider = self.authProvider;
        string|auth:Error token = authProvider.generateToken();
        if (token is string) {
            req.setHeader(http:AUTH_HEADER, AUTH_SCHEME_TOKEN + TOKEN + token);
            return req;
        } else {
            return prepareAuthenticationError("Failed to prepare request at token auth handler.", token);
        }
    }

    # Inspects the request and response and calls the Auth provider for inspection.
    #
    # + req - The `http:Request` instance
    # + resp - The `http:Response` instance
    # + return - The updated `http:Request` instance, an `http:AuthenticationError` in case of an error,
    #                 or else `()` if nothing is to be returned
    public function inspect(http:Request req, http:Response resp) returns http:Request|http:AuthenticationError? {
        auth:OutboundAuthProvider authProvider = self.authProvider;
        map<anydata> headerMap = createResponseHeaderMap(resp);
        string|auth:Error? token = authProvider.inspect(headerMap);
        if (token is string) {
            req.setHeader(http:AUTH_HEADER, AUTH_SCHEME_TOKEN + TOKEN + token);
            return req;
        } else if (token is auth:Error) {
            return prepareAuthenticationError("Failed to inspect at token auth handler.", token);
        }
        return;
    }
};

# Logs, prepares, and returns the `AuthenticationError`.
#
# + message -The error message
# + err - The `error` instance
# + return - The prepared `http:AuthenticationError` instance
function prepareAuthenticationError(string message, auth:Error? err = ()) returns http:AuthenticationError {
    log:printDebug(function () returns string { return message; });
    if (err is error) {
        http:AuthenticationError preparedError = error(http:AUTHN_FAILED, message = message, cause = err);
        return preparedError;
    }
    http:AuthenticationError preparedError = error(http:AUTHN_FAILED, message = message);
    return preparedError;
}

# Creates a map out of the headers of the HTTP response.
#
# + resp - The `Response` instance
# + return - Returns the map of the response headers
function createResponseHeaderMap(http:Response resp) returns @tainted map<anydata> {
    map<anydata> headerMap = { STATUS_CODE: resp.statusCode };
    string[] headerNames = resp.getHeaderNames();
    foreach string header in headerNames {
        string[] headerValues = resp.getHeaders(<@untainted> header);
        headerMap[header] = headerValues;
    }
    return headerMap;
}
