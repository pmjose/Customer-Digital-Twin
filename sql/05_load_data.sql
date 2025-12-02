-- ============================================================================
-- Snowmobile Wireless - Customer Digital Twin
-- 05_load_data.sql
-- 
-- Purpose: Load data from staged CSV files into tables
-- ============================================================================

USE DATABASE SNOWMOBILE_DIGITAL_TWIN;
USE WAREHOUSE CDT_LOAD_WH;

-- ============================================================================
-- PRE-LOAD CHECKS
-- ============================================================================

-- Verify files are staged
-- LIST @RAW.DATA_STAGE/internal/;
-- LIST @RAW.DATA_STAGE/external/;

-- ============================================================================
-- LOAD INTERNAL DATA
-- ============================================================================

-- -----------------------------------------------------------------------------
-- Load Customers (1M records)
-- -----------------------------------------------------------------------------

COPY INTO RAW.CUSTOMERS (
    customer_id, account_id, zip_code, state_code, dma_code,
    age, gender, customer_since, tenure_months, acquisition_channel,
    plan_name, plan_category, plan_price, lines_on_account, contract_type, contract_end_date,
    device_brand, device_model, device_tier, device_os, device_age_months, is_5g_capable,
    monthly_arpu, lifetime_value, total_revenue_12m, payment_method, autopay_enrolled, paperless_billing, credit_class,
    has_device_protection, has_intl_roaming, has_streaming_bundle,
    rewards_member, rewards_tier, rewards_points_balance,
    app_user, app_engagement_score, last_app_login, nps_score, nps_survey_date,
    churn_risk_score, predicted_churn_reason, complaint_count_12m
)
FROM @RAW.DATA_STAGE/internal/customers/
FILE_FORMAT = (FORMAT_NAME = 'RAW.CSV_FORMAT')
ON_ERROR = 'CONTINUE'
PURGE = FALSE;

-- Log results
SELECT 'CUSTOMERS' AS table_name, COUNT(*) AS records_loaded FROM RAW.CUSTOMERS;

-- -----------------------------------------------------------------------------
-- Load Monthly Usage (12M records)
-- -----------------------------------------------------------------------------

COPY INTO RAW.MONTHLY_USAGE (
    usage_id, customer_id, billing_month,
    voice_minutes_onnet, voice_minutes_offnet, voice_minutes_intl, voice_calls_count,
    data_usage_gb, data_usage_4g_pct, data_usage_5g_pct, data_throttled_days,
    sms_sent, mms_sent,
    roaming_days, roaming_data_gb, roaming_voice_min,
    base_charge, overage_charges, roaming_charges, add_on_charges, discounts_applied, total_bill,
    payment_status, days_to_payment
)
FROM @RAW.DATA_STAGE/internal/monthly_usage/
FILE_FORMAT = (FORMAT_NAME = 'RAW.CSV_FORMAT')
ON_ERROR = 'CONTINUE'
PURGE = FALSE;

SELECT 'MONTHLY_USAGE' AS table_name, COUNT(*) AS records_loaded FROM RAW.MONTHLY_USAGE;

-- -----------------------------------------------------------------------------
-- Load Support Interactions (2M records)
-- -----------------------------------------------------------------------------

COPY INTO RAW.SUPPORT_INTERACTIONS (
    interaction_id, customer_id, interaction_date,
    channel, category, subcategory, intent,
    resolution_status, resolution_time_hours, first_contact_resolution,
    sentiment_score, csat_score,
    interaction_summary, customer_verbatim
)
FROM @RAW.DATA_STAGE/internal/support_interactions/
FILE_FORMAT = (FORMAT_NAME = 'RAW.CSV_FORMAT')
ON_ERROR = 'CONTINUE'
PURGE = FALSE;

SELECT 'SUPPORT_INTERACTIONS' AS table_name, COUNT(*) AS records_loaded FROM RAW.SUPPORT_INTERACTIONS;

-- -----------------------------------------------------------------------------
-- Load Campaign Responses (5M records)
-- -----------------------------------------------------------------------------

COPY INTO RAW.CAMPAIGN_RESPONSES (
    response_id, customer_id, campaign_id,
    campaign_name, campaign_type, campaign_category, offer_type, offer_value,
    channel, sent_at, delivered,
    opened, clicked, responded, response_type, response_at,
    converted, conversion_value
)
FROM @RAW.DATA_STAGE/internal/campaign_responses/
FILE_FORMAT = (FORMAT_NAME = 'RAW.CSV_FORMAT')
ON_ERROR = 'CONTINUE'
PURGE = FALSE;

