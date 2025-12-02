# Snowmobile Wireless - Customer Digital Twin
## Technical Architecture Document

**Version**: 1.0  
**Last Updated**: December 2024  
**Author**: Data Engineering Team

---

## 1. System Architecture Overview

### 1.1 High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           SNOWFLAKE ENVIRONMENT                              │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                         DATA LAYER                                   │   │
│  │  ┌───────────────┐  ┌───────────────┐  ┌───────────────┐           │   │
│  │  │   RAW Schema  │  │EXTERNAL Schema│  │ANALYTICS      │           │   │
│  │  │   (Internal)  │  │ (3rd Party)   │  │Schema         │           │   │
│  │  │               │  │               │  │               │           │   │
│  │  │ • Customers   │  │ • ZIP_Demo    │  │ • Features    │           │   │
│  │  │ • Usage       │  │ • Economic    │  │ • Segments    │           │   │
│  │  │ • Interactions│  │ • Competitive │  │ • Statistics  │           │   │
│  │  │ • Campaigns   │  │ • Lifestyle   │  │               │           │   │
│  │  └───────────────┘  └───────────────┘  └───────────────┘           │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                      │                                      │
│                                      ▼                                      │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                      ML & AI LAYER                                   │   │
│  │  ┌───────────────────┐  ┌───────────────────┐                       │   │
│  │  │   Snowflake ML    │  │  Snowflake Cortex │                       │   │
│  │  │                   │  │                   │                       │   │
│  │  │ • K-Means         │  │ • COMPLETE        │                       │   │
│  │  │ • Feature Scaling │  │ • EMBED_TEXT      │                       │   │
│  │  │ • Classification  │  │ • Cortex Search   │                       │   │
│  │  └───────────────────┘  └───────────────────┘                       │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                      │                                      │
│                                      ▼                                      │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                    PERSONA & AGENT LAYER                             │   │
│  │  ┌───────────────┐  ┌───────────────┐  ┌───────────────┐           │   │
│  │  │   PERSONAS    │  │    AGENTS     │  │   HISTORY     │           │   │
│  │  │   Schema      │  │   Schema      │  │   Schema      │           │   │
│  │  │               │  │               │  │               │           │   │
│  │  │ • Definitions │  │ • Functions   │  │ • Reactions   │           │   │
│  │  │ • Profiles    │  │ • Orchestrator│  │ • Simulations │           │   │
│  │  │ • Embeddings  │  │ • Aggregator  │  │ • Feedback    │           │   │
│  │  └───────────────┘  └───────────────┘  └───────────────┘           │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                      │                                      │
│                                      ▼                                      │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                    PRESENTATION LAYER                                │   │
│  │  ┌───────────────────────────────────────────────────────────────┐  │   │
│  │  │              Streamlit in Snowflake                            │  │   │
│  │  │  • Segment Explorer  • Persona Gallery  • Simulation Studio   │  │   │
│  │  │  • Campaign Tester   • Historical Analysis                    │  │   │
│  │  └───────────────────────────────────────────────────────────────┘  │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 1.2 Component Summary

| Layer | Components | Purpose |
|-------|------------|---------|
| **Data Layer** | RAW, EXTERNAL, ANALYTICS schemas | Store and organize all data |
| **ML Layer** | Snowflake ML, Cortex AI | Segmentation, persona generation |
| **Agent Layer** | PERSONAS, AGENTS, HISTORY schemas | Manage personas and simulations |
| **Presentation** | Streamlit in Snowflake | User interface |

---

## 2. Database Architecture

### 2.1 Database and Schema Structure

```sql
Database: SNOWMOBILE_DIGITAL_TWIN
│
├── Schema: RAW                    -- Internal/1st party data
│   ├── CUSTOMERS                  -- Customer master (1M records)
│   ├── MONTHLY_USAGE              -- Usage/billing history (12M records)
│   ├── SUPPORT_INTERACTIONS       -- Support tickets (2M records)
│   └── CAMPAIGN_RESPONSES         -- Campaign history (5M records)
│
├── Schema: EXTERNAL               -- External/3rd party data
│   ├── ZIP_DEMOGRAPHICS           -- Census data by ZIP (42K records)
│   ├── ECONOMIC_INDICATORS        -- Economic metrics by ZIP (42K records)
│   ├── COMPETITIVE_LANDSCAPE      -- Competitor data by DMA (210 records)
│   └── LIFESTYLE_SEGMENTS         -- Psychographics by ZIP (42K records)
│
├── Schema: ANALYTICS              -- Derived analytics
│   ├── CUSTOMER_USAGE_SUMMARY     -- Aggregated usage metrics
│   ├── CUSTOMER_INTERACTION_SUMMARY -- Aggregated interaction metrics
│   ├── CUSTOMER_FEATURES_ENRICHED -- Full feature set for ML
│   ├── CUSTOMER_SEGMENTS          -- Segment assignments
│   └── SEGMENT_STATISTICS         -- Segment-level aggregations
│
├── Schema: PERSONAS               -- Persona definitions
│   ├── PERSONA_DEFINITIONS        -- LLM-generated personas
│   ├── PERSONA_PROFILES           -- Structured persona attributes
│   ├── HISTORICAL_REACTIONS       -- Past event reactions for RAG
│   └── PERSONA_EMBEDDINGS         -- Vector embeddings for search
│
├── Schema: AGENTS                 -- Agent functions and logs
│   ├── Functions/Procedures
│   │   ├── ASK_PERSONA()          -- Query single persona
│   │   ├── SIMULATE_SCENARIO()    -- Multi-agent simulation
│   │   └── AGGREGATE_REACTIONS()  -- Combine persona responses
│   └── SIMULATION_LOGS            -- Audit trail of simulations
│
└── Schema: APP                    -- Application objects
    └── Streamlit App
```

