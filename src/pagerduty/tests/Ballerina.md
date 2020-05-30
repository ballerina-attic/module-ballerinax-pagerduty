# Compatibility

|                             |           Version           |
|:---------------------------:|:---------------------------:|
| Ballerina Language          |            1.2.X            |
| PagerDuty REST API          |            v2               |

## Prerequisites

- Download and install [Ballerina](https://ballerinalang.org/downloads/).
- Get the [Personal REST API Key](https://support.pagerduty.com/docs/generating-api-keys#section-generating-a-personal-rest-api-key).

## Running the tests

You can use the `tests.bal` file to test all the connector actions by following the below steps:

- Create `ballerina.conf` file in the module-ballerinax-pagerduty.
- Obtain the `personal API key` as mentioned above and add that values in the ballerina.conf file.
    ```ballerina
    PAGERDUTY_API_TOKEN = "USER_API_TOKEN"
  ```ballerina
    
- Navigate to the folder module--ballerinax-pagerduty.
- Run the following commands to execute the tests.
   ```ballerina
   ballerina test pagerduty --b7a.config.file=<ballerina_conf-file_path>
   ```