# Compatibility

|                             |           Version           |
|:---------------------------:|:---------------------------:|
| Ballerina Language          |            1.2.X            |
| PagerDuty REST API          |            v2               |

## Prerequisites

- Download and install [Ballerina](https://ballerinalang.org/downloads/).
- Get the [Personal REST API Key](https://support.pagerduty.com/docs/generating-api-keys#section-generating-a-personal-rest-api-key).

## Running the tests

1. Configure the `Account` in the `main_test.bal` file to add the `Personal REST API Key`.

2. Execute the following commands inside the root folder.

    ```cmd
    $ ballerina build -c  pagerduty
    ```