"""
Snowmobile Wireless - Customer Digital Twin
Main Streamlit Application

This is the main entry point for the Streamlit in Snowflake application.
"""

import streamlit as st

# Page configuration
st.set_page_config(
    page_title="Snowmobile Digital Twin",
    page_icon="❄️",
    layout="wide",
    initial_sidebar_state="expanded"
)

# Custom CSS for Snowmobile branding
st.markdown("""
<style>
    /* Snowmobile Brand Colors */
    :root {
        --arctic-blue: #29B5E8;
        --glacier-gray: #6E7681;
        --snow-white: #FFFFFF;
        --deep-navy: #1B2838;
    }
    
    /* Header styling */
    .main-header {
        background: linear-gradient(135deg, #1B2838 0%, #29B5E8 100%);
        padding: 2rem;
        border-radius: 10px;
        margin-bottom: 2rem;
        color: white;
    }
    
    .main-header h1 {
        color: white !important;
        margin-bottom: 0.5rem;
    }
    
    .main-header p {
        color: rgba(255,255,255,0.8);
        font-size: 1.1rem;
    }
    
    /* Card styling */
    .metric-card {
        background: white;
        padding: 1.5rem;
        border-radius: 10px;
        box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        border-left: 4px solid #29B5E8;
    }
    
    /* Segment colors */
    .segment-value-seekers { border-left-color: #FF6B6B; }
    .segment-data-streamers { border-left-color: #4ECDC4; }
    .segment-family-connectors { border-left-color: #45B7D1; }
    .segment-steady-loyalists { border-left-color: #96CEB4; }
    .segment-premium-techies { border-left-color: #9B59B6; }
    .segment-rural-reliables { border-left-color: #F39C12; }
    .segment-young-digitals { border-left-color: #E74C3C; }
    .segment-at-risk { border-left-color: #C0392B; }
    
    /* Sidebar styling */
    .css-1d391kg {
        background-color: #1B2838;
    }
    
    /* Button styling */
    .stButton>button {
        background-color: #29B5E8;
        color: white;
        border: none;
        border-radius: 5px;
        padding: 0.5rem 1rem;
    }
    
    .stButton>button:hover {
        background-color: #1E8FC2;
    }
</style>
""", unsafe_allow_html=True)


def main():
    # Header
    st.markdown("""
    <div class="main-header">
        <h1>❄️ Snowmobile Wireless - Customer Digital Twin</h1>
        <p>AI-powered customer personas for marketing simulation</p>
    </div>
    """, unsafe_allow_html=True)
    
    # Sidebar navigation
    st.sidebar.image("https://via.placeholder.com/200x60/29B5E8/FFFFFF?text=Snowmobile", width=200)
    st.sidebar.markdown("---")
    
    st.sidebar.markdown("### Navigation")
    page = st.sidebar.radio(
        "Select Page",
        ["🏠 Home", "📊 Segment Explorer", "👥 Persona Gallery", 
         "🎯 Simulation Studio", "📈 Campaign Tester", "📜 History"],
        label_visibility="collapsed"
    )
    
    st.sidebar.markdown("---")
    st.sidebar.markdown("### Quick Stats")
    
    # These would come from database in production
    st.sidebar.metric("Total Customers", "1,000,000")
    st.sidebar.metric("Active Segments", "8")
    st.sidebar.metric("Simulations Run", "127")
    
    # Route to appropriate page
    if page == "🏠 Home":
        show_home()
    elif page == "📊 Segment Explorer":
        show_segment_explorer()
    elif page == "👥 Persona Gallery":
        show_persona_gallery()
    elif page == "🎯 Simulation Studio":
        show_simulation_studio()
    elif page == "📈 Campaign Tester":
        show_campaign_tester()
    elif page == "📜 History":
        show_history()


