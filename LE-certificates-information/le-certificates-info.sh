#!/usr/bin/env bash
LANG='en_US.UTF-8'

function get-cert-info {
  #
  local SUBJECT=$(openssl x509 -text -in $1 | grep 'Subject:' | tr -d " \t" | sed 's/'"Subject:CN="'//')
  #
  local AFTER_DATE=$(openssl x509 -in $1 -text| grep 'Not Before' | sed 's/.'"Not Before: "'//' | sed 's/^ *//')
  local BEFORE_DATE=$(openssl x509 -in $1 -text| grep 'Not After' | sed 's/.'"Not After : "'//' | sed 's/^ *//')
  local TODAY_DATE=$(date --utc)
  #
  local BEFORE_DATE_EPOCH=$(date --date="${BEFORE_DATE}" --utc +"%s")
  local TODAY_DATE_EPOCH=$(date --date="${TODAY_DATE}" +"%s")
  local DAYS_LEFT=$(( (BEFORE_DATE_EPOCH - TODAY_DATE_EPOCH) / 86400 ))
  #
  local AFTER_DATE_DD_MM_YYYY=$(date --date="${AFTER_DATE}" --utc +"%d-%m-%Y")
  local BEFORE_DATE_DD_MM_YYYY=$(date --date="${BEFORE_DATE}" --utc +"%d-%m-%Y")
  # Массив первая строка ключи, вторая значения
  local KEY_VALUE_ARRAY="SUBJECT|AFTER_DATE|BEFORE_DATE|DAYS_LEFT
${SUBJECT}|${AFTER_DATE_DD_MM_YYYY}|${BEFORE_DATE_DD_MM_YYYY}|${DAYS_LEFT}"

  # Превращаем в json массив с данными
  jq -M -Rn '
  ( input  | split("|") ) as $keys |
  ( inputs | split("|") ) as $vals |
  [[$keys, $vals] | transpose[] | {key:.[0],value:.[1]}] | from_entries
  ' <<<"${KEY_VALUE_ARRAY}"
}

function find-certs {
  LE_CERTS=$(find /etc/letsencrypt/live/* -type d -exec basename {} \;)
}

function discovery {
  find-certs
  local CERT_INFO_FILE_PATH='/tmp/le-discrovery.json'
  printf '[\n'
  # printf '  "data": {\n'
  for CERT in ${LE_CERTS[@]} ; do
    local KEY_VALUE_ARRAY="CERTIFICATE
${CERT}"
    # Превращаем в json массив с данными
    jq -M -Rn '
    ( input  | split("|") ) as $keys |
    ( inputs | split("|") ) as $vals |
    [[$keys, $vals] | transpose[] | {key:.[0],value:.[1]}] | from_entries
    ' <<<"${KEY_VALUE_ARRAY}" >> ${CERT_INFO_FILE_PATH}
  done
  cat ${CERT_INFO_FILE_PATH} | head -n -1 | sed 's/^/  /' | sed 's/ }/ },/'
  # printf '    }\n'
  printf '  }\n'
  printf ']\n'
  rm -f ${CERT_INFO_FILE_PATH}
}

function certs-info {
  find-certs
  local CERT_INFO_FILE_PATH='/tmp/le-certs.json'
  for CERT in ${LE_CERTS[@]} ; do
    echo -e "\""${CERT}"\": \c" >> ${CERT_INFO_FILE_PATH}
    get-cert-info /etc/letsencrypt/live/${CERT}/fullchain.pem | sed 's/}/},/' >> ${CERT_INFO_FILE_PATH}
  done
  printf '{\n'
#  printf '  "data": [\n'
  cat ${CERT_INFO_FILE_PATH} | head -n -1 | sed 's/^/    /'
  printf '    }\n'
#  printf '  ]\n'
  printf '}\n'
  rm -f ${CERT_INFO_FILE_PATH}
}
$1
