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

returns['Return_Date'] = pd.to_datetime(returns['Return_Date'])
returns['Discount_%'] = pd.to_numeric(returns['Discount_%'], errors='coerce')
returns['Refund_Amount'] = pd.to_numeric(returns['Refund_Amount'], errors='coerce')
#sales
sales['Sale_Date'] = pd.to_datetime(sales['Sale_Date'])



#calculations

#calculating orders by month
orders['Month'] = orders['Order_Date'].dt.month
orders ['month_name'] = orders['Order_Date'].dt.strftime('%B')
monthly_orders = orders.groupby(['Month', 'month_name'])['Order_ID'].count().reset_index()
monthly_orders = monthly_orders.sort_values('Month')
monthly_orders.rename(columns={'Order_ID': 'Total_Orders'}, inplace=True)



#calculating avg delivery time
orders['delivery_day'] = orders['Delivery_Date'].dt.day
orders['ship_day'] = orders['Ship_Date'].dt.day
orders['order_shipping'] = (orders['Ship_Date'] - orders['Order_Date']).dt.days
delivery_time = (orders['Delivery_Date'] - orders['Order_Date']).dt.days
average_delivery_time = delivery_time.mean().astype(int)
avg_order_delay = orders['order_shipping'].mean()




#stating order status
def calculate_order_delay (row):
    if row['order_shipping']< avg_order_delay:
        return 'early'
    elif row['order_shipping'] > avg_order_delay:
        return 'late'
    else:        return 'on time'
orders['Shipping_Status'] = orders.apply(calculate_order_delay, axis=1)




#avg cost per order
avg_rev_per_order = orders['Total_Revenue'].sum() / orders['Order_ID'].nunique()
avg_cost_per_order = orders['Total_Cost'].sum() / orders['Order_ID'].nunique()
# print (f'Average Cost per Order: {avg_cost_per_order:.2f} $')    

# Count orders by payment method
payment_orders = (
    orders['Payment_Method']
    .value_counts()
    .reset_index()
)

# Rename columns
payment_orders.columns = ['Payment_Method', 'Orders_Count']



#merging dataframes
product_sales= pd.merge(products, sales, on='SKU', how='left')
print (product_sales.columns)
orders_sales = pd.merge(orders, sales, on='Order_ID', how='left')
orders_products = pd.merge(orders, products, on='SKU', how='left')




#dashboard

colors=["#00cfc8","#ff9da7"]

# # dashboard grid
st.title("📊 Supply Chain Dashboard")
st.markdown("Orders performance")
st.divider()
col1, col2, col3 = st.columns(3)
with col1:
        with st.container(border=True):
         st.metric(label="Avg Revenue Per Order", value=f"{avg_rev_per_order:.1f}$")
with col2:
    with st.container(border=True):
        st.metric(label="Avg Cost Per Order", value=f"{avg_cost_per_order:.2f} $")
with col3:
    with st.container(border=True):
        st.metric(label="Avg Delivery Time", value=f"{average_delivery_time} days")

with st.container(border=True):
    st.subheader("Monthly Orders Trend")
    fig_monthly = px.line(
        orders.groupby(['Month', 'month_name'])['Order_ID'].count().reset_index(),
        x='month_name',
        y='Order_ID',
        markers=True,
        color_discrete_sequence= colors
    )
    fig_monthly.update_layout( 
        xaxis_title="",
        yaxis_title="Total Orders",
        height=400,
        margin=dict(l=20, r=20, t=30, b=20)
    )
    st.plotly_chart(fig_monthly, use_container_width=True)

col1, col2, col3 = st.columns(3, gap="medium")
with col1:
   with st.container(border=True):
        st.subheader('Orders By Payment Method')
        fig = px.bar(
           payment_orders,
           x='Payment_Method',
           y='Orders_Count',
           text='Orders_Count',
           color_discrete_sequence= colors
        )
        fig.update_layout(
            xaxis_title="Payment Method",
            yaxis_title="Number of Orders",
            height=400,
            margin=dict(l=20, r=20, t=30, b=20),
            font=dict(
               family="Arial, sans-serif", 
               size=16)  
        )
        st.plotly_chart(fig, use_container_width=True)

ord_by_reg= orders.groupby(['Region'])['Order_ID'].count().reset_index()
with col2:
    
    with st.container(border=True):
        st.subheader("Orders By Region")
        fig_regional = px.bar(
        ord_by_reg,   
        x='Order_ID',
        y='Region',
        text='Order_ID',
        orientation="h",
        color_discrete_sequence= colors
    )
        fig_regional.update_layout(
        xaxis_title="",
        yaxis_title="Total Orders",
        height=400,
        margin=dict(l=20, r=20, t=30, b=20),
          font=dict(
            family="Arial, sans-serif", 
             size=16)  
    )
        st.plotly_chart(fig_regional, use_container_width=True)

with col3:

    with st.container(border=True):
        st.subheader("Order Status Distribution")
        fig_status = px.pie(
            orders.groupby('Shipping_Status')['Order_ID'].count().reset_index(),
            names='Shipping_Status',
            values='Order_ID',
            color_discrete_sequence=colors
        )
        # fig_status.update_layout(height=320, margin=dict(t=0, b=0, l=0, r=0))
        fig_status.update_traces(textposition='inside', textinfo='percent+label', showlegend=False)
       
        fig_status.update_layout(
         margin=dict(l=0, r=0, t=30, b=0), 
         showlegend=False,                
         height=400, 
         font=dict(
           family="Arial, sans-serif", 
           size=16)                     
      )
        st.plotly_chart(fig_status, use_container_width=True)







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



