-- ============================================================================
-- Snowmobile Wireless - Customer Digital Twin
-- 08_persona_generation.sql
-- 
-- Purpose: Generate AI personas using Snowflake Cortex
-- ============================================================================

USE DATABASE SNOWMOBILE_DIGITAL_TWIN;
USE SCHEMA PERSONAS;
USE WAREHOUSE CDT_CORTEX_WH;

-- ============================================================================
-- PERSONA DEFINITIONS TABLE
-- Store generated personas
-- ============================================================================

CREATE OR REPLACE TABLE PERSONAS.PERSONA_DEFINITIONS (
    persona_id              VARCHAR(36) DEFAULT UUID_STRING() PRIMARY KEY,
    segment_id              VARCHAR(10) NOT NULL,
    segment_name            VARCHAR(50) NOT NULL,
    persona_name            VARCHAR(100),
    persona_age             INT,
    persona_location        VARCHAR(100),
    persona_tagline         VARCHAR(200),
    
    -- Demographic Composite
    typical_age_range       VARCHAR(20),
    typical_gender_dist     VARCHAR(50),
    typical_income_range    VARCHAR(50),
    typical_household       VARCHAR(100),
    typical_geography       VARCHAR(100),
    
    -- Account Composite
    typical_plan            VARCHAR(50),
    typical_contract        VARCHAR(30),
    typical_tenure          VARCHAR(30),
    typical_arpu            DECIMAL(10,2),
    typical_device          VARCHAR(100),
    
    -- Behavioral Profile (JSON)
    usage_profile           VARIANT,
    channel_preferences     VARIANT,
    price_sensitivity       VARIANT,
    loyalty_indicators      VARIANT,
    pain_points             VARIANT,
    value_drivers           VARIANT,
    
    -- LLM-Generated Content
    background_story        TEXT,
    personality_description TEXT,
    relationship_with_service TEXT,
    financial_mindset       TEXT,
    communication_style     TEXT,
    decision_making_style   TEXT,
    emotional_triggers      TEXT,
    hot_buttons             VARIANT,
    sample_quotes           VARIANT,
    
    -- Metadata
    created_at              TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at              TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    created_by              VARCHAR(100) DEFAULT CURRENT_USER(),
    generation_model        VARCHAR(50) DEFAULT 'llama3.1-70b',
    version                 INT DEFAULT 1
);

-- ============================================================================
-- HISTORICAL REACTIONS TABLE
-- Store past event reactions for RAG context
-- ============================================================================

