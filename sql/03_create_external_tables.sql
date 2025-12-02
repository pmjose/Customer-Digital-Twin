-- ============================================================================
-- Snowmobile Wireless - Customer Digital Twin
-- 03_create_external_tables.sql
-- 
-- Purpose: Create external (3rd party) data tables in EXTERNAL schema
-- ============================================================================

USE DATABASE SNOWMOBILE_DIGITAL_TWIN;
USE SCHEMA EXTERNAL;
USE WAREHOUSE CDT_LOAD_WH;

-- ============================================================================
-- ZIP_DEMOGRAPHICS TABLE
-- Census-based demographic data by ZIP code
-- ============================================================================

CREATE OR REPLACE TABLE EXTERNAL.ZIP_DEMOGRAPHICS (
    -- Identity
    zip_code                VARCHAR(5) NOT NULL PRIMARY KEY
                            COMMENT 'US ZIP code (5-digit)',
    zip_name                VARCHAR(100)
                            COMMENT 'City, State name for ZIP',
    state_code              VARCHAR(2)
                            COMMENT 'Two-letter state code',
    state_name              VARCHAR(50)
                            COMMENT 'Full state name',
    region                  VARCHAR(20)
                            COMMENT 'US region (Northeast/Southeast/Midwest/Southwest/West)',
    dma_code                VARCHAR(3)
                            COMMENT 'Designated Market Area code',
    dma_name                VARCHAR(100)
                            COMMENT 'DMA name',
    
    -- Population
    total_population        INT
                            COMMENT 'Total population in ZIP',
    population_density      DECIMAL(10,2)
                            COMMENT 'Population per square mile',
    land_area_sq_miles      DECIMAL(10,2)
                            COMMENT 'Land area in square miles',
    urban_rural_class       VARCHAR(20)
                            COMMENT 'Classification (Urban/Suburban/Rural/Remote)',
    
    -- Age Distribution (percentages)
    pct_age_18_24           DECIMAL(5,2)
                            COMMENT 'Percent age 18-24',
    pct_age_25_34           DECIMAL(5,2)
                            COMMENT 'Percent age 25-34',
    pct_age_35_44           DECIMAL(5,2)
                            COMMENT 'Percent age 35-44',
    pct_age_45_54           DECIMAL(5,2)
                            COMMENT 'Percent age 45-54',
    pct_age_55_64           DECIMAL(5,2)
                            COMMENT 'Percent age 55-64',
    pct_age_65_plus         DECIMAL(5,2)
                            COMMENT 'Percent age 65+',
    median_age              DECIMAL(4,1)
                            COMMENT 'Median age',
    
    -- Income
    median_household_income INT
                            COMMENT 'Median household income ($)',
    mean_household_income   INT
                            COMMENT 'Mean household income ($)',
    per_capita_income       INT
                            COMMENT 'Per capita income ($)',
    pct_income_under_25k    DECIMAL(5,2)
                            COMMENT 'Percent HH income under $25K',
    pct_income_25k_50k      DECIMAL(5,2)
                            COMMENT 'Percent HH income $25K-$50K',
    pct_income_50k_75k      DECIMAL(5,2)
                            COMMENT 'Percent HH income $50K-$75K',
    pct_income_75k_100k     DECIMAL(5,2)
                            COMMENT 'Percent HH income $75K-$100K',
    pct_income_100k_150k    DECIMAL(5,2)
                            COMMENT 'Percent HH income $100K-$150K',
    pct_income_150k_plus    DECIMAL(5,2)
                            COMMENT 'Percent HH income $150K+',
    
    -- Education
    pct_high_school         DECIMAL(5,2)
                            COMMENT 'Percent with high school diploma',
    pct_some_college        DECIMAL(5,2)
                            COMMENT 'Percent with some college',
    pct_bachelors           DECIMAL(5,2)
                            COMMENT 'Percent with bachelors degree',
    pct_graduate_degree     DECIMAL(5,2)
                            COMMENT 'Percent with graduate degree',
    
    -- Housing
    pct_owner_occupied      DECIMAL(5,2)
                            COMMENT 'Percent owner-occupied housing',
    pct_renter_occupied     DECIMAL(5,2)
                            COMMENT 'Percent renter-occupied housing',
    median_home_value       INT
                            COMMENT 'Median home value ($)',
    median_rent             INT
                            COMMENT 'Median monthly rent ($)',
    
    -- Household Composition
    avg_household_size      DECIMAL(3,1)
                            COMMENT 'Average household size',
    pct_family_households   DECIMAL(5,2)
                            COMMENT 'Percent family households',
    pct_married_couples     DECIMAL(5,2)
                            COMMENT 'Percent married couple households',
    pct_single_parent       DECIMAL(5,2)
                            COMMENT 'Percent single parent households',
    pct_living_alone        DECIMAL(5,2)
                            COMMENT 'Percent living alone',
    
    -- Employment
    labor_force_participation DECIMAL(5,2)
                            COMMENT 'Labor force participation rate',
    pct_white_collar        DECIMAL(5,2)
                            COMMENT 'Percent white collar workers',
    pct_blue_collar         DECIMAL(5,2)
                            COMMENT 'Percent blue collar workers',
    pct_service_industry    DECIMAL(5,2)
                            COMMENT 'Percent service industry workers',
    
    -- Diversity
    pct_white               DECIMAL(5,2)
                            COMMENT 'Percent White population',
    pct_black               DECIMAL(5,2)
                            COMMENT 'Percent Black population',
    pct_hispanic            DECIMAL(5,2)
                            COMMENT 'Percent Hispanic population',
    pct_asian               DECIMAL(5,2)
                            COMMENT 'Percent Asian population',
    pct_other_race          DECIMAL(5,2)
                            COMMENT 'Percent other race'
)
COMMENT = 'ZIP code demographics from Census data - 42K records';

