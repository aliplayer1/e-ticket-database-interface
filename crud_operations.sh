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


# Database schema definitions
declare -A SCHEMA
SCHEMA=(
    [users]="user_id:INT:Unique identifier
password:VARCHAR2(200):User password
email:VARCHAR2(100):Email address"

    [alternate_identifiers]="user_id:INT:User ID reference
name:VARCHAR2(40):Full name
phone_number:VARCHAR2(15):Contact number"

    [events]="event_id:INT:Unique event ID
event_name:VARCHAR2(100):Name of the event
event_date:DATE:Date (YYYY-MM-DD)
location:VARCHAR2(100):Event location
capacity:INT:Maximum capacity"

    [seats]="event_id:INT:Event ID reference
seat_section:VARCHAR2(10):Section identifier
seat_number:INT:Seat number"

    [tickets]="ticket_id:INT:Unique ticket ID
user_id:INT:User ID reference
event_id:INT:Event ID reference
ticket_date:DATE:Date (YYYY-MM-DD)
price:NUMBER(10,2):Ticket price
seat_number:INT:Seat number
seat_section:VARCHAR2(10):Section identifier"

    [payments]="payment_id:INT:Unique payment ID
user_id:INT:User ID reference
event_id:INT:Event ID reference
amount:NUMBER(10,2):Payment amount
payment_status:VARCHAR2(20):Status (e.g., completed)
payment_method:VARCHAR2(50):Method of payment"

    [reviews]="user_id:INT:User ID reference
event_id:INT:Event ID reference
rating:INT:Rating (1-5)
review_text:VARCHAR2(300):Review content
review_date:DATE:Date (YYYY-MM-DD)"

    [promotions]="promotion_id:INT:Unique promotion ID
discount_percentage:NUMBER(5,2):Discount %
start_date:DATE:Start date (YYYY-MM-DD)
end_date:DATE:End date (YYYY-MM-DD)
is_active:NUMBER(1):Active status (0/1)
promotion_code:VARCHAR2(20):Unique code"
)

# Helper function to parse schema for a table
parse_schema() {
    local table=$1
    local schema=${SCHEMA[$table]}
    
    COLUMNS=(); DATA_TYPES=(); DESCRIPTIONS=()
    
    while IFS= read -r line; do
        IFS=':' read -r col dtype desc <<< "$line"
        COLUMNS+=("$col")
        DATA_TYPES+=("$dtype")
        DESCRIPTIONS+=("$desc")
    done <<< "$schema"
}

# Function to generate column formatting SQL
generate_column_formats() {
    local formats=""
    for i in "${!COLUMNS[@]}"; do
        local col="${COLUMNS[$i]}"
        local dtype="${DATA_TYPES[$i]}"
        
        case "$dtype" in
            INT)
                formats+="COLUMN $col FORMAT 999999999\n"
                ;;
            NUMBER\(10,2\))
                formats+="COLUMN $col FORMAT 999,999.99\n"
                ;;
            NUMBER\(5,2\))
                formats+="COLUMN $col FORMAT 99,999.99\n"
                ;;
            NUMBER\(1\))
                formats+="COLUMN $col FORMAT 9\n"
                ;;
            VARCHAR2*)
                local max_length=${dtype//[!0-9]/}
                # Calculate display width (min of actual width or 30 characters)
                local display_width=$((max_length < 30 ? max_length : 30))
                formats+="COLUMN $col FORMAT A${display_width} TRUNCATED\n"
                ;;
            DATE)
                formats+="COLUMN $col FORMAT A12\n"
                ;;
        esac
    done
    echo -e "$formats"
}

