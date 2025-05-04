#%%
import mlflow
import mlflow.sklearn
import pandas as pd
import sqlalchemy
from sqlalchemy.exc import OperationalError


#%%
print("Scrip para execução de modelos iniciado!")
print('Carregando modelo...')
model_name = 'models:/churn-tmw/production'
mlflow.set_tracking_uri('http://127.0.0.1:8080/')
model = mlflow.sklearn.load_model(model_name)
features = model.feature_names_in_
#%%
print('Carregando base para score...')
engine = sqlalchemy.create_engine('sqlite:///../../data/feature_store.db')

with open('etl.sql') as open_file:
    query = open_file.read()

df = pd.read_sql(sql=query, con=engine)
df.head()
#%%
print('Realizando predições...')
preds = model.predict_proba(df[features])
churn_proba = preds[:,1]

print('Persistindo dados...')
df_predict = pd.DataFrame(
    {'dtRef': df['dtRef'],
     'idCustomer': df['idCustomer'],
     'churnProba': churn_proba})

df_predict = df_predict.sort_values('churnProba', ascending=False).reset_index(drop=True)

#%%
with engine.connect() as con:
    state = f"DELETE FROM tb_churn WHERE dtRef = {df['dtRef'].min()}"
    try:
        state = sqlalchemy.text(state)
        con.execute(state)
        con.commit()
    except OperationalError as err:
        print('Tabela ainda não existe...')
        

df_predict.to_sql('tb_churn', con=engine, if_exists='append', index=False)

print('Fim.')