### 2.2 Warehouse Configuration

| Warehouse | Size | Purpose | Auto-Suspend |
|-----------|------|---------|--------------|
| `CDT_LOAD_WH` | MEDIUM | Data loading, ETL | 300 seconds |
| `CDT_ML_WH` | LARGE | ML training, clustering | 300 seconds |
| `CDT_CORTEX_WH` | MEDIUM | Cortex LLM calls | 300 seconds |
| `CDT_APP_WH` | X-SMALL | Streamlit app | 60 seconds |

---

## 3. Data Model Specifications

### 3.1 Internal Data Tables

#### RAW.CUSTOMERS

```sql
CREATE OR REPLACE TABLE RAW.CUSTOMERS (
    -- Identity
    customer_id             VARCHAR(36) PRIMARY KEY,
    account_id              VARCHAR(20),
    
    -- Location (links to external data)
    zip_code                VARCHAR(5),
    state_code              VARCHAR(2),
    dma_code                VARCHAR(3),
    
    -- Demographics
    age                     INT,
    gender                  VARCHAR(10),
    
    -- Account Details
    customer_since          DATE,
    tenure_months           INT,
    acquisition_channel     VARCHAR(30),
    
    -- Current Plan
    plan_name               VARCHAR(30),
    plan_category           VARCHAR(20),
    plan_price              DECIMAL(6,2),
    lines_on_account        INT,
    contract_type           VARCHAR(20),
    contract_end_date       DATE,
    
    -- Device
    device_brand            VARCHAR(30),
    device_model            VARCHAR(50),
    device_tier             VARCHAR(20),
    device_os               VARCHAR(20),
    device_age_months       INT,
    is_5g_capable           BOOLEAN,
    
    -- Financial
    monthly_arpu            DECIMAL(8,2),
    lifetime_value          DECIMAL(10,2),
    total_revenue_12m       DECIMAL(10,2),
    payment_method          VARCHAR(20),
    autopay_enrolled        BOOLEAN,
    paperless_billing       BOOLEAN,
    credit_class            VARCHAR(10),
    
    -- Add-Ons
    has_device_protection   BOOLEAN,
    has_intl_roaming        BOOLEAN,
    has_streaming_bundle    BOOLEAN,
    
    -- Loyalty
    rewards_member          BOOLEAN,
    rewards_tier            VARCHAR(20),
    rewards_points_balance  INT,
    
    -- Engagement
    app_user                BOOLEAN,
    app_engagement_score    DECIMAL(3,2),
    last_app_login          DATE,
    nps_score               INT,
    nps_survey_date         DATE,
    
    -- Risk Indicators
    churn_risk_score        DECIMAL(3,2),
    predicted_churn_reason  VARCHAR(50),
    complaint_count_12m     INT,
    
    -- Timestamps
    created_at              TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at              TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);
```

#### RAW.MONTHLY_USAGE

```sql
CREATE OR REPLACE TABLE RAW.MONTHLY_USAGE (
    usage_id                VARCHAR(36) PRIMARY KEY,
    customer_id             VARCHAR(36) REFERENCES RAW.CUSTOMERS(customer_id),
    billing_month           DATE,
    
    -- Voice
    voice_minutes_onnet     INT,
    voice_minutes_offnet    INT,
    voice_minutes_intl      INT,
    voice_calls_count       INT,
    
    -- Data
    data_usage_gb           DECIMAL(10,3),
    data_usage_4g_pct       DECIMAL(5,2),
    data_usage_5g_pct       DECIMAL(5,2),
    data_throttled_days     INT,
    
    -- Messaging
    sms_sent                INT,
    mms_sent                INT,
    
    -- Roaming
    roaming_days            INT,
    roaming_data_gb         DECIMAL(10,3),
    roaming_voice_min       INT,
    
    -- Financials
    base_charge             DECIMAL(10,2),
    overage_charges         DECIMAL(10,2),
    roaming_charges         DECIMAL(10,2),
    add_on_charges          DECIMAL(10,2),
    discounts_applied       DECIMAL(10,2),
    total_bill              DECIMAL(10,2),
    
    -- Payment
    payment_status          VARCHAR(20),
    days_to_payment         INT
);
```

#### RAW.SUPPORT_INTERACTIONS

