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
-- INSERT INITIAL PERSONAS (Manual for reliability)
-- ============================================================================

-- Clear existing personas
TRUNCATE TABLE PERSONAS.PERSONA_DEFINITIONS;

-- Insert pre-crafted personas based on segment profiles
INSERT INTO PERSONAS.PERSONA_DEFINITIONS (
    segment_id, segment_name, persona_name, persona_age, persona_location, persona_tagline,
    typical_age_range, typical_gender_dist, typical_income_range, typical_household, typical_geography,
    typical_plan, typical_contract, typical_tenure, typical_arpu, typical_device,
    background_story, personality_description, relationship_with_service, financial_mindset,
    communication_style, decision_making_style, emotional_triggers,
    hot_buttons, sample_quotes
)
VALUES
-- S1: Value Seekers
('S1', 'Value Seekers', 'Carlos Mendez', 34, 'Phoenix, AZ', 
 'The budget-conscious deal hunter who refuses to pay a dollar more than necessary',
 '25-45', '52% M, 48% F', '$35,000-$55,000', 'Single or roommates, renting', 'Urban/Suburban',
 'Glacier', 'No Contract', '8-14 months', 38.00, 'Samsung Galaxy A54',
 'Carlos works as a warehouse supervisor in Phoenix and shares an apartment with a roommate. He switched to Snowmobile 10 months ago after seeing a prepaid promotion on Facebook. Before that, he bounced between Cricket and Metro depending on who had the best deal. He keeps a close eye on his budget and uses Google Sheets to track all his monthly expenses. His phone is essential for work communication and streaming music during his commute, but he refuses to pay for what he considers "premium features" he won''t use.',
 'Carlos is practical, skeptical of marketing claims, and always looking for the catch in any offer. He values transparency and gets frustrated by hidden fees or complicated pricing. He''s not anti-technology but doesn''t feel the need to have the latest and greatest. He''ll do significant research before any purchase decision.',
 'Mobile service is a utility to Carlos - necessary but shouldn''t be expensive. He uses his phone for calls, texts, music streaming, and occasional GPS navigation. He rarely uses more than 5GB of data because he''s careful to use WiFi whenever available. He checked the Snowmobile app once to see his usage but prefers to just set up autopay and forget about it unless there''s a problem.',
 'Carlos sets strict limits on his phone bill - anything over $35/month feels like too much. He compares prices constantly and has a spreadsheet of competitor offers. When Snowmobile raised prices last year, he immediately called to complain and threatened to leave. He''s loyal only to whoever gives him the best deal.',
 'Carlos prefers to handle everything through chat or the app - he hates waiting on hold. When frustrated, he''s direct and to the point. He''ll leave negative reviews if he feels wronged but will also give credit when deserved. His tone is matter-of-fact, not emotional.',
 'Carlos researches extensively before making changes. He''ll spend hours comparing plans across carriers. He trusts online reviews and Reddit threads more than company marketing. Decisions can take weeks as he waits for better offers.',
 'Price increases without value, hidden fees, feeling like he''s being taken advantage of, seeing competitors offer better deals',
 PARSE_JSON('{"happy": ["Getting a lower price than expected", "Clear and simple pricing", "Bill credits for issues"], "angry": ["Any price increase", "Hidden fees or surprise charges", "Slow customer service"], "ignores": ["5G marketing", "Premium features", "Device upgrade offers"]}'),
 PARSE_JSON('{"satisfied": "The price is right and I get what I need. No complaints.", "frustrated": "Why is my bill higher this month? I didn''t change anything. This is exactly why I left AT&T.", "considering_change": "Metro has a $25 plan now. What can you offer me to stay?"}')),

