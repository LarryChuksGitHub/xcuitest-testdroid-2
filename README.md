# XCTEST and XCUITest example project 

Basic calculator app for iOS done with swift. Calculator can do additon and subtration operations.

Project includes examples of unit tests written using XCTest framework.

## Building the IPA and TEST FILE WITH FASTLANE

#### Prerequisite
- You should have Xcode 7 and above installed on your machine
- You need to have a signing certificate (Signing ID) from a registered iOS development group. This can obtain when you are invited to any of the zalando iOS develoment group either Zalando SE or Zalando AG
- Get an account account in [Testdroid](https://techwiki.zalando.net/display/BA/Testdroid-+HowTo)
- You have [fastlane](https://github.com/fastlane/fastlane) installed on your machine
- Login into your [Testdroid](https://cloud.testdroid.com/) and grab your APIKEY under my account > Integration > APIKEY
- Create a device group in testdroid under Device > Device Groups, add iOS device with iOS version 9.0 and above

#### More information

To build the IPA and Test file you need to know the follwings
- The .ipa needs to be built for Device and not for simulators more to that [here](https://developer.apple.com/library/content/documentation/IDEs/Conceptual/AppDistributionGuide/LaunchingYourApponDevices/LaunchingYourApponDevices.html)
- In Xcode under Buid Setting add armv7s and arm64 as a standard architecture
- In Xcode select "Generic Device" as a target
- For more info on how to build .ipa visit [online documentation](http://docs.testdroid.com/xcode/ipa/).


#### Build the APP and the Runner APP
- Clone the project
- Navigate to the project `cd project` and install fastlane in the project using the following command 

  `fastlane init`
  
- Navigate into the fastlane folder and open the "Fastfile"

##### Edit the Fastfile
The Fastfile is a ruby script that contain the build process of the APP and the Test file (-RUNNER APP). Under the function with description "build for testing", you will see the configuration of the build process. Please edit the path of the scripts "_script_ipa" and "_script_launch_xcuitest" to fit your path.

##### Build the IPA file

The .ipa file is created with help of the "zip_to_ipa.sh" script. open the _script_ipa to edit. Change the path of Release-iphones to your path and path of the "calculator.app". 

##### Build the Test file (-Runner.zip)

The Testdroid only accepts zip file as test file. The test file recides in the -Runner.app folder. This has to be zipped before uploading it into the Cloud. This zipping is done in the launch-xcuitest.sh under the "# create zip file from the RUNNER folder". The launch-xcuitest.sh is in the root folder.


##### Launch the Test with fastlane
The test execution will generate the .ipa and -Runner.zip file that is needed for the test and thereafter, the XCUITest which will run the test on the Cloud. 

To launch the test you have to do the follwing steps, open the launch-xcuitest.sh and edit the following
- search for API_KEY and add. This is the API KEY which you have grabbed earlier
- add your device group. This the name of the device group you created earlier
- under "APP_FILE" adjust the path to the IPA file that will created when you run the test


- Navigate into the project `cd project` and run the command below

`fastlane buildTesting`

Visit [Testdroid](https://cloud.testdroid.com/) to see the test results

