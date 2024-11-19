#!/bin/sh
# Drop all tables script

# Replace 'your_username' and 'your_password' with your actual Oracle credentials
#!/bin/sh
# Create all tables script

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

# Connect to Oracle database
sqlplus "${ORACLE_USER}/${ORACLE_PASS}@${ORACLE_CONN}" <<EOF


DROP TABLE tickets CASCADE CONSTRAINTS;
DROP TABLE seats CASCADE CONSTRAINTS;
DROP TABLE payments CASCADE CONSTRAINTS;
DROP TABLE reviews CASCADE CONSTRAINTS;
DROP TABLE promotions CASCADE CONSTRAINTS;
DROP TABLE users CASCADE CONSTRAINTS;
DROP TABLE events CASCADE CONSTRAINTS;

EXIT;
EOF

