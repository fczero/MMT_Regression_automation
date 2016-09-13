*** Settings ***
Suite Setup       Open MMT
Suite Teardown    Close MMT
Test Setup        MMT is active window
Library           AutoItLibrary    ${OUTPUTDIR}    15    ${True}
Library           String
Library           Collections
Library           OperatingSystem
Library           mmt_registry.py
Default Tags      DCM    NONDCM

*** Variables ***
${LTE_VER}               9.2.4
${3G_VER}                8.0.3
${HARDWARE}              3201
${MMTSS_VERSION}         10
${VERSION}               18.20.17.2

${API_VER}               ${HARDWARE}_API_v${LTE_VER}(LTE)_API_v${3G_VER}(3G)

${DCM}                   0
#${MMT_PATH}              C:\\BS3201_Tools\\MMT\\
#${DCM_PATH}              C:\\BS3201_Tools\\MMT_DCM\\
#${MMT}                   ${MMT_PATH}MMT.exe
#${MMT_STARTMENU_PATH}    C:\\ProgramData\\Microsoft\\Windows\\Start Menu\\Programs\\MMT.lnk
#${MMT_PLUGINS_PATH}      ${MMT_PATH}plugins


${MMT_MAIN_WINDOW}       [REGEXPTITLE:(.*Message Monitoring Tool.*)]
${MMT_OPTIONS_WINDOW}    Wireshark: Capture Options
${MMT_ABOUT}             About MMT
${MMT_CAPTURING}         Capturing
${MMT_CAPTURED}          [REGEXPTITLE:(\\*.*Message Monitoring Tool.*)]
${SAVE_FILE}             D:\\dummy.mcap
${MMT_SAVE_DIALOG}       Wireshark: Save file as
${MMT_OPEN_DIALOG}       Wireshark: Open Capture File
${MMT_INCOMP_DIALOG}     Wireshark
${MCAP_PATH}             d:\\userdata\\lagadia\\My Documents\\!Tasks\\MMT_REGRESSION_ROBOT\\Common log for pre-release confirmation\\
${MCAP_NAME}             MMTSS_VERSION_
${MAX_MMTSS_VERSION}     11
${REL10_FILENAME}        Release_No10.mcap
${REG06_FILENAME}        hdbdeMMT Regression_No06.mcap 
${REG04_FILENAME}        hdbdeMMT Regression_No04.mcap 
${REL10}                 ${MCAP_PATH}${REL10_FILENAME}
${REG04}                 ${MCAP_PATH}${REG04_FILENAME}
${REG06}                 ${MCAP_PATH}${REG06_FILENAME}
${INCOMPAT}              Incompatible MMT version.
${EXPORT}                Wireshark: Export File

*** Test Cases ***
Version Check
#    Run Keyword If   ${DCM}    set tags   DCM
#...    ELSE       set tags NONDCM
    Displays Version
    ${mmt_ver} =    Get Version
    Then Should Be Equal As Strings    ${mmt_ver}    ${VERSION}

DB Version Check
    ${api_version} =    Get API Version
    Then Should Be Equal As Strings    ${api_version}    ${API_VER}

Registry Check
    ${mmt_reg_version} =    Get Version From Registry
    Should Be Equal As Strings    ${mmt_reg_version}    ${VERSION}

Program Name Check
    File Should Exist    ${MMT_STARTMENU_PATH}

Plugin Name Check
    ${item_count} =    Count Directories In Directory    ${MMT_PLUGINS_PATH}
    @{items} =    List Directories In Directory    ${MMT_PLUGINS_PATH}
    Should Be Equal As Integers    ${item_count}    1
    Should Be Equal As Strings    @{items}[0]    ${VERSION}

Save MCAP Check
    Remove File    ${SAVE_FILE}
    Given MMT is active window
    Toggle Capture On All Interfaces
    And Start Capture
    Stop Capture
    Save Capture
    File Should Exist    ${SAVE_FILE}
    Close mcap File
    Remove File    ${SAVE_FILE}
    Toggle Capture On All Interfaces

