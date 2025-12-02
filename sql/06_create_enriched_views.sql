-- ============================================================================
-- Snowmobile Wireless - Customer Digital Twin
-- 06_create_enriched_views.sql
-- 
-- Purpose: Create analytics views with feature engineering and external enrichment
-- ============================================================================

USE DATABASE SNOWMOBILE_DIGITAL_TWIN;
USE SCHEMA ANALYTICS;
USE WAREHOUSE CDT_ML_WH;

-- ============================================================================
-- CUSTOMER USAGE SUMMARY
-- Aggregate usage metrics per customer
-- ============================================================================

CREATE OR REPLACE TABLE ANALYTICS.CUSTOMER_USAGE_SUMMARY AS
WITH usage_stats AS (
    SELECT 
        customer_id,
        
        -- Overall averages
        AVG(data_usage_gb) AS avg_data_usage_gb,
        AVG(voice_minutes_onnet + voice_minutes_offnet + voice_minutes_intl) AS avg_voice_minutes,
        AVG(total_bill) AS avg_bill_amount,
        
        -- Recent trends (last 3 months vs prior 3 months)
        AVG(CASE WHEN billing_month >= DATEADD('month', -3, CURRENT_DATE()) THEN data_usage_gb END) AS recent_data_avg,
        AVG(CASE WHEN billing_month >= DATEADD('month', -6, CURRENT_DATE()) 
                  AND billing_month < DATEADD('month', -3, CURRENT_DATE()) THEN data_usage_gb END) AS prior_data_avg,
        
        -- Overage and roaming
        SUM(CASE WHEN overage_charges > 0 THEN 1 ELSE 0 END) AS overage_months,
        SUM(CASE WHEN roaming_days > 0 THEN 1 ELSE 0 END) AS roaming_months,
        AVG(roaming_data_gb) AS avg_roaming_data_gb,
        
        -- Payment behavior
        AVG(days_to_payment) AS avg_days_to_payment,
        SUM(CASE WHEN payment_status != 'Paid' THEN 1 ELSE 0 END) AS late_payment_count,
        
        -- 5G adoption
        AVG(data_usage_5g_pct) AS avg_5g_pct,
        
        -- Counts
        COUNT(*) AS months_of_data
        
    FROM RAW.MONTHLY_USAGE
    WHERE billing_month >= DATEADD('month', -12, CURRENT_DATE())
    GROUP BY customer_id
)
SELECT 
    customer_id,
    avg_data_usage_gb,
    avg_voice_minutes,
    avg_bill_amount,
    
    -- Data trend classification
    CASE 
        WHEN recent_data_avg > prior_data_avg * 1.1 THEN 'Growing'
        WHEN recent_data_avg < prior_data_avg * 0.9 THEN 'Declining'
        ELSE 'Stable'
    END AS data_trend_3m,
    
    -- Overage frequency
    ROUND(overage_months * 100.0 / NULLIF(months_of_data, 0), 1) AS overage_frequency,
    
    -- Roaming behavior
    roaming_months AS roaming_month_count,
    avg_roaming_data_gb,
    
    -- Payment behavior
    avg_days_to_payment,
    late_payment_count,
    
    -- 5G usage
    avg_5g_pct,
    
    months_of_data
    
FROM usage_stats;

-- ============================================================================
-- CUSTOMER INTERACTION SUMMARY
-- Aggregate support interaction metrics per customer
-- ============================================================================

CREATE OR REPLACE TABLE ANALYTICS.CUSTOMER_INTERACTION_SUMMARY AS
SELECT 
    customer_id,
    
    -- Contact volume
    COUNT(*) AS support_contacts_12m,
    COUNT(DISTINCT DATE_TRUNC('month', interaction_date)) AS months_with_contact,
    
    -- Channel distribution
    SUM(CASE WHEN channel = 'Call' THEN 1 ELSE 0 END) AS call_contacts,
    SUM(CASE WHEN channel IN ('App', 'Chat') THEN 1 ELSE 0 END) AS digital_contacts,
    SUM(CASE WHEN channel = 'Store' THEN 1 ELSE 0 END) AS store_contacts,
    
    -- Issue types
    SUM(CASE WHEN category = 'Billing' THEN 1 ELSE 0 END) AS billing_issues,
    SUM(CASE WHEN category = 'Technical' THEN 1 ELSE 0 END) AS technical_issues,
    SUM(CASE WHEN category = 'Complaint' THEN 1 ELSE 0 END) AS complaints,
    
    -- Sentiment
    AVG(sentiment_score) AS avg_sentiment_score,
    MIN(sentiment_score) AS min_sentiment_score,
    AVG(csat_score) AS avg_csat_score,
    
    -- Resolution
    AVG(resolution_time_hours) AS avg_resolution_time,
    SUM(CASE WHEN first_contact_resolution THEN 1 ELSE 0 END) * 100.0 / NULLIF(COUNT(*), 0) AS fcr_rate,
    
    -- Complaint rate
    SUM(CASE WHEN category = 'Complaint' THEN 1 ELSE 0 END) * 100.0 / NULLIF(COUNT(*), 0) AS complaint_rate,
    
    -- Most recent interaction
    MAX(interaction_date) AS last_interaction_date,
    DATEDIFF('day', MAX(interaction_date), CURRENT_DATE()) AS days_since_last_contact

