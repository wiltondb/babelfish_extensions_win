-- complain if script is sourced in psql, rather than via ALTER EXTENSION
\echo Use "ALTER EXTENSION ""babelfishpg_common"" UPDATE TO '1.1.0'" to load this file. \quit

-- Drops an operator class if it does not have any dependent objects.
-- We will drop redundant operator classes since sys.fixeddecimal_ops operator family will now contain
-- all the operators.
-- It is a temporary procedure for use by the upgrade script. Will be dropped at the end of the upgrade.
-- Please have this be one of the first statements executed in this upgrade script. 
CREATE OR REPLACE PROCEDURE babelfish_drop_deprecated_opclass(schema_name varchar, opcname varchar) AS
$$
DECLARE
    error_msg text;
    query1 text;
    query2 text;
BEGIN
    query1 := format('drop operator class if exists %s.%s using btree', schema_name, opcname);
    query2 := format('drop operator class if exists %s.%s using hash', schema_name, opcname);
    execute query1;
    execute query2;
EXCEPTION
    when dependent_objects_still_exist then --if 'drop operator class' statement fails
        GET STACKED DIAGNOSTICS error_msg = MESSAGE_TEXT;
        raise warning '%', error_msg;
end
$$
LANGUAGE plpgsql;

-- drop fixeddecimal_numeric_ops and add corresponding operators to operator family fixeddecimal_ops
CALL babelfish_drop_deprecated_opclass('sys', 'fixeddecimal_numeric_ops');

ALTER OPERATOR FAMILY sys.fixeddecimal_ops USING btree ADD
    OPERATOR    1   sys.<  (sys.FIXEDDECIMAL, NUMERIC),
    OPERATOR    2   sys.<= (sys.FIXEDDECIMAL, NUMERIC),
    OPERATOR    3   sys.=  (sys.FIXEDDECIMAL, NUMERIC),
    OPERATOR    4   sys.>= (sys.FIXEDDECIMAL, NUMERIC),
    OPERATOR    5   sys.>  (sys.FIXEDDECIMAL, NUMERIC),
    FUNCTION    1   sys.fixeddecimal_numeric_cmp(sys.FIXEDDECIMAL, NUMERIC);

ALTER OPERATOR FAMILY sys.fixeddecimal_ops USING hash ADD
    OPERATOR    1   sys.=  (sys.FIXEDDECIMAL, NUMERIC);


-- drop numeric_fixeddecimal_ops and add corresponding operators to operator family fixeddecimal_ops
CALL babelfish_drop_deprecated_opclass('sys', 'numeric_fixeddecimal_ops');

ALTER OPERATOR FAMILY sys.fixeddecimal_ops USING btree ADD
    OPERATOR    1   sys.<  (NUMERIC, sys.FIXEDDECIMAL) FOR SEARCH,
    OPERATOR    2   sys.<= (NUMERIC, sys.FIXEDDECIMAL) FOR SEARCH,
    OPERATOR    3   sys.=  (NUMERIC, sys.FIXEDDECIMAL) FOR SEARCH,
    OPERATOR    4   sys.>= (NUMERIC, sys.FIXEDDECIMAL) FOR SEARCH,
    OPERATOR    5   sys.>  (NUMERIC, sys.FIXEDDECIMAL) FOR SEARCH,
    FUNCTION    1   sys.numeric_fixeddecimal_cmp(NUMERIC, sys.FIXEDDECIMAL);

ALTER OPERATOR FAMILY sys.fixeddecimal_ops USING hash ADD
    OPERATOR    1   sys.=  (NUMERIC, sys.FIXEDDECIMAL);


-- drop fixeddecimal_int8_ops and add corresponding operators to operator family fixeddecimal_ops
CALL babelfish_drop_deprecated_opclass('sys', 'fixeddecimal_int8_ops');

ALTER OPERATOR FAMILY sys.fixeddecimal_ops USING btree ADD
    OPERATOR    1   sys.<  (sys.FIXEDDECIMAL, INT8),
    OPERATOR    2   sys.<= (sys.FIXEDDECIMAL, INT8),
    OPERATOR    3   sys.=  (sys.FIXEDDECIMAL, INT8),
    OPERATOR    4   sys.>= (sys.FIXEDDECIMAL, INT8),
    OPERATOR    5   sys.>  (sys.FIXEDDECIMAL, INT8),
    FUNCTION    1   sys.fixeddecimal_int8_cmp(sys.FIXEDDECIMAL, INT8);

ALTER OPERATOR FAMILY sys.fixeddecimal_ops USING hash ADD
   OPERATOR    1   sys.=  (sys.FIXEDDECIMAL, INT8);


