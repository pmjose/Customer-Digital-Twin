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
-- EXTERNAL S3 STAGE
-- ============================================================================

-- External stage pointing to public S3 bucket with CSV data
-- Data location: s3://pjose-public/Customer-Digital-Twin/data/
-- Structure:
--   s3://pjose-public/Customer-Digital-Twin/data/internal/customers.csv
--   s3://pjose-public/Customer-Digital-Twin/data/internal/monthly_usage.csv
--   s3://pjose-public/Customer-Digital-Twin/data/internal/support_interactions.csv
--   s3://pjose-public/Customer-Digital-Twin/data/internal/campaign_responses.csv
--   s3://pjose-public/Customer-Digital-Twin/data/external/zip_demographics.csv
--   s3://pjose-public/Customer-Digital-Twin/data/external/economic_indicators.csv
--   s3://pjose-public/Customer-Digital-Twin/data/external/competitive_landscape.csv
--   s3://pjose-public/Customer-Digital-Twin/data/external/lifestyle_segments.csv

CREATE OR REPLACE STAGE RAW.S3_DATA_STAGE
    URL = 's3://pjose-public/Customer-Digital-Twin/data/'
    FILE_FORMAT = RAW.CSV_FORMAT
    DIRECTORY = (ENABLE = TRUE)
    COMMENT = 'External S3 stage for Customer Digital Twin data';

-- Alternative: Internal stage (if you prefer to upload files manually)
CREATE OR REPLACE STAGE RAW.DATA_STAGE
    FILE_FORMAT = RAW.CSV_FORMAT
    DIRECTORY = (ENABLE = TRUE)
    COMMENT = 'Internal stage for manual file uploads';

-- ============================================================================
-- GRANT STAGE ACCESS
-- ============================================================================

-- S3 external stage permissions
GRANT READ ON STAGE RAW.S3_DATA_STAGE TO ROLE CDT_DATA_LOADER;
GRANT READ ON STAGE RAW.S3_DATA_STAGE TO ROLE CDT_DEVELOPER;
GRANT READ ON STAGE RAW.S3_DATA_STAGE TO ROLE CDT_ADMIN;

-- Internal stage permissions (for manual uploads)
GRANT READ, WRITE ON STAGE RAW.DATA_STAGE TO ROLE CDT_DATA_LOADER;
GRANT READ ON STAGE RAW.DATA_STAGE TO ROLE CDT_DEVELOPER;
GRANT READ ON STAGE RAW.DATA_STAGE TO ROLE CDT_ADMIN;

-- ============================================================================
-- DATA LOCATION INFORMATION
-- ============================================================================

/*
================================================================================
DATA IS ALREADY AVAILABLE IN S3
================================================================================

The CSV data files are hosted in a public S3 bucket:
  s3://pjose-public/Customer-Digital-Twin/data/

Files available:
  - internal/customers.csv          (1M records, ~256 MB)
  - internal/monthly_usage.csv      (9.3M records, ~1.4 GB)
  - internal/support_interactions.csv (2.1M records, ~613 MB)
  - internal/campaign_responses.csv (5.3M records, ~1.1 GB)
  - external/zip_demographics.csv   (42K records, ~11 MB)
  - external/economic_indicators.csv (42K records, ~5 MB)
  - external/competitive_landscape.csv (210 records, ~37 KB)
  - external/lifestyle_segments.csv (42K records, ~8 MB)

Total: ~17.8M records, ~3.4 GB

To load data, run 05_load_data.sql which uses the S3_DATA_STAGE.

================================================================================
ALTERNATIVE: Manual Upload to Internal Stage
================================================================================

If you prefer to upload files manually instead of using S3:

Option 1: Using SnowSQL CLI
--------------------------
PUT file://./data/internal/customers.csv @RAW.DATA_STAGE/internal/ AUTO_COMPRESS=TRUE OVERWRITE=TRUE;
PUT file://./data/internal/monthly_usage.csv @RAW.DATA_STAGE/internal/ AUTO_COMPRESS=TRUE OVERWRITE=TRUE;
PUT file://./data/internal/support_interactions.csv @RAW.DATA_STAGE/internal/ AUTO_COMPRESS=TRUE OVERWRITE=TRUE;
PUT file://./data/internal/campaign_responses.csv @RAW.DATA_STAGE/internal/ AUTO_COMPRESS=TRUE OVERWRITE=TRUE;
PUT file://./data/external/zip_demographics.csv @RAW.DATA_STAGE/external/ AUTO_COMPRESS=TRUE OVERWRITE=TRUE;
PUT file://./data/external/economic_indicators.csv @RAW.DATA_STAGE/external/ AUTO_COMPRESS=TRUE OVERWRITE=TRUE;
PUT file://./data/external/competitive_landscape.csv @RAW.DATA_STAGE/external/ AUTO_COMPRESS=TRUE OVERWRITE=TRUE;
PUT file://./data/external/lifestyle_segments.csv @RAW.DATA_STAGE/external/ AUTO_COMPRESS=TRUE OVERWRITE=TRUE;

Option 2: Using Snowsight UI
---------------------------
1. Navigate to Data > Databases > SNOWMOBILE_DIGITAL_TWIN > RAW > Stages
2. Click on DATA_STAGE
3. Click "+ Files" button
4. Browse and select CSV files

================================================================================
*/

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

-- Check file format
SHOW FILE FORMATS IN SCHEMA RAW;

-- Check stages
SHOW STAGES IN SCHEMA RAW;

-- List files in S3 stage
LIST @RAW.S3_DATA_STAGE/internal/;
LIST @RAW.S3_DATA_STAGE/external/;

SELECT 'Stages and file formats created successfully!' AS status;

-- ============================================================================
-- SAMPLE DATA VALIDATION QUERIES
-- ============================================================================

-- Preview customers data from S3 (first 5 rows)
SELECT $1 AS customer_id, $2 AS account_id, $3 AS zip_code, $4 AS state_code, $5 AS dma_code
FROM @RAW.S3_DATA_STAGE/internal/customers.csv
(FILE_FORMAT => RAW.CSV_FORMAT)
LIMIT 5;

-- Preview external data
SELECT $1 AS zip_code, $2 AS zip_name, $3 AS state_code
FROM @RAW.S3_DATA_STAGE/external/zip_demographics.csv
(FILE_FORMAT => RAW.CSV_FORMAT)
LIMIT 5;


