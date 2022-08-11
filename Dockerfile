FROM alpine:3.14

MAINTAINER jota

RUN apk add bash openssl mutt coreutils ssmtp
RUN mkdir /home/jota
COPY jota-cert-checker.sh /home/jota/
COPY html2img.py /home/jota/
COPY sitelist /home/jota/
COPY crontab.txt /home/jota/
COPY entry.sh /home/jota/
COPY ssmtp.conf /etc/ssmtp/
RUN chmod 755 /home/jota/*.sh
RUN chmod 755 /home/jota/*.py
RUN /usr/bin/crontab /home/jota/crontab.txt
WORKDIR /home/jota
CMD ["/home/jota/entry.sh"]
