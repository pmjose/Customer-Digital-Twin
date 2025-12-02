"""
Snowmobile Wireless - Customer Digital Twin
Configuration file for synthetic data generation

This file contains all distribution parameters and constants used to generate
realistic telecom customer data for a US Tier 1 carrier.
"""

from datetime import date

# =============================================================================
# GENERAL CONFIGURATION
# =============================================================================

RANDOM_SEED = 42  # For reproducibility
OUTPUT_DIR = "../data"

# Record counts
CUSTOMER_CONFIG = {
    "total_records": 1_000_000,
    "months_of_usage": 12,
    "avg_interactions_per_customer": 2.0,
    "avg_campaigns_per_customer": 5.0,
}

EXTERNAL_CONFIG = {
    "zip_codes": 42_000,
    "dmas": 210,
}

# =============================================================================
# US GEOGRAPHIC DISTRIBUTION
# =============================================================================

# State distribution (weighted by US population)
STATE_DISTRIBUTION = {
    "CA": 0.118,  # California
    "TX": 0.088,  # Texas
    "FL": 0.066,  # Florida
    "NY": 0.059,  # New York
    "PA": 0.039,  # Pennsylvania
    "IL": 0.038,  # Illinois
    "OH": 0.035,  # Ohio
    "GA": 0.033,  # Georgia
    "NC": 0.032,  # North Carolina
    "MI": 0.030,  # Michigan
    "NJ": 0.028,  # New Jersey
    "VA": 0.026,  # Virginia
    "WA": 0.024,  # Washington
    "AZ": 0.023,  # Arizona
    "MA": 0.021,  # Massachusetts
    "TN": 0.021,  # Tennessee
    "IN": 0.020,  # Indiana
    "MD": 0.019,  # Maryland
    "MO": 0.018,  # Missouri
    "WI": 0.017,  # Wisconsin
    "CO": 0.018,  # Colorado
    "MN": 0.017,  # Minnesota
    "SC": 0.016,  # South Carolina
    "AL": 0.015,  # Alabama
    "LA": 0.014,  # Louisiana
    "KY": 0.013,  # Kentucky
    "OR": 0.013,  # Oregon
    "OK": 0.012,  # Oklahoma
    "CT": 0.011,  # Connecticut
    "UT": 0.010,  # Utah
    "IA": 0.009,  # Iowa
    "NV": 0.010,  # Nevada
    "AR": 0.009,  # Arkansas
    "MS": 0.009,  # Mississippi
    "KS": 0.009,  # Kansas
    "NM": 0.006,  # New Mexico
    "NE": 0.006,  # Nebraska
    "ID": 0.006,  # Idaho
    "WV": 0.005,  # West Virginia
    "HI": 0.004,  # Hawaii
    "NH": 0.004,  # New Hampshire
    "ME": 0.004,  # Maine
    "MT": 0.003,  # Montana
    "RI": 0.003,  # Rhode Island
    "DE": 0.003,  # Delaware
    "SD": 0.003,  # South Dakota
    "ND": 0.002,  # North Dakota
    "AK": 0.002,  # Alaska
    "VT": 0.002,  # Vermont
    "WY": 0.002,  # Wyoming
    "DC": 0.002,  # District of Columbia
}

REGION_MAPPING = {
    "CA": "West", "WA": "West", "OR": "West", "NV": "West", "AZ": "Southwest",
    "UT": "West", "CO": "West", "ID": "West", "MT": "West", "WY": "West",
    "AK": "West", "HI": "West", "NM": "Southwest",
    "TX": "Southwest", "OK": "Southwest",
    "NY": "Northeast", "NJ": "Northeast", "PA": "Northeast", "MA": "Northeast",
    "CT": "Northeast", "RI": "Northeast", "VT": "Northeast", "NH": "Northeast",
    "ME": "Northeast", "DE": "Northeast", "MD": "Northeast", "DC": "Northeast",
    "FL": "Southeast", "GA": "Southeast", "NC": "Southeast", "SC": "Southeast",
    "VA": "Southeast", "WV": "Southeast", "KY": "Southeast", "TN": "Southeast",
    "AL": "Southeast", "MS": "Southeast", "LA": "Southeast", "AR": "Southeast",
    "IL": "Midwest", "OH": "Midwest", "MI": "Midwest", "IN": "Midwest",
    "WI": "Midwest", "MN": "Midwest", "IA": "Midwest", "MO": "Midwest",
    "KS": "Midwest", "NE": "Midwest", "SD": "Midwest", "ND": "Midwest",
}

