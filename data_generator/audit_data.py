"""
Snowmobile Wireless - Data Quality Audit
Checks all generated CSV files for:
- Null/NaN values
- Data consistency
- Realistic value ranges
- Referential integrity
"""

import pandas as pd
import numpy as np
from pathlib import Path
import sys

# Paths
DATA_DIR = Path("../data")
INTERNAL_DIR = DATA_DIR / "internal"
EXTERNAL_DIR = DATA_DIR / "external"

# Color codes for terminal
RED = "\033[91m"
GREEN = "\033[92m"
YELLOW = "\033[93m"
BLUE = "\033[94m"
RESET = "\033[0m"

def print_header(title):
    print(f"\n{'='*70}")
    print(f"{BLUE}{title}{RESET}")
    print(f"{'='*70}")

def print_pass(msg):
    print(f"  {GREEN}✓{RESET} {msg}")

def print_fail(msg):
    print(f"  {RED}✗{RESET} {msg}")

def print_warn(msg):
    print(f"  {YELLOW}⚠{RESET} {msg}")

def print_info(msg):
    print(f"  {msg}")

issues_found = []

def check_nulls(df, name, critical_cols=None):
    """Check for null/NaN values"""
    null_counts = df.isnull().sum()
    null_cols = null_counts[null_counts > 0]
    
    if len(null_cols) == 0:
        print_pass(f"No null values found")
        return True
    else:
        for col, count in null_cols.items():
            pct = count / len(df) * 100
            if critical_cols and col in critical_cols:
                print_fail(f"CRITICAL: {col} has {count:,} nulls ({pct:.2f}%)")
                issues_found.append((name, col, "critical_null", count))
            elif pct > 50:
                print_warn(f"{col} has {count:,} nulls ({pct:.2f}%) - expected for optional field")
            else:
                print_warn(f"{col} has {count:,} nulls ({pct:.2f}%)")
        return False

def check_range(df, col, min_val, max_val, name):
    """Check if values are within expected range"""
    if col not in df.columns:
        return True
    
    actual_min = df[col].min()
    actual_max = df[col].max()
    
    if actual_min >= min_val and actual_max <= max_val:
        print_pass(f"{col}: {actual_min:.2f} to {actual_max:.2f} (expected {min_val}-{max_val})")
        return True
    else:
        print_fail(f"{col}: {actual_min:.2f} to {actual_max:.2f} (expected {min_val}-{max_val})")
        issues_found.append((name, col, "out_of_range", f"{actual_min}-{actual_max}"))
        return False

def check_categorical(df, col, valid_values, name):
    """Check if categorical values are valid"""
    if col not in df.columns:
        return True
    
    unique_vals = set(df[col].dropna().unique())
    invalid = unique_vals - set(valid_values)
    
    if len(invalid) == 0:
        print_pass(f"{col}: {len(unique_vals)} unique values, all valid")
        return True
    else:
        print_fail(f"{col}: Invalid values found: {invalid}")
        issues_found.append((name, col, "invalid_categorical", str(invalid)))
        return False

def check_uniqueness(df, col, name):
    """Check if column has unique values"""
    if col not in df.columns:
        return True
    
    total = len(df)
    unique = df[col].nunique()
    
    if total == unique:
        print_pass(f"{col}: All {total:,} values are unique")
        return True
    else:
        dupes = total - unique
        print_fail(f"{col}: {dupes:,} duplicate values found")
        issues_found.append((name, col, "duplicates", dupes))
        return False

