"""
Snowmobile Wireless - ZIP Demographics Generator
Generates synthetic census-based demographic data by ZIP code
"""

import numpy as np
import pandas as pd
from tqdm import tqdm

import sys
sys.path.append('..')
from config import (
    STATE_DISTRIBUTION, REGION_MAPPING, URBAN_RURAL_DISTRIBUTION,
    INCOME_DISTRIBUTION, EDUCATION_DISTRIBUTION
)


# Major DMAs (Designated Market Areas) in the US
DMA_LIST = [
    ("501", "New York, NY"), ("803", "Los Angeles, CA"), ("602", "Chicago, IL"),
    ("504", "Philadelphia, PA"), ("807", "San Francisco-Oakland-San Jose, CA"),
    ("511", "Washington, DC"), ("506", "Boston, MA"), ("623", "Dallas-Ft. Worth, TX"),
    ("524", "Atlanta, GA"), ("618", "Houston, TX"), ("505", "Detroit, MI"),
    ("819", "Seattle-Tacoma, WA"), ("753", "Phoenix, AZ"), ("613", "Minneapolis-St. Paul, MN"),
    ("510", "Cleveland-Akron, OH"), ("528", "Miami-Ft. Lauderdale, FL"),
    ("751", "Denver, CO"), ("527", "Indianapolis, IN"), ("539", "Tampa-St. Petersburg, FL"),
    ("825", "San Diego, CA"), ("609", "St. Louis, MO"), ("560", "Raleigh-Durham, NC"),
    ("617", "Milwaukee, WI"), ("515", "Cincinnati, OH"), ("548", "West Palm Beach, FL"),
    ("508", "Pittsburgh, PA"), ("640", "Memphis, TN"), ("534", "Orlando, FL"),
    ("641", "San Antonio, TX"), ("512", "Baltimore, MD"), ("659", "Nashville, TN"),
    ("561", "Jacksonville, FL"), ("820", "Portland, OR"), ("517", "Charlotte, NC"),
    ("544", "Norfolk-Portsmouth, VA"), ("533", "Hartford-New Haven, CT"),
    ("521", "Providence, RI"), ("563", "Grand Rapids, MI"), ("686", "Mobile, AL"),
    ("546", "Columbia, SC"), ("525", "Columbus, OH"), ("532", "Albany-Schenectady, NY"),
    ("577", "Wilkes Barre-Scranton, PA"), ("566", "Harrisburg, PA"),
    ("557", "Knoxville, TN"), ("693", "Little Rock, AR"), ("541", "Lexington, KY"),
    ("630", "Birmingham, AL"), ("691", "Huntsville, AL"), ("558", "Rochester, NY"),
    ("518", "Greensboro, NC"), ("545", "Greenville-Spartanburg, SC"),
    ("542", "Dayton, OH"), ("564", "Charleston, WV"), ("540", "Louisville, KY"),
    ("718", "Milwaukee, WI"), ("773", "Grand Junction, CO"), ("810", "Yakima, WA"),
    ("813", "Medford, OR"), ("881", "Spokane, WA"), ("855", "Santabarbara, CA"),
    # Adding more DMAs to cover all regions
]

# State to typical DMA mappings (aligned with competitive_landscape DMAs)
STATE_TO_DMA = {
    "CA": ["803", "807", "825"],
    "TX": ["623", "618", "641"],
    "FL": ["528", "539", "534", "548", "561"],
    "NY": ["501", "532"],
    "PA": ["504", "508", "577", "566"],
    "IL": ["602"],
    "OH": ["510", "515", "525", "542"],
    "GA": ["524"],
    "NC": ["560", "517", "518"],
    "MI": ["505", "563"],
    "NJ": ["501"],  # Part of NYC DMA
    "VA": ["544", "511"],
    "WA": ["819", "881"],
    "AZ": ["753"],
    "MA": ["506"],
    "TN": ["659", "640", "557"],
    "IN": ["527"],
    "MD": ["512", "511"],
    "MO": ["609"],
    "WI": ["617"],
    "CO": ["751"],
    "MN": ["613"],
    "SC": ["546", "545"],
    "AL": ["630", "691", "686"],
    "LA": ["622"],
    "KY": ["541", "540"],
    "OR": ["820", "813"],
    "OK": ["650"],
    "CT": ["533"],
    "UT": ["770"],
    "IA": ["679"],
    "NV": ["839"],
    "AR": ["693"],
    "MS": ["718"],
    "KS": ["678"],
    "NM": ["790"],
    "NE": ["652"],
    "ID": ["757"],
    "WV": ["564"],
    "HI": ["744"],
    "NH": ["506"],  # Part of Boston DMA
    "ME": ["500"],
    "MT": ["762"],
    "RI": ["521"],
    "DE": ["504"],  # Part of Philadelphia DMA
    "SD": ["725"],
    "ND": ["724"],
    "AK": ["743"],
    "VT": ["523"],
    "WY": ["767"],
    "DC": ["511"],
}


