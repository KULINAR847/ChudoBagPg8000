import os
import pg8000

ddl = r'''
DO $$ BEGIN
CREATE OR REPLACE FUNCTION public.function (
  out code integer
)
RETURNS integer AS
$body$
plpy.execute("SELECT public.errwrite('getRecipe', 13, ARRAY['%s'])" % str(e2).replace("\\\\","\\").replace("'","\""))
#plpy.execute("SELECT public.errwrite('getRecipe', 13, ARRAY['%s'])" % str(e2).replace("\\\\","\\").replace("'","\""))
return 0
$body$
LANGUAGE 'plpython3u'
VOLATILE
CALLED ON NULL INPUT
SECURITY INVOKER
COST 100;

ALTER FUNCTION public.function (out code integer)
  OWNER TO postgres;
END$$;
'''

if __name__ == '__main__':
    try:
        ddl = ddl.replace(' % ', ' %% ')

        conn = pg8000.connect(user='postgres', password='pass', database='test_db', host='localhost', port=5432, timeout=0.500)
        cursor = conn.cursor()
        cursor.execute(ddl)

        conn.commit()
        cursor.close()
        conn.close()

    except Exception as e:
        print(e)
        input()
