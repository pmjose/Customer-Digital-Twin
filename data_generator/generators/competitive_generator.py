"""
Snowmobile Wireless - Competitive Landscape Generator
Generates competitive intelligence data by DMA
"""

from datetime import date, timedelta
import numpy as np
import pandas as pd
from tqdm import tqdm

import sys
sys.path.append('..')
from config import CARRIER_MARKET_SHARE, CARRIER_AVG_PRICE


# Top 210 DMAs (comprehensive list aligned with zip_demographics)
DMA_DATA = [
    ("501", "New York, NY", 7500000),
    ("803", "Los Angeles, CA", 5800000),
    ("602", "Chicago, IL", 3500000),
    ("504", "Philadelphia, PA", 2900000),
    ("807", "San Francisco-Oakland-San Jose, CA", 2700000),
    ("511", "Washington, DC", 2500000),
    ("506", "Boston, MA", 2400000),
    ("623", "Dallas-Ft. Worth, TX", 2800000),
    ("524", "Atlanta, GA", 2600000),
    ("618", "Houston, TX", 2500000),
    ("505", "Detroit, MI", 1900000),
    ("819", "Seattle-Tacoma, WA", 2000000),
    ("753", "Phoenix, AZ", 2100000),
    ("613", "Minneapolis-St. Paul, MN", 1800000),
    ("510", "Cleveland-Akron, OH", 1500000),
    ("528", "Miami-Ft. Lauderdale, FL", 1700000),
    ("751", "Denver, CO", 1600000),
    ("527", "Indianapolis, IN", 1100000),
    ("539", "Tampa-St. Petersburg, FL", 1500000),
    ("825", "San Diego, CA", 1300000),
    ("609", "St. Louis, MO", 1200000),
    ("560", "Raleigh-Durham, NC", 1200000),
    ("617", "Milwaukee, WI", 900000),
    ("515", "Cincinnati, OH", 900000),
    ("548", "West Palm Beach, FL", 800000),
    ("508", "Pittsburgh, PA", 1100000),
    ("640", "Memphis, TN", 700000),
    ("534", "Orlando, FL", 1400000),
    ("641", "San Antonio, TX", 1000000),
    ("512", "Baltimore, MD", 1100000),
    ("659", "Nashville, TN", 1000000),
    ("561", "Jacksonville, FL", 800000),
    ("820", "Portland, OR", 900000),
    ("517", "Charlotte, NC", 1100000),
    ("544", "Norfolk, VA", 700000),
    ("533", "Hartford, CT", 700000),
    ("521", "Providence, RI", 600000),
    ("563", "Grand Rapids, MI", 500000),
    ("686", "Mobile, AL", 400000),
    ("546", "Columbia, SC", 500000),
    ("525", "Columbus, OH", 900000),
    ("532", "Albany, NY", 500000),
    ("577", "Scranton, PA", 400000),
    ("566", "Harrisburg, PA", 500000),
    ("557", "Knoxville, TN", 500000),
    ("693", "Little Rock, AR", 450000),
    ("541", "Lexington, KY", 400000),
    ("630", "Birmingham, AL", 600000),
    ("691", "Huntsville, AL", 400000),
    ("518", "Greensboro, NC", 600000),
    ("545", "Greenville, SC", 600000),
    ("542", "Dayton, OH", 500000),
    ("564", "Charleston, WV", 350000),
    ("540", "Louisville, KY", 700000),
    ("881", "Spokane, WA", 400000),
    ("813", "Medford, OR", 200000),
    ("622", "New Orleans, LA", 700000),
    ("650", "Oklahoma City, OK", 700000),
    ("770", "Salt Lake City, UT", 900000),
    ("679", "Des Moines, IA", 450000),
    ("839", "Las Vegas, NV", 900000),
    ("718", "Jackson, MS", 350000),
    ("678", "Wichita, KS", 350000),
    ("790", "Albuquerque, NM", 500000),
    ("652", "Omaha, NE", 500000),
    ("757", "Boise, ID", 400000),
    ("744", "Honolulu, HI", 600000),
    ("762", "Missoula, MT", 150000),
    ("725", "Sioux Falls, SD", 250000),
    ("724", "Fargo, ND", 200000),
    ("743", "Anchorage, AK", 200000),
    ("523", "Burlington, VT", 150000),
    ("767", "Casper, WY", 100000),
    ("500", "Portland, ME", 350000),
    # Additional markets for coverage
]

# Generate remaining DMAs programmatically with unique codes
existing_codes = {d[0] for d in DMA_DATA}
next_code = 700  # Start from 700 to avoid conflicts
while len(DMA_DATA) < 210:
    code = str(next_code)
    if code not in existing_codes:
        dma_name = f"Market {code}"
        pop = int(np.random.uniform(100000, 800000))
        DMA_DATA.append((code, dma_name, pop))
        existing_codes.add(code)
    next_code += 1


COMPETITOR_PROMOS = [
    "Unlimited plan at $50/month for new customers",
    "Free iPhone 15 with trade-in",
    "Buy one get one free on all smartphones",
    "3 months free when you switch",
    "$200 prepaid card for switchers",
    "50% off family plans first year",
    "Free Netflix subscription included",
    "No activation fees limited time",
    "Double data on all plans",
    "Student discount 25% off",
]