URBAN_RURAL_DISTRIBUTION = {
    "Urban": 0.30,
    "Suburban": 0.50,
    "Rural": 0.18,
    "Remote": 0.02,
}

# =============================================================================
# CUSTOMER DEMOGRAPHICS
# =============================================================================

AGE_DISTRIBUTION = {
    "18-24": {"pct": 0.12, "min": 18, "max": 24},
    "25-34": {"pct": 0.22, "min": 25, "max": 34},
    "35-44": {"pct": 0.20, "min": 35, "max": 44},
    "45-54": {"pct": 0.18, "min": 45, "max": 54},
    "55-64": {"pct": 0.15, "min": 55, "max": 64},
    "65+": {"pct": 0.13, "min": 65, "max": 85},
}

GENDER_DISTRIBUTION = {
    "M": 0.48,
    "F": 0.50,
    "Other": 0.01,
    "Unknown": 0.01,
}

ACQUISITION_CHANNEL_DISTRIBUTION = {
    "Retail Store": 0.35,
    "Online": 0.30,
    "Telesales": 0.15,
    "Partner": 0.12,
    "Referral": 0.08,
}

# =============================================================================
# SNOWMOBILE PLANS
# =============================================================================

PLAN_CONFIG = {
    "Glacier": {
        "price": 25, "category": "Prepaid", "data_gb": 2,
        "weight": 0.12, "contract_types": ["NoContract"],
        "typical_arpu_range": (20, 35),
    },
    "Flurry": {
        "price": 35, "category": "Postpaid", "data_gb": 5,
        "weight": 0.15, "contract_types": ["NoContract", "12M"],
        "typical_arpu_range": (30, 50),
    },
    "Powder": {
        "price": 55, "category": "Postpaid", "data_gb": 15,
        "weight": 0.30, "contract_types": ["NoContract", "12M", "24M", "DevicePayment"],
        "typical_arpu_range": (45, 75),
    },
    "Blizzard": {
        "price": 75, "category": "Postpaid", "data_gb": 999,  # Unlimited
        "weight": 0.22, "contract_types": ["12M", "24M", "DevicePayment"],
        "typical_arpu_range": (65, 95),
    },
    "Avalanche": {
        "price": 140, "category": "Postpaid", "data_gb": 999,  # Family unlimited
        "weight": 0.12, "contract_types": ["24M", "DevicePayment"],
        "typical_arpu_range": (120, 180),
        "min_lines": 3, "max_lines": 6,
    },
    "Summit": {
        "price": 95, "category": "Postpaid", "data_gb": 999,  # Premium unlimited
        "weight": 0.09, "contract_types": ["24M", "DevicePayment"],
        "typical_arpu_range": (85, 120),
    },
}

CONTRACT_TYPE_WEIGHTS = {
    "NoContract": 0.25,
    "12M": 0.20,
    "24M": 0.35,
    "DevicePayment": 0.20,
}

# =============================================================================
# DEVICES
# =============================================================================

DEVICE_BRANDS = {
    "Apple": {
        "weight": 0.52,
        "os": "iOS",
        "models": ["iPhone 15 Pro Max", "iPhone 15 Pro", "iPhone 15", "iPhone 14", "iPhone 13", "iPhone SE"],
        "tiers": {"Flagship": 0.35, "Mid": 0.45, "Budget": 0.20},
    },
    "Samsung": {
        "weight": 0.28,
        "os": "Android",
        "models": ["Galaxy S24 Ultra", "Galaxy S24", "Galaxy S23", "Galaxy A54", "Galaxy A34", "Galaxy A14"],
        "tiers": {"Flagship": 0.25, "Mid": 0.50, "Budget": 0.25},
    },
    "Google": {
        "weight": 0.08,
        "os": "Android",
        "models": ["Pixel 8 Pro", "Pixel 8", "Pixel 7a", "Pixel 7"],
        "tiers": {"Flagship": 0.40, "Mid": 0.50, "Budget": 0.10},
    },
    "Motorola": {
        "weight": 0.06,
        "os": "Android",
        "models": ["Edge+ 2024", "Edge 2024", "Moto G Power", "Moto G Stylus"],
        "tiers": {"Flagship": 0.10, "Mid": 0.40, "Budget": 0.50},
    },
    "OnePlus": {
        "weight": 0.03,
        "os": "Android",
        "models": ["OnePlus 12", "OnePlus 11", "Nord N30"],
        "tiers": {"Flagship": 0.50, "Mid": 0.40, "Budget": 0.10},
    },
    "Other": {
        "weight": 0.03,
        "os": "Android",
        "models": ["Basic Smartphone"],
        "tiers": {"Flagship": 0.05, "Mid": 0.25, "Budget": 0.70},
    },
}

