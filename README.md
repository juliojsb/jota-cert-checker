# jota-cert-checker

## Description

A script to check SSL certificate expiration date of a list of sites.

The script can be launched in two modes:

* **Terminal**: Output is displayed in your terminal
* **HTML**: the script generates an HTML file (called **certs_check.html** by default) that can be opened with your browser. 

Optionally, you can also embed the HTML and send it to an email (you will need to install **mutt** if you use this option)

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