def audit_customers():
    """Audit customers.csv"""
    print_header("AUDITING: customers.csv")
    
    df = pd.read_csv(INTERNAL_DIR / "customers.csv")
    print_info(f"Records: {len(df):,}")
    
    # Critical columns that should never be null
    critical_cols = ['customer_id', 'account_id', 'zip_code', 'state_code', 
                     'plan_name', 'monthly_arpu', 'tenure_months']
    
    print("\n  Checking for nulls...")
    check_nulls(df, "customers", critical_cols)
    
    print("\n  Checking primary key uniqueness...")
    check_uniqueness(df, 'customer_id', "customers")
    
    print("\n  Checking value ranges...")
    check_range(df, 'age', 18, 100, "customers")
    check_range(df, 'tenure_months', 1, 120, "customers")
    check_range(df, 'monthly_arpu', 10, 800, "customers")  # Multi-line Avalanche can be $400+
    check_range(df, 'churn_risk_score', 0, 1, "customers")
    check_range(df, 'app_engagement_score', 0, 1, "customers")
    check_range(df, 'lines_on_account', 1, 10, "customers")
    
    print("\n  Checking categorical values...")
    check_categorical(df, 'gender', ['M', 'F', 'Other', 'Unknown'], "customers")
    check_categorical(df, 'plan_name', ['Glacier', 'Flurry', 'Powder', 'Blizzard', 'Avalanche', 'Summit'], "customers")
    check_categorical(df, 'plan_category', ['Prepaid', 'Postpaid'], "customers")
    check_categorical(df, 'device_os', ['iOS', 'Android'], "customers")
    check_categorical(df, 'device_tier', ['Flagship', 'Mid', 'Budget'], "customers")
    check_categorical(df, 'credit_class', ['A', 'B', 'C', 'D'], "customers")
    check_categorical(df, 'payment_method', ['AutoPay', 'Card', 'Manual', 'Cash'], "customers")
    
    # Check state codes
    valid_states = ['CA', 'TX', 'FL', 'NY', 'PA', 'IL', 'OH', 'GA', 'NC', 'MI', 
                   'NJ', 'VA', 'WA', 'AZ', 'MA', 'TN', 'IN', 'MD', 'MO', 'WI',
                   'CO', 'MN', 'SC', 'AL', 'LA', 'KY', 'OR', 'OK', 'CT', 'UT',
                   'IA', 'NV', 'AR', 'MS', 'KS', 'NM', 'NE', 'ID', 'WV', 'HI',
                   'NH', 'ME', 'MT', 'RI', 'DE', 'SD', 'ND', 'AK', 'VT', 'WY', 'DC']
    check_categorical(df, 'state_code', valid_states, "customers")
    
    print("\n  Checking business logic consistency...")
    # Prepaid should be Glacier
    glacier_prepaid = df[df['plan_name'] == 'Glacier']['plan_category'].value_counts()
    if glacier_prepaid.get('Prepaid', 0) > 0:
        print_pass(f"Glacier plan is correctly marked as Prepaid")
    
    # Avalanche should have multiple lines
    avalanche_lines = df[df['plan_name'] == 'Avalanche']['lines_on_account'].mean()
    if avalanche_lines >= 3:
        print_pass(f"Avalanche plan avg lines: {avalanche_lines:.1f} (expected >= 3)")
    else:
        print_warn(f"Avalanche plan avg lines: {avalanche_lines:.1f} (expected >= 3)")
    
    # Check ARPU by plan makes sense
    arpu_by_plan = df.groupby('plan_name')['monthly_arpu'].mean()
    print_info(f"\n  ARPU by Plan:")
    for plan in ['Glacier', 'Flurry', 'Powder', 'Blizzard', 'Summit', 'Avalanche']:
        if plan in arpu_by_plan.index:
            print_info(f"    {plan}: ${arpu_by_plan[plan]:.2f}")
    
    return df

def audit_monthly_usage():
    """Audit monthly_usage.csv"""
    print_header("AUDITING: monthly_usage.csv")
    
    df = pd.read_csv(INTERNAL_DIR / "monthly_usage.csv")
    print_info(f"Records: {len(df):,}")
    
    critical_cols = ['usage_id', 'customer_id', 'billing_month', 'data_usage_gb']
    
    print("\n  Checking for nulls...")
    check_nulls(df, "monthly_usage", critical_cols)
    
    print("\n  Checking value ranges...")
    check_range(df, 'data_usage_gb', 0, 200, "monthly_usage")
    check_range(df, 'voice_minutes_onnet', 0, 5000, "monthly_usage")
    check_range(df, 'voice_minutes_offnet', 0, 3000, "monthly_usage")
    check_range(df, 'total_bill', 0, 800, "monthly_usage")
    check_range(df, 'data_usage_4g_pct', 0, 100, "monthly_usage")
    check_range(df, 'data_usage_5g_pct', 0, 100, "monthly_usage")
    
    print("\n  Checking payment status...")
    check_categorical(df, 'payment_status', ['Paid', 'Pending', 'Late', 'Failed', 'Partial', 'Unpaid'], "monthly_usage")
    
    print("\n  Checking data distribution...")
    avg_data = df['data_usage_gb'].mean()
    total_voice = df['voice_minutes_onnet'] + df['voice_minutes_offnet'] + df['voice_minutes_intl']
    avg_voice = total_voice.mean()
    avg_bill = df['total_bill'].mean()
    print_info(f"  Average data usage: {avg_data:.1f} GB")
    print_info(f"  Average voice minutes: {avg_voice:.0f}")
    print_info(f"  Average bill: ${avg_bill:.2f}")
    
    return df

