#!/bin/sh
# Script to list all user tables

# Load database configuration
if [ -f db_config.env ]; then
    source db_config.env
else
    echo "Error: db_config.env file not found! Please create one based on db_config_sample.env."
    exit 1
fi

# Check if all required variables are set
if [ -z "$ORACLE_USER" ] || [ -z "$ORACLE_PASS" ] || [ -z "$ORACLE_CONN" ]; then
    echo "Error: Missing database credentials in db_config.env."
    exit 1
fi

# Connect to Oracle database and list tables
sqlplus -s "${ORACLE_USER}/${ORACLE_PASS}@${ORACLE_CONN}" <<EOF
SET PAGESIZE 0 FEEDBACK OFF VERIFY OFF HEADING OFF ECHO OFF
SELECT table_name FROM user_tables;
EXIT;
EOF