def show_home():
    """Home page with overview"""
    
    st.markdown("## Welcome to Customer Digital Twin")
    
    st.markdown("""
    This application allows you to interact with AI-powered customer personas 
    to predict how different customer segments will react to:
    
    - 💰 **Price changes** (increases, promotions, discounts)
    - 📱 **New products** (plans, features, bundles)
    - 📋 **Policy changes** (terms, fair use, coverage)
    - 🏃 **Competitor moves** (promotions, new offerings)
    """)
    
    # Overview metrics
    col1, col2, col3, col4 = st.columns(4)
    
    with col1:
        st.markdown("""
        <div class="metric-card">
            <h3>28M</h3>
            <p>Total Subscribers</p>
        </div>
        """, unsafe_allow_html=True)
    
    with col2:
        st.markdown("""
        <div class="metric-card">
            <h3>8</h3>
            <p>Customer Segments</p>
        </div>
        """, unsafe_allow_html=True)
    
    with col3:
        st.markdown("""
        <div class="metric-card">
            <h3>$68</h3>
            <p>Avg ARPU</p>
        </div>
        """, unsafe_allow_html=True)
    
    with col4:
        st.markdown("""
        <div class="metric-card">
            <h3>+32</h3>
            <p>NPS Score</p>
        </div>
        """, unsafe_allow_html=True)
    
    st.markdown("---")
    
    # Segment overview
    st.markdown("### Customer Segments")
    
    segments_data = [
        {"name": "Value Seekers", "pct": 20, "arpu": 38, "color": "#FF6B6B"},
        {"name": "Data Streamers", "pct": 16, "arpu": 72, "color": "#4ECDC4"},
        {"name": "Family Connectors", "pct": 18, "arpu": 125, "color": "#45B7D1"},
        {"name": "Steady Loyalists", "pct": 15, "arpu": 52, "color": "#96CEB4"},
        {"name": "Premium Techies", "pct": 10, "arpu": 95, "color": "#9B59B6"},
        {"name": "Rural Reliables", "pct": 8, "arpu": 48, "color": "#F39C12"},
        {"name": "Young Digitals", "pct": 9, "arpu": 55, "color": "#E74C3C"},
        {"name": "At-Risk Defectors", "pct": 4, "arpu": 45, "color": "#C0392B"},
    ]
    
    cols = st.columns(4)
    for i, seg in enumerate(segments_data):
        with cols[i % 4]:
            st.markdown(f"""
            <div style="background: white; padding: 1rem; border-radius: 8px; 
                        border-left: 4px solid {seg['color']}; margin-bottom: 1rem;
                        box-shadow: 0 2px 5px rgba(0,0,0,0.1);">
                <strong>{seg['name']}</strong><br>
                <span style="color: #666;">{seg['pct']}% of base</span><br>
                <span style="color: {seg['color']}; font-size: 1.2rem;">${seg['arpu']} ARPU</span>
            </div>
            """, unsafe_allow_html=True)
    
    st.markdown("---")
    
    # Quick actions
    st.markdown("### Quick Actions")
    
    col1, col2, col3 = st.columns(3)
    
    with col1:
        if st.button("🎯 Run Price Simulation", use_container_width=True):
            st.session_state.page = "simulation"
            st.rerun()
    
    with col2:
        if st.button("👥 View Personas", use_container_width=True):
            st.session_state.page = "personas"
            st.rerun()
    
    with col3:
        if st.button("📊 Explore Segments", use_container_width=True):
            st.session_state.page = "segments"
            st.rerun()


def show_segment_explorer():
    """Segment analysis page"""
    
    st.markdown("## 📊 Segment Explorer")
    st.markdown("Analyze customer segments and their characteristics")
    
    # Segment selector
    segment = st.selectbox(
        "Select Segment",
        ["All Segments", "S1: Value Seekers", "S2: Data Streamers", 
         "S3: Family Connectors", "S4: Steady Loyalists",
         "S5: Premium Techies", "S6: Rural Reliables",
         "S7: Young Digitals", "S8: At-Risk Defectors"]
    )
    
    col1, col2 = st.columns([2, 1])
    
    with col1:
        st.markdown("### Segment Distribution")
        # Placeholder for chart
        st.info("📊 Segment distribution chart would render here using Snowflake data")
        
        st.markdown("### Key Metrics Comparison")
        st.info("📈 Radar chart comparing segment metrics would render here")
    
    with col2:
        st.markdown("### Segment Details")
        
        if "Value Seekers" in segment:
            st.markdown("""
            **Value Seekers (S1)**
            
            - 📊 **20%** of customer base
            - 💰 **$38** average ARPU
            - ⏱️ **14 months** avg tenure
            - 📱 **Glacier/Flurry** typical plan
            - ⚠️ **High** churn risk
            - 💵 **Very High** price sensitivity
            
            **Key Characteristics:**
            - Price-conscious shoppers
            - Respond to discounts
            - Shorter tenure
            - Prepaid preference
            
            **Recommended Approach:**
            Focus on value messaging, 
            avoid price increases without 
            significant value-add.
            """)


