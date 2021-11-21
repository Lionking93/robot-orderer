*** Settings ***
Documentation   This robot reads a list of robot orders from .csv file 
...             And orders them from robotsparebinindustries.com
Library    RPA.Browser.Selenium
Library    RPA.HTTP
Library    RPA.Tables
Library    RPA.PDF
Library    RPA.Archive
Library    RPA.Dialogs
Library    RPA.Robocorp.Vault

*** Keywords ***
Open the robot order website
    ${config}=    Get Secret    robot_orderer_config
    Log    ${config}[robot_order_url]
    Open Available Browser    ${config}[robot_order_url]

*** Keywords ***
Get orders
    [Arguments]    ${orders_url}
    Download    ${orders_url}    overwrite=True
    ${orders}=    Read table from CSV    orders.csv    header=True
    [Return]    ${orders}

*** Keywords ***
Close the annoying modal
    Wait Until Page Contains Element    xpath=//button[contains(.,'I guess so...')]
    Click Button    xpath=//button[contains(.,'I guess so...')]

*** Keywords ***
Fill the form
    [Arguments]    ${order}
    Select From List By Value    name:head    ${order}[Head]
    Click Button    css=input#id-body-${order}[Body].form-check-input
    Input Text    xpath=//input[@placeholder='Enter the part number for the legs']    ${order}[Legs]
    Input Text    css=#address    ${order}[Address]

*** Keywords ***
Preview the robot
    Click Button    Preview

*** Keywords ***
Submit the order
    Wait Until Keyword Succeeds    10x    1 sec    Assert order completed

*** Keywords ***
Assert order completed
    Click Button    Order
    Wait Until Page Contains Element    xpath=//h3[contains(.,'Receipt')]    timeout=2 sec

*** Keywords ***
Go to order another robot
    Click Button    Order another robot

*** Keywords ***
Store the receipt as a PDF file
    [Arguments]    ${order_number}
    ${receipt_as_html}=    Get Element Attribute    id:receipt    outerHTML
    ${receipt_file_name}    Set Variable    ${OUTPUT_DIR}${/}receipts${/}receipt_for_order_${order_number}.pdf
    Html To Pdf    ${receipt_as_html}    ${receipt_file_name}
    [Return]    ${receipt_file_name}

*** Keywords ***
Take a screenshot of the robot
    [Arguments]    ${order_number}
    ${screenshot_file_name}    Set Variable    ${OUTPUT_DIR}${/}robot_previews${/}robot_preview_for_order_${order_number}.png
    Screenshot    locator=css=#robot-preview-image    filename=${screenshot_file_name}
    [Return]    ${screen_shot_file_name}

*** Keywords ***
Embed the screenshot to the receipt PDF file
    [Arguments]    ${screenshot}    ${pdf}
    Open Pdf    ${pdf}
    Add Watermark Image To Pdf    image_path=${screenshot}    output_path=${pdf}
    Close Pdf    ${pdf}

*** Keywords ***
Create a ZIP file of the receipts
    Archive Folder With Zip    ${OUTPUT_DIR}${/}receipts    ${OUTPUT_DIR}${/}receipts.zip    recursive=True

*** Keywords ***
Give orders URL dialog
    Add heading    Please insert URL for orders.csv    size=Medium
    Add text input    orders_url    
    ...    label=Orders URL
    ...    placeholder=Enter orders URL here
    ${result}=    Run dialog
    [Return]    ${result.orders_url}

*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open the robot order website
    ${orders_url}=    Give orders URL dialog
    ${orders}=    Get orders    ${orders_url}
    FOR    ${order}    IN    @{orders}
        Close the annoying modal
        Fill the form    ${order}
        Preview the robot
        Submit the order
        ${pdf}=    Store the receipt as a PDF file    ${order}[Order number]
        ${screenshot}=    Take a screenshot of the robot    ${order}[Order number]
        Embed the screenshot to the receipt PDF file    ${screenshot}    ${pdf}
        Go to order another robot
    END
    Create a ZIP file of the receipts
    [Teardown]    Close Browser