-- S2: Data Streamers
('S2', 'Data Streamers', 'Jordan Chen', 28, 'Austin, TX',
 'The content-obsessed streamer who treats unlimited data as a basic human right',
 '22-35', '55% M, 45% F', '$60,000-$90,000', 'Single, apartment dweller', 'Urban',
 'Blizzard', '24 Month Device', '18-24 months', 72.00, 'iPhone 15 Pro',
 'Jordan is a UX designer at a tech startup in Austin. They work hybrid but spend significant time at coffee shops and coworking spaces. They chose Snowmobile because a coworker recommended it for streaming quality on 5G. Jordan uses their phone constantly - for work Slack messages, streaming Spotify and podcasts, watching YouTube and TikTok, and video calls with friends. They went through 45GB last month without even trying. Their phone is essentially an extension of their personality.',
 'Jordan is tech-forward, socially connected, and values experiences over things (except their phone). They''re early adopters who will try new features and apps immediately. They appreciate good design and get frustrated by clunky interfaces. They''re comfortable with digital everything and rarely step into physical stores.',
 'Mobile connectivity is essential to Jordan''s identity and lifestyle. They chose the Blizzard unlimited plan specifically to never worry about data caps. The Snowmobile app is on their home screen and they check it occasionally to see their 5G usage stats. They genuinely enjoy having fast reliable data everywhere they go.',
 'Jordan doesn''t mind paying $75/month because the service delivers. They view it as reasonable for unlimited everything. A price increase with added streaming benefits would be acceptable. They''d only leave if data performance degraded significantly or a competitor offered dramatically better value.',
 'Jordan handles everything through the app and chat. They''ve never called customer service and hope to never need to. They''re concise in written communication and expect quick responses. If frustrated, they might post about it on social media.',
 'Jordan makes decisions quickly based on tech reviews and friend recommendations. They trust brands that align with their values. Price is a factor but not the primary one - experience matters more.',
 'Slow data speeds, being throttled, app crashes, outdated technology, falling behind competitors on features',
 PARSE_JSON('{"happy": ["Fast 5G everywhere", "Streaming bundles included", "Easy-to-use app"], "angry": ["Data throttling", "Network congestion", "Outdated app features"], "ignores": ["Voice minute counts", "Store promotions", "Traditional advertising"]}'),
 PARSE_JSON('{"satisfied": "5G speeds are actually incredible. Streaming never buffers. Worth every penny.", "frustrated": "Why am I getting throttled in downtown Austin? I pay for unlimited. This is not acceptable.", "considering_change": "Heard Verizon has better 5G coverage here. Might check them out if this keeps happening."}')),

-- S3: Family Connectors
('S3', 'Family Connectors', 'Michelle Torres', 41, 'Gilbert, AZ',
 'The family''s wireless lifeline who keeps everyone connected without breaking the bank',
 '35-50', '55% F, 45% M', '$85,000-$120,000', 'Married with children, homeowner', 'Suburban',
 'Avalanche', '24 Month', '24-36 months', 125.00, 'iPhone 14/Samsung Galaxy S23',
 'Michelle is a project manager at a healthcare company in the Phoenix suburbs. She''s married with three kids (15, 12, and 8) and manages all household technology and bills. She switched the family to Snowmobile two years ago for the Avalanche family plan after their previous carrier kept raising prices. She oversees four phone lines plus a tablet, constantly juggling her teenagers'' data usage while trying to keep the monthly bill predictable. Her husband travels for work and relies on good coverage.',
 'Michelle is organized, practical, and protective of her family and budget. She''s the household CEO who researches purchases thoroughly but values time efficiency. She''s moderately tech-savvy - enough to troubleshoot basic issues but doesn''t want to spend hours on technical problems. She values reliability and hates surprises on her bill.',
 'Michelle views wireless as essential household infrastructure. She monitors her kids'' usage through the app and has set up parental controls. The app is her primary interface with Snowmobile - she checks bills, adds data when needed, and manages family settings. She appreciates that she can handle most things without calling.',
 'Michelle budgets $150/month for wireless and gets concerned if it exceeds $175. She evaluates price increases based on whether value is added - pure increases feel unfair. The total family value matters more than per-line cost. She''d consider leaving if a competitor offered significantly better family value.',
 'Michelle prefers app and chat - they''re quick and documented. She avoids phone calls because they take too long. Her tone is direct and practical. When frustrated, she''s firm but not aggressive and will escalate if not resolved promptly.',
 'Michelle evaluates offers based on total family impact. She''ll discuss major decisions with her husband but typically drives the final choice. She makes decisions within a week once she has the information she needs.',
 'Surprise charges, coverage gaps during family travel, kids complaining about data limits, complicated family management',
 PARSE_JSON('{"happy": ["Family perks like Disney+", "Easy parental controls", "Bill credits for outages"], "angry": ["Unexpected bill increases", "Coverage problems on vacation", "Complicated family management"], "ignores": ["5G speed marketing", "Individual upgrade offers", "Technical jargon"]}'),
 PARSE_JSON('{"satisfied": "The family plan actually makes sense for us. Managing four lines through the app is pretty easy.", "frustrated": "Why did my bill jump $25 this month? I haven''t changed anything. This is exactly why we left Verizon.", "considering_change": "My neighbor says T-Mobile is $40 cheaper for families. Is there anything you can offer us?"}')),

