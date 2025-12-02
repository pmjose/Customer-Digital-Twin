#!/usr/bin/env python3
"""
Snowmobile Wireless - Customer Digital Twin
Main data generation orchestrator

This script generates all synthetic data for the Customer Digital Twin POC:
- Internal: Customers, Usage, Interactions, Campaigns
- External: ZIP Demographics, Economic, Competitive, Lifestyle

Usage:
    python generate_all_data.py [--customers N] [--seed S]
"""

import os
import sys
import argparse
import time
from datetime import datetime

import numpy as np
import pandas as pd
from tqdm import tqdm

# Import configuration
from config import (
    RANDOM_SEED, OUTPUT_DIR, CUSTOMER_CONFIG, EXTERNAL_CONFIG, OUTPUT_FILES
)

# Import generators
from generators.customer_generator import generate_customers
from generators.usage_generator import generate_monthly_usage
from generators.interaction_generator import generate_support_interactions
from generators.campaign_generator import generate_campaign_responses
from generators.zip_demographics_generator import generate_zip_demographics
from generators.economic_generator import generate_economic_indicators
from generators.competitive_generator import generate_competitive_landscape
from generators.lifestyle_generator import generate_lifestyle_segments


def setup_output_directories():
    """Create output directory structure"""
    directories = [
        os.path.join(OUTPUT_DIR, "internal"),
        os.path.join(OUTPUT_DIR, "external"),
    ]
    for directory in directories:
        os.makedirs(directory, exist_ok=True)
        print(f"  ✓ Created/verified: {directory}")


def save_dataframe(df: pd.DataFrame, filename: str, description: str):
    """Save DataFrame to CSV with progress reporting"""
    filepath = os.path.join(OUTPUT_DIR, filename)
    print(f"\n  Saving {description}...")
    print(f"    Records: {len(df):,}")
    
    start = time.time()
    df.to_csv(filepath, index=False)
    elapsed = time.time() - start
    
    # Get file size
    size_mb = os.path.getsize(filepath) / (1024 * 1024)
    print(f"    File: {filepath}")
    print(f"    Size: {size_mb:.1f} MB")
    print(f"    Time: {elapsed:.1f}s")
    print(f"  ✓ {description} saved!")
    
    return filepath


