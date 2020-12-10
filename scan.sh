#!/bin/sh
# cd /src
# Remove all existing Fortify Static Code Analyzer temporary files for the specified build ID.
sourceanalyzer -b $BUILD_ID -clean

# Translate the project code.
sourceanalyzer -b $BUILD_ID -fcontainer $SCA_OPTIONS $SOURCE_FILES

# List any warnings and errors that occurred in the translation phase
sourceanalyzer -b $BUILD_ID -show-build-warnings

# Analyze the project code and produce the Fortify Project Results file (FPR).
sourceanalyzer -b $BUILD_ID -scan -fcontainer -f $FPR_FILE
