#!/bin/bash
#
# Author        :Julio Sanz
# Website       :www.elarraydejota.com
# Email         :juliojosesb@gmail.com
# Description   :Script to check SSL certificate expiration date of a list of sites. Recommended to use with a dark terminal theme to
#                see the colors correctly
# Dependencies  :openssl
# Usage         :./ssl-cert-expiration-checker.sh [ file ]
#                Where 'file' is a list of sites with one site per line with format 'site:port', example:
#                google.com:443
#                microsoft.com:443
#                github.com:443
#                ...
# License       :GPLv3
#


#
# VARIABLES
#

sites_list="$1"
sitename=""
current_date=$(date +%s)
end_date=""
days_left=""
certificate_last_day=""
warning_days="30"
alert_days="15"
ok_color="\e[92m"
warning_color="\e[93m"
alert_color="\e[91m"
expired_color="\e[31m"
end_of_color="\033[0m"

#
# FUNCTIONS
#

check_ssl_cert(){
    printf "\n| %-30s | %-30s | %-10s | %-5s %s\n" "SITE" "EXPIRATION DAY" "DAYS LEFT" "STATUS"

    while read site;do
        sitename=$(echo $site | cut -d ":" -f1)
        certificate_last_day=$(echo | openssl s_client -connect ${site} 2>/dev/null | \
        openssl x509 -noout -enddate 2>/dev/null | cut -d "=" -f2)
        end_date=$(date +%s -d "$certificate_last_day")
        days_left=$(((end_date - current_date) / 86400))

        if [ "$days_left" -gt "$warning_days" ];then
            printf "${ok_color}| %-30s | %-30s | %-10s | %-5s %s\n${end_of_color}" "$sitename" "$certificate_last_day" "$days_left" "Ok"
        elif [ "$days_left" -le "$warning_days" ] && [ "$days_left" -gt "$alert_days" ];then
            printf "${warning_color}| %-30s | %-30s | %-10s | %-5s %s\n${end_of_color}" "$sitename" "$certificate_last_day" "$days_left" "Warning"
        elif [ "$days_left" -le "$alert_days" ] && [ "$days_left" -gt 0 ];then
            printf "${alert_color}| %-30s | %-30s | %-10s | %-5s %s\n${end_of_color}" "$sitename" "$certificate_last_day" "$days_left" "Alert"
        elif [ "$days_left" -le 0 ];then
            printf "${expired_color}| %-30s | %-30s | %-10s | %-5s %s\n${end_of_color}" "$sitename" "$certificate_last_day" "$days_left" "Expired"
        fi

    done < $sites_list

    printf "\n %-10s" "STATUS LEGEND"
    printf "\n ${ok_color}%-8s${end_of_color} %-30s" "Ok" "- More than ${warning_days} days left until the certificate expires"
    printf "\n ${warning_color}%-8s${end_of_color} %-30s" "Warning" "- The certificate will expire in less than ${warning_days} days"
    printf "\n ${alert_color}%-8s${end_of_color} %-30s" "Alert" "- The certificate will expire in less than ${alert_days} days"
    printf "\n ${expired_color}%-8s${end_of_color} %-30s\n\n" "Expired" "- The certificate has already expired"
}

how_to_use(){
    echo "Usage: $0 [ file ]"
    echo "Check SSL certificate expiration date from a list of sites"
    echo ""
    echo "In 'file' there must be a list of one site per line with the format sitename:port, for example:"
    echo "google.com:443"
    echo "linux.com:443"
    echo "..."
    echo ""
    echo "Example: ./ssl-cert-expiration-checker.sh sitelist"
}

#
# MAIN
#

if [ $# -ne 1 ];then
    how_to_use
else
    if [ ! -f $sites_list ];then
        echo "$0: The file '$sites_list' does not exist"
        how_to_use
        exit 1
    else
        check_ssl_cert
    fi
fi 
