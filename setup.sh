DOCKER_DATA=$HOME/docker-data
CONTAINER=rss2email

function check_requirements() {
    if [ -d $DOCKER_DATA/rss2email ]; then
        echo "WARNING - rss2email data directory already exists, setup.sh will not modify the files. "
        echo "If you wish to start with a clean configuration, you must remove these files yourself, and run setup.sh again."
        echo " eg.  rm -rf $DOCKER_DATA/rss2email"
        echo ""
    fi
    
    docker inspect $CONTAINER > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "ERROR - Docker container $CONTAINER already exists, you must remove it first before running setup again"
        echo " eg.  docker rm -f $CONTAINER"
        exit 1
    fi

}

function create_container() {
    docker create --name=rss2email --volume=$DOCKER_DATA/rss2email/rss2email:/home/rss2email/.rss2email \
           --volume=$DOCKER_DATA/rss2email/config:/home/rss2email/.config \
           --volume=$DOCKER_DATA/rss2email/ssmtp:/etc/ssmtp enigmacurry/rss2email
}

function create_configuration() {
    if [ -d $DOCKER_DATA/rss2email ]; then
        return 0
    fi
    
    mkdir -p $DOCKER_DATA/rss2email/rss2email
    mkdir -p $DOCKER_DATA/rss2email/ssmtp
    mkdir -p $DOCKER_DATA/rss2email/config

    cat > $DOCKER_DATA/rss2email/ssmtp/ssmtp.conf <<EOF
# The user that gets all the mails (UID < 1000, usually the admin)
root=username@gmail.com

# Username/Password
AuthUser=username
AuthPass=password

# The mail server (where the mail is sent to), both port 465 or 587 should be acceptable
# See also http://mail.google.com/support/bin/answer.py?answer=78799
mailhub=smtp.gmail.com:587

# The address where the mail appears to come from for user authentication.
rewriteDomain=gmail.com

# The full hostname
hostname=localhost

# Use SSL/TLS before starting negotiation
UseTLS=Yes
UseSTARTTLS=Yes

# Email 'From header's can override the default domain?
FromLineOverride=yes
EOF
    chmod 600 $DOCKER_DATA/rss2email/ssmtp/ssmtp.conf

    # Run 'r2e new' in order to create the initial config file
    docker run --rm --volume=$DOCKER_DATA/rss2email/config:/home/rss2email/.config enigmacurry/rss2email setuser rss2email r2e new

    # Turn on HTML mail
    docker run --rm --volume=$DOCKER_DATA/rss2email/config:/home/rss2email/.config enigmacurry/rss2email setuser rss2email perl -pi -e 's/html-mail = False/html-mail = True/' /home/rss2email/.config/rss2email.cfg
    
}

check_requirements
create_configuration
create_container

if [ $? -eq 0 ]; then
    echo ""
    echo "rss2email docker container created."
    echo ""
    echo "Next steps:"
    echo " 1) You must configure your SMTP server settings in $DOCKER_DATA/rss2email/ssmtp/ssmtp.conf"
    echo " 2) (optional) Modify anything you want in $DOCKER_DATA/rss2email/config/rss2email.cfg"
    echo " 3) Start the container with: docker start rss2email"
    echo " 4) Start a shell for the rss2email user: docker exec -it rss2email setuser rss2email bash"
    echo "   a) Add a few RSS feeds: r2e add bitcoin \"http://www.reddit.com/r/bitcoin.rss\" your_email@example.com"
    echo "   b) List all the feeds you're watching: r2e list"
    echo "   d) Test running: r2e run"
    echo ""
    echo "If the test ran successfully, every hour you should now receive emails for updated feeds"
fi
