#!/bin/sh

set -e

# Required
if [ -z "$SPOND_CLUB_ID" ]; then
    echo "Please specify SPOND_CLUB_ID"
    exit 1
fi

# Required
if [ -z "$SPOND_EMAIL" ]; then
    echo "Please specify SPOND_EMAIL"
    exit 1
fi

# Required
if [ -z "$SPOND_PASSWORD" ]; then
    echo "Please specify SPOND_PASSWORD"
    exit 1
fi

# Required
if [ -z "$PGHOST" ]; then
    echo "Please specify PGHOST"
    exit 1
fi

# Required
if [ -z "$PGDATABASE" ]; then
    echo "Please specify PGDATABASE"
    exit 1
fi

# Required
if [ -z "$PGUSER" ]; then
    echo "Please specify PGUSER"
    exit 1
fi

# Required
if [ -z "$PGPASSWORD" ]; then
    echo "Please specify PGPASSWORD"
    exit 1
fi

if [ -z "$PGPORT" ]; then
    export PGPORT=5432
fi


if [ -z "$PGSSLMODE" ]; then
    export PGSSLMODE="require"
fi

# Ensure data directory exists
if [ ! -d "data" ]; then
    if [ -e "data" ]; then
        echo "Please ensure the 'data' is a directory"
        exit 1
    fi
    mkdir -p data
fi

SPOND_CREDS="{\"email\":\"$SPOND_EMAIL\",\"password\":\"$SPOND_PASSWORD\"}"

# Login and store cookies
echo "Logging in to Spond Using SPOND_EMAIL=$SPOND_EMAIL and SPOND_PASSWORD=<hidden>..."
curl -s -c data/cookies.txt -H 'Content-Type: application/json' \
 -d "$SPOND_CREDS" -o data/login.json \
 'https://club.spond.com/club-api/v1/login'

# Fetch member types with cookie auth
echo "Fetching Spond member types using SPOND_CLUB_ID=$SPOND_CLUB_ID..."
curl -s -b data/cookies.txt -H "X-Spond-ClubId: $SPOND_CLUB_ID" \
 'https://club.spond.com/club-api/v1/memberTypes' | jq . > data/types.json

# Fetch field types with cookie auth
echo "Fetching Spond member fields using SPOND_CLUB_ID=$SPOND_CLUB_ID..."
curl -s -b data/cookies.txt -H "X-Spond-ClubId: $SPOND_CLUB_ID" \
 'https://club.spond.com/club-api/v1/fields' | jq .clubFields > data/fields.json

# Fetch members with cookie auth
echo "Fetching Spond members using SPOND_CLUB_ID=$SPOND_CLUB_ID..."
curl -s -b data/cookies.txt -H "X-Spond-ClubId: $SPOND_CLUB_ID" \
 'https://club.spond.com/club-api/v1/members' | jq . > data/members.json

# Import JSON files into PostgreSQL database tables
echo "Importing downloaded Spond JSON data into members database..."
echo "Using PGHOST=$PGHOST"
echo "Using PGPORT=$PGPORT"
echo "Using PGDATABASE=$PGDATABASE"
echo "Using PGUSER=$PGUSER"
echo "Using PGSSLMODE=$PGSSLMODE"
echo "Using PGPASSWORD=<hidden>"
psql -1 <<'EOF'
-- Import member types
\set content `cat data/types.json`
DELETE FROM member_types;
INSERT INTO member_types (
    id,
    name
) SELECT * FROM json_populate_recordset(null::member_types, :'content');

-- Import member fields
\set content `cat data/fields.json`
DELETE FROM member_fields;
INSERT INTO member_fields (
    id,
    name,
    type
) SELECT * FROM json_populate_recordset(null::member_fields, :'content');

-- Import members
\set content `cat data/members.json`
DELETE FROM members;
INSERT INTO members (
    id,
    "firstName",
    "lastName",
    profile,
    type,
    "fieldValues",
    guardians,
    nationality,
    "joinedDate",
    "dateOfBirth",
    address,
    country,
    groups,
    gender,
    deleted
) SELECT * FROM json_populate_recordset(null::members, :'content');
EOF
