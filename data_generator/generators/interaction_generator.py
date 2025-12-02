"""
Snowmobile Wireless - Interaction Generator
Generates support interaction data
"""

import uuid
from datetime import datetime, timedelta
import numpy as np
import pandas as pd
from tqdm import tqdm
from faker import Faker

import sys
sys.path.append('..')
from config import SUPPORT_CHANNELS, SUPPORT_CATEGORIES, SUPPORT_SUBCATEGORIES

fake = Faker('en_US')
Faker.seed(42)


# Sample verbatims by category and sentiment
VERBATIM_TEMPLATES = {
    "Billing": {
        "negative": [
            "Why is my bill higher than last month? I didn't change anything.",
            "I was charged twice for the same thing. This is unacceptable.",
            "The autopay failed and now you're charging me a late fee?",
            "I don't understand these charges. Your pricing is confusing.",
            "You keep raising prices every year. I'm considering switching.",
        ],
        "neutral": [
            "I need to understand my bill better.",
            "Can you explain these charges?",
            "I'd like to update my payment method.",
            "When is my next payment due?",
        ],
        "positive": [
            "Thanks for the credit on my account.",
            "The new billing app makes it much easier to understand.",
            "I appreciate the autopay discount.",
        ],
    },
    "Technical": {
        "negative": [
            "I have no service at my house. This has been going on for days.",
            "My data is so slow it's unusable. I pay for unlimited!",
            "Calls keep dropping. This is affecting my work.",
            "The 5G coverage you advertised doesn't exist where I live.",
            "Your app crashes every time I try to use it.",
        ],
        "neutral": [
            "My voicemail isn't working. Can you help?",
            "How do I set up WiFi calling?",
            "I need help transferring my data to a new phone.",
        ],
        "positive": [
            "The 5G speeds are amazing!",
            "Thanks for fixing the coverage issue in my area.",
        ],
    },
    "Complaint": {
        "negative": [
            "I've called three times about this and nothing is resolved.",
            "Your customer service is terrible. I've been on hold for an hour.",
            "This is the worst carrier I've ever had.",
            "I want to speak to a supervisor immediately.",
            "I'm filing a complaint with the FCC.",
            "I'm switching to T-Mobile. They actually care about customers.",
        ],
        "neutral": [
            "I'd like to formally complain about my recent experience.",
        ],
        "positive": [],
    },
    "Sales": {
        "negative": [
            "You promised me a discount that's not on my bill.",
            "The phone I bought has issues and I want to return it.",
        ],
        "neutral": [
            "What are my upgrade options?",
            "I'm looking to add a line for my teenager.",
            "Can you compare the Blizzard and Summit plans for me?",
            "What promotions are currently available?",
        ],
        "positive": [
            "I love my new phone! Thanks for the help.",
            "The upgrade process was really smooth.",
        ],
    },
    "General": {
        "negative": [],
        "neutral": [
            "I need to update my address.",
            "Can you tell me where the nearest store is?",
            "What's included in my plan?",
            "How do I check my data usage?",
        ],
        "positive": [
            "I've been a customer for years and I'm happy with the service.",
        ],
    },
    "Account": {
        "negative": [
            "I can't access my account online.",
            "Someone made unauthorized changes to my account.",
        ],
        "neutral": [
            "I need to reset my password.",
            "I'm moving and need to update my address.",
            "I need to change the name on my account.",
        ],
        "positive": [],
    },
}

AGENT_SUMMARIES = {
    "Billing": [
        "Customer inquired about recent bill increase. Explained charges and applied courtesy credit.",
        "Customer reported payment processing issue. Verified payment method and reprocessed.",
        "Customer requested plan change to reduce costs. Reviewed options and updated plan.",
        "Customer disputed overage charges. Reviewed usage and explained fair use policy.",
    ],
    "Technical": [
        "Customer reported service outage. Confirmed tower maintenance in area, provided estimated restoration.",
        "Customer experiencing slow data. Ran network diagnostics and reset network settings.",
        "Customer having issues with voicemail setup. Walked through configuration steps.",
        "Customer reported dropped calls. Submitted ticket for network investigation.",
    ],
    "Complaint": [
        "Customer expressed frustration with previous interaction. Apologized and escalated to supervisor.",
        "Customer threatened to cancel service. Reviewed account and offered retention promotion.",
        "Customer complained about wait times. Acknowledged feedback and expedited resolution.",
    ],
    "Sales": [
        "Customer interested in device upgrade. Reviewed eligible options and processing trade-in.",
        "Customer adding new line for family member. Set up new line with appropriate plan.",
        "Customer comparing plan options. Recommended Powder based on usage patterns.",
    ],
    "General": [
        "Customer requested account information. Verified identity and provided requested details.",
        "Customer asked about store locations. Provided nearest store address and hours.",
        "Customer inquiry about coverage in new area. Checked coverage map and confirmed service.",
    ],
    "Account": [
        "Customer needed password reset. Verified identity and sent reset link.",
        "Customer updating contact information. Made requested changes to account.",
        "Customer inquiring about authorized users. Explained process and added new user.",
    ],
}


