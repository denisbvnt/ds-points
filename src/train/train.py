# %%
import datetime
import pandas as pd
import sqlalchemy
from sklearn.model_selection import train_test_split, GridSearchCV
from sklearn import ensemble, pipeline, metrics
from feature_engine import encoding

# %%
def report_metrics(y_true, y_proba):
    y_pred = y_proba.argmax(axis=1)
    acc = metrics.accuracy_score(y_true, y_pred)
    prec = metrics.precision_score(y_true, y_pred)
    rec = metrics.recall_score(y_true, y_pred)
    f1 = metrics.f1_score(y_true, y_pred)
    auc = metrics.roc_auc_score(y_true, y_proba[:,1])
    return {
        'Accuracy': acc,
        'AUC': auc,
        'Precision': prec,
        'Recall': rec,
        'F1 Score': f1
    }

#%%
engine = sqlalchemy.create_engine("sqlite:///../../data/feature_store.db")

with open('abt.sql', 'r') as open_file:
    query = open_file.read()

# Processa e traz os dados
df = pd.read_sql(sql=query, con=engine)

string_columns = ['dtRef', 'idCustomer', 'maisComprado', 'menosComprado']
df[df.drop(string_columns, axis=1).columns] = df[df.drop(string_columns, axis=1).columns].apply(pd.to_numeric)
df.head()
# %%
# Separação de dados entre treino e OOT

df_oot = df[df['dtRef'] == df['dtRef'].max()]
df_train = df[df['dtRef'] < df['dtRef'].max()]
# %%

target = 'flChurn'
features = df_train.drop(target, axis=1).columns[2:].to_list()
# %%
X_train, X_test, y_train, y_test = train_test_split(df_train[features],
                                                    df_train[target],
                                                    random_state=42,
                                                    test_size=0.2,
                                                    stratify=df_train[target])

# %%
print(f'Taxa de resposta na base de treino: {y_train.mean()}')
print(f'Taxa de resposta na base de test: {y_test.mean()}')

# %%
cat_features = X_train.dtypes[X_train.dtypes == 'object'].index.tolist()
num_features = list(set(features) - set(cat_features))
# %%
X_train[cat_features].describe()
# %%
X_train[num_features].describe().T
# %%
X_train[num_features].isna().sum().sum()

# %%
onehot = encoding.OneHotEncoder(variables=cat_features,
                                drop_last=True)

model = ensemble.RandomForestClassifier(random_state=42,
                                        min_samples_leaf=25)

params = {'min_samples_leaf': [10, 25, 50, 75, 100],
          'n_estimators': [100, 200, 500, 1000],
          'criterion': ['gini', 'entropy'],
          'max_depth': [5, 8, 10, 12, 15]}

grid = GridSearchCV(model,
                    param_grid=params,
                    cv=3,
                    scoring='roc_auc',
                    n_jobs=-2)

model_pipeline = pipeline.Pipeline([
    ('One Hot Encoder', onehot),
    ('Modelo', grid)
])

# %%
model_pipeline.fit(X_train, y_train)

# %%
y_train_proba = model_pipeline.predict_proba(X_train)
y_test_proba = model_pipeline.predict_proba(X_test)
y_oot_proba = model_pipeline.predict_proba(df_oot[features])

report_train = report_metrics(y_train, y_train_proba)
report_train['base'] = 'train'
report_test = report_metrics(y_test, y_test_proba)
report_test['base'] = 'test'
report_oot = report_metrics(df_oot[target], y_oot_proba)
report_oot['base'] = 'oot'

# %%
df_metrics = pd.DataFrame([report_train, report_test, report_oot])
df_metrics
# %%
model_seriees = pd.Series({
    'model': model_pipeline,
    'features': features,
    'metrics': df_metrics,
    'dt_train': datetime.datetime.now()
})

model_seriees.to_pickle('../../models/rf_model.pkl')