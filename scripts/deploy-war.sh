#!/usr/bin/env sh
set -eu

WAR_FILE="${1:-dist/IMSFuelMasterPro.war}"
APP_NAME="${IMS_APP_NAME:-IMSFuelMasterPro}"

if [ ! -f "$WAR_FILE" ]; then
  echo "WAR not found: $WAR_FILE" >&2
  echo "Run: ant clean dist" >&2
  exit 1
fi

if [ -z "${CATALINA_BASE:-}" ] && [ -z "${CATALINA_HOME:-}" ]; then
  echo "Set CATALINA_BASE or CATALINA_HOME before deploying." >&2
  exit 1
fi

TOMCAT_BASE="${CATALINA_BASE:-$CATALINA_HOME}"
WEBAPPS_DIR="$TOMCAT_BASE/webapps"

if [ ! -d "$WEBAPPS_DIR" ]; then
  echo "Tomcat webapps directory not found: $WEBAPPS_DIR" >&2
  exit 1
fi

cp "$WAR_FILE" "$WEBAPPS_DIR/$APP_NAME.war"
echo "Deployed $WAR_FILE to $WEBAPPS_DIR/$APP_NAME.war"
echo "Configure IMS_DB_URL, IMS_DB_USER and IMS_DB_PASS in Tomcat's environment before startup."
