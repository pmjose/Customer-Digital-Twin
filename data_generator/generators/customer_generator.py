"""
Snowmobile Wireless - Customer Generator
Generates synthetic customer master data
"""

import uuid
from datetime import date, timedelta
import numpy as np
import pandas as pd
from tqdm import tqdm
from faker import Faker

import sys
sys.path.append('..')
from config import (
    STATE_DISTRIBUTION, REGION_MAPPING, AGE_DISTRIBUTION, GENDER_DISTRIBUTION,
    ACQUISITION_CHANNEL_DISTRIBUTION, PLAN_CONFIG, CONTRACT_TYPE_WEIGHTS,
    DEVICE_BRANDS, CHURN_RISK_WEIGHTS
)

# Initialize Faker
fake = Faker('en_US')
Faker.seed(42)


def weighted_choice(distribution: dict) -> str:
    """Select from distribution based on weights"""
    items = list(distribution.keys())
    weights = list(distribution.values())
    return np.random.choice(items, p=weights)


def generate_age(age_dist: dict) -> int:
    """Generate age based on distribution"""
    bucket = weighted_choice({k: v["pct"] for k, v in age_dist.items()})
    return np.random.randint(age_dist[bucket]["min"], age_dist[bucket]["max"] + 1)


def generate_tenure() -> int:
    """Generate customer tenure in months (exponential distribution)"""
    # Most customers are newer, fewer are long-tenured
    tenure = int(np.random.exponential(24))  # Mean of 24 months
    return min(max(tenure, 1), 120)  # Cap at 10 years


def generate_device(plan_name: str) -> dict:
    """Generate device based on plan type"""
    # Premium plans more likely to have flagship devices
    if plan_name in ['Summit', 'Blizzard']:
        device_weights = {
            "Apple": 0.60, "Samsung": 0.25, "Google": 0.08,
            "Motorola": 0.04, "OnePlus": 0.02, "Other": 0.01
        }
    elif plan_name == 'Glacier':
        device_weights = {
            "Apple": 0.30, "Samsung": 0.35, "Google": 0.05,
            "Motorola": 0.15, "OnePlus": 0.02, "Other": 0.13
        }
    else:
        device_weights = {k: v["weight"] for k, v in DEVICE_BRANDS.items()}
    
    brand = weighted_choice(device_weights)
    brand_info = DEVICE_BRANDS[brand]
    
    model = np.random.choice(brand_info["models"])
    tier = weighted_choice(brand_info["tiers"])
    
    # 5G capable based on tier and model recency
    is_5g = tier == "Flagship" or (tier == "Mid" and np.random.random() < 0.6)
    
    return {
        "brand": brand,
        "model": model,
        "tier": tier,
        "os": brand_info["os"],
        "is_5g": is_5g,
        "age_months": np.random.randint(1, 36)
    }


def calculate_churn_risk(tenure: int, complaints: int, plan: str, 
                         price_sensitivity: float, competition_intensity: str) -> float:
    """Calculate churn risk score based on multiple factors"""
    risk = CHURN_RISK_WEIGHTS["base_risk"]
    
    # Tenure factor (longer tenure = lower risk)
    risk += CHURN_RISK_WEIGHTS["tenure_factor"] * tenure
    
    # Complaints factor
    risk += CHURN_RISK_WEIGHTS["complaint_factor"] * complaints
    
    # Competition intensity
    if competition_intensity == "High":
        risk += CHURN_RISK_WEIGHTS["competitor_intensity_factor"]
    
    # Price sensitivity
    risk += CHURN_RISK_WEIGHTS["price_sensitivity_factor"] * price_sensitivity
    
    # Plan factor (prepaid higher risk)
    if plan == "Glacier":
        risk += 0.10
    
    # Add some randomness
    risk += np.random.normal(0, 0.05)
    
    return max(0.01, min(0.99, risk))