SELECT 'CAMPAIGN_RESPONSES' AS table_name, COUNT(*) AS records_loaded FROM RAW.CAMPAIGN_RESPONSES;

-- ============================================================================
-- LOAD EXTERNAL DATA
-- ============================================================================

-- -----------------------------------------------------------------------------
-- Load ZIP Demographics (42K records)
-- -----------------------------------------------------------------------------

COPY INTO EXTERNAL.ZIP_DEMOGRAPHICS (
    zip_code, zip_name, state_code, state_name, region, dma_code, dma_name,
    total_population, population_density, land_area_sq_miles, urban_rural_class,
    pct_age_18_24, pct_age_25_34, pct_age_35_44, pct_age_45_54, pct_age_55_64, pct_age_65_plus, median_age,
    median_household_income, mean_household_income, per_capita_income,
    pct_income_under_25k, pct_income_25k_50k, pct_income_50k_75k, pct_income_75k_100k, pct_income_100k_150k, pct_income_150k_plus,
    pct_high_school, pct_some_college, pct_bachelors, pct_graduate_degree,
    pct_owner_occupied, pct_renter_occupied, median_home_value, median_rent,
    avg_household_size, pct_family_households, pct_married_couples, pct_single_parent, pct_living_alone,
    labor_force_participation, pct_white_collar, pct_blue_collar, pct_service_industry,
    pct_white, pct_black, pct_hispanic, pct_asian, pct_other_race
)
FROM @RAW.DATA_STAGE/external/zip_demographics/
FILE_FORMAT = (FORMAT_NAME = 'RAW.CSV_FORMAT')
ON_ERROR = 'CONTINUE'
PURGE = FALSE;

SELECT 'ZIP_DEMOGRAPHICS' AS table_name, COUNT(*) AS records_loaded FROM EXTERNAL.ZIP_DEMOGRAPHICS;

-- -----------------------------------------------------------------------------
-- Load Economic Indicators (42K records)
-- -----------------------------------------------------------------------------

COPY INTO EXTERNAL.ECONOMIC_INDICATORS (
    zip_code,
    cost_of_living_index, housing_cost_index, utilities_cost_index, transportation_index, groceries_index, healthcare_index,
    unemployment_rate, job_growth_rate_yoy,
    poverty_rate, food_insecurity_rate, uninsured_rate,
    home_price_growth_yoy, rent_growth_yoy, vacancy_rate,
    avg_credit_score, pct_prime_credit, pct_subprime_credit, avg_debt_to_income,
    retail_sales_per_capita, ecommerce_penetration,
    data_as_of_date
)
FROM @RAW.DATA_STAGE/external/economic_indicators/
FILE_FORMAT = (FORMAT_NAME = 'RAW.CSV_FORMAT')
ON_ERROR = 'CONTINUE'
PURGE = FALSE;

SELECT 'ECONOMIC_INDICATORS' AS table_name, COUNT(*) AS records_loaded FROM EXTERNAL.ECONOMIC_INDICATORS;

-- -----------------------------------------------------------------------------
-- Load Competitive Landscape (210 records)
-- -----------------------------------------------------------------------------

COPY INTO EXTERNAL.COMPETITIVE_LANDSCAPE (
    dma_code, dma_name,
    total_wireless_subs, market_size_revenue, yoy_market_growth,
    snowmobile_subs, snowmobile_market_share, snowmobile_nps, snowmobile_coverage_pct, snowmobile_5g_pct,
    vz_market_share, vz_avg_price, vz_nps, vz_coverage_pct,
    att_market_share, att_avg_price, att_nps, att_coverage_pct,
    tmo_market_share, tmo_avg_price, tmo_nps, tmo_coverage_pct,
    regional_market_share, regional_avg_price,
    market_concentration, price_war_intensity, recent_competitor_promo, promo_end_date
)
FROM @RAW.DATA_STAGE/external/competitive_landscape/
FILE_FORMAT = (FORMAT_NAME = 'RAW.CSV_FORMAT')
ON_ERROR = 'CONTINUE'
PURGE = FALSE;

SELECT 'COMPETITIVE_LANDSCAPE' AS table_name, COUNT(*) AS records_loaded FROM EXTERNAL.COMPETITIVE_LANDSCAPE;