def audit_support_interactions():
    """Audit support_interactions.csv"""
    print_header("AUDITING: support_interactions.csv")
    
    df = pd.read_csv(INTERNAL_DIR / "support_interactions.csv")
    print_info(f"Records: {len(df):,}")
    
    critical_cols = ['interaction_id', 'customer_id', 'channel', 'category']
    
    print("\n  Checking for nulls...")
    check_nulls(df, "support_interactions", critical_cols)
    
    print("\n  Checking categorical values...")
    check_categorical(df, 'channel', ['App', 'Chat', 'Call', 'Email', 'Store', 'Social'], "support_interactions")
    check_categorical(df, 'category', ['Billing', 'Technical', 'Sales', 'Complaint', 'General', 'Account'], "support_interactions")
    check_categorical(df, 'resolution_status', ['Resolved', 'Pending', 'Escalated', 'Transferred', 'Unresolved'], "support_interactions")
    
    print("\n  Checking value ranges...")
    check_range(df, 'sentiment_score', -1, 1, "support_interactions")
    check_range(df, 'resolution_time_hours', 0, 500, "support_interactions")
    check_range(df, 'csat_score', 1, 5, "support_interactions")
    
    # Check FCR rate
    if 'first_contact_resolution' in df.columns:
        fcr_rate = df['first_contact_resolution'].mean() * 100
        print_info(f"\n  First Contact Resolution rate: {fcr_rate:.1f}%")
    
    return df

def audit_campaign_responses():
    """Audit campaign_responses.csv"""
    print_header("AUDITING: campaign_responses.csv")
    
    df = pd.read_csv(INTERNAL_DIR / "campaign_responses.csv")
    print_info(f"Records: {len(df):,}")
    
    critical_cols = ['response_id', 'customer_id', 'campaign_type', 'channel']
    
    print("\n  Checking for nulls...")
    check_nulls(df, "campaign_responses", critical_cols)
    
    print("\n  Checking categorical values...")
    check_categorical(df, 'campaign_type', ['Retention', 'Upsell', 'Cross-sell', 'Win-back', 'Loyalty', 'Seasonal'], "campaign_responses")
    check_categorical(df, 'channel', ['Email', 'SMS', 'App Push', 'Direct Mail', 'Call'], "campaign_responses")
    
    # Check response types
    valid_responses = ['Opened', 'Clicked', 'Converted', 'Unsubscribed', 'No Response', 
                       'Ignored', 'Bounced', 'Complained', 'Declined', 'Accepted']
    if 'response_type' in df.columns:
        check_categorical(df, 'response_type', valid_responses, "campaign_responses")
    
    # Check conversion logic
    print("\n  Checking conversion rates...")
    total = len(df)
    converted = len(df[df['converted'] == True])
    conv_rate = converted / total * 100
    print_info(f"  Overall conversion rate: {conv_rate:.2f}%")
    if conv_rate < 1 or conv_rate > 15:
        print_warn(f"Conversion rate outside typical range (expected 2-8%)")
    else:
        print_pass(f"Conversion rate is realistic")
    
    # Check delivery and open rates
    if 'delivered' in df.columns:
        delivered = df['delivered'].sum()
        delivery_rate = delivered / total * 100
        print_info(f"  Delivery rate: {delivery_rate:.1f}%")
    
    if 'opened' in df.columns:
        opened = df['opened'].sum()
        open_rate = opened / total * 100
        print_info(f"  Open rate: {open_rate:.1f}%")
    
    return df

