#!/bin/sh
# Populate tables script

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


-- Populating the users table
INSERT INTO users (user_id, password, email) VALUES (1, 'password123', 'john.doe@example.com');
INSERT INTO users (user_id, password, email) VALUES (2, 'mypassword', 'jane.smith@example.com');
INSERT INTO users (user_id, password, email) VALUES (3, 'alicepwd', 'alice.johnson@example.com');
INSERT INTO users (user_id, password, email) VALUES (4, 'bobsecurepwd', 'bob.brown@example.com');
INSERT INTO users (user_id, password, email) VALUES (5, 'charliepwd', 'charlie.davis@example.com');
INSERT INTO users (user_id, password, email) VALUES (6, 'emilypwd', 'emily.clark@example.com');
INSERT INTO users (user_id, password, email) VALUES (7, 'davidpwd', 'david.wilson@example.com');

-- Populating the alternate_identifiers table
INSERT INTO alternate_identifiers (user_id, name, phone_number) VALUES (1, 'John Doe', '1234567890');
INSERT INTO alternate_identifiers (user_id, name, phone_number) VALUES (2, 'Jane Smith', '9876543210');
INSERT INTO alternate_identifiers (user_id, name, phone_number) VALUES (3, 'Alice Johnson', '4567891230');
INSERT INTO alternate_identifiers (user_id, name, phone_number) VALUES (4, 'Bob Brown', '6541239870');
INSERT INTO alternate_identifiers (user_id, name, phone_number) VALUES (5, 'Charlie Davis', '1112223333');
INSERT INTO alternate_identifiers (user_id, name, phone_number) VALUES (6, 'Emily Clark', '4445556666');
INSERT INTO alternate_identifiers (user_id, name, phone_number) VALUES (7, 'David Wilson', '7778889999');

-- Populating the events table
INSERT INTO events (event_id, event_name, event_date, location, capacity) VALUES (1, 'Country Concert', TO_DATE('2024-10-15', 'YYYY-MM-DD'), 'Scotiabank Arena', 20000);
INSERT INTO events (event_id, event_name, event_date, location, capacity) VALUES (2, 'Tech Conference', TO_DATE('2024-11-05', 'YYYY-MM-DD'), 'Silicon Valley Expo Center', 5000);
INSERT INTO events (event_id, event_name, event_date, location, capacity) VALUES (3, 'Comedy Show', TO_DATE('2024-12-20', 'YYYY-MM-DD'), 'LA Comedy Club', 1000);
INSERT INTO events (event_id, event_name, event_date, location, capacity) VALUES (4, 'Art Exhibition', TO_DATE('2024-10-10', 'YYYY-MM-DD'), 'Ontario Art Gallery', 1500);
INSERT INTO events (event_id, event_name, event_date, location, capacity) VALUES (5, 'Jazz Night', TO_DATE('2024-11-20', 'YYYY-MM-DD'), 'Blue Note Club', 300);
INSERT INTO events (event_id, event_name, event_date, location, capacity) VALUES (6, 'Food Festival', TO_DATE('2024-10-25', 'YYYY-MM-DD'), 'Central Park', 10000);

-- Populating the seats table
INSERT INTO seats (event_id, seat_section, seat_number) VALUES (1, 'A', 101);
INSERT INTO seats (event_id, seat_section, seat_number) VALUES (1, 'A', 102);
INSERT INTO seats (event_id, seat_section, seat_number) VALUES (2, 'B', 201);
INSERT INTO seats (event_id, seat_section, seat_number) VALUES (2, 'B', 202);
INSERT INTO seats (event_id, seat_section, seat_number) VALUES (3, 'C', 301);
INSERT INTO seats (event_id, seat_section, seat_number) VALUES (3, 'C', 302);
INSERT INTO seats (event_id, seat_section, seat_number) VALUES (4, 'D', 401);
INSERT INTO seats (event_id, seat_section, seat_number) VALUES (4, 'D', 402);
INSERT INTO seats (event_id, seat_section, seat_number) VALUES (5, 'E', 501);
INSERT INTO seats (event_id, seat_section, seat_number) VALUES (6, 'F', 601);

