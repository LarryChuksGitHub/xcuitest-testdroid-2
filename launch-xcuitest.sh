#!/bin/bash

#  launch-test.sh
#
#
#  Created by Hilary Chukwuji on 31/01/2017.
#


function help() {
echo
echo "$0 - create and upload test project to Testdroid Cloud and run it"
echo "Usage: $0 -k <API_KEY>"
echo "Usage: $0 -g <DEVICE_GROUP_NAME> -k <API_KEY>"
echo "Optional: -p <PROJECT_NAME> to choose a specific profile. If not given, a new project will be created"
echo "Optional: -t for creating and uploading a new test zip file"
echo "Optional: -f <APP_FILE_PATH> for uploading a new app file but compulsory for new project"
echo "Optional: -r <NAME OF THE RUNNER APP> for uploading a new test file compulsory for new project"
exit
}

while getopts "tg:k:p:f:r:h" opt; do
    case $opt in
        t) UPLOAD_TEST=true
            ;;
        g) DEVICE_GROUP_NAME=${OPTARG}
            ;;
        k) API_KEY=${OPTARG}
            ;;
        p) PROJECT_NAME=${OPTARG}
            ;;
        f) APP_FILE=${OPTARG}
            ;;
        r) RUNNER_FOLDER=${OPTARG}
            ;;
        h) help
            ;;
        \?) echo "Invalid option: -${OPTARG}" >&2
            ;;
        :) echo "Option -${OPTARG} requires an argument." >&2
            exit 1
            ;;
    esac
done
API_ENDPOINT=https://cloud.testdroid.com
API_KEY=Uvxt9QOtMVWSBoE00LoCerh2RlSfPLvv
DEVICE_GROUP_NAME=4-iOSXCUITest-Device
APP_FOLDER=calculatorUITests-Runner.app
APP_FILE=/Users/hchukwuji/Documents/workspace/ios-projects/xctest-xcuitest-project/project/app/builds/Build/Products/Release-iphoneos/temporary/calculator.ipa

# Check that -k was given
if [ -z ${API_KEY} ] ; then
    echo "API_KEY with -k not given!" >&2
    help
else
    MAIN_USER_ID="$(curl -H "Accept: application/json" -u ${API_KEY}: "${API_ENDPOINT}/api/v2/me" | python -m json.tool | sed -n -e '/"mainUserId": / s/^.*"mainUserId": \(.*\)"*,/\1/p')"
        echo "MAIN_USER_ID: ${MAIN_USER_ID}"
    if [ -z ${MAIN_USER_ID} ] ; then
        echo "Authentication failed, check apikey given in -k: "${API_KEY}""
        help
    else
        echo "Authentication succeeded."
        echo "mainUserId: ${MAIN_USER_ID}"
    fi
fi

# Check if -p <PROJECT_NAME> was given
if [ -z ${PROJECT_NAME} ] ; then
    echo "No -p <PROJECT_NAME> given, creating a new project"
    echo "Creating XCUITest project.."
    PROJECT_NAME="$(curl -H "Accept: application/json" -u ${API_KEY}: -X POST -F 'type=XCUITEST' "${API_ENDPOINT}/api/v2/me/projects" | python -m json.tool | sed -n -e '/"name":/ s/^.*"name": "\(.*\)".*/\1/p')"

    echo "Created project with name: ${PROJECT_NAME}"
    PROJECT_ID="$(curl -G -s -H "Accept: application/json" -u ${API_KEY}: "${API_ENDPOINT}/api/v2/me/projects?limit=1" --data-urlencode "search=${PROJECT_NAME}" | python -m json.tool | sed -n -e '/"id":/ s/^.* \(.*\),.*/\1/p')"
    echo "PROJECT_ID: ${PROJECT_ID}"