-- ============================================================================
-- ECONOMIC_INDICATORS TABLE
-- Economic metrics by ZIP code
-- ============================================================================

CREATE OR REPLACE TABLE EXTERNAL.ECONOMIC_INDICATORS (
    -- Identity
    zip_code                VARCHAR(5) NOT NULL PRIMARY KEY
                            COMMENT 'US ZIP code (5-digit)',
    
    -- Cost of Living (100 = national average)
    cost_of_living_index    DECIMAL(5,1)
                            COMMENT 'Overall cost of living index (100=avg)',
    housing_cost_index      DECIMAL(5,1)
                            COMMENT 'Housing cost index',
    utilities_cost_index    DECIMAL(5,1)
                            COMMENT 'Utilities cost index',
    transportation_index    DECIMAL(5,1)
                            COMMENT 'Transportation cost index',
    groceries_index         DECIMAL(5,1)
                            COMMENT 'Groceries cost index',
    healthcare_index        DECIMAL(5,1)
                            COMMENT 'Healthcare cost index',
    
    -- Employment
    unemployment_rate       DECIMAL(4,2)
                            COMMENT 'Unemployment rate (%)',
    job_growth_rate_yoy     DECIMAL(5,2)
                            COMMENT 'Year-over-year job growth rate (%)',
    
    -- Economic Health
    poverty_rate            DECIMAL(5,2)
                            COMMENT 'Poverty rate (%)',
    food_insecurity_rate    DECIMAL(5,2)
                            COMMENT 'Food insecurity rate (%)',
    uninsured_rate          DECIMAL(5,2)
                            COMMENT 'Uninsured rate (%)',
    
    -- Housing Market
    home_price_growth_yoy   DECIMAL(5,2)
                            COMMENT 'YoY home price growth (%)',
    rent_growth_yoy         DECIMAL(5,2)
                            COMMENT 'YoY rent growth (%)',
    vacancy_rate            DECIMAL(5,2)
                            COMMENT 'Housing vacancy rate (%)',
    
    -- Consumer Behavior
    avg_credit_score        INT
                            COMMENT 'Average credit score (300-850)',
    pct_prime_credit        DECIMAL(5,2)
                            COMMENT 'Percent with prime credit (720+)',
    pct_subprime_credit     DECIMAL(5,2)
                            COMMENT 'Percent with subprime credit (<620)',
    avg_debt_to_income      DECIMAL(5,2)
                            COMMENT 'Average debt-to-income ratio',
    
    -- Retail/Spending
    retail_sales_per_capita INT
                            COMMENT 'Annual retail sales per capita ($)',
    ecommerce_penetration   DECIMAL(5,2)
                            COMMENT 'E-commerce as % of retail',
    
    -- Metadata
    data_as_of_date         DATE
                            COMMENT 'Date of data snapshot'
)
COMMENT = 'Economic indicators by ZIP code - 42K records';

-- ============================================================================
-- COMPETITIVE_LANDSCAPE TABLE
-- Competitive intelligence by DMA
-- ============================================================================

CREATE OR REPLACE TABLE EXTERNAL.COMPETITIVE_LANDSCAPE (
    -- Identity
    dma_code                VARCHAR(3) NOT NULL PRIMARY KEY
                            COMMENT 'Designated Market Area code',
    dma_name                VARCHAR(100)
                            COMMENT 'DMA name',
    
    -- Market Size
    total_wireless_subs     INT
                            COMMENT 'Total wireless subscribers in DMA',
    market_size_revenue     DECIMAL(12,2)
                            COMMENT 'Annual market revenue ($)',
    yoy_market_growth       DECIMAL(5,2)
                            COMMENT 'YoY market growth (%)',
    
    -- Snowmobile Position
    snowmobile_subs         INT
                            COMMENT 'Snowmobile subscribers in DMA',
    snowmobile_market_share DECIMAL(5,2)
                            COMMENT 'Snowmobile market share (%)',
    snowmobile_nps          INT
                            COMMENT 'Snowmobile NPS in DMA',
    snowmobile_coverage_pct DECIMAL(5,2)
                            COMMENT 'Snowmobile coverage (%)',
    snowmobile_5g_pct       DECIMAL(5,2)
                            COMMENT 'Snowmobile 5G coverage (%)',
    
    -- Competitor 1: Verizon
    vz_market_share         DECIMAL(5,2)
                            COMMENT 'Verizon market share (%)',
    vz_avg_price            DECIMAL(6,2)
                            COMMENT 'Verizon average plan price ($)',
    vz_nps                  INT
                            COMMENT 'Verizon NPS',
    vz_coverage_pct         DECIMAL(5,2)
                            COMMENT 'Verizon coverage (%)',
    
    -- Competitor 2: AT&T
    att_market_share        DECIMAL(5,2)
                            COMMENT 'AT&T market share (%)',
    att_avg_price           DECIMAL(6,2)
                            COMMENT 'AT&T average plan price ($)',
    att_nps                 INT
                            COMMENT 'AT&T NPS',
    att_coverage_pct        DECIMAL(5,2)
                            COMMENT 'AT&T coverage (%)',
    
    -- Competitor 3: T-Mobile
    tmo_market_share        DECIMAL(5,2)
                            COMMENT 'T-Mobile market share (%)',
    tmo_avg_price           DECIMAL(6,2)
                            COMMENT 'T-Mobile average plan price ($)',
    tmo_nps                 INT
                            COMMENT 'T-Mobile NPS',
    tmo_coverage_pct        DECIMAL(5,2)
                            COMMENT 'T-Mobile coverage (%)',
    
    -- Regional Competitors (Cricket, Metro, US Cellular, etc.)
    regional_market_share   DECIMAL(5,2)
                            COMMENT 'Regional competitors combined share (%)',
    regional_avg_price      DECIMAL(6,2)
                            COMMENT 'Regional competitors avg price ($)',
    
    -- Competitive Dynamics
    market_concentration    DECIMAL(5,2)
                            COMMENT 'HHI market concentration index',
    price_war_intensity     VARCHAR(10)
                            COMMENT 'Price war intensity (Low/Medium/High)',
    recent_competitor_promo VARCHAR(200)
                            COMMENT 'Recent competitor promotion description',
    promo_end_date          DATE
                            COMMENT 'Competitor promo end date'
)
COMMENT = 'Competitive landscape by DMA - 210 records';

-- ============================================================================
-- LIFESTYLE_SEGMENTS TABLE
-- Psychographic/lifestyle data by ZIP code
-- ============================================================================

