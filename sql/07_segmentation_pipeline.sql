-- ============================================================================
-- Snowmobile Wireless - Customer Digital Twin
-- 07_segmentation_pipeline.sql
-- 
-- Purpose: Data-driven customer segmentation using ML clustering
-- ============================================================================

USE DATABASE SNOWMOBILE_DIGITAL_TWIN;
USE SCHEMA ANALYTICS;
USE WAREHOUSE CDT_ML_WH;

-- ============================================================================
-- FEATURE PREPARATION FOR CLUSTERING
-- Normalize features to 0-1 scale for K-Means
-- ============================================================================

CREATE OR REPLACE TABLE ANALYTICS.CLUSTERING_FEATURES AS
WITH feature_stats AS (
    SELECT 
        -- Calculate min/max for normalization
        MIN(monthly_arpu) AS min_arpu, MAX(monthly_arpu) AS max_arpu,
        MIN(avg_data_usage_gb) AS min_data, MAX(avg_data_usage_gb) AS max_data,
        MIN(tenure_months) AS min_tenure, MAX(tenure_months) AS max_tenure,
        MIN(COALESCE(app_engagement_score, 0)) AS min_engage, MAX(COALESCE(app_engagement_score, 0)) AS max_engage,
        MIN(churn_risk_score) AS min_churn, MAX(churn_risk_score) AS max_churn,
        MIN(COALESCE(price_sensitivity_index, 50)) AS min_price_sens, MAX(COALESCE(price_sensitivity_index, 50)) AS max_price_sens,
        MIN(COALESCE(tech_adoption_score, 50)) AS min_tech, MAX(COALESCE(tech_adoption_score, 50)) AS max_tech,
        MIN(lines_on_account) AS min_lines, MAX(lines_on_account) AS max_lines,
        MIN(age) AS min_age, MAX(age) AS max_age
    FROM ANALYTICS.CUSTOMER_FEATURES_ENRICHED
)
SELECT 
    f.customer_id,
    
    -- Normalized features (0-1 scale)
    (f.monthly_arpu - s.min_arpu) / NULLIF(s.max_arpu - s.min_arpu, 0) AS arpu_norm,
    (COALESCE(f.avg_data_usage_gb, 0) - s.min_data) / NULLIF(s.max_data - s.min_data, 0) AS data_norm,
    (f.tenure_months - s.min_tenure) / NULLIF(s.max_tenure - s.min_tenure, 0) AS tenure_norm,
    (COALESCE(f.app_engagement_score, 0) - s.min_engage) / NULLIF(s.max_engage - s.min_engage, 0) AS engagement_norm,
    (f.churn_risk_score - s.min_churn) / NULLIF(s.max_churn - s.min_churn, 0) AS churn_risk_norm,
    (COALESCE(f.price_sensitivity_index, 50) - s.min_price_sens) / NULLIF(s.max_price_sens - s.min_price_sens, 0) AS price_sens_norm,
    (COALESCE(f.tech_adoption_score, 50) - s.min_tech) / NULLIF(s.max_tech - s.min_tech, 0) AS tech_adoption_norm,
    (f.lines_on_account - s.min_lines) / NULLIF(s.max_lines - s.min_lines, 0) AS lines_norm,
    (f.age - s.min_age) / NULLIF(s.max_age - s.min_age, 0) AS age_norm,
    
    -- Categorical encodings
    CASE f.urban_rural_class 
        WHEN 'Urban' THEN 1.0 
        WHEN 'Suburban' THEN 0.66 
        WHEN 'Rural' THEN 0.33 
        ELSE 0.0 
    END AS urban_score,
    
    CASE WHEN f.device_os = 'iOS' THEN 1.0 ELSE 0.0 END AS ios_flag,
    
    CASE f.plan_category
        WHEN 'Postpaid' THEN 1.0
        ELSE 0.0
    END AS postpaid_flag,
    
    CASE 
        WHEN f.plan_name IN ('Summit', 'Blizzard') THEN 1.0
        WHEN f.plan_name IN ('Powder', 'Avalanche') THEN 0.5
        ELSE 0.0
    END AS premium_plan_score,
    
    -- Raw values for analysis
    f.monthly_arpu,
    f.avg_data_usage_gb,
    f.tenure_months,
    f.plan_name,
    f.urban_rural_class,
    f.primary_lifestyle

FROM ANALYTICS.CUSTOMER_FEATURES_ENRICHED f
CROSS JOIN feature_stats s;

-- ============================================================================
-- K-MEANS CLUSTERING
-- Using Snowflake ML Functions
-- ============================================================================

-- Note: Snowflake ML K-Means syntax may vary by version
-- This uses the Snowpark ML approach

