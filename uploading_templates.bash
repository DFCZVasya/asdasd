#!/bin/bash
#Notification center

url=$1
tenant=$2
create_template_url="$url""event/type/create"
upload_template_url="$url""upload_html/"

function get_folders() {
  find . -maxdepth 1 -type d -regex '.*/[^\.].*' -not -name "*-ci"
}

function extract_event_type() {
  event_type=$(grep -m 1 "eventType" ./manifest.yaml | sed "s/.*\: *'\(.*\)'.*/\1/")
  echo "$event_type"
}

function create_template() {
  event_type=$1
  pwd
  echo "Start creation template with event type: $event_type"
  echo "{\"eventType\": \"$event_type\"}"
  status_code=$(curl --http1.1 --silent --output create.res --write-out "%{http_code}" -k -X POST "$create_template_url" \
    -H "X-Tenant-ID: $tenant" \
    -H "accept: application/json" \
    -H "Content-Type: application/json" \
    -d "{\"eventType\": \"$event_type\"}")

  cat create.res
  echo ""
  rm create.res

  if [[ "$status_code" -ne 200 ]]; then
    echo "ERROR: Template with eventType: $event_type was not created. Request failed with status code: $status_code"
    exit 1
  fi
}

function upload_template() {
  zip -r arch.zip ./*

  event_type=$1
  echo "Start uploading an archive for template with event type: $event_type"
  status_code=$(curl --http1.1 --silent --output upload.res --write-out "%{http_code}" -k -X POST "$upload_template_url" \
    -H "X-Tenant-ID: $tenant" \
    -F "file=@arch.zip" \
    -H "Content-Type:multipart/form-data")

  cat upload.res
  echo ""
  rm upload.res
  rm arch.zip

  if [[ "$status_code" -ne 200 ]]; then
    echo "ERROR: Archive for template with eventType: $event_type was not uploaded. Request failed with status code: $status_code"
    exit 1
  fi
}

echo "$url"

cd /Meta/ || exit
for folder in $(get_folders); do
  current_dir=$(pwd)

  cd "$folder" || exit

  event_type=$(extract_event_type)

  create_template "$event_type"

  upload_template "$event_type"

  cd "$current_dir" || exit
done