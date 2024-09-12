# Housing project python

import pandas as pd

df = pd.read_csv("C:/Users/Robert Kuyer/Data analytics/Portfolio/Nashville housing project/data/Nashville_Housing.csv")
df

# Check missings
df.isna().sum()
df = df.dropna()

# Check types
df.dtypes

# Clean the sale price column
df_filtered = df[df['sale_price'].str.contains(r'[^0-9]', regex= True)]
df['sale_price'] = df['sale_price'].str.replace(r'[,\$]', '', regex=True)
df['sale_price']

# Change types
df['sale_date'] = pd.to_datetime(df['sale_date'])
df= df.astype({'sale_price' : 'int', 'landuse' : 'category'})

# Clean and split property address and city
df[['property_address', 'property_city']] = df['property_address'].str.split(',', expand= True)
df[['owner_address', 'owner_city', 'owner_state']] = df['owner_address'].str.split(',', expand=True)
df[['owner_address', 'owner_city', \
    'property_address', 'property_city', \
        'landuse', 'owner_name']] = df[['owner_address', 'owner_city',\
                                        'property_address', 'property_city',\
                                            'landuse', 'owner_name']].apply(lambda x: x.str.title())

# Clean sold vacant
df['sold_vacant'].unique()
mapping = {'Y': True, 'Yes': True , 'No' :False, 'N' : False}
df['sold_vacant'] = df['sold_vacant'].replace(mapping)


# Check duplicates
column_names = ['parcelid', 'landuse', 'property_address','sale_date','sale_price', 'legal_reference']
duplicates = df.duplicated(subset= column_names)
df = df[~duplicates]
df = df.reset_index(drop=True)
df.head(100) 

df.to_csv('C:/Users/Robert Kuyer/Data analytics/Portfolio/Nashville housing project/data/Cleaned_nashville_Housing.csv', index=False)