CREATE OR REPLACE TABLE PERSONAS.HISTORICAL_REACTIONS (
    reaction_id             VARCHAR(36) DEFAULT UUID_STRING() PRIMARY KEY,
    segment_id              VARCHAR(10),
    event_date              DATE,
    event_type              VARCHAR(50),
    event_description       TEXT,
    
    -- Measured Outcomes
    churn_rate_change       DECIMAL(5,2),
    nps_change              INT,
    call_volume_change      DECIMAL(5,2),
    social_sentiment        DECIMAL(3,2),
    
    -- Qualitative
    reaction_summary        TEXT,
    verbatim_examples       TEXT,
    lessons_learned         TEXT,
    
    -- Metadata
    created_at              TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- Insert sample historical events
INSERT INTO PERSONAS.HISTORICAL_REACTIONS 
(segment_id, event_date, event_type, event_description, churn_rate_change, nps_change, call_volume_change, social_sentiment, reaction_summary, verbatim_examples, lessons_learned)
VALUES
-- Value Seekers reactions
('S1', '2024-04-01', 'PriceIncrease', '5% price increase on all postpaid plans due to inflation', 
 3.2, -12, 55.0, -0.6,
 'Value Seekers showed the strongest negative reaction. 18% contacted support to complain, 12% requested immediate cancellation. Social media complaints spiked. Retention offers with 15% discount effective in 55% of save attempts.',
 '"This is ridiculous - you keep raising prices every year!" / "I''m switching to Mint Mobile" / "Why should I pay more for the same service?"',
 'For price-sensitive segments, price increases must be accompanied by tangible value adds. Consider grandfather clauses or loyalty discounts.'),

('S1', '2024-01-15', 'CompetitorPromo', 'T-Mobile launched $25/month unlimited plan promotion',
 2.8, -8, 25.0, -0.4,
 'Significant uptick in churn intent. Many Value Seekers called to ask about matching offers. Those who churned cited price as primary factor.',
 '"T-Mobile is offering unlimited for $25, can you match it?" / "I''ve been loyal but I can''t ignore $30/month savings"',
 'Monitor competitor promotions closely. Have pre-approved retention offers ready for immediate deployment.'),

-- Data Streamers reactions
('S2', '2024-09-01', 'ProductLaunch', 'Launch of Peak Streaming bundle with Disney+, Hulu, ESPN+',
 -1.5, 15, -10.0, 0.75,
 'Data Streamers responded very positively. High upgrade rate to Summit plan for bundle. Social media praise for value proposition. Reduced support calls as streaming issues decreased with optimized delivery.',
 '"Finally! This is exactly what I wanted" / "The bundle actually makes sense financially" / "5G streaming is incredible"',
 'This segment responds well to entertainment bundles and streaming optimization. Lead with content value, not price.'),

('S2', '2024-06-15', 'NetworkUpgrade', '5G expansion to 15 new markets',
 -0.8, 8, -5.0, 0.6,
 'Positive reception from Data Streamers in affected markets. Increased data usage observed. Some customers upgraded devices to access 5G.',
 '"About time! 5G speeds are amazing" / "Streaming quality is noticeably better"',
 'Network improvements are valued by this segment. Communicate coverage expansions proactively.'),

-- Family Connectors reactions
('S3', '2024-03-01', 'PolicyChange', 'Changes to family plan data sharing - stricter fair use policy',
 1.2, -6, 35.0, -0.3,
 'Moderate negative reaction. Parents concerned about managing kids'' usage. Increase in parental control feature usage. Some complaints about throttling.',
 '"My kids are complaining about slow speeds" / "The fair use policy is too restrictive for a family" / "We need more flexibility"',
 'Family segments need clear communication and tools to manage usage across lines. Parental control features should be highlighted.'),

('S3', '2024-07-01', 'Promotion', 'Back-to-school promotion: Free tablet with Avalanche plan',
 -2.0, 10, 15.0, 0.5,
 'Strong positive response. High conversion on tablet offer. Parents appreciated back-to-school timing. Increased line additions.',
 '"Perfect timing for school" / "Great value for families" / "Added a line for my daughter"',
 'Seasonal promotions aligned with family milestones (back-to-school, holidays) resonate strongly.'),

-- Steady Loyalists reactions
('S4', '2024-02-01', 'AppRedesign', 'Major redesign of Snowmobile app with new interface',
 0.5, -3, 40.0, -0.2,
 'Mixed to negative reaction from Loyalists. Many struggled with new interface. Increased support calls for help navigating. Some reverted to calling customer service.',
 '"Why did you change everything? I knew how to use the old app" / "Can''t find where to pay my bill anymore" / "Too many changes at once"',
 'For traditional segments, introduce changes gradually. Provide tutorials and maintain familiar pathways.'),

-- Premium Techies reactions  
('S5', '2024-08-01', 'BetaProgram', 'Early access beta for new AI assistant feature in app',
 -0.5, 12, -8.0, 0.8,
 'Very positive reception. High enrollment in beta program. Active feedback provided. Social media advocacy from participants.',
 '"Love being first to try new features" / "The AI assistant is actually useful" / "This is why I pay premium"',
 'Premium segments value exclusivity and early access. Beta programs drive engagement and loyalty.'),

-- Rural Reliables reactions
('S6', '2024-05-01', 'CoverageExpansion', 'Network coverage expansion to rural Montana and Wyoming',
 -1.8, 18, -15.0, 0.7,
 'Highly positive reaction in affected areas. Significant reduction in churn. Customers expressed gratitude for investment in rural areas.',
 '"Finally have signal at my ranch" / "You''re the only carrier that cares about rural customers" / "Worth every penny now"',
 'Coverage is the #1 priority for rural segments. Infrastructure investments drive strong loyalty.'),

-- Young Digitals reactions
('S7', '2024-10-01', 'SocialCampaign', 'TikTok influencer campaign with exclusive promo code',
 -0.8, 5, 10.0, 0.4,
 'Moderate positive response. Good engagement on social content. Promo code redemption met targets. Some organic sharing.',
 '"Saw this on TikTok, the deal is legit" / "Finally a carrier that gets how we communicate"',
 'Social media campaigns can reach this segment effectively. Authenticity matters - avoid overly corporate messaging.'),

-- At-Risk Defectors reactions
('S8', '2024-04-15', 'RetentionOutreach', 'Proactive retention calls with personalized offers',
 -4.5, 8, 20.0, 0.3,
 'Mixed results. Early intervention successful for 45% of contacted customers. Others had already decided to leave. Personalization was key differentiator.',
 '"I appreciate you reaching out proactively" / "Too little too late - should have called months ago" / "The offer is good but my trust is broken"',
 'Early intervention is critical. By the time customers show high risk signals, some are already decided. Focus on prevention.');

-- ============================================================================
-- PERSONA GENERATION FUNCTION
-- Generate persona using Cortex LLM
-- ============================================================================

CREATE OR REPLACE FUNCTION PERSONAS.GENERATE_PERSONA_TEXT(
    segment_stats VARIANT,
    sample_verbatims ARRAY
)
RETURNS TEXT
LANGUAGE SQL
AS
$$
SELECT SNOWFLAKE.CORTEX.COMPLETE(
    'llama3.1-70b',
    CONCAT(
        'You are an expert in telecom customer behavior and market research for Snowmobile Wireless, ',
        'a US-based mobile carrier headquartered in Bozeman, Montana. Their brand is data-focused, ',
        'modern, and transparent with snow-themed plan names (Flurry, Powder, Blizzard, Avalanche, Summit, Glacier).',
        
        '\n\nCreate a detailed, realistic persona for this customer segment. ',
        'The persona should feel like a real American customer, not a stereotype. ',
        'Include nuanced motivations, concerns, and behavioral patterns specific to US telecom market.',
        
        '\n\n### SEGMENT STATISTICS ###\n',
        TO_VARCHAR(segment_stats),
        
        '\n\n### SAMPLE CUSTOMER VERBATIMS FROM THIS SEGMENT ###\n',
        ARRAY_TO_STRING(sample_verbatims, '\n---\n'),
        
        '\n\n### INSTRUCTIONS ###\n',
        'Generate a persona with ALL of the following sections. Be specific and detailed:\n\n',
        
        '1. **PERSONA IDENTITY**\n',
        '   - Full name (realistic American name appropriate for demographics)\n',
        '   - Age (specific number within segment range)\n',
        '   - Location (specific city, state that matches segment geography)\n',
        '   - Tagline (one sentence capturing their essence)\n\n',
        
        '2. **BACKGROUND STORY** (150 words)\n',
        '   - Occupation and life situation\n',
        '   - Family/household composition\n',
        '   - Why they chose Snowmobile Wireless\n',
        '   - How long they''ve been a customer\n\n',
        
        '3. **RELATIONSHIP WITH MOBILE SERVICE** (150 words)\n',
        '   - How important is mobile connectivity to their daily life?\n',
        '   - What do they primarily use their phone for?\n',
        '   - How tech-savvy are they?\n',
        '   - How do they interact with Snowmobile (app, store, call)?\n\n',
        
        '4. **FINANCIAL MINDSET** (100 words)\n',
        '   - How do they view their wireless bill?\n',
        '   - What monthly amount triggers concern?\n',
        '   - How do they react to price increases?\n',
        '   - What would make them consider leaving?\n\n',
        
        '5. **COMMUNICATION STYLE** (75 words)\n',
        '   - How do they prefer to interact with customer service?\n',
        '   - How do they express dissatisfaction?\n',
        '   - What tone do they use (formal/casual/emotional)?\n\n',
        
        '6. **DECISION-MAKING PATTERN** (75 words)\n',
        '   - How do they evaluate offers and changes?\n',
        '   - Who influences their decisions?\n',
        '   - How quickly do they make decisions?\n\n',
        
        '7. **HOT BUTTONS**\n',
        '   - 3 things that would definitely make them HAPPY\n',
        '   - 3 things that would definitely make them ANGRY\n',
        '   - 3 things they would likely IGNORE\n\n',
        
        '8. **SAMPLE QUOTES** (realistic things they might say)\n',
        '   - When satisfied with service\n',
        '   - When frustrated with an issue\n',
        '   - When considering leaving for a competitor\n\n',
        
        'Make this persona grounded in the data provided. The persona should be consistent ',
        'with the segment statistics while feeling like a real individual.'
    )
)
$$;

-- ============================================================================
-- PROCEDURE TO GENERATE ALL PERSONAS
-- ============================================================================

CREATE OR REPLACE PROCEDURE PERSONAS.GENERATE_ALL_PERSONAS()
RETURNS VARCHAR
LANGUAGE SQL
AS
$$
DECLARE
    segment_record RECORD;
    segment_stats VARIANT;
    verbatims ARRAY;
    persona_text TEXT;
    persona_count INT := 0;
BEGIN
    -- Loop through each segment
    FOR segment_record IN 
        SELECT segment_id, segment_name FROM ANALYTICS.SEGMENT_STATISTICS ORDER BY customer_count DESC
    DO
        -- Get segment statistics as JSON
        SELECT OBJECT_CONSTRUCT(
            'segment_id', segment_id,
            'segment_name', segment_name,
            'customer_count', customer_count,
            'pct_of_base', pct_of_base,
            'avg_age', avg_age,
            'age_range', age_p25::VARCHAR || '-' || age_p75::VARCHAR,
            'primary_gender', primary_gender,
            'avg_household_income', avg_hh_income,
            'primary_geography', primary_geography,
            'primary_region', primary_region,
            'avg_arpu', avg_arpu,
            'median_arpu', median_arpu,
            'avg_tenure_months', avg_tenure_months,
            'avg_lines', avg_lines,
            'most_common_plan', most_common_plan,
            'avg_data_gb', avg_data_gb,
            'avg_voice_min', avg_voice_min,
            'primary_os', primary_os,
            'top_device_brand', top_device_brand,
            'pct_flagship', pct_flagship,
            'avg_engagement', avg_engagement,
            'pct_app_users', pct_app_users,
            'avg_churn_risk', avg_churn_risk,
            'avg_nps', avg_nps,
            'avg_tech_adoption', avg_tech_adoption,
            'avg_price_sensitivity', avg_price_sensitivity,
            'avg_brand_loyalty', avg_brand_loyalty,
            'dominant_lifestyle', dominant_lifestyle
        ) INTO segment_stats
        FROM ANALYTICS.SEGMENT_STATISTICS
        WHERE segment_id = segment_record.segment_id;
        
        -- Get sample verbatims from historical reactions
        SELECT ARRAY_AGG(verbatim_examples) INTO verbatims
        FROM PERSONAS.HISTORICAL_REACTIONS
        WHERE segment_id = segment_record.segment_id;
        
        -- Generate persona text
        SELECT PERSONAS.GENERATE_PERSONA_TEXT(segment_stats, COALESCE(verbatims, ARRAY_CONSTRUCT('No historical verbatims available')))
        INTO persona_text;
        
        -- Insert into persona definitions
        INSERT INTO PERSONAS.PERSONA_DEFINITIONS (
            segment_id,
            segment_name,
            typical_arpu,
            background_story,
            personality_description
        )
        SELECT 
            segment_record.segment_id,
            segment_record.segment_name,
            segment_stats:avg_arpu::DECIMAL(10,2),
            persona_text,
            persona_text;
        
        persona_count := persona_count + 1;
    END FOR;
    
    RETURN 'Generated ' || persona_count::VARCHAR || ' personas successfully';
END;
$$;

-- ============================================================================
-- GENERATE PERSONAS FROM SEGMENTATION RESULTS
-- ============================================================================
-- 
-- IMPORTANT: Personas are generated DYNAMICALLY from segment statistics.
-- This follows the industry-standard flow:
--   1. Run segmentation (07_segmentation_pipeline.sql)
--   2. Generate personas from segment statistics (this section)
--
-- The GENERATE_ALL_PERSONAS() procedure reads from ANALYTICS.SEGMENT_STATISTICS
-- which is created by the segmentation pipeline.
-- ============================================================================

-- Clear any existing personas before regenerating
TRUNCATE TABLE PERSONAS.PERSONA_DEFINITIONS;

-- Generate personas dynamically from segment statistics
-- This procedure:
--   1. Reads each segment from ANALYTICS.SEGMENT_STATISTICS
--   2. Gathers historical verbatims for context
--   3. Calls Snowflake Cortex LLM to generate realistic personas
--   4. Inserts the generated personas into PERSONA_DEFINITIONS
--
-- NOTE: This requires ANALYTICS.SEGMENT_STATISTICS to exist.
-- Run 07_segmentation_pipeline.sql first!

CALL PERSONAS.GENERATE_ALL_PERSONAS();

-- ============================================================================
-- VERIFICATION
-- ============================================================================

-- Check personas were generated from segments
SELECT 
    p.persona_id,
    p.segment_id,
    p.segment_name,
    p.typical_arpu,
    p.created_at,
    p.generation_model,
    LEFT(p.background_story, 200) AS background_preview
FROM PERSONAS.PERSONA_DEFINITIONS p
ORDER BY p.segment_id;

-- Show segment statistics that personas were generated from
SELECT 
    segment_id,
    segment_name,
    customer_count,
    ROUND(pct_of_base, 1) AS pct_of_base,
    ROUND(avg_arpu, 2) AS avg_arpu,
    most_common_plan,
    primary_geography
FROM ANALYTICS.SEGMENT_STATISTICS
ORDER BY customer_count DESC;

-- Check historical reactions (used for RAG context in generation)
SELECT 
    segment_id, 
    COUNT(*) AS reaction_count,
    LISTAGG(DISTINCT event_type, ', ') AS event_types
FROM PERSONAS.HISTORICAL_REACTIONS
GROUP BY segment_id
ORDER BY segment_id;

-- Summary
SELECT 
    (SELECT COUNT(*) FROM ANALYTICS.SEGMENT_STATISTICS) AS segments_found,
    (SELECT COUNT(*) FROM PERSONAS.PERSONA_DEFINITIONS) AS personas_generated,
    (SELECT COUNT(*) FROM PERSONAS.HISTORICAL_REACTIONS) AS historical_reactions,
    'Personas dynamically generated from segmentation results!' AS status;