-- -----------------------------------------------------------------------------
-- Load Lifestyle Segments (42K records)
-- -----------------------------------------------------------------------------

COPY INTO EXTERNAL.LIFESTYLE_SEGMENTS (
    zip_code,
    primary_lifestyle, secondary_lifestyle, lifestyle_diversity,
    tech_adoption_score, smartphone_penetration, pct_iphone, pct_android, smart_home_adoption, streaming_penetration, cord_cutter_rate,
    avg_daily_screen_time, social_media_heavy_pct, online_shopping_pct, mobile_banking_pct,
    streaming_hours_week, gaming_hours_week, news_consumption, primary_news_source,
    price_sensitivity_index, brand_loyalty_index, eco_consciousness, early_adopter_index,
    pref_channel_digital, pref_channel_phone, pref_channel_store, pref_channel_chat,
    avg_data_usage_gb, avg_lines_per_account, family_plan_propensity, premium_plan_propensity, prepaid_propensity,
    deal_seeker_index, switching_propensity, competitor_awareness
)
FROM @RAW.DATA_STAGE/external/lifestyle_segments/
FILE_FORMAT = (FORMAT_NAME = 'RAW.CSV_FORMAT')
ON_ERROR = 'CONTINUE'
PURGE = FALSE;

SELECT 'LIFESTYLE_SEGMENTS' AS table_name, COUNT(*) AS records_loaded FROM EXTERNAL.LIFESTYLE_SEGMENTS;

-- ============================================================================
-- POST-LOAD VALIDATION
-- ============================================================================

-- Summary of all loaded data
SELECT 'DATA LOAD SUMMARY' AS report;

SELECT 
    'Internal Data' AS category,
    'RAW.CUSTOMERS' AS table_name,
    COUNT(*) AS record_count,
    '1,000,000' AS expected_count
FROM RAW.CUSTOMERS
UNION ALL
SELECT 
    'Internal Data',
    'RAW.MONTHLY_USAGE',
    COUNT(*),
    '12,000,000'
FROM RAW.MONTHLY_USAGE
UNION ALL
SELECT 
    'Internal Data',
    'RAW.SUPPORT_INTERACTIONS',
    COUNT(*),
    '2,000,000'
FROM RAW.SUPPORT_INTERACTIONS
UNION ALL
SELECT 
    'Internal Data',
    'RAW.CAMPAIGN_RESPONSES',
    COUNT(*),
    '5,000,000'
FROM RAW.CAMPAIGN_RESPONSES
UNION ALL
SELECT 
    'External Data',
    'EXTERNAL.ZIP_DEMOGRAPHICS',
    COUNT(*),
    '42,000'
FROM EXTERNAL.ZIP_DEMOGRAPHICS
UNION ALL
SELECT 
    'External Data',
    'EXTERNAL.ECONOMIC_INDICATORS',
    COUNT(*),
    '42,000'
FROM EXTERNAL.ECONOMIC_INDICATORS
UNION ALL
SELECT 
    'External Data',
    'EXTERNAL.COMPETITIVE_LANDSCAPE',
    COUNT(*),
    '210'
FROM EXTERNAL.COMPETITIVE_LANDSCAPE
UNION ALL
SELECT 
    'External Data',
    'EXTERNAL.LIFESTYLE_SEGMENTS',
    COUNT(*),
    '42,000'
FROM EXTERNAL.LIFESTYLE_SEGMENTS
ORDER BY category, table_name;

-- ============================================================================
-- DATA QUALITY CHECKS
-- ============================================================================

-- Check for orphan records (customers not matching external data)
SELECT 
    'Customers without ZIP demographics' AS check_name,
    COUNT(*) AS count
FROM RAW.CUSTOMERS c
LEFT JOIN EXTERNAL.ZIP_DEMOGRAPHICS z ON c.zip_code = z.zip_code
WHERE z.zip_code IS NULL;

-- Check plan distribution
SELECT 
    plan_name,
    COUNT(*) AS customer_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS pct
FROM RAW.CUSTOMERS
GROUP BY plan_name
ORDER BY customer_count DESC;

-- Check geographic distribution
SELECT 
    state_code,
    COUNT(*) AS customer_count
FROM RAW.CUSTOMERS
GROUP BY state_code
ORDER BY customer_count DESC
LIMIT 10;

SELECT 'Data loading complete!' AS status;


