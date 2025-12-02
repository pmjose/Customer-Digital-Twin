-- ============================================================================
-- Snowmobile Wireless - Customer Digital Twin
-- 09_agent_functions.sql
-- 
-- Purpose: Create AI agent functions for persona interactions and simulations
-- ============================================================================

USE DATABASE SNOWMOBILE_DIGITAL_TWIN;
USE SCHEMA AGENTS;
USE WAREHOUSE CDT_CORTEX_WH;

-- ============================================================================
-- SIMULATION LOGS TABLE
-- Track all simulation runs
-- ============================================================================

CREATE OR REPLACE TABLE AGENTS.SIMULATION_LOGS (
    simulation_id           VARCHAR(36) DEFAULT UUID_STRING() PRIMARY KEY,
    simulation_timestamp    TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    scenario_text           TEXT,
    scenario_type           VARCHAR(50),
    segments_included       ARRAY,
    run_by                  VARCHAR(100) DEFAULT CURRENT_USER(),
    total_personas          INT,
    avg_sentiment           DECIMAL(4,2),
    dominant_action         VARCHAR(50),
    execution_time_seconds  DECIMAL(10,2),
    results                 VARIANT
);

-- ============================================================================
-- ASK_PERSONA FUNCTION
-- Query a single persona agent about a scenario
-- ============================================================================

CREATE OR REPLACE FUNCTION AGENTS.ASK_PERSONA(
    p_persona_id VARCHAR,
    p_scenario TEXT
)
RETURNS VARIANT
LANGUAGE SQL
AS
$$
WITH persona_data AS (
    SELECT 
        persona_name,
        segment_name,
        persona_location,
        persona_tagline,
        background_story,
        personality_description,
        relationship_with_service,
        financial_mindset,
        communication_style,
        emotional_triggers,
        hot_buttons,
        sample_quotes,
        typical_arpu
    FROM PERSONAS.PERSONA_DEFINITIONS 
    WHERE persona_id = p_persona_id
),
historical_context AS (
    SELECT LISTAGG(
        'Event: ' || event_type || ' (' || event_date::VARCHAR || ')\n' ||
        'Description: ' || event_description || '\n' ||
        'Reaction: ' || reaction_summary || '\n' ||
        'Lesson: ' || lessons_learned,
        '\n---\n'
    ) WITHIN GROUP (ORDER BY event_date DESC) AS context
    FROM PERSONAS.HISTORICAL_REACTIONS h
    JOIN PERSONAS.PERSONA_DEFINITIONS p ON h.segment_id = p.segment_id
    WHERE p.persona_id = p_persona_id
)
SELECT PARSE_JSON(
    SNOWFLAKE.CORTEX.COMPLETE(
        'llama3.1-70b',
        (SELECT CONCAT(
            '### ROLE ###\n',
            'You are roleplaying as a Snowmobile Wireless customer. Stay COMPLETELY in character.\n',
            'Respond exactly as this specific person would - with their concerns, priorities, communication style, and personality.\n',
            'You are NOT an AI assistant - you ARE this customer.\n\n',
            
            '### YOUR IDENTITY ###\n',
            'Name: ', p.persona_name, '\n',
            'Location: ', p.persona_location, '\n',
            'Who you are: ', p.persona_tagline, '\n\n',
            
            '### YOUR BACKGROUND ###\n',
            p.background_story, '\n\n',
            
            '### YOUR PERSONALITY ###\n',
            p.personality_description, '\n\n',
            
            '### HOW YOU VIEW MOBILE SERVICE ###\n',
            p.relationship_with_service, '\n\n',
            
            '### YOUR FINANCIAL MINDSET ###\n',
            p.financial_mindset, '\n\n',
            
            '### HOW YOU COMMUNICATE ###\n',
            p.communication_style, '\n\n',
            
            '### WHAT TRIGGERS YOUR EMOTIONS ###\n',
            p.emotional_triggers, '\n\n',
            
            '### YOUR HOT BUTTONS ###\n',
            TO_VARCHAR(p.hot_buttons), '\n\n',
            
            '### HOW YOU''VE REACTED TO SIMILAR SITUATIONS ###\n',
            COALESCE(h.context, 'No similar historical situations recorded.'), '\n\n',
            
            '### THE SCENARIO YOU ARE REACTING TO ###\n',
            p_scenario, '\n\n',
            
            '### INSTRUCTIONS ###\n',
            'React to this scenario AS THIS CUSTOMER. Respond with a JSON object:\n',
            '{\n',
            '  "initial_reaction": "Your immediate gut reaction in 1-2 sentences. Use first person. Be authentic to your character.",\n',
            '  "sentiment_score": <number from -1.0 (very negative/will definitely leave) to 1.0 (very positive/love this)>,\n',
            '  "likely_action": "One of: ACCEPT, IGNORE, COMPLAIN, THREATEN_CHURN, CHURN, UPGRADE, DOWNGRADE",\n',
            '  "action_probability": <0.0 to 1.0 - how likely you are to take this action>,\n',
            '  "reasoning": "2-3 sentences explaining WHY you feel this way based on your background and values",\n',
            '  "what_would_change_mind": "What could Snowmobile do to make you feel differently about this?",\n',
            '  "sample_verbatim": "Exactly what you might say to customer service about this, in quotes, realistic to your character"\n',
            '}\n\n',
            'CRITICAL: Stay in character. Your response must be consistent with your personality, background, and values.\n',
            'Respond ONLY with the JSON object, nothing else.'
         )
         FROM persona_data p, historical_context h)
    )
)
$$;

