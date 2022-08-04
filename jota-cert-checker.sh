#!/bin/bash
#
# Author        :Julio Sanz
# Website       :www.elarraydejota.com
# Email         :juliojosesb@gmail.com
# Description   :Script to check SSL certificate expiration date of a list of sites. Recommended to use with a dark terminal theme to
#                see the colors correctly. The terminal also needs to support 256 colors.
# Dependencies  :openssl, mutt (if you use the mail option)
# License       :GPLv3
#

#
# VARIABLES
#

script_path=$(dirname $(realpath -s $0))
sites_list="$1"
timeout="5"
show_port="false"
sitename="${sitename:-}"
html_file="${html_file:-certs_check.html}"
img_file="${img_file:-certs_check.jpg}"
current_date=$(date +%s)
end_date="${end_date:-}"
days_left="${days_left:-}"
certificate_last_day="${certificate_last_day:-}"
warning_days="${warning_days:-300}"
alert_days="${alert_days:-150}"
# Terminal colors
ok_color="\e[38;5;40m"
warning_color="\e[38;5;220m"
alert_color="\e[38;5;208m"
expired_color="\e[38;5;196m"
unknown_color="\e[38;5;246m"
end_of_color="\033[0m"
# Slack
slack_token="${slack_token:-your_slack_token}"

#
# FUNCTIONS
#

html_mode(){
	# Generate and reset file
	cat <<- EOF > $html_file
	<!DOCTYPE html>
	<html>
			<head>
			<title>SSL Certs expiration</title>
			</head>
			<body style="background-color: lightblue;">
					<h1 style="color: navy;text-align: center;font-family: 'Helvetica Neue', sans-serif;font-size: 20px;font-weight: bold;">SSL Certs expiration checker</h1>
					<a href="https://github.com/juliojsb/jota-cert-checker" style="position: absolute; top: 0; right: 0px"><img loading="lazy" width="100" height="100" src="https://github.blog/wp-content/uploads/2008/12/forkme_right_darkblue_121621.png?resize=100%2C100" class="attachment-full size-full" alt="Fork me on GitHub" data-recalc-dims="1"></a>
					<table style="background-color: #C5E1E7;padding: 10px;box-shadow: 5px 10px 18px #888888;margin-left: auto ;margin-right: auto ;border: 1px solid black;">
					<tr style="padding: 8px;text-align: left;font-family: 'Helvetica Neue', sans-serif;">
					<th style="padding: 8px;text-align: left;font-family: 'Helvetica Neue', sans-serif;font-weight: bold;">Site</th>
					<th style="padding: 8px;text-align: left;font-family: 'Helvetica Neue', sans-serif;font-weight: bold;">Expiration date</th>
					<th style="padding: 8px;text-align: left;font-family: 'Helvetica Neue', sans-serif;font-weight: bold;">Days left</th>
					<th style="padding: 8px;text-align: left;font-family: 'Helvetica Neue', sans-serif;font-weight: bold;">Status</th>
					</tr>
	EOF

	while read site;do
		sitename=$(echo $site | cut -d ":" -f1)
		port=$(echo $site | cut -d ":" -f2)
		timeout $timeout bash -c "cat < /dev/null > /dev/tcp/$sitename/$port"
		if [ "$?" = 0 ];then
			certificate_last_day=$(echo | openssl s_client -servername ${sitename} -connect ${site} 2>/dev/null | openssl x509 -noout -enddate 2>/dev/null | cut -d "=" -f2)
			end_date=$(date +%s -d "$certificate_last_day")
			days_left=$(((end_date - current_date) / 86400))

			if [ "$days_left" -gt "$warning_days" ];then
				echo "<tr style=\"padding: 8px;text-align: left;font-family: 'Helvetica Neue', sans-serif;\">" >> $html_file
				if [ "$show_port" == "true" ];then
					echo "<td style=\"padding: 8px;background-color: #33FF4F;\">${sitename}:${port}</td>" >> $html_file
				else
					echo "<td style=\"padding: 8px;background-color: #33FF4F;\">${sitename}</td>" >> $html_file
				fi
				echo "<td style=\"padding: 8px;background-color: #33FF4F;\">${certificate_last_day}</td>" >> $html_file
				echo "<td style=\"padding: 8px;background-color: #33FF4F;\">${days_left}</td>" >> $html_file
				echo "<td style=\"padding: 8px;background-color: #33FF4F;\">Ok</td>" >> $html_file
				echo "</tr>" >> $html_file

			elif [ "$days_left" -le "$warning_days" ] && [ "$days_left" -gt "$alert_days" ];then
				echo "<tr style=\"padding: 8px;text-align: left;font-family: 'Helvetica Neue', sans-serif;\">" >> $html_file
				if [ "$show_port" == "true" ];then
					echo "<td style=\"padding: 8px;background-color: #FFE032;\">${sitename}:${port}</td>" >> $html_file
				else
					echo "<td style=\"padding: 8px;background-color: #FFE032;\">${sitename}</td>" >> $html_file
				fi
				echo "<td style=\"padding: 8px;background-color: #FFE032;\">${certificate_last_day}</td>" >> $html_file
				echo "<td style=\"padding: 8px;background-color: #FFE032;\">${days_left}</td>" >> $html_file
				echo "<td style=\"padding: 8px;background-color: #FFE032;\">Warning</td>" >> $html_file
				echo "</tr>" >> $html_file

			elif [ "$days_left" -le "$alert_days" ] && [ "$days_left" -gt 0 ];then
				echo "<tr style=\"padding: 8px;text-align: left;font-family: 'Helvetica Neue', sans-serif;\">" >> $html_file
				if [ "$show_port" == "true" ];then
					echo "<td style=\"padding: 8px;background-color: #FF8F32;\">${sitename}:${port}</td>" >> $html_file
				else
					echo "<td style=\"padding: 8px;background-color: #FF8F32;\">${sitename}</td>" >> $html_file
				fi
				echo "<td style=\"padding: 8px;background-color: #FF8F32;\">${certificate_last_day}</td>" >> $html_file
				echo "<td style=\"padding: 8px;background-color: #FF8F32;\">${days_left}</td>" >> $html_file
				echo "<td style=\"padding: 8px;background-color: #FF8F32;\">Alert</td>" >> $html_file
				echo "</tr>" >> $html_file

			elif [ "$days_left" -le 0 ];then
				echo "<tr style=\"padding: 8px;text-align: left;font-family: 'Helvetica Neue', sans-serif;\">" >> $html_file
				if [ "$show_port" == "true" ];then
					echo "<td style=\"padding: 8px;background-color: #EF3434;\">${sitename}:${port}</td>" >> $html_file
				else
					echo "<td style=\"padding: 8px;background-color: #EF3434;\">${sitename}</td>" >> $html_file
				fi
				echo "<td style=\"padding: 8px;background-color: #EF3434;\">${certificate_last_day}</td>" >> $html_file
				echo "<td style=\"padding: 8px;background-color: #EF3434;\">${days_left}</td>" >> $html_file
				echo "<td style=\"padding: 8px;background-color: #EF3434;\">Expired</td>" >> $html_file
				echo "</tr>" >> $html_file
			fi
		else
			echo "<tr style=\"padding: 8px;text-align: left;font-family: 'Helvetica Neue', sans-serif;\">" >> $html_file
			if [ "$show_port" == "true" ];then
				echo "<td style=\"padding: 8px;background-color: #999493;\">${sitename}:${port}</td>" >> $html_file
			else
				echo "<td style=\"padding: 8px;background-color: #999493;\">${sitename}</td>" >> $html_file
			fi
			echo "<td style=\"padding: 8px;background-color: #999493;\">n/a</td>" >> $html_file
			echo "<td style=\"padding: 8px;background-color: #999493;\">n/a</td>" >> $html_file
			echo "<td style=\"padding: 8px;background-color: #999493;\">Unknown</td>" >> $html_file
			echo "</tr>" >> $html_file
		fi
	done < ${sites_list}

	# Close main HTML tags
	cat <<- EOF >> $html_file
			</table>
			</body>
	</html>
	EOF
}

