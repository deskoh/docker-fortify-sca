# Fortify Static Code Analyzer (SCA) Docker

## Build Image

```sh
# Copy installer (e.g. Fortify_SCA_and_Apps_<Version>_linux_x64.run) and `fortify.license` into installer directory

# Build image
docker build -t sca .

# Build image with JDK  11 (override BASE_TAG)
docker build -t sca:jdk11 . --build-arg BASE_IMAGE=openjdk --build-arg BASE_TAG=11-jdk-slim
```

## Quick Start

> For SCA 20.1.0 and later, Use `–fcontainer` option in both the translate and scan commands so that SCA detects and uses only the memory dedicated to the container. Otherwise, by default Fortify Static Code Analyzer detectsthe total system memory because `-autoheap` is enabled.

See `scan.sh` for environment variables usage.

```sh
# Mount source code to /src inside container and run the scan (see scan.sh)

# Java example
docker run --rm \
  -v $(pwd):/src \
  sca mybuildid -jdk 11 "/src/**/*.java"

# Python example
docker run --rm \
  -v $(pwd):/src \
  sca mybuildid -python-version 3 "/src/**/*.py"

# TypeScript example
docker run --rm \
  -v $(pwd):/src \
  sca mybuildid --exclude "/src/__tests__:/src/__mocks__" -Dcom.fortify.sca.follow.imports=false "/src/**/*.ts" "/src/**/*.tsx"
```

## Running `sourceanalyzer` Manually

```sh
# Bash into the container in /src directory
docker run --rm -it -v /local_src:/src sca bash

# Remove all existing Fortify Static Code Analyzer temporary files
sourceanalyzer -b $BUILD_ID -clean

# Translate the project code.
sourceanalyzer –b $BUILD_ID -fcontainer $SCA_OPTIONS $SOURCE_FILES

# List any warnings and errors that occurred in the translation phase
sourceanalyzer -b $BUILD_ID -show-build-warnings

# Analyze the project code and produce the Fortify Project Results file (FPR).
sourceanalyzer –b $BUILD_ID –scan -fcontainer $SCA_OPTIONS –f $FPR_FILE
```

## Generating Reports

```sh
# Assuming using results file is results.fpr

# Note:
#  - Supported formats are in uppercase for SCA 19.1.0 (i.e. `PDF | DOC | HTML | XLS`)
#  - Report Generation in SCA 20.1.0 is broken and fixed in 20.2.0
docker run --rm \
  -v /local_src:/src \
  sca BIRTReportGenerator -template 'Developer Workbook' -source results.fpr \
  -format pdf -output report.pdf
```

## Examples Commands

```sh
# Java (colon- orsemicolon-separated list of class paths)
sourceanalyzer -b $BUILD_ID -fcontainer -cp $CLASSPATH -jdk 11 $SOURCE_FILES
sourceanalyzer -b $BUILD_ID gradle clean build
sourceanalyzer -b $BUILD_ID gradle --info assemble
```

## References

[Fortify Static Code Analyzer and Tools Software Documentation](https://www.microfocus.com/documentation/fortify-static-code-analyzer-and-tools/)