```sql
CREATE OR REPLACE TABLE RAW.SUPPORT_INTERACTIONS (
    interaction_id          VARCHAR(36) PRIMARY KEY,
    customer_id             VARCHAR(36) REFERENCES RAW.CUSTOMERS(customer_id),
    interaction_date        TIMESTAMP_NTZ,
    
    -- Channel
    channel                 VARCHAR(20),
    
    -- Classification
    category                VARCHAR(50),
    subcategory             VARCHAR(50),
    intent                  VARCHAR(100),
    
    -- Resolution
    resolution_status       VARCHAR(20),
    resolution_time_hours   DECIMAL(10,2),
    first_contact_resolution BOOLEAN,
    
    -- Sentiment
    sentiment_score         DECIMAL(3,2),
    csat_score              INT,
    
    -- Content
    interaction_summary     VARCHAR(1000),
    customer_verbatim       VARCHAR(2000)
);
```

#### RAW.CAMPAIGN_RESPONSES

```sql
CREATE OR REPLACE TABLE RAW.CAMPAIGN_RESPONSES (
    response_id             VARCHAR(36) PRIMARY KEY,
    customer_id             VARCHAR(36) REFERENCES RAW.CUSTOMERS(customer_id),
    campaign_id             VARCHAR(36),
    
    -- Campaign Details
    campaign_name           VARCHAR(100),
    campaign_type           VARCHAR(30),
    campaign_category       VARCHAR(50),
    offer_type              VARCHAR(50),
    offer_value             DECIMAL(10,2),
    
    -- Delivery
    channel                 VARCHAR(20),
    sent_at                 TIMESTAMP_NTZ,
    delivered               BOOLEAN,
    
    -- Response
    opened                  BOOLEAN,
    clicked                 BOOLEAN,
    responded               BOOLEAN,
    response_type           VARCHAR(30),
    response_at             TIMESTAMP_NTZ,
    
    -- Outcome
    converted               BOOLEAN,
    conversion_value        DECIMAL(10,2)
);
```

### 3.2 External Data Tables

#### EXTERNAL.ZIP_DEMOGRAPHICS

```sql
CREATE OR REPLACE TABLE EXTERNAL.ZIP_DEMOGRAPHICS (
    zip_code                VARCHAR(5) PRIMARY KEY,
    zip_name                VARCHAR(100),
    state_code              VARCHAR(2),
    state_name              VARCHAR(50),
    region                  VARCHAR(20),
    dma_code                VARCHAR(3),
    dma_name                VARCHAR(100),
    
    -- Population
    total_population        INT,
    population_density      DECIMAL(10,2),
    land_area_sq_miles      DECIMAL(10,2),
    urban_rural_class       VARCHAR(20),
    
    -- Age Distribution (%)
    pct_age_18_24           DECIMAL(5,2),
    pct_age_25_34           DECIMAL(5,2),
    pct_age_35_44           DECIMAL(5,2),
    pct_age_45_54           DECIMAL(5,2),
    pct_age_55_64           DECIMAL(5,2),
    pct_age_65_plus         DECIMAL(5,2),
    median_age              DECIMAL(4,1),
    
    -- Income
    median_household_income INT,
    mean_household_income   INT,
    per_capita_income       INT,
    pct_income_under_25k    DECIMAL(5,2),
    pct_income_25k_50k      DECIMAL(5,2),
    pct_income_50k_75k      DECIMAL(5,2),
    pct_income_75k_100k     DECIMAL(5,2),
    pct_income_100k_150k    DECIMAL(5,2),
    pct_income_150k_plus    DECIMAL(5,2),
    
    -- Education
    pct_high_school         DECIMAL(5,2),
    pct_some_college        DECIMAL(5,2),
    pct_bachelors           DECIMAL(5,2),
    pct_graduate_degree     DECIMAL(5,2),
    
    -- Housing
    pct_owner_occupied      DECIMAL(5,2),
    pct_renter_occupied     DECIMAL(5,2),
    median_home_value       INT,
    median_rent             INT,
    
    -- Household Composition
    avg_household_size      DECIMAL(3,1),
    pct_family_households   DECIMAL(5,2),
    pct_married_couples     DECIMAL(5,2),
    pct_single_parent       DECIMAL(5,2),
    pct_living_alone        DECIMAL(5,2),
    
    -- Employment
    labor_force_participation DECIMAL(5,2),
    pct_white_collar        DECIMAL(5,2),
    pct_blue_collar         DECIMAL(5,2),
    pct_service_industry    DECIMAL(5,2),
    
    -- Diversity
    pct_white               DECIMAL(5,2),
    pct_black               DECIMAL(5,2),
    pct_hispanic            DECIMAL(5,2),
    pct_asian               DECIMAL(5,2),
    pct_other_race          DECIMAL(5,2)
);
```

#### EXTERNAL.ECONOMIC_INDICATORS

```sql
CREATE OR REPLACE TABLE EXTERNAL.ECONOMIC_INDICATORS (
    zip_code                VARCHAR(5) PRIMARY KEY,
    
    -- Cost of Living (100 = national average)
    cost_of_living_index    DECIMAL(5,1),
    housing_cost_index      DECIMAL(5,1),
    utilities_cost_index    DECIMAL(5,1),
    transportation_index    DECIMAL(5,1),
    groceries_index         DECIMAL(5,1),
    healthcare_index        DECIMAL(5,1),
    
    -- Employment
    unemployment_rate       DECIMAL(4,2),
    job_growth_rate_yoy     DECIMAL(5,2),
    
    -- Economic Health
    poverty_rate            DECIMAL(5,2),
    food_insecurity_rate    DECIMAL(5,2),
    uninsured_rate          DECIMAL(5,2),
    
    -- Housing Market
    home_price_growth_yoy   DECIMAL(5,2),
    rent_growth_yoy         DECIMAL(5,2),
    vacancy_rate            DECIMAL(5,2),
    
    -- Consumer Behavior
    avg_credit_score        INT,
    pct_prime_credit        DECIMAL(5,2),
    pct_subprime_credit     DECIMAL(5,2),
    avg_debt_to_income      DECIMAL(5,2),
    
    -- Retail/Spending
    retail_sales_per_capita INT,
    ecommerce_penetration   DECIMAL(5,2),
    
    -- Last Updated
    data_as_of_date         DATE
);
```

