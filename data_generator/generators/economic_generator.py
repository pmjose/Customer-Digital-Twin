"""
Snowmobile Wireless - Economic Indicators Generator
Generates economic data by ZIP code
"""

from datetime import date
import numpy as np
import pandas as pd
from tqdm import tqdm

import sys
sys.path.append('..')
from config import (
    COST_OF_LIVING_DISTRIBUTION, UNEMPLOYMENT_DISTRIBUTION, CREDIT_SCORE_DISTRIBUTION
)


def generate_economic_indicators(zip_df: pd.DataFrame) -> pd.DataFrame:
    """Generate economic indicator data for each ZIP code"""
    
    n_zips = len(zip_df)
    print(f"  Generating {n_zips:,} economic indicator records...")
    
    records = []
    
    for _, row in tqdm(zip_df.iterrows(), total=n_zips, desc="  Economic"):
        zip_code = row['zip_code']
        urban_rural = row['urban_rural_class']
        median_income = row['median_household_income']
        region = row['region']
        
        # Cost of living (correlated with income and region)
        base_col = COST_OF_LIVING_DISTRIBUTION["mean"]
        
        # Regional adjustments
        region_col = {
            "West": 115, "Northeast": 120, "Southeast": 90,
            "Midwest": 88, "Southwest": 95
        }.get(region, 100)
        
        # Urban adjustments
        urban_col = {
            "Urban": 20, "Suburban": 5, "Rural": -10, "Remote": -15
        }.get(urban_rural, 0)
        
        # Income correlation
        income_col = (median_income - 75000) / 5000
        
        col_index = round(base_col + (region_col - 100) + urban_col + income_col + np.random.normal(0, 10), 1)
        col_index = max(COST_OF_LIVING_DISTRIBUTION["min"], 
                       min(COST_OF_LIVING_DISTRIBUTION["max"], col_index))
        
        # Component indices (relative to overall COL)
        housing_index = round(col_index * np.random.uniform(0.9, 1.3), 1)
        utilities_index = round(col_index * np.random.uniform(0.85, 1.1), 1)
        transport_index = round(col_index * np.random.uniform(0.9, 1.15), 1)
        groceries_index = round(col_index * np.random.uniform(0.9, 1.1), 1)
        healthcare_index = round(col_index * np.random.uniform(0.95, 1.15), 1)
        
        # Unemployment (inversely correlated with income, with regional variation)
        base_unemp = UNEMPLOYMENT_DISTRIBUTION["mean"]
        income_unemp = (75000 - median_income) / 30000  # Higher income = lower unemployment
        regional_unemp = {
            "West": -0.3, "Northeast": 0.2, "Southeast": 0.5,
            "Midwest": 0.3, "Southwest": 0.1
        }.get(region, 0)
        
        unemployment = round(base_unemp + income_unemp + regional_unemp + np.random.normal(0, 1), 2)
        unemployment = max(UNEMPLOYMENT_DISTRIBUTION["min"], 
                          min(UNEMPLOYMENT_DISTRIBUTION["max"], unemployment))
        
        # Job growth (slightly negative correlation with unemployment)
        job_growth = round(2.5 - unemployment * 0.3 + np.random.normal(0, 2), 2)
        job_growth = max(-5, min(10, job_growth))
        
        # Poverty rate (inversely correlated with income)
        poverty_base = 30 - (median_income / 5000)
        poverty_rate = round(max(2, min(35, poverty_base + np.random.normal(0, 5))), 2)
        
        # Food insecurity (correlated with poverty)
        food_insecurity = round(poverty_rate * np.random.uniform(0.3, 0.5), 2)
        
        # Uninsured rate
        uninsured = round(max(2, min(25, 10 - (median_income - 50000) / 15000 + np.random.normal(0, 3))), 2)
        
        # Housing market
        home_growth = round(np.random.normal(5, 4), 2)  # National avg ~5%
        rent_growth = round(np.random.normal(4, 3), 2)
        vacancy = round(max(2, min(15, 7 + np.random.normal(0, 3))), 2)
        
        # Credit scores (correlated with income)
        base_credit = CREDIT_SCORE_DISTRIBUTION["mean"]
        income_credit = (median_income - 75000) / 2000
        avg_credit = int(base_credit + income_credit + np.random.normal(0, 30))
        avg_credit = max(CREDIT_SCORE_DISTRIBUTION["min"], 
                        min(CREDIT_SCORE_DISTRIBUTION["max"], avg_credit))
        
        # Prime/subprime distribution
        pct_prime = round(max(20, min(80, 50 + (avg_credit - 700) / 3)), 2)
        pct_subprime = round(max(5, min(40, 20 - (avg_credit - 700) / 5)), 2)
        
        # Debt to income
        avg_dti = round(max(15, min(50, 35 + np.random.normal(0, 8))), 2)
        
        # Retail/spending
        retail_per_capita = int(median_income * np.random.uniform(0.15, 0.25))
        ecommerce_pct = round(max(10, min(40, 20 + (avg_credit - 680) / 10 + np.random.normal(0, 5))), 2)
        
        record = {
            "zip_code": zip_code,
            "cost_of_living_index": col_index,
            "housing_cost_index": housing_index,
            "utilities_cost_index": utilities_index,
            "transportation_index": transport_index,
            "groceries_index": groceries_index,
            "healthcare_index": healthcare_index,
            "unemployment_rate": unemployment,
            "job_growth_rate_yoy": job_growth,
            "poverty_rate": poverty_rate,
            "food_insecurity_rate": food_insecurity,
            "uninsured_rate": uninsured,
            "home_price_growth_yoy": home_growth,
            "rent_growth_yoy": rent_growth,
            "vacancy_rate": vacancy,
            "avg_credit_score": avg_credit,
            "pct_prime_credit": pct_prime,
            "pct_subprime_credit": pct_subprime,
            "avg_debt_to_income": avg_dti,
            "retail_sales_per_capita": retail_per_capita,
            "ecommerce_penetration": ecommerce_pct,
            "data_as_of_date": date.today(),
        }
        records.append(record)
    
    df = pd.DataFrame(records)
    print(f"  ✓ Generated {len(df):,} economic indicator records")
    return df