else
    # Replace all spaces in PROJECT_NAME with + signs
    #PROJECT_NAME=${PROJECT_NAME// /+}
    echo "Checking if project with name ${PROJECT_NAME} exists (spaces escaped with +)"
    # Check if Project exists
    PROJECT_ID="$(curl -G -s -H "Accept: application/json" -u ${API_KEY}: "${API_ENDPOINT}/api/v2/me/projects?limit=1" --data-urlencode "search=${PROJECT_NAME}" | python -m json.tool | sed -n -e '/"id":/ s/^.* \(.*\),.*/\1/p')"

    if [ -z ${PROJECT_ID} ] ; then
            #echo "Project not found, creating it now with name ${PROJECT_NAME} (spaces escaped with +)"
            echo "Creating XCUITest project.."
            PROJECT_NAME="$(curl -H "Accept: application/json" -u ${API_KEY}: -X POST -F 'type=XCUITEST' "${API_ENDPOINT}/api/v2/me/projects" | python -m json.tool | sed -n -e '/"name":/ s/^.*"name": "\(.*\)".*/\1/p')"


            PROJECT_ID="$(curl -s -H "Accept: application/json" -u ${API_KEY}: "${API_ENDPOINT}/api/v2/me/projects?limit=1" --data-urlencode "search=${PROJECT_NAME}" | python -m json.tool | sed -n -e '/"id":/ s/^.* \(.*\),.*/\1/p')"
                echo "Project created with ID: ${PROJECT_ID} and name: ${PROJECT_NAME}"
                if [ -z {PROJECT_NAME}] ; then
                   echo "No Project created"
                   exit

                fi

    else
        echo "Project found with ID: ${PROJECT_ID}"
    fi
fi

# Check that the used project is of correct type
PROJECT_TYPE="$(curl -s -H "Accept: application/json" -u ${API_KEY}: "${API_ENDPOINT}/api/v2/me/projects/${PROJECT_ID}" | python -m json.tool | sed -n -e '/"type":/ s/^.*"type": "\(.*\)".*/\1/p')"
echo "PROJECT_TYPE: ${PROJECT_TYPE}"


if [ "${PROJECT_TYPE}" == "XCUITEST" ] ; then

        #Check if framework of correct type
        PROJECT_FRAMEWORK_ID="$(curl -s -H "Accept: application/json" -u ${API_KEY}: "${API_ENDPOINT}/api/v2/me/projects/${PROJECT_ID}" | python -m json.tool | sed -n -e '/"frameworkId":/ s/^.* \(.*\),.*/\1/p')"
        echo "PROJECT_FRAMEWORK_ID: ${PROJECT_FRAMEWORK_ID}"

        if [ ${PROJECT_FRAMEWORK_ID} != 612 ]; then

        echo "The framework type is wrong"
        exit
        fi
else
    echo "wrong Project type: ${PROJECT_TYPE} "
exit

fi



# Check that Device Group exists
if [ -z ${DEVICE_GROUP_NAME} ]; then
echo  "Please provide device group with correct platform (device OS) using the -g flag exiting....."
exit

fi

echo "DEVICE_GROUP_NAME: ${DEVICE_GROUP_NAME}"
DEVICE_GROUP_ID="$(curl -G -s -H "Accept: application/json" -u ${API_KEY}: "${API_ENDPOINT}/api/v2/me/device-groups?withPublic=true" --data-urlencode "limit=1" --data-urlencode "search=${DEVICE_GROUP_NAME}" | python -m json.tool | sed -n -e '/"id":/ s/^.* \(.*\),.*/\1/p')"
echo "DEVICE_GROUP_ID: ${DEVICE_GROUP_ID}"

if [ -z ${DEVICE_GROUP_ID} ]; then
echo "No DEVICE_GROUP_ID found; Device group with name \"${DEVICE_GROUP_NAME}\" doesn't seem to exist."
exit
fi

# Check that Device Group is of correct type
DEVICE_GROUP_TYPE="$(curl -s -H "Accept: application/json" -u ${API_KEY}: "${API_ENDPOINT}/api/v2/me/device-groups/${DEVICE_GROUP_ID}" | python -m json.tool | sed -n -e '/"osType":/ s/^.*"osType": "\(.*\)".*/\1/p')"
echo "DEVICE_GROUP_TYPE: ${DEVICE_GROUP_TYPE}"

if [ "${DEVICE_GROUP_TYPE}" != "IOS" ] ; then

    echo "Device Group must be iOS device exiting...."
    exit

fi