CREATE OR REPLACE TABLE EXTERNAL.LIFESTYLE_SEGMENTS (
    -- Identity
    zip_code                VARCHAR(5) NOT NULL PRIMARY KEY
                            COMMENT 'US ZIP code (5-digit)',
    
    -- Dominant Lifestyle Cluster (PRIZM-style)
    primary_lifestyle       VARCHAR(50)
                            COMMENT 'Primary lifestyle cluster',
    secondary_lifestyle     VARCHAR(50)
                            COMMENT 'Secondary lifestyle cluster',
    lifestyle_diversity     DECIMAL(3,2)
                            COMMENT 'Lifestyle diversity score (0-1)',
    
    -- Technology Adoption (0-100 scores)
    tech_adoption_score     INT
                            COMMENT 'Overall tech adoption score (0-100)',
    smartphone_penetration  DECIMAL(5,2)
                            COMMENT 'Smartphone penetration (%)',
    pct_iphone              DECIMAL(5,2)
                            COMMENT 'iPhone market share in ZIP (%)',
    pct_android             DECIMAL(5,2)
                            COMMENT 'Android market share in ZIP (%)',
    smart_home_adoption     DECIMAL(5,2)
                            COMMENT 'Smart home device adoption (%)',
    streaming_penetration   DECIMAL(5,2)
                            COMMENT 'Streaming service penetration (%)',
    cord_cutter_rate        DECIMAL(5,2)
                            COMMENT 'Cord cutter rate (%)',
    
    -- Digital Behavior
    avg_daily_screen_time   DECIMAL(4,1)
                            COMMENT 'Average daily screen time (hours)',
    social_media_heavy_pct  DECIMAL(5,2)
                            COMMENT 'Heavy social media users (%)',
    online_shopping_pct     DECIMAL(5,2)
                            COMMENT 'Online shopping participation (%)',
    mobile_banking_pct      DECIMAL(5,2)
                            COMMENT 'Mobile banking users (%)',
    
    -- Media Consumption
    streaming_hours_week    DECIMAL(4,1)
                            COMMENT 'Weekly streaming hours',
    gaming_hours_week       DECIMAL(4,1)
                            COMMENT 'Weekly gaming hours',
    news_consumption        VARCHAR(20)
                            COMMENT 'News consumption level (Heavy/Moderate/Light)',
    primary_news_source     VARCHAR(30)
                            COMMENT 'Primary news source (Social/TV/Online/Print)',
    
    -- Values & Priorities (0-100 scores)
    price_sensitivity_index INT
                            COMMENT 'Price sensitivity score (0-100, higher=more sensitive)',
    brand_loyalty_index     INT
                            COMMENT 'Brand loyalty score (0-100)',
    eco_consciousness       INT
                            COMMENT 'Eco-consciousness score (0-100)',
    early_adopter_index     INT
                            COMMENT 'Early adopter score (0-100)',
    
    -- Communication Preferences (percentages)
    pref_channel_digital    DECIMAL(5,2)
                            COMMENT 'Prefer digital/app communication (%)',
    pref_channel_phone      DECIMAL(5,2)
                            COMMENT 'Prefer phone communication (%)',
    pref_channel_store      DECIMAL(5,2)
                            COMMENT 'Prefer in-store communication (%)',
    pref_channel_chat       DECIMAL(5,2)
                            COMMENT 'Prefer chat communication (%)',
    
    -- Wireless-Specific Behaviors
    avg_data_usage_gb       DECIMAL(5,1)
                            COMMENT 'Average monthly data usage (GB)',
    avg_lines_per_account   DECIMAL(3,1)
                            COMMENT 'Average lines per account',
    family_plan_propensity  DECIMAL(5,2)
                            COMMENT 'Family plan propensity (%)',
    premium_plan_propensity DECIMAL(5,2)
                            COMMENT 'Premium plan propensity (%)',
    prepaid_propensity      DECIMAL(5,2)
                            COMMENT 'Prepaid plan propensity (%)',
    
    -- Churn Propensity Factors
    deal_seeker_index       INT
                            COMMENT 'Deal seeker score (0-100)',
    switching_propensity    DECIMAL(5,2)
                            COMMENT 'Base switching propensity (%)',
    competitor_awareness    DECIMAL(5,2)
                            COMMENT 'Competitor offer awareness (%)'
)
COMMENT = 'Lifestyle/psychographic segments by ZIP - 42K records';

-- ============================================================================
-- INDEXES (Clustering Keys)
-- ============================================================================

-- Cluster demographics by region for analysis
ALTER TABLE EXTERNAL.ZIP_DEMOGRAPHICS CLUSTER BY (state_code, region);

-- Cluster economic by COL for segmentation
ALTER TABLE EXTERNAL.ECONOMIC_INDICATORS CLUSTER BY (cost_of_living_index);

-- Cluster lifestyle by tech adoption
ALTER TABLE EXTERNAL.LIFESTYLE_SEGMENTS CLUSTER BY (tech_adoption_score, price_sensitivity_index);

-- ============================================================================
-- VERIFICATION
-- ============================================================================

SHOW TABLES IN SCHEMA EXTERNAL;

SELECT 'External tables created successfully!' AS status;