def show_persona_gallery():
    """Persona gallery page"""
    
    st.markdown("## 👥 Persona Gallery")
    st.markdown("Browse AI-generated customer personas")
    
    # Persona cards
    personas = [
        {
            "name": "Carlos Mendez",
            "segment": "Value Seekers",
            "age": 34,
            "location": "Phoenix, AZ",
            "tagline": "Budget-conscious deal hunter",
            "plan": "Glacier",
            "arpu": 38
        },
        {
            "name": "Jordan Chen",
            "segment": "Data Streamers", 
            "age": 28,
            "location": "Austin, TX",
            "tagline": "Content-obsessed streamer",
            "plan": "Blizzard",
            "arpu": 72
        },
        {
            "name": "Michelle Torres",
            "segment": "Family Connectors",
            "age": 41,
            "location": "Gilbert, AZ",
            "tagline": "Family's wireless lifeline",
            "plan": "Avalanche",
            "arpu": 125
        },
        {
            "name": "Robert Patterson",
            "segment": "Steady Loyalists",
            "age": 62,
            "location": "Columbus, OH",
            "tagline": "Values what works",
            "plan": "Powder",
            "arpu": 52
        },
    ]
    
    cols = st.columns(2)
    for i, persona in enumerate(personas):
        with cols[i % 2]:
            with st.expander(f"**{persona['name']}** - {persona['segment']}", expanded=i==0):
                st.markdown(f"""
                **{persona['tagline']}**
                
                - 🎂 **Age:** {persona['age']}
                - 📍 **Location:** {persona['location']}
                - 📱 **Plan:** {persona['plan']}
                - 💰 **ARPU:** ${persona['arpu']}
                """)
                
                if st.button(f"💬 Ask {persona['name'].split()[0]}", key=f"ask_{i}"):
                    st.session_state.selected_persona = persona['name']
                    st.info(f"Navigate to Simulation Studio to chat with {persona['name']}")


def show_simulation_studio():
    """Main simulation interface"""
    
    st.markdown("## 🎯 Simulation Studio")
    st.markdown("Test scenarios and see how personas react")
    
    # Scenario builder
    with st.expander("📋 Scenario Builder", expanded=True):
        scenario_type = st.selectbox(
            "Scenario Type",
            ["Price Change", "New Product Launch", "Policy Change", "Competitor Response"]
        )
        
        if scenario_type == "Price Change":
            col1, col2 = st.columns(2)
            with col1:
                price_change = st.slider("Price Change ($)", -10, 10, 5)
                affected_plans = st.multiselect(
                    "Affected Plans",
                    ["Glacier", "Flurry", "Powder", "Blizzard", "Avalanche", "Summit"],
                    default=["Blizzard", "Summit"]
                )
            with col2:
                value_add = st.checkbox("Include value-add?")
                if value_add:
                    value_add_desc = st.text_input("Value-add description", "Disney+ Basic included")
                notice_days = st.number_input("Notice period (days)", 30, 90, 60)
            
            scenario_text = f"""Snowmobile is announcing a ${abs(price_change)}/month price {'increase' if price_change > 0 else 'decrease'} on {', '.join(affected_plans)} plans.
{'Customers will receive ' + value_add_desc + ' as part of this change.' if value_add else ''}
Customers will receive {notice_days} days notice via email and app notification."""
        
        else:
            scenario_text = st.text_area(
                "Scenario Description",
                "Describe the scenario you want to test...",
                height=100
            )
        
        st.markdown("**Preview:**")
        st.info(scenario_text)
    
    # Segment selection
    st.markdown("### Select Segments to Simulate")
    
    col1, col2 = st.columns([3, 1])
    with col1:
        segments = st.multiselect(
            "Segments",
            ["S1: Value Seekers", "S2: Data Streamers", "S3: Family Connectors",
             "S4: Steady Loyalists", "S5: Premium Techies", "S6: Rural Reliables",
             "S7: Young Digitals", "S8: At-Risk Defectors"],
            default=["S1: Value Seekers", "S2: Data Streamers", "S3: Family Connectors"]
        )
    with col2:
        if st.button("Select All"):
            segments = ["S1: Value Seekers", "S2: Data Streamers", "S3: Family Connectors",
                       "S4: Steady Loyalists", "S5: Premium Techies", "S6: Rural Reliables",
                       "S7: Young Digitals", "S8: At-Risk Defectors"]
    
    # Run simulation
    if st.button("🚀 Run Simulation", type="primary", use_container_width=True):
        with st.spinner("Running simulation across all personas..."):
            # This would call the Snowflake function in production
            import time
            time.sleep(2)
            
            st.success("Simulation complete!")
            
            # Results
            st.markdown("### Simulation Results")
            
            # Summary metrics
            col1, col2, col3, col4 = st.columns(4)
            with col1:
                st.metric("Overall Sentiment", "-0.18", delta="-0.18")
            with col2:
                st.metric("Est. Churn Impact", "+2.1%", delta="2.1%", delta_color="inverse")
            with col3:
                st.metric("Revenue at Risk", "$2.3M", delta="-$2.3M", delta_color="inverse")
            with col4:
                st.metric("Customers Affected", "450K")
            
            # Detailed results table
            st.markdown("### Segment Reactions")
            
            results_data = {
                "Segment": ["Value Seekers", "Data Streamers", "Family Connectors"],
                "Sentiment": [-0.72, 0.12, -0.15],
                "Likely Action": ["COMPLAIN", "ACCEPT", "ACCEPT"],
                "Churn Risk Δ": ["+4.8%", "+0.4%", "+0.6%"],
                "Sample Reaction": [
                    "Another price increase? This is exactly why I left AT&T!",
                    "Disney+ is nice, but still $5 more...",
                    "Why am I paying more? I haven't changed anything."
                ]
            }
            
            st.dataframe(results_data, use_container_width=True)
            
            # Detailed persona response
            st.markdown("### Deep Dive: Value Seekers")
            st.warning("""
            **Carlos Mendez (Value Seekers persona)**
            
            *Initial Reaction:*
            "Another price increase? This is the second one this year! $5 more for Disney+ I don't even want? This is exactly why I was looking at Mint Mobile."
            
            *What would change his mind:*
            "If you gave me a loyalty discount for being a customer, or let me keep my old rate, I might consider staying. But just adding $5 with no option? That's not fair."
            
            *Likely verbatim to customer service:*
            "I want to cancel. Can you match what Mint Mobile is offering or give me some kind of discount? I've been a good customer."
            """)


