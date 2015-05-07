# Phusion baseimage comes with cron and a proper init:
FROM phusion/baseimage:latest
MAINTAINER Ryan McGuire <ryan@enigmacurry.com>

RUN useradd -ms /bin/bash rss2email

RUN apt-get update
RUN apt-get install -y ssmtp python3-pip

ADD rss2email.crontab /tmp/
RUN crontab -u rss2email /tmp/rss2email.crontab
RUN mkdir /home/rss2email/.config && \
    ln -s /home/rss2email/.rss2email/rss2email.cfg /home/rss2email/.config/rss2email.cfg && \
    chown -R rss2email:rss2email /home/rss2email/.config

RUN pip3 install feedparser html2text https://github.com/wking/rss2email/archive/master.zip

CMD "/sbin/my_init"
VOLUME ["/home/rss2email/.rss2email", "/home/rss2email/.config", "/etc/ssmtp"]
