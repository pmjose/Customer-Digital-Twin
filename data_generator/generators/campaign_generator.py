"""
Snowmobile Wireless - Campaign Generator
Generates marketing campaign response data
"""

import uuid
from datetime import datetime, timedelta
import numpy as np
import pandas as pd
from tqdm import tqdm

import sys
sys.path.append('..')
from config import CAMPAIGN_TYPES, CAMPAIGN_CHANNELS


CAMPAIGN_TEMPLATES = {
    "Retention": [
        {"name": "Loyalty Thank You", "offer": "10% off next 3 months", "value": 30},
        {"name": "We Miss You", "offer": "$50 bill credit", "value": 50},
        {"name": "Stay With Us", "offer": "Free device protection 6 months", "value": 90},
        {"name": "Anniversary Reward", "offer": "Double rewards points", "value": 25},
    ],
    "Upsell": [
        {"name": "Upgrade to Unlimited", "offer": "Blizzard plan at Powder price for 3 months", "value": 60},
        {"name": "Premium Experience", "offer": "Try Summit plan free for 1 month", "value": 95},
        {"name": "More Data", "offer": "Add 10GB for $10/month", "value": 10},
        {"name": "Hotspot Add-On", "offer": "Free hotspot for 3 months", "value": 45},
    ],
    "Cross-sell": [
        {"name": "Protect Your Device", "offer": "Snowpack Protection 50% off first 3 months", "value": 22},
        {"name": "Stream More", "offer": "Peak Streaming bundle at $5/month", "value": 15},
        {"name": "Go International", "offer": "Altitude Roaming first trip free", "value": 30},
        {"name": "Add a Line", "offer": "$0 activation for additional line", "value": 35},
    ],
    "Win-back": [
        {"name": "Come Back Offer", "offer": "$100 credit on return", "value": 100},
        {"name": "Fresh Start", "offer": "50% off for 6 months", "value": 150},
        {"name": "We've Changed", "offer": "Free month of service", "value": 75},
    ],
    "Loyalty": [
        {"name": "Rewards Redemption", "offer": "Double points weekend", "value": 0},
        {"name": "Exclusive Access", "offer": "Early upgrade eligibility", "value": 50},
        {"name": "Thank You Gift", "offer": "Free accessory credit $50", "value": 50},
        {"name": "Gold Member Perk", "offer": "Priority customer service", "value": 20},
    ],
    "Seasonal": [
        {"name": "Back to School", "offer": "Free tablet with new line", "value": 300},
        {"name": "Holiday Special", "offer": "BOGO device offer", "value": 500},
        {"name": "Summer Savings", "offer": "3 months free streaming", "value": 30},
        {"name": "Black Friday", "offer": "$400 off flagship phones", "value": 400},
    ],
}


def weighted_choice(distribution: dict) -> str:
    items = list(distribution.keys())
    weights = list(distribution.values())
    return np.random.choice(items, p=weights)


def generate_campaign_responses(customers_df: pd.DataFrame,
                                 avg_per_customer: float = 5.0) -> pd.DataFrame:
    """Generate campaign response records"""
    
    n_customers = len(customers_df)
    est_records = int(n_customers * avg_per_customer)
    
    print(f"  Generating ~{est_records:,} campaign response records...")
    
    records = []
    customer_data = customers_df.set_index('customer_id').to_dict('index')
    
    for customer_id, cust in tqdm(customer_data.items(), desc="  Campaigns"):
        # Number of campaigns based on tenure and value
        tenure = cust.get('tenure_months', 12)
        arpu = cust.get('monthly_arpu', 50)
        churn_risk = cust.get('churn_risk_score', 0.2)
        
        # More campaigns for higher value customers and those at risk
        base_campaigns = np.random.poisson(avg_per_customer)
        if arpu > 70:
            base_campaigns = int(base_campaigns * 1.2)
        if churn_risk > 0.5:
            base_campaigns = int(base_campaigns * 1.3)
        
        base_campaigns = max(1, min(base_campaigns, 15))  # Cap at 15
        
        for _ in range(base_campaigns):
            response_id = str(uuid.uuid4())
            campaign_id = str(uuid.uuid4())[:8].upper()
            
            # Select campaign type (influenced by customer status)
            if churn_risk > 0.5:
                type_weights = {"Retention": 0.40, "Upsell": 0.15, "Cross-sell": 0.10,
                               "Win-back": 0.05, "Loyalty": 0.20, "Seasonal": 0.10}
            elif arpu > 80:
                type_weights = {"Retention": 0.15, "Upsell": 0.30, "Cross-sell": 0.20,
                               "Win-back": 0.02, "Loyalty": 0.25, "Seasonal": 0.08}
            else:
                type_weights = {k: v["weight"] for k, v in CAMPAIGN_TYPES.items()}
            
            campaign_type = weighted_choice(type_weights)
            campaign_info = CAMPAIGN_TYPES[campaign_type]
            
            # Select specific campaign
            templates = CAMPAIGN_TEMPLATES.get(campaign_type, [{"name": "General", "offer": "Special offer", "value": 25}])
            template = np.random.choice(templates)
            
            # Campaign timing
            days_ago = np.random.randint(0, min(365, tenure * 30))
            sent_at = datetime.now() - timedelta(days=days_ago)
            
            # Channel
            channel = weighted_choice(CAMPAIGN_CHANNELS)
            
            # Delivery (most are delivered)
            delivered = np.random.random() < 0.95
            
            # Response funnel
            base_open_rate = campaign_info["response_rate"] * 3  # Open rate higher than response
            base_response_rate = campaign_info["response_rate"]
            base_conversion_rate = campaign_info["conversion_rate"]
            
            # Adjust rates based on customer profile
            if cust.get('app_user', False) and channel in ["App Push", "SMS"]:
                base_open_rate *= 1.3
            if churn_risk > 0.6 and campaign_type == "Retention":
                base_response_rate *= 1.5  # Higher response to retention for at-risk
            
            opened = delivered and np.random.random() < min(base_open_rate, 0.8)
            clicked = opened and np.random.random() < 0.5
            responded = clicked and np.random.random() < min(base_response_rate * 2, 0.6)
            
            # Response type
            if responded:
                if np.random.random() < base_conversion_rate / base_response_rate:
                    response_type = "Accepted"
                    converted = True
                else:
                    response_type = np.random.choice(["Declined", "Ignored"], p=[0.6, 0.4])
                    converted = False
            else:
                response_type = "Ignored"
                converted = False
            
            # Response timing
            if responded:
                response_delay = timedelta(hours=np.random.exponential(48))
                response_at = sent_at + response_delay
            else:
                response_at = None
            
            # Conversion value
            if converted:
                conversion_value = template["value"] * np.random.uniform(0.8, 1.2)
            else:
                conversion_value = 0
            
            # Handle complaints (rare)
            if responded and np.random.random() < 0.02:
                response_type = "Complained"
                converted = False
                conversion_value = 0
            
            record = {
                "response_id": response_id,
                "customer_id": customer_id,
                "campaign_id": campaign_id,
                "campaign_name": template["name"],
                "campaign_type": campaign_type,
                "campaign_category": campaign_type,
                "offer_type": template["offer"],
                "offer_value": template["value"],
                "channel": channel,
                "sent_at": sent_at,
                "delivered": delivered,
                "opened": opened,
                "clicked": clicked,
                "responded": responded,
                "response_type": response_type,
                "response_at": response_at,
                "converted": converted,
                "conversion_value": round(conversion_value, 2),
            }
            records.append(record)
    
    df = pd.DataFrame(records)
    print(f"  ✓ Generated {len(df):,} campaign records")
    return df