def generate_zip_demographics(n_zips: int = 42000) -> pd.DataFrame:
    """Generate synthetic ZIP code demographic data"""
    
    print(f"  Generating {n_zips:,} ZIP demographic records...")
    
    records = []
    
    # Generate ZIP codes across all states
    states = list(STATE_DISTRIBUTION.keys())
    state_weights = list(STATE_DISTRIBUTION.values())
    
    # Assign ZIPs to states proportionally
    state_zip_counts = {}
    remaining = n_zips
    for i, state in enumerate(states):
        if i == len(states) - 1:
            count = remaining
        else:
            count = int(n_zips * state_weights[i])
        state_zip_counts[state] = count
        remaining -= count
    
    zip_counter = 10001  # Start from 10001
    
    for state, count in tqdm(state_zip_counts.items(), desc="  ZIP Demographics"):
        region = REGION_MAPPING.get(state, "Southeast")
        
        # Get DMAs for this state
        state_dmas = STATE_TO_DMA.get(state, ["500"])
        
        for _ in range(count):
            zip_code = str(zip_counter).zfill(5)
            zip_counter += 1
            
            # DMA assignment
            dma_code = np.random.choice(state_dmas) if state_dmas else "500"
            dma_name = next((d[1] for d in DMA_LIST if d[0] == dma_code), f"{state} Metro")
            
            # Urban/Rural classification
            urban_rural = np.random.choice(
                list(URBAN_RURAL_DISTRIBUTION.keys()),
                p=list(URBAN_RURAL_DISTRIBUTION.values())
            )
            
            # Population based on urban/rural
            pop_params = {
                "Urban": (50000, 25000),
                "Suburban": (20000, 15000),
                "Rural": (3000, 2000),
                "Remote": (500, 400)
            }
            pop_mean, pop_std = pop_params.get(urban_rural, (10000, 8000))
            population = max(100, int(np.random.normal(pop_mean, pop_std)))
            
            # Land area and density
            area_params = {
                "Urban": (5, 3),
                "Suburban": (20, 15),
                "Rural": (100, 80),
                "Remote": (500, 400)
            }
            area_mean, area_std = area_params.get(urban_rural, (50, 40))
            land_area = max(0.5, np.random.normal(area_mean, area_std))
            density = round(population / land_area, 2)
            
            # Age distribution
            pct_18_24 = round(max(5, min(25, np.random.normal(12, 4))), 2)
            pct_25_34 = round(max(8, min(25, np.random.normal(15, 4))), 2)
            pct_35_44 = round(max(8, min(20, np.random.normal(14, 3))), 2)
            pct_45_54 = round(max(8, min(20, np.random.normal(13, 3))), 2)
            pct_55_64 = round(max(8, min(20, np.random.normal(13, 3))), 2)
            total_under_65 = pct_18_24 + pct_25_34 + pct_35_44 + pct_45_54 + pct_55_64
            pct_65_plus = round(max(5, 100 - total_under_65), 2)
            
            median_age = round(35 + (pct_65_plus - 15) * 0.5 + np.random.normal(0, 3), 1)
            median_age = max(25, min(55, median_age))
            
            # Income (correlated with urban/rural and region)
            income_base = INCOME_DISTRIBUTION["national_median"]
            if urban_rural == "Urban":
                income_mult = 1.2
            elif urban_rural == "Suburban":
                income_mult = 1.1
            elif urban_rural == "Remote":
                income_mult = 0.75
            else:
                income_mult = 0.85
            
            # Regional adjustment
            region_mult = {"West": 1.1, "Northeast": 1.15, "Midwest": 0.95, 
                          "Southeast": 0.90, "Southwest": 1.0}.get(region, 1.0)
            
            median_income = int(income_base * income_mult * region_mult * np.random.uniform(0.7, 1.5))
            median_income = max(25000, min(300000, median_income))
            mean_income = int(median_income * np.random.uniform(1.1, 1.4))
            per_capita = int(median_income / np.random.uniform(2.0, 3.5))
            
            # Income brackets
            pct_under_25k = round(max(5, min(40, 30 - (median_income - 50000) / 5000)), 2)
            pct_25k_50k = round(max(10, min(35, 25 - (median_income - 75000) / 10000)), 2)
            pct_50k_75k = round(max(10, min(25, 20)), 2)
            pct_75k_100k = round(max(5, min(20, 15)), 2)
            pct_100k_150k = round(max(5, min(20, (median_income - 60000) / 5000)), 2)
            remaining_pct = 100 - (pct_under_25k + pct_25k_50k + pct_50k_75k + pct_75k_100k + pct_100k_150k)
            pct_150k_plus = round(max(2, remaining_pct), 2)
            
            # Education (correlated with income)
            edu_base = EDUCATION_DISTRIBUTION
            income_factor = (median_income - 50000) / 100000
            pct_hs = round(min(98, max(70, edu_base["pct_high_school"]["mean"] + income_factor * 5)), 2)
            pct_college = round(min(80, max(30, edu_base["pct_some_college"]["mean"] + income_factor * 10)), 2)
            pct_bach = round(min(70, max(10, edu_base["pct_bachelors"]["mean"] + income_factor * 20)), 2)
            pct_grad = round(min(40, max(3, edu_base["pct_graduate"]["mean"] + income_factor * 15)), 2)
            
            # Housing
            pct_owner = round(max(20, min(90, 65 + (urban_rural == "Suburban") * 15 - (urban_rural == "Urban") * 20)), 2)
            pct_renter = round(100 - pct_owner, 2)
            
            home_value = int(median_income * np.random.uniform(3, 6))
            median_rent = int(median_income * np.random.uniform(0.015, 0.025))
            
            # Household composition
            avg_hh_size = round(np.random.uniform(2.0, 3.2), 1)
            pct_family = round(max(40, min(80, 60 + (urban_rural == "Suburban") * 15)), 2)
            pct_married = round(pct_family * np.random.uniform(0.6, 0.8), 2)
            pct_single_parent = round(max(5, min(25, np.random.normal(12, 5))), 2)
            pct_alone = round(max(15, min(45, 100 - pct_family - 10)), 2)
            
            # Employment
            labor_force = round(max(50, min(80, np.random.normal(63, 8))), 2)
            pct_white_collar = round(max(20, min(80, 45 + income_factor * 30)), 2)
            pct_blue_collar = round(max(10, min(50, 100 - pct_white_collar - 25)), 2)
            pct_service = round(100 - pct_white_collar - pct_blue_collar, 2)
            
            # Diversity (varies by region)
            pct_white = round(max(20, min(95, np.random.normal(60, 20))), 2)
            pct_black = round(max(1, min(50, np.random.exponential(13))), 2)
            pct_hispanic = round(max(1, min(60, np.random.exponential(18))), 2)
            pct_asian = round(max(0.5, min(40, np.random.exponential(6))), 2)
            total_other = max(0, 100 - pct_white - pct_black - pct_hispanic - pct_asian)
            pct_other = round(total_other, 2)
            
            # Normalize to 100%
            race_total = pct_white + pct_black + pct_hispanic + pct_asian + pct_other
            if race_total != 100:
                factor = 100 / race_total
                pct_white = round(pct_white * factor, 2)
                pct_black = round(pct_black * factor, 2)
                pct_hispanic = round(pct_hispanic * factor, 2)
                pct_asian = round(pct_asian * factor, 2)
                pct_other = round(100 - pct_white - pct_black - pct_hispanic - pct_asian, 2)
            
            record = {
                "zip_code": zip_code,
                "zip_name": f"{state} {zip_counter % 1000}",
                "state_code": state,
                "state_name": state,  # Would map to full name in production
                "region": region,
                "dma_code": dma_code,
                "dma_name": dma_name,
                "total_population": population,
                "population_density": density,
                "land_area_sq_miles": round(land_area, 2),
                "urban_rural_class": urban_rural,
                "pct_age_18_24": pct_18_24,
                "pct_age_25_34": pct_25_34,
                "pct_age_35_44": pct_35_44,
                "pct_age_45_54": pct_45_54,
                "pct_age_55_64": pct_55_64,
                "pct_age_65_plus": pct_65_plus,
                "median_age": median_age,
                "median_household_income": median_income,
                "mean_household_income": mean_income,
                "per_capita_income": per_capita,
                "pct_income_under_25k": pct_under_25k,
                "pct_income_25k_50k": pct_25k_50k,
                "pct_income_50k_75k": pct_50k_75k,
                "pct_income_75k_100k": pct_75k_100k,
                "pct_income_100k_150k": pct_100k_150k,
                "pct_income_150k_plus": pct_150k_plus,
                "pct_high_school": pct_hs,
                "pct_some_college": pct_college,
                "pct_bachelors": pct_bach,
                "pct_graduate_degree": pct_grad,
                "pct_owner_occupied": pct_owner,
                "pct_renter_occupied": pct_renter,
                "median_home_value": home_value,
                "median_rent": median_rent,
                "avg_household_size": avg_hh_size,
                "pct_family_households": pct_family,
                "pct_married_couples": pct_married,
                "pct_single_parent": pct_single_parent,
                "pct_living_alone": pct_alone,
                "labor_force_participation": labor_force,
                "pct_white_collar": pct_white_collar,
                "pct_blue_collar": pct_blue_collar,
                "pct_service_industry": pct_service,
                "pct_white": pct_white,
                "pct_black": pct_black,
                "pct_hispanic": pct_hispanic,
                "pct_asian": pct_asian,
                "pct_other_race": pct_other,
            }
            records.append(record)
    
    df = pd.DataFrame(records)
    print(f"  ✓ Generated {len(df):,} ZIP demographic records")
    return df


