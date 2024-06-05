#!/usr/local/bin/bash

# Polybar module name
module_name="xfce4-notify"

# Function to update Polybar module with notification count
update_polybar_module() {
    count=$(xfce4-notifyd-client list --limit=5 | grep -c Notification)
    polybar-msg hook $module_name $count
}

# Listen for notifications
dbus-monitor "interface='org.freedesktop.Notifications'" | \
while read -r line; do
    update_polybar_module
done