-- For environments without ML Functions, use manual distance-based clustering:

CREATE OR REPLACE TABLE ANALYTICS.CUSTOMER_SEGMENTS AS
WITH cluster_centroids AS (
    -- Define 8 cluster centroids based on business logic
    -- These represent our target segment profiles
    SELECT 1 AS cluster_id, 0.3 AS c_arpu, 0.2 AS c_data, 0.2 AS c_tenure, 0.3 AS c_engage, 0.6 AS c_churn, 0.8 AS c_price_sens, 0.3 AS c_tech, 0.2 AS c_lines, 0.4 AS c_age UNION ALL  -- Value Seekers
    SELECT 2, 0.7, 0.9, 0.5, 0.8, 0.2, 0.3, 0.9, 0.2, 0.3 UNION ALL  -- Data Streamers
    SELECT 3, 0.8, 0.6, 0.6, 0.6, 0.3, 0.5, 0.5, 0.9, 0.5 UNION ALL  -- Family Connectors
    SELECT 4, 0.5, 0.3, 0.9, 0.5, 0.1, 0.4, 0.3, 0.2, 0.7 UNION ALL  -- Steady Loyalists
    SELECT 5, 0.9, 0.8, 0.5, 0.9, 0.2, 0.2, 0.95, 0.2, 0.4 UNION ALL  -- Premium Techies
    SELECT 6, 0.5, 0.4, 0.7, 0.3, 0.3, 0.5, 0.3, 0.2, 0.6 UNION ALL  -- Rural Reliables
    SELECT 7, 0.5, 0.7, 0.1, 0.7, 0.5, 0.6, 0.8, 0.1, 0.1 UNION ALL  -- Young Digitals
    SELECT 8, 0.4, 0.4, 0.4, 0.3, 0.9, 0.7, 0.4, 0.2, 0.5           -- At-Risk Defectors
),
customer_distances AS (
    -- Calculate Euclidean distance from each customer to each centroid
    SELECT 
        f.customer_id,
        c.cluster_id,
        SQRT(
            POWER(COALESCE(f.arpu_norm, 0.5) - c.c_arpu, 2) +
            POWER(COALESCE(f.data_norm, 0.5) - c.c_data, 2) +
            POWER(COALESCE(f.tenure_norm, 0.5) - c.c_tenure, 2) +
            POWER(COALESCE(f.engagement_norm, 0.5) - c.c_engage, 2) +
            POWER(COALESCE(f.churn_risk_norm, 0.5) - c.c_churn, 2) +
            POWER(COALESCE(f.price_sens_norm, 0.5) - c.c_price_sens, 2) +
            POWER(COALESCE(f.tech_adoption_norm, 0.5) - c.c_tech, 2) +
            POWER(COALESCE(f.lines_norm, 0.5) - c.c_lines, 2) +
            POWER(COALESCE(f.age_norm, 0.5) - c.c_age, 2)
        ) AS distance
    FROM ANALYTICS.CLUSTERING_FEATURES f
    CROSS JOIN cluster_centroids c
),
nearest_cluster AS (
    -- Assign each customer to nearest centroid
    SELECT 
        customer_id,
        cluster_id,
        distance,
        ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY distance) AS rn
    FROM customer_distances
)
SELECT 
    nc.customer_id,
    nc.cluster_id,
    CASE nc.cluster_id
        WHEN 1 THEN 'S1'
        WHEN 2 THEN 'S2'
        WHEN 3 THEN 'S3'
        WHEN 4 THEN 'S4'
        WHEN 5 THEN 'S5'
        WHEN 6 THEN 'S6'
        WHEN 7 THEN 'S7'
        WHEN 8 THEN 'S8'
    END AS segment_id,
    CASE nc.cluster_id
        WHEN 1 THEN 'Value Seekers'
        WHEN 2 THEN 'Data Streamers'
        WHEN 3 THEN 'Family Connectors'
        WHEN 4 THEN 'Steady Loyalists'
        WHEN 5 THEN 'Premium Techies'
        WHEN 6 THEN 'Rural Reliables'
        WHEN 7 THEN 'Young Digitals'
        WHEN 8 THEN 'At-Risk Defectors'
    END AS segment_name,
    nc.distance AS cluster_distance
FROM nearest_cluster nc
WHERE nc.rn = 1;

-- ============================================================================
-- SEGMENT STATISTICS
-- Aggregate statistics for each segment
-- ============================================================================