-- S4: Steady Loyalists
('S4', 'Steady Loyalists', 'Robert Patterson', 62, 'Columbus, OH',
 'The long-term customer who values what works and isn''t looking for change',
 '50-70', '52% M, 48% F', '$55,000-$75,000', 'Empty nesters or married couple', 'Suburban/Rural',
 'Powder', 'No Contract', '60+ months', 52.00, 'iPhone 12/Samsung Galaxy S21',
 'Robert retired last year from a manufacturing company where he worked for 30 years. He''s been with Snowmobile (and its predecessor before the merger) for over 7 years. He and his wife Barbara have two lines on a simple plan. Robert uses his phone primarily for calls to family, occasional texts, and looking up information. He upgraded to a smartphone five years ago at his daughter''s insistence and has gotten comfortable with the basics.',
 'Robert values reliability, simplicity, and doing business with companies he trusts. He''s not opposed to technology but doesn''t chase new features. He appreciates consistency and gets frustrated when things change unnecessarily. Once he finds something that works, he sticks with it.',
 'Mobile service is a communication tool for Robert - important but not central to his identity. He calls his kids and grandkids, texts occasionally, and uses GPS when traveling. He''s learned to use the basics of his smartphone but prefers calling customer service over using apps. He appreciates that his phone just works.',
 'Robert has paid roughly $50/month for years and considers it fair. Small price increases ($2-3) are acceptable if explained. He values the relationship and wouldn''t leave over minor issues. However, dramatic changes to his plan or service would shake his loyalty.',
 'Robert prefers calling customer service - he likes talking to a real person. He''s polite but persistent if he has an issue. He visits the local store occasionally and appreciates face-to-face service. Email and app communication feel impersonal to him.',
 'Robert deliberates on decisions and discusses with Barbara. He trusts personal recommendations over advertising. Major changes (like switching carriers) would take months of consideration. He values input from his adult children.',
 'Forced changes to his plan, app redesigns that confuse him, feeling like a number instead of a valued customer, losing local store access',
 PARSE_JSON('{"happy": ["Recognition of loyalty", "Consistent reliable service", "Human customer service"], "angry": ["Forced plan changes", "Confusing new app interfaces", "Feeling undervalued"], "ignores": ["5G promotion", "New features marketing", "Social media campaigns"]}'),
 PARSE_JSON('{"satisfied": "Been with you folks for years and no major problems. That counts for something.", "frustrated": "Why did you change the app again? I finally learned how to use the old one. Just leave things alone.", "considering_change": "After all these years, I never thought I''d consider leaving. But if you keep making changes, maybe it''s time."}')),

-- S5: Premium Techies
('S5', 'Premium Techies', 'Priya Sharma', 35, 'San Jose, CA',
 'The tech enthusiast who expects the best and is willing to pay for it',
 '28-45', '58% M, 42% F', '$130,000-$200,000', 'Single or DINK couple', 'Urban',
 'Summit', '24 Month Device', '18-30 months', 95.00, 'iPhone 15 Pro Max',
 'Priya is a senior software engineer at a major tech company in Silicon Valley. She chose Snowmobile specifically for their Summit plan and the data-focused brand messaging that resonated with her. She upgrades her phone annually and expects her carrier to match her tech-forward lifestyle. She signed up for the beta testing program and actively provides feedback on new features. Her phone is her primary computing device outside of work.',
 'Priya is analytical, quality-focused, and expects premium experiences. She''s an early adopter who reads tech blogs and follows industry news. She values efficiency and innovative features. She''s willing to pay more for better quality but has high expectations in return.',
 'Mobile connectivity is seamlessly integrated into Priya''s life. She uses her phone for everything - smart home control, mobile payments, health tracking, navigation, communication. She evaluates carriers like she evaluates tech products - features, performance, and innovation matter. She uses the Snowmobile app regularly and appreciates well-designed interfaces.',
 'Priya views $95/month as reasonable for premium service. Price increases are acceptable if paired with genuine improvements. She''d pay more for exclusive features or early access. Value means getting the latest technology and best performance, not lowest price.',
 'Priya handles everything digitally and expects instant responses. She''s comfortable with self-service but expects premium support when needed. Her communication is precise and solution-oriented. She provides constructive feedback and expects it to be valued.',
 'Priya makes decisions based on research and technical evaluation. She reads reviews from trusted tech sources. She''s influenced by what other tech professionals use. Decisions are quick once she''s convinced of the value.',
 'Being behind other carriers on features, network performance issues, beta features not shipping, feeling like just another customer',
 PARSE_JSON('{"happy": ["Early access to new features", "Best-in-class network performance", "Premium support experience"], "angry": ["Technical issues or downtime", "Falling behind competitors", "Generic customer treatment"], "ignores": ["Price-focused messaging", "Basic plan offers", "Non-tech promotions"]}'),
 PARSE_JSON('{"satisfied": "The Summit plan delivers. Beta features are actually innovative. This is why I chose Snowmobile.", "frustrated": "Why is Verizon getting this feature before us? I pay premium specifically to be first.", "considering_change": "If T-Mobile keeps out-innovating you on 5G, I might have to switch despite everything."}')),

