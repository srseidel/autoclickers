#!/bin/bash
# ============================================================
# list_privileges.sh — READ-ONLY audit of powerful macOS
# privacy permissions (TCC). Shows every app granted:
#   Accessibility, Input Monitoring, Screen Recording, Full Disk Access
#
# This ONLY reads Apple's TCC database. It changes nothing.
# The system database needs sudo (you'll be prompted).
# ============================================================
# To REMOVE a permission (Apple's built-in tool, no SIP disable):
#   tccutil reset Accessibility <bundle-id>
#   tccutil reset ListenEvent   <bundle-id>   # Input Monitoring
# To GRANT one: not possible from the CLI — Apple requires the
# GUI toggle in System Settings > Privacy & Security (by design).
# ============================================================

SYS_DB="/Library/Application Support/com.apple.TCC/TCC.db"
USER_DB="$HOME/Library/Application Support/com.apple.TCC/TCC.db"

QUERY="SELECT service, client,
  CASE auth_value WHEN 2 THEN 'ALLOWED' WHEN 3 THEN 'ALLOWED' WHEN 0 THEN 'denied' ELSE auth_value END
 FROM access
 WHERE service IN (
   'kTCCServiceAccessibility',
   'kTCCServiceListenEvent',
   'kTCCServiceScreenCapture',
   'kTCCServiceSystemPolicyAllFiles'
 )
 ORDER BY service, client;"

# Friendlier names for the raw service keys
pretty() {
    sed -e 's/kTCCServiceAccessibility/Accessibility        /' \
        -e 's/kTCCServiceListenEvent/Input Monitoring     /' \
        -e 's/kTCCServiceScreenCapture/Screen Recording     /' \
        -e 's/kTCCServiceSystemPolicyAllFiles/Full Disk Access     /' \
        -e 's/|/  |  /g'
}

echo "=================================================================="
echo " SYSTEM TCC database  (needs sudo)"
echo "=================================================================="
sudo sqlite3 "$SYS_DB" "$QUERY" 2>/dev/null | pretty \
    || echo "  (could not read — sudo declined or SIP-protected)"

echo
echo "=================================================================="
echo " PER-USER TCC database  ($USER)"
echo "=================================================================="
sqlite3 "$USER_DB" "$QUERY" 2>/dev/null | pretty \
    || echo "  (none, or not readable)"

echo
echo "Legend: ALLOWED = granted, denied = explicitly blocked."
echo "Remove with:  tccutil reset <Service> <bundle-id>"
