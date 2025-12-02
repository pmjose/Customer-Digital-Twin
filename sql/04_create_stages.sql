-- ============================================================================
-- Snowmobile Wireless - Customer Digital Twin
-- 04_create_stages.sql
-- 
-- Purpose: Create stages for loading CSV data
-- ============================================================================

USE DATABASE SNOWMOBILE_DIGITAL_TWIN;
USE SCHEMA RAW;
USE WAREHOUSE CDT_LOAD_WH;

-- ============================================================================
-- FILE FORMATS
-- ============================================================================

-- Standard CSV format for most files
CREATE OR REPLACE FILE FORMAT RAW.CSV_FORMAT
    TYPE = 'CSV'
    FIELD_DELIMITER = ','
    RECORD_DELIMITER = '\n'
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    NULL_IF = ('', 'NULL', 'null', 'None', 'NA', 'N/A')
    TRIM_SPACE = TRUE
    ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE
    DATE_FORMAT = 'YYYY-MM-DD'
    TIMESTAMP_FORMAT = 'YYYY-MM-DD HH24:MI:SS'
    COMMENT = 'Standard CSV format for data loading';

-- CSV format with pipe delimiter (alternative)
CREATE OR REPLACE FILE FORMAT RAW.CSV_PIPE_FORMAT
    TYPE = 'CSV'
    FIELD_DELIMITER = '|'
    RECORD_DELIMITER = '\n'
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    NULL_IF = ('', 'NULL', 'null')
    TRIM_SPACE = TRUE
    COMMENT = 'Pipe-delimited CSV format';

-- ============================================================================
-- INTERNAL STAGES
-- ============================================================================

-- Main data stage for all CSV files
CREATE OR REPLACE STAGE RAW.DATA_STAGE
    FILE_FORMAT = RAW.CSV_FORMAT
    DIRECTORY = (ENABLE = TRUE)
    COMMENT = 'Stage for loading CSV data files';

-- Create subdirectories within stage (conceptual - actual paths created on upload)
-- Structure:
--   @RAW.DATA_STAGE/internal/customers/
--   @RAW.DATA_STAGE/internal/monthly_usage/
--   @RAW.DATA_STAGE/internal/support_interactions/
--   @RAW.DATA_STAGE/internal/campaign_responses/
--   @RAW.DATA_STAGE/external/zip_demographics/
--   @RAW.DATA_STAGE/external/economic_indicators/
--   @RAW.DATA_STAGE/external/competitive_landscape/
--   @RAW.DATA_STAGE/external/lifestyle_segments/

-- ============================================================================
-- GRANT STAGE ACCESS
-- ============================================================================

GRANT READ, WRITE ON STAGE RAW.DATA_STAGE TO ROLE CDT_DATA_LOADER;
GRANT READ ON STAGE RAW.DATA_STAGE TO ROLE CDT_DEVELOPER;
GRANT READ ON STAGE RAW.DATA_STAGE TO ROLE CDT_ADMIN;

-- ============================================================================
-- HELPER COMMANDS FOR UPLOADING FILES
-- ============================================================================

/*
================================================================================
UPLOADING DATA FILES TO STAGE
================================================================================

Option 1: Using SnowSQL CLI
--------------------------
-- Internal data files
PUT file://./data/internal/customers.csv @RAW.DATA_STAGE/internal/customers/ AUTO_COMPRESS=TRUE OVERWRITE=TRUE;
PUT file://./data/internal/monthly_usage.csv @RAW.DATA_STAGE/internal/monthly_usage/ AUTO_COMPRESS=TRUE OVERWRITE=TRUE;
PUT file://./data/internal/support_interactions.csv @RAW.DATA_STAGE/internal/support_interactions/ AUTO_COMPRESS=TRUE OVERWRITE=TRUE;
PUT file://./data/internal/campaign_responses.csv @RAW.DATA_STAGE/internal/campaign_responses/ AUTO_COMPRESS=TRUE OVERWRITE=TRUE;

-- External data files
PUT file://./data/external/zip_demographics.csv @RAW.DATA_STAGE/external/zip_demographics/ AUTO_COMPRESS=TRUE OVERWRITE=TRUE;
PUT file://./data/external/economic_indicators.csv @RAW.DATA_STAGE/external/economic_indicators/ AUTO_COMPRESS=TRUE OVERWRITE=TRUE;
PUT file://./data/external/competitive_landscape.csv @RAW.DATA_STAGE/external/competitive_landscape/ AUTO_COMPRESS=TRUE OVERWRITE=TRUE;
PUT file://./data/external/lifestyle_segments.csv @RAW.DATA_STAGE/external/lifestyle_segments/ AUTO_COMPRESS=TRUE OVERWRITE=TRUE;


Option 2: Using Snowsight UI
---------------------------
1. Navigate to Data > Databases > SNOWMOBILE_DIGITAL_TWIN > RAW > Stages
2. Click on DATA_STAGE
3. Click "+ Files" button
4. Browse and select CSV files
5. Optionally specify path prefix (e.g., internal/customers/)


Option 3: Using Python Snowpark
-------------------------------
from snowflake.snowpark import Session
session = Session.builder.configs(connection_params).create()
session.file.put('file://./data/internal/customers.csv', '@RAW.DATA_STAGE/internal/customers/', auto_compress=True, overwrite=True)

================================================================================
*/

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

-- List files in stage (run after uploading)
-- LIST @RAW.DATA_STAGE;

-- List files in specific path
-- LIST @RAW.DATA_STAGE/internal/customers/;

-- Check file format
SHOW FILE FORMATS IN SCHEMA RAW;

-- Check stages
SHOW STAGES IN SCHEMA RAW;

SELECT 'Stages and file formats created successfully!' AS status;

-- ============================================================================
-- SAMPLE DATA VALIDATION QUERIES
-- ============================================================================

/*
-- Preview data before loading (first 10 rows)
SELECT $1, $2, $3, $4, $5
FROM @RAW.DATA_STAGE/internal/customers/customers.csv.gz
(FILE_FORMAT => RAW.CSV_FORMAT)
LIMIT 10;

-- Check row counts
SELECT 
    METADATA$FILENAME as filename,
    COUNT(*) as row_count
FROM @RAW.DATA_STAGE/internal/customers/
(FILE_FORMAT => RAW.CSV_FORMAT)
GROUP BY filename;
*/


