#%%
import os
import argparse
import sqlalchemy
import pandas as pd
import datetime
import sqlalchemy.exc
from tqdm import tqdm

def import_query(path):
    with open(path, 'r') as open_file:
        return open_file.read()
    
def ingest_date(query, table, date):
    # Substituição de '{date}' por uma data
    query_fmt = query.format(date=date)

    # Executa e traz o resultado para o Python
    df = pd.read_sql(sql=query_fmt, con=ORIGIN_ENGINE)

    # Deleta os dados com a data de referência para garantir a integridade
    with TARGET_ENGINE.connect() as con:
        try:
            state = f"DELETE FROM {table} WHERE dtRef = '{date}'"
            con.execute(sqlalchemy.text(state))
            con.commit()
        except sqlalchemy.exc.OperationalError as err:
            print('Tabela ainda não existe, criando agora...')

    # Enviando os dados para o novo database
    df.to_sql(table, TARGET_ENGINE, index=False, if_exists='append')
# %%
def main():
    today = datetime.date.today().strftime('%Y-%m-%d')

    parser = argparse.ArgumentParser()
    parser.add_argument("--feature_store", "-f", help='Nome da Feature Store', type=str)
    parser.add_argument("--start", "-s", help='Data de Início', default=today)
    parser.add_argument("--end", "-e", help='Data de Fim', default=today)
    args = parser.parse_args()

    # Import da query
    query = import_query(f'{args.feature_store}.sql')
    dates = [date.strftime('%Y-%m-%d')
            for date in pd.date_range(
                start=datetime.datetime.strptime(args.start, '%Y-%m-%d'),
                end=datetime.datetime.strptime(args.end, '%Y-%m-%d'), freq='1D')
            ]

    for i in tqdm(dates):
        ingest_date(query, args.feature_store, i)
#%%
if __name__ == '__main__':
    ORIGIN_ENGINE = sqlalchemy.create_engine('sqlite:///../../data/database.db')
    TARGET_ENGINE = sqlalchemy.create_engine('sqlite:///../../data/feature_store.db')
    main()
# %%