-- Populating the tickets table
INSERT INTO tickets (ticket_id, user_id, event_id, ticket_date, price, seat_number, seat_section) 
VALUES (1, 1, 1, TO_DATE('2024-09-30', 'YYYY-MM-DD'), 100.00, 101, 'A');
INSERT INTO tickets (ticket_id, user_id, event_id, ticket_date, price, seat_number, seat_section) 
VALUES (2, 2, 2, TO_DATE('2024-10-01', 'YYYY-MM-DD'), 150.00, 201, 'B');
INSERT INTO tickets (ticket_id, user_id, event_id, ticket_date, price, seat_number, seat_section) 
VALUES (3, 3, 3, TO_DATE('2024-10-05', 'YYYY-MM-DD'), 50.00, 301, 'C');
INSERT INTO tickets (ticket_id, user_id, event_id, ticket_date, price, seat_number, seat_section) 
VALUES (4, 4, 4, TO_DATE('2024-09-20', 'YYYY-MM-DD'), 200.00, 401, 'D');
INSERT INTO tickets (ticket_id, user_id, event_id, ticket_date, price, seat_number, seat_section) 
VALUES (5, 5, 5, TO_DATE('2024-10-10', 'YYYY-MM-DD'), 75.00, 501, 'E');
INSERT INTO tickets (ticket_id, user_id, event_id, ticket_date, price, seat_number, seat_section) 
VALUES (6, 6, 6, TO_DATE('2024-10-15', 'YYYY-MM-DD'), 25.00, 601, 'F');

-- Populating the payments table
INSERT INTO payments (payment_id, user_id, event_id, amount, payment_status, payment_method) 
VALUES (1, 1, 1, 100.00, 1, 'Credit Card');
INSERT INTO payments (payment_id, user_id, event_id, amount, payment_status, payment_method) 
VALUES (2, 2, 2, 150.00, 1, 'PayPal');
INSERT INTO payments (payment_id, user_id, event_id, amount, payment_status, payment_method) 
VALUES (3, 3, 3, 50.00, 1, 'Debit Card');
INSERT INTO payments (payment_id, user_id, event_id, amount, payment_status, payment_method) 
VALUES (4, 4, 4, 200.00, 1, 'Cash');
INSERT INTO payments (payment_id, user_id, event_id, amount, payment_status, payment_method) 
VALUES (5, 5, 5, 75.00, 1, 'Credit Card');
INSERT INTO payments (payment_id, user_id, event_id, amount, payment_status, payment_method) 
VALUES (6, 6, 6, 25.00, 1, 'PayPal');

-- Populating the reviews table
INSERT INTO reviews (user_id, event_id, rating, review_text, review_date) 
VALUES (1, 1, 5, 'Amazing concert! Great energy!', TO_DATE('2024-10-16', 'YYYY-MM-DD'));
INSERT INTO reviews (user_id, event_id, rating, review_text, review_date) 
VALUES (2, 2, 4, 'Very informative conference, but too crowded.', TO_DATE('2024-11-06', 'YYYY-MM-DD'));
INSERT INTO reviews (user_id, event_id, rating, review_text, review_date) 
VALUES (3, 3, 3, 'The show was okay, nothing special.', TO_DATE('2024-12-21', 'YYYY-MM-DD'));
INSERT INTO reviews (user_id, event_id, rating, review_text, review_date) 
VALUES (4, 4, 5, 'Stunning art exhibition!', TO_DATE('2024-10-11', 'YYYY-MM-DD'));
INSERT INTO reviews (user_id, event_id, rating, review_text, review_date) 
VALUES (5, 5, 4, 'Wonderful jazz performance. The musicians were very talented.', TO_DATE('2024-11-21', 'YYYY-MM-DD'));
INSERT INTO reviews (user_id, event_id, rating, review_text, review_date) 
VALUES (6, 6, 5, 'Amazing variety of food options, great experience!', TO_DATE('2024-10-26', 'YYYY-MM-DD'));

-- Populating the promotions table
INSERT INTO promotions (promotion_id, discount_percentage, start_date, end_date, is_active, promotion_code) 
VALUES (1, 10.00, TO_DATE('2024-09-01', 'YYYY-MM-DD'), TO_DATE('2024-10-01', 'YYYY-MM-DD'), 0, 'EARLYBIRD');
INSERT INTO promotions (promotion_id, discount_percentage, start_date, end_date, is_active, promotion_code) 
VALUES (2, 20.00, TO_DATE('2024-09-15', 'YYYY-MM-DD'), TO_DATE('2024-11-15', 'YYYY-MM-DD'), 1, 'FALLSALE');
INSERT INTO promotions (promotion_id, discount_percentage, start_date, end_date, is_active, promotion_code) 
VALUES (3, 15.00, TO_DATE('2024-10-01', 'YYYY-MM-DD'), TO_DATE('2024-10-31', 'YYYY-MM-DD'), 1, 'OCTOBERFEST');
INSERT INTO promotions (promotion_id, discount_percentage, start_date, end_date, is_active, promotion_code) 
VALUES (4, 25.00, TO_DATE('2024-10-15', 'YYYY-MM-DD'), TO_DATE('2024-12-31', 'YYYY-MM-DD'), 1, 'HOLIDAY25');
INSERT INTO promotions (promotion_id, discount_percentage, start_date, end_date, is_active, promotion_code) 
VALUES (5, 5.00, TO_DATE('2024-10-01', 'YYYY-MM-DD'), TO_DATE('2024-11-30', 'YYYY-MM-DD'), 1, 'THANKS5');

EXIT;
EOF