FROM RAW.SUPPORT_INTERACTIONS
WHERE interaction_date >= DATEADD('month', -12, CURRENT_DATE())
GROUP BY customer_id;

-- ============================================================================
-- CUSTOMER CAMPAIGN SUMMARY
-- Aggregate campaign response metrics per customer
-- ============================================================================

CREATE OR REPLACE TABLE ANALYTICS.CUSTOMER_CAMPAIGN_SUMMARY AS
SELECT 
    customer_id,
    
    -- Campaign exposure
    COUNT(*) AS campaigns_received,
    SUM(CASE WHEN delivered THEN 1 ELSE 0 END) AS campaigns_delivered,
    
    -- Engagement
    SUM(CASE WHEN opened THEN 1 ELSE 0 END) AS campaigns_opened,
    SUM(CASE WHEN clicked THEN 1 ELSE 0 END) AS campaigns_clicked,
    SUM(CASE WHEN responded THEN 1 ELSE 0 END) AS campaigns_responded,
    
    -- Response types
    SUM(CASE WHEN response_type = 'Accepted' THEN 1 ELSE 0 END) AS offers_accepted,
    SUM(CASE WHEN response_type = 'Declined' THEN 1 ELSE 0 END) AS offers_declined,
    SUM(CASE WHEN response_type = 'Complained' THEN 1 ELSE 0 END) AS campaign_complaints,
    
    -- Conversions
    SUM(CASE WHEN converted THEN 1 ELSE 0 END) AS conversions,
    SUM(conversion_value) AS total_conversion_value,
    
    -- Rates
    SUM(CASE WHEN opened THEN 1 ELSE 0 END) * 100.0 / NULLIF(SUM(CASE WHEN delivered THEN 1 ELSE 0 END), 0) AS open_rate,
    SUM(CASE WHEN clicked THEN 1 ELSE 0 END) * 100.0 / NULLIF(SUM(CASE WHEN opened THEN 1 ELSE 0 END), 0) AS click_rate,
    SUM(CASE WHEN converted THEN 1 ELSE 0 END) * 100.0 / NULLIF(COUNT(*), 0) AS conversion_rate,
    
    -- Campaign type responsiveness
    SUM(CASE WHEN campaign_type = 'Retention' AND converted THEN 1 ELSE 0 END) AS retention_conversions,
    SUM(CASE WHEN campaign_type = 'Upsell' AND converted THEN 1 ELSE 0 END) AS upsell_conversions

FROM RAW.CAMPAIGN_RESPONSES
WHERE sent_at >= DATEADD('month', -12, CURRENT_DATE())
GROUP BY customer_id;

-- ============================================================================
-- CUSTOMER FEATURES ENRICHED
-- Main feature table with all internal and external data joined
-- ============================================================================

