rss2email-docker
================

Docker image for [rss2email](https://github.com/wking/rss2email)

Usage
-----

    ./setup.sh

setup.sh will fetch the docker image from the docker hub, create a data directory under $HOME/docker-data/rss2email to hold configuration files outside of the container, and create the docker container for you. It will list a few more instructions for you at that point:

    Next steps:
     1) You must configure your SMTP server settings in /home/ryan/docker-data/rss2email/ssmtp/ssmtp.conf
     2) (optional) Modify anything you want in /home/ryan/docker-data/rss2email/config/rss2email.cfg
     3) Start the container with: docker start rss2email
     4) Start a shell for the rss2email user: docker exec -it rss2email setuser rss2email bash
       a) Add a few RSS feeds: r2e add bitcoin "http://www.reddit.com/r/bitcoin.rss" your_email@example.com
       b) List all the feeds you're watching: r2e list
       d) Test running: r2e run

    If the test ran successfully, every hour you should now receive emails for updated feeds

The container, once running, will run 'r2e run' once per hour, sending updated feeds to your inbox.
