"""
Snowmobile Wireless - Lifestyle Segments Generator
Generates psychographic/lifestyle data by ZIP code
"""

import numpy as np
import pandas as pd
from tqdm import tqdm

import sys
sys.path.append('..')
from config import (
    LIFESTYLE_CLUSTERS, LIFESTYLE_BY_GEOGRAPHY, TECH_ADOPTION_BY_LIFESTYLE
)


def weighted_choice(distribution: dict) -> str:
    items = list(distribution.keys())
    weights = list(distribution.values())
    # Normalize weights
    total = sum(weights)
    weights = [w/total for w in weights]
    return np.random.choice(items, p=weights)


def generate_lifestyle_segments(zip_df: pd.DataFrame) -> pd.DataFrame:
    """Generate lifestyle segment data for each ZIP code"""
    
    n_zips = len(zip_df)
    print(f"  Generating {n_zips:,} lifestyle segment records...")
    
    records = []
    
    for _, row in tqdm(zip_df.iterrows(), total=n_zips, desc="  Lifestyle"):
        zip_code = row['zip_code']
        urban_rural = row['urban_rural_class']
        median_income = row['median_household_income']
        median_age = row['median_age']
        pct_bachelors = row.get('pct_bachelors', 30)
        
        # Select primary lifestyle based on geography
        lifestyle_dist = LIFESTYLE_BY_GEOGRAPHY.get(urban_rural, LIFESTYLE_BY_GEOGRAPHY["Suburban"])
        primary_lifestyle = weighted_choice(lifestyle_dist)
        
        # Secondary lifestyle (different from primary)
        remaining = {k: v for k, v in lifestyle_dist.items() if k != primary_lifestyle}
        if remaining:
            secondary_lifestyle = weighted_choice(remaining)
        else:
            secondary_lifestyle = primary_lifestyle
        
        # Lifestyle diversity (higher in urban areas)
        diversity = round(np.random.uniform(0.3, 0.8) if urban_rural == "Urban" else np.random.uniform(0.1, 0.5), 2)
        
        # Tech adoption based on lifestyle and demographics
        tech_params = TECH_ADOPTION_BY_LIFESTYLE.get(primary_lifestyle, {"mean": 50, "std": 15})
        
        # Adjust for income and education
        income_factor = (median_income - 75000) / 50000 * 10
        edu_factor = (pct_bachelors - 30) / 20 * 5
        age_factor = (40 - median_age) / 20 * 10  # Younger = higher tech
        
        tech_score = int(tech_params["mean"] + income_factor + edu_factor + age_factor + np.random.normal(0, tech_params["std"]))
        tech_score = max(10, min(95, tech_score))
        
        # Smartphone penetration
        smartphone_pct = round(max(70, min(98, 85 + tech_score/10 + np.random.normal(0, 3))), 2)
        
        # iPhone vs Android split (iPhone higher in affluent areas)
        iphone_base = 45 + (median_income - 75000) / 10000 + (tech_score - 50) / 10
        pct_iphone = round(max(30, min(70, iphone_base + np.random.normal(0, 8))), 2)
        pct_android = round(100 - pct_iphone, 2)
        
        # Smart home adoption
        smart_home = round(max(5, min(60, tech_score * 0.5 + np.random.normal(0, 10))), 2)
        
        # Streaming penetration
        streaming_pct = round(max(50, min(95, 70 + tech_score/5 + np.random.normal(0, 8))), 2)
        
        # Cord cutters
        cord_cutter = round(max(15, min(70, 35 + tech_score/5 - (median_age - 40)/3 + np.random.normal(0, 10))), 2)
        
        # Screen time
        screen_time = round(max(3, min(10, 6 + (tech_score - 50)/20 - (median_age - 40)/15 + np.random.normal(0, 1))), 1)
        
        # Social media heavy users
        social_heavy = round(max(10, min(70, 40 - (median_age - 35)/2 + np.random.normal(0, 12))), 2)
        
        # Online shopping
        online_shop = round(max(40, min(90, 60 + tech_score/10 + np.random.normal(0, 8))), 2)
        
        # Mobile banking
        mobile_bank = round(max(30, min(85, 55 + tech_score/10 + np.random.normal(0, 10))), 2)
        
        # Media consumption
        streaming_hrs = round(max(5, min(40, 20 + tech_score/10 - (median_age - 40)/5 + np.random.normal(0, 5))), 1)
        gaming_hrs = round(max(0, min(20, 8 - (median_age - 30)/5 + np.random.normal(0, 4))), 1)
        
        news_level = np.random.choice(["Heavy", "Moderate", "Light"], p=[0.25, 0.50, 0.25])
        news_source = np.random.choice(
            ["Social", "TV", "Online", "Print"],
            p=[0.30, 0.25, 0.35, 0.10] if median_age < 45 else [0.15, 0.40, 0.30, 0.15]
        )
        
        # Values and priorities
        # Price sensitivity (inversely correlated with income)
        price_sens = int(max(10, min(90, 60 - (median_income - 75000) / 5000 + np.random.normal(0, 15))))
        
        # Brand loyalty
        brand_loyalty = int(max(20, min(80, 50 + (median_age - 40) / 3 + np.random.normal(0, 12))))
        
        # Eco consciousness
        eco = int(max(15, min(85, 50 + (pct_bachelors - 30) / 3 + np.random.normal(0, 15))))
        
        # Early adopter
        early_adopter = int(max(10, min(90, tech_score * 0.8 - (median_age - 35) / 2 + np.random.normal(0, 10))))
        
        # Communication preferences
        if median_age < 35:
            pref_digital = round(np.random.uniform(50, 70), 2)
            pref_phone = round(np.random.uniform(10, 20), 2)
            pref_store = round(np.random.uniform(5, 15), 2)
            pref_chat = round(100 - pref_digital - pref_phone - pref_store, 2)
        elif median_age > 55:
            pref_digital = round(np.random.uniform(20, 35), 2)
            pref_phone = round(np.random.uniform(35, 50), 2)
            pref_store = round(np.random.uniform(20, 35), 2)
            pref_chat = round(100 - pref_digital - pref_phone - pref_store, 2)
        else:
            pref_digital = round(np.random.uniform(35, 50), 2)
            pref_phone = round(np.random.uniform(20, 35), 2)
            pref_store = round(np.random.uniform(15, 25), 2)
            pref_chat = round(100 - pref_digital - pref_phone - pref_store, 2)
        
        # Wireless behaviors
        avg_data = round(max(5, min(50, 15 + tech_score/5 - (median_age - 40)/3 + np.random.normal(0, 8))), 1)
        avg_lines = round(max(1, min(4, 1.5 + (urban_rural == "Suburban") * 0.8 + np.random.normal(0, 0.5))), 1)
        
        family_propensity = round(max(10, min(70, 30 + (urban_rural == "Suburban") * 20 + np.random.normal(0, 10))), 2)
        premium_propensity = round(max(5, min(50, 20 + (median_income - 75000) / 5000 + tech_score/5 + np.random.normal(0, 10))), 2)
        prepaid_propensity = round(max(5, min(50, 25 - (median_income - 75000) / 8000 + np.random.normal(0, 10))), 2)
        
        # Churn factors
        deal_seeker = int(max(10, min(90, price_sens * 0.8 + np.random.normal(0, 10))))
        switching_prop = round(max(5, min(40, 15 + price_sens/5 - brand_loyalty/10 + np.random.normal(0, 5))), 2)
        competitor_aware = round(max(20, min(80, 50 + deal_seeker/5 + np.random.normal(0, 10))), 2)
        
        record = {
            "zip_code": zip_code,
            "primary_lifestyle": primary_lifestyle,
            "secondary_lifestyle": secondary_lifestyle,
            "lifestyle_diversity": diversity,
            "tech_adoption_score": tech_score,
            "smartphone_penetration": smartphone_pct,
            "pct_iphone": pct_iphone,
            "pct_android": pct_android,
            "smart_home_adoption": smart_home,
            "streaming_penetration": streaming_pct,
            "cord_cutter_rate": cord_cutter,
            "avg_daily_screen_time": screen_time,
            "social_media_heavy_pct": social_heavy,
            "online_shopping_pct": online_shop,
            "mobile_banking_pct": mobile_bank,
            "streaming_hours_week": streaming_hrs,
            "gaming_hours_week": gaming_hrs,
            "news_consumption": news_level,
            "primary_news_source": news_source,
            "price_sensitivity_index": price_sens,
            "brand_loyalty_index": brand_loyalty,
            "eco_consciousness": eco,
            "early_adopter_index": early_adopter,
            "pref_channel_digital": pref_digital,
            "pref_channel_phone": pref_phone,
            "pref_channel_store": pref_store,
            "pref_channel_chat": pref_chat,
            "avg_data_usage_gb": avg_data,
            "avg_lines_per_account": avg_lines,
            "family_plan_propensity": family_propensity,
            "premium_plan_propensity": premium_propensity,
            "prepaid_propensity": prepaid_propensity,
            "deal_seeker_index": deal_seeker,
            "switching_propensity": switching_prop,
            "competitor_awareness": competitor_aware,
        }
        records.append(record)
    
    df = pd.DataFrame(records)
    print(f"  ✓ Generated {len(df):,} lifestyle segment records")
    return df