CREATE OR REPLACE TABLE ANALYTICS.CUSTOMER_FEATURES_ENRICHED AS
SELECT
    -- Customer Identity
    c.customer_id,
    c.account_id,
    c.zip_code,
    c.state_code,
    c.dma_code,
    
    -- Customer Demographics
    c.age,
    c.gender,
    
    -- Account Details
    c.customer_since,
    c.tenure_months,
    c.acquisition_channel,
    c.plan_name,
    c.plan_category,
    c.plan_price,
    c.lines_on_account,
    c.contract_type,
    c.contract_end_date,
    
    -- Device
    c.device_brand,
    c.device_model,
    c.device_tier,
    c.device_os,
    c.device_age_months,
    c.is_5g_capable,
    
    -- Financial
    c.monthly_arpu,
    c.lifetime_value,
    c.total_revenue_12m,
    c.payment_method,
    c.autopay_enrolled,
    c.paperless_billing,
    c.credit_class,
    
    -- Add-ons
    c.has_device_protection,
    c.has_intl_roaming,
    c.has_streaming_bundle,
    
    -- Loyalty
    c.rewards_member,
    c.rewards_tier,
    c.rewards_points_balance,
    
    -- Engagement
    c.app_user,
    c.app_engagement_score,
    c.last_app_login,
    c.nps_score,
    c.nps_survey_date,
    
    -- Risk
    c.churn_risk_score,
    c.predicted_churn_reason,
    c.complaint_count_12m,
    
    -- ========== USAGE AGGREGATES ==========
    COALESCE(u.avg_data_usage_gb, 0) AS avg_data_usage_gb,
    COALESCE(u.avg_voice_minutes, 0) AS avg_voice_minutes,
    COALESCE(u.avg_bill_amount, c.monthly_arpu) AS avg_bill_amount,
    COALESCE(u.data_trend_3m, 'Stable') AS data_trend_3m,
    COALESCE(u.overage_frequency, 0) AS overage_frequency,
    COALESCE(u.avg_5g_pct, 0) AS avg_5g_usage_pct,
    COALESCE(u.late_payment_count, 0) AS late_payment_count,
    
    -- ========== INTERACTION AGGREGATES ==========
    COALESCE(i.support_contacts_12m, 0) AS support_contacts_12m,
    COALESCE(i.avg_sentiment_score, 0) AS avg_sentiment_score,
    COALESCE(i.complaint_rate, 0) AS complaint_rate,
    COALESCE(i.fcr_rate, 100) AS fcr_rate,
    COALESCE(i.digital_contacts, 0) * 100.0 / NULLIF(i.support_contacts_12m, 0) AS digital_contact_pct,
    
    -- ========== CAMPAIGN AGGREGATES ==========
    COALESCE(camp.campaigns_received, 0) AS campaigns_received,
    COALESCE(camp.open_rate, 0) AS campaign_open_rate,
    COALESCE(camp.conversion_rate, 0) AS campaign_conversion_rate,
    COALESCE(camp.offers_accepted, 0) AS offers_accepted,
    
    -- ========== ZIP DEMOGRAPHICS ==========
    z.zip_name,
    z.state_name,
    z.region,
    z.dma_name,
    z.total_population AS zip_population,
    z.population_density,
    z.urban_rural_class,
    z.median_age AS zip_median_age,
    z.median_household_income,
    z.mean_household_income,
    z.per_capita_income,
    z.pct_income_under_25k,
    z.pct_income_150k_plus,
    z.pct_bachelors AS zip_pct_bachelors,
    z.pct_graduate_degree AS zip_pct_graduate,
    z.pct_owner_occupied,
    z.avg_household_size,
    z.pct_family_households,
    z.pct_married_couples,
    z.pct_living_alone,
    
    -- ========== ECONOMIC INDICATORS ==========
    e.cost_of_living_index,
    e.housing_cost_index,
    e.unemployment_rate,
    e.poverty_rate,
    e.avg_credit_score AS zip_avg_credit_score,
    e.pct_prime_credit,
    e.pct_subprime_credit,
    e.retail_sales_per_capita,
    e.ecommerce_penetration,
    
    -- ========== COMPETITIVE LANDSCAPE ==========
    comp.total_wireless_subs AS dma_total_subs,
    comp.snowmobile_market_share AS local_market_share,
    comp.snowmobile_nps AS local_nps,
    comp.vz_market_share,
    comp.att_market_share,
    comp.tmo_market_share,
    comp.vz_avg_price,
    comp.att_avg_price,
    comp.tmo_avg_price,
    (comp.vz_avg_price + comp.att_avg_price + comp.tmo_avg_price) / 3 AS competitor_avg_price,
    comp.price_war_intensity,
    comp.market_concentration,
    
    -- ========== LIFESTYLE SEGMENTS ==========
    l.primary_lifestyle,
    l.secondary_lifestyle,
    l.tech_adoption_score,
    l.smartphone_penetration AS zip_smartphone_pct,
    l.pct_iphone AS zip_iphone_pct,
    l.streaming_penetration AS zip_streaming_pct,
    l.cord_cutter_rate,
    l.avg_daily_screen_time AS zip_screen_time,
    l.price_sensitivity_index,
    l.brand_loyalty_index,
    l.eco_consciousness,
    l.early_adopter_index,
    l.pref_channel_digital,
    l.pref_channel_phone,
    l.avg_data_usage_gb AS zip_avg_data_gb,
    l.family_plan_propensity,
    l.premium_plan_propensity,
    l.prepaid_propensity,
    l.deal_seeker_index,
    l.switching_propensity AS zip_switch_propensity,
    l.competitor_awareness,
    
    -- ========== DERIVED FEATURES ==========
    -- Price position vs market
    c.monthly_arpu / NULLIF((comp.vz_avg_price + comp.att_avg_price + comp.tmo_avg_price) / 3, 0) AS price_position_ratio,
    
    -- Affordability (ARPU as % of monthly income)
    (c.monthly_arpu * 12) / NULLIF(z.median_household_income, 0) * 100 AS wallet_share_pct,
    
    -- Monthly value score
    c.lifetime_value / NULLIF(c.tenure_months, 0) AS monthly_value,
    
    -- Tenure bucket
    CASE 
        WHEN c.tenure_months < 6 THEN 'New (0-6m)'
        WHEN c.tenure_months < 12 THEN 'Developing (6-12m)'
        WHEN c.tenure_months < 24 THEN 'Established (1-2y)'
        WHEN c.tenure_months < 48 THEN 'Mature (2-4y)'
        ELSE 'Loyal (4y+)'
    END AS tenure_bucket,
    
    -- Age bucket
    CASE 
        WHEN c.age < 25 THEN '18-24'
        WHEN c.age < 35 THEN '25-34'
        WHEN c.age < 45 THEN '35-44'
        WHEN c.age < 55 THEN '45-54'
        WHEN c.age < 65 THEN '55-64'
        ELSE '65+'
    END AS age_bucket,
    
    -- ARPU bucket
    CASE 
        WHEN c.monthly_arpu < 30 THEN 'Low (<$30)'
        WHEN c.monthly_arpu < 50 THEN 'Medium ($30-50)'
        WHEN c.monthly_arpu < 75 THEN 'High ($50-75)'
        WHEN c.monthly_arpu < 100 THEN 'Premium ($75-100)'
        ELSE 'Ultra ($100+)'
    END AS arpu_bucket,
    
    -- Risk-adjusted churn score (combining internal score with external factors)
    c.churn_risk_score * 
        (1 + COALESCE(l.switching_propensity, 0)/100) * 
        CASE 
            WHEN comp.price_war_intensity = 'High' THEN 1.2 
            WHEN comp.price_war_intensity = 'Medium' THEN 1.1 
            ELSE 1.0 
        END AS adjusted_churn_risk,
    
    -- Digital engagement score (composite)
    (COALESCE(c.app_engagement_score, 0) * 0.4 +
     COALESCE(l.tech_adoption_score, 50) / 100 * 0.3 +
     COALESCE(i.digital_contacts, 0) * 100.0 / NULLIF(i.support_contacts_12m, 0) / 100 * 0.3
    ) AS digital_engagement_score,
    
    -- Value at risk (ARPU × churn risk)
    c.monthly_arpu * c.churn_risk_score AS monthly_value_at_risk