def main(num_customers: int = None, seed: int = None):
    """Main data generation pipeline"""
    
    print("=" * 70)
    print("SNOWMOBILE WIRELESS - CUSTOMER DIGITAL TWIN DATA GENERATOR")
    print("=" * 70)
    print(f"\nStarted at: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    
    # Set configuration
    if num_customers:
        CUSTOMER_CONFIG["total_records"] = num_customers
    if seed:
        np.random.seed(seed)
    else:
        np.random.seed(RANDOM_SEED)
    
    print(f"\nConfiguration:")
    print(f"  Customers: {CUSTOMER_CONFIG['total_records']:,}")
    print(f"  Usage months: {CUSTOMER_CONFIG['months_of_usage']}")
    print(f"  Random seed: {seed or RANDOM_SEED}")
    
    # Setup directories
    print(f"\n{'=' * 70}")
    print("STEP 1: Setting up output directories")
    print("=" * 70)
    setup_output_directories()
    
    # =========================================================================
    # EXTERNAL DATA (generate first as customers reference ZIP codes)
    # =========================================================================
    
    print(f"\n{'=' * 70}")
    print("STEP 2: Generating EXTERNAL data")
    print("=" * 70)
    
    # ZIP Demographics
    print("\n[2.1] Generating ZIP Demographics...")
    zip_demographics = generate_zip_demographics(EXTERNAL_CONFIG["zip_codes"])
    save_dataframe(zip_demographics, OUTPUT_FILES["zip_demographics"], "ZIP Demographics")
    
    # Economic Indicators
    print("\n[2.2] Generating Economic Indicators...")
    economic_indicators = generate_economic_indicators(zip_demographics)
    save_dataframe(economic_indicators, OUTPUT_FILES["economic_indicators"], "Economic Indicators")
    
    # Competitive Landscape
    print("\n[2.3] Generating Competitive Landscape...")
    competitive_landscape = generate_competitive_landscape(EXTERNAL_CONFIG["dmas"])
    save_dataframe(competitive_landscape, OUTPUT_FILES["competitive_landscape"], "Competitive Landscape")
    
    # Lifestyle Segments
    print("\n[2.4] Generating Lifestyle Segments...")
    lifestyle_segments = generate_lifestyle_segments(zip_demographics)
    save_dataframe(lifestyle_segments, OUTPUT_FILES["lifestyle_segments"], "Lifestyle Segments")
    
    # =========================================================================
    # INTERNAL DATA
    # =========================================================================
    
    print(f"\n{'=' * 70}")
    print("STEP 3: Generating INTERNAL data")
    print("=" * 70)
    
    # Customers
    print("\n[3.1] Generating Customers...")
    customers = generate_customers(
        CUSTOMER_CONFIG["total_records"],
        zip_demographics,
        lifestyle_segments,
        competitive_landscape
    )
    save_dataframe(customers, OUTPUT_FILES["customers"], "Customers")
    
    # Monthly Usage
    print("\n[3.2] Generating Monthly Usage...")
    monthly_usage = generate_monthly_usage(
        customers,
        CUSTOMER_CONFIG["months_of_usage"]
    )
    save_dataframe(monthly_usage, OUTPUT_FILES["monthly_usage"], "Monthly Usage")
    
    # Support Interactions
    print("\n[3.3] Generating Support Interactions...")
    interactions = generate_support_interactions(
        customers,
        CUSTOMER_CONFIG["avg_interactions_per_customer"]
    )
    save_dataframe(interactions, OUTPUT_FILES["support_interactions"], "Support Interactions")
    
    # Campaign Responses
    print("\n[3.4] Generating Campaign Responses...")
    campaigns = generate_campaign_responses(
        customers,
        CUSTOMER_CONFIG["avg_campaigns_per_customer"]
    )
    save_dataframe(campaigns, OUTPUT_FILES["campaign_responses"], "Campaign Responses")
    
    # =========================================================================
    # SUMMARY
    # =========================================================================
    
    print(f"\n{'=' * 70}")
    print("GENERATION COMPLETE!")
    print("=" * 70)
    
    # Calculate total records and size
    total_records = (
        len(customers) + 
        len(monthly_usage) + 
        len(interactions) + 
        len(campaigns) +
        len(zip_demographics) +
        len(economic_indicators) +
        len(competitive_landscape) +
        len(lifestyle_segments)
    )
    
    total_size_mb = sum(
        os.path.getsize(os.path.join(OUTPUT_DIR, f)) / (1024 * 1024)
        for f in OUTPUT_FILES.values()
        if os.path.exists(os.path.join(OUTPUT_DIR, f))
    )
    
    print(f"\nSummary:")
    print(f"  Total records generated: {total_records:,}")
    print(f"  Total file size: {total_size_mb:.1f} MB")
    print(f"\nFiles created:")
    for name, path in OUTPUT_FILES.items():
        full_path = os.path.join(OUTPUT_DIR, path)
        if os.path.exists(full_path):
            size = os.path.getsize(full_path) / (1024 * 1024)
            print(f"  ✓ {path} ({size:.1f} MB)")
    
    print(f"\nCompleted at: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("\nNext steps:")
    print("  1. Upload CSV files to Snowflake stage")
    print("  2. Run sql/05_load_data.sql to load into tables")
    print("  3. Run sql/06_create_enriched_views.sql for feature engineering")
    

if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Generate synthetic data for Snowmobile Wireless Customer Digital Twin"
    )
    parser.add_argument(
        "--customers", "-c",
        type=int,
        default=None,
        help="Number of customers to generate (default: 1,000,000)"
    )
    parser.add_argument(
        "--seed", "-s",
        type=int,
        default=None,
        help="Random seed for reproducibility (default: 42)"
    )
    
    args = parser.parse_args()
    
    try:
        main(num_customers=args.customers, seed=args.seed)
    except KeyboardInterrupt:
        print("\n\nGeneration cancelled by user.")
        sys.exit(1)
    except Exception as e:
        print(f"\n\nError during generation: {e}")
        raise