Load other MMTSS version Check
    : FOR    ${index}    IN RANGE    0    ${MAX_MMTSS_VERSION}
    \    Continue for loop if    ${index} == ${MMTSS_VERSION}
    \    Open other mmtss mcap    ${MCAP_PATH}${MCAP_NAME}${index}.mcap
    \    Close Incompatible Dialog

Load matching MMTSS version Check
    MMT is active window
    Open mcap    ${MCAP_PATH}${MCAP_NAME}${MMTSS_VERSION}.mcap
    Confirm window    ${MCAP_NAME}${MMTSS_VERSION}.mcap - Message Monitoring Tool

DCM Should Display Exactly 7432 Packets
    [Tags]    DCM
    MMT is active window
    Open mcap    ${REL10}
    Win Wait Active    ${MMT_INCOMP_DIALOG}     ${EMPTY}      60
    Close Incompatible Dialog
    ${count} =    Get Number of Displayed Packets
    Should Be Equal As Strings    7432    ${count}

DCM Should Not Display ICMPv6
    [Tags]    DCM
    MMT is active window
    Open mcap    ${REG06}
    Win Wait Active    ${MMT_INCOMP_DIALOG}     ${EMPTY}      60
    Close Incompatible Dialog
    ${count} =    Get Number of Displayed Packets
    Should Be Equal As Strings    531    ${count}

Text Output for messages greater than 25 bytes
    [Tags]    NONDCM    test
    MMT is active window
    Open mcap    ${REG04}
    Win Wait Active    ${MMT_INCOMP_DIALOG}     ${EMPTY}      60
    Close Incompatible Dialog
    Send        {TAB}
#improve
#    : For    ${index}    IN RANGE    0    9
    : For    ${index}    IN RANGE    9
    \    Send    {DOWN}
#hotkey not working
#   Send      +^d
    Send       !e
    Send    {RIGHT}
    Send    {ENTER}
    Sleep    1
    ${info} =      ClipGet
    Should Be Equal As Strings    
    ...     Message Data: 000102030405060708090A0B0C0D0E0F0001020304050607...
    ...    ${info}



*** Keywords ***
Initialize Paths
   ${path} =    Set Variable if    ${DCM}   
   ...   C:\\BS${HARDWARE}_Tools\\MMT_DCM\\    C:\\BS${HARDWARE}_Tools\\MMT\\
   ${startmenu_path} =    Set Variable if    ${DCM}
   ...   C:\\ProgramData\\Microsoft\\Windows\\Start Menu\\Programs\\MMT_DCM.lnk
   ...   C:\\ProgramData\\Microsoft\\Windows\\Start Menu\\Programs\\MMT.lnk
   ${mmt_exe} =    Set Variable if    ${DCM}    MMT_DCM.exe    MMT.exe
   Set Global Variable    ${MMT_PATH}    ${path}
   Set Global Variable    ${MMT}    ${path}${mmt_exe}
   Set Global Variable    ${MMT_START_MENU_PATH}    ${startmenu_path}
   Set Global Variable    ${MMT_PLUGINS_PATH}       ${path}plugins

Open MMT
    Initialize Paths
    AutoItLibrary.Run    ${MMT}
    Wait for active window    ${MMT_MAIN_WINDOW}     ${EMPTY}      60

Close MMT
    MMT is active window
    Win Close    ${MMT_MAIN_WINDOW}
    Win Wait Close    ${MMT_MAIN_WINDOW}

MMT is active window
    Win Activate    ${MMT_MAIN_WINDOW}

Displays Version
    Send    !h
    Send    a
    Wait for active window    ${MMT_ABOUT}