def generate_customers(n_records: int, zip_df: pd.DataFrame, 
                       lifestyle_df: pd.DataFrame, competitive_df: pd.DataFrame) -> pd.DataFrame:
    """Generate synthetic customer data"""
    
    print(f"  Generating {n_records:,} customer records...")
    
    # Pre-compute ZIP code list and DMA mappings
    zip_codes = zip_df['zip_code'].tolist()
    zip_to_state = dict(zip(zip_df['zip_code'], zip_df['state_code']))
    zip_to_dma = dict(zip(zip_df['zip_code'], zip_df['dma_code']))
    
    # Get lifestyle data for price sensitivity
    zip_to_price_sens = dict(zip(lifestyle_df['zip_code'], lifestyle_df['price_sensitivity_index']))
    
    # Get competition intensity by DMA
    dma_to_competition = dict(zip(competitive_df['dma_code'], competitive_df['price_war_intensity']))
    
    records = []
    
    for _ in tqdm(range(n_records), desc="  Customers"):
        customer_id = str(uuid.uuid4())
        account_id = f"SNM{np.random.randint(10000000, 99999999)}"
        
        # Location - weighted by state population
        state = weighted_choice(STATE_DISTRIBUTION)
        # Get ZIP codes for this state
        state_zips = zip_df[zip_df['state_code'] == state]['zip_code'].tolist()
        if state_zips:
            zip_code = np.random.choice(state_zips)
        else:
            zip_code = np.random.choice(zip_codes)
        
        dma_code = zip_to_dma.get(zip_code, "500")
        
        # Demographics
        age = generate_age(AGE_DISTRIBUTION)
        gender = weighted_choice(GENDER_DISTRIBUTION)
        
        # Tenure and dates
        tenure_months = generate_tenure()
        customer_since = date.today() - timedelta(days=tenure_months * 30)
        
        # Acquisition channel
        acquisition_channel = weighted_choice(ACQUISITION_CHANNEL_DISTRIBUTION)
        
        # Plan selection (influenced by age and tenure)
        if age >= 55:
            plan_weights = {"Glacier": 0.10, "Flurry": 0.25, "Powder": 0.35, 
                          "Blizzard": 0.15, "Avalanche": 0.08, "Summit": 0.07}
        elif age <= 28:
            plan_weights = {"Glacier": 0.15, "Flurry": 0.10, "Powder": 0.30,
                          "Blizzard": 0.30, "Avalanche": 0.05, "Summit": 0.10}
        else:
            plan_weights = {k: v["weight"] for k, v in PLAN_CONFIG.items()}
        
        plan_name = weighted_choice(plan_weights)
        plan_info = PLAN_CONFIG[plan_name]
        
        # Lines on account
        if plan_name == "Avalanche":
            lines = np.random.randint(plan_info.get("min_lines", 3), 
                                     plan_info.get("max_lines", 6) + 1)
        elif age >= 35 and age <= 55 and np.random.random() < 0.3:
            lines = np.random.randint(2, 5)
        else:
            lines = 1
        
        # Contract type
        contract_type = np.random.choice(
            plan_info["contract_types"],
            p=[1/len(plan_info["contract_types"])] * len(plan_info["contract_types"])
        )
        
        # Contract end date
        if contract_type in ["12M", "24M"]:
            months = 12 if contract_type == "12M" else 24
            contract_end = date.today() + timedelta(days=np.random.randint(0, months * 30))
        elif contract_type == "DevicePayment":
            contract_end = date.today() + timedelta(days=np.random.randint(0, 24 * 30))
        else:
            contract_end = None
        
        # Device
        device = generate_device(plan_name)
        
        # Financial
        arpu_range = plan_info["typical_arpu_range"]
        monthly_arpu = round(np.random.uniform(arpu_range[0], arpu_range[1]), 2)
        if lines > 1:
            monthly_arpu = round(monthly_arpu * (1 + 0.6 * (lines - 1)), 2)
        
        lifetime_value = round(monthly_arpu * tenure_months * 0.85, 2)
        total_revenue_12m = round(monthly_arpu * min(12, tenure_months), 2)
        
        # Payment method
        payment_weights = {"AutoPay": 0.55, "Card": 0.25, "Manual": 0.15, "Cash": 0.05}
        if plan_name == "Glacier":
            payment_weights = {"AutoPay": 0.30, "Card": 0.30, "Manual": 0.25, "Cash": 0.15}
        payment_method = weighted_choice(payment_weights)
        autopay = payment_method == "AutoPay" or (payment_method == "Card" and np.random.random() < 0.5)
        paperless = autopay or np.random.random() < 0.6
        
        # Credit class
        credit_weights = {"A": 0.40, "B": 0.30, "C": 0.20, "D": 0.10}
        if plan_name in ["Summit", "Blizzard"]:
            credit_weights = {"A": 0.55, "B": 0.30, "C": 0.12, "D": 0.03}
        elif plan_name == "Glacier":
            credit_weights = {"A": 0.20, "B": 0.30, "C": 0.30, "D": 0.20}
        credit_class = weighted_choice(credit_weights)
        
        # Add-ons
        has_protection = np.random.random() < (0.4 if device["tier"] == "Flagship" else 0.15)
        has_roaming = np.random.random() < 0.08
        has_streaming = plan_name in ["Summit", "Blizzard"] and np.random.random() < 0.25
        
        # Loyalty
        rewards_member = tenure_months >= 6 and np.random.random() < 0.65
        if rewards_member:
            if tenure_months >= 48 and monthly_arpu >= 70:
                rewards_tier = np.random.choice(["Gold", "Platinum"], p=[0.6, 0.4])
            elif tenure_months >= 24:
                rewards_tier = np.random.choice(["Silver", "Gold"], p=[0.7, 0.3])
            else:
                rewards_tier = np.random.choice(["Bronze", "Silver"], p=[0.8, 0.2])
            rewards_points = np.random.randint(100, 10000)
        else:
            rewards_tier = None
            rewards_points = 0
        
        # Engagement
        app_user = np.random.random() < (0.8 if age <= 45 else 0.5)
        app_engagement = round(np.random.beta(2, 3), 2) if app_user else 0
        last_app_login = date.today() - timedelta(days=np.random.randint(0, 90)) if app_user else None
        
        # NPS
        nps_response = np.random.random() < 0.15  # 15% survey response rate
        if nps_response:
            # Skewed towards promoters for this company
            nps_score = int(np.random.choice(
                range(-100, 101),
                p=np.array([0.1 if i < 0 else (0.3 if i <= 30 else 0.6) 
                           for i in range(-100, 101)]) / sum([0.1 if i < 0 else (0.3 if i <= 30 else 0.6) 
                                                              for i in range(-100, 101)])
            ))
            # Simpler approach
            nps_score = int(np.random.normal(30, 35))
            nps_score = max(-100, min(100, nps_score))
            nps_date = date.today() - timedelta(days=np.random.randint(0, 180))
        else:
            nps_score = None
            nps_date = None
        
        # Complaints
        complaint_count = int(np.random.exponential(0.5))
        complaint_count = min(complaint_count, 10)
        
        # Churn risk
        price_sensitivity = zip_to_price_sens.get(zip_code, 50)
        competition = dma_to_competition.get(dma_code, "Medium")
        churn_risk = calculate_churn_risk(tenure_months, complaint_count, plan_name,
                                          price_sensitivity, competition)
        
        # Predicted churn reason
        if churn_risk > 0.5:
            reasons = ["Price", "Service Quality", "Competitor Offer", "Coverage", "Support Experience"]
            predicted_reason = np.random.choice(reasons, p=[0.35, 0.20, 0.25, 0.10, 0.10])
        else:
            predicted_reason = None
        
        record = {
            "customer_id": customer_id,
            "account_id": account_id,
            "zip_code": zip_code,
            "state_code": state,
            "dma_code": dma_code,
            "age": age,
            "gender": gender,
            "customer_since": customer_since,
            "tenure_months": tenure_months,
            "acquisition_channel": acquisition_channel,
            "plan_name": plan_name,
            "plan_category": plan_info["category"],
            "plan_price": plan_info["price"],
            "lines_on_account": lines,
            "contract_type": contract_type,
            "contract_end_date": contract_end,
            "device_brand": device["brand"],
            "device_model": device["model"],
            "device_tier": device["tier"],
            "device_os": device["os"],
            "device_age_months": device["age_months"],
            "is_5g_capable": device["is_5g"],
            "monthly_arpu": monthly_arpu,
            "lifetime_value": lifetime_value,
            "total_revenue_12m": total_revenue_12m,
            "payment_method": payment_method,
            "autopay_enrolled": autopay,
            "paperless_billing": paperless,
            "credit_class": credit_class,
            "has_device_protection": has_protection,
            "has_intl_roaming": has_roaming,
            "has_streaming_bundle": has_streaming,
            "rewards_member": rewards_member,
            "rewards_tier": rewards_tier,
            "rewards_points_balance": rewards_points,
            "app_user": app_user,
            "app_engagement_score": app_engagement,
            "last_app_login": last_app_login,
            "nps_score": nps_score,
            "nps_survey_date": nps_date,
            "churn_risk_score": round(churn_risk, 2),
            "predicted_churn_reason": predicted_reason,
            "complaint_count_12m": complaint_count,
        }
        records.append(record)
    
    df = pd.DataFrame(records)
    print(f"  ✓ Generated {len(df):,} customers")
    return df


