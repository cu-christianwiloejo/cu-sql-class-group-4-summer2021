#!/usr/bin/env python
# coding: utf-8

# In[1]:


import numpy as np
import pandas as pd
from sqlalchemy import create_engine
import matplotlib.pyplot as plt


# In[2]:


hostname = 'group4.cplpzlen7ufk.us-east-2.rds.amazonaws.com'
username = 'pgsql4'
password = # HIDDEN #
database = 'group4'
conn_url = 'postgresql://' + username + ':' + password + '@' + hostname + '/' + database
engine = create_engine(conn_url)
conn = engine.connect()


# # IMPORT ALL OF THE DATA TO PANDAS AND LOAD TO SQL

# ## Payments

# In[15]:


payments = pd.read_excel('./AMAZON REPORTS COMBINED.xlsx', sheet_name='Payments')
payments.to_sql('payments', engine, if_exists = 'append', index = False)


# ## Customers

# In[16]:


customers = pd.read_excel('./AMAZON REPORTS COMBINED.xlsx', sheet_name='Customers')
customers.to_sql('customers', engine, if_exists = 'append', index = False)


# ## CustomersPayments

# In[18]:


customers_payments = pd.read_excel('./AMAZON REPORTS COMBINED.xlsx', sheet_name='CustomersPayments')
customers_payments.to_sql('customerspayments', engine, if_exists = 'append', index = False)


# ## Addresses

# In[19]:


addresses = pd.read_excel('./AMAZON REPORTS COMBINED.xlsx', sheet_name='Addresses')
addresses.to_sql('addresses', engine, if_exists = 'append', index = False)


# ## CustomersAddresses

# In[20]:


customers_addresses = pd.read_excel('./AMAZON REPORTS COMBINED.xlsx', sheet_name='CustomersAddresses')
customers_addresses.to_sql('customeraddresses', engine, if_exists = 'append', index = False)


# ## Orders

# In[22]:


orders = pd.read_excel('./AMAZON REPORTS COMBINED.xlsx', sheet_name='Orders')
orders.to_sql('orders', engine, if_exists = 'append', index = False)


# ## CustomersOrders

# In[23]:


customers_orders = pd.read_excel('./AMAZON REPORTS COMBINED.xlsx', sheet_name='CustomersOrders')
customers_orders.to_sql('customersorders', engine, if_exists = 'append', index = False)


# ## Products

# In[27]:


products = pd.read_excel('./AMAZON REPORTS COMBINED.xlsx', sheet_name='Products')
products.to_sql('products', engine, if_exists = 'append', index = False)


# ## OrdersProducts

# In[28]:


orders_products = pd.read_excel('./AMAZON REPORTS COMBINED.xlsx', sheet_name='OrdersProducts')
orders_products.to_sql('ordersproducts', engine, if_exists = 'append', index = False)


# ## Categories

# In[29]:


categories = pd.read_excel('./AMAZON REPORTS COMBINED.xlsx', sheet_name='Categories')
categories.to_sql('categories', engine, if_exists = 'append', index = False)


# ## ProductsCategories

# In[30]:


products_categories = pd.read_excel('./AMAZON REPORTS COMBINED.xlsx', sheet_name='ProductsCategories')
products_categories.to_sql('productscategories', engine, if_exists = 'append', index = False)


# ## Sellers

# In[31]:


sellers = pd.read_excel('./AMAZON REPORTS COMBINED.xlsx', sheet_name='Sellers')
sellers.to_sql('sellers', engine, if_exists = 'append', index = False)


# ## ProductsSellers

# In[33]:


products_sellers = pd.read_excel('./AMAZON REPORTS COMBINED.xlsx', sheet_name='ProductsSellers')
products_sellers.to_sql('productssellers', engine, if_exists = 'append', index = False)


# ## ProductsSellers

# In[4]:


products_price = pd.read_excel('./AMAZON REPORTS COMBINED.xlsx', sheet_name='ProductsPrice')
products_price.to_sql('productsprice', engine, if_exists = 'append', index = False)


# In[ ]:




