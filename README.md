# ChudoBagPg8000
Unexpected behavior pg8000

If execute update_script.py all done success.

BUT...

Something interesting happens when you uncommented 19 string in update_script.py and comment 20. These lines are absolutely identical)

![image](https://user-images.githubusercontent.com/40752666/141421204-394d25a8-6736-46f8-a9bd-4f2c5a7b532b.png)

You get:

![image](https://user-images.githubusercontent.com/40752666/141421057-ade0b6aa-797e-4cb6-a29d-4b6359df2980.png)


{'S': 'ОШИБКА', 'C': 'XX000', 'M': 'не удалось скомпилировать функцию PL/Python "function"', 'D': 'SyntaxError: invalid syntax (<string>, line 11)', 'W': 'SQL-оператор: "CREATE OR REPLACE FUNCTION public.function (\n  out code integer\n)\nRETURNS integer AS\n$body$\ntry:\n    pass\n\nexcept urllib.error.HTTPError as e1:\n    plpy.execute("SELECT public.errwrite(\'getRecipe\', 12, ARRAY[\'%s\',\'%s\',\'%s\'])" % (e1.code, e1.reason.replace("\\\\\\\\","\\\\").replace("\'","\\""), e1.read().decode(\'utf-8\').replace("\\\\\\\\","\\\\").replace("\'","\\"")))\n    return [123, e1.reason]\n    \nexcept Exception as e2:\n    plpy.execute("SELECT public.errwrite(\'getRecipe\', 13, ARRAY[\'$1\'])" %% str(e2).replace("\\\\\\\\","\\\\").replace("\'","\\""))\n    #plpy.execute("SELECT public.errwrite(\'getRecipe\', 13, ARRAY[\'%s\'])" % str(e2).replace("\\\\\\\\","\\\\").replace("\'","\\""))\n    return [1232, str(e2)]\n$body$\nLANGUAGE \'plpython3u\'\nVOLATILE\nCALLED ON NULL INPUT\nSECURITY INVOKER\nCOST 100"\nфункция PL/pgSQL inline_code_block, строка 2, оператор SQL-оператор', 'F': 'src\\pl\\plpython\\plpy_elog.c', 'L': '106', 'R': 'PLy_elog'}
