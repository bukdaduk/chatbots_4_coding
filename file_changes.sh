#!/bin/bash

# Email Configuration
RECIPIENT="your-email@example.com"
SENDER="alerts@your-server.com"

# Function to send email alert
send_alert() {
    SUBJECT=$1
    MESSAGE=$2
    echo -e "Subject: $SUBJECT\n$MESSAGE" | sendmail -f "$SENDER" "$RECIPIENT"
}

# Monitor file system events
inotifywait -m -r -e create,delete,modify,attrib --format "%w%f %e" /path/to/monitor 2>/dev/null |
while read -r FILE EVENT; do
    # Check if it's a file permission change event
    if [[ "$EVENT" == "attrib" ]]; then
        send_alert "File Permission Change" "File: $FILE\nEvent: $EVENT"
    else
        send_alert "File Event" "File: $FILE\nEvent: $EVENT"
    fi
done &

# Monitor user logins and logoffs
last | awk '!/wtmp/{print $1, $3, $4}' |
while read -r USER DATE TIME; do
    if [[ "$TIME" == "still" ]]; then
        send_alert "User Logoff" "User: $USER\nDate: $DATE"
    else
        send_alert "User Login" "User: $USER\nDate: $DATE\nTime: $TIME"
    fi
done &

# Keep the script running
while true; do
    sleep 60
done