-- drop int8_fixeddecimal_ops and add corresponding operators to operator family fixeddecimal_ops
CALL babelfish_drop_deprecated_opclass('sys', 'int8_fixeddecimal_ops');

ALTER OPERATOR FAMILY sys.fixeddecimal_ops USING btree ADD
    OPERATOR    1   sys.<  (INT8, sys.FIXEDDECIMAL),
    OPERATOR    2   sys.<= (INT8, sys.FIXEDDECIMAL),
    OPERATOR    3   sys.=  (INT8, sys.FIXEDDECIMAL),
    OPERATOR    4   sys.>= (INT8, sys.FIXEDDECIMAL),
    OPERATOR    5   sys.>  (INT8, sys.FIXEDDECIMAL),
    FUNCTION    1   sys.int8_fixeddecimal_cmp(INT8, sys.FIXEDDECIMAL);

ALTER OPERATOR FAMILY sys.fixeddecimal_ops USING hash ADD
   OPERATOR    1   sys.=  (INT8, sys.FIXEDDECIMAL);


-- drop fixeddecimal_int4_ops and add corresponding operators to operator family fixeddecimal_ops
CALL babelfish_drop_deprecated_opclass('sys', 'fixeddecimal_int4_ops');

ALTER OPERATOR FAMILY sys.fixeddecimal_ops USING btree ADD
    OPERATOR    1   sys.<  (sys.FIXEDDECIMAL, INT4),
    OPERATOR    2   sys.<= (sys.FIXEDDECIMAL, INT4),
    OPERATOR    3   sys.=  (sys.FIXEDDECIMAL, INT4),
    OPERATOR    4   sys.>= (sys.FIXEDDECIMAL, INT4),
    OPERATOR    5   sys.>  (sys.FIXEDDECIMAL, INT4),
    FUNCTION    1   sys.fixeddecimal_int4_cmp(sys.FIXEDDECIMAL, INT4);

ALTER OPERATOR FAMILY sys.fixeddecimal_ops USING hash ADD
   OPERATOR    1   sys.=  (sys.FIXEDDECIMAL, INT4);


-- drop int4_fixeddecimal_ops and add corresponding operators to operator family fixeddecimal_ops
CALL babelfish_drop_deprecated_opclass('sys', 'int4_fixeddecimal_ops');

ALTER OPERATOR FAMILY sys.fixeddecimal_ops USING btree ADD
    OPERATOR    1   sys.<  (INT4, sys.FIXEDDECIMAL),
    OPERATOR    2   sys.<= (INT4, sys.FIXEDDECIMAL),
    OPERATOR    3   sys.=  (INT4, sys.FIXEDDECIMAL),
    OPERATOR    4   sys.>= (INT4, sys.FIXEDDECIMAL),
    OPERATOR    5   sys.>  (INT4, sys.FIXEDDECIMAL),
    FUNCTION    1   sys.int4_fixeddecimal_cmp(INT4, sys.FIXEDDECIMAL);

ALTER OPERATOR FAMILY sys.fixeddecimal_ops USING hash ADD
   OPERATOR    1   sys.=  (INT4, sys.FIXEDDECIMAL);


-- drop fixeddecimal_int2_ops and add corresponding operators to operator family fixeddecimal_ops
CALL babelfish_drop_deprecated_opclass('sys', 'fixeddecimal_int2_ops');

ALTER OPERATOR FAMILY sys.fixeddecimal_ops USING btree ADD
    OPERATOR    1   sys.<  (sys.FIXEDDECIMAL, INT2),
    OPERATOR    2   sys.<= (sys.FIXEDDECIMAL, INT2),
    OPERATOR    3   sys.=  (sys.FIXEDDECIMAL, INT2),
    OPERATOR    4   sys.>= (sys.FIXEDDECIMAL, INT2),
    OPERATOR    5   sys.>  (sys.FIXEDDECIMAL, INT2),
    FUNCTION    1   sys.fixeddecimal_int2_cmp(sys.FIXEDDECIMAL, INT2);

ALTER OPERATOR FAMILY sys.fixeddecimal_ops USING hash ADD
   OPERATOR    1   sys.=  (sys.FIXEDDECIMAL, INT2);


-- drop int2_fixeddecimal_ops and add corresponding operators to operator family fixeddecimal_ops
CALL babelfish_drop_deprecated_opclass('sys', 'int2_fixeddecimal_ops');

ALTER OPERATOR FAMILY sys.fixeddecimal_ops USING btree ADD
    OPERATOR    1   sys.<  (INT2, sys.FIXEDDECIMAL),
    OPERATOR    2   sys.<= (INT2, sys.FIXEDDECIMAL),
    OPERATOR    3   sys.=  (INT2, sys.FIXEDDECIMAL),
    OPERATOR    4   sys.>= (INT2, sys.FIXEDDECIMAL),
    OPERATOR    5   sys.>  (INT2, sys.FIXEDDECIMAL),
    FUNCTION    1   sys.int2_fixeddecimal_cmp(INT2, sys.FIXEDDECIMAL);

