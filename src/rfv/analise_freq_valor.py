import pandas as pd
import sqlalchemy
import matplotlib.pyplot as plt
import seaborn as sns

from sklearn import cluster, preprocessing, tree

def rf_cluster(row):
    if row['valorPoints'] < 500:
        if row['frequenciaDias'] < 3.5:
            return '01-BB'
        elif row['frequenciaDias'] < 7.5:
            return '02-MB'
        elif row['frequenciaDias'] < 10.5:
            return '03-AB'
        else:
            return '04-SB'
        
    elif row['valorPoints'] < 1600:
        if row['frequenciaDias'] < 3.5:
            return '05-BM'
        elif row['frequenciaDias'] < 7.5:
            return '06-MM'
        elif row['frequenciaDias'] < 10.5:
            return '07-AM'
        else:
            return '08-SM'
    
    else:
        if row['frequenciaDias'] < 3.5:
            return '09-BA'
        elif row['frequenciaDias'] < 7.5:
            return '10-MA'
        elif row['frequenciaDias'] < 10.5:
            return '11-AA'
        else:
            return '12-SA'
#%%
engine = sqlalchemy.create_engine("sqlite:///../../data/feature_store.db")
query = '''
SELECT *
FROM fs_general
WHERE dtRef = (SELECT MAX(dtRef) FROM fs_general)
'''

df = pd.read_sql(sql=query, con=engine)

minmax = preprocessing.MinMaxScaler()
X_trans = minmax.fit_transform(df[['valorPoints', 'frequenciaDias']])

# cluster_model = cluster.KMeans(n_clusters=5)

cluster_model = cluster.AgglomerativeClustering(n_clusters=5,
                                                linkage='ward')
cluster_model.fit(X_trans)

df['cluster'] = cluster_model.labels_


plt.figure(dpi=400)
sns.set_theme(style='darkgrid')
sns.scatterplot(data=df,
                x='valorPoints',
                y='frequenciaDias',
                hue='cluster',
                palette='husl')
plt.title('Frequência vs Valor')


df['cluster'].value_counts()


df['cluster_rf'] = df.apply(rf_cluster, axis=1)
    
plt.figure(dpi=400)
sns.set_theme(style='darkgrid')
sns.scatterplot(data=df,
                x='valorPoints',
                y='frequenciaDias',
                hue='cluster_rf',
                palette='husl')
plt.title('Cluster Frequência vs Valor')

df['cluster_rf'].value_counts()


clf = tree.DecisionTreeClassifier(
    random_state=42,
    min_samples_leaf=1,
    max_depth=None
)
clf.fit(df[['frequenciaDias', 'valorPoints']], df['cluster_rf'])

model_freq_valor = pd.Series({
    'model': clf,
    'features': ['frequenciaDias', 'valorPoints']
})

model_freq_valor.to_pickle('../../models/cluster_fv.pkl')

