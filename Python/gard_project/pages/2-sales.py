import pandas as pd 
import numpy as np 
import plotly.express as px
import streamlit as st 
import os
import warnings
warnings.filterwarnings("ignore")
st.set_page_config(page_title="Supply Chain", layout="wide", initial_sidebar_state="expanded", page_icon="📊")

#load data
sales = pd.read_csv('sales.csv')
orders = pd.read_csv('orders.csv')
products = pd.read_csv('products.csv')
product_sales= pd.merge(products, sales, on='SKU', how='left')


#transforming data
#orders
orders['Order_Date'] = pd.to_datetime(orders['Order_Date'])
orders['Ship_Date'] = pd.to_datetime(orders['Ship_Date'])
orders['Delivery_Date'] = pd.to_datetime(orders['Delivery_Date'])
orders['Discount_%'] = pd.to_numeric(orders['Discount_%'], errors='coerce')
orders['Total_Revenue'] = pd.to_numeric(orders['Total_Revenue'], errors='coerce')
orders['Total_Cost'] = pd.to_numeric(orders['Total_Cost'], errors='coerce')
orders['Profit'] = pd.to_numeric(orders['Profit'], errors='coerce')
#sales
sales['Sale_Date'] = pd.to_datetime(sales['Sale_Date'])##checked
sales['Discount_%'] = pd.to_numeric(sales['Discount_%'], errors='coerce')
print(sales.info())


#calculations
highest_discount = sales['Discount_%'].fillna(0).max() #checked
sales['sale_month_num'] = sales['Sale_Date'].dt.month #checked
sales['month_name'] = sales['Sale_Date'].dt.strftime('%B') #checked
monthly_sales = sales.groupby(['sale_month_num', 'month_name'])['Total_Revenue'].sum().reset_index()
monthly_sales = monthly_sales.sort_values('sale_month_num')
highest_sales_month = monthly_sales.loc[monthly_sales['Total_Revenue'].idxmax(), 'month_name']
actual_revenue = sales['Total_Revenue'].sum() #checked
orders['Month'] = orders['Order_Date'].dt.month
orders ['month_name'] = orders['Order_Date'].dt.strftime('%B')

#revenue by order
orders_rev = orders.groupby('month_name')['Total_Revenue'].sum().reset_index()
#revenue by sales
sales_rev = sales.groupby('month_name')['Total_Revenue'].sum().reset_index()
#composite revenue 
comparison = pd.merge(orders_rev, sales_rev, on='month_name', how='inner')
#melting 
rev_melted = comparison.melt(
    id_vars='month_name', 
    value_vars=['Total_Revenue_x', 'Total_Revenue_y'],
    var_name='Revenue Type', 
    value_name='Amount'
)
rev_melted['month_num'] = pd.to_datetime(rev_melted['month_name'], format='%B').dt.month
rev_melted = rev_melted.sort_values('month_num')
rev_melted['Revenue Type'] = rev_melted['Revenue Type'].map({
    'Total_Revenue_y': 'Orders Revenue',
    'Total_Revenue_x': 'Sales Revenue'
})

colors=["#FFF9D2","#FFEBCC","#BFDDF0","#8CC0EB","#2F2FE4"]
#dashboard
#dashboard grid
st.title("📊 Supply Chain Dashboard")
st.markdown("Sales Performance")
st.divider()
col1, col2, col3=st.columns(3)
with col1:
        with st.container(border=True):
         st.metric(label="Highest Discount", value=f"{highest_discount:.0f}%")
with col2:
    with st.container(border=True):
        st.metric(label="Highest Month By Sales", value= highest_sales_month)
with col3:
    with st.container(border=True):
        st.metric(label="Net Revenue", value=f"{actual_revenue/1e6:.1f}M$")


with st.container(border=True):
    st.subheader("Orders vs Sales revenue")
    fig_compare = px.bar(
        rev_melted,
        x='month_name',
        y='Amount',
        color='Revenue Type',
        barmode='group',
        text_auto='.2s',
       
    )
    
    fig_compare.update_layout(height=450, hovermode="x unified",   font=dict(
        family="Arial, sans-serif", 
        size=16
    ))
    st.plotly_chart(fig_compare, use_container_width=True)


chartcol1, chartcol2 = st.columns(2, gap="medium")
with chartcol1:
   with st.container(border=True):
    st.subheader("Top 5 Products by Sales")
    top_sales_df = product_sales.sort_values(by='Total_Revenue', ascending=False).head(5)
    fig_sales = px.bar(
        top_sales_df,
        x='Product_Name',
        y='Total_Revenue', 
        text='Total_Revenue',
        text_auto='.2s',
        color='Total_Revenue',
        color_continuous_scale=colors,
        labels={'Total_Revenue': 'Total Revenue', 'Product_Name': 'Product Name'}
    )
    fig_sales.update_layout(xaxis_tickangle=-90)
    fig_sales.update_layout(coloraxis_showscale=False)
    fig_sales.update_layout(height=420,  font=dict(
        family="Arial, sans-serif", 
        size=16
    )  
    
    )
    st.plotly_chart(fig_sales, use_container_width=True)

with chartcol2:
   with st.container(border=True):
      st.subheader("Sales by Category")
      category_sales = product_sales.groupby('Category')['Total_Revenue'].sum().reset_index()
      fig_pie = px.pie(
        category_sales, 
        values='Total_Revenue', 
        names='Category', 
        hole=0.4, 
        color_discrete_sequence=colors
    )
      fig_pie.update_traces(textposition='inside', textinfo='percent+label')
      fig_pie.update_layout(height=460)
      fig_pie.update_layout(
    margin=dict(l=0, r=0, t=30, b=0), 
    showlegend=False,                
    height=420,
    font=dict(
        family="Arial, sans-serif", 
        size=16
    )                      
)
      st.plotly_chart(fig_pie, use_container_width=True)




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
