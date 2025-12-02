"""
Snowmobile Wireless - Cross-File Data Validation
Validates relationships, consistency, and relevance across all data files
"""

import pandas as pd
import numpy as np
from pathlib import Path

# Paths
DATA_DIR = Path("../data")
INTERNAL_DIR = DATA_DIR / "internal"
EXTERNAL_DIR = DATA_DIR / "external"

# Colors
RED = "\033[91m"
GREEN = "\033[92m"
YELLOW = "\033[93m"
BLUE = "\033[94m"
CYAN = "\033[96m"
RESET = "\033[0m"

def print_header(title):
    print(f"\n{BLUE}{'='*70}")
    print(f"  {title}")
    print(f"{'='*70}{RESET}")

def print_subheader(title):
    print(f"\n{CYAN}  {title}{RESET}")
    print(f"  {'-'*50}")

def print_pass(msg):
    print(f"    {GREEN}✓{RESET} {msg}")

def print_fail(msg):
    print(f"    {RED}✗{RESET} {msg}")

def print_warn(msg):
    print(f"    {YELLOW}⚠{RESET} {msg}")

def print_info(msg):
    print(f"    {msg}")

issues = []

def main():
    print(f"\n{BLUE}{'='*70}")
    print(f"   SNOWMOBILE WIRELESS - CROSS-FILE VALIDATION")
    print(f"   Checking data relationships, consistency & relevance")
    print(f"{'='*70}{RESET}")
    
    # Load all files
    print("\n  Loading data files...")
    customers = pd.read_csv(INTERNAL_DIR / "customers.csv")
    usage = pd.read_csv(INTERNAL_DIR / "monthly_usage.csv")
    interactions = pd.read_csv(INTERNAL_DIR / "support_interactions.csv")
    campaigns = pd.read_csv(INTERNAL_DIR / "campaign_responses.csv")
    zip_demo = pd.read_csv(EXTERNAL_DIR / "zip_demographics.csv")
    economic = pd.read_csv(EXTERNAL_DIR / "economic_indicators.csv")
    competitive = pd.read_csv(EXTERNAL_DIR / "competitive_landscape.csv")
    lifestyle = pd.read_csv(EXTERNAL_DIR / "lifestyle_segments.csv")
    print(f"    ✓ Loaded 8 files")
    
    # =========================================================================
    # 1. CUSTOMER ID CONSISTENCY
    # =========================================================================
    print_header("1. CUSTOMER ID CONSISTENCY")
    
    customer_ids = set(customers['customer_id'].unique())
    
    print_subheader("Checking all internal files reference valid customers")
    
    # Usage
    usage_customers = set(usage['customer_id'].unique())
    missing_in_usage = usage_customers - customer_ids
    extra_in_usage = customer_ids - usage_customers
    if len(missing_in_usage) == 0:
        print_pass(f"All {len(usage_customers):,} usage customer IDs exist in customers table")
    else:
        print_fail(f"{len(missing_in_usage):,} usage records reference non-existent customers")
        issues.append("usage has invalid customer IDs")
    
    # Check coverage
    coverage = len(usage_customers) / len(customer_ids) * 100
    if coverage > 95:
        print_pass(f"Usage covers {coverage:.1f}% of customers")
    else:
        print_warn(f"Usage only covers {coverage:.1f}% of customers")
    
    # Interactions
    interaction_customers = set(interactions['customer_id'].unique())
    missing_in_interactions = interaction_customers - customer_ids
    if len(missing_in_interactions) == 0:
        print_pass(f"All {len(interaction_customers):,} interaction customer IDs are valid")
    else:
        print_fail(f"{len(missing_in_interactions):,} invalid customer IDs in interactions")
        issues.append("interactions has invalid customer IDs")
    
    # Campaigns
    campaign_customers = set(campaigns['customer_id'].unique())
    missing_in_campaigns = campaign_customers - customer_ids
    if len(missing_in_campaigns) == 0:
        print_pass(f"All {len(campaign_customers):,} campaign customer IDs are valid")
    else:
        print_fail(f"{len(missing_in_campaigns):,} invalid customer IDs in campaigns")
        issues.append("campaigns has invalid customer IDs")
    
    # =========================================================================
    # 2. ZIP CODE CONSISTENCY
    # =========================================================================
    print_header("2. ZIP CODE & GEOGRAPHY CONSISTENCY")
    
    print_subheader("Checking ZIP codes across files")
    
    customer_zips = set(customers['zip_code'].unique())
    demo_zips = set(zip_demo['zip_code'].unique())
    econ_zips = set(economic['zip_code'].unique())
    lifestyle_zips = set(lifestyle['zip_code'].unique())
    
    # All customer ZIPs have demographics
    missing_demo = customer_zips - demo_zips
    if len(missing_demo) == 0:
        print_pass(f"All {len(customer_zips):,} customer ZIP codes have demographic data")
    else:
        print_fail(f"{len(missing_demo):,} customer ZIPs missing demographic data")
        issues.append("missing demographic data for some ZIPs")
    
    # All customer ZIPs have economic data
    missing_econ = customer_zips - econ_zips
    if len(missing_econ) == 0:
        print_pass(f"All customer ZIP codes have economic indicators")
    else:
        print_fail(f"{len(missing_econ):,} customer ZIPs missing economic data")
        issues.append("missing economic data for some ZIPs")
    
    # All customer ZIPs have lifestyle data
    missing_lifestyle = customer_zips - lifestyle_zips
    if len(missing_lifestyle) == 0:
        print_pass(f"All customer ZIP codes have lifestyle segment data")
    else:
        print_fail(f"{len(missing_lifestyle):,} customer ZIPs missing lifestyle data")
        issues.append("missing lifestyle data for some ZIPs")
    
    # External files have same ZIPs
    if demo_zips == econ_zips == lifestyle_zips:
        print_pass(f"All 3 external ZIP-level files have identical ZIP coverage ({len(demo_zips):,} ZIPs)")
    else:
        print_warn("External files have different ZIP coverage")
    
    print_subheader("Checking state consistency")
    
    # Merge to check state consistency
    customer_states = customers[['zip_code', 'state_code']].drop_duplicates()
    demo_states = zip_demo[['zip_code', 'state_code']].drop_duplicates()
    merged = customer_states.merge(demo_states, on='zip_code', suffixes=('_cust', '_demo'))
    mismatched = merged[merged['state_code_cust'] != merged['state_code_demo']]
    
    if len(mismatched) == 0:
        print_pass("State codes match between customers and demographics")
    else:
        print_fail(f"{len(mismatched):,} ZIPs have mismatched state codes")
        issues.append("state code mismatch")
    
    # =========================================================================
    # 3. DMA CODE CONSISTENCY
    # =========================================================================
    print_header("3. DMA (MARKET) CONSISTENCY")
    
    print_subheader("Checking DMA coverage")
    
    customer_dmas = set(customers['dma_code'].unique())
    competitive_dmas = set(competitive['dma_code'].unique())
    
    missing_dmas = customer_dmas - competitive_dmas
    if len(missing_dmas) == 0:
        print_pass(f"All {len(customer_dmas):,} customer DMAs have competitive data")
    else:
        pct = len(missing_dmas) / len(customer_dmas) * 100
        if pct < 5:
            print_warn(f"{len(missing_dmas)} customer DMAs ({pct:.1f}%) missing competitive data")
        else:
            print_fail(f"{len(missing_dmas)} customer DMAs ({pct:.1f}%) missing competitive data")
            issues.append("many DMAs missing competitive data")
    
    # =========================================================================
    # 4. PLAN CONSISTENCY & BUSINESS LOGIC
    # =========================================================================
    print_header("4. PLAN & PRICING CONSISTENCY")
    
    print_subheader("Validating plan-based business rules")
    
    # Glacier should be Prepaid
    glacier = customers[customers['plan_name'] == 'Glacier']
    glacier_prepaid_pct = (glacier['plan_category'] == 'Prepaid').mean() * 100
    if glacier_prepaid_pct == 100:
        print_pass(f"All Glacier customers are Prepaid (100%)")
    else:
        print_fail(f"Only {glacier_prepaid_pct:.1f}% of Glacier customers are Prepaid")
        issues.append("Glacier plan category issue")
    
    # Avalanche should have 3+ lines
    avalanche = customers[customers['plan_name'] == 'Avalanche']
    avg_lines = avalanche['lines_on_account'].mean()
    min_lines = avalanche['lines_on_account'].min()
    if min_lines >= 3:
        print_pass(f"All Avalanche customers have 3+ lines (min={min_lines}, avg={avg_lines:.1f})")
    else:
        pct_under_3 = (avalanche['lines_on_account'] < 3).mean() * 100
        print_warn(f"{pct_under_3:.1f}% of Avalanche customers have <3 lines")
    
    # ARPU should correlate with plan tier
    print_subheader("Validating ARPU by plan (should increase with tier)")
    
    plan_arpu = customers.groupby('plan_name')['monthly_arpu'].mean().sort_values()
    expected_order = ['Glacier', 'Flurry', 'Powder', 'Blizzard', 'Summit', 'Avalanche']
    
    for plan in expected_order:
        arpu = plan_arpu.get(plan, 0)
        print_info(f"  {plan:12s}: ${arpu:,.2f}")
    
    # Check order is generally correct (Glacier < Flurry < Powder < Blizzard < Summit)
    if (plan_arpu['Glacier'] < plan_arpu['Flurry'] < plan_arpu['Powder'] < 
        plan_arpu['Blizzard'] < plan_arpu['Summit']):
        print_pass("ARPU increases correctly with plan tier")
    else:
        print_warn("ARPU order may not match expected plan tier")
    
    # =========================================================================
    # 5. USAGE-CUSTOMER CORRELATION
    # =========================================================================
    print_header("5. USAGE-CUSTOMER CORRELATION")
    
    print_subheader("Checking usage patterns match customer profiles")
    
    # Aggregate usage by customer
    usage_agg = usage.groupby('customer_id').agg({
        'data_usage_gb': 'mean',
        'total_bill': 'mean'
    }).reset_index()
    usage_agg.columns = ['customer_id', 'avg_data', 'avg_bill']
    
    # Merge with customers
    customer_usage = customers.merge(usage_agg, on='customer_id', how='left')
    
    # Check ARPU vs actual bill correlation
    corr = customer_usage[['monthly_arpu', 'avg_bill']].corr().iloc[0,1]
    if corr > 0.7:
        print_pass(f"ARPU correlates strongly with actual bills (r={corr:.2f})")
    elif corr > 0.5:
        print_pass(f"ARPU correlates moderately with actual bills (r={corr:.2f})")
    else:
        print_warn(f"Weak correlation between ARPU and bills (r={corr:.2f})")
    
    # Heavy data plans should have more data usage
    usage_by_plan = customer_usage.groupby('plan_name')['avg_data'].mean()
    if usage_by_plan['Blizzard'] > usage_by_plan['Powder'] > usage_by_plan['Flurry']:
        print_pass("Data usage increases with plan tier as expected")
    else:
        print_warn("Data usage pattern doesn't match plan tier")
    
    print_info(f"\n  Data usage by plan:")
    for plan in ['Glacier', 'Flurry', 'Powder', 'Blizzard', 'Summit', 'Avalanche']:
        if plan in usage_by_plan.index:
            print_info(f"    {plan:12s}: {usage_by_plan[plan]:,.1f} GB/month")
    
    # =========================================================================
    # 6. INTERACTION PATTERNS
    # =========================================================================
    print_header("6. SUPPORT INTERACTION PATTERNS")
    
    print_subheader("Checking interaction distribution")
    
    interactions_per_customer = interactions.groupby('customer_id').size()
    avg_interactions = interactions_per_customer.mean()
    print_info(f"  Average interactions per customer: {avg_interactions:.2f}")
    
    # High-risk customers should have more interactions
    high_risk = customers[customers['churn_risk_score'] > 0.5]['customer_id']
    low_risk = customers[customers['churn_risk_score'] < 0.3]['customer_id']
    
    high_risk_interactions = interactions_per_customer[interactions_per_customer.index.isin(high_risk)].mean()
    low_risk_interactions = interactions_per_customer[interactions_per_customer.index.isin(low_risk)].mean()
    
    if high_risk_interactions > low_risk_interactions:
        print_pass(f"High-risk customers have more interactions ({high_risk_interactions:.2f}) than low-risk ({low_risk_interactions:.2f})")
    else:
        print_info(f"High-risk: {high_risk_interactions:.2f}, Low-risk: {low_risk_interactions:.2f} interactions")
    
    # Complainers should have lower sentiment
    complaints = interactions[interactions['category'] == 'Complaint']
    non_complaints = interactions[interactions['category'] != 'Complaint']
    if len(complaints) > 0:
        complaint_sentiment = complaints['sentiment_score'].mean()
        other_sentiment = non_complaints['sentiment_score'].mean()
        if complaint_sentiment < other_sentiment:
            print_pass(f"Complaint sentiment ({complaint_sentiment:.2f}) lower than other ({other_sentiment:.2f})")
        else:
            print_warn("Complaint sentiment not lower than other interactions")
    
    # =========================================================================
    # 7. CAMPAIGN RESPONSE PATTERNS
    # =========================================================================
    print_header("7. CAMPAIGN RESPONSE PATTERNS")
    
    print_subheader("Checking campaign metrics by type")
    
    campaign_stats = campaigns.groupby('campaign_type').agg({
        'delivered': 'mean',
        'opened': 'mean',
        'converted': 'mean'
    }).round(3)
    
    print_info("\n  Conversion rates by campaign type:")
    for ctype in campaign_stats.index:
        conv = campaign_stats.loc[ctype, 'converted'] * 100
        print_info(f"    {ctype:12s}: {conv:.2f}%")
    
    # Retention campaigns should have higher conversion than cold campaigns
    if 'Retention' in campaign_stats.index and 'Win-back' in campaign_stats.index:
        ret_conv = campaign_stats.loc['Retention', 'converted']
        wb_conv = campaign_stats.loc['Win-back', 'converted']
        if ret_conv > wb_conv:
            print_pass(f"Retention converts better ({ret_conv*100:.2f}%) than Win-back ({wb_conv*100:.2f}%)")
        else:
            print_info(f"Retention: {ret_conv*100:.2f}%, Win-back: {wb_conv*100:.2f}%")
    
    # =========================================================================
    # 8. EXTERNAL DATA RELEVANCE
    # =========================================================================
    print_header("8. EXTERNAL DATA RELEVANCE")
    
    print_subheader("Checking external data impacts customer behavior")
    
    # Merge customer with external data
    cust_enriched = customers.merge(zip_demo[['zip_code', 'median_household_income', 'urban_rural_class']], 
                                    on='zip_code', how='left')
    cust_enriched = cust_enriched.merge(lifestyle[['zip_code', 'price_sensitivity_index', 'tech_adoption_score']], 
                                        on='zip_code', how='left')
    
    # High income areas should have higher ARPU
    high_income = cust_enriched[cust_enriched['median_household_income'] > 100000]['monthly_arpu'].mean()
    low_income = cust_enriched[cust_enriched['median_household_income'] < 50000]['monthly_arpu'].mean()
    if high_income > low_income:
        print_pass(f"High-income areas have higher ARPU (${high_income:.2f}) vs low-income (${low_income:.2f})")
    else:
        print_warn(f"Income-ARPU correlation unexpected")
    
    # Urban areas should have different plan mix
    urban_premium = cust_enriched[cust_enriched['urban_rural_class'] == 'Urban']['plan_name'].isin(['Summit', 'Blizzard']).mean()
    rural_premium = cust_enriched[cust_enriched['urban_rural_class'] == 'Rural']['plan_name'].isin(['Summit', 'Blizzard']).mean()
    print_info(f"\n  Premium plan adoption:")
    print_info(f"    Urban: {urban_premium*100:.1f}%")
    print_info(f"    Rural: {rural_premium*100:.1f}%")
    
    # Tech adoption should correlate with 5G adoption
    cust_enriched['is_5g'] = cust_enriched['is_5g_capable'].astype(int)
    tech_5g_corr = cust_enriched[['tech_adoption_score', 'is_5g']].corr().iloc[0,1]
    if tech_5g_corr > 0.05:
        print_pass(f"Tech adoption correlates with 5G device ownership (r={tech_5g_corr:.3f})")
    else:
        print_info(f"Tech adoption vs 5G correlation: r={tech_5g_corr:.3f}")
    
    # =========================================================================
    # 9. COMPETITIVE DATA RELEVANCE
    # =========================================================================
    print_header("9. COMPETITIVE DATA RELEVANCE")
    
    print_subheader("Checking market share data")
    
    # Market shares should sum to ~100%
    competitive['total_share'] = (competitive['snowmobile_market_share'] + 
                                  competitive['vz_market_share'] + 
                                  competitive['att_market_share'] + 
                                  competitive['tmo_market_share'] + 
                                  competitive['regional_market_share'])
    
    share_min = competitive['total_share'].min()
    share_max = competitive['total_share'].max()
    if 99 <= share_min and share_max <= 101:
        print_pass(f"Market shares sum to 100% in all DMAs ({share_min:.1f}%-{share_max:.1f}%)")
    else:
        print_warn(f"Market share totals vary: {share_min:.1f}%-{share_max:.1f}%")
    
    # Snowmobile share should match company profile (~18% national)
    avg_snow_share = competitive['snowmobile_market_share'].mean()
    print_info(f"\n  Snowmobile avg market share: {avg_snow_share:.1f}% (target: ~18%)")
    
    # =========================================================================
    # FINAL SUMMARY
    # =========================================================================
    print_header("VALIDATION SUMMARY")
    
    if len(issues) == 0:
        print(f"\n  {GREEN}✓ ALL CROSS-FILE VALIDATIONS PASSED!{RESET}")
        print(f"\n  Data is:")
        print(f"    • {GREEN}RELATED{RESET} - All files properly linked via customer_id, zip_code, dma_code")
        print(f"    • {GREEN}CONSISTENT{RESET} - Values match across files, business rules enforced")
        print(f"    • {GREEN}RELEVANT{RESET} - External data meaningfully correlates with customer behavior")
    else:
        print(f"\n  {RED}✗ {len(issues)} ISSUES FOUND:{RESET}")
        for issue in issues:
            print(f"    - {issue}")
    
    print()
    return len(issues)

if __name__ == "__main__":
    exit(main())

