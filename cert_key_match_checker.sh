#!/bin/bash
#
# Script        :cert_key_match_checker.sh
# Author        :Julio Sanz
# Website       :www.elarraydejota.com
# Email         :juliojosesb@gmail.com
# Description   :Script to check if a given certificate belongs to a given private
#                key. Useful to troubleshoot web server certificate mismatches and errors.
# Dependencies  :openssl
# Usage         :./cert_key_match_checker.sh [ private_key_location ] [ certificate_location ]
# License       :GPLv3
#
#################################################################################

#--------------------------
# VARIABLES
#--------------------------

v_key=$1
v_cert=$2

#--------------------------
# FUNCTIONS
#--------------------------

function f_check_match(){
    certificate_modulus=$(openssl x509 -noout -modulus -in $v_cert | openssl md5 | awk '{print $2}')
    key_modulus=$(openssl rsa -noout -modulus -in $v_key | openssl md5 | awk '{print $2}')
    if [[ "$certificate_modulus" == "$key_modulus" ]];then
        echo "LOOKS GOOD! This certificate belongs to the private key provided"
        echo "Private key modulus -> ${key_modulus}"
        echo "Certificate modulus -> ${certificate_modulus}"
    else
        echo "WARNING! The certificate doesn't belong to the given private key"
        echo "Think twice before using this key and certificate in your web server, it won't even start"
        echo "Private key modulus -> ${key_modulus}"
        echo "Certificate modulus -> ${certificate_modulus}"
    fi
    exit 0
}

function f_how_to_use(){
    echo "Usage -> ./cert_key_match_checker.sh [ private_key_location ] [ certificate_location ]
    echo "Example: ./cert_key_match_checker.sh /tmp/myprivkey.key /tmp/mycert.crt
    exit 1
}

#--------------------------
# MAIN
#--------------------------

if [ $# -ne 2 ];then
    echo "The script needs at least two parameters, please check usage..."
    f_how_to_use
else
    f_check_match
fi