def audit_zip_demographics():
    """Audit zip_demographics.csv"""
    print_header("AUDITING: zip_demographics.csv")
    
    df = pd.read_csv(EXTERNAL_DIR / "zip_demographics.csv")
    print_info(f"Records: {len(df):,}")
    
    critical_cols = ['zip_code', 'state_code', 'median_household_income', 'total_population']
    
    print("\n  Checking for nulls...")
    check_nulls(df, "zip_demographics", critical_cols)
    
    print("\n  Checking uniqueness...")
    check_uniqueness(df, 'zip_code', "zip_demographics")
    
    print("\n  Checking value ranges...")
    check_range(df, 'median_household_income', 20000, 300000, "zip_demographics")
    check_range(df, 'total_population', 100, 1000000, "zip_demographics")
    check_range(df, 'median_age', 20, 70, "zip_demographics")
    
    print("\n  Checking categorical values...")
    check_categorical(df, 'urban_rural_class', ['Urban', 'Suburban', 'Rural', 'Remote'], "zip_demographics")
    
    return df

def audit_economic_indicators():
    """Audit economic_indicators.csv"""
    print_header("AUDITING: economic_indicators.csv")
    
    df = pd.read_csv(EXTERNAL_DIR / "economic_indicators.csv")
    print_info(f"Records: {len(df):,}")
    
    critical_cols = ['zip_code', 'cost_of_living_index', 'unemployment_rate']
    
    print("\n  Checking for nulls...")
    check_nulls(df, "economic_indicators", critical_cols)
    
    print("\n  Checking value ranges...")
    check_range(df, 'cost_of_living_index', 60, 200, "economic_indicators")
    check_range(df, 'unemployment_rate', 1, 15, "economic_indicators")
    check_range(df, 'avg_credit_score', 550, 850, "economic_indicators")
    check_range(df, 'poverty_rate', 0, 50, "economic_indicators")
    
    return df

def audit_competitive_landscape():
    """Audit competitive_landscape.csv"""
    print_header("AUDITING: competitive_landscape.csv")
    
    df = pd.read_csv(EXTERNAL_DIR / "competitive_landscape.csv")
    print_info(f"Records: {len(df):,}")
    
    critical_cols = ['dma_code', 'dma_name', 'snowmobile_market_share']
    
    print("\n  Checking for nulls...")
    check_nulls(df, "competitive_landscape", critical_cols)
    
    print("\n  Checking uniqueness...")
    check_uniqueness(df, 'dma_code', "competitive_landscape")
    
    print("\n  Checking value ranges...")
    check_range(df, 'snowmobile_market_share', 5, 40, "competitive_landscape")
    check_range(df, 'vz_market_share', 15, 45, "competitive_landscape")
    check_range(df, 'att_market_share', 15, 40, "competitive_landscape")
    check_range(df, 'tmo_market_share', 15, 40, "competitive_landscape")
    
    # Check market shares sum reasonably
    print("\n  Checking market share consistency...")
    df['total_share'] = (df['snowmobile_market_share'] + df['vz_market_share'] + 
                         df['att_market_share'] + df['tmo_market_share'] + 
                         df['regional_market_share'])
    min_total = df['total_share'].min()
    max_total = df['total_share'].max()
    if 95 <= min_total and max_total <= 105:
        print_pass(f"Market shares sum to {min_total:.1f}%-{max_total:.1f}% (expected ~100%)")
    else:
        print_warn(f"Market shares sum to {min_total:.1f}%-{max_total:.1f}% (expected ~100%)")
    
    return df

