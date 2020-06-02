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

# A record type defined to be used as the "error detail" in the errors defined in this module.
#
# + message - A message describing the error in detail
# + cause - The error, which caused this error (if any)
# + errorCode - The pagerduty error code
type Detail record {
    string message;
    error cause?;
    int errorCode?;
};

# Represents the PagerDuty error reason.
public const PAGERDUTY_ERROR = "{ballerinax/pagerduty}Error";

# Represents the PagerDuty error type with details.
public type Error error<PAGERDUTY_ERROR, Detail>;