#### EXTERNAL.COMPETITIVE_LANDSCAPE

```sql
CREATE OR REPLACE TABLE EXTERNAL.COMPETITIVE_LANDSCAPE (
    dma_code                VARCHAR(3) PRIMARY KEY,
    dma_name                VARCHAR(100),
    
    -- Market Size
    total_wireless_subs     INT,
    market_size_revenue     DECIMAL(12,2),
    yoy_market_growth       DECIMAL(5,2),
    
    -- Snowmobile Position
    snowmobile_subs         INT,
    snowmobile_market_share DECIMAL(5,2),
    snowmobile_nps          INT,
    snowmobile_coverage_pct DECIMAL(5,2),
    snowmobile_5g_pct       DECIMAL(5,2),
    
    -- Competitor 1: Verizon
    vz_market_share         DECIMAL(5,2),
    vz_avg_price            DECIMAL(6,2),
    vz_nps                  INT,
    vz_coverage_pct         DECIMAL(5,2),
    
    -- Competitor 2: AT&T
    att_market_share        DECIMAL(5,2),
    att_avg_price           DECIMAL(6,2),
    att_nps                 INT,
    att_coverage_pct        DECIMAL(5,2),
    
    -- Competitor 3: T-Mobile
    tmo_market_share        DECIMAL(5,2),
    tmo_avg_price           DECIMAL(6,2),
    tmo_nps                 INT,
    tmo_coverage_pct        DECIMAL(5,2),
    
    -- Regional Competitors
    regional_market_share   DECIMAL(5,2),
    regional_avg_price      DECIMAL(6,2),
    
    -- Competitive Dynamics
    market_concentration    DECIMAL(5,2),
    price_war_intensity     VARCHAR(10),
    recent_competitor_promo VARCHAR(200),
    promo_end_date          DATE
);
```

#### EXTERNAL.LIFESTYLE_SEGMENTS

```sql
CREATE OR REPLACE TABLE EXTERNAL.LIFESTYLE_SEGMENTS (
    zip_code                VARCHAR(5) PRIMARY KEY,
    
    -- Dominant Lifestyle Cluster
    primary_lifestyle       VARCHAR(50),
    secondary_lifestyle     VARCHAR(50),
    lifestyle_diversity     DECIMAL(3,2),
    
    -- Technology Adoption (0-100 scores)
    tech_adoption_score     INT,
    smartphone_penetration  DECIMAL(5,2),
    pct_iphone              DECIMAL(5,2),
    pct_android             DECIMAL(5,2),
    smart_home_adoption     DECIMAL(5,2),
    streaming_penetration   DECIMAL(5,2),
    cord_cutter_rate        DECIMAL(5,2),
    
    -- Digital Behavior
    avg_daily_screen_time   DECIMAL(4,1),
    social_media_heavy_pct  DECIMAL(5,2),
    online_shopping_pct     DECIMAL(5,2),
    mobile_banking_pct      DECIMAL(5,2),
    
    -- Media Consumption
    streaming_hours_week    DECIMAL(4,1),
    gaming_hours_week       DECIMAL(4,1),
    news_consumption        VARCHAR(20),
    primary_news_source     VARCHAR(30),
    
    -- Values & Priorities
    price_sensitivity_index INT,
    brand_loyalty_index     INT,
    eco_consciousness       INT,
    early_adopter_index     INT,
    
    -- Communication Preferences
    pref_channel_digital    DECIMAL(5,2),
    pref_channel_phone      DECIMAL(5,2),
    pref_channel_store      DECIMAL(5,2),
    pref_channel_chat       DECIMAL(5,2),
    
    -- Wireless-Specific Behaviors
    avg_data_usage_gb       DECIMAL(5,1),
    avg_lines_per_account   DECIMAL(3,1),
    family_plan_propensity  DECIMAL(5,2),
    premium_plan_propensity DECIMAL(5,2),
    prepaid_propensity      DECIMAL(5,2),
    
    -- Churn Propensity Factors
    deal_seeker_index       INT,
    switching_propensity    DECIMAL(5,2),
    competitor_awareness    DECIMAL(5,2)
);
```

### 3.3 Analytics Tables

#### ANALYTICS.CUSTOMER_FEATURES_ENRICHED

