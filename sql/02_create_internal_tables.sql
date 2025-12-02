-- ============================================================================
-- Snowmobile Wireless - Customer Digital Twin
-- 02_create_internal_tables.sql
-- 
-- Purpose: Create internal (1st party) data tables in RAW schema
-- ============================================================================

USE DATABASE SNOWMOBILE_DIGITAL_TWIN;
USE SCHEMA RAW;
USE WAREHOUSE CDT_LOAD_WH;

-- ============================================================================
-- CUSTOMERS TABLE
-- Primary customer master data
-- ============================================================================

CREATE OR REPLACE TABLE RAW.CUSTOMERS (
    -- Identity
    customer_id             VARCHAR(36) NOT NULL PRIMARY KEY
                            COMMENT 'Unique customer identifier (UUID)',
    account_id              VARCHAR(20)
                            COMMENT 'Account number for billing',
    
    -- Location (links to external data)
    zip_code                VARCHAR(5)
                            COMMENT 'Customer ZIP code - JOIN KEY to external tables',
    state_code              VARCHAR(2)
                            COMMENT 'Two-letter state code',
    dma_code                VARCHAR(3)
                            COMMENT 'Designated Market Area code',
    
    -- Demographics
    age                     INT
                            COMMENT 'Customer age in years',
    gender                  VARCHAR(10)
                            COMMENT 'Gender (M/F/Other/Unknown)',
    
    -- Account Details
    customer_since          DATE
                            COMMENT 'Date customer joined Snowmobile',
    tenure_months           INT
                            COMMENT 'Number of months as customer',
    acquisition_channel     VARCHAR(30)
                            COMMENT 'How customer was acquired (Retail/Online/Telesales/Partner)',
    
    -- Current Plan
    plan_name               VARCHAR(30)
                            COMMENT 'Current plan name (Flurry/Powder/Blizzard/Avalanche/Summit/Glacier)',
    plan_category           VARCHAR(20)
                            COMMENT 'Plan category (Prepaid/Postpaid)',
    plan_price              DECIMAL(6,2)
                            COMMENT 'Base monthly plan price',
    lines_on_account        INT
                            COMMENT 'Number of lines on account',
    contract_type           VARCHAR(20)
                            COMMENT 'Contract type (NoContract/12M/24M/DevicePayment)',
    contract_end_date       DATE
                            COMMENT 'Contract end date if applicable',
    
    -- Device
    device_brand            VARCHAR(30)
                            COMMENT 'Device manufacturer (Apple/Samsung/Google/etc)',
    device_model            VARCHAR(50)
                            COMMENT 'Device model name',
    device_tier             VARCHAR(20)
                            COMMENT 'Device tier (Flagship/Mid/Budget)',
    device_os               VARCHAR(20)
                            COMMENT 'Operating system (iOS/Android)',
    device_age_months       INT
                            COMMENT 'Months since device activation',
    is_5g_capable           BOOLEAN
                            COMMENT 'Whether device supports 5G',
    
    -- Financial
    monthly_arpu            DECIMAL(8,2)
                            COMMENT 'Average Revenue Per User (monthly)',
    lifetime_value          DECIMAL(10,2)
                            COMMENT 'Total lifetime revenue from customer',
    total_revenue_12m       DECIMAL(10,2)
                            COMMENT 'Total revenue last 12 months',
    payment_method          VARCHAR(20)
                            COMMENT 'Payment method (AutoPay/Card/Manual/Cash)',
    autopay_enrolled        BOOLEAN
                            COMMENT 'Whether enrolled in AutoPay',
    paperless_billing       BOOLEAN
                            COMMENT 'Whether using paperless billing',
    credit_class            VARCHAR(10)
                            COMMENT 'Internal credit classification (A/B/C/D)',
    
    -- Add-Ons
    has_device_protection   BOOLEAN
                            COMMENT 'Has Snowpack Protection add-on',
    has_intl_roaming        BOOLEAN
                            COMMENT 'Has Altitude Roaming add-on',
    has_streaming_bundle    BOOLEAN
                            COMMENT 'Has Peak Streaming add-on',
    
    -- Loyalty
    rewards_member          BOOLEAN
                            COMMENT 'Member of Summit Rewards program',
    rewards_tier            VARCHAR(20)
                            COMMENT 'Rewards tier (Bronze/Silver/Gold/Platinum)',
    rewards_points_balance  INT
                            COMMENT 'Current rewards points balance',
    
    -- Engagement
    app_user                BOOLEAN
                            COMMENT 'Whether customer uses Snowmobile app',
    app_engagement_score    DECIMAL(3,2)
                            COMMENT 'App engagement score (0.00-1.00)',
    last_app_login          DATE
                            COMMENT 'Date of last app login',
    nps_score               INT
                            COMMENT 'Last NPS survey response (-100 to 100)',
    nps_survey_date         DATE
                            COMMENT 'Date of last NPS survey',
    
    -- Risk Indicators
    churn_risk_score        DECIMAL(3,2)
                            COMMENT 'ML-predicted churn risk (0.00-1.00)',
    predicted_churn_reason  VARCHAR(50)
                            COMMENT 'Predicted primary churn reason',
    complaint_count_12m     INT
                            COMMENT 'Number of complaints in last 12 months',
    
    -- Timestamps
    created_at              TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
                            COMMENT 'Record creation timestamp',
    updated_at              TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
                            COMMENT 'Record last update timestamp'
)
COMMENT = 'Snowmobile Wireless customer master data - 1M records';

