# Horten Folkeverksted Spond Club API to PostgreSQL database import script

This scripts logs in to https://club.spond.com/, downloads the all of the
members in your club as JSON and injects them into your specified PostgreSQL
database.

It is all done inside a Docker container, to avoid polluting the local
environment with binaries.

You need the following environment variables set for the command to work:

* SPOND_CLUB_ID
* SPOND_EMAIL
* SPOND_PASSWORD
* PGHOST
* PGDATABASE
* PGUSER
* PGPASSWORD

To build the Docker container (required for systemd unit) run the following command:

    ./build

To run the Docker container (make sure `.env` is setup, see below):

    ./run

The database schema can be exported with this command:

    ./run pg_dump -s -x -f /data/schema.sql members \
     && mv data/schema.sql schema.sql \
     && sudo chown $(id -u):$(id -g) schema.sql

Installation of systemd units (make sure you verify the path in the .service file):

    sudo cp hortenfv-member-import.{service,timer} /etc/systemd/system/
    sudo systemctl daemon-reload
    sudo systemctl enable hortenfv-member-import.{service,timer}
    sudo systemctl start hortenfv-member-import.timer

Add the environment variables mentioned above to the file `.env` in the app
directory. Here is an example of its contents:

    SPOND_PASSWORD=myspondpassword
    SPOND_CLUB_ID=D3B671790123456789ABCDEFB097AA68D
    SPOND_EMAIL=myemail@example.com
    PGPASSWORD=mydbpassword
    PGDATABASE=members
    PGHOST=mypghost.example.com
    PGUSER=mypguser

Once you've done that you should change it's permission so it's only
readable by its owner:

    chmod 0600 .env

And then the script should automatically start every night at 03:00, and on
demand by running `sudo systemctl start hortenfv-member-import` whenever you
need to.