-- S6: Rural Reliables
('S6', 'Rural Reliables', 'Wayne Thompson', 54, 'Billings, MT',
 'The rural customer whose biggest ask is a signal where he needs it',
 '40-65', '54% M, 46% F', '$50,000-$70,000', 'Married, homeowner', 'Rural',
 'Powder', 'No Contract', '36-48 months', 48.00, 'Samsung Galaxy A34',
 'Wayne owns a small cattle ranch outside Billings. He''s been with Snowmobile for 4 years since they expanded coverage in his area - before that, he had to drive 20 minutes to get a reliable signal. His wife Linda is also on the plan. Wayne uses his phone primarily for calls, weather apps, and occasionally looking up equipment information. Coverage on his property and along the rural highways he drives is non-negotiable.',
 'Wayne is pragmatic, straightforward, and community-oriented. He values companies that invest in rural America. He''s patient with limitations but expects honesty about coverage. He maintains personal relationships with local businesses and expects the same from his carrier.',
 'Mobile service is a safety and business tool for Wayne. He needs to be reachable for ranch operations and emergencies. He appreciates that he can now get service on most of his property. He uses the store in Billings when he needs help and prefers that to apps. Voice calls matter more than data.',
 'Wayne considers $48/month fair for rural coverage. He understands rural service costs more to provide. Price increases are acceptable if coverage continues improving. He''d only leave if service degraded or a competitor offered better rural coverage.',
 'Wayne prefers the local store or phone calls. He values personal relationships with staff who understand rural needs. He''s patient but direct when there are issues. He appreciates when companies remember rural customers exist.',
 'Wayne makes decisions based on practical needs and local recommendations. His ranching neighbors'' experiences matter. He''s loyal once trust is established. Major decisions are discussed with Linda.',
 'Coverage gaps, being deprioritized versus urban customers, losing local store, companies that forget rural America',
 PARSE_JSON('{"happy": ["Coverage improvements in rural areas", "Local store with knowledgeable staff", "Reliable service during emergencies"], "angry": ["Coverage gaps on his property", "Being told to use WiFi calling", "City-focused marketing"], "ignores": ["Streaming bundles", "5G speed marketing", "App-only promotions"]}'),
 PARSE_JSON('{"satisfied": "You''re the only carrier that works at my ranch. That means everything.", "frustrated": "Lost signal again at the north pasture. You said the tower upgrade would fix this.", "considering_change": "Heard US Cellular is expanding out here. Might check their coverage if yours doesn''t improve."}')),

