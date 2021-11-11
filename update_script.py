import os
import pg8000

def try_update(u, p, db, h, pt, sql):    
    try:
        conn = pg8000.connect(user=u, password=p, database=db, host=h, port=int(pt), timeout=0.500)
        cursor = conn.cursor()
        cursor.execute(sql)

        conn.commit()
        cursor.close()
        conn.close()

    except Exception as e:
        print(h + ' EXCEPTION')
        print(e)
        c = input()

def read_file(filename, enc='windows-1251'):
    if os.path.exists(filename):
        with open(filename, 'r', encoding=enc) as f:
            return f.read()
    return ''

if __name__ == '__main__':
    ### if plpython3u extension not exist
    #sql = 'CREATE EXTENSION plpython3u'
    #try_update('postgres', 'pass', 'test_db', 'localhost', 5432, sql)

    ### The first file creates a function that is called in the second to avoid other errors
    files = ['public_errwrite.sql', 'public_function.sql']
    for f in files:
        ddl = read_file(f, 'utf-8').replace(' % ', ' %% ') 
        prepared_ddl = f'DO $$ BEGIN \n {ddl} \n END$$;'
        try_update('postgres', 'pass', 'test_db', 'localhost', 5432, prepared_ddl)