#%%
import sqlalchemy
import pandas as pd

def import_query(path):
    with open('fs_general.sql', 'r') as open_file:
        return open_file.read()
# %%
origin_engine = sqlalchemy.create_engine('sqlite:///../../data/datanase.db')
target_engine = sqlalchemy.create_engine('sqlite:///../../data/feature_store.db')
# %%

# Import da query
query = import_query('fs_general.sql')

# Substituição de '{date}' por uma data
query_fmt = query.format(date='2024-06-06')
# %%
df = pd.read_sql(sql=query_fmt, con=origin_engine)
df.head()
# %%
