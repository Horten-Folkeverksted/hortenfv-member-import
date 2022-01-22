# Horten Folkeverksted Spond Club API to PostgreSQL database import script

This scripts logs in to https://club.spond.com/, downloads the all of the
members in your club as JSON and injects them into your specified PostgreSQL
database.

You need the following environment variables set for the command to work:

* SPOND_CLUB_ID
* SPOND_EMAIL
* SPOND_PASSWORD
* PGHOST
* PGDATABASE
* PGUSER
* PGPASSWORD

To build and run the script run the following command:

    ./build && ./run

The database schema can be exported with this command:

    ./run pg_dump -s -x -f /data/schema.sql members \
     && mv data/schema.sql schema.sql \
     && sudo chown $(id -u):$(id -g) schema.sql