```sql
CREATE OR REPLACE TABLE ANALYTICS.CUSTOMER_FEATURES_ENRICHED AS
SELECT
    c.customer_id,
    c.zip_code,
    c.state_code,
    c.dma_code,
    
    -- Customer Demographics
    c.age,
    c.gender,
    
    -- Account
    c.tenure_months,
    c.plan_name,
    c.plan_category,
    c.plan_price,
    c.lines_on_account,
    c.contract_type,
    c.monthly_arpu,
    c.lifetime_value,
    
    -- Device
    c.device_brand,
    c.device_os,
    c.device_tier,
    c.is_5g_capable,
    
    -- Engagement
    c.app_engagement_score,
    c.rewards_tier,
    c.nps_score,
    
    -- Risk
    c.churn_risk_score,
    c.complaint_count_12m,
    
    -- Usage Aggregates
    u.avg_data_usage_gb,
    u.avg_voice_minutes,
    u.data_trend_3m,
    u.overage_frequency,
    u.avg_bill_amount,
    
    -- Interaction Aggregates
    i.support_contacts_12m,
    i.avg_sentiment_score,
    i.complaint_rate,
    
    -- ZIP Demographics
    z.total_population,
    z.population_density,
    z.urban_rural_class,
    z.median_household_income,
    z.median_age AS zip_median_age,
    z.pct_bachelors AS zip_education,
    z.pct_family_households,
    
    -- Economic
    e.cost_of_living_index,
    e.unemployment_rate,
    e.avg_credit_score AS zip_credit_score,
    e.poverty_rate,
    
    -- Competitive
    comp.snowmobile_market_share AS local_market_share,
    comp.price_war_intensity,
    (comp.vz_avg_price + comp.att_avg_price + comp.tmo_avg_price) / 3 AS competitor_avg_price,
    
    -- Lifestyle
    l.primary_lifestyle,
    l.tech_adoption_score,
    l.price_sensitivity_index,
    l.brand_loyalty_index,
    l.early_adopter_index,
    l.switching_propensity AS zip_switch_propensity,
    l.deal_seeker_index,
    
    -- Derived Features
    c.monthly_arpu / NULLIF((comp.vz_avg_price + comp.att_avg_price + comp.tmo_avg_price) / 3, 0) AS price_position_ratio,
    (c.monthly_arpu * 12) / NULLIF(z.median_household_income, 0) * 100 AS wallet_share_pct,
    c.lifetime_value / NULLIF(c.tenure_months, 0) AS monthly_value,
    c.churn_risk_score * (1 + l.switching_propensity/100) * 
        CASE WHEN comp.price_war_intensity = 'High' THEN 1.2 
             WHEN comp.price_war_intensity = 'Medium' THEN 1.1 
             ELSE 1.0 END AS adjusted_churn_risk

FROM RAW.CUSTOMERS c
LEFT JOIN ANALYTICS.CUSTOMER_USAGE_SUMMARY u ON c.customer_id = u.customer_id
LEFT JOIN ANALYTICS.CUSTOMER_INTERACTION_SUMMARY i ON c.customer_id = i.customer_id
LEFT JOIN EXTERNAL.ZIP_DEMOGRAPHICS z ON c.zip_code = z.zip_code
LEFT JOIN EXTERNAL.ECONOMIC_INDICATORS e ON c.zip_code = e.zip_code
LEFT JOIN EXTERNAL.COMPETITIVE_LANDSCAPE comp ON c.dma_code = comp.dma_code
LEFT JOIN EXTERNAL.LIFESTYLE_SEGMENTS l ON c.zip_code = l.zip_code;
```

### 3.4 Persona Tables

#### PERSONAS.PERSONA_DEFINITIONS

```sql
CREATE OR REPLACE TABLE PERSONAS.PERSONA_DEFINITIONS (
    persona_id              VARCHAR(36) PRIMARY KEY,
    segment_id              VARCHAR(10),
    segment_name            VARCHAR(50),
    persona_name            VARCHAR(100),
    
    -- Demographic Composite
    typical_age_range       VARCHAR(20),
    typical_gender_dist     VARCHAR(50),
    typical_income          VARCHAR(30),
    typical_household       VARCHAR(50),
    typical_location        VARCHAR(100),
    
    -- Account Composite
    typical_plan            VARCHAR(50),
    typical_contract        VARCHAR(30),
    typical_tenure          VARCHAR(30),
    typical_arpu            DECIMAL(10,2),
    typical_device          VARCHAR(50),
    
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
    communication_style     TEXT,
    decision_making_style   TEXT,
    emotional_triggers      TEXT,
    sample_quotes           VARIANT,
    
    -- Metadata
    created_at              TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at              TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    created_by              VARCHAR(100),
    version                 INT DEFAULT 1
);
```

---

## 4. Cortex AI Integration

### 4.1 Models Used

| Model | Purpose | Use Case |
|-------|---------|----------|
| `llama3.1-70b` | Text generation | Persona creation, scenario responses |
| `llama3.1-8b` | Fast text generation | Quick reactions, summaries |
| `e5-base-v2` | Text embeddings | Semantic search, RAG |
| Cortex Search | Vector search | Historical context retrieval |

### 4.2 Persona Generation Function

