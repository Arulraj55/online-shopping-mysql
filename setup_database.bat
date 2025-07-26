@echo off
echo Setting up MySQL Database for Online Shopping System...
echo.

echo Step 1: Creating database...
mysql -u root -p -e "CREATE DATABASE IF NOT EXISTS online_shopping;"

echo Step 2: Importing schema...
mysql -u root -p online_shopping < database/schema.sql

echo Step 3: Importing initial data...
mysql -u root -p online_shopping < database/initial_data.sql

echo Step 4: Importing stored procedures...
mysql -u root -p online_shopping < database/stored_procedures.sql

echo Step 5: Importing triggers...
mysql -u root -p online_shopping < database/triggers.sql

echo Step 6: Creating indexes...
mysql -u root -p online_shopping < database/indexes.sql

echo.
echo Database setup complete!
echo You can now start the Node.js backend.
pause