ALTER OPERATOR FAMILY sys.fixeddecimal_ops USING hash ADD
   OPERATOR    1   sys.=  (INT2, sys.FIXEDDECIMAL);


-- add combination of (int8/int4/int2/numeric) to fixeddecimal_ops to make it complete
ALTER OPERATOR FAMILY sys.fixeddecimal_ops USING btree ADD
    -- INT8
    OPERATOR    1   <  (INT8, INT8),
    OPERATOR    2   <= (INT8, INT8),
    OPERATOR    3   =  (INT8, INT8),
    OPERATOR    4   >= (INT8, INT8),
    OPERATOR    5   >  (INT8, INT8),
    FUNCTION    1   btint8cmp(INT8, INT8),

    OPERATOR    1   <  (INT8, INT4),
    OPERATOR    2   <= (INT8, INT4),
    OPERATOR    3   =  (INT8, INT4),
    OPERATOR    4   >= (INT8, INT4),
    OPERATOR    5   >  (INT8, INT4),
    FUNCTION    1   btint84cmp(INT8, INT4),

    OPERATOR    1   <  (INT8, INT2),
    OPERATOR    2   <= (INT8, INT2),
    OPERATOR    3   =  (INT8, INT2),
    OPERATOR    4   >= (INT8, INT2),
    OPERATOR    5   >  (INT8, INT2),
    FUNCTION    1   btint82cmp(INT8, INT2),

    -- INT4
    OPERATOR    1   <  (INT4, INT8),
    OPERATOR    2   <= (INT4, INT8),
    OPERATOR    3   =  (INT4, INT8),
    OPERATOR    4   >= (INT4, INT8),
    OPERATOR    5   >  (INT4, INT8),
    FUNCTION    1   btint48cmp(INT4, INT8),

    OPERATOR    1   <  (INT4, INT4),
    OPERATOR    2   <= (INT4, INT4),
    OPERATOR    3   =  (INT4, INT4),
    OPERATOR    4   >= (INT4, INT4),
    OPERATOR    5   >  (INT4, INT4),
    FUNCTION    1   btint4cmp(INT4, INT4),

    OPERATOR    1   <  (INT4, INT2),
    OPERATOR    2   <= (INT4, INT2),
    OPERATOR    3   =  (INT4, INT2),
    OPERATOR    4   >= (INT4, INT2),
    OPERATOR    5   >  (INT4, INT2),
    FUNCTION    1   btint42cmp(INT4, INT2),

    -- INT2
    OPERATOR    1   <  (INT2, INT8),
    OPERATOR    2   <= (INT2, INT8),
    OPERATOR    3   =  (INT2, INT8),
    OPERATOR    4   >= (INT2, INT8),
    OPERATOR    5   >  (INT2, INT8),
    FUNCTION    1   btint28cmp(INT2, INT8),

    OPERATOR    1   <  (INT2, INT4),
    OPERATOR    2   <= (INT2, INT4),
    OPERATOR    3   =  (INT2, INT4),
    OPERATOR    4   >= (INT2, INT4),
    OPERATOR    5   >  (INT2, INT4),
    FUNCTION    1   btint24cmp(INT2, INT4),

    OPERATOR    1   <  (INT2, INT2),
    OPERATOR    2   <= (INT2, INT2),
    OPERATOR    3   =  (INT2, INT2),
    OPERATOR    4   >= (INT2, INT2),
    OPERATOR    5   >  (INT2, INT2),
    FUNCTION    1   btint2cmp(INT2, INT2),

    -- numeric
    OPERATOR    1   <  (NUMERIC, NUMERIC),
    OPERATOR    2   <= (NUMERIC, NUMERIC),
    OPERATOR    3   =  (NUMERIC, NUMERIC),
    OPERATOR    4   >= (NUMERIC, NUMERIC),
    OPERATOR    5   >  (NUMERIC, NUMERIC),
    FUNCTION    1   numeric_cmp(NUMERIC, NUMERIC);