-- ============================================================================
-- ASK_PERSONA_BY_SEGMENT FUNCTION
-- Query a persona by segment ID
-- ============================================================================

CREATE OR REPLACE FUNCTION AGENTS.ASK_PERSONA_BY_SEGMENT(
    p_segment_id VARCHAR,
    p_scenario TEXT
)
RETURNS VARIANT
LANGUAGE SQL
AS
$$
SELECT AGENTS.ASK_PERSONA(
    (SELECT persona_id FROM PERSONAS.PERSONA_DEFINITIONS WHERE segment_id = p_segment_id LIMIT 1),
    p_scenario
)
$$;

-- ============================================================================
-- SIMULATE_SCENARIO PROCEDURE
-- Run a scenario across all personas and aggregate results
-- ============================================================================

CREATE OR REPLACE PROCEDURE AGENTS.SIMULATE_SCENARIO(
    p_scenario TEXT,
    p_scenario_type VARCHAR DEFAULT 'General',
    p_segment_filter ARRAY DEFAULT NULL
)
RETURNS TABLE (
    segment_id VARCHAR,
    segment_name VARCHAR,
    persona_name VARCHAR,
    customer_count INT,
    pct_of_base DECIMAL(5,2),
    reaction VARIANT,
    sentiment_score DECIMAL(4,2),
    likely_action VARCHAR,
    action_probability DECIMAL(3,2),
    initial_reaction TEXT,
    sample_verbatim TEXT,
    weighted_sentiment DECIMAL(6,4),
    revenue_at_risk DECIMAL(12,2)
)
LANGUAGE SQL
AS
$$
DECLARE
    start_time TIMESTAMP_NTZ := CURRENT_TIMESTAMP();
    simulation_id VARCHAR := UUID_STRING();
    result_table TABLE (
        segment_id VARCHAR,
        segment_name VARCHAR,
        persona_name VARCHAR,
        customer_count INT,
        pct_of_base DECIMAL(5,2),
        reaction VARIANT,
        sentiment_score DECIMAL(4,2),
        likely_action VARCHAR,
        action_probability DECIMAL(3,2),
        initial_reaction TEXT,
        sample_verbatim TEXT,
        weighted_sentiment DECIMAL(6,4),
        revenue_at_risk DECIMAL(12,2)
    );
