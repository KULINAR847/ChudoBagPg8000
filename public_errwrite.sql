CREATE OR REPLACE FUNCTION public.errwrite (
  varchar,
  integer,
  varchar [] = NULL::character varying[]
)
RETURNS void AS
$body$
DECLARE
	_id_user		INTEGER[];
  _pcall			BIGINT;
BEGIN	
END;
$body$
LANGUAGE 'plpgsql'
VOLATILE
CALLED ON NULL INPUT
SECURITY DEFINER
COST 100;

ALTER FUNCTION public.errwrite (varchar, integer, varchar [])
  OWNER TO postgres;