ALTER OPERATOR FAMILY sys.fixeddecimal_ops USING hash ADD
    OPERATOR    1   =  (INT8, INT8),
    OPERATOR    1   =  (INT8, INT4),
    OPERATOR    1   =  (INT8, INT2),
    OPERATOR    1   =  (INT4, INT8),
    OPERATOR    1   =  (INT4, INT4),
    OPERATOR    1   =  (INT4, INT2),
    OPERATOR    1   =  (INT2, INT8),
    OPERATOR    1   =  (INT2, INT4),
    OPERATOR    1   =  (INT2, INT2),
    OPERATOR    1   =  (NUMERIC, NUMERIC),
    FUNCTION    1   hashint8(INT8),
    FUNCTION    1   hashint4(INT4),
    FUNCTION    1   hashint2(INT2),
    FUNCTION    1   hash_numeric(NUMERIC);


-- Any casting from (var)binary to float4 and float8 is not allowed. drop CAST
DROP CAST IF EXISTS (sys.BBF_BINARY as REAL);
DROP CAST IF EXISTS (sys.BBF_BINARY as DOUBLE PRECISION);
DROP CAST IF EXISTS (sys.BBF_VARBINARY as REAL);
DROP CAST IF EXISTS (sys.BBF_VARBINARY as DOUBLE PRECISION);

CREATE CAST (sys.VARCHAR as sys.BPCHAR)
WITHOUT FUNCTION AS IMPLICIT;

CREATE OR REPLACE FUNCTION sys.bpchar2int2(sys.BPCHAR)
RETURNS INT2
AS 'babelfishpg_common', 'bpchar2int2'
LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE CAST (sys.BPCHAR AS INT2)
WITH FUNCTION sys.bpchar2int2(sys.BPCHAR) AS IMPLICIT;

CREATE OR REPLACE FUNCTION sys.bpchar2int4(sys.BPCHAR)
RETURNS INT4
AS 'babelfishpg_common', 'bpchar2int4'
LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE CAST (sys.BPCHAR AS INT4)
WITH FUNCTION sys.bpchar2int4(sys.BPCHAR) AS IMPLICIT;

CREATE OR REPLACE FUNCTION sys.bpchar2int8(sys.BPCHAR)
RETURNS INT8
AS 'babelfishpg_common', 'bpchar2int8'
LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE CAST (sys.BPCHAR AS INT8)
WITH FUNCTION sys.bpchar2int8(sys.BPCHAR) AS IMPLICIT;

CREATE OR REPLACE FUNCTION sys.bpchar2float4(sys.BPCHAR)
RETURNS FLOAT4
AS 'babelfishpg_common', 'bpchar2float4'
LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE CAST (sys.BPCHAR AS FLOAT4)
WITH FUNCTION sys.bpchar2float4(sys.BPCHAR) AS IMPLICIT;

CREATE OR REPLACE FUNCTION sys.bpchar2float8(sys.BPCHAR)
RETURNS FLOAT8
AS 'babelfishpg_common', 'bpchar2float8'
LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE CAST (sys.BPCHAR AS FLOAT8)
WITH FUNCTION sys.bpchar2float8(sys.BPCHAR) AS IMPLICIT;

CREATE OR REPLACE FUNCTION sys.varchar2int2(sys.VARCHAR)
RETURNS INT2
AS 'babelfishpg_common', 'varchar2int2'
LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE CAST (sys.VARCHAR AS INT2)
WITH FUNCTION sys.varchar2int2(sys.VARCHAR) AS IMPLICIT;

CREATE OR REPLACE FUNCTION sys.varchar2int4(sys.VARCHAR)
RETURNS INT4
AS 'babelfishpg_common', 'varchar2int4'
LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE CAST (sys.VARCHAR AS INT4)
WITH FUNCTION sys.varchar2int4(sys.VARCHAR) AS IMPLICIT;

CREATE OR REPLACE FUNCTION sys.varchar2int8(sys.VARCHAR)
RETURNS INT8
AS 'babelfishpg_common', 'varchar2int8'
LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE CAST (sys.VARCHAR AS INT8)
WITH FUNCTION sys.varchar2int8(sys.VARCHAR) AS IMPLICIT;

CREATE OR REPLACE FUNCTION sys.varchar2float4(sys.VARCHAR)
RETURNS FLOAT4
AS 'babelfishpg_common', 'varchar2float4'
LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE CAST (sys.VARCHAR AS FLOAT4)
WITH FUNCTION sys.varchar2float4(sys.VARCHAR) AS IMPLICIT;

CREATE OR REPLACE FUNCTION sys.varchar2float8(sys.VARCHAR)
RETURNS FLOAT8
AS 'babelfishpg_common', 'varchar2float8'
LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE CAST (sys.VARCHAR AS FLOAT8)
WITH FUNCTION sys.varchar2float8(sys.VARCHAR) AS IMPLICIT;

-- Drops the temporary procedure used by the upgrade script.
-- Please have this be one of the last statements executed in this upgrade script.
DROP PROCEDURE babelfish_drop_deprecated_opclass(varchar, varchar);