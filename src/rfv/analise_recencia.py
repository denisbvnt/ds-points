import pandas as pd
import sqlalchemy
import matplotlib.pyplot as plt
from sklearn import tree

def ciclo_vida(row):
    if row['idadeBaseDias'] <= 7:
        return '01-Nova'
    elif row['recenciaDias'] <= 2:
        return '02-Super Ativa'
    elif row['recenciaDias'] <= 6:
        return '03-Ativa Comum'
    elif row['recenciaDias'] <= 12:
        return '04-Ativa Fria'
    elif row['recenciaDias'] <= 18:
        return '05-Desiludida'
    else:
        return '06-Pre Churn'

# if __name__ == '__main__':
engine = sqlalchemy.create_engine("sqlite:///../../data/feature_store.db")
query = '''
SELECT *
FROM fs_general
WHERE dtRef = (SELECT MAX(dtRef) FROM fs_general)
'''

df = pd.read_sql(sql=query, con=engine)
df_recencia = df[['recenciaDias', 'idadeBaseDias']].sort_values('recenciaDias')
df_recencia['unit'] = 1
df_recencia['Acum'] = df_recencia['unit'].cumsum()
df_recencia['pctAcum'] = df_recencia['Acum'] / df_recencia['Acum'].max()

plt.plot(df_recencia['recenciaDias'], df_recencia['pctAcum'])
plt.grid(True)
plt.title('Dist. Recência Acumulada')
plt.xlabel('Recência')
plt.ylabel('Pct Acum')
df_recencia['cicloVida'] = df_recencia.apply(ciclo_vida, axis=1)
df_recencia.groupby('cicloVida').agg({'recenciaDias': ['mean', 'count'],
                                    'idadeBaseDias': ['mean']})

#%%
clf = tree.DecisionTreeClassifier(
    random_state=42,
    min_samples_leaf=1,
    max_depth=None
)

clf.fit(df_recencia[['recenciaDias', 'idadeBaseDias']], df_recencia['cicloVida'])
clf
# %%
model = pd.Series({
    'model': clf,
    'features': ['recenciaDias', 'idadeBaseDias']
})

model.to_pickle('../../models/cluster_recencia.pkl')