# create zip file from the RUNNER folder

ZIP_EXISTS="$(curl -H "Accept: application/json" -u ${API_KEY}: "${API_ENDPOINT}/api/v2/me/projects/${PROJECT_ID}/files" | python -m json.tool | sed -n -e '/"test":/ s/^.*"test": \(.*\)"*/\1/p')"
if [[ ( -z ${UPLOAD} ) && ( ${ZIP_EXISTS} -ne "null" ) ]]; then
:
else
  echo "APP_FOLDER is: ${APP_FOLDER}"
  echo "Zipping app folder: ${APP_FOLDER}"
  cd /Users/hchukwuji/Documents/workspace/ios-projects/xctest-xcuitest-project/project/app/builds/Build/Products/Release-iphoneos
  zip -r -X calculatorUITests-Runner.zip $APP_FOLDER

  if [ -z ${calculatorUITests-Runner.zip} ] ; then
    echo "App folder was not zipped exiting"
    exit
  else
  echo "The full path of calculatorUITests-Runner.zip is :"
  echo `pwd`/`ls calculatorUITests-Runner.zip`
  RUNNER_ZIP=calculatorUITests-Runner.zip
  echo "ZIP_FOLDER is: ${RUNNER_ZIP}"
  fi
  echo "Uploading ${RUNNER_ZIP} to Project with ID ${PROJECT_ID} this may take some minutes"
  curl -H "Accept: application/json" -u ${API_KEY}: -X POST -F "file=@${RUNNER_ZIP}" "${API_ENDPOINT}/api/v2/me/projects/${PROJECT_ID}/files/test"
  echo " zip folder: ${RUNNER_ZIP} was uploaded successfully "

fi


# upload ipa file

APP_EXISTS="$(curl -H "Accept: application/json" -u ${API_KEY}: "${API_ENDPOINT}/api/v2/me/projects/${PROJECT_ID}/files" | python -m json.tool | sed -n -e '/"app":/ s/^.*"app": \(.*\)"*,/\1/p')"

# Upload APP_FILE if -f was given or if project has no app uploaded yet
if [[ ( -z ${APP_FILE} ) && ( ${APP_EXISTS} -ne "null" ) ]]; then
# if file path is given before project name
    if [[ ( -z ${PROJECT_NAME} ) && (${APP_FILE} = true) ]] ; then
    echo "Provide project -p (project name) before -f (file name)  exiting ......."
            exit
    fi
    :
else
    if [[ -z ${APP_FILE} ]]; then
        echo "No app file given in -f and no app has been previously uploaded to the project! Exiting."
        exit
    else
        echo "-f was given, uploading the given file: ${APP_FILE} this may take some minutes"
        UPLOADED_FILE="$(curl -H "Accept: application/json" -u ${API_KEY}: -X POST -F "file=@${APP_FILE}" "${API_ENDPOINT}/api/v2/me/projects/${PROJECT_ID}/files/application" | python -m json.tool | sed -n -e '/"ipa":/ s/^.* \(.*\),.*/\1/p')"
            echo " App file: ${APP_FILE} was uploaded successfully "
    fi
fi


#launch the test and get the test run ID
echo "Launching test in Testdroid! under project: ${PROJECT_NAME} "
TESTRUN_ID="$(curl -s -H "Accept: application/json" -u ${API_KEY}: -X POST "${API_ENDPOINT}/api/v2/me/projects/${PROJECT_ID}/runs?usedDeviceGroupId=${DEVICE_GROUP_ID}" | python -m json.tool | sed -n -e '/"id":/ s/^.* \(.*\),.*/\1/p')"

if [ -z ${TESTRUN_ID} ] ; then
    echo "TESTRUN_ID not gotten, the test probably wasn't launched properly.. exiting."
    exit
else
    echo "Testrun ID: ${TESTRUN_ID}"

fi

# Replace 'com/cloud' with 'com' from the end, if it exists due to private cloud API endpoint.
API_ENDPOINT=${API_ENDPOINT//com\/cloud/com}
echo "TEST DONE! The test results are available at ${API_ENDPOINT}/#service/testrun/${PROJECT_ID}/${TESTRUN_ID}"