```sql
CREATE OR REPLACE FUNCTION PERSONAS.GENERATE_PERSONA(
    p_segment_id VARCHAR,
    p_segment_stats VARIANT,
    p_sample_verbatims ARRAY
)
RETURNS VARIANT
LANGUAGE SQL
AS
$$
SELECT PARSE_JSON(
    SNOWFLAKE.CORTEX.COMPLETE(
        'llama3.1-70b',
        CONCAT(
            'You are an expert in telecom customer behavior and market research for Snowmobile Wireless, ',
            'a US-based mobile carrier. Create a detailed, realistic persona for this customer segment. ',
            'The persona should feel like a real American customer, not a stereotype. ',
            'Include nuanced motivations, concerns, and behavioral patterns specific to US telecom market.',
            
            '\n\n### SEGMENT STATISTICS ###\n',
            TO_VARCHAR(p_segment_stats),
            
            '\n\n### SAMPLE CUSTOMER VERBATIMS ###\n',
            ARRAY_TO_STRING(p_sample_verbatims, '\n---\n'),
            
            '\n\n### INSTRUCTIONS ###\n',
            'Generate a persona as a JSON object with these fields:',
            '\n{',
            '\n  "persona_name": "First Last, Age",',
            '\n  "location": "City, State",',
            '\n  "tagline": "One-sentence description",',
            '\n  "background_story": "100 words about their life situation",',
            '\n  "relationship_with_service": "150 words about how they use mobile",',
            '\n  "financial_mindset": {"bill_tolerance": "$X-Y/month", "price_increase_reaction": "...", "decision_factors": ["...", "..."]},',
            '\n  "communication_style": {"prefers": ["..."], "avoids": ["..."], "tone": "..."},',
            '\n  "hot_buttons": {"happy": ["...", "..."], "angry": ["...", "..."], "ignores": ["...", "..."]},',
            '\n  "sample_quotes": {"satisfied": "...", "frustrated": "...", "considering_change": "..."}',
            '\n}',
            '\n\nRespond ONLY with the JSON object, no other text.'
        )
    )
)
$$;
```

### 4.3 Agent Query Function

```sql
CREATE OR REPLACE FUNCTION AGENTS.ASK_PERSONA(
    p_persona_id VARCHAR,
    p_scenario TEXT
)
RETURNS VARIANT
LANGUAGE SQL
AS
$$
WITH persona AS (
    SELECT * FROM PERSONAS.PERSONA_DEFINITIONS WHERE persona_id = p_persona_id
),
historical AS (
    SELECT TOP 3 
        event_type, event_description, reaction_summary
    FROM PERSONAS.HISTORICAL_REACTIONS h
    WHERE h.segment_id = (SELECT segment_id FROM persona)
    ORDER BY event_date DESC
)
SELECT PARSE_JSON(
    SNOWFLAKE.CORTEX.COMPLETE(
        'llama3.1-70b',
        CONCAT(
            '### ROLE ###\n',
            'You are roleplaying as a Snowmobile Wireless customer persona. Stay completely in character.\n',
            'Respond exactly as this person would - with their concerns, priorities, and communication style.\n',
            
            '\n### YOUR PERSONA ###\n',
            'Name: ', (SELECT persona_name FROM persona), '\n',
            'Background: ', (SELECT background_story FROM persona), '\n',
            'Personality: ', (SELECT personality_description FROM persona), '\n',
            'Communication Style: ', (SELECT communication_style FROM persona), '\n',
            'Hot Buttons: ', (SELECT emotional_triggers FROM persona), '\n',
            
            '\n### HISTORICAL CONTEXT ###\n',
            'Here is how customers like you have reacted to similar situations:\n',
            (SELECT LISTAGG(reaction_summary, '\n---\n') FROM historical),
            
            '\n### SCENARIO ###\n',
            p_scenario,
            
            '\n### INSTRUCTIONS ###\n',
            'Respond as a JSON object:\n',
            '{\n',
            '  "initial_reaction": "Your immediate emotional response (1-2 sentences, in character)",\n',
            '  "sentiment_score": <number from -1.0 (very negative) to 1.0 (very positive)>,\n',
            '  "likely_action": "One of: ACCEPT, IGNORE, COMPLAIN, THREATEN_CHURN, CHURN, UPGRADE, DOWNGRADE",\n',
            '  "action_probability": <0.0 to 1.0>,\n',
            '  "reasoning": "Why you would react this way (2-3 sentences, analytical)",\n',
            '  "what_would_change_mind": "What the company could do differently (1-2 sentences)",\n',
            '  "sample_verbatim": "What you might actually say to customer service (realistic quote)"\n',
            '}\n',
            'Respond ONLY with the JSON object.'
        )
    )
)
$$;
```

### 4.4 Multi-Agent Simulation Procedure

```sql
CREATE OR REPLACE PROCEDURE AGENTS.SIMULATE_SCENARIO(
    p_scenario TEXT,
    p_segment_filter ARRAY DEFAULT NULL
)
RETURNS TABLE (
    segment_id VARCHAR,
    segment_name VARCHAR,
    customer_count INT,
    pct_of_base DECIMAL(5,2),
    reaction VARIANT,
    sentiment_score DECIMAL(3,2),
    likely_action VARCHAR,
    weighted_impact DECIMAL(5,2)
)
LANGUAGE SQL
AS
$$
DECLARE
    result RESULTSET;
BEGIN
    result := (
        SELECT 
            p.segment_id,
            p.segment_name,
            s.customer_count,
            s.pct_of_base,
            AGENTS.ASK_PERSONA(p.persona_id, p_scenario) AS reaction,
            reaction:sentiment_score::DECIMAL(3,2) AS sentiment_score,
            reaction:likely_action::VARCHAR AS likely_action,
            (reaction:sentiment_score::DECIMAL * s.pct_of_base / 100) AS weighted_impact
        FROM PERSONAS.PERSONA_DEFINITIONS p
        JOIN ANALYTICS.SEGMENT_STATISTICS s ON p.segment_id = s.segment_id
        WHERE p_segment_filter IS NULL 
           OR p.segment_id IN (SELECT VALUE FROM TABLE(FLATTEN(p_segment_filter)))
        ORDER BY s.customer_count DESC
    );
    RETURN TABLE(result);
END;
$$;
```

