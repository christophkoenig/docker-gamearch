#!/bin/bash

DB=/data/db/db.sqlite

echo -e "Checking if database schema is up-to-date..."

if [ -f $DB ]; then
    # Migrate Games table
    GAMES_COL_EXISTS=$(sqlite3 $DB \
        "SELECT COUNT(*) FROM pragma_table_info('Games') WHERE name = 'saleprice';")

    if [ "0" == $GAMES_COL_EXISTS ]; then
        sqlite3 $DB "ALTER TABLE Games ADD COLUMN saleprice text;"
        echo -e "Updated table Games"
    else
        echo -e "Nothing to do for table Games"
    fi

    # Migrate Settings table
    SETTINGS_COL_EXISTS=$(sqlite3 $DB \
        "SELECT COUNT(*) FROM pragma_table_info('Settings') WHERE name = 'resolution'")

    if [ "0" == $SETTINGS_COL_EXISTS ]; then
        sqlite3 $DB "ALTER TABLE Settings ADD COLUMN resolution text;"
        echo -e "Updated table Settings"
    else
        echo -e "Nothing to do for table Settings"
    fi
else
    echo -e "Unable to find database"
fi