BEGIN
    -- Run simulation for each persona
    INSERT INTO result_table
    SELECT 
        p.segment_id,
        p.segment_name,
        p.persona_name,
        s.customer_count,
        s.pct_of_base,
        AGENTS.ASK_PERSONA(p.persona_id, p_scenario) AS reaction,
        reaction:sentiment_score::DECIMAL(4,2) AS sentiment_score,
        reaction:likely_action::VARCHAR AS likely_action,
        reaction:action_probability::DECIMAL(3,2) AS action_probability,
        reaction:initial_reaction::TEXT AS initial_reaction,
        reaction:sample_verbatim::TEXT AS sample_verbatim,
        (reaction:sentiment_score::DECIMAL * s.pct_of_base / 100) AS weighted_sentiment,
        CASE 
            WHEN reaction:likely_action IN ('CHURN', 'THREATEN_CHURN', 'DOWNGRADE') 
            THEN s.total_monthly_revenue * reaction:action_probability::DECIMAL * 12
            ELSE 0 
        END AS revenue_at_risk
    FROM PERSONAS.PERSONA_DEFINITIONS p
    JOIN ANALYTICS.SEGMENT_STATISTICS s ON p.segment_id = s.segment_id
    WHERE p_segment_filter IS NULL 
       OR p.segment_id IN (SELECT VALUE FROM TABLE(FLATTEN(p_segment_filter)));
    
    -- Log the simulation
    INSERT INTO AGENTS.SIMULATION_LOGS (
        simulation_id,
        scenario_text,
        scenario_type,
        segments_included,
        total_personas,
        avg_sentiment,
        dominant_action,
        execution_time_seconds,
        results
    )
    SELECT
        simulation_id,
        p_scenario,
        p_scenario_type,
        ARRAY_AGG(segment_id),
        COUNT(*),
        AVG(sentiment_score),
        MODE(likely_action),
        DATEDIFF('second', start_time, CURRENT_TIMESTAMP()),
        OBJECT_AGG(segment_id, reaction)
    FROM result_table;
    
    -- Return results
    RETURN TABLE(SELECT * FROM result_table ORDER BY customer_count DESC);
END;
$$;

-- ============================================================================
-- QUICK_SIMULATE FUNCTION
-- Simplified simulation returning summary
-- ============================================================================

CREATE OR REPLACE FUNCTION AGENTS.QUICK_SIMULATE(
    p_scenario TEXT
)
RETURNS TABLE (
    segment VARCHAR,
    sentiment DECIMAL(4,2),
    action VARCHAR,
    reaction TEXT
)
LANGUAGE SQL
AS
$$
SELECT 
    p.segment_name AS segment,
    reaction:sentiment_score::DECIMAL(4,2) AS sentiment,
    reaction:likely_action::VARCHAR AS action,
    reaction:initial_reaction::VARCHAR AS reaction
FROM PERSONAS.PERSONA_DEFINITIONS p,
     TABLE(RESULT_SCAN(LAST_QUERY_ID())) AS r
WHERE r.segment_id = p.segment_id
ORDER BY 
    (SELECT customer_count FROM ANALYTICS.SEGMENT_STATISTICS s WHERE s.segment_id = p.segment_id) DESC
$$;

-- ============================================================================
-- AGGREGATE_SIMULATION_RESULTS FUNCTION
-- Calculate overall impact metrics from simulation results
-- ============================================================================

CREATE OR REPLACE FUNCTION AGENTS.AGGREGATE_RESULTS(
    simulation_results ARRAY
)
RETURNS VARIANT
LANGUAGE SQL
AS
$$
SELECT OBJECT_CONSTRUCT(
    'overall_sentiment', AVG(r.value:sentiment_score::DECIMAL),
    'weighted_sentiment', SUM(r.value:weighted_sentiment::DECIMAL),
    'total_revenue_at_risk', SUM(r.value:revenue_at_risk::DECIMAL),
    'customers_affected', SUM(r.value:customer_count::INT),
    'action_distribution', OBJECT_CONSTRUCT(
        'ACCEPT', SUM(CASE WHEN r.value:likely_action = 'ACCEPT' THEN r.value:customer_count ELSE 0 END),
        'IGNORE', SUM(CASE WHEN r.value:likely_action = 'IGNORE' THEN r.value:customer_count ELSE 0 END),
        'COMPLAIN', SUM(CASE WHEN r.value:likely_action = 'COMPLAIN' THEN r.value:customer_count ELSE 0 END),
        'THREATEN_CHURN', SUM(CASE WHEN r.value:likely_action = 'THREATEN_CHURN' THEN r.value:customer_count ELSE 0 END),
        'CHURN', SUM(CASE WHEN r.value:likely_action = 'CHURN' THEN r.value:customer_count ELSE 0 END)
    ),
    'most_negative_segment', (
        SELECT r2.value:segment_name 
        FROM TABLE(FLATTEN(simulation_results)) r2 
        ORDER BY r2.value:sentiment_score ASC 
        LIMIT 1
    ),
    'most_positive_segment', (
        SELECT r2.value:segment_name 
        FROM TABLE(FLATTEN(simulation_results)) r2 
        ORDER BY r2.value:sentiment_score DESC 
        LIMIT 1
    )
)
FROM TABLE(FLATTEN(simulation_results)) r
$$;

