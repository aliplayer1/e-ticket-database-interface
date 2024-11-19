#!/bin/sh
# Script to run sample queries with improved formatting

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
sqlplus -s "${ORACLE_USER}/${ORACLE_PASS}@${ORACLE_CONN}" <<EOF


REM Set SQL*Plus environment settings for better output formatting
SET PAGESIZE 1000
SET LINESIZE 200
SET TRIMSPOOL ON
SET WRAP OFF
SET TAB OFF
SET FEEDBACK OFF
SET ECHO OFF
SET HEADING ON
SET TERMOUT ON
SET COLSEP ' | '

Format individual columns
COLUMN user_id FORMAT 9999 HEADING 'User ID'
COLUMN name FORMAT A20
COLUMN user_password FORMAT A15 HEADING 'Password'
COLUMN email FORMAT A25

COLUMN event_id FORMAT 9999 HEADING 'Event ID'
COLUMN event_name FORMAT A25 HEADING 'Event Name'
COLUMN event_date FORMAT A11 HEADING 'Event Date'
COLUMN location FORMAT A25
COLUMN capacity FORMAT 99999

COLUMN seat_section FORMAT A5 HEADING 'Sec.'
COLUMN seat_number FORMAT 9999 HEADING 'Seat No.'

COLUMN ticket_id FORMAT 9999 HEADING 'Ticket ID'
COLUMN ticket_date FORMAT A11 HEADING 'Ticket Date'

COLUMN payment_id FORMAT 9999 HEADING 'Pay ID'
COLUMN payment_status FORMAT 9 HEADING 'Status'
COLUMN payment_method FORMAT A12 HEADING 'Method'

COLUMN rating FORMAT 9
COLUMN review_text FORMAT A40 HEADING 'Review'
COLUMN review_date FORMAT A11 HEADING 'Review Date'

COLUMN promotion_code FORMAT A12 HEADING 'Promo Code'
COLUMN discount_percentage FORMAT 999.99 HEADING 'Discount %'
COLUMN start_date FORMAT A11 HEADING 'Start Date'
COLUMN end_date FORMAT A11 HEADING 'End Date'
COLUMN is_active FORMAT 9 HEADING 'Active'

REM Query 1: List all users
PROMPT
PROMPT ***** List of All Users *****
SELECT u.user_id, ai.name, u.password AS user_password, u.email 
FROM users u
LEFT JOIN alternate_identifiers ai ON u.user_id = ai.user_id;

REM Query 2: List all events
PROMPT
PROMPT ***** List of All Events *****
SELECT event_id, event_name, TO_CHAR(event_date, 'DD-MON-YYYY') AS event_date, location, capacity FROM events;

REM Query 3: Show tickets purchased by each user
PROMPT
PROMPT ***** Tickets Purchased by Users *****
SELECT ai.name AS "User Name", e.event_name AS "Event Name", 
       TO_CHAR(t.ticket_date, 'DD-MON-YYYY') AS "Ticket Date", t.price
FROM tickets t
JOIN users u ON t.user_id = u.user_id
JOIN events e ON t.event_id = e.event_id
JOIN alternate_identifiers ai ON ai.user_id = u.user_id;

REM Query 4: Show reviews for events
PROMPT
PROMPT ***** Reviews for Events *****
SELECT e.event_name, ai.name AS "Reviewer", r.rating, r.review_text
FROM reviews r
JOIN users u ON r.user_id = u.user_id
JOIN events e ON r.event_id = e.event_id
JOIN alternate_identifiers ai ON ai.user_id = u.user_id;

REM Query 5: Show active promotions
PROMPT
PROMPT ***** Active Promotions *****
SELECT promotion_code, discount_percentage, TO_CHAR(start_date, 'DD-MON-YYYY') AS start_date, TO_CHAR(end_date, 'DD-MON-YYYY') AS end_date
FROM promotions
WHERE is_active = 1;

REM Query 6: Show seat availability for an event
PROMPT
PROMPT ***** Seat Availability for Events *****
SELECT e.event_name, s.seat_section AS "Sec.", s.seat_number AS "Seat No."
FROM seats s
JOIN events e ON s.event_id = e.event_id
LEFT JOIN tickets t ON s.event_id = t.event_id AND s.seat_section = t.seat_section AND s.seat_number = t.seat_number
WHERE t.ticket_id IS NULL;

REM Query 7: Count of tickets sold per event
PROMPT
PROMPT ***** Tickets Sold Per Event *****
SELECT e.event_name, COUNT(t.ticket_id) AS "Tickets Sold"
FROM events e
LEFT JOIN tickets t ON e.event_id = t.event_id
GROUP BY e.event_name;

REM Query 8: Total payments received per event
PROMPT
PROMPT ***** Total Payments Received Per Event *****
SELECT e.event_name, SUM(p.amount) AS "Total Payments"
FROM events e
JOIN payments p ON e.event_id = p.event_id
GROUP BY e.event_name;

REM Query 9: Average rating per event
PROMPT
PROMPT ***** Average Rating Per Event *****
SELECT e.event_name, ROUND(AVG(r.rating), 2) AS "Average Rating"
FROM events e
JOIN reviews r ON e.event_id = r.event_id
GROUP BY e.event_name;

REM Query 10: List users who have not purchased any tickets
PROMPT
PROMPT ***** Users Who Have Not Purchased Tickets *****
SELECT ai.name AS "User Name"
FROM users u
LEFT JOIN tickets t ON u.user_id = t.user_id
LEFT JOIN alternate_identifiers ai ON ai.user_id = u.user_id
WHERE t.ticket_id IS NULL;

EXIT;
EOF