terminal_mode(){
	printf "\n| %-25s | %-25s | %-10s | %-8s %s\n" "SITE" "EXPIRATION DAY" "DAYS LEFT" "STATUS"

	while read site;do
		sitename=$(echo $site | cut -d ":" -f1)
		port=$(echo $site | cut -d ":" -f2)
		timeout $timeout bash -c "cat < /dev/null > /dev/tcp/$sitename/$port"
		if [ "$?" = 0 ];then
			certificate_last_day=$(echo | openssl s_client -servername ${sitename} -connect ${site} 2>/dev/null | openssl x509 -noout -enddate 2>/dev/null | cut -d "=" -f2)
			end_date=$(date +%s -d "$certificate_last_day")
			days_left=$(((end_date - current_date) / 86400))
		
			if [ "$days_left" -gt "$warning_days" ];then
				if [ "$show_port" == "true" ];then
					printf "${ok_color}| %-25s | %-25s | %-10s | %-8s %s\n${end_of_color}" \
					"${sitename}:${port}" "$certificate_last_day" "$days_left" "Ok"
				else
					printf "${ok_color}| %-25s | %-25s | %-10s | %-8s %s\n${end_of_color}" \
					"$sitename" "$certificate_last_day" "$days_left" "Ok"
				fi

			elif [ "$days_left" -le "$warning_days" ] && [ "$days_left" -gt "$alert_days" ];then
				if [ "$show_port" == "true" ];then
					printf "${warning_color}| %-25s | %-25s | %-10s | %-8s %s\n${end_of_color}" \
					"${sitename}:${port}" "$certificate_last_day" "$days_left" "Warning"
				else
					printf "${warning_color}| %-25s | %-25s | %-10s | %-8s %s\n${end_of_color}" \
					"$sitename" "$certificate_last_day" "$days_left" "Warning"
				fi

			elif [ "$days_left" -le "$alert_days" ] && [ "$days_left" -gt 0 ];then
				if [ "$show_port" == "true" ];then
					printf "${alert_color}| %-25s | %-25s | %-10s | %-8s %s\n${end_of_color}" \
					"${sitename}:${port}" "$certificate_last_day" "$days_left" "Alert"
				else
					printf "${alert_color}| %-25s | %-25s | %-10s | %-8s %s\n${end_of_color}" \
					"$sitename" "$certificate_last_day" "$days_left" "Alert"
				fi
			elif [ "$days_left" -le 0 ];then
				if [ "$show_port" == "true" ];then
					printf "${expired_color}| %-25s | %-25s | %-10s | %-8s %s\n${end_of_color}" \
					"${sitename}:${port}" "$certificate_last_day" "$days_left" "Expired"
				else
					printf "${expired_color}| %-25s | %-25s | %-10s | %-8s %s\n${end_of_color}" \
					"$sitename" "$certificate_last_day" "$days_left" "Expired"
				fi
			fi
		else
			if [ "$show_port" == "true" ];then
				printf "${unknown_color}| %-25s | %-50s | %-25s | %-10s | %-5s %s\n${end_of_color}" \
				"${sitename}:${port}" "n/a" "n/a" "n/a"
			else
				printf "${unknown_color}| %-25s | %-50s | %-25s | %-10s | %-5s %s\n${end_of_color}" \
				"$sitename" "n/a" "n/a" "n/a"
			fi				
		fi
	done < ${sites_list} 

	printf "\n %-10s" "STATUS LEGEND"
	printf "\n ${ok_color}%-8s${end_of_color} %-30s" "Ok" "- More than ${warning_days} days left until the certificate expires"
	printf "\n ${warning_color}%-8s${end_of_color} %-30s" "Warning" "- The certificate will expire in less than ${warning_days} days"
	printf "\n ${alert_color}%-8s${end_of_color} %-30s" "Alert" "- The certificate will expire in less than ${alert_days} days"
	printf "\n ${expired_color}%-8s${end_of_color} %-30s" "Expired" "- The certificate has already expired"
	printf "\n ${unknown_color}%-8s${end_of_color} %-30s\n\n" "Unknown" "- The site with defined port could not be reached"
}

