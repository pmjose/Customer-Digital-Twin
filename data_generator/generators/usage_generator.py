"""
Snowmobile Wireless - Usage Generator
Generates monthly usage and billing data
"""

import uuid
from datetime import date, timedelta
import numpy as np
import pandas as pd
from tqdm import tqdm

import sys
sys.path.append('..')
from config import DATA_USAGE_BY_PLAN, VOICE_USAGE_BY_PLAN


def generate_monthly_usage(customers_df: pd.DataFrame, months: int = 12) -> pd.DataFrame:
    """Generate monthly usage records for all customers"""
    
    n_customers = len(customers_df)
    total_records = n_customers * months
    
    print(f"  Generating {total_records:,} monthly usage records...")
    print(f"    ({n_customers:,} customers × {months} months)")
    
    records = []
    
    # Pre-compute customer data for faster access
    customer_data = customers_df.set_index('customer_id').to_dict('index')
    customer_ids = customers_df['customer_id'].tolist()
    
    for customer_id in tqdm(customer_ids, desc="  Usage"):
        cust = customer_data[customer_id]
        plan_name = cust['plan_name']
        tenure = cust['tenure_months']
        lines = cust['lines_on_account']
        
        # Get usage parameters for plan
        data_params = DATA_USAGE_BY_PLAN.get(plan_name, DATA_USAGE_BY_PLAN["Powder"])
        voice_params = VOICE_USAGE_BY_PLAN.get(plan_name, VOICE_USAGE_BY_PLAN["Powder"])
        
        # Generate usage trend (some customers increase, some decrease)
        trend = np.random.choice(["up", "stable", "down"], p=[0.3, 0.5, 0.2])
        trend_factor = {"up": 1.02, "stable": 1.0, "down": 0.98}[trend]
        
        # Seasonal factors (higher usage in summer, holidays)
        seasonal_factors = {
            1: 1.0, 2: 0.95, 3: 1.0, 4: 1.0, 5: 1.05, 6: 1.10,
            7: 1.15, 8: 1.12, 9: 1.0, 10: 1.0, 11: 1.05, 12: 1.10
        }
        
        for month_offset in range(min(months, tenure)):
            usage_id = str(uuid.uuid4())
            billing_month = date.today().replace(day=1) - timedelta(days=30 * (months - month_offset - 1))
            billing_month = billing_month.replace(day=1)
            
            month_num = billing_month.month
            seasonal = seasonal_factors[month_num]
            month_trend = trend_factor ** month_offset
            
            # Data usage
            base_data = max(0, np.random.normal(data_params["mean"], data_params["std"]))
            data_usage = round(min(base_data * seasonal * month_trend * lines, 
                                  data_params.get("max", 200)), 3)
            
            # 5G percentage (higher for newer customers with 5G devices)
            if cust.get('is_5g_capable', False):
                data_5g_pct = round(min(np.random.normal(40, 20), 80), 2)
                data_4g_pct = round(100 - data_5g_pct, 2)
            else:
                data_5g_pct = 0
                data_4g_pct = 100
            
            # Throttled days (only for limited plans)
            plan_limit = DATA_USAGE_BY_PLAN[plan_name].get("max", 999)
            if data_usage > plan_limit * 0.9 and plan_limit < 100:
                throttled_days = np.random.randint(0, 5)
            else:
                throttled_days = 0
            
            # Voice usage
            voice_total = max(0, int(np.random.normal(voice_params["mean"], voice_params["std"]) * lines))
            voice_onnet = int(voice_total * np.random.uniform(0.4, 0.6))
            voice_offnet = int(voice_total * np.random.uniform(0.3, 0.5))
            voice_intl = int(voice_total * np.random.uniform(0, 0.1))
            calls_count = int(voice_total / np.random.uniform(2, 5))  # Avg call length 2-5 min
            
            # Messaging
            sms_sent = int(np.random.exponential(50) * lines)
            mms_sent = int(np.random.exponential(5) * lines)
            
            # Roaming (rare)
            if cust.get('has_intl_roaming', False) and np.random.random() < 0.1:
                roaming_days = np.random.randint(1, 14)
                roaming_data = round(np.random.uniform(0.5, 3), 3)
                roaming_voice = np.random.randint(10, 100)
            else:
                roaming_days = 0
                roaming_data = 0
                roaming_voice = 0
            
            # Billing
            base_charge = cust['plan_price']
            
            # Overage charges (for limited plans)
            if plan_name in ["Glacier", "Flurry", "Powder"] and data_usage > plan_limit:
                overage = round((data_usage - plan_limit) * 10, 2)  # $10/GB overage
            else:
                overage = 0
            
            # Roaming charges
            roaming_charges = round(roaming_days * 10 + roaming_data * 15, 2) if roaming_days > 0 else 0
            
            # Add-on charges
            addon_charges = 0
            if cust.get('has_device_protection', False):
                addon_charges += 15
            if cust.get('has_streaming_bundle', False):
                addon_charges += 10
            
            # Discounts
            discounts = 0
            if cust.get('autopay_enrolled', False):
                discounts += 5  # Autopay discount
            if tenure > 24:
                discounts += round(base_charge * 0.05, 2)  # Loyalty discount
            
            total_bill = round(max(0, base_charge + overage + roaming_charges + addon_charges - discounts), 2)
            
            # Payment behavior
            if cust.get('credit_class', 'B') == 'A':
                payment_status = np.random.choice(["Paid", "Paid", "Paid", "Late"], p=[0.95, 0.02, 0.02, 0.01])
                days_to_payment = np.random.randint(1, 15)
            elif cust.get('credit_class', 'B') == 'D':
                payment_status = np.random.choice(["Paid", "Late", "Partial", "Unpaid"], p=[0.60, 0.25, 0.10, 0.05])
                days_to_payment = np.random.randint(10, 45)
            else:
                payment_status = np.random.choice(["Paid", "Late", "Partial"], p=[0.85, 0.12, 0.03])
                days_to_payment = np.random.randint(5, 25)
            
            record = {
                "usage_id": usage_id,
                "customer_id": customer_id,
                "billing_month": billing_month,
                "voice_minutes_onnet": voice_onnet,
                "voice_minutes_offnet": voice_offnet,
                "voice_minutes_intl": voice_intl,
                "voice_calls_count": calls_count,
                "data_usage_gb": data_usage,
                "data_usage_4g_pct": data_4g_pct,
                "data_usage_5g_pct": data_5g_pct,
                "data_throttled_days": throttled_days,
                "sms_sent": sms_sent,
                "mms_sent": mms_sent,
                "roaming_days": roaming_days,
                "roaming_data_gb": roaming_data,
                "roaming_voice_min": roaming_voice,
                "base_charge": base_charge,
                "overage_charges": overage,
                "roaming_charges": roaming_charges,
                "add_on_charges": addon_charges,
                "discounts_applied": discounts,
                "total_bill": total_bill,
                "payment_status": payment_status,
                "days_to_payment": days_to_payment,
            }
            records.append(record)
    
    df = pd.DataFrame(records)
    print(f"  ✓ Generated {len(df):,} usage records")
    return df