# =============================================================================
# USAGE PATTERNS
# =============================================================================

# Data usage by plan (GB/month)
DATA_USAGE_BY_PLAN = {
    "Glacier": {"mean": 1.5, "std": 0.5, "max": 2.5},
    "Flurry": {"mean": 3.5, "std": 1.5, "max": 6},
    "Powder": {"mean": 10, "std": 5, "max": 18},
    "Blizzard": {"mean": 30, "std": 15, "max": 100},
    "Avalanche": {"mean": 45, "std": 20, "max": 150},
    "Summit": {"mean": 40, "std": 20, "max": 120},
}

# Voice usage (minutes/month)
VOICE_USAGE_BY_PLAN = {
    "Glacier": {"mean": 100, "std": 50},
    "Flurry": {"mean": 150, "std": 80},
    "Powder": {"mean": 200, "std": 100},
    "Blizzard": {"mean": 150, "std": 100},
    "Avalanche": {"mean": 300, "std": 150},
    "Summit": {"mean": 180, "std": 100},
}

# =============================================================================
# SUPPORT INTERACTIONS
# =============================================================================

SUPPORT_CHANNELS = {
    "App": 0.25,
    "Chat": 0.20,
    "Call": 0.30,
    "Email": 0.10,
    "Store": 0.10,
    "Social": 0.05,
}

SUPPORT_CATEGORIES = {
    "Billing": 0.30,
    "Technical": 0.25,
    "Sales": 0.15,
    "Complaint": 0.12,
    "General": 0.10,
    "Account": 0.08,
}

SUPPORT_SUBCATEGORIES = {
    "Billing": ["Payment Issue", "Bill Dispute", "Plan Change", "Refund Request", "Auto-pay Setup"],
    "Technical": ["No Service", "Slow Data", "Call Quality", "Voicemail", "5G Issues"],
    "Sales": ["Upgrade", "Add Line", "New Device", "Plan Comparison", "Promotion"],
    "Complaint": ["Service Quality", "Billing Error", "Wait Time", "Staff Behavior", "Coverage"],
    "General": ["Account Info", "Coverage Check", "Store Location", "App Help", "Other"],
    "Account": ["Password Reset", "Name Change", "Address Update", "Account Access", "Transfer"],
}

# =============================================================================
# CAMPAIGNS
# =============================================================================

CAMPAIGN_TYPES = {
    "Retention": {"weight": 0.25, "response_rate": 0.15, "conversion_rate": 0.08},
    "Upsell": {"weight": 0.30, "response_rate": 0.08, "conversion_rate": 0.04},
    "Cross-sell": {"weight": 0.15, "response_rate": 0.06, "conversion_rate": 0.03},
    "Win-back": {"weight": 0.10, "response_rate": 0.05, "conversion_rate": 0.02},
    "Loyalty": {"weight": 0.12, "response_rate": 0.12, "conversion_rate": 0.06},
    "Seasonal": {"weight": 0.08, "response_rate": 0.10, "conversion_rate": 0.05},
}

CAMPAIGN_CHANNELS = {
    "Email": 0.40,
    "SMS": 0.30,
    "App Push": 0.20,
    "Direct Mail": 0.05,
    "Call": 0.05,
}

# =============================================================================
# EXTERNAL DATA - ZIP DEMOGRAPHICS
# =============================================================================

# Income distribution parameters (national averages with variance)
INCOME_DISTRIBUTION = {
    "median_range": (35000, 250000),
    "national_median": 75000,
    "std": 25000,
}

# Education levels
EDUCATION_DISTRIBUTION = {
    "pct_high_school": {"mean": 88, "std": 8},
    "pct_some_college": {"mean": 60, "std": 15},
    "pct_bachelors": {"mean": 33, "std": 15},
    "pct_graduate": {"mean": 13, "std": 8},
}

# =============================================================================
# EXTERNAL DATA - ECONOMIC INDICATORS
# =============================================================================

COST_OF_LIVING_DISTRIBUTION = {
    "min": 70,
    "max": 180,
    "mean": 100,
    "std": 20,
}

UNEMPLOYMENT_DISTRIBUTION = {
    "min": 1.5,
    "max": 12.0,
    "mean": 4.0,
    "std": 1.5,
}

