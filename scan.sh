#!/bin/bash
set -e

if [ $# -lt 2 ]; then
  # Print usage
  echo "Usage: $0 <project/module> <sourceanalyzer args>"
  echo
  echo "Example:"
  echo "  $0 --exclude "./__tests__:./__mocks__" -Dcom.fortify.sca.follow.imports=false "./**/*.ts" "./**/*.tsx""
  echo "  $0 -jdk 11 "./**/*.java""
fi

BUILD_ID=$1

FPR_FILE=${FPR_FILE:-fortify.fpr}
HTML_REPORT=${HTML_REPORT:-fortify.html}
PDF_REPORT=${PDF_REPORT:-fortify.pdf}
XML_REPORT=${XML_REPORT:-fortify.xml}

shift

# Remove all existing Fortify Static Code Analyzer temporary files for the specified build ID.
echo "Cleaning any previous build $BUILD_ID..."
sourceanalyzer -b $BUILD_ID -clean

# Translate the project code.
echo "Translating..."
# Notes:
#   * Multiple file patterns to be scanned needs to be quoted.
#   * Separate multiple file paths with colons (Linux) or semicolons (Windows)
#   * (Maybe fixed) For some reason for glob patterns to work the file pattern need to start with .  e.g. ./src/**/*.ts .
sourceanalyzer -b $BUILD_ID -fcontainer -debug-verbose "$@"

# List any warnings and errors that occurred in the translation phase
echo "Translation warnings (if any):"
sourceanalyzer -b $BUILD_ID -show-build-warnings

# Analyze the project code and produce the Fortify Project Results file (FPR).
echo "Performing analysis..."
sourceanalyzer -b $BUILD_ID -scan -fcontainer -f $FPR_FILE

# Generate report
echo "Generating HTML report ($HTML_REPORT)..."
BIRTReportGenerator -format HTML -output $HTML_REPORT -source $FPR_FILE -showSuppressed -template "Developer Workbook"
echo "Generating PDF report ($PDF_REPORT)..."
BIRTReportGenerator -format PDF -output $PDF_REPORT -source $FPR_FILE  -template "Developer Workbook"

# Generate XML reports (for DefectDojo)
echo "Generating XML report ($XML_REPORT)..."
ReportGenerator -format xml -f $XML_REPORT -source $FPR_FILE -showSuppressed -template "DeveloperWorkbook.xml"
