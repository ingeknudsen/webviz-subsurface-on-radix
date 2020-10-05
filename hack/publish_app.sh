#!/bin/bash

STORAGE_ACCOUNT_NAME="webvizonradix"
CONTAINER_NAME="webviz-data"
WEBVIZ_CONFIG="../webviz-subsurface-testdata/webviz_examples/webviz-full-demo.yml"

#######################################################################################
### Check for prerequisites binaries
###

echo ""
printf "Check for neccesary executables... "
hash azcopy 2>/dev/null || {
    echo -e "\nError: Azure-CLI not found in PATH. Exiting..."
    exit 1
}
hash webviz 2>/dev/null || {
    echo -e "\nError: webviz not found in PATH. Exiting..."
    exit 1
}
hash git 2>/dev/null || {
    echo -e "\nError: git not found in PATH. Exiting..."
    exit 1
}
printf "All is good."
echo ""

#######################################################################################
### Generates the app from webviz yaml config file. This requires access to
### raw resource files used by the reports
###

WORKDIR="./generated_app"
WEBVIZ_STORAGE="webviz_storage"

# echo "Generate app"
# rm -rf generated_app &&
#     webviz build "${WEBVIZ_CONFIG}" --theme equinor --portable "${WORKDIR}"

#######################################################################################
### Radix needs to be able to load aggregated files. Unless agregated files are small enough to
### be kept inside the built docker container image, the data needs to be separate from the
### container. In this case we are using the storage account
###

SOURCE_FOLDER="${WORKDIR}/${WEBVIZ_STORAGE}"
DESTINATION_FOLDER="${WEBVIZ_STORAGE}"

echo "Copy generated data to storage account"
azcopy login
azcopy copy "${SOURCE_FOLDER}" "https://${STORAGE_ACCOUNT_NAME}.blob.core.windows.net/${CONTAINER_NAME}/${DESTINATION_FOLDER}/" --recursive

#######################################################################################
### Using the generated assets
###

cp -rf ./generated_app/assets/ ./assets/
cp ./generated_app/.dockerignore ./.dockerignore
cp ./generated_app/theme_settings.json ./theme_settings.json
cp ./generated_app/webviz_app.py ./webviz_app.py

#######################################################################################
### Using the blob storage plugin
###

echo "Replacing sections on generated file"

OLD_IMPORT="from webviz_config.webviz_store import WEBVIZ_STORAGE"
NEW_IMPORT="from webviz_config.webviz_store import WebvizStorage, WEBVIZ_STORAGE\\
from blob_storage.webviz_blob_store import WEBVIZ_BLOB_STORAGE"

OLD_USE_STORAGE="WEBVIZ_STORAGE.use_storage = True"
NEW_USE_STORAGE="WEBVIZ_STORAGE.get_stored_data = WEBVIZ_BLOB_STORAGE.get_stored_data\\
WEBVIZ_STORAGE.use_storage = True"

sed -i -e "s/${OLD_IMPORT}/${NEW_IMPORT}/g" webviz_app.py
sed -i -e "s/${OLD_USE_STORAGE}/${NEW_USE_STORAGE}/g" webviz_app.py

#######################################################################################
### Push to github to trigger build
###

current_time=$(date "+%Y.%m.%d-%H.%M.%S")
git add .
git commit -a -m "Generated code ${current_time}"
git push