# Input validation function
validate_input() {
    local input=$1
    local data_type=$2
    
    case "$data_type" in
        INT)
            [[ "$input" =~ ^[0-9]+$ ]] || return 1
            ;;
        NUMBER\(10,2\)|NUMBER\(5,2\))
            [[ "$input" =~ ^[0-9]+(\.[0-9]{1,2})?$ ]] || return 1
            ;;
        NUMBER\(1\))
            [[ "$input" =~ ^[01]$ ]] || return 1
            ;;
        VARCHAR2*)
            local max_length=${data_type//[!0-9]/}
            [ ${#input} -le "$max_length" ] || return 1
            ;;
        DATE)
            [[ "$input" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] || return 1
            ;;
        *)
            return 1
            ;;
    esac
    return 0
}

# Function to execute SQL queries with formatting
execute_formatted_sql() {
    local query=$1
    local column_formats=$(generate_column_formats)
    
    sqlplus -s "${ORACLE_USER}/${ORACLE_PASS}@${ORACLE_CONN}" <<EOF
SET LINESIZE 1000
SET PAGESIZE 50000
SET WRAP ON
SET FEEDBACK ON
SET HEADING ON
SET UNDERLINE ON
SET TAB OFF
SET VERIFY OFF
SET TRIMOUT ON
SET TRIMSPOOL ON
SET NULL "<null>"
TTITLE OFF

$column_formats
$query

EXIT;
EOF
}


# Function to get table name from user
get_table() {
    echo "Available tables:"
    for table in "${!SCHEMA[@]}"; do
        echo "- $table"
    done
    
    while true; do
        echo -e "\nEnter table name (or 'exit'): "
        read -r table_name
        
        [[ "$table_name" == "exit" ]] && return 1
        [[ -n "${SCHEMA[$table_name]}" ]] && break
        
        echo "Invalid table name. Please try again."
    done
    
    parse_schema "$table_name"
    return 0
}

# Function to get condition from user
get_condition() {
    while true; do
        echo -e "\nAvailable columns:"
        for i in "${!COLUMNS[@]}"; do
            echo "- ${COLUMNS[$i]} (${DATA_TYPES[$i]}) - ${DESCRIPTIONS[$i]}"
        done
        
        echo -e "\nEnter condition (e.g., user_id=1) or 'exit': "
        read -r condition
        
        [[ "$condition" == "exit" ]] && return 1
        
        local column=${condition%%=*}
        local value=${condition#*=}
        
        # Validate column exists
        local idx=-1
        for i in "${!COLUMNS[@]}"; do
            [[ "${COLUMNS[$i]}" == "$column" ]] && idx=$i && break
        done
        
        [[ $idx -eq -1 ]] && echo "Invalid column." && continue
        
        # Validate value
        validate_input "$value" "${DATA_TYPES[$idx]}" || continue
        
        # Format condition
        if [[ "${DATA_TYPES[$idx]}" =~ VARCHAR2|DATE ]]; then
            condition="${column}='${value}'"
        else
            condition="${column}=${value}"
        fi
        
        break
    done
    return 0
}

# CRUD Operations
read_records() {
    get_table || return
    execute_formatted_sql "
SELECT * FROM $table_name;"
}

update_record() {
    get_table || return
    get_condition || return
    
    # Get column to update
    while true; do
        echo -e "\nEnter column to update or 'exit': "
        read -r column
        
        [[ "$column" == "exit" ]] && return
        
        local idx=-1
        for i in "${!COLUMNS[@]}"; do
            [[ "${COLUMNS[$i]}" == "$column" ]] && idx=$i && break
        done
        
        [[ $idx -eq -1 ]] && echo "Invalid column." && continue
        
        echo "Enter new value: "
        read -r value
        
        validate_input "$value" "${DATA_TYPES[$idx]}" || continue
        
        [[ "${DATA_TYPES[$idx]}" =~ VARCHAR2|DATE ]] && value="'$value'"
        
        execute_formatted_sql "
UPDATE $table_name SET $column = $value WHERE $condition;
COMMIT;"
        echo "Record updated successfully."
        break
    done
}

delete_record() {
    get_table || return 1
    get_condition || return 1

    # Show records that will be deleted
    echo -e "\nThe following records will be deleted:"
    execute_formatted_sql "
SELECT * FROM $table_name WHERE $condition;" || return 1

    echo -e "\nAre you sure you want to delete these records? (y/n): "
    read -r confirm
    [[ "$confirm" != "y" ]] && echo "Delete cancelled." && return 1

    # Execute delete with commit
    execute_formatted_sql "
DELETE FROM $table_name WHERE $condition;
COMMIT;"
    status=$?

    if [ $status -ne 0 ]; then
        echo "Error deleting record(s)."
        return 1
    fi

    # Check if records still exist
    count=$(execute_formatted_sql "
SELECT COUNT(*) FROM $table_name WHERE $condition;" |
        sed -n '/COUNT/,+1p' |   # Get COUNT line and next line
        tail -n1 |               # Take just the number line
        tr -cd '0-9')           # Keep only digits

    if [[ "$count" =~ ^[0-9]+$ ]] && [ "$count" -eq 0 ]; then
        echo "Delete operation successful"
        return 0
    else
        echo "Delete operation failed - records still exist"
        return 1
    fi
}


search_record() {
    get_table || return
    get_condition || return
    
    execute_formatted_sql "
SELECT * FROM $table_name WHERE $condition;"
}

# Main menu
main_menu() {
    while true; do
        echo -e "\n====== CRUD Operations Menu ======"
        echo "1. Read Records"
        echo "2. Update Record"
        echo "3. Delete Record"
        echo "4. Search Record"
        echo "5. Exit"
        echo -n "Select an option (1-5): "
        read -r choice
        
        case $choice in
            1) read_records ;;
            2) update_record ;;
            3) delete_record ;;
            4) search_record ;;
            5) echo "Exiting..." && break ;;
            *) echo "Invalid option. Please enter 1-5." ;;
        esac
    done
}

# Start the application
main_menu