-- S7: Young Digitals
('S7', 'Young Digitals', 'Zoe Williams', 23, 'Denver, CO',
 'The social-first Gen Z customer whose phone is their portal to the world',
 '18-28', '50% F, 50% M', '$35,000-$55,000', 'Single, roommates or parents', 'Urban',
 'Powder', 'No Contract', '6-18 months', 55.00, 'iPhone 14',
 'Zoe graduated from CU Boulder last year and works as a social media coordinator for a local brewery. She''s on her own phone plan for the first time after being on her parents'' family plan. She chose Snowmobile because she saw a TikTok about their brand and liked the vibe. She''s already considering whether to switch when her 6-month promotion ends. Her phone is her life - social media, dating apps, music, everything.',
 'Zoe is social, trend-aware, and values authenticity. She makes decisions quickly based on vibes and peer influence. Brand loyalty is low - she''ll switch for a better deal or cooler brand. She''s highly connected digitally but craves genuine experiences. FOMO is real.',
 'Zoe''s phone is literally her world - average 8+ hours screen time daily. She uses TikTok, Instagram, Spotify, and various chat apps constantly. Data is more important than voice - she FaceTimes instead of calling. She chose based on social proof and will leave based on social proof. The app better look good.',
 'Zoe budgets tightly and $55/month feels like a lot. She''s constantly aware of what friends pay and competitor promotions. She''ll switch for $15/month savings without hesitation. Price increases would trigger immediate competitor research.',
 'Zoe uses chat exclusively and expects instant responses. She''d never call customer service by choice. She might post about bad experiences on social media. Her tone is casual and she uses emojis. She expects brands to communicate like humans.',
 'Zoe makes decisions fast based on peer recommendations and social proof. TikTok reviews and Reddit threads are trusted sources. Brand aesthetics and values matter. She might switch on a whim if something better comes along.',
 'Higher prices than friends pay, FOMO on competitor deals, outdated or corporate brand image, slow customer service',
 PARSE_JSON('{"happy": ["Influencer collaborations and promo codes", "Trendy brand image", "Fast chat support"], "angry": ["Paying more than friends", "Missing competitor deals", "Slow or robotic service"], "ignores": ["Traditional advertising", "Voice plan features", "Long-term contract benefits"]}'),
 PARSE_JSON('{"satisfied": "The vibe is right and my friends have it. Plus that TikTok promo was fire.", "frustrated": "Wait my friend pays $20 less? That''s not fair. Why am I paying more?", "considering_change": "Mint Mobile has this hilarious ad and it''s literally half the price. Might switch tbh."}')),

-- S8: At-Risk Defectors
('S8', 'At-Risk Defectors', 'David Kim', 39, 'Atlanta, GA',
 'The frustrated customer on the edge of leaving who just needs a reason to stay',
 '30-55', '50% M, 50% F', '$60,000-$85,000', 'Various', 'Various',
 'Powder', 'Month to Month', '24+ months', 45.00, 'Various',
 'David has been with Snowmobile for 3 years but the relationship has soured over the past 6 months. It started with a billing error that took three calls to resolve. Then there were network issues near his new apartment. His work-from-home setup suffers from spotty coverage. He''s been researching T-Mobile and Verizon and has even visited competitor stores. He hasn''t switched yet but he''s close.',
 'David is reasonable but feels unheard. His frustration has built over multiple unresolved issues. He''s not inherently disloyal - he stayed for 3 years - but trust is broken. He needs to feel valued and have his problems genuinely solved. He''s willing to give one more chance but skeptical.',
 'Mobile service has become a source of stress for David rather than convenience. He''s hyperaware of network issues that he might have ignored before. He dreads interacting with customer service. He still uses the phone for work but is emotionally checked out from the Snowmobile brand.',
 'David''s frustration isn''t primarily about price - it''s about value received. He''d pay more for service that actually works. At this point, a competitor could win him with similar pricing and a fresh start. Retention offers feel hollow without addressing root issues.',
 'David has tried multiple channels and found all of them lacking. He''s documented his issues and references past ticket numbers. His tone starts controlled but escalates when issues aren''t resolved. He''s told friends about his negative experiences.',
 'David is in active evaluation mode. He''s comparing options rationally but emotional factors (frustration, distrust) weigh heavily. A genuine save attempt with real problem resolution could work. Generic retention offers will fail.',
 'Feeling unheard, issues not getting resolved, generic retention scripts, being treated like a statistic',
 PARSE_JSON('{"happy": ["Proactive outreach acknowledging issues", "Real solutions not band-aids", "Genuine apology from leadership"], "angry": ["Scripted retention offers", "Having to re-explain issues", "Empty promises"], "ignores": ["Marketing messages", "Upgrade offers", "Promotional emails"]}'),
 PARSE_JSON('{"satisfied": "If you had fixed this months ago, we wouldn''t be having this conversation.", "frustrated": "I''ve called three times about this. Every time I have to start from scratch. Nobody seems to care.", "considering_change": "I''ve already been to the T-Mobile store. They were actually helpful. What can you do that they can''t?"}'));

-- ============================================================================
-- VERIFICATION
-- ============================================================================

-- Check personas created
SELECT 
    persona_id,
    segment_id,
    segment_name,
    persona_name,
    persona_age,
    persona_location
FROM PERSONAS.PERSONA_DEFINITIONS
ORDER BY segment_id;

-- Check historical reactions
SELECT segment_id, COUNT(*) AS reaction_count
FROM PERSONAS.HISTORICAL_REACTIONS
GROUP BY segment_id
ORDER BY segment_id;

SELECT 'Persona generation complete!' AS status;


