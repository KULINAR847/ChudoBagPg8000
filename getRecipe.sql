CREATE OR REPLACE FUNCTION dzm."emias_getRecipe" (
  _qr text,
  _check_id integer [],
  out number text,
  out type text,
  out discount integer,
  out exp_date text,
  out req_guid text,
  out patient text,
  out birthday text,
  out doctor text,
  out "position" text,
  out organization text,
  out phone text,
  out good text,
  out form text,
  out dosage text,
  out numero integer,
  out qty integer,
  out signa text
)
RETURNS SETOF record AS
$body$
"""
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
"""

import ssl
import os

import urllib
from urllib import request
import json
import xml.etree.ElementTree as et

def get_first_child(node):
	index = 0
	if type(et.Element('a')) == type(node) and index >= 0 and len(node) > index:		
		return node[index]
	return 0

def get_node_by_name(root, name='', is_text=False):	
	if root:
		for node in root:
			if type(et.Element('a')) == type(node) and name != '' and node.tag[node.tag.find('}'):] == '}' + name:
				if is_text:
					return node.text
				else:
					return node
	return 0


# Основные константы
ident = ''
pos_ident = ''
token = ''

qry = plpy.execute("""SELECT 
                    	e.ident, 
                      e.pos_ident,
                      e.token,
                      e.connection_string 
                    FROM 
                    	dzm.emias_er e                     
                   """, 1)
 
# глобальные переменные
_url = qry[0]["connection_string"]                  
ident = qry[0]["ident"]
pos_ident = qry[0]["pos_ident"]
token = qry[0]["token"]


"""
	Основной код метода (модуля)
"""
# возвращаемые значения
code = -1
dsc = None
bns = 0
state = None
minpoints = 0
maxpoints = 0
cheque = None
oper = None


headers = {
	'Host' : 'club'.encode('utf-8'),
	'Accept' : 'application/json'.encode('utf-8'), 
	'Content-Type' : 'application/json'.encode('utf-8'),
	'Authorization' : str('F ' + token).encode('utf-8'),
}
# Тело запроса (XML) для метода
post_data = {
	"query": "getRecipe",
	"ident": ident,
	"POSIdent": pos_ident,
	"QRCode": _qr,
	"getSignature": "false"
}
  
# Пошли работать вызов метода и обработку ответа
try:
    post_str = json.dumps(post_data).encode('utf-8')

    response = request.Request( _url, headers=headers, data=post_str )
    _result = request.urlopen(response)

    # анализ ответа
    _text = _result.read().decode('utf-8')
    code = _result.code
    dsc = 'OK'
    
    root = et.fromstring(_text)
    body = get_first_child(root)
    recipe = get_first_child(body)
    trn_id = get_node_by_name(recipe, 'requestGUID', True)
    plpy.execute("""INSERT INTO 
					  dzm.emias_er_log
					(
					  trn_id,
					  method,
					  request,
					  response,
					  response_code,
					  response_dsc,
					  id_cash_str,
                      qr_code 
					)
					VALUES (
					  '%s',
					  'getRecipe',
					  '%s',
					  '%s',
					  %s,
					  '%s',
					  '%s',
                      '%s'
					  
					)""" % (trn_id, post_str.decode('utf-8'), et.tostring(root, 'utf-8', method="xml").decode('utf-8'), 
							code, dsc, '{0,0}', _qr) )

    sales = []
    for child in recipe:
        if child.tag[child.tag.find('}'):] == '}sale':
            sales.append(child)

    expDate = get_node_by_name(recipe, 'expirationDate', True)

    patientInfo = get_node_by_name(recipe, name='patientInfo')
    patientBirthday = get_node_by_name(patientInfo, 'birthDate', True)
    patientName =  get_node_by_name(patientInfo, 'fullName', True)

    medicineInfo = get_node_by_name(recipe, name='medicineInfo')
    INNName = get_node_by_name(medicineInfo, 'INNName', True)
    formName = get_node_by_name(medicineInfo, 'formName', True)

    qty = get_node_by_name(recipe, name='qty')
    dosage = get_node_by_name(qty, 'dosage', True)
    numero = get_node_by_name(qty, 'numero', True)

    signa = get_node_by_name(recipe, 'signa', True)

    registrationData = get_node_by_name(recipe, name='registrationData')
    doctorName = get_node_by_name(registrationData, 'doctorName', True)
    doctorPosition =  get_node_by_name(registrationData, 'doctorPosition', True)
    organizationName =  get_node_by_name(registrationData, 'organizationName', True)
    organizationPhone =  get_node_by_name(registrationData, 'organizationPhone', True)

    prescriptionNumber = get_node_by_name(recipe, 'prescriptionNumber', True)
    prescriptionType = get_node_by_name(recipe, 'prescriptionType', True)
    if prescriptionType == 'commercial':
        prescriptionType = 'без льгот'
    if prescriptionType == 'benefit':
        prescriptionType = 'льготный'

    req_guid = get_node_by_name(recipe, 'requestGUID', True)
    resp_guid = get_node_by_name(recipe, 'responseGUID', True)

    benefit = get_node_by_name(recipe, name='benefit')
    benefitDiscount = get_node_by_name(benefit, 'benefitDiscount', True)

    main_list = [prescriptionNumber, prescriptionType, benefitDiscount, expDate, req_guid, patientName, patientBirthday, doctorName, doctorPosition, organizationName, organizationPhone ]

    results = [main_list + [INNName, formName, dosage, numero, 0, signa]]

    for sale in sales:
        title = get_node_by_name(sale, name='title').text
        qtyPrim = get_node_by_name(sale, name='qtyPrim').text
        qtySec = get_node_by_name(sale, name='qtySec').text
        results.append( main_list + [ title, '', '', qtyPrim, qtySec, ''] )
    return results
    
except urllib.error.HTTPError as e1:
    plpy.execute("SELECT audit.errwrite('dzm.emias_getRecipe', _dis.errid(3,1), ARRAY['%s','%s','%s'])" % (e1.code, e1.reason.replace("\\\\","\\").replace("'","\""), e1.read().decode('utf-8').replace("\\\\","\\").replace("'","\"")))
    return e1.reason
    
except Exception as e2:
    # Далее 2 абсолютно одинаковые строки
    #plpy.execute("SELECT audit.errwrite('dzm.emias_getRecipe', _dis.errid(3,0), ARRAY['%s'])" % ( str(e2).replace("\\\\","\\").replace("'","\"") ))
    plpy.execute("SELECT audit.errwrite('dzm.emias_getRecipe', _dis.errid(3,0), ARRAY['%s'])" % ( str(e2).replace("\\\\","\\").replace("'","\"") ))
    return str(e2)
    
$body$
LANGUAGE 'plpython3u'
VOLATILE
CALLED ON NULL INPUT
SECURITY DEFINER
COST 100 ROWS 1000;

ALTER FUNCTION dzm."emias_getRecipe" (_qr text, _check_id integer [], out number text, out type text, out discount integer, out exp_date text, out req_guid text, out patient text, out birthday text, out doctor text, out "position" text, out organization text, out phone text, out good text, out form text, out dosage text, out numero integer, out qty integer, out signa text)
  OWNER TO postgres;