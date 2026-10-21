#!/bin/bash

set -e
path=`dirname $0`

OUTPUT_DIR=$1
TARGET_NAME=${2:-plugin_liveBuild}
OUTPUT_SUFFIX=a
CONFIG=Release


# 
# Canonicalize relative paths to absolute paths
# 
pushd $path > /dev/null
dir=`pwd`
path=$dir
popd > /dev/null

if [ -z "$OUTPUT_DIR" ]
then
    OUTPUT_DIR=.
fi

pushd $OUTPUT_DIR > /dev/null
dir=`pwd`
OUTPUT_DIR=$dir
popd > /dev/null

echo "OUTPUT_DIR: $OUTPUT_DIR"

# Clean
xcodebuild -project "$path/Plugin.xcodeproj" -configuration $CONFIG clean

# SDK plugin

## iOS
echo ""
echo "[SDK plugin (ARM)] Building..."
xcodebuild -project "$path/Plugin.xcodeproj" -target $TARGET_NAME -configuration $CONFIG -sdk iphoneos

## iOS-sim
echo ""
echo "[SDK plugin (x86)] Building..."
xcodebuild -project "$path/Plugin.xcodeproj" -target $TARGET_NAME -configuration $CONFIG -sdk iphonesimulator


echo "$OUTPUT_DIR"/lib$TARGET_NAME.$OUTPUT_SUFFIX