-- ============================================================================
-- SCENARIO TEMPLATES
-- Pre-built scenario templates for common use cases
-- ============================================================================

CREATE OR REPLACE TABLE AGENTS.SCENARIO_TEMPLATES (
    template_id VARCHAR(36) DEFAULT UUID_STRING() PRIMARY KEY,
    template_name VARCHAR(100),
    template_category VARCHAR(50),
    template_text TEXT,
    parameters VARIANT,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

INSERT INTO AGENTS.SCENARIO_TEMPLATES (template_name, template_category, template_text, parameters) VALUES
-- Price Changes
('Price Increase - Basic', 'Pricing', 
 'Snowmobile Wireless is announcing a ${amount}/month price increase on {plan_names} plans, effective {effective_date}. The increase is due to {reason}. {value_add_statement} Customers will receive 30 days notice via email and app notification.',
 PARSE_JSON('{"amount": "$5", "plan_names": "all postpaid", "effective_date": "April 1, 2025", "reason": "inflation and network investment costs", "value_add_statement": ""}')),

('Price Increase with Value Add', 'Pricing',
 'Snowmobile Wireless is announcing a ${amount}/month price increase on {plan_names} plans, effective {effective_date}. To offset this increase, all affected customers will receive {value_add} (${value_add_worth} value) included at no extra cost.',
 PARSE_JSON('{"amount": "$5", "plan_names": "Blizzard Unlimited", "effective_date": "March 1, 2025", "value_add": "Disney+ Basic subscription", "value_add_worth": "$8"}')),

-- Product Launches
('New Plan Launch', 'Product',
 'Snowmobile Wireless is launching {plan_name}, a new {plan_category} plan. Key features include: {features}. Price: ${price}/month. Available starting {launch_date}. Promotional offer: {promo}.',
 PARSE_JSON('{"plan_name": "Blizzard Ultra", "plan_category": "premium unlimited", "features": "unlimited premium data, 100GB hotspot, international texting included", "price": "85", "launch_date": "February 15, 2025", "promo": "First 3 months at $65/month"}')),

('Streaming Bundle Launch', 'Product',
 'Snowmobile Wireless is launching {bundle_name}, a new streaming bundle for {eligible_plans} customers. Includes: {services}. Price: ${price}/month added to your plan, or {free_statement}.',
 PARSE_JSON('{"bundle_name": "Peak Entertainment Max", "eligible_plans": "Summit and Blizzard", "services": "Netflix Standard, Disney+, Hulu", "price": "20", "free_statement": "FREE for Summit customers"}')),

-- Policy Changes
('Data Policy Change', 'Policy',
 'Snowmobile Wireless is updating its {policy_area} policy. Current policy: {current_policy}. New policy: {new_policy}. Reason for change: {reason}. Effective: {effective_date}.',
 PARSE_JSON('{"policy_area": "unlimited data fair use", "current_policy": "Deprioritization after 50GB", "new_policy": "Deprioritization after 35GB during network congestion", "reason": "Network optimization for all customers", "effective_date": "March 1, 2025"}')),

-- Competitor Response
('Competitor Offer Response', 'Competitive',
 '{competitor} has announced {competitor_offer}. Key details: {offer_details}. Their price point: ${competitor_price}/month. This directly competes with our {affected_plans} plans. How do you feel about this competitor offer and does it change how you view Snowmobile?',
 PARSE_JSON('{"competitor": "T-Mobile", "competitor_offer": "a new unlimited plan with free Netflix", "offer_details": "Unlimited 5G data, free Netflix Standard, $200 bring-your-own-phone credit", "competitor_price": "65", "affected_plans": "Blizzard and Summit"}')),

-- Retention
('Loyalty Reward', 'Retention',
 'Thank you for being a Snowmobile customer for {tenure}! As a valued customer, we''re offering you {offer}. This offer is valid until {expiry_date}. To accept, simply {action}.',
 PARSE_JSON('{"tenure": "over 2 years", "offer": "a free upgrade to our Summit plan for 6 months ($120 value)", "expiry_date": "end of this month", "action": "reply YES to this message or tap Accept in the app"}')),

-- Service Issues
('Network Outage Communication', 'Service',
 'We experienced a network outage in {affected_area} on {date} from {start_time} to {end_time}. We understand this impacted your service and apologize. As a gesture of goodwill, we''re {compensation}.',
 PARSE_JSON('{"affected_area": "the greater Phoenix metro area", "date": "January 15", "start_time": "2 PM", "end_time": "6 PM", "compensation": "crediting $10 to your next bill automatically"}'));

-- ============================================================================
-- GENERATE_SCENARIO FUNCTION
-- Create scenario from template
-- ============================================================================

CREATE OR REPLACE FUNCTION AGENTS.GENERATE_SCENARIO(
    p_template_id VARCHAR,
    p_parameters VARIANT
)
RETURNS TEXT
LANGUAGE SQL
AS
$$
SELECT REGEXP_REPLACE(
    template_text,
    '\\{([^}]+)\\}',
    COALESCE(p_parameters[$1]::VARCHAR, parameters[$1]::VARCHAR, '{' || $1 || '}')
)
FROM AGENTS.SCENARIO_TEMPLATES
WHERE template_id = p_template_id
$$;

-- ============================================================================
-- GRANTS
-- ============================================================================

GRANT USAGE ON FUNCTION AGENTS.ASK_PERSONA(VARCHAR, TEXT) TO ROLE CDT_ANALYST;
GRANT USAGE ON FUNCTION AGENTS.ASK_PERSONA(VARCHAR, TEXT) TO ROLE CDT_APP_ROLE;

GRANT USAGE ON FUNCTION AGENTS.ASK_PERSONA_BY_SEGMENT(VARCHAR, TEXT) TO ROLE CDT_ANALYST;
GRANT USAGE ON FUNCTION AGENTS.ASK_PERSONA_BY_SEGMENT(VARCHAR, TEXT) TO ROLE CDT_APP_ROLE;

GRANT USAGE ON PROCEDURE AGENTS.SIMULATE_SCENARIO(TEXT, VARCHAR, ARRAY) TO ROLE CDT_ANALYST;
GRANT USAGE ON PROCEDURE AGENTS.SIMULATE_SCENARIO(TEXT, VARCHAR, ARRAY) TO ROLE CDT_APP_ROLE;

GRANT SELECT ON TABLE AGENTS.SCENARIO_TEMPLATES TO ROLE CDT_ANALYST;
GRANT SELECT ON TABLE AGENTS.SCENARIO_TEMPLATES TO ROLE CDT_APP_ROLE;

GRANT SELECT ON TABLE AGENTS.SIMULATION_LOGS TO ROLE CDT_ANALYST;
GRANT SELECT ON TABLE AGENTS.SIMULATION_LOGS TO ROLE CDT_APP_ROLE;

-- ============================================================================
-- VERIFICATION
-- ============================================================================

-- Test ASK_PERSONA function (example)
/*
SELECT AGENTS.ASK_PERSONA(
    (SELECT persona_id FROM PERSONAS.PERSONA_DEFINITIONS WHERE segment_id = 'S1'),
    'Snowmobile is raising prices by $5/month on all plans. No additional value is being added.'
) AS value_seeker_reaction;
*/

-- List available functions
SHOW FUNCTIONS IN SCHEMA AGENTS;

-- List scenario templates
SELECT template_name, template_category FROM AGENTS.SCENARIO_TEMPLATES;

SELECT 'Agent functions created successfully!' AS status;