---

## 5. Streamlit Application Architecture

### 5.1 Application Structure

```
streamlit/
├── Snowmobile_Digital_Twin.py       # Main entry point
├── pages/
│   ├── 1_Segment_Explorer.py        # Segment analysis
│   ├── 2_Persona_Gallery.py         # Browse personas
│   ├── 3_Simulation_Studio.py       # Run simulations
│   ├── 4_Campaign_Tester.py         # Batch testing
│   └── 5_Scenario_History.py        # Past simulations
└── utils/
    ├── snowflake_utils.py           # Database connections
    ├── persona_utils.py             # Persona operations
    └── chart_utils.py               # Visualization helpers
```

### 5.2 Key Pages

**1. Segment Explorer**
- Segment distribution visualization (treemap, pie chart)
- Segment comparison radar charts
- Drill-down to segment statistics
- Customer sample browser

**2. Persona Gallery**
- Card-based persona browser
- Expandable persona details
- Side-by-side comparison
- Persona regeneration controls

**3. Simulation Studio** (Core Feature)
- Scenario builder with templates
- Single persona deep-dive mode
- Multi-persona comparison
- Real-time streaming responses
- Results aggregation and recommendations

**4. Campaign Tester**
- Bulk scenario testing
- Message A/B comparison
- Export results to CSV/table

**5. Scenario History**
- Past simulation browser
- Outcome tracking (if available)
- Trend analysis

---

## 6. Data Flow Diagrams

### 6.1 Data Loading Flow

```
CSV Files                    Snowflake Stage              Tables
─────────────────────────────────────────────────────────────────
                                                          
customers.csv        ──►    @RAW.DATA_STAGE    ──►    RAW.CUSTOMERS
monthly_usage.csv    ──►    /internal/         ──►    RAW.MONTHLY_USAGE
interactions.csv     ──►                       ──►    RAW.SUPPORT_INTERACTIONS
campaigns.csv        ──►                       ──►    RAW.CAMPAIGN_RESPONSES

zip_demographics.csv ──►    @RAW.DATA_STAGE    ──►    EXTERNAL.ZIP_DEMOGRAPHICS
economic.csv         ──►    /external/         ──►    EXTERNAL.ECONOMIC_INDICATORS
competitive.csv      ──►                       ──►    EXTERNAL.COMPETITIVE_LANDSCAPE
lifestyle.csv        ──►                       ──►    EXTERNAL.LIFESTYLE_SEGMENTS
```

### 6.2 Feature Engineering Flow

```
RAW + EXTERNAL Data          Aggregations              Enriched Features
─────────────────────────────────────────────────────────────────────────

RAW.CUSTOMERS           ──►  ANALYTICS.              ──►  ANALYTICS.
RAW.MONTHLY_USAGE       ──►  CUSTOMER_USAGE_         ──►  CUSTOMER_FEATURES_
RAW.SUPPORT_INTERACTIONS──►  SUMMARY                 ──►  ENRICHED
RAW.CAMPAIGN_RESPONSES  ──►  CUSTOMER_INTERACTION_   ──►
                             SUMMARY                      │
EXTERNAL.ZIP_DEMOGRAPHICS   ─────────────────────────────┘
EXTERNAL.ECONOMIC_INDICATORS─────────────────────────────┘
EXTERNAL.COMPETITIVE_LANDSCAPE───────────────────────────┘
EXTERNAL.LIFESTYLE_SEGMENTS ─────────────────────────────┘
```

### 6.3 Segmentation Flow

```
Enriched Features       Clustering           Segments              Personas
─────────────────────────────────────────────────────────────────────────────

CUSTOMER_FEATURES   ──► K-Means      ──► CUSTOMER_         ──► Cortex LLM
_ENRICHED               Clustering       SEGMENTS              │
    │                       │                │                 │
    │                       ▼                ▼                 ▼
    │               Feature          SEGMENT_           PERSONA_
    │               Normalization    STATISTICS         DEFINITIONS
    │                       │                │                 │
    │                       ▼                │                 │
    │               Cluster          ────────┴─────────────────┘
    │               Assignment              │
    │                       │               │
    └───────────────────────┴───────────────┘
```

---

## 7. Security & Access Control

### 7.1 Role Hierarchy