-- ============================================================================
-- MONTHLY_USAGE TABLE
-- Monthly usage and billing data
-- ============================================================================

CREATE OR REPLACE TABLE RAW.MONTHLY_USAGE (
    -- Identity
    usage_id                VARCHAR(36) NOT NULL PRIMARY KEY
                            COMMENT 'Unique usage record identifier',
    customer_id             VARCHAR(36) NOT NULL
                            COMMENT 'Reference to customer',
    billing_month           DATE NOT NULL
                            COMMENT 'First day of billing month',
    
    -- Voice Usage
    voice_minutes_onnet     INT DEFAULT 0
                            COMMENT 'On-network voice minutes',
    voice_minutes_offnet    INT DEFAULT 0
                            COMMENT 'Off-network voice minutes',
    voice_minutes_intl      INT DEFAULT 0
                            COMMENT 'International voice minutes',
    voice_calls_count       INT DEFAULT 0
                            COMMENT 'Total number of voice calls',
    
    -- Data Usage
    data_usage_gb           DECIMAL(10,3) DEFAULT 0
                            COMMENT 'Total data usage in GB',
    data_usage_4g_pct       DECIMAL(5,2) DEFAULT 0
                            COMMENT 'Percentage of data on 4G',
    data_usage_5g_pct       DECIMAL(5,2) DEFAULT 0
                            COMMENT 'Percentage of data on 5G',
    data_throttled_days     INT DEFAULT 0
                            COMMENT 'Days data was throttled (over fair use)',
    
    -- Messaging
    sms_sent                INT DEFAULT 0
                            COMMENT 'SMS messages sent',
    mms_sent                INT DEFAULT 0
                            COMMENT 'MMS messages sent',
    
    -- Roaming
    roaming_days            INT DEFAULT 0
                            COMMENT 'Days spent roaming',
    roaming_data_gb         DECIMAL(10,3) DEFAULT 0
                            COMMENT 'Data used while roaming (GB)',
    roaming_voice_min       INT DEFAULT 0
                            COMMENT 'Voice minutes while roaming',
    
    -- Billing
    base_charge             DECIMAL(10,2) DEFAULT 0
                            COMMENT 'Base plan charge',
    overage_charges         DECIMAL(10,2) DEFAULT 0
                            COMMENT 'Overage charges',
    roaming_charges         DECIMAL(10,2) DEFAULT 0
                            COMMENT 'Roaming charges',
    add_on_charges          DECIMAL(10,2) DEFAULT 0
                            COMMENT 'Add-on service charges',
    discounts_applied       DECIMAL(10,2) DEFAULT 0
                            COMMENT 'Total discounts applied',
    total_bill              DECIMAL(10,2) DEFAULT 0
                            COMMENT 'Total bill amount',
    
    -- Payment
    payment_status          VARCHAR(20) DEFAULT 'Paid'
                            COMMENT 'Payment status (Paid/Late/Partial/Unpaid)',
    days_to_payment         INT
                            COMMENT 'Days from bill date to payment',
    
    -- Constraints
    CONSTRAINT fk_usage_customer 
        FOREIGN KEY (customer_id) REFERENCES RAW.CUSTOMERS(customer_id)
)
COMMENT = 'Monthly usage and billing records - 12M records (12 months x 1M customers)';

-- ============================================================================
-- SUPPORT_INTERACTIONS TABLE
-- Customer support interactions
-- ============================================================================

