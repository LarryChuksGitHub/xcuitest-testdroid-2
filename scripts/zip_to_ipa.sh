#!/bin/bash
#cd /Users/hchukwuji/Documents/workspace/ios-projects/xcuitest-github/xctest-xcuitest-project/project/app/builds/Build/Products/Release-iphoneos
cd /Users/hchukwuji/Documents/workspace/ios-projects/xcuitest-github/xctest-xcuitest-project/project/app/Build/Products/Release-iphoneos
mkdir -p ./temporary/Payload
echo "created temporary folder"
cd temporary/Payload

cp -r /Users/hchukwuji/Documents/workspace/ios-projects/xcuitest-github/xctest-xcuitest-project/project/app/Build/Products/Release-iphoneos/calculator.app .

#cp -r /Users/hchukwuji/Documents/workspace/ios-projects/xcuitest-github/xctest-xcuitest-project/project/app/builds/Build/Products/Release-iphoneos/calculator.app .
cd ..
echo "creating .ipa file it may take some time"
rm -rf .ipa
zip --symlinks -qr "calculator.ipa" Payload
echo "Created .ipa file Successfully"
ls -lrt calculator.ipa