CREATE OR REPLACE TABLE ANALYTICS.SEGMENT_STATISTICS AS
SELECT
    s.segment_id,
    s.segment_name,
    
    -- Size metrics
    COUNT(*) AS customer_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS pct_of_base,
    
    -- Demographics
    ROUND(AVG(f.age), 0) AS avg_age,
    ROUND(PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY f.age), 0) AS age_p25,
    ROUND(PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY f.age), 0) AS age_p75,
    MODE(f.gender) AS primary_gender,
    ROUND(AVG(f.median_household_income), 0) AS avg_hh_income,
    
    -- Geography
    MODE(f.state_code) AS top_state,
    MODE(f.urban_rural_class) AS primary_geography,
    ROUND(AVG(f.population_density), 0) AS avg_pop_density,
    MODE(f.region) AS primary_region,
    
    -- Account
    ROUND(AVG(f.monthly_arpu), 2) AS avg_arpu,
    ROUND(MEDIAN(f.monthly_arpu), 2) AS median_arpu,
    ROUND(PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY f.monthly_arpu), 2) AS arpu_p25,
    ROUND(PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY f.monthly_arpu), 2) AS arpu_p75,
    ROUND(AVG(f.tenure_months), 0) AS avg_tenure_months,
    ROUND(AVG(f.lines_on_account), 1) AS avg_lines,
    MODE(f.plan_name) AS most_common_plan,
    MODE(f.plan_category) AS primary_plan_category,
    MODE(f.contract_type) AS primary_contract_type,
    
    -- Usage
    ROUND(AVG(f.avg_data_usage_gb), 1) AS avg_data_gb,
    ROUND(MEDIAN(f.avg_data_usage_gb), 1) AS median_data_gb,
    ROUND(AVG(f.avg_voice_minutes), 0) AS avg_voice_min,
    ROUND(AVG(f.avg_5g_usage_pct), 1) AS avg_5g_pct,
    
    -- Device
    MODE(f.device_os) AS primary_os,
    MODE(f.device_brand) AS top_device_brand,
    ROUND(AVG(CASE WHEN f.device_tier = 'Flagship' THEN 1 ELSE 0 END) * 100, 1) AS pct_flagship,
    ROUND(AVG(CASE WHEN f.is_5g_capable THEN 1 ELSE 0 END) * 100, 1) AS pct_5g_capable,
    
    -- Engagement & Loyalty
    ROUND(AVG(COALESCE(f.app_engagement_score, 0)), 2) AS avg_engagement,
    ROUND(AVG(CASE WHEN f.app_user THEN 1 ELSE 0 END) * 100, 1) AS pct_app_users,
    ROUND(AVG(CASE WHEN f.rewards_member THEN 1 ELSE 0 END) * 100, 1) AS pct_rewards_members,
    MODE(f.rewards_tier) AS primary_rewards_tier,
    
    -- Risk
    ROUND(AVG(f.churn_risk_score), 3) AS avg_churn_risk,
    ROUND(AVG(f.adjusted_churn_risk), 3) AS avg_adjusted_churn_risk,
    ROUND(AVG(f.nps_score), 0) AS avg_nps,
    ROUND(AVG(f.complaint_count_12m), 1) AS avg_complaints,
    
    -- External/Lifestyle
    ROUND(AVG(COALESCE(f.tech_adoption_score, 50)), 0) AS avg_tech_adoption,
    ROUND(AVG(COALESCE(f.price_sensitivity_index, 50)), 0) AS avg_price_sensitivity,
    ROUND(AVG(COALESCE(f.brand_loyalty_index, 50)), 0) AS avg_brand_loyalty,
    ROUND(AVG(COALESCE(f.early_adopter_index, 50)), 0) AS avg_early_adopter,
    MODE(f.primary_lifestyle) AS dominant_lifestyle,
    
    -- Economic context
    ROUND(AVG(COALESCE(f.cost_of_living_index, 100)), 1) AS avg_col_index,
    ROUND(AVG(COALESCE(f.unemployment_rate, 4)), 2) AS avg_unemployment,
    
    -- Competitive context
    ROUND(AVG(COALESCE(f.local_market_share, 18)), 1) AS avg_market_share,
    MODE(f.price_war_intensity) AS typical_competition,
    
    -- Financial metrics
    SUM(f.monthly_arpu) AS total_monthly_revenue,
    SUM(f.lifetime_value) AS total_ltv,
    SUM(f.monthly_arpu * f.churn_risk_score) AS total_value_at_risk,
    
    -- Timestamps
    CURRENT_TIMESTAMP() AS created_at

FROM ANALYTICS.CUSTOMER_SEGMENTS s
JOIN ANALYTICS.CUSTOMER_FEATURES_ENRICHED f ON s.customer_id = f.customer_id
GROUP BY s.segment_id, s.segment_name
ORDER BY customer_count DESC;

