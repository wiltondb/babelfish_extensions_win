-- tsql
USE master
GO

CREATE TABLE sp_rename_vu_table1(sp_rename_vu_t1_col1 int, sp_rename_vu_t1_col2 int);
GO

CREATE TABLE sp_rename_vu_table2(sp_rename_vu_t2_col1 int, sp_rename_vu_t2_col2 int);
GO

CREATE SCHEMA sp_rename_vu_schema1;
GO

CREATE TABLE sp_rename_vu_schema1.sp_rename_vu_table1(sp_rename_vu_s1_t1_col1 int, sp_rename_vu_s1_t1_col2 int);
GO

CREATE TABLE sp_rename_vu_schema1.sp_rename_vu_table2(sp_rename_vu_s1_t2_col1 int, sp_rename_vu_s1_t2_col2 int);
GO

CREATE VIEW sp_rename_vu_view1 as SELECT sp_rename_vu_t1_col1 FROM sp_rename_vu_table1;
GO

CREATE VIEW sp_rename_vu_schema1.sp_rename_vu_view1 as SELECT sp_rename_vu_s1_t1_col1 FROM sp_rename_vu_table1;
GO

CREATE PROCEDURE sp_rename_vu_proc1
AS
SELECT 1;
GO

CREATE PROCEDURE sp_rename_vu_schema1.sp_rename_vu_proc2
AS
SELECT 1;
GO

CREATE FUNCTION sp_rename_vu_func1() 
RETURNS INT
AS 
BEGIN
    RETURN 1;
END
GO

CREATE FUNCTION sp_rename_vu_func2(@id INT) 
RETURNS INT
AS 
BEGIN
    RETURN 1;
END
GO

CREATE FUNCTION sp_rename_vu_schema1.sp_rename_vu_func3(@id INT) 
RETURNS INT
AS 
BEGIN
    RETURN 1;
END
GO

CREATE SEQUENCE sp_rename_vu_seq1 
START WITH 1  
INCREMENT BY 1;  
GO

CREATE SEQUENCE sp_rename_vu_schema1.sp_rename_vu_seq1 
START WITH 1  
INCREMENT BY 1;  
GO

CREATE SEQUENCE sp_rename_vu_seq2
START WITH 1  
INCREMENT BY 1;  
GO

CREATE TRIGGER sp_rename_vu_trig1 ON sp_rename_vu_table2
AFTER INSERT, UPDATE AS 
RAISERROR ('Testing sp_rename', 16, 10);
GO