def show_campaign_tester():
    """Campaign testing page"""
    
    st.markdown("## 📈 Campaign Tester")
    st.markdown("Test marketing campaigns across personas")
    
    st.info("Upload campaign content or enter message to test across all personas.")
    
    campaign_text = st.text_area(
        "Campaign Message",
        """Hi [Name],

As a valued Snowmobile customer, we're excited to offer you an exclusive deal!

Upgrade to our Blizzard Unlimited plan and get:
✓ Unlimited 5G data
✓ FREE Disney+ subscription ($8/month value)
✓ 50GB hotspot included

All for just $75/month - that's $20 off the regular price!

Tap here to upgrade now: [LINK]

Thanks for being part of the Snowmobile family! ❄️""",
        height=200
    )
    
    if st.button("🧪 Test Campaign", type="primary"):
        st.markdown("### Campaign Test Results")
        
        col1, col2 = st.columns(2)
        with col1:
            st.metric("Predicted Open Rate", "42%")
            st.metric("Predicted Click Rate", "18%")
        with col2:
            st.metric("Predicted Conversion", "8%")
            st.metric("Est. Revenue Impact", "+$125K")
        
        st.markdown("### Segment Response Predictions")
        st.info("Response predictions by segment would appear here")


def show_history():
    """Simulation history page"""
    
    st.markdown("## 📜 Simulation History")
    st.markdown("View past simulations and their outcomes")
    
    # Mock history data
    history = [
        {"date": "2024-12-01", "scenario": "5% price increase on Blizzard", "sentiment": -0.18, "status": "Completed"},
        {"date": "2024-11-28", "scenario": "Disney+ bundle launch", "sentiment": 0.35, "status": "Completed"},
        {"date": "2024-11-25", "scenario": "T-Mobile competitor response", "sentiment": -0.22, "status": "Completed"},
    ]
    
    for h in history:
        with st.expander(f"**{h['date']}** - {h['scenario']}"):
            st.markdown(f"""
            - **Scenario:** {h['scenario']}
            - **Overall Sentiment:** {h['sentiment']}
            - **Status:** {h['status']}
            """)
            if st.button("View Details", key=h['date']):
                st.info("Full simulation details would load here")


if __name__ == "__main__":
    main()


