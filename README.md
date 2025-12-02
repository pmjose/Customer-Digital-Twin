# ❄️ Snowmobile Wireless - Customer Digital Twin

**AI-Powered Customer Personas for Marketing Simulation**

A Snowflake Cortex-powered system that creates intelligent AI persona agents representing B2C telecom customer segments. These agents simulate realistic customer reactions to product launches, price changes, and marketing campaigns.

![Snowmobile Digital Twin](https://via.placeholder.com/800x400/29B5E8/FFFFFF?text=Snowmobile+Digital+Twin)

---

## 🎯 Overview

### The Problem

Marketing and product teams at telecom operators face significant risk when:
- Launching new products (5G plans, streaming bundles)
- Implementing price increases
- Changing contract terms or policies
- Responding to competitor moves

Traditional methods (focus groups, A/B tests) are expensive, slow, and risky.

### The Solution

**Customer Digital Twin** creates AI-powered "digital twins" of customer segments that can:
- Answer questions in natural language as if they were real customers
- Predict sentiment and likely actions (upgrade, downgrade, churn, complain)
- Provide reasoning for their reactions
- Simulate responses across multiple scenarios simultaneously

### Key Capabilities

| Feature | Description |
|---------|-------------|
| 🎭 **8 AI Personas** | Data-driven personas representing distinct customer segments |
| 🧠 **Cortex-Powered** | Uses Snowflake Cortex LLM for realistic, contextual responses |
| 📊 **Data Enrichment** | Internal + external data (demographics, economic, competitive) |
| 🎯 **Scenario Simulation** | Test pricing, products, policies across all personas |
| 📱 **Streamlit App** | Interactive UI for business users |
| 📓 **Lab Notebook** | Hands-on workshop for learning |

---

## 🏢 Company Profile: Snowmobile Wireless

| Attribute | Details |
|-----------|---------|
| **Company** | Snowmobile Wireless |
| **Tagline** | "Your Data, Boundless" |
| **Headquarters** | Bozeman, Montana |
| **Subscribers** | 28 million (B2C) |
| **Market Share** | 18% (4th largest US carrier) |

### Plans

| Plan | Price | Data | Target |
|------|-------|------|--------|
| Glacier | $25/mo | 2GB | Budget/Prepaid |
| Flurry | $35/mo | 5GB | Light Users |
| Powder | $55/mo | 15GB | Standard |
| Blizzard | $75/mo | Unlimited | Heavy Users |
| Avalanche | $140/mo | Unlimited x4 | Families |
| Summit | $95/mo | Unlimited+ | Premium |

---

## 👥 Customer Segments

| Segment | Name | % | ARPU | Key Traits |
|---------|------|---|------|------------|
| S1 | **Value Seekers** | 20% | $38 | Price-sensitive, deal-seeking |
| S2 | **Data Streamers** | 16% | $72 | Heavy data, streaming-focused |
| S3 | **Family Connectors** | 18% | $125 | Multi-line, family plans |
| S4 | **Steady Loyalists** | 15% | $52 | Long tenure, change-resistant |
| S5 | **Premium Techies** | 10% | $95 | Early adopters, quality-focused |
| S6 | **Rural Reliables** | 8% | $48 | Coverage-focused, traditional |
| S7 | **Young Digitals** | 9% | $55 | Gen Z, social-first |
| S8 | **At-Risk Defectors** | 4% | $45 | High churn risk, frustrated |

---

## 📁 Project Structure

```
Customer-Digital-Twin/
├── docs/
│   ├── design.md                    # Design document
│   └── architecture.md              # Technical architecture
├── sql/
│   ├── 01_setup_database.sql        # Database & schemas
│   ├── 02_create_internal_tables.sql
│   ├── 03_create_external_tables.sql
│   ├── 04_create_stages.sql
│   ├── 05_load_data.sql
│   ├── 06_create_enriched_views.sql
│   ├── 07_segmentation_pipeline.sql
│   ├── 08_persona_generation.sql
│   └── 09_agent_functions.sql
├── notebooks/
│   └── Snowmobile_Digital_Twin_Lab.ipynb
├── streamlit/
│   └── Snowmobile_Digital_Twin.py
├── data_generator/
│   ├── requirements.txt
│   ├── config.py
│   ├── generate_all_data.py
│   └── generators/
│       ├── customer_generator.py
│       ├── usage_generator.py
│       ├── interaction_generator.py
│       ├── campaign_generator.py
│       ├── zip_demographics_generator.py
│       ├── economic_generator.py
│       ├── competitive_generator.py
│       └── lifestyle_generator.py
├── data/                            # Generated CSVs (gitignored)
│   ├── internal/
│   └── external/
└── README.md
```

---

## 🚀 Quick Start

### Prerequisites

- Snowflake Enterprise or Business Critical account
- Cortex AI enabled in your region
- Python 3.8+ (for data generation)
- ACCOUNTADMIN role or equivalent

### Step 1: Set Up Snowflake

```sql
-- Run SQL scripts in order
-- 01_setup_database.sql
-- 02_create_internal_tables.sql
-- 03_create_external_tables.sql
-- 04_create_stages.sql
```

### Step 2: Load Data from S3

**Data is pre-staged in a public S3 bucket!** No need to generate or upload data manually.

```
S3 Location: s3://pjose-public/Customer-Digital-Twin/data/
```

```sql
-- Run 05_load_data.sql (loads from S3 automatically)
-- This loads ~17.8M records from S3 into Snowflake tables
```

**Alternative: Generate Your Own Data**

```bash
cd data_generator
pip install -r requirements.txt

# Generate 1M customers (full dataset - ~35 min)
python generate_all_data.py --customers 1000000 --seed 42

# Or generate 100K customers (quick test - ~5 min)
python generate_all_data.py --customers 100000 --seed 42
```

### Step 3: Build Analytics Pipeline

```sql
-- Run these in order:
-- 06_create_enriched_views.sql   (Join internal + external data)
-- 07_segmentation_pipeline.sql   (K-Means clustering)
-- 08_persona_generation.sql      (Generate AI personas from segments)
-- 09_agent_functions.sql         (Create persona interaction functions)
```

### Step 4: Deploy Streamlit App

1. Go to Snowsight → Streamlit
2. Create new app
3. Upload `streamlit/Snowmobile_Digital_Twin.py`
4. Configure warehouse: `CDT_APP_WH`

---

## 💬 Using the Personas

### Ask a Single Persona

```sql
SELECT AGENTS.ASK_PERSONA(
    (SELECT persona_id FROM PERSONAS.PERSONA_DEFINITIONS WHERE segment_id = 'S1'),
    'Snowmobile is raising prices by $5/month. Disney+ will be included free.'
);
```

### Run Multi-Persona Simulation

```sql
CALL AGENTS.SIMULATE_SCENARIO(
    'We are announcing a 5% price increase on all postpaid plans effective April 1.',
    'Pricing',
    NULL  -- All segments
);
```

### Sample Response

```json
{
  "initial_reaction": "Another price increase? This is exactly why I left AT&T!",
  "sentiment_score": -0.72,
  "likely_action": "COMPLAIN",
  "action_probability": 0.65,
  "reasoning": "I chose Snowmobile specifically for the low prices...",
  "what_would_change_mind": "A loyalty discount for existing customers",
  "sample_verbatim": "I want to cancel. What can you offer me to stay?"
}
```

---

## 📊 Data Architecture

### ☁️ Pre-Staged Data in S3

**Data is already available in a public S3 bucket - no generation needed!**

```
S3 Bucket: s3://pjose-public/Customer-Digital-Twin/data/
├── internal/
│   ├── customers.csv           (1M records, 256 MB)
│   ├── monthly_usage.csv       (9.3M records, 1.4 GB)
│   ├── support_interactions.csv (2.1M records, 613 MB)
│   └── campaign_responses.csv   (5.3M records, 1.1 GB)
└── external/
    ├── zip_demographics.csv     (42K records, 11 MB)
    ├── economic_indicators.csv  (42K records, 5 MB)
    ├── competitive_landscape.csv (210 records, 37 KB)
    └── lifestyle_segments.csv   (42K records, 8 MB)
```

The SQL scripts automatically create an external stage pointing to this S3 location.

### Alternative: Generate Your Own Data

If you want to generate fresh synthetic data:

```bash
cd data_generator
pip install -r requirements.txt
python generate_all_data.py --customers 1000000 --seed 42
```

### Internal Data (1st Party)

| File | Records | Size | Description |
|------|---------|------|-------------|
| `data/internal/customers.csv` | 1,000,000 | 256 MB | Customer master data: demographics, plans, devices, financial, engagement |
| `data/internal/monthly_usage.csv` | 9,288,388 | 1.4 GB | 12 months of usage: data GB, voice minutes, SMS, billing |
| `data/internal/support_interactions.csv` | 2,111,579 | 613 MB | Support tickets: channel, category, sentiment, resolution |
| `data/internal/campaign_responses.csv` | 5,286,390 | 1.1 GB | Marketing campaigns: offers, responses, conversions |

### External Data (3rd Party)

| File | Records | Size | Description |
|------|---------|------|-------------|
| `data/external/zip_demographics.csv` | 42,000 | 11 MB | Census data: income, age, education, housing by ZIP |
| `data/external/economic_indicators.csv` | 42,000 | 5 MB | Economic health: cost of living, unemployment, credit |
| `data/external/competitive_landscape.csv` | 210 | 37 KB | Market share by DMA: Verizon, AT&T, T-Mobile, regional |
| `data/external/lifestyle_segments.csv` | 42,000 | 8.3 MB | Psychographics: tech adoption, price sensitivity, lifestyle |

### Data Summary

| Metric | Value |
|--------|-------|
| **Total Records** | ~17.8 million |
| **Total Size** | ~3.4 GB |
| **Generation Time** | ~35 minutes |
| **Seed** | 42 (reproducible) |

### Customer Data Fields

The `customers.csv` includes 40+ fields:

| Category | Fields |
|----------|--------|
| **Identity** | `customer_id`, `account_id` |
| **Location** | `zip_code`, `state_code`, `dma_code` |
| **Demographics** | `age`, `gender` |
| **Account** | `customer_since`, `tenure_months`, `acquisition_channel` |
| **Plan** | `plan_name`, `plan_category`, `plan_price`, `lines_on_account`, `contract_type` |
| **Device** | `device_brand`, `device_model`, `device_tier`, `device_os`, `is_5g_capable` |
| **Financial** | `monthly_arpu`, `lifetime_value`, `payment_method`, `autopay_enrolled`, `credit_class` |
| **Add-ons** | `has_device_protection`, `has_intl_roaming`, `has_streaming_bundle` |
| **Loyalty** | `rewards_member`, `rewards_tier`, `rewards_points_balance` |
| **Engagement** | `app_user`, `app_engagement_score`, `nps_score` |
| **Risk** | `churn_risk_score`, `predicted_churn_reason`, `complaint_count_12m` |

---

## 🔧 Configuration

### Cortex Models Used

| Model | Purpose |
|-------|---------|
| `llama3.1-70b` | Persona generation, scenario responses |
| `llama3.1-8b` | Quick reactions (lab/testing) |
| `e5-base-v2` | Text embeddings for RAG |

### Warehouse Sizing

| Warehouse | Size | Purpose |
|-----------|------|---------|
| CDT_LOAD_WH | MEDIUM | Data loading |
| CDT_ML_WH | LARGE | Clustering |
| CDT_CORTEX_WH | MEDIUM | LLM calls |
| CDT_APP_WH | X-SMALL | Streamlit |

---

## 📈 Cost Estimates

### Daily Operation (Active Use)

| Component | Est. Cost |
|-----------|-----------|
| Compute (credits) | ~$15-25 |
| Cortex AI (tokens) | ~$10-15 |
| Storage | ~$1-2 |
| **Total** | **~$25-40/day** |

---

## 🧪 Lab Workshop

The included Jupyter notebook (`notebooks/Snowmobile_Digital_Twin_Lab.ipynb`) provides a 3-hour hands-on workshop covering:

1. Environment Setup (10 min)
2. Data Loading (20 min)
3. Data Exploration (15 min)
4. External Data Join (15 min)
5. Feature Engineering (20 min)
6. Segmentation (25 min)
7. Persona Generation (25 min)
8. Agent Functions (20 min)
9. Full Simulation (20 min)
10. Streamlit Preview (10 min)

---

## 📚 Documentation

- [Design Document](docs/design.md) - Business requirements and personas
- [Architecture Document](docs/architecture.md) - Technical implementation details

---

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

---

## 📄 License

This project is for demonstration purposes. All company names and data are fictional.

---

## 🙏 Acknowledgments

- Snowflake Cortex AI team
- Telecom industry research sources
- US Census Bureau (demographic distributions)

---

**Built with ❄️ Snowflake Cortex**