howtouse(){
	cat <<-'EOF'

	You must always specify -f option with the name of the file that contains the list of sites to check
	Options:
		-f [ sitelist file ]          list of sites (domains) to check
		-o [ html | terminal ]        output (can be html or terminal)
		-m [ mail ]                   mail address to send the graphs to
		-s [ slack_channel ]          slack channel to send the report to
		-h                            help
	
	Examples:

		# Launch the script in terminal mode:
		./jota-cert-checker.sh -f sitelist -o terminal

		# Using HTML mode:
		./jota-cert-checker.sh -f sitelist -o html

		# Using HTML mode and sending results via email
		./jota-cert-checker.sh -f sitelist -o html -m mail@example.com

		# Using HTML mode and sending results via email
		./jota-cert-checker.sh -f sitelist -o html -s my_slack_channel

	EOF
}

# 
# MAIN
# 

cd "$script_path"

if [ "$#" -eq 0 ];then
	howtouse

elif [ "$#" -ne 0 ];then
	while getopts ":f:o:m:s:h" opt; do
		case $opt in
			"f")
				sites_list="$OPTARG"
				;;
			"o")
				output="$OPTARG"
				if [ "$output" == "terminal" ];then
					terminal_mode
				elif [ "$output" == "html" ];then
					html_mode
				else
					echo "Wrong output selected"
					howtouse
				fi
				;;
			"m")
				if [ "$output" == "html" ];then
					mail_to="$OPTARG"
				else
					echo "Mail option is only used with HTML mode"
				fi
				;;
			"s")
				if [ "$output" == "html" ];then
					slack_to="$OPTARG"
				else
					echo "Slack option is only used with HTML mode"
				fi
				;;
			\?)
				echo "Invalid option: -$OPTARG" >&2
				howtouse
				exit 1
				;;
			:)
				echo "Option -$OPTARG requires an argument." >&2
				howtouse
				exit 1
				;;
			"h" | *)
				howtouse
				exit 1
				;;
		esac
	done

	# Send mail if specified
	if [[ $mail_to ]];then
		sed -i '/forkme/d' $html_file
		mutt -e 'set content_type="text/html"' $mail_to -s "SSL certs expiration check" < $html_file
	fi

	# Send slack if specified
	if [[ $slack_to ]];then
		python3 html2img.py "${html_file}" "${img_file}"
		curl -s \
			--form-string channels="${slack_to}" \
			-F file="@${img_file}" \
			-F filename="@${img_file}" \
			-F token="${slack_token}" \
			https://slack.com/api/files.upload
	fi
fi
