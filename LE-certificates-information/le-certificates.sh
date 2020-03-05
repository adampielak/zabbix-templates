#!/usr/bin/env bash
function remove-last-symbol {
  sed 's/.$//'
}

function to-key-value {
  for INDEX in ${!ARRAY[*]}; do
    KEY_VALUE_OUT=''
    KEY_VALUE_OUT="${KEY_VALUE_OUT}$(printf '"')"
    KEY_VALUE_OUT="${KEY_VALUE_OUT}$(printf "${ARRAY[$INDEX]}")"
    KEY_VALUE_OUT="${KEY_VALUE_OUT}$(printf '"')"
    KEY_VALUE_OUT="${KEY_VALUE_OUT}$(printf ':')"
    KEY_VALUE_OUT="${KEY_VALUE_OUT}$(printf '"')"
    KEY_VALUE_OUT="${KEY_VALUE_OUT}$(printf "${ARRAY2[$INDEX]}")"
    KEY_VALUE_OUT="${KEY_VALUE_OUT}$(printf '"')"
    printf "${KEY_VALUE_OUT}"
    printf ','
  done
}

function find-certificates {
  LE_CERTS=$(find /etc/letsencrypt/live/* -type d -exec basename {} \;)
}

function openssl-parse-certificate-file {
  #
  local SUBJECT=$(openssl x509 -text -in $1 | grep 'Subject:' | tr -d " \t" | sed 's/'"Subject:CN="'//')
  #
  local AFTER_DATE=$(openssl x509 -in $1 -text| grep 'Not Before' | sed 's/.'"Not Before: "'//' | sed 's/^ *//')
  local BEFORE_DATE=$(openssl x509 -in $1 -text| grep 'Not After' | sed 's/.'"Not After : "'//' | sed 's/^ *//')
  #
  local AFTER_DATE_DD_MM_YYYY=$(date --date="${AFTER_DATE}" --utc +"%d-%m-%Y")
  local BEFORE_DATE_DD_MM_YYYY=$(date --date="${BEFORE_DATE}" --utc +"%d-%m-%Y")
  #
  local BEFORE_DATE_EPOCH=$(date --date="${BEFORE_DATE}" --utc +"%s")
  # Массив со значениями из сертификата
  CERTS_INFO=("${SUBJECT}" "${AFTER_DATE_DD_MM_YYYY}" "${BEFORE_DATE_DD_MM_YYYY}" "${BEFORE_DATE_EPOCH}")

}

function discovery {
  local KEY='{#CERTIFICATE}'
  find-certificates
  printf '['
  local INFO=$(for CERT in ${LE_CERTS[@]} ; do
    printf '{'
    printf '"'
    printf "${KEY}"
    printf '"'
    printf ':'
    printf '"'
    printf ${CERT}
    printf '"'
    printf '}'
    printf ','
  done)
  printf ${INFO} | remove-last-symbol
  printf ']\n'
}

function information {
  find-certificates
  printf '{'
  local INFO=$(for CERT in ${LE_CERTS[@]} ; do
    CERT_PATH="/etc/letsencrypt/live/${CERT}/fullchain.pem"
    openssl-parse-certificate-file ${CERT_PATH}
    printf '"'
    printf ${CERT}
    printf '"'
    printf ':'
    # Массив с ключями
    ARRAY=(SUBJECT AFTER_DATE BEFORE_DATE BEFORE_DATE_EPOCH)
    # Массив с значениями
    ARRAY2=("${CERTS_INFO[@]}")
    printf '{'
    to-key-value | remove-last-symbol
    printf '}'
    printf ','
  done)
  printf ${INFO} | remove-last-symbol
  printf '}\n'
}

case "$1" in
  #
  discovery)
    discovery
    ;;
  #
  information)
    information
    ;;
  # Выходим с ошибкой в ином случае
  *)
    exit 1
    ;;
esac
