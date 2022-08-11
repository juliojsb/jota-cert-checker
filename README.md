# jota-cert-checker

## Description

A script to check SSL certificate expiration date of a list of sites.

The script can be launched in two modes:

* **Terminal**: Output is displayed in your terminal
* **HTML**: the script generates an HTML file (called **certs_check.html** by default) that can be opened with your browser. 

Optionally, you can also embed the HTML and send it via:

* **email**: you will need to install **mutt** if you use this option
* **slack**: install **imgkit** via pip and **wkhtmltopdf** using your distribution package manager (in RHEL/CentOS you will need to enable EPEL first) Don't forget to configure you Slack Token the **slack_token** variable of jota-cert-checker.sh script

## Usage

For example, we have the following file called sitelist that contains a list of domains with the HTTPS port, one domain per line:

```
linux.com:443
kernel.org:443
gnu.org:443
debian.org:443
ubuntu.com:443
github.com:443
google.es:443
redhat.com:443
superuser.com:443
youtube.com:443
stackoverflow.com:443
stackexchange.com:443
wikipedia.org:443
python.org:443
codecademy.com:443
packtpub.com:443
reddit.com:443
mysql.com:443
```

In the following cases I modified the variables **warning_days** and **alert_days** for sample purposes. 

To launch the script in terminal mode:
```bash
./jota-cert-checker.sh -f sitelist -o terminal
```
We get the following output in our terminal:

![screenshot from 2018-02-11 20-33-06](https://user-images.githubusercontent.com/12804701/36077449-5f85d338-0f6b-11e8-991d-1ffef916d4b6.png)

In HTML mode:
```bash
./jota-cert-checker.sh -f sitelist -o html
```
We get the following output:

![screenshot from 2018-02-11 20-29-44](https://user-images.githubusercontent.com/12804701/36077452-6c282e4c-0f6b-11e8-966b-f3d863298586.png)

In HTML mode and sending the result to an email:
```bash
./jota-cert-checker.sh -f sitelist -o html -m mail@example.com
```
Checking our email we will see:

![screenshot from 2018-02-11 20-30-11](https://user-images.githubusercontent.com/12804701/36078161-891bb566-0f73-11e8-984c-1cd65127a8e4.png)

Also in HTML mode and sending the result to a slack channel:
```bash
./jota-cert-checker.sh -f sitelist -o html -s my_slack_channel
```

## Docker
You can also use this script inside a docker container. Just modify the following files as you need:

* `ssmpt.conf`: specify the mail server (I included gmail as example), mail account and password.
* `crontab.txt`: specify the mail account and crontab config. By default the script runs everyday at 08AM

### Build & Run

Once you hace customized the config files, build the image:
```bash
docker build -t jota-cert-checker .
```
Then run it:
```bash
docker run --name jota-cert-checker -d jota-cert-checker
```
Once running, you can enter the container and operate as you need:
```bash
docker exec -it jota-cert-checker bash
```
```bash
bash-5.1# crontab -l
0 8 * * * /home/jota/jota-cert-checker.sh -f sitelist -o html -m mail@example.com
bash-5.1# ./jota-cert-checker.sh -f sitelist -o terminal

| SITE                      | EXPIRATION DAY            | DAYS LEFT  | STATUS   
| linux.com                 | Oct 19 00:02:05 2022 GMT  | 68         | Alert    
| kernel.org                | Oct 17 18:03:22 2022 GMT  | 66         | Alert    
| gnu.org                   | Sep 14 22:42:29 2022 GMT  | 34         | Alert    
| debian.org                | Nov  9 00:15:51 2022 GMT  | 89         | Alert    
| ubuntu.com                | Oct 16 10:20:35 2022 GMT  | 65         | Alert    
| github.com                | Mar 15 23:59:59 2023 GMT  | 216        | Warning  
| google.es                 | Oct 10 08:27:29 2022 GMT  | 59         | Alert    
| redhat.com                | Mar 29 23:59:59 2023 GMT  | 230        | Warning  
| superuser.com             | Oct 18 16:09:00 2022 GMT  | 67         | Alert    
| youtube.com               | Oct 10 08:18:56 2022 GMT  | 59         | Alert    
| stackoverflow.com         | Oct 18 16:09:00 2022 GMT  | 67         | Alert    
| stackexchange.com         | Oct 18 16:09:00 2022 GMT  | 67         | Alert    
| wikipedia.org             | Nov 17 23:59:59 2022 GMT  | 98         | Alert    
| python.org                | Oct 24 15:59:15 2022 GMT  | 73         | Alert    
| codecademy.com            | Jul 11 23:59:59 2023 GMT  | 334        | Ok       
| packtpub.com              | May  7 23:59:59 2023 GMT  | 269        | Warning  
| reddit.com                | Dec 30 23:59:59 2022 GMT  | 141        | Alert    
| mysql.com                 | Feb 25 23:59:59 2023 GMT  | 198        | Warning  

 STATUS LEGEND
 Ok       - More than 300 days left until the certificate expires
 Warning  - The certificate will expire in less than 300 days
 Alert    - The certificate will expire in less than 150 days
 Expired  - The certificate has already expired
 Unknown  - The site with defined port could not be reached
```
