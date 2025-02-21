#!/bin/bash
 
# Set Snowflake credentials (Update these variables accordingly)
export SNOWSQL_ACCOUNT="qxqznhd-qz34352"
export SNOWSQL_USER="RUPAMP"
export SNOWSQL_PWD="Rupam@1998"
export SNOWSQL_DATABASE="NATIVE_APP_QUICKSTART_DB"
export SNOWSQL_SCHEMA="NATIVE_APP_QUICKSTART_SCHEMA"
export SNOWSQL_WAREHOUSE="NATIVE_APP_QUICKSTART_WH"
 
# ---------------------------------
# Step 1: Create Warehouse, Database, Schema, and Tables
# ---------------------------------
snow sql -q "
CREATE OR REPLACE WAREHOUSE NATIVE_APP_QUICKSTART_WH WAREHOUSE_SIZE=SMALL INITIALLY_SUSPENDED=TRUE;
 
CREATE OR REPLACE DATABASE NATIVE_APP_QUICKSTART_DB;
USE DATABASE NATIVE_APP_QUICKSTART_DB;
 
CREATE OR REPLACE SCHEMA NATIVE_APP_QUICKSTART_SCHEMA;
USE SCHEMA NATIVE_APP_QUICKSTART_SCHEMA;
 
CREATE OR REPLACE TABLE MFG_SHIPPING (
  order_id NUMBER(38,0),
  ship_order_id NUMBER(38,0),
  status VARCHAR(60),
  lat FLOAT,
  lon FLOAT,
  duration NUMBER(38,0)
);
 
CREATE OR REPLACE TABLE MFG_ORDERS (
  order_id NUMBER(38,0),
  material_name VARCHAR(60),
  supplier_name VARCHAR(60),
  quantity NUMBER(38,0),
  cost FLOAT,
  process_supply_day NUMBER(38,0)
);
 
CREATE OR REPLACE TABLE MFG_SITE_RECOVERY (
  event_id NUMBER(38,0),
  recovery_weeks NUMBER(38,0),
  lat FLOAT,
  lon FLOAT
);
"
 
# ---------------------------------
# Step 2: Create a Named Stage
# ---------------------------------
snow sql -q "
USE DATABASE NATIVE_APP_QUICKSTART_DB;
USE SCHEMA NATIVE_APP_QUICKSTART_SCHEMA;
CREATE OR REPLACE STAGE NATIVE_APP_STAGE FILE_FORMAT = (TYPE = CSV FIELD_OPTIONALLY_ENCLOSED_BY='\"');
"
 
# ---------------------------------
# Step 3: Upload Data to Stage (Ensure Database & Schema are Set)
# ---------------------------------
snow sql -q "
USE DATABASE NATIVE_APP_QUICKSTART_DB;
USE SCHEMA NATIVE_APP_QUICKSTART_SCHEMA;
 
PUT file://app/data/shipping_data.csv @NATIVE_APP_STAGE AUTO_COMPRESS=TRUE;
PUT file://app/data/order_data.csv @NATIVE_APP_STAGE AUTO_COMPRESS=TRUE;
PUT file://app/data/site_recovery_data.csv @NATIVE_APP_STAGE AUTO_COMPRESS=TRUE;
"
 
# ---------------------------------
# Step 4: Load Data from Stage into Tables
# ---------------------------------
snow sql -q "
USE WAREHOUSE NATIVE_APP_QUICKSTART_WH;
USE DATABASE NATIVE_APP_QUICKSTART_DB;
USE SCHEMA NATIVE_APP_QUICKSTART_SCHEMA;
 
COPY INTO MFG_SHIPPING FROM @NATIVE_APP_STAGE/shipping_data.csv.gz FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY='\"');
 
COPY INTO MFG_ORDERS FROM @NATIVE_APP_STAGE/order_data.csv.gz FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY='\"');
 
COPY INTO MFG_SITE_RECOVERY FROM @NATIVE_APP_STAGE/site_recovery_data.csv.gz FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY='\"');
"
 
echo "Data loading complete!"