CREDIT_SCORE_DISTRIBUTION = {
    "min": 580,
    "max": 800,
    "mean": 710,
    "std": 50,
}

# =============================================================================
# EXTERNAL DATA - COMPETITIVE LANDSCAPE
# =============================================================================

# Market share by carrier (national averages)
CARRIER_MARKET_SHARE = {
    "Verizon": {"mean": 28, "std": 5},
    "AT&T": {"mean": 25, "std": 5},
    "T-Mobile": {"mean": 24, "std": 6},
    "Snowmobile": {"mean": 18, "std": 4},
    "Regional": {"mean": 5, "std": 3},
}

CARRIER_AVG_PRICE = {
    "Verizon": {"mean": 78, "std": 8},
    "AT&T": {"mean": 72, "std": 8},
    "T-Mobile": {"mean": 65, "std": 7},
    "Snowmobile": {"mean": 68, "std": 8},
    "Regional": {"mean": 45, "std": 10},
}

# =============================================================================
# EXTERNAL DATA - LIFESTYLE SEGMENTS
# =============================================================================

LIFESTYLE_CLUSTERS = [
    "Urban Tech Elite",
    "Suburban Family Focus",
    "Budget Maximizers",
    "Silver Streamers",
    "Rural Reliability",
    "Young & Mobile",
    "Small Biz Hustlers",
    "Connected Seniors",
    "Digital Minimalists",
    "Premium Professionals",
]

# Lifestyle cluster by urban/rural
LIFESTYLE_BY_GEOGRAPHY = {
    "Urban": {
        "Urban Tech Elite": 0.25,
        "Young & Mobile": 0.20,
        "Premium Professionals": 0.15,
        "Budget Maximizers": 0.15,
        "Small Biz Hustlers": 0.10,
        "Connected Seniors": 0.08,
        "Digital Minimalists": 0.07,
    },
    "Suburban": {
        "Suburban Family Focus": 0.35,
        "Premium Professionals": 0.15,
        "Silver Streamers": 0.15,
        "Young & Mobile": 0.10,
        "Connected Seniors": 0.10,
        "Budget Maximizers": 0.08,
        "Small Biz Hustlers": 0.07,
    },
    "Rural": {
        "Rural Reliability": 0.35,
        "Silver Streamers": 0.20,
        "Budget Maximizers": 0.15,
        "Connected Seniors": 0.12,
        "Digital Minimalists": 0.10,
        "Small Biz Hustlers": 0.08,
    },
    "Remote": {
        "Rural Reliability": 0.50,
        "Digital Minimalists": 0.20,
        "Silver Streamers": 0.15,
        "Budget Maximizers": 0.10,
        "Connected Seniors": 0.05,
    },
}

# Tech adoption by lifestyle
TECH_ADOPTION_BY_LIFESTYLE = {
    "Urban Tech Elite": {"mean": 85, "std": 8},
    "Suburban Family Focus": {"mean": 60, "std": 12},
    "Budget Maximizers": {"mean": 45, "std": 15},
    "Silver Streamers": {"mean": 50, "std": 15},
    "Rural Reliability": {"mean": 40, "std": 15},
    "Young & Mobile": {"mean": 80, "std": 10},
    "Small Biz Hustlers": {"mean": 65, "std": 12},
    "Connected Seniors": {"mean": 45, "std": 18},
    "Digital Minimalists": {"mean": 25, "std": 12},
    "Premium Professionals": {"mean": 75, "std": 10},
}

# =============================================================================
# CHURN RISK FACTORS
# =============================================================================

CHURN_RISK_WEIGHTS = {
    "tenure_factor": -0.02,  # Per month of tenure (longer = lower risk)
    "complaint_factor": 0.05,  # Per complaint
    "payment_issue_factor": 0.10,  # Per late payment
    "competitor_intensity_factor": 0.05,  # For high competition markets
    "price_sensitivity_factor": 0.003,  # Per price sensitivity point
    "base_risk": 0.15,  # Base churn probability
}

# =============================================================================
# OUTPUT FILE NAMES
# =============================================================================

OUTPUT_FILES = {
    "customers": "internal/customers.csv",
    "monthly_usage": "internal/monthly_usage.csv",
    "support_interactions": "internal/support_interactions.csv",
    "campaign_responses": "internal/campaign_responses.csv",
    "zip_demographics": "external/zip_demographics.csv",
    "economic_indicators": "external/economic_indicators.csv",
    "competitive_landscape": "external/competitive_landscape.csv",
    "lifestyle_segments": "external/lifestyle_segments.csv",
}