FROM RAW.CUSTOMERS c
LEFT JOIN ANALYTICS.CUSTOMER_USAGE_SUMMARY u ON c.customer_id = u.customer_id
LEFT JOIN ANALYTICS.CUSTOMER_INTERACTION_SUMMARY i ON c.customer_id = i.customer_id
LEFT JOIN ANALYTICS.CUSTOMER_CAMPAIGN_SUMMARY camp ON c.customer_id = camp.customer_id
LEFT JOIN EXTERNAL.ZIP_DEMOGRAPHICS z ON c.zip_code = z.zip_code
LEFT JOIN EXTERNAL.ECONOMIC_INDICATORS e ON c.zip_code = e.zip_code
LEFT JOIN EXTERNAL.COMPETITIVE_LANDSCAPE comp ON c.dma_code = comp.dma_code
LEFT JOIN EXTERNAL.LIFESTYLE_SEGMENTS l ON c.zip_code = l.zip_code;

-- ============================================================================
-- CREATE INDEXES
-- ============================================================================

-- Cluster enriched features for segment analysis
ALTER TABLE ANALYTICS.CUSTOMER_FEATURES_ENRICHED 
    CLUSTER BY (plan_name, urban_rural_class, primary_lifestyle);

-- ============================================================================
-- VERIFICATION
-- ============================================================================

-- Check enrichment coverage
SELECT 
    COUNT(*) AS total_customers,
    COUNT(zip_name) AS with_demographics,
    COUNT(cost_of_living_index) AS with_economic,
    COUNT(local_market_share) AS with_competitive,
    COUNT(primary_lifestyle) AS with_lifestyle,
    ROUND(COUNT(zip_name) * 100.0 / COUNT(*), 1) AS demographics_coverage_pct,
    ROUND(COUNT(primary_lifestyle) * 100.0 / COUNT(*), 1) AS lifestyle_coverage_pct
FROM ANALYTICS.CUSTOMER_FEATURES_ENRICHED;

-- Sample enriched record
SELECT * FROM ANALYTICS.CUSTOMER_FEATURES_ENRICHED LIMIT 5;

SELECT 'Enriched views created successfully!' AS status;


