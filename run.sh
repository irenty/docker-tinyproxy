#!/bin/bash

# Global vars
PROG_NAME='TinyProxy'
PROXY_CONF='/etc/tinyproxy/tinyproxy.conf'
PROXY_LOG='/var/log/tinyproxy/tinyproxy.log'
#PROXY_LOG_LEVEL='Info'
PROXY_LOG_LEVEL='Warning'
PROXY_RULES='Allow\tANY'
HOST_PORT=6666

# Usage: screenOut STATUS message
screenOut() {
    timestamp=$(date +"%H:%M:%S")
    
    if [ "$#" -ne 2 ]; then
        status='INFO'
        message="$1"
    else
        status="$1"
        message="$2"
    fi

    echo -e "[$PROG_NAME][$status][$timestamp]: $message"
}

# Usage: checkStatus $? "Error message" "Success message"
checkStatus() {
    case $1 in
        0)
            screenOut "SUCCESS" "$3"
            ;;
        1)
            screenOut "ERROR" "$2 - Exiting..."
            exit 1
            ;;
        *)
            screenOut "ERROR" "Unrecognised return code."
            ;;
    esac
}

setMiscConfig() {
    sed -i -e"s,^MinSpareServers ,MinSpareServers\t1 ," $PROXY_CONF
    checkStatus $? "Set MinSpareServers - Could not edit $PROXY_CONF" \
                   "Set MinSpareServers - Edited $PROXY_CONF successfully."

    sed -i -e"s,^MaxSpareServers ,MaxSpareServers\t1 ," $PROXY_CONF
    checkStatus $? "Set MinSpareServers - Could not edit $PROXY_CONF" \
                   "Set MinSpareServers - Edited $PROXY_CONF successfully."
    
    sed -i -e"s,^StartServers ,StartServers\t1 ," $PROXY_CONF
    checkStatus $? "Set MinSpareServers - Could not edit $PROXY_CONF" \
                   "Set MinSpareServers - Edited $PROXY_CONF successfully."
}

enableLogFile() {
	touch $PROXY_LOG
        chmod 666 $PROXY_LOG
        sed -i -e"s,^#LogFile.*$,LogFile \"$PROXY_LOG\"," $PROXY_CONF
        sed -i -e"s,^LogLevel.*$,LogLevel $PROXY_LOG_LEVEL," $PROXY_CONF
}

setAccess() {
    if [[ "$1" == *ANY* ]]; then
        sed -i -e"s/^Allow /#Allow /" $PROXY_CONF
        checkStatus $? "Allowing ANY - Could not edit $PROXY_CONF" \
                       "Allowed ANY - Edited $PROXY_CONF successfully."
    else
        sed -i "s,^Allow 127.0.0.1,$1," $PROXY_CONF
        checkStatus $? "Allowing IPs - Could not edit $PROXY_CONF" \
                       "Allowed IPs - Edited $PROXY_CONF successfully."
    fi
}

stopProxy() {
    screenOut "Checking for running Tinyproxy service..."
    if [ "$(pidof tinyproxy)" ]; then
        screenOut "Found. Stopping Tinyproxy service for pre-configuration..."
        killall tinyproxy
        checkStatus $? "Could not stop Tinyproxy service." \
                       "Tinyproxy service stopped successfully."
    else
        screenOut "Tinyproxy service not running."
    fi
}

startProxy() {
    screenOut "Starting Tinyproxy service..."
    /usr/sbin/tinyproxy
    checkStatus $? "Could not start Tinyproxy service." \
                   "Tinyproxy service started successfully."
}

tailLog() {
    screenOut "Tailing TinyProxy log..."
    #tail -f /var/log/syslog | grep VPN
    tail -f $PROXY_LOG
    checkStatus $? "Could not tail $PROXY_LOG" \
                   "Stopped tailing $PROXY_LOG"
}

parseAccessRules() {
    list=''
    for ARG in $@; do
        line="Allow\t$ARG\n"
        list+=$line
    done
    echo "$list" | sed 's/.\{2\}$//'
}

echo && screenOut "$PROG_NAME script started..."

stopProxy

echo "**** PROXY_RULES are $PROXY_RULES"

setAccess $PROXY_RULES
enableLogFile

startProxy

tailLog

# End
screenOut "$PROG_NAME script ended." && echo
exit 0