-- ============================================================================
-- SEGMENT MAPPING TABLE
-- Business descriptions for each segment
-- ============================================================================

CREATE OR REPLACE TABLE ANALYTICS.SEGMENT_MAPPING (
    segment_id VARCHAR(10) PRIMARY KEY,
    segment_name VARCHAR(50),
    segment_description VARCHAR(500),
    key_characteristics VARCHAR(500),
    typical_plan VARCHAR(50),
    price_sensitivity VARCHAR(20),
    churn_risk_level VARCHAR(20),
    engagement_level VARCHAR(20),
    primary_value_driver VARCHAR(100),
    recommended_approach VARCHAR(200)
);

INSERT INTO ANALYTICS.SEGMENT_MAPPING VALUES
('S1', 'Value Seekers', 
 'Price-conscious customers who prioritize low cost over features. Often on prepaid or basic plans, shorter tenure, higher churn risk when prices increase.',
 'High price sensitivity, low tenure, prepaid/Glacier plans, respond mainly to discounts',
 'Glacier/Flurry', 'Very High', 'High', 'Low',
 'Lowest possible price',
 'Focus on value messaging, discount offers, avoid price increases without significant value-add'),

('S2', 'Data Streamers',
 'Heavy data users who consume streaming content extensively. Tech-savvy, engaged with app, willing to pay for unlimited data.',
 'High data usage (35GB+), high tech adoption, Blizzard plan, streaming-focused',
 'Blizzard', 'Medium', 'Low', 'High',
 'Unlimited data and streaming quality',
 'Bundle streaming services, highlight 5G speeds, promote unlimited benefits'),

('S3', 'Family Connectors',
 'Multi-line family accounts who value stability and parental controls. Higher ARPU due to multiple lines, suburban households.',
 '3+ lines, suburban, Avalanche plan, family-focused features',
 'Avalanche', 'Medium', 'Low', 'Medium',
 'Family value and control features',
 'Emphasize family benefits, parental controls, multi-line savings'),

('S4', 'Steady Loyalists',
 'Long-tenure customers with consistent usage patterns. Voice-heavy, traditional users who value reliability over innovation.',
 'High tenure (4yr+), low churn risk, voice-heavy, change-resistant',
 'Powder', 'Low', 'Very Low', 'Medium',
 'Reliability and familiar service',
 'Reward loyalty, gentle modernization, avoid forcing changes'),

('S5', 'Premium Techies',
 'High-value customers with flagship devices who want the best. Early adopters, high engagement, willing to pay premium for cutting-edge features.',
 'Flagship devices, iOS dominant, Summit plan, early adopter mindset',
 'Summit', 'Low', 'Low', 'Very High',
 'Latest technology and premium experience',
 'Early access to new features, premium support, tech-forward messaging'),

('S6', 'Rural Reliables',
 'Rural customers where coverage is the primary concern. Moderate usage, value reliability over price, traditional communication preferences.',
 'Rural areas, coverage-focused, moderate data, voice-important',
 'Powder', 'Medium', 'Medium', 'Low',
 'Network coverage and reliability',
 'Emphasize coverage improvements, local presence, reliable service'),

('S7', 'Young Digitals',
 'Young customers (18-29) who are digital natives. High social media usage, brand-agnostic, prone to switching for better deals.',
 'Age 18-29, high social/streaming, high switch propensity, deal-seeking',
 'Powder/Blizzard', 'High', 'High', 'High',
 'Social validation and good deals',
 'Social media engagement, influencer partnerships, competitive offers'),

('S8', 'At-Risk Defectors',
 'Customers showing signs of imminent churn. Recent complaints, high risk scores, may be researching competitors.',
 'High churn risk, recent complaints, competitor interest signals',
 'Various', 'High', 'Critical', 'Declining',
 'Resolution of pain points',
 'Immediate retention intervention, personalized save offers, address complaints');

-- ============================================================================
-- VERIFICATION
-- ============================================================================

-- Segment distribution
SELECT 
    segment_id,
    segment_name,
    customer_count,
    pct_of_base,
    avg_arpu,
    avg_churn_risk,
    avg_price_sensitivity,
    dominant_lifestyle
FROM ANALYTICS.SEGMENT_STATISTICS
ORDER BY customer_count DESC;

-- Verify all customers are segmented
SELECT 
    (SELECT COUNT(*) FROM RAW.CUSTOMERS) AS total_customers,
    (SELECT COUNT(*) FROM ANALYTICS.CUSTOMER_SEGMENTS) AS segmented_customers,
    (SELECT COUNT(DISTINCT segment_id) FROM ANALYTICS.CUSTOMER_SEGMENTS) AS num_segments;

SELECT 'Segmentation pipeline complete!' AS status;


