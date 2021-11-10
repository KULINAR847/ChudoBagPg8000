import os
import pg8000

def try_update(u, p, db, h, pt, text, sql, params=[]):    
    try:
        conn = pg8000.connect(user=u, password=p, database=db, host=h, port=int(pt), timeout=0.500)
        cursor = conn.cursor()
        
        if len(params) > 0:            
            cursor.execute(sql, params)
        else:           
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

def update_ip(e, params):
    data = read_file('getRecipe.sql', 'utf-8').replace(' % ', ' %% ')
    get_receipt_sql = f'DO $$ BEGIN \n {data} \n END$$;'   
    try_update('postgres', 'pass', '193', e[0], 5433, e[1], get_receipt_sql)

if __name__ == '__main__':
    update_ip(['172.20.251.116', ''], [r'https://', 
                                       r'Test15', 
                                       r'Test15_Pos_1', 
                                       r'token'])