```
ACCOUNTADMIN
    │
    ├── CDT_ADMIN              # Full access to all objects
    │       │
    │       ├── CDT_DEVELOPER  # Create/modify objects
    │       │       │
    │       │       └── CDT_ANALYST  # Read analytics, run simulations
    │       │               │
    │       │               └── CDT_VIEWER  # Read-only access
    │       │
    │       └── CDT_DATA_LOADER  # Load data, manage stages
    │
    └── CDT_APP_ROLE  # Streamlit app service role
```

### 7.2 Permission Matrix

| Role | RAW | EXTERNAL | ANALYTICS | PERSONAS | AGENTS | APP |
|------|-----|----------|-----------|----------|--------|-----|
| CDT_ADMIN | OWNERSHIP | OWNERSHIP | OWNERSHIP | OWNERSHIP | OWNERSHIP | OWNERSHIP |
| CDT_DEVELOPER | MODIFY | MODIFY | MODIFY | MODIFY | MODIFY | MODIFY |
| CDT_ANALYST | READ | READ | READ | READ | EXECUTE | READ |
| CDT_VIEWER | READ | READ | READ | READ | - | READ |
| CDT_DATA_LOADER | WRITE | WRITE | - | - | - | - |
| CDT_APP_ROLE | READ | READ | READ | READ | EXECUTE | READ |

---

## 8. Resource Estimates

### 8.1 Compute (Credits/Day)

| Operation | Warehouse | Size | Est. Duration | Credits |
|-----------|-----------|------|---------------|---------|
| Data Load (initial) | CDT_LOAD_WH | MEDIUM | 30 min | 2 |
| Feature Engineering | CDT_LOAD_WH | MEDIUM | 15 min | 1 |
| Segmentation | CDT_ML_WH | LARGE | 20 min | 2.7 |
| Persona Generation (8) | CDT_CORTEX_WH | MEDIUM | 10 min | 0.7 |
| Simulations (50/day) | CDT_CORTEX_WH | MEDIUM | 25 min | 1.7 |
| Streamlit App | CDT_APP_WH | X-SMALL | 8 hrs | 0.5 |
| **Daily Total** | | | | **~8-10** |

### 8.2 Cortex AI Costs

| Operation | Model | Tokens/Call | Cost/Call | Daily Volume | Daily Cost |
|-----------|-------|-------------|-----------|--------------|------------|
| Persona Generation | llama3.1-70b | 2,000 | $0.02 | 10 | $0.20 |
| Scenario Simulation | llama3.1-70b | 1,500 | $0.015 | 500 | $7.50 |
| Embeddings | e5-base-v2 | 500 | $0.001 | 1,000 | $1.00 |
| **Daily Total** | | | | | **~$9** |

### 8.3 Storage

| Object | Records | Est. Size |
|--------|---------|-----------|
| RAW Tables | 20M | ~5 GB |
| EXTERNAL Tables | 126K | ~0.5 GB |
| ANALYTICS Tables | 1M | ~2 GB |
| PERSONAS Tables | 1K | ~0.1 GB |
| Stages (CSV) | - | ~3 GB |
| **Total** | | **~11 GB** |

---

## 9. Deployment Checklist

### 9.1 Prerequisites

- [ ] Snowflake Enterprise or Business Critical account
- [ ] Cortex AI enabled (region-specific)
- [ ] Snowflake Notebooks enabled
- [ ] Streamlit in Snowflake enabled
- [ ] Sufficient credit quota

### 9.2 Setup Steps

1. [ ] Run `01_setup_database.sql` - Create database and schemas
2. [ ] Run `02_create_internal_tables.sql` - Create RAW tables
3. [ ] Run `03_create_external_tables.sql` - Create EXTERNAL tables
4. [ ] Run `04_create_stages.sql` - Create stages
5. [ ] Upload CSV files to stages
6. [ ] Run `05_load_data.sql` - Load data
7. [ ] Run `06_create_enriched_views.sql` - Create analytics views
8. [ ] Run `07_segmentation_pipeline.sql` - Run clustering
9. [ ] Run `08_persona_generation.sql` - Generate personas
10. [ ] Run `09_agent_functions.sql` - Create agent functions
11. [ ] Deploy Streamlit app

### 9.3 Validation

- [ ] All tables populated with expected record counts
- [ ] Features enriched view returns data
- [ ] Segmentation produces 8 distinct clusters
- [ ] All 8 personas generated successfully
- [ ] ASK_PERSONA function returns valid JSON
- [ ] SIMULATE_SCENARIO returns results for all segments
- [ ] Streamlit app loads and functions correctly

---

## 10. Maintenance & Operations

### 10.1 Data Refresh Schedule

| Data | Refresh Frequency | Method |
|------|-------------------|--------|
| Customer Master | Daily | Incremental |
| Usage Data | Daily | Append monthly |
| Interactions | Daily | Incremental |
| Campaigns | Daily | Incremental |
| ZIP Demographics | Quarterly | Full refresh |
| Economic Indicators | Monthly | Full refresh |
| Competitive Intel | Weekly | Full refresh |
| Lifestyle Segments | Quarterly | Full refresh |

### 10.2 Monitoring

- Warehouse credit consumption
- Cortex AI token usage
- Query performance (slow queries)
- Streamlit app usage metrics
- Simulation response times

### 10.3 Backup & Recovery

- Time Travel: 7 days (Standard), 90 days (Enterprise)
- Fail-safe: 7 days additional
- Critical tables cloned weekly


