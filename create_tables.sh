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

-- Drop tables if they exist
DROP TABLE reviews CASCADE CONSTRAINTS;
DROP TABLE promotions CASCADE CONSTRAINTS;
DROP TABLE payments CASCADE CONSTRAINTS;
DROP TABLE tickets CASCADE CONSTRAINTS;
DROP TABLE seats CASCADE CONSTRAINTS;
DROP TABLE events CASCADE CONSTRAINTS;
DROP TABLE alternate_identifiers CASCADE CONSTRAINTS;
DROP TABLE users CASCADE CONSTRAINTS;

-- Revised users table
CREATE TABLE users(
    user_id INT PRIMARY KEY NOT NULL,
    password VARCHAR2(200) NOT NULL,
    email VARCHAR2(100) NOT NULL
);

-- Separate alternate identifiers table
CREATE TABLE alternate_identifiers(
    user_id INT REFERENCES users(user_id),
    name VARCHAR2(40) UNIQUE,
    phone_number VARCHAR2(15) UNIQUE,
    PRIMARY KEY (user_id)
);

-- Events table
CREATE TABLE events(
    event_id INT PRIMARY KEY NOT NULL,
    event_name VARCHAR2(100) NOT NULL,
    event_date DATE NOT NULL,
    location VARCHAR2(100),
    capacity INT
);

-- Seats table
CREATE TABLE seats(
    event_id INT REFERENCES events(event_id),
    seat_section VARCHAR2(10),
    seat_number INT,
    PRIMARY KEY (seat_number, seat_section)
);

-- Revised tickets table with event_id
CREATE TABLE tickets(
    ticket_id INT PRIMARY KEY NOT NULL,
    user_id INT REFERENCES users(user_id),
    event_id INT REFERENCES events(event_id), -- Added event_id
    ticket_date DATE NOT NULL,
    price NUMBER(10,2),
    seat_number INT,
    seat_section VARCHAR2(10),
    FOREIGN KEY (seat_number, seat_section)
    REFERENCES seats(seat_number, seat_section)
);

-- Payments table
CREATE TABLE payments(
    payment_id INT PRIMARY KEY NOT NULL,
    user_id INT REFERENCES users(user_id),
    event_id INT REFERENCES events(event_id),
    amount NUMBER(10,2) NOT NULL,
    payment_status VARCHAR2(20) NOT NULL,
    payment_method VARCHAR2(50)
);

-- Reviews table
CREATE TABLE reviews(
    user_id INT REFERENCES users(user_id),
    event_id INT REFERENCES events(event_id),
    rating INT,
    review_text VARCHAR2(300),
    review_date DATE,
    PRIMARY KEY (user_id, event_id),
    CONSTRAINT chk_rating CHECK (rating BETWEEN 1 AND 5)
);

-- Promotions table
CREATE TABLE promotions(
    promotion_id INT PRIMARY KEY NOT NULL,
    discount_percentage NUMBER(5,2),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    is_active NUMBER(1),
    promotion_code VARCHAR2(20),
    CONSTRAINT unique_promotion_code UNIQUE (promotion_code)
);

EXIT;
EOF