def generate_competitive_landscape(n_dmas: int = 210) -> pd.DataFrame:
    """Generate competitive landscape data for each DMA"""
    
    print(f"  Generating {n_dmas:,} competitive landscape records...")
    
    records = []
    
    for i, (dma_code, dma_name, base_subs) in enumerate(tqdm(DMA_DATA[:n_dmas], desc="  Competitive")):
        
        # Market size (based on DMA population)
        total_subs = int(base_subs * np.random.uniform(0.8, 1.2))
        avg_revenue_per_sub = np.random.uniform(55, 75)
        market_revenue = round(total_subs * avg_revenue_per_sub * 12 / 1e6, 2)  # Annual in millions
        market_growth = round(np.random.normal(2.5, 2), 2)  # ~2.5% avg growth
        
        # Market share with variation
        vz_share = round(max(15, min(40, CARRIER_MARKET_SHARE["Verizon"]["mean"] + np.random.normal(0, 5))), 2)
        att_share = round(max(15, min(35, CARRIER_MARKET_SHARE["AT&T"]["mean"] + np.random.normal(0, 5))), 2)
        tmo_share = round(max(15, min(35, CARRIER_MARKET_SHARE["T-Mobile"]["mean"] + np.random.normal(0, 4))), 2)
        
        # Snowmobile share varies by market
        # Stronger in West/Mountain, weaker in some East Coast markets
        if "CA" in dma_name or "WA" in dma_name or "CO" in dma_name:
            snow_base = 22
        elif "NY" in dma_name or "NJ" in dma_name:
            snow_base = 14
        else:
            snow_base = 18
        
        snow_share = round(max(10, min(30, snow_base + np.random.normal(0, 4))), 2)
        
        # Regional carriers get remainder
        total_big4 = vz_share + att_share + tmo_share + snow_share
        regional_share = round(max(2, 100 - total_big4), 2)
        
        # Normalize to 100%
        total = vz_share + att_share + tmo_share + snow_share + regional_share
        factor = 100 / total
        vz_share = round(vz_share * factor, 2)
        att_share = round(att_share * factor, 2)
        tmo_share = round(tmo_share * factor, 2)
        snow_share = round(snow_share * factor, 2)
        regional_share = round(100 - vz_share - att_share - tmo_share - snow_share, 2)
        
        # Subscriber counts
        snow_subs = int(total_subs * snow_share / 100)
        
        # NPS scores
        snow_nps = int(np.random.normal(32, 8))  # Slightly above avg
        vz_nps = int(np.random.normal(28, 10))
        att_nps = int(np.random.normal(22, 10))
        tmo_nps = int(np.random.normal(35, 12))  # T-Mobile often higher
        
        # Coverage
        snow_coverage = round(max(85, min(99, 96 + np.random.normal(0, 3))), 2)
        snow_5g = round(max(60, min(95, 82 + np.random.normal(0, 8))), 2)
        vz_coverage = round(max(90, min(99, 97 + np.random.normal(0, 2))), 2)
        att_coverage = round(max(88, min(99, 96 + np.random.normal(0, 2))), 2)
        tmo_coverage = round(max(85, min(99, 95 + np.random.normal(0, 3))), 2)
        
        # Pricing
        vz_price = round(CARRIER_AVG_PRICE["Verizon"]["mean"] + np.random.normal(0, 5), 2)
        att_price = round(CARRIER_AVG_PRICE["AT&T"]["mean"] + np.random.normal(0, 5), 2)
        tmo_price = round(CARRIER_AVG_PRICE["T-Mobile"]["mean"] + np.random.normal(0, 5), 2)
        regional_price = round(CARRIER_AVG_PRICE["Regional"]["mean"] + np.random.normal(0, 8), 2)
        
        # Market concentration (HHI)
        hhi = round((vz_share**2 + att_share**2 + tmo_share**2 + snow_share**2 + regional_share**2) / 100, 2)
        
        # Price war intensity
        if hhi < 20:
            price_war = "High"
        elif hhi < 25:
            price_war = "Medium"
        else:
            price_war = "Low"
        
        # Competitor promo
        if np.random.random() < 0.7:  # 70% of markets have active promo
            promo = np.random.choice(COMPETITOR_PROMOS)
            promo_end = date.today() + timedelta(days=np.random.randint(7, 60))
        else:
            promo = None
            promo_end = None
        
        record = {
            "dma_code": dma_code,
            "dma_name": dma_name,
            "total_wireless_subs": total_subs,
            "market_size_revenue": market_revenue,
            "yoy_market_growth": market_growth,
            "snowmobile_subs": snow_subs,
            "snowmobile_market_share": snow_share,
            "snowmobile_nps": snow_nps,
            "snowmobile_coverage_pct": snow_coverage,
            "snowmobile_5g_pct": snow_5g,
            "vz_market_share": vz_share,
            "vz_avg_price": vz_price,
            "vz_nps": vz_nps,
            "vz_coverage_pct": vz_coverage,
            "att_market_share": att_share,
            "att_avg_price": att_price,
            "att_nps": att_nps,
            "att_coverage_pct": att_coverage,
            "tmo_market_share": tmo_share,
            "tmo_avg_price": tmo_price,
            "tmo_nps": tmo_nps,
            "tmo_coverage_pct": tmo_coverage,
            "regional_market_share": regional_share,
            "regional_avg_price": regional_price,
            "market_concentration": hhi,
            "price_war_intensity": price_war,
            "recent_competitor_promo": promo,
            "promo_end_date": promo_end,
        }
        records.append(record)
    
    df = pd.DataFrame(records)
    print(f"  ✓ Generated {len(df):,} competitive landscape records")
    return df


