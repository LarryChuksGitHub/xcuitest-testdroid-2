#!/bin/sh

KEY_CHAIN=ios-build.keychain
LIB_KEY=~/Library/Keychains
LIB_KEY_CHAIN=${LIB_KEY}/${KEY_CHAIN}
security create-keychain -p travis $KEY_CHAIN
# Make the keychain the default so identities are found
security default-keychain -s $KEY_CHAIN
# Unlock the keychain
security unlock-keychain -p travis $KEY_CHAIN
# Set keychain locking timeout to 3600 seconds
security set-keychain-settings -t 3600 -u $KEY_CHAIN

# Add certificates to keychain and allow codesign to access them
#security import ./scripts/certs/SE.cer -k $LIB_KEY_CHAIN -T /usr/bin/codesign
#security import ./scripts/certs/SE.p12 -k $LIB_KEY_CHAIN -T /usr/bin/codesign
security import ./scripts/certs/apple.cer -k $LIB_KEY_CHAIN -T /usr/bin/codesign
security import ./scripts/certs/se-dist.cer -k $LIB_KEY_CHAIN -T /usr/bin/codesign
security import ./scripts/certs/se-dist-key.p12 -k $LIB_KEY_CHAIN -T /usr/bin/codesign
#security import ./scripts/certs/dist.cer -k $LIB_KEY_CHAIN -T /usr/bin/codesign
#security import ./scripts/certs/dist.p12 -k $LIB_KEY_CHAIN -P $KEY_PASSWORD -T /usr/bin/codesign

echo "Add keychain to keychain-list"
#security list-keychains -s ios-build.keychain
security set-key-partition-list -S apple-tool:,apple: -s -k travis ios-build.keychain
