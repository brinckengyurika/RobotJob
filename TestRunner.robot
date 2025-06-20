*** Settings ***
Library    String
Library    RequestsLibrary
Library    Collections
#Library    OperatingSystem
Library    BuiltIn
Library    json
Library    DateTime

*** Variables ***
### ${BROWSER}                Chrome
${TEST_TARGET}                https://petstore.swagger.io
#${TEST_TARGET}               http://rock64
#${USERNAME}                  test
#${PASSWORD}                  abc123
${BASE_PATH}                  v2
${MAXIMUM_EXECUTION_TIME}     1500

*** Keywords ***
POST REQUEST AND CHECK
    [Arguments]          ${hostname}    ${path}      ${body}     ${expected_response_code}     ${maximum_response_time}   ${set_suite}=True
    ${header}=           Create dictionary      Content-Type=application/json
    create session       positive_session       ${hostname}
    ${date_start} =      Get Current Date
    ${response}=         Post On Session        positive_session   ${BASE_PATH}/${path}   json=${body}   headers=${header}
    ${date_stop} =       Get Current Date
    ${request_time} =    Subtract Date From Date  ${date_stop}  ${date_start}
    IF  ${set_suite} == True
        ${response_json}     Evaluate  json.loads($response.content)
        Convert to Dictionary    ${response_json}
        Set Suite Variable   ${response_json}
    END
    ${request_msec} =    Evaluate    ${request_time} * 1000
    Should Be Equal      "${response.status_code}"     "${expected_response_code}"
    Should Be True       ${request_msec}<${maximum_response_time}

POST REQUEST AND CHECK FORM ENCODED
    [Arguments]          ${hostname}    ${path}      ${body}     ${expected_response_code}     ${maximum_response_time}   ${set_suite}=True
    ${header}=           Create dictionary      Content-Type=application/x-www-form-urlencoded
    create session       positive_session       ${hostname}
    ${date_start} =      Get Current Date
    ${response}=         Post On Session        positive_session   ${BASE_PATH}/${path}   data=${body}   headers=${header}
    ${date_stop} =       Get Current Date
    ${request_time} =    Subtract Date From Date  ${date_stop}  ${date_start}
    IF  ${set_suite} == True
        ${response_json}     Evaluate  json.loads($response.content)
        Convert to Dictionary    ${response_json}
        Set Suite Variable   ${response_json}
    END
    ${request_msec} =    Evaluate    ${request_time} * 1000
    Should Be Equal      "${response.status_code}"     "${expected_response_code}"
    Should Be True       ${request_msec}<${maximum_response_time}


PUT REQUEST AND CHECK
    [Arguments]          ${hostname}    ${path}      ${body}     ${expected_response_code}     ${maximum_response_time}   ${set_suite}=True
    ${header}=           Create dictionary      Content-Type=application/json
    create session       positive_session       ${hostname}
    ${date_start} =      Get Current Date
    ${response}=         Put On Session         positive_session   ${BASE_PATH}/${path}   json=${body}   headers=${header}
    ${date_stop} =       Get Current Date
    ${request_time} =    Subtract Date From Date  ${date_stop}  ${date_start}
    IF  ${set_suite} == True
        ${response_json}     Evaluate  json.loads($response.content)
        Convert to Dictionary    ${response_json}
        Set Suite Variable   ${response_json}
    END
    ${request_msec} =    Evaluate    ${request_time} * 1000
    Should Be Equal      "${response.status_code}"     "${expected_response_code}"
    Should Be True       ${request_msec}<${maximum_response_time}



IMAGE UPLOAD AND CHECK
    [Arguments]     ${hostname}     ${path}   ${id}         ${image_filename}   ${expected_response_code}     ${maximum_response_time}   ${set_suite}=True
    ${file}=             GET FILE FOR STREAMING UPLOAD      ${CURDIR}/${image_filename}
    ${files}=            CREATE DICTIONARY                  file    ${file}
    ${Header}            CREATE DICTIONARY                  accept=application/json
    create session       positive_session                   ${hostname}
    ${date_start} =      Get Current Date
    ${response}          POST ON SESSION                    positive_session    ${BASE_PATH}/${path}/${id}/uploadImage   files=${files}    headers=${Header}
    ${date_stop} =       Get Current Date
    ${request_time} =    Subtract Date From Date            ${date_stop}  ${date_start}
    IF  ${set_suite} == True
        ${response_json}     Evaluate  json.loads($response.content)
        Convert to Dictionary    ${response_json}
        Set Suite Variable   ${response_json}
    END
    ${request_msec} =    Evaluate                           ${request_time} * 1000
    Should Be Equal      "${response.status_code}"          "${expected_response_code}"
    Should Be True       ${request_msec}<${maximum_response_time}

GET REQUEST AND CHECK
    [Arguments]          ${hostname}    ${path}      ${arguments}     ${expected_response_code}     ${maximum_response_time}  ${set_suite}=True
    ${header}=           Create dictionary      Accept=application/json
    create session       positive_session       ${hostname}     headers=${header}
    ${date_start} =      Get Current Date
    ${response}=         Get On Session         positive_session   ${BASE_PATH}/${path}   params=${arguments}
    ${date_stop} =       Get Current Date
    ${request_time} =    Subtract Date From Date  ${date_stop}  ${date_start}
    IF  ${set_suite} == True
        ${response_json}     Evaluate  json.loads($response.content)
        Convert to Dictionary    ${response_json}
        Set Suite Variable   ${response_json}
    END
    ${request_msec} =    Evaluate    ${request_time} * 1000
    Should Be Equal      "${response.status_code}"     "${expected_response_code}"
    Should Be True       ${request_msec}<${maximum_response_time}