def audit_lifestyle_segments():
    """Audit lifestyle_segments.csv"""
    print_header("AUDITING: lifestyle_segments.csv")
    
    df = pd.read_csv(EXTERNAL_DIR / "lifestyle_segments.csv")
    print_info(f"Records: {len(df):,}")
    
    critical_cols = ['zip_code', 'primary_lifestyle', 'tech_adoption_score', 'price_sensitivity_index']
    
    print("\n  Checking for nulls...")
    check_nulls(df, "lifestyle_segments", critical_cols)
    
    print("\n  Checking value ranges...")
    check_range(df, 'tech_adoption_score', 0, 100, "lifestyle_segments")
    check_range(df, 'price_sensitivity_index', 0, 100, "lifestyle_segments")
    check_range(df, 'brand_loyalty_index', 0, 100, "lifestyle_segments")
    check_range(df, 'switching_propensity', 0, 100, "lifestyle_segments")
    
    valid_lifestyles = ['Urban Tech Elite', 'Suburban Family Focus', 'Budget Maximizers',
                       'Silver Streamers', 'Rural Reliability', 'Young & Mobile',
                       'Small Biz Hustlers', 'Connected Seniors', 'Digital Minimalists',
                       'Premium Professionals']
    check_categorical(df, 'primary_lifestyle', valid_lifestyles, "lifestyle_segments")
    
    return df

def check_referential_integrity(customers_df, usage_df, interactions_df, campaigns_df, zip_demo_df):
    """Check foreign key relationships"""
    print_header("CHECKING REFERENTIAL INTEGRITY")
    
    customer_ids = set(customers_df['customer_id'].unique())
    
    # Check usage references valid customers
    usage_customers = set(usage_df['customer_id'].unique())
    invalid_usage = usage_customers - customer_ids
    if len(invalid_usage) == 0:
        print_pass(f"All usage records reference valid customers")
    else:
        print_fail(f"{len(invalid_usage):,} usage records reference invalid customers")
        issues_found.append(("referential", "usage->customers", "invalid_fk", len(invalid_usage)))
    
    # Check interactions reference valid customers
    interaction_customers = set(interactions_df['customer_id'].unique())
    invalid_interactions = interaction_customers - customer_ids
    if len(invalid_interactions) == 0:
        print_pass(f"All interaction records reference valid customers")
    else:
        print_fail(f"{len(invalid_interactions):,} interaction records reference invalid customers")
        issues_found.append(("referential", "interactions->customers", "invalid_fk", len(invalid_interactions)))
    
    # Check campaigns reference valid customers
    campaign_customers = set(campaigns_df['customer_id'].unique())
    invalid_campaigns = campaign_customers - customer_ids
    if len(invalid_campaigns) == 0:
        print_pass(f"All campaign records reference valid customers")
    else:
        print_fail(f"{len(invalid_campaigns):,} campaign records reference invalid customers")
        issues_found.append(("referential", "campaigns->customers", "invalid_fk", len(invalid_campaigns)))
    
    # Check customers reference valid ZIP codes
    customer_zips = set(customers_df['zip_code'].unique())
    demo_zips = set(zip_demo_df['zip_code'].unique())
    invalid_zips = customer_zips - demo_zips
    if len(invalid_zips) == 0:
        print_pass(f"All customer ZIP codes have demographic data")
    else:
        pct = len(invalid_zips) / len(customer_zips) * 100
        print_warn(f"{len(invalid_zips):,} customer ZIP codes ({pct:.1f}%) missing demographic data")

def main():
    print(f"\n{BLUE}{'='*70}{RESET}")
    print(f"{BLUE}   SNOWMOBILE WIRELESS - DATA QUALITY AUDIT{RESET}")
    print(f"{BLUE}{'='*70}{RESET}")
    
    # Audit each file
    customers_df = audit_customers()
    usage_df = audit_monthly_usage()
    interactions_df = audit_support_interactions()
    campaigns_df = audit_campaign_responses()
    zip_demo_df = audit_zip_demographics()
    econ_df = audit_economic_indicators()
    comp_df = audit_competitive_landscape()
    lifestyle_df = audit_lifestyle_segments()
    
    # Check referential integrity
    check_referential_integrity(customers_df, usage_df, interactions_df, campaigns_df, zip_demo_df)
    
    # Summary
    print_header("AUDIT SUMMARY")
    
    if len(issues_found) == 0:
        print(f"\n  {GREEN}✓ ALL CHECKS PASSED - Data is clean and consistent!{RESET}\n")
    else:
        print(f"\n  {RED}✗ {len(issues_found)} ISSUES FOUND:{RESET}")
        for issue in issues_found:
            print(f"    - {issue[0]}.{issue[1]}: {issue[2]} ({issue[3]})")
        print()
        return 1
    
    return 0

if __name__ == "__main__":
    sys.exit(main())

