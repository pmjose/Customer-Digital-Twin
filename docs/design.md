# Snowmobile Wireless - Customer Digital Twin
## Design Document

**Version**: 1.0  
**Last Updated**: December 2024  
**Author**: Customer Experience & Data Science Team

---

## Executive Summary

This document outlines the design for a **Snowflake Cortex-powered Customer Digital Twin** system for **Snowmobile Wireless**, a Tier 1 US telecom operator. The system creates intelligent AI persona agents from data-driven customer segments, enriched with external demographic, economic, competitive, and lifestyle data at ZIP-5 granularity. These agents simulate realistic customer reactions to product launches, price changes, and marketing campaigns—enabling marketing teams to "test" strategies before market deployment.

---

## 1. Company Profile: Snowmobile Wireless

### 1.1 Brand Identity

| Attribute | Details |
|-----------|---------|
| **Company Name** | Snowmobile Wireless |
| **Tagline** | "Your Data, Boundless" |
| **Founded** | 2012 (fictional) |
| **Headquarters** | Bozeman, Montana |
| **Brand Colors** | Arctic Blue (#29B5E8), Cloud White (#FFFFFF), Glacier Gray (#6E7681) |
| **Brand Personality** | Data-first, transparent, modern, reliable |

### 1.2 Company Story

Snowmobile Wireless was founded by data engineers who believed wireless connectivity should be as seamless and scalable as cloud computing. Named after the massive data transfer vehicles, Snowmobile built its network on principles of infinite capacity, zero friction, and complete transparency. The company pioneered "Data Cloud Wireless" — treating mobile data like cloud storage: always available, infinitely scalable, and priced fairly.

### 1.3 Market Position

| Metric | Value |
|--------|-------|
| **Subscribers** | 28 million (B2C) |
| **Market Share** | ~18% (4th largest US carrier) |
| **Coverage** | 98% US population |
| **5G Coverage** | 85% US population |
| **Annual Revenue** | $32 billion |
| **NPS Score** | +32 (industry avg: +22) |
| **Churn Rate** | 1.8% monthly / 19% annual |

### 1.4 Product Portfolio

#### Consumer Plans (Snow-themed)

| Plan Name | Price | Data | Target Segment |
|-----------|-------|------|----------------|
| **Flurry** | $35/mo | 5GB | Light users, seniors |
| **Powder** | $55/mo | 15GB | Standard users |
| **Blizzard** | $75/mo | Unlimited | Heavy users |
| **Avalanche** | $140/mo | Unlimited x4 lines | Families |
| **Summit** | $95/mo | Unlimited + perks | Premium individuals |
| **Glacier** | $25/mo | 2GB (prepaid) | Budget/prepaid |

#### Add-Ons & Services

| Service | Price | Description |
|---------|-------|-------------|
| **Snowpack Protection** | $15/mo | Device insurance + extended warranty |
| **Altitude Roaming** | $10/day | International day pass |
| **Peak Streaming** | $10/mo | HD streaming + partner bundle |
| **Summit Rewards** | Free | Loyalty program (Bronze/Silver/Gold/Platinum) |

### 1.5 Network & Technology

- **Network Name**: The Data Cloud Network
- **Technology**: 5G (n77, n78, n261), LTE-A, VoLTE
- **Differentiator**: "Elastic Bandwidth" - automatic speed boost during congestion
- **App**: Snowmobile app (4.6★ rating, 15M+ downloads)

---

## 2. Problem Statement & Objectives

### 2.1 Business Challenge

Marketing and product teams at Snowmobile Wireless face significant risk when:
- Launching new products (5G plans, streaming bundles, IoT packages)
- Implementing price increases (often 3-5% annually due to inflation)
- Changing contract terms or fair usage policies
- Introducing loyalty programs or retention offers
- Responding to competitor moves (Verizon, AT&T, T-Mobile)

**Current Pain Points**:
- Focus groups are expensive ($15-50K per study) and slow (4-6 weeks)
- A/B testing requires live customers and risks churn
- Historical data analysis shows what happened, not what will happen
- Surveys have response bias and low completion rates

### 2.2 Solution: Customer Digital Twin

Create AI-powered "digital twins" of customer segments that can:
- Answer questions in natural language as if they were real customers
- Predict sentiment and likely actions (upgrade, downgrade, churn, complain)
- Provide reasoning for their reactions
- Simulate responses across multiple scenarios simultaneously

### 2.3 Success Metrics

| Metric | Target |
|--------|--------|
| Prediction accuracy vs. historical outcomes | >75% |
| Time to insight (vs. focus groups) | <1 hour vs. 4-6 weeks |
| Cost per simulation | <$10 vs. $15-50K |
| Segments covered | 100% of customer base |
| User adoption (marketing team) | >80% weekly active |

---

## 3. Data Architecture

### 3.1 Data Model Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        SNOWMOBILE DATA ECOSYSTEM                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│   INTERNAL DATA (1st Party)              EXTERNAL DATA (3rd Party)          │
│   ─────────────────────────              ──────────────────────────          │
│   ┌──────────────────────┐               ┌──────────────────────┐           │
│   │   CUSTOMERS          │               │   ZIP_DEMOGRAPHICS   │           │
│   │   1M records         │───────────────│   42K ZIP codes      │           │
│   │   (customer_id, zip) │    JOIN ON    │   (zip_code, income, │           │
│   └──────────────────────┘    ZIP CODE   │    density, age_dist)│           │
│                                          └──────────────────────┘           │
│   ┌──────────────────────┐               ┌──────────────────────┐           │
│   │   MONTHLY_USAGE      │               │   ECONOMIC_INDICATORS│           │
│   │   12M records        │               │   (cost_of_living,   │           │
│   └──────────────────────┘               │    unemployment)     │           │
│                                          └──────────────────────┘           │
│   ┌──────────────────────┐               ┌──────────────────────┐           │
│   │   SUPPORT_TICKETS    │               │   COMPETITIVE_INTEL  │           │
│   │   2M records         │               │   (market_share,     │           │
│   └──────────────────────┘               │    competitor_promos)│           │
│                                          └──────────────────────┘           │
│   ┌──────────────────────┐               ┌──────────────────────┐           │
│   │   CAMPAIGN_RESPONSES │               │   LIFESTYLE_SEGMENTS │           │
│   │   5M records         │               │   (tech_adoption,    │           │
│   └──────────────────────┘               │    media_habits)     │           │
│                                          └──────────────────────┘           │
│                                                                              │
│                              ▼                                               │
│              ┌───────────────────────────────────┐                          │
│              │     ENRICHED_CUSTOMER_360         │                          │
│              │     (Internal + External Join)    │                          │
│              └───────────────────────────────────┘                          │
│                              │                                               │
│              ┌───────────────┼───────────────┐                              │
│              ▼               ▼               ▼                              │
│   ┌──────────────┐  ┌──────────────┐  ┌──────────────┐                     │
│   │   SEGMENTS   │  │   PERSONAS   │  │    AGENTS    │                     │
│   │  (ML-driven) │  │ (LLM-generated)│ │   (Cortex)   │                     │
│   └──────────────┘  └──────────────┘  └──────────────┘                     │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 3.2 Data Volume Summary

| Dataset | Records | Source | Key Fields |
|---------|---------|--------|------------|
| **Customers** | 1,000,000 | Internal | customer_id, zip_code, plan, arpu |
| **Monthly Usage** | 12,000,000 | Internal | usage, billing, payment |
| **Support Interactions** | 2,000,000 | Internal | tickets, sentiment, resolution |
| **Campaign Responses** | 5,000,000 | Internal | campaigns, responses, conversions |
| **ZIP Demographics** | 42,000 | External | census, income, density |
| **Economic Indicators** | 42,000 | External | cost of living, unemployment |
| **Competitive Intel** | 210 (DMAs) | External | market share, competitor pricing |
| **Lifestyle Segments** | 42,000 | External | tech adoption, media habits |

---

## 4. External Data Specifications

### 4.1 ZIP Demographics (Census-Based)

**Purpose**: Enrich customer profiles with neighborhood-level demographic context.

**Key Fields**:
- Population metrics (total, density, urban/rural classification)
- Age distribution (% by age bracket, median age)
- Income levels (median household, per capita, distribution brackets)
- Education attainment (high school, bachelor's, graduate)
- Housing characteristics (owner vs renter, home values, rent)
- Household composition (family size, married, single parent)
- Employment (labor force participation, white/blue collar)

**Sample Data Distribution (US Reality-Based)**:
- Median household income: $35K - $250K (national median ~$75K)
- Population density: 1 - 70,000 per sq mile
- Urban: 30%, Suburban: 50%, Rural: 18%, Remote: 2%

### 4.2 Economic Indicators

**Purpose**: Understand local economic conditions that affect price sensitivity and churn risk.

**Key Fields**:
- Cost of Living Index (100 = national average, range 70-180)
- Component indices (housing, utilities, transportation, groceries, healthcare)
- Employment metrics (unemployment rate, job growth)
- Economic health (poverty rate, food insecurity, uninsured rate)
- Housing market (price growth, rent growth, vacancy)
- Consumer behavior (credit scores, debt-to-income, retail spending)

**Key Correlations**:
- High cost of living → Higher ARPU tolerance, but more price sensitivity to increases
- High unemployment → Higher churn risk, more prepaid preference
- Good credit scores → Higher postpaid adoption, lower payment issues

### 4.3 Competitive Intelligence

**Purpose**: Understand competitive pressure by market area.

**Key Fields**:
- Market size (total wireless subs, revenue, growth)
- Snowmobile position (subs, market share, NPS, coverage)
- Competitor positions (Verizon, AT&T, T-Mobile - share, price, NPS, coverage)
- Regional competitors (Cricket, Metro, US Cellular)
- Competitive dynamics (concentration, price war intensity, recent promos)

**Example Markets**:
| DMA | Market | Snowmobile Share | Top Competitor | Competitive Intensity |
|-----|--------|------------------|----------------|----------------------|
| 501 | New York | 15% | Verizon (32%) | High |
| 803 | Los Angeles | 19% | T-Mobile (28%) | High |
| 602 | Chicago | 21% | AT&T (26%) | Medium |
| 511 | Denver | 28% | T-Mobile (24%) | Medium |
| 820 | Seattle | 24% | T-Mobile (30%) | High |

### 4.4 Lifestyle Segments (Psychographics)

**Purpose**: Understand customer values, behaviors, and preferences beyond demographics.

**Key Fields**:
- Lifestyle clusters (PRIZM-style segmentation)
- Technology adoption (tech score, smartphone %, iPhone/Android split, smart home, streaming)
- Digital behavior (screen time, social media, online shopping, mobile banking)
- Media consumption (streaming hours, gaming, news sources)
- Values & priorities (price sensitivity, brand loyalty, eco-consciousness, early adopter)
- Communication preferences (digital vs phone vs store vs chat)
- Wireless behaviors (data usage, lines per account, plan propensity)
- Churn propensity (deal seeker index, switching propensity, competitor awareness)

**Lifestyle Cluster Examples**:
| Cluster Name | Description | % of US | Key Traits |
|--------------|-------------|---------|------------|
| **Urban Tech Elite** | Young professionals in major metros | 8% | High income, iPhone, early adopters, low price sensitivity |
| **Suburban Family Focus** | Families in suburbs, multiple lines | 18% | Family plans, value stability, moderate tech |
| **Budget Maximizers** | Price-conscious across all areas | 15% | High price sensitivity, prepaid/MVNO switchers |
| **Silver Streamers** | 55+ discovering streaming/tech | 12% | Growing data use, need support, loyal |
| **Rural Reliability** | Rural areas, coverage-focused | 10% | Coverage > price, traditional, voice-heavy |
| **Young & Mobile** | 18-29, digital natives | 14% | Heavy data, social media, brand agnostic |
| **Small Biz Hustlers** | Self-employed, gig workers | 8% | Business use, reliability, expense-conscious |

---

## 5. Customer Data Schema (Internal)

### 5.1 Customer Master

The customer master table contains all account-level information:

**Identity & Location**:
- customer_id (UUID primary key)
- account_id
- zip_code (JOIN KEY to external tables)
- state_code, dma_code

**Demographics**:
- age, gender

**Account Details**:
- customer_since, tenure_months
- acquisition_channel (Retail/Online/Telesales/Partner)

**Current Plan**:
- plan_name (Flurry/Powder/Blizzard/Avalanche/Summit/Glacier)
- plan_category (Prepaid/Postpaid)
- plan_price, lines_on_account
- contract_type (NoContract/12M/24M/DevicePayment)
- contract_end_date

**Device**:
- device_brand, device_model, device_tier (Flagship/Mid/Budget)
- device_os (iOS/Android)
- device_age_months, is_5g_capable

**Financial**:
- monthly_arpu, lifetime_value, total_revenue_12m
- payment_method (AutoPay/Card/Manual/Cash)
- autopay_enrolled, paperless_billing, credit_class (A/B/C/D)

**Add-Ons**:
- has_device_protection (Snowpack Protection)
- has_intl_roaming (Altitude Roaming)
- has_streaming_bundle (Peak Streaming)

**Loyalty**:
- rewards_member (Summit Rewards)
- rewards_tier (Bronze/Silver/Gold/Platinum)
- rewards_points_balance

**Engagement**:
- app_user, app_engagement_score (0.00-1.00)
- last_app_login
- nps_score, nps_survey_date

**Risk Indicators**:
- churn_risk_score (0.00-1.00, ML predicted)
- predicted_churn_reason
- complaint_count_12m

### 5.2 Monthly Usage

Monthly aggregation of customer usage and billing:
- Voice (on-net, off-net, international minutes)
- Data (GB used, 4G/5G split, throttled days)
- Messaging (SMS, MMS)
- Roaming (days, data, voice)
- Billing (base, overage, roaming, add-ons, discounts, total)
- Payment (status, days to payment)

### 5.3 Support Interactions

Customer service touchpoints:
- Channel (App/Chat/Call/Email/Store/Social)
- Category (Billing/Technical/Sales/Complaint/General)
- Resolution (status, time, first contact resolution)
- Sentiment (score -1 to 1, CSAT 1-5)
- Content (summary, verbatim quotes)

### 5.4 Campaign Responses

Marketing campaign interactions:
- Campaign details (name, type, category, offer)
- Delivery (channel, sent time, delivered flag)
- Response (opened, clicked, responded, response type)
- Outcome (converted, conversion value)

---

## 6. Data-Driven Segmentation

### 6.1 Approach

**Method**: Hybrid approach combining:
1. **Feature Engineering** - Create rich features from internal + external data
2. **K-Means Clustering** - Discover natural customer groupings
3. **Business Labeling** - Map clusters to meaningful segment names

### 6.2 Enriched Feature Set

Features for clustering include:

**Internal Features**:
- Tenure, ARPU, lifetime value, lines on account
- Data usage, voice usage, usage trends
- App engagement, support contacts, sentiment
- Churn risk, complaint count

**External Enrichment**:
- ZIP demographics (income, density, urban/rural, education)
- Economic indicators (cost of living, unemployment, credit scores)
- Competitive landscape (market share, price war intensity)
- Lifestyle (tech adoption, price sensitivity, brand loyalty)

**Derived Features**:
- Price position ratio (ARPU vs competitor avg)
- Wallet share (ARPU as % of household income)
- Monthly value (LTV / tenure)
- Adjusted churn risk (base risk × local factors × competition)

### 6.3 Target Segments

After clustering and business labeling, 8 segments emerge:

| Segment | Name | % | Avg ARPU | Key Data Signals |
|---------|------|---|----------|------------------|
| S1 | **Value Seekers** | 20% | $38 | High price_sensitivity, low tenure, prepaid/Glacier plans |
| S2 | **Data Streamers** | 16% | $72 | High data_usage (35GB+), high tech_adoption, Blizzard plan |
| S3 | **Family Connectors** | 18% | $125 | 3+ lines, suburban, Avalanche plan, family_lifestyle |
| S4 | **Steady Loyalists** | 15% | $52 | High tenure (4yr+), low churn_risk, voice-heavy |
| S5 | **Premium Techies** | 10% | $95 | Flagship devices, iOS, Summit plan, early_adopter high |
| S6 | **Rural Reliables** | 8% | $48 | Rural zips, coverage-focused, moderate data |
| S7 | **Young Digitals** | 9% | $55 | Age 18-29, high social/streaming, high switch propensity |
| S8 | **At-Risk Defectors** | 4% | $45 | High churn_risk, recent complaints, competitor research |

---

## 7. Persona Generation System

### 7.1 Process Overview

```
┌─────────────────────────────────────────────────────────────────────┐
│                    DATA-DRIVEN PERSONA CREATION                      │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  STEP 1: Aggregate Segment Statistics                               │
│  ────────────────────────────────────                               │
│  • Demographics: age distribution, gender split, income range       │
│  • Geography: top states, urban/rural mix, top DMAs                 │
│  • Behavior: avg ARPU, data usage, tenure, churn risk              │
│  • External: lifestyle cluster, tech adoption, price sensitivity    │
│                                                                      │
│  STEP 2: Extract Representative Verbatims                           │
│  ────────────────────────────────────────                           │
│  • Sample support ticket comments from segment                      │
│  • NPS survey feedback                                              │
│  • Campaign response patterns                                       │
│                                                                      │
│  STEP 3: Generate Persona with Cortex LLM                          │
│  ────────────────────────────────────────                           │
│  • Feed statistics + verbatims to llama3.1-70b                     │
│  • Generate personality, communication style, triggers              │
│  • Create realistic backstory grounded in data                      │
│                                                                      │
│  STEP 4: Validate & Refine                                          │
│  ────────────────────────────────────────                           │
│  • Human review for believability                                   │
│  • Test against historical scenarios                                │
│  • Iterate prompt until persona passes "smell test"                 │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

### 7.2 Persona Components

Each persona includes:

| Component | Description |
|-----------|-------------|
| **Name & Snapshot** | Realistic name, age, location, 2-sentence summary |
| **Background Story** | Life situation, why they chose Snowmobile |
| **Relationship with Service** | How important mobile is, usage patterns, tech savviness |
| **Financial Mindset** | Bill tolerance, price increase reaction, decision factors |
| **Communication Style** | Preferred channels, tone, frustration expression |
| **Hot Buttons** | What makes them happy/angry/indifferent |
| **Sample Quotes** | Realistic things they'd say in various situations |

### 7.3 Example Persona: Family Connectors

**Name**: Michelle Torres, 41  
**Location**: Gilbert, AZ (suburban Phoenix)  
**Tagline**: "The family's wireless lifeline who makes sure everyone stays connected without breaking the bank"

**Background Story**:
Michelle is a project manager at a healthcare company, married with three kids (15, 12, 8). She switched to Snowmobile two years ago for the Avalanche family plan after her previous carrier kept raising prices. She manages four lines plus a tablet, juggling her teenagers' data usage while trying to keep the monthly bill predictable.

**Relationship with Snowmobile**:
Michelle sees her wireless bill as a necessary household utility—important but shouldn't be a luxury. She chose Snowmobile for the family plan value and the app that lets her monitor her kids' usage. She's moderately tech-savvy but doesn't have time to troubleshoot. The app is her primary interface.

**Financial Mindset**:
- Bill tolerance: $140-160/month acceptable; over $175 triggers concern
- Price increase reaction: Will analyze if value is added; pure increases feel unfair
- Quote: "I don't mind paying for good service, but don't nickel-and-dime me with hidden fees"

**Communication Style**:
- Prefers: App and chat (quick, documented)
- Avoids: Phone calls (time-consuming, often on hold)
- Tone: Direct, practical, expects competence

**Hot Buttons**:
- HAPPY: Bill credits for issues, family perks (Disney+), easy parental controls
- ANGRY: Surprise charges, coverage gaps during travel, long hold times
- IGNORES: 5G hype, device upgrade offers (kids don't need flagships)

---

## 8. Agent Architecture

### 8.1 Design Philosophy

Each persona agent is a **stateful, context-aware LLM agent** that:
- Maintains consistent personality across interactions
- Retrieves relevant historical context via RAG
- Provides structured responses (reaction + reasoning + confidence)
- Can participate in multi-agent simulations

### 8.2 Interaction Flow

```
┌─────────────────────────────────────────────────────────────────────┐
│                        USER QUERY                                    │
│  "How would customers react to a $5/month price increase on         │
│   Blizzard plans, with Disney+ included free?"                      │
└────────────────────────────┬────────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    QUERY PROCESSING                                  │
│  1. Extract scenario parameters (price: +$5, value-add: Disney+)    │
│  2. Identify relevant segments (Blizzard plan holders)              │
│  3. Retrieve historical context (past price increases)              │
└────────────────────────────┬────────────────────────────────────────┘
                             │
              ┌──────────────┼──────────────┐
              ▼              ▼              ▼
┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐
│  Value Seeker   │ │ Data Streamer   │ │ Premium Techie  │
│     Agent       │ │     Agent       │ │     Agent       │
├─────────────────┤ ├─────────────────┤ ├─────────────────┤
│ • Load persona  │ │ • Load persona  │ │ • Load persona  │
│ • Add context   │ │ • Add context   │ │ • Add context   │
│ • Generate      │ │ • Generate      │ │ • Generate      │
│   response      │ │   response      │ │   response      │
└────────┬────────┘ └────────┬────────┘ └────────┬────────┘
         │                   │                   │
         ▼                   ▼                   ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    RESPONSE AGGREGATION                              │
│                                                                      │
│  Segment         Reaction    Churn Risk   Confidence   Key Quote    │
│  ─────────────   ────────    ──────────   ──────────   ──────────   │
│  Value Seeker    Negative    +5.2%        High         "Another     │
│                  (-0.7)                                increase..."  │
│  Data Streamer   Neutral     +0.8%        Medium       "Disney+     │
│                  (+0.1)                                is nice"      │
│  Premium Techie  Positive    -0.3%        High         "Fair deal"  │
│                  (+0.5)                                              │
│                                                                      │
│  OVERALL IMPACT: Weighted avg churn risk +2.1%                      │
│  RECOMMENDATION: Consider grandfather clause for Value Seekers      │
└─────────────────────────────────────────────────────────────────────┘
```

### 8.3 Response Structure

Each agent response includes:
- **initial_reaction**: Emotional response in character (1-2 sentences)
- **sentiment_score**: Number from -1.0 (very negative) to 1.0 (very positive)
- **likely_action**: ACCEPT / IGNORE / COMPLAIN / THREATEN_CHURN / CHURN / UPGRADE / DOWNGRADE
- **action_probability**: 0.0 to 1.0
- **reasoning**: Why they'd react this way (2-3 sentences)
- **what_would_change_mind**: What company could do differently
- **sample_verbatim**: What they'd say to customer service

---

## 9. Scenario Templates

### 9.1 Price Increase

```
Snowmobile is announcing a {X}% price increase on {plan_types} plans, effective {date}.
The increase is {justification}.
{Optional: We are including {value_add} as part of this change.}
Customers will receive {notice_period} days notice via {channels}.
```

### 9.2 New Product Launch

```
Snowmobile is launching {product_name}, a new {product_category}.
Key features: {feature_list}
Price point: {price} per month
Target customers: {target_description}
Launch date: {date}
Promotional offer: {promo_details}
```

### 9.3 Competitor Response

```
{Competitor_name} has announced {their_offer}.
Key details: {offer_details}
Their price point: {price}
This affects our {affected_segments} customers.
What should we expect from our customers?
```

### 9.4 Policy Change

```
Snowmobile is changing its {policy_area} policy.
Current policy: {current}
New policy: {new}
Reason: {justification}
Effective date: {date}
```

---

## 10. Success Criteria

### 10.1 POC Success (Week 3)
- [ ] 8 distinct, data-validated customer segments
- [ ] Personas pass "believability test" with marketing team
- [ ] Can simulate 5+ scenario types
- [ ] Response time < 30 seconds for single query
- [ ] Basic Streamlit app functional

### 10.2 Production Success (Month 2)
- [ ] External data enrichment demonstrably improves segment quality
- [ ] Prediction accuracy validated > 70% against historical outcomes
- [ ] 10+ marketing team members trained
- [ ] Used for at least 2 real business decisions
- [ ] Positive user feedback (NPS > 30)

---

## Appendix A: Glossary

| Term | Definition |
|------|------------|
| ARPU | Average Revenue Per User - monthly revenue per customer |
| Churn | Customer leaving/cancelling service |
| Cortex | Snowflake's AI/ML platform |
| Digital Twin | AI simulation of a real-world entity |
| DMA | Designated Market Area - geographic regions for media markets |
| NPS | Net Promoter Score - customer loyalty metric (-100 to +100) |
| RAG | Retrieval Augmented Generation - LLM + knowledge base |
| Segment | Group of customers with similar characteristics |
| Persona | Fictional representative of a customer segment |
| ZIP-5 | 5-digit US ZIP code (42,000+ unique codes) |

---

## Appendix B: References

- US Census Bureau American Community Survey (demographic distributions)
- Bureau of Labor Statistics (employment, cost of living)
- CTIA Wireless Industry Report (market size, trends)
- J.D. Power Wireless Customer Satisfaction Study (NPS benchmarks)
- Claritas PRIZM (lifestyle segmentation methodology)


