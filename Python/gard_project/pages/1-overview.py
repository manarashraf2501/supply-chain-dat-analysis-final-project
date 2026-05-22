import pandas as pd 
import numpy as np 
import plotly.express as px
import streamlit as st 
st.set_page_config(page_title="Supply Chain", layout="wide", initial_sidebar_state="expanded", page_icon="📊")

#load data
orders = pd.read_csv('orders.csv')
returns = pd.read_csv('returns.csv')
sales = pd.read_csv('sales.csv')
products = pd.read_csv('products.csv')
product_sales= pd.merge(products, sales, on='SKU', how='left')


#metrics
total_revenue = sales['Total_Revenue'].sum()
total_orders = orders['Order_ID'].nunique()
returned= returns['Order_ID'].nunique()
return_rate= returned/total_orders*100
products_sale = product_sales.groupby('Product_Name')['Total_Revenue'].sum()
best_selling_product = products_sale.idxmax()

#calculations
sales['Sale_Date'] = pd.to_datetime(sales['Sale_Date'])##checked
sales['sale_month_num'] = sales['Sale_Date'].dt.month #checked
sales['month_name'] = sales['Sale_Date'].dt.strftime('%B') #checked
monthly_sales = sales.groupby(['sale_month_num', 'month_name'])['Total_Revenue'].sum().reset_index()
monthly_sales = monthly_sales.sort_values('sale_month_num')
monthly_sales.rename(columns={'Total_Revenue': 'Actual Revenue'}, inplace=True)
monthly_sales = monthly_sales.sort_values('sale_month_num')
sales['sale_month_num'] = sales['Sale_Date'].dt.month #checked
sales['month_name'] = sales['Sale_Date'].dt.strftime('%B') #checked
monthly_sales = sales.groupby(['sale_month_num', 'month_name'])['Total_Revenue'].sum().reset_index()





st.title("📊 Supply Chain Dashboard")
st.markdown("Quick overview on performance")
st.divider()

#kpis
col1, col2= st.columns(2)
with col1:
        with st.container(border=True):
         st.metric(label="Total Revenue", value=f"{total_revenue/1e6:.1f}M $")
with col2:
    with st.container(border=True):
        st.metric(label="Total Orders", value=f"{total_orders/1e3:.0f}K")

col1, col2= st.columns(2)
with col1:
        with st.container(border=True):
         st.metric(label="Return Rate", value=f"{return_rate:.0f}%")
with col2:
    with st.container(border=True):
        st.metric(label="Best Selling Product", value= best_selling_product)



#chart
    
with st.container(border=True):
        st.subheader("Monthly Revenue Trend")
        fig_monthly = px.line(
        monthly_sales,
        x='month_name',
        y='Total_Revenue',
        markers=True,
        color_discrete_sequence=['#2F2FE4']
    )
        fig_monthly.update_layout(
        xaxis_title="",
        yaxis_title="Total Revenue",
        height=370,
        font=dict(family="Arial, sans-serif",size=16),
        margin=dict(l=20, r=20, t=30, b=20)
    )
        st.plotly_chart(fig_monthly, use_container_width=True)



#styling 
st.markdown("""
    <style>
    /* (Label) */
    [data-testid="stMetricLabel"] {
        display: flex;
        justify-content: center;
        align-items: center;
        width: 100%;
        text-align: center;
    }

    /*(Value) */
    [data-testid="stMetricValue"] {
        display: flex;
        justify-content: center;
        align-items: center;
        width: 100%;
        text-align: center;
        font-size: 1.9em;
        font-weight: bolder;
    }
   
    
    /* (Container)*/
    [data-testid="stMetric"] {
            text-align: center;
        }
    </style>
    """, unsafe_allow_html=True)