CREATE OR REPLACE TABLE RAW.SUPPORT_INTERACTIONS (
    -- Identity
    interaction_id          VARCHAR(36) NOT NULL PRIMARY KEY
                            COMMENT 'Unique interaction identifier',
    customer_id             VARCHAR(36) NOT NULL
                            COMMENT 'Reference to customer',
    interaction_date        TIMESTAMP_NTZ NOT NULL
                            COMMENT 'Date and time of interaction',
    
    -- Channel
    channel                 VARCHAR(20)
                            COMMENT 'Interaction channel (App/Chat/Call/Email/Store/Social)',
    
    -- Classification
    category                VARCHAR(50)
                            COMMENT 'Primary category (Billing/Technical/Sales/Complaint/General)',
    subcategory             VARCHAR(50)
                            COMMENT 'Subcategory for detailed classification',
    intent                  VARCHAR(100)
                            COMMENT 'ML-classified customer intent',
    
    -- Resolution
    resolution_status       VARCHAR(20)
                            COMMENT 'Resolution status (Resolved/Escalated/Pending/Unresolved)',
    resolution_time_hours   DECIMAL(10,2)
                            COMMENT 'Time to resolution in hours',
    first_contact_resolution BOOLEAN
                            COMMENT 'Whether resolved on first contact',
    
    -- Sentiment
    sentiment_score         DECIMAL(3,2)
                            COMMENT 'Sentiment score (-1.00 to 1.00)',
    csat_score              INT
                            COMMENT 'Post-interaction CSAT score (1-5)',
    
    -- Content
    interaction_summary     VARCHAR(1000)
                            COMMENT 'Agent summary of interaction',
    customer_verbatim       VARCHAR(2000)
                            COMMENT 'Customer verbatim quotes',
    
    -- Constraints
    CONSTRAINT fk_interaction_customer 
        FOREIGN KEY (customer_id) REFERENCES RAW.CUSTOMERS(customer_id)
)
COMMENT = 'Customer support interactions - 2M records';

-- ============================================================================
-- CAMPAIGN_RESPONSES TABLE
-- Marketing campaign responses
-- ============================================================================

CREATE OR REPLACE TABLE RAW.CAMPAIGN_RESPONSES (
    -- Identity
    response_id             VARCHAR(36) NOT NULL PRIMARY KEY
                            COMMENT 'Unique response record identifier',
    customer_id             VARCHAR(36) NOT NULL
                            COMMENT 'Reference to customer',
    campaign_id             VARCHAR(36)
                            COMMENT 'Campaign identifier',
    
    -- Campaign Details
    campaign_name           VARCHAR(100)
                            COMMENT 'Campaign name',
    campaign_type           VARCHAR(30)
                            COMMENT 'Campaign type (Retention/Upsell/Cross-sell/Win-back/Loyalty)',
    campaign_category       VARCHAR(50)
                            COMMENT 'Campaign category (Price/Product/Loyalty/Seasonal)',
    offer_type              VARCHAR(50)
                            COMMENT 'Type of offer presented',
    offer_value             DECIMAL(10,2)
                            COMMENT 'Monetary value of offer',
    
    -- Delivery
    channel                 VARCHAR(20)
                            COMMENT 'Delivery channel (Email/SMS/App/Call/Mail)',
    sent_at                 TIMESTAMP_NTZ
                            COMMENT 'Timestamp when campaign was sent',
    delivered               BOOLEAN
                            COMMENT 'Whether campaign was successfully delivered',
    
    -- Response
    opened                  BOOLEAN
                            COMMENT 'Whether customer opened message',
    clicked                 BOOLEAN
                            COMMENT 'Whether customer clicked CTA',
    responded               BOOLEAN
                            COMMENT 'Whether customer responded',
    response_type           VARCHAR(30)
                            COMMENT 'Response type (Accepted/Declined/Ignored/Complained)',
    response_at             TIMESTAMP_NTZ
                            COMMENT 'Timestamp of response',
    
    -- Outcome
    converted               BOOLEAN
                            COMMENT 'Whether customer converted',
    conversion_value        DECIMAL(10,2)
                            COMMENT 'Value of conversion',
    
    -- Constraints
    CONSTRAINT fk_campaign_customer 
        FOREIGN KEY (customer_id) REFERENCES RAW.CUSTOMERS(customer_id)
)
COMMENT = 'Marketing campaign responses - 5M records';

-- ============================================================================
-- INDEXES (Clustering Keys for performance)
-- ============================================================================

-- Cluster customers by location for external data joins
ALTER TABLE RAW.CUSTOMERS CLUSTER BY (zip_code, state_code);

-- Cluster usage by customer and month
ALTER TABLE RAW.MONTHLY_USAGE CLUSTER BY (customer_id, billing_month);

-- Cluster interactions by customer and date
ALTER TABLE RAW.SUPPORT_INTERACTIONS CLUSTER BY (customer_id, interaction_date);

-- Cluster campaigns by customer
ALTER TABLE RAW.CAMPAIGN_RESPONSES CLUSTER BY (customer_id, sent_at);

-- ============================================================================
-- VERIFICATION
-- ============================================================================

-- Verify tables created
SHOW TABLES IN SCHEMA RAW;

SELECT 'Internal tables created successfully!' AS status;