DELETE REQUEST AND CHECK
    [Arguments]          ${hostname}    ${path}      ${expected_response_code}     ${maximum_response_time}  ${set_suite}=True
    ${header}=           Create dictionary      Accept=application/json
    create session       positive_session       ${hostname}     headers=${header}
    ${date_start} =      Get Current Date
    ${response}=         Delete On Session         positive_session   ${BASE_PATH}/${path}
    ${date_stop} =       Get Current Date
    ${request_time} =    Subtract Date From Date  ${date_stop}  ${date_start}
    IF  ${set_suite} == True
        ${response_json}     Evaluate  json.loads($response.content)
        Convert to Dictionary    ${response_json}
        Set Suite Variable   ${response_json}
    END
    ${request_msec} =    Evaluate    ${request_time} * 1000
    Should Be Equal      "${response.status_code}"     "${expected_response_code}"
    Should Be True       ${request_msec}<${maximum_response_time}



*** Test Cases ***
 Create pet
    [Tags]                     Endpoint Positive Test Case
    Log                        Positive test case - Add a new pet to the pet store
    ${path} =                  Set Variable       pet
    ${photoUrls}=              Create List        string
    ${category}=               Create Dictionary  id=0    name=string
    ${tag}                     Create Dictionary  id=0    name=string
    @{tags}                    Create List        ${tag}
    ${pet}=                    Create Dictionary  id=0    name=doggie    status=available    photoUrls=${photoUrls}   tags=${tags}   category=${category}
    POST REQUEST AND CHECK     ${TEST_TARGET}  ${path}  ${pet}  200  ${MAXIMUM_EXECUTION_TIME}
    ${pet_id}=                 Get From Dictionary      ${response_json}    id
    Set Suite Variable         ${pet_id}
    LOG                        ID IS ${pet_id}

Upload Image
    [Tags]                     Endpoint Positive Test Case
    Log                        Positive test case - Upload a doggie.png
    ${path} =                  Set Variable       pet
    ${filename}                Set Variable            doggie.png
    IMAGE UPLOAD AND CHECK     ${TEST_TARGET}  ${path}  ${pet_id}  ${filename}  200  ${MAXIMUM_EXECUTION_TIME}   False

Update Pet with PUT
    [Tags]                     Endpoint Positive Test Case
    Log                        Positive test case - Update an existing pet
    ${path} =                  Set Variable       pet
    ${photoUrls}=              Create List        string
    ${category}=               Create Dictionary  id=0    name=string
    ${tag}                     Create Dictionary  id=0    name=string
    @{tags}                    Create List        ${tag}
    ${pet}=                    Create Dictionary  id=${pet_id}    name=doggie2    status=available    photoUrls=${photoUrls}   tags=${tags}   category=${category}
    PUT REQUEST AND CHECK      ${TEST_TARGET}  ${path}  ${pet}  200  ${MAXIMUM_EXECUTION_TIME}

Find by Status
    [Tags]                     Endpoint Positive Test Case
    Log                        Positive test case - Find by Status of pets
    ${path} =                  Set Variable       pet/findByStatus
    ${category}=               Create Dictionary  status=pending
    GET REQUEST AND CHECK      ${TEST_TARGET}  ${path}  ${category}  200  ${MAXIMUM_EXECUTION_TIME}    False

Update Pet with POST by id
    [Tags]                     Endpoint Positive Test Case
    Log                        Positive test case - Update an existing pet with form encoded
    ${path} =                  Set Variable       pet/${pet_id}
    ${pet}=                    Create Dictionary  name=doggie2    status=pending
    POST REQUEST AND CHECK FORM ENCODED      ${TEST_TARGET}  ${path}  ${pet}  200  ${MAXIMUM_EXECUTION_TIME}   False

Find pet by id
    [Tags]                     Endpoint Positive Test Case
    Log                        Positive test case - Find by Status of pets
    ${path} =                  Set Variable       pet/${pet_id}
    ${category}=               Create Dictionary
    GET REQUEST AND CHECK      ${TEST_TARGET}  ${path}  ${category}  200  ${MAXIMUM_EXECUTION_TIME}    False


#A DLEETE MEG VALAMIERT HIBAS!!!!!!!!!
Delete pet by id
    [Tags]                     Endpoint Positive Test Case
    Log                        Positive test case - Delete
    ${path} =                  Set Variable       pet/${pet_id}
    DELETE REQUEST AND CHECK      ${TEST_TARGET}  ${path}  200  ${MAXIMUM_EXECUTION_TIME}    False

Find pet by id2
    [Tags]                     Endpoint Positive Test Case
    Log                        Positive test case - Find by Status of pets
    ${path} =                  Set Variable       pet/${pet_id}
    ${category}=               Create Dictionary
    GET REQUEST AND CHECK      ${TEST_TARGET}  ${path}  ${category}  200  ${MAXIMUM_EXECUTION_TIME}    False


Endpoint Negative Test Cases
    [Tags]                     Endpoint Negative Test Case
    Log                        Negative test cases


Full Procedure Test Cases
    [Tags]                     Full procedure Test Case
    Log                        Full procedure test cases