def weighted_choice(distribution: dict) -> str:
    items = list(distribution.keys())
    weights = list(distribution.values())
    return np.random.choice(items, p=weights)


def generate_support_interactions(customers_df: pd.DataFrame, 
                                   avg_per_customer: float = 2.0) -> pd.DataFrame:
    """Generate support interaction records"""
    
    n_customers = len(customers_df)
    est_records = int(n_customers * avg_per_customer)
    
    print(f"  Generating ~{est_records:,} support interaction records...")
    
    records = []
    customer_data = customers_df.set_index('customer_id').to_dict('index')
    
    for customer_id, cust in tqdm(customer_data.items(), desc="  Interactions"):
        # Number of interactions based on tenure and churn risk
        base_interactions = np.random.poisson(avg_per_customer)
        
        # High churn risk customers have more interactions
        if cust.get('churn_risk_score', 0) > 0.5:
            base_interactions = int(base_interactions * 1.5)
        
        # Newer customers have more onboarding interactions
        if cust.get('tenure_months', 12) < 6:
            base_interactions += np.random.randint(0, 2)
        
        for _ in range(base_interactions):
            interaction_id = str(uuid.uuid4())
            
            # Random date in last 12 months
            days_ago = np.random.randint(0, 365)
            interaction_date = datetime.now() - timedelta(days=days_ago)
            
            # Channel (influenced by age)
            if cust.get('age', 40) < 35:
                channel_weights = {"App": 0.35, "Chat": 0.30, "Call": 0.15, 
                                  "Email": 0.10, "Store": 0.05, "Social": 0.05}
            elif cust.get('age', 40) > 55:
                channel_weights = {"Call": 0.45, "Store": 0.25, "Email": 0.15,
                                  "App": 0.08, "Chat": 0.05, "Social": 0.02}
            else:
                channel_weights = SUPPORT_CHANNELS
            
            channel = weighted_choice(channel_weights)
            
            # Category (influenced by churn risk)
            if cust.get('churn_risk_score', 0) > 0.6:
                cat_weights = {"Billing": 0.35, "Complaint": 0.25, "Technical": 0.20,
                              "Sales": 0.10, "General": 0.05, "Account": 0.05}
            else:
                cat_weights = SUPPORT_CATEGORIES
            
            category = weighted_choice(cat_weights)
            subcategory = np.random.choice(SUPPORT_SUBCATEGORIES.get(category, ["General"]))
            intent = f"{category} - {subcategory}"
            
            # Sentiment
            if category == "Complaint":
                sentiment = np.random.choice([-0.8, -0.6, -0.4], p=[0.5, 0.3, 0.2])
            elif category in ["Billing", "Technical"] and np.random.random() < 0.4:
                sentiment = round(np.random.uniform(-0.6, 0), 2)
            else:
                sentiment = round(np.random.uniform(-0.2, 0.8), 2)
            
            # CSAT score (correlated with sentiment)
            if sentiment < -0.3:
                csat = np.random.choice([1, 2, 3], p=[0.4, 0.4, 0.2])
            elif sentiment > 0.3:
                csat = np.random.choice([3, 4, 5], p=[0.1, 0.3, 0.6])
            else:
                csat = np.random.choice([2, 3, 4], p=[0.2, 0.5, 0.3])
            
            # Resolution
            if category == "Complaint":
                resolution = np.random.choice(["Resolved", "Escalated", "Pending", "Unresolved"],
                                            p=[0.45, 0.30, 0.15, 0.10])
                resolution_time = np.random.uniform(2, 48)
                fcr = np.random.random() < 0.3
            else:
                resolution = np.random.choice(["Resolved", "Escalated", "Pending"],
                                            p=[0.75, 0.15, 0.10])
                resolution_time = np.random.uniform(0.1, 8)
                fcr = np.random.random() < 0.65
            
            # Verbatim
            sentiment_bucket = "negative" if sentiment < -0.2 else ("positive" if sentiment > 0.3 else "neutral")
            verbatims = VERBATIM_TEMPLATES.get(category, {}).get(sentiment_bucket, [])
            if verbatims:
                verbatim = np.random.choice(verbatims)
            else:
                verbatim = None
            
            # Summary
            summaries = AGENT_SUMMARIES.get(category, ["Assisted customer with inquiry."])
            summary = np.random.choice(summaries)
            
            record = {
                "interaction_id": interaction_id,
                "customer_id": customer_id,
                "interaction_date": interaction_date,
                "channel": channel,
                "category": category,
                "subcategory": subcategory,
                "intent": intent,
                "resolution_status": resolution,
                "resolution_time_hours": round(resolution_time, 2),
                "first_contact_resolution": fcr,
                "sentiment_score": sentiment,
                "csat_score": csat,
                "interaction_summary": summary,
                "customer_verbatim": verbatim,
            }
            records.append(record)
    
    df = pd.DataFrame(records)
    print(f"  ✓ Generated {len(df):,} interaction records")
    return df


