import pandas as pd 
import numpy as np 
import plotly.express as px
import streamlit as st 
st.set_page_config(page_title="Supply Chain", layout="wide", initial_sidebar_state="expanded", page_icon="📊")


#loading data
orders = pd.read_csv('orders.csv')
print(orders.info())
products = pd.read_csv('products.csv')
print(products.info())
returns = pd.read_csv('returns.csv')
print(returns.info())
sales = pd.read_csv('sales.csv')
print(sales.info())




#transforming data
#orders
orders['Order_Date'] = pd.to_datetime(orders['Order_Date'])
orders['Ship_Date'] = pd.to_datetime(orders['Ship_Date'])
orders['Delivery_Date'] = pd.to_datetime(orders['Delivery_Date'])
orders['Discount_%'] = pd.to_numeric(orders['Discount_%'], errors='coerce')
orders['Total_Revenue'] = pd.to_numeric(orders['Total_Revenue'], errors='coerce')
orders['Total_Cost'] = pd.to_numeric(orders['Total_Cost'], errors='coerce')
orders['Profit'] = pd.to_numeric(orders['Profit'], errors='coerce')
#returns
returns['Return_Date'] = pd.to_datetime(returns['Return_Date'])
returns['Discount_%'] = pd.to_numeric(returns['Discount_%'], errors='coerce')
returns['Refund_Amount'] = pd.to_numeric(returns['Refund_Amount'], errors='coerce')
#sales
sales['Sale_Date'] = pd.to_datetime(sales['Sale_Date'])

######################################


#calculating monthly orders
orders['Month'] = orders['Order_Date'].dt.month
orders ['month_name'] = orders['Order_Date'].dt.strftime('%B')
monthly_orders = orders.groupby(['Month', 'month_name'])['Order_ID'].count().reset_index()
monthly_orders = monthly_orders.sort_values('Month')
#calculating delivery time
orders['Delivery_Date'] = pd.to_datetime(orders['Delivery_Date'])
orders['delivery_day'] = orders['Delivery_Date'].dt.day
orders['Order_Date'] = pd.to_datetime(orders['Order_Date'])
orders['order_day'] = orders['Order_Date'].dt.day

#calculating avg orders delay
orders['ship_day'] = orders['Ship_Date'].dt.day
orders['order_shipping'] = (orders['Ship_Date'] - orders['Order_Date']).dt.days
avg_order_delay = orders['order_shipping'].mean()

# stating order status 
def calculate_order_delay (row):
    if row['order_shipping']< avg_order_delay:
        return 'early'
    elif row['order_shipping'] > avg_order_delay:
        return 'late'
    else:        
        return 'on time'
    
orders['Shipping_Status'] = orders.apply(calculate_order_delay, axis=1)

#calculating returned products
returned= returns['Returned_Qty'].sum()

#calculating delaying in orders and regions 
total_orders = orders['Order_ID'].nunique()
orders['Shipping_Status'] = orders.apply(calculate_order_delay, axis=1)
late_orders = (orders['Shipping_Status']== 'late').sum()
late_by_region = orders.groupby('Region')['Shipping_Status'].apply(lambda x: (x == 'late').sum()).sort_values(ascending=False)
max_late_region = late_by_region.idxmax()
late_orders_percentage = (late_orders / total_orders) * 100


#merging dataframes
product_sales= pd.merge(products, sales, on='SKU', how='left')
orders_sales = pd.merge(orders, sales, on='Order_ID', how='left')
orders_products = pd.merge(orders, products, on='SKU', how='left')
returns_products = pd.merge(returns, orders_products, on='Order_ID', how='left')


# #dashboard
# # dashboard grid
color2=["#FFF9D2","#FFEBCC","#BFDDF0","#8CC0EB","#2F2FE4"]
st.title("📊 Supply Chain Dashboard")
st.markdown("returns performance")
st.divider()
col1, col2, col3 = st.columns(3)
with col1:
        with st.container(border=True):
         st.metric(label="Delayed Orders", value=f"{late_orders_percentage:.0f}%")
with col2:
    with st.container(border=True):
        st.metric(label="Delayed Region", value=max_late_region)
with col3:
    with st.container(border=True):
        st.metric(label="Returned Products", value=f"{returned/1e3:.0f}K")
with col4:
    with st.container(border=True):
        st.metric(label="Refund Amount", value=f"{refund_amount/1e3:.0f}K $")

#charts
col1, col2 = st.columns(2, gap="medium")
with col1:
   with st.container(border=True):
    st.subheader("Delayed Orders by Region")
    late_by_region = (orders.groupby('Region')['Shipping_Status'].apply(lambda x: (x == 'late').sum()).reset_index(name='Late Orders').sort_values( by='Late Orders', ascending=False))
    fig_sales = px.bar(
        late_by_region,
        x='Region',
        y='Late Orders',
        color='Late Orders',
        text= 'Late Orders',
        color_continuous_scale=color2,
        labels={'Region': 'Regions', 'Late Orders': 'Late Orders' })
    fig_sales.update_layout(xaxis_tickangle=-90)
    fig_sales.update_layout(coloraxis_showscale=False)
    fig_sales.update_layout(height=420,font=dict(family="Arial, sans-serif",size=16))
    st.plotly_chart(fig_sales, use_container_width=True)

with col2:
   with st.container(border=True):
    st.subheader("Top delayed products")
    delayed_products = (orders_products.groupby('Product_Name')['Shipping_Status'].apply(lambda x: (x == 'late').sum()).reset_index(name='Late Orders').sort_values( by='Late Orders', ascending=False))
    fig_pro = px.bar(
        delayed_products.head(5),
        y='Product_Name',
        x='Late Orders',
        orientation='h',
        color='Late Orders',
        text= 'Late Orders',
        color_continuous_scale=color2,
        labels={'Product_Name': 'Products', 'Late Orders': 'Late Orders' })
    fig_pro.update_layout(xaxis_tickangle=-90)
    fig_pro.update_layout(coloraxis_showscale=False)
    fig_pro.update_layout(height=420,font=dict(family="Arial, sans-serif",size=16))
    st.plotly_chart(fig_pro, use_container_width=True)



with st.container(border=True):
    returned_products = returns_products.groupby(
    ['Category', 'Product_Name'])['Return_ID'].count().reset_index()
    fig_return = px.treemap(
        returned_products,
        path=['Category', 'Product_Name'],
        values='Return_ID',
        color='Return_ID',
        color_continuous_scale=color2,
        title='Returned Products by Category',
        labels={'Return_ID': 'Number of Returns', 'Product_Name': 'Product Name', 'Category': 'Category'}
        )
    fig_return.update_traces(
        hovertemplate="""""
        <b>Product Name:</b> %{label}<br>
        <b>Category:</b> %{parent}<br>
        <b>Returns:</b> %{value}<extra></extra>
        """
    )
    fig_return.update_layout(margin=dict(t=50, l=25, r=25, b=25), height=500,plot_bgcolor="rgba(0,0,0,0)",
    paper_bgcolor="rgba(0,0,0,0)", coloraxis_showscale=False,font=dict(family="Arial, sans-serif",size=16))
    st.plotly_chart(fig_return, use_container_width=True)



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