Get Version
    Win Activate    ${MMT_ABOUT}
    Send    ^+{TAB}
    Send    ^a
    Send    ^c
    ${MMT_VERSION} =    ClipGet
    ${MMT_VERSION} =    Get Line    ${MMT_VERSION}    0
    ${MMT_VERSION} =    Fetch From Left    ${MMT_VERSION}    (
    ${MMT_VERSION} =    Fetch From Right    ${MMT_VERSION}    Version
    ${MMT_VERSION} =    Strip String    ${MMT_VERSION}
    [Return]    ${MMT_VERSION}

Get API Version
    ${MMT_API_VER} =    Win Get Title    [ACTIVE]
    ${MMT_API_VER} =    Fetch From Right    ${MMT_API_VER}    -
    ${MMT_API_VER} =    Strip String    ${MMT_API_VER}
    [Return]    ${MMT_API_VER}

Open Options
    MMT is active window
    Send    ^k
    Wait for active window    ${MMT_OPTIONS_WINDOW}

Close Options
    MMT Options is active window
    Send    {ESC}

MMT Options is active window
    Win Activate    ${MMT_OPTIONS_WINDOW}

Toggle Capture On All Interfaces
    Open Options
    Win Activate    ${MMT_OPTIONS_WINDOW}
    Send    ^+{TAB}
    Send    ^+{TAB}
    Send    ^+{TAB}
    Send    ^+{TAB}
    Send    {SPACE}
    Close Options

Toggle Capture On First Interface
    Open Options
    Win Activate    ${MMT_OPTIONS_WINDOW}
    Send    ^+{TAB}
    Send    ^+{TAB}
    Send    ^+{TAB}
    Send    ^+{TAB}
    Send    ^+{TAB}
    Send    {SPACE}
    Close Options

Start Capture
    MMT is active window
    Send    ^e
    Sleep    1
    ${result} =    Win Active    ${MMT_CAPTURING}
    Should Be True    ${result}

Stop Capture
    Win Activate    ${MMT_CAPTURING}
    Send    ^e
    Sleep    1
    Confirm Window    ${MMT_CAPTURED}
    #${result} =    Win Active    ${MMT_CAPTURED}
    #Should Be True    ${result}

Confirm Window
    [Arguments]    ${window}
    ${result} =    Win Active    ${window}
    Should Be True    ${result}

Save Capture
    Win Activate    ${MMT_CAPTURED}
    Send    ^+s
    Sleep    1
    Wait For Active Window    ${MMT_SAVE_DIALOG}    ${EMPTY}    60
    #Confirm Window    ${MMT_SAVE_DIALOG}
    #Win
    ClipPut    ${SAVE_FILE}
    Send    ^v
    Send    {TAB}
    Send    {DOWN}
    Send    {DOWN}
    Sleep    1
    Send    {Enter}
    Send    !s
    Sleep    2

Close mcap file
    Win Activate    ${MMT_MAIN_WINDOW}
    Send    ^w
    Confirm Window    Message Monitoring Tool
    Sleep    2

Close unsaved mcap
    Win Activate    ${MMT_CAPTURED}
    Send    ^w
    Sleep    1
    Send    !w
    Confirm Window    ${MMT_MAIN_WINDOW}

Open mcap
    [Arguments]    ${mcap_file}
    Confirm Window    ${MMT_MAIN_WINDOW}
    Send    ^o
    Wait For Active Window    ${MMT_OPEN_DIALOG}    ${EMPTY}    60
    ClipPut    ${mcap_file}
    Send    ^v
    Send    {ENTER}
    Win wait close    ${MMT_OPEN_DIALOG}    ${EMPTY}    60

Open other mmtss mcap
    [Arguments]    ${mcap_file}
    Open mcap    ${mcap_file}
    ${filename} =    Fetch from right    ${mcap_file}    \\
    Confirm Window    ${MMT_INCOMP_DIALOG}

Open Export File Dialog
    Confirm Window    ${MMT_MAIN_WINDOW}
    Send    !f
#improve
#    : For    ${index}    IN RANGE    0    8
    : For    ${index}    IN RANGE    8
    \    Send    {DOWN}
    #Send    {ENTER}
    Send    {RIGHT}
    Send    {ENTER}
    Win Wait Active    ${EXPORT}

Close Incompatible Dialog
    Send    !o

Close Dialog
    Send    {ESC}

Get Number of Displayed Packets
    Confirm Window    ${MMT_MAIN_WINDOW}
    Send     ^+m
    Sleep     1
    Open Export File Dialog
    ${count} =    Control Get Text    ${EXPORT}    ${EMPTY}    1017
    Close Dialog
    Send     ^!m
    [Return]    ${count}
