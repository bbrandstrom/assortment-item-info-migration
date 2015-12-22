REM*******************************************************************************************************************
REM***    File Name     :   Execute_Item_info_Conversion.sql
REM***
REM***    Purpose       :  This file is used to kick off the Item Info Conversion Process
REM***                     The file contains several annonomys PL/SQL blocks to execute the Creation of Database objects 
REM***                     Create tables, Indexs, installs Packages, and triggers used in the Conversion Process. 
REM***                     File also executes the conversion process. 
REM***                     the entire conversion process is completed when complete.
REM***
REM***
REM***
REM***    Creation  Date:  12-01-2015 
REM***
REM***
REM***    Author        :   Brett Brandstrom Sr.Oracle Developer/Analysist
REM***                      Brandstrom Consulting Services
REM***                      Brett.Brandstrom@gmail.com
REM***
REM********************************************************************************************************************
set serveroutput on size 1000000
declare

 v_item_info_master      varchar2(32000);
 v_item_info_detail      varchar2(32000);
 v_item_attribute_master varchar2(32000);
 v_item_master_seq       varchar2(32000);
 v_item_attribute_idx    varchar2(32000);
 v_alter_idx             varchar2(32000);
 V_CREATE_IF             VARCHAR2(32000);


begin


 v_item_info_master := q'[CREATE TABLE "SPS_CATALOG"."ITEM_INFO_MASTER"("ITEMINFOID" NUMBER(10,0),"COMPANYID" NUMBER(10,0) NOT NULL ENABLE,"ISXREF" NUMBER DEFAULT 0 NOT NULL ENABLE,"ISVALID" NUMBER(12,0) DEFAULT 2 NOT NULL ENABLE,]'; 
 v_item_info_master :=v_item_info_master||q'[ "ROW_VERSION" NUMBER(12,0) DEFAULT 1 NOT NULL ENABLE,"HASHCOL" VARCHAR2(255 BYTE),"MODIFIED_BY" VARCHAR2(255 BYTE),"MODIFIED_DATE" DATE,"MODIFIED_BY_SVC" VARCHAR2(255 BYTE),]'; 
 v_item_info_master :=v_item_info_master||q'["ITEMTIMESTAMP" TIMESTAMP (6) DEFAULT SYSDATE,"CREATEDDATE" TIMESTAMP (6) DEFAULT SYSDATE,"UPC" VARCHAR2(50 BYTE),"GTIN" VARCHAR2(20 BYTE),"EAN" VARCHAR2(50 BYTE),]'; 
 v_item_info_master :=v_item_info_master||q'["PARTNUMBER" VARCHAR2(50 BYTE),"ISBN" VARCHAR2(50 BYTE),"ISACTIVE" NUMBER ) SEGMENT CREATION DEFERRED PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 NOCOMPRESS LOGGING TABLESPACE "SPS_CATALOG" ]';

 v_item_info_detail:= q'[CREATE TABLE "SPS_CATALOG"."ITEM_INFO_DETAIL" ("ITEMINFOID" NUMBER(10,0) NOT NULL ENABLE,"ITEM_ATTRIBUTE_ID" NUMBER NOT NULL ENABLE,"ITEM_ATTRIBUTE_VALUE" VARCHAR2(4000 BYTE),"MODIFIED_DATE" TIMESTAMP (6),]'; 
 v_item_info_detail:=  v_item_info_detail||q'["CREATEDDATE" TIMESTAMP (6)) SEGMENT CREATION IMMEDIATE PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 NOCOMPRESS LOGGING STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645]';
 v_item_info_detail:=  v_item_info_detail||q'[ PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT) TABLESPACE "SPS_CATALOG"]';


 
  
  v_item_attribute_master :=  q'[CREATE TABLE "SPS_CATALOG"."ITEM_ATTRIBUTE_MASTER" ("ITEM_ATTRIBUTE_ID" NUMBER,"ITEM_ATTRIBUTE_NAME" VARCHAR2(30 BYTE),"ITEM_ATTRIBUTE_TYPE" VARCHAR2(30 BYTE),"ITEM_ATTRIBUTE_LENGTH" VARCHAR2(30 BYTE),"ITEM_ATTRIBUTE_ACTIVE" NUMBER,]';
  v_item_attribute_master :=  v_item_attribute_master||q'["CREATEDDATE" TIMESTAMP (6),"ITEM_ATTRIBUTE_ACTIVE_DATE" TIMESTAMP (6),"ITEM_ATTRIBUTE_DEACTIVE_DATE" TIMESTAMP (6),"ITEM_ATTRIBUTE_POSITION" NUMBER,"ITEM_ATTRIBUTE_CATEGORYID" VARCHAR2(30 BYTE),"ITEM_ATTRIBUTE_LABEL" VARCHAR2(200 BYTE),]'; 
	v_item_attribute_master :=  v_item_attribute_master||q'["ITEM_ATTRIBUTE_FORMAT" VARCHAR2(200 BYTE)) SEGMENT CREATION IMMEDIATE PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 NOCOMPRESS LOGGING STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645 PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 ]';
  v_item_attribute_master :=  v_item_attribute_master||q'[BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT) TABLESPACE "SPS_CATALOG"]' ;

  v_item_master_seq := q'[CREATE SEQUENCE  "SPS_CATALOG"."ITEM_ATTRIBUTE_MASTER_SEQ"  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 881 CACHE 20 NOORDER  NOCYCLE]';


  v_item_attribute_idx := q'[CREATE INDEX "SPS_CATALOG"."ITEM_ATTRIBUTE_MASTER_IDX1" ON "SPS_CATALOG"."ITEM_ATTRIBUTE_MASTER" ("ITEM_ATTRIBUTE_ID") PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS ]';
  v_item_attribute_idx := v_item_attribute_idx ||q'[ STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645 PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)]';
  v_item_attribute_idx := v_item_attribute_idx ||q'[TABLESPACE "SPS_CATALOG" PARALLEL]' ;

  v_alter_idx  :=    q'[ALTER INDEX SPS_CATALOG.ITEM_ATTRIBUTE_MASTER_IDX1 NOPARALLEL]';

   V_CREATE_IF := 'CREATE OR REPLACE PROCEDURE Item_Info_Validation_Proc(indx in NUMBER) AS '||chr(10);
   V_CREATE_IF := V_CREATE_IF||'        '||chr(10);
   V_CREATE_IF := V_CREATE_IF||'BEGIN   '||chr(10);
   V_CREATE_IF := V_CREATE_IF||'   null;  '||chr(10);
   V_CREATE_IF := V_CREATE_IF||'END Item_Info_Validation_Proc;'; 
   
   
execute immediate v_item_info_master;
execute immediate v_item_info_detail;
execute immediate v_item_attribute_master;
execute immediate v_item_master_seq;
execute immediate v_item_attribute_idx;
execute immediate v_alter_idx;
execute immediate V_CREATE_IF;
  end;
/

@ITEM_INFO_UTILITIES.pks
@ITEM_INFO_UTILITIES.pkb
@ITEM_INFO_CONVERSION.pks
@ITEM_INFO_CONVERSION.pkb
  
  declare 
  
  v_statement              varchar2(32000);
  
  begin
 v_statement := q'{     DECLARE
     	 cursor c_main is select column_name ,data_type,data_length from all_tab_columns 
                              where table_name = 'ITEM_INFO' and column_name not in (select item_attribute_name from item_attribute_master)
                              ORDER BY COLUMN_ID;

             v_attribute_id item_attribute_master.item_attribute_id%type;

      BEGIN

             for v_main in c_main loop
                                    ITEM_INFO_utilities.create_new_item_attribute (v_main.column_name,  -- ITEM_ATTRIBUTE_NAME  ,
                                     v_main.data_type, --ITEM_ATTRIBUTE_TYPE  ,                 
                                     v_main.data_length ,--ITEM_ATTRIBUTE_LENGTH ,
                                     v_main.column_name,--ITEM_ATTRIBUTE_LABEL   ,
                                     null   ,
                                     1 ,
                                     null  );

								 
             end loop;								 
								 
         commit;						 
	  END;}';
	execute immediate v_statement;  
   
     ITEM_INFO_UTILITIES.Create_Item_Validation_Stmt;  
     ITEM_INFO_CONVERSION.ITEM_INFO_CONVERSION;


end;
/
declare

v_item_mst_idx1  varchar2(32000);
v_item_mst_idx2  varchar2(32000);
v_item_mst_idx3  varchar2(32000);
v_item_mst_idx4  varchar2(32000);
v_item_mst_idx5  varchar2(32000);
v_item_mst_idx6  varchar2(32000);
v_item_mst_idx7  varchar2(32000);
v_item_mst_idx8  varchar2(32000);
v_item_mst_idx9  varchar2(32000);
v_item_mst_idx10 varchar2(32000);
v_item_mst_idx11 varchar2(32000);
v_item_mst_idx12 varchar2(32000);
v_item_mst_idx13 varchar2(32000);
v_item_mst_idx14 varchar2(32000);

v_item_dtl_idx1  varchar2(32000);
v_item_dtl_idx2  varchar2(32000);
v_alter_1        varchar2(1000);
v_alter_2        varchar2(1000);
v_alter_3        varchar2(1000);
v_alter_4        varchar2(1000);
v_alter_5        varchar2(1000);
v_alter_6        varchar2(1000);
v_alter_7        varchar2(1000);
v_alter_8        varchar2(1000);
v_alter_9        varchar2(1000);
v_alter_10       varchar2(1000);
v_alter_11       varchar2(1000);
v_alter_12       varchar2(1000);
v_alter_13       varchar2(1000);
v_alter_14       varchar2(1000);
v_alter_15       varchar2(1000);
v_alter_16       varchar2(1000);

V_ALTER_pk      varchar2(1000) := 'ALTER TABLE ITEM_INFO_MASTER ADD CONSTRAINT ITEMINFOID_PK PRIMARY KEY(ITEMINFOID)';
V_ALTER_pk2     varchar2(1000) := 'ALTER TABLE ITEM_INFO_DETAIL ADD CONSTRAINT ITEM_INFO_DETAIL_PK PRIMARY KEY(ITEMINFOID,ITEM_ATTRIBUTE_ID)';

sql_stmt_rename  varchar2(4000):=  'alter table item_info rename to item_info_orig';

begin

   v_item_mst_idx1 :=   q'[CREATE INDEX "SPS_CATALOG"."ITEM_INFO_MASTER_IDX1" ON "SPS_CATALOG"."ITEM_INFO_MASTER" ("ITEMINFOID") PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645 ]';
   v_item_mst_idx1 := v_item_mst_idx1 || q'[PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT) TABLESPACE "SPS_CATALOG" PARALLEL ]';


   v_item_mst_idx2 := q'[CREATE INDEX "SPS_CATALOG"."ITEM_INFO_MASTER_IDX2" ON "SPS_CATALOG"."ITEM_INFO_MASTER" ("COMPANYID", "ITEMINFOID") PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS ]';
   v_item_mst_idx2 := v_item_mst_idx2||q'[ STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645 PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)]';
   v_item_mst_idx2 := v_item_mst_idx2||q'[TABLESPACE "SPS_CATALOG" PARALLEL]';
 
   v_item_mst_idx3 :=q'[CREATE INDEX "SPS_CATALOG"."ITEM_INFO_MASTER_IDX3" ON "SPS_CATALOG"."ITEM_INFO_MASTER" ("COMPANYID") PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 ]';
   v_item_mst_idx3 := v_item_mst_idx3||q'[ MAXEXTENTS 2147483645 PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT) TABLESPACE "SPS_CATALOG" PARALLEL]';

   
   v_item_mst_idx4 := v_item_mst_idx4||q'[CREATE INDEX "SPS_CATALOG"."ITEM_INFO_MST_CREDATE_IDX" ON "SPS_CATALOG"."ITEM_INFO_MASTER" ("CREATEDDATE")  ]';
   v_item_mst_idx4 := v_item_mst_idx4||q'[ PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS  ]';
   v_item_mst_idx4 := v_item_mst_idx4||q'[  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645]';
   v_item_mst_idx4 := v_item_mst_idx4||q'[PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 ]';
   v_item_mst_idx4 := v_item_mst_idx4||q'[ BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)  TABLESPACE "SPS_CATALOG" PARALLEL ]';

   
   v_item_mst_idx5 := v_item_mst_idx5||q'[CREATE INDEX "SPS_CATALOG"."ITEM_INFO_MST_EAN_IDX" ON "SPS_CATALOG"."ITEM_INFO_MASTER" ("EAN")  ]';
   v_item_mst_idx5 := v_item_mst_idx5||q'[PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS  ]';
   v_item_mst_idx5 := v_item_mst_idx5||q'[ STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645]';
   v_item_mst_idx5 := v_item_mst_idx5||q'[PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 ]';
   v_item_mst_idx5 := v_item_mst_idx5||q'[BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT) ]';
   v_item_mst_idx5 := v_item_mst_idx5||q'[ TABLESPACE "SPS_CATALOG" PARALLEL]';
   
   
   v_item_mst_idx6 := v_item_mst_idx6||q'[CREATE INDEX "SPS_CATALOG"."ITEM_INFO_MST_GTIN_IDX" ON "SPS_CATALOG"."ITEM_INFO_MASTER" ("GTIN")  ]';
   v_item_mst_idx6 := v_item_mst_idx6||q'[ PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS ]';
   v_item_mst_idx6 := v_item_mst_idx6||q'[STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645 ]';
   v_item_mst_idx6 := v_item_mst_idx6||q'[ PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1]';
   v_item_mst_idx6 := v_item_mst_idx6||q'[BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)]';
   v_item_mst_idx6 := v_item_mst_idx6||q'[TABLESPACE "SPS_CATALOG" PARALLEL ]';
   
   v_item_mst_idx7 := v_item_mst_idx7||q'[ CREATE UNIQUE INDEX "SPS_CATALOG"."ITEM_INFO_MST_HASH_IDX" ON "SPS_CATALOG"."ITEM_INFO_MASTER" (CASE  WHEN ("ISACTIVE"=0 OR "HASHCOL" IS NULL) THEN NULL ELSE "COMPANYID" END , CASE "ISACTIVE" WHEN 0 THEN NULL ELSE "HASHCOL" END )]';
   v_item_mst_idx7 := v_item_mst_idx7||q'[ PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS  ]';
   v_item_mst_idx7 := v_item_mst_idx7||q'[ STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645]';
   v_item_mst_idx7 := v_item_mst_idx7||q'[ PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 ]';
   v_item_mst_idx7 := v_item_mst_idx7||q'[ BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT) ]';
   v_item_mst_idx7 := v_item_mst_idx7||q'[ TABLESPACE "SPS_CATALOG" PARALLEL ]';
  
   v_item_mst_idx8 := v_item_mst_idx8||q'[ CREATE INDEX "SPS_CATALOG"."ITEM_INFO_MST_IDX11" ON "SPS_CATALOG"."ITEM_INFO_MASTER" ("ISACTIVE", "ITEMINFOID")]';
   v_item_mst_idx8 := v_item_mst_idx8||q'[ PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS ]';
   v_item_mst_idx8 := v_item_mst_idx8||q'[ STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645]';
   v_item_mst_idx8 := v_item_mst_idx8||q'[ PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 MAXSIZE UNLIMITED ]';
   v_item_mst_idx8 := v_item_mst_idx8||q'[ BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)]';
   v_item_mst_idx8 := v_item_mst_idx8||q'[ TABLESPACE "SPS_CATALOG" PARALLEL ]';

   v_item_mst_idx9 := v_item_mst_idx9||q'[ CREATE INDEX "SPS_CATALOG"."ITEM_INFO_MST_TM_IDX1" ON "SPS_CATALOG"."ITEM_INFO_MASTER" ("ITEMTIMESTAMP") ]';
   v_item_mst_idx9 := v_item_mst_idx9||q'[ PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS  ]';
   v_item_mst_idx9 := v_item_mst_idx9||q'[ STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645 ]';
   v_item_mst_idx9 := v_item_mst_idx9||q'[ PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1]';
   v_item_mst_idx9 := v_item_mst_idx9||q'[ BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)]';
   v_item_mst_idx9 := v_item_mst_idx9||q'[ TABLESPACE "SPS_CATALOG" PARALLEL ]';

   v_item_mst_idx10 := v_item_mst_idx10||q'[ CREATE INDEX "SPS_CATALOG"."ITEM_INFO_MST_ISACTIVE_IDX" ON "SPS_CATALOG"."ITEM_INFO_MASTER" ("ISACTIVE")  ]';
   v_item_mst_idx10 := v_item_mst_idx10||q'[ PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS ]';
   v_item_mst_idx10 := v_item_mst_idx10||q'[ STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645]';
   v_item_mst_idx10 := v_item_mst_idx10||q'[ PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1]';
   v_item_mst_idx10 := v_item_mst_idx10||q'[ BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)]';
   v_item_mst_idx10 := v_item_mst_idx10||q'[ TABLESPACE "SPS_CATALOG" PARALLEL ]';

   
   v_item_mst_idx11 := v_item_mst_idx11||q'[ CREATE INDEX "SPS_CATALOG"."ITEM_INFO_MST_ISBN_IDX" ON "SPS_CATALOG"."ITEM_INFO_MASTER" ("ISBN") ]';
   v_item_mst_idx11 := v_item_mst_idx11||q'[ PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS ]';
   v_item_mst_idx11 := v_item_mst_idx11||q'[ STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645 ]';
   v_item_mst_idx11 := v_item_mst_idx11||q'[ PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1]';
   v_item_mst_idx11 := v_item_mst_idx11||q'[ BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)]';
   v_item_mst_idx11 := v_item_mst_idx11||q'[ TABLESPACE "SPS_CATALOG" PARALLEL ]';

   v_item_mst_idx12 := v_item_mst_idx12||q'[ CREATE INDEX "SPS_CATALOG"."ITEM_INFO_MST_MODDATE_IDX" ON "SPS_CATALOG"."ITEM_INFO_MASTER" ("MODIFIED_DATE") ]';
   v_item_mst_idx12 := v_item_mst_idx12||q'[ PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS ]';
   v_item_mst_idx12 := v_item_mst_idx12||q'[ STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645]';
   v_item_mst_idx12 := v_item_mst_idx12||q'[ PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1]';
   v_item_mst_idx12 := v_item_mst_idx12||q'[ BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)]';
   v_item_mst_idx12 := v_item_mst_idx12||q'[ TABLESPACE "SPS_CATALOG" PARALLEL ]';
   
   v_item_mst_idx13 := v_item_mst_idx13||q'[CREATE INDEX "SPS_CATALOG"."ITEM_INFO_PART_MST_IDX" ON "SPS_CATALOG"."ITEM_INFO_MASTER" ("PARTNUMBER")]';
   v_item_mst_idx13 := v_item_mst_idx13||q'[ PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS ]';
   v_item_mst_idx13 := v_item_mst_idx13||q'[ STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645]';
   v_item_mst_idx13 := v_item_mst_idx13||q'[ PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1]';
   v_item_mst_idx13 := v_item_mst_idx13||q'[ BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)]';
   v_item_mst_idx13 := v_item_mst_idx13||q'[ TABLESPACE "SPS_CATALOG" PARALLEL]';
   
   v_item_mst_idx14 := v_item_mst_idx14||q'[ CREATE INDEX "SPS_CATALOG"."ITEM_INFO_MST_UPC_IDX" ON "SPS_CATALOG"."ITEM_INFO_MASTER" ("UPC")]';
   v_item_mst_idx14 := v_item_mst_idx14||q'[ PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS ]';
   v_item_mst_idx14 := v_item_mst_idx14||q'[ STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645]';
   v_item_mst_idx14 := v_item_mst_idx14||q'[ PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1]';
   v_item_mst_idx14 := v_item_mst_idx14||q'[ BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)]';
   v_item_mst_idx14 := v_item_mst_idx14||q'[ TABLESPACE "SPS_CATALOG" PARALLEL ]';
  
   
   v_item_dtl_idx1 := q'[CREATE INDEX "SPS_CATALOG"."ITEM_INFO_DETAIL_IDX1" ON "SPS_CATALOG"."ITEM_INFO_DETAIL" ("ITEMINFOID") PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 ]';
   v_item_dtl_idx1 := v_item_dtl_idx1||q'[ MAXEXTENTS 2147483645 PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT) TABLESPACE "SPS_CATALOG" PARALLEL]';
 
 
   v_alter_1   := 'ALTER INDEX SPS_CATALOG.ITEM_INFO_MASTER_IDX1 NOPARALLEL';
   v_alter_2   := 'ALTER INDEX SPS_CATALOG.ITEM_INFO_MASTER_IDX2 NOPARALLEL';
   v_alter_3   := 'ALTER INDEX SPS_CATALOG.ITEM_INFO_MASTER_IDX3 NOPARALLEL';
   v_alter_4   := 'ALTER INDEX SPS_CATALOG.ITEM_INFO_MST_CREDATE_IDX NOPARALLEL';
   v_alter_5   := 'ALTER INDEX SPS_CATALOG.ITEM_INFO_MST_EAN_IDX NOPARALLEL';
   v_alter_6   := 'ALTER INDEX SPS_CATALOG.ITEM_INFO_MST_GTIN_IDX NOPARALLEL';
   v_alter_7   := 'ALTER INDEX SPS_CATALOG.ITEM_INFO_MST_HASH_IDX NOPARALLEL';
   v_alter_8   := 'ALTER INDEX SPS_CATALOG.ITEM_INFO_MST_IDX11 NOPARALLEL';
   v_alter_9   := 'ALTER INDEX SPS_CATALOG.ITEM_INFO_MST_TM_IDX1 NOPARALLEL';
   v_alter_10  := 'ALTER INDEX SPS_CATALOG.ITEM_INFO_MST_ISACTIVE_IDX NOPARALLEL';
   v_alter_11  := 'ALTER INDEX SPS_CATALOG.ITEM_INFO_MST_ISBN_IDX NOPARALLEL';
   v_alter_12  := 'ALTER INDEX SPS_CATALOG.ITEM_INFO_MST_MODDATE_IDX NOPARALLEL';
   v_alter_13  := 'ALTER INDEX SPS_CATALOG.ITEM_INFO_PART_MST_IDX NOPARALLEL';
   v_alter_14  := 'ALTER INDEX SPS_CATALOG.ITEM_INFO_MST_UPC_IDX NOPARALLEL';
  
  
   v_alter_15  := 'ALTER INDEX SPS_CATALOG.ITEM_INFO_DETAIL_IDX1 NOPARALLEL';


execute immediate v_item_mst_idx1;
execute immediate v_item_mst_idx2;
execute immediate v_item_mst_idx3;
execute immediate v_item_mst_idx4;
execute immediate v_item_mst_idx5;
execute immediate v_item_mst_idx6;
execute immediate v_item_mst_idx7;
execute immediate v_item_mst_idx8;
execute immediate v_item_mst_idx9;
execute immediate v_item_mst_idx10;
execute immediate v_item_mst_idx11;
execute immediate v_item_mst_idx12;
execute immediate v_item_mst_idx13;
execute immediate v_item_mst_idx14;
execute immediate V_ALTER_pk;
execute immediate V_ALTER_pk2;
execute immediate v_item_dtl_idx1;
execute immediate v_alter_1; 
execute immediate v_alter_2;
execute immediate v_alter_3;
execute immediate v_alter_4;
execute immediate v_alter_5; 
execute immediate v_alter_6;
execute immediate v_alter_7;
execute immediate v_alter_8;
execute immediate v_alter_9; 
execute immediate v_alter_10;
execute immediate v_alter_11;
execute immediate v_alter_12;
execute immediate v_alter_13; 
execute immediate v_alter_14;
execute immediate v_alter_15;

execute immediate sql_stmt_rename;

END;
/

analyze table item_info_master estimate statistics ;
analyze table item_info_detail estimate statistics ;

begin
     null;
	Item_Info_Utilities.Rebuild_Item_Info_Objects;
end;
/


  CREATE OR REPLACE TRIGGER "SPS_CATALOG"."ITEM_INFO_MST_ES_UPDATE_TRG" 
AFTER UPDATE ON ITEM_INFO_MASTER
REFERENCING OLD AS OLD NEW AS NEW
FOR EACH ROW
BEGIN
		INSERT INTO ES_MODIFICATION_HISTORY (ITEMINFOID, MODIFICATION_DATE) VALUES (:OLD.ITEMINFOID, SYSDATE);
        INSERT INTO ES_MODIFICATION_HISTORY (ITEMINFOID, MODIFICATION_DATE) VALUES (:NEW.ITEMINFOID, SYSDATE);
END;
/
ALTER TRIGGER "SPS_CATALOG"."ITEM_INFO_MST_ES_UPDATE_TRG" ENABLE;

  CREATE OR REPLACE TRIGGER "SPS_CATALOG"."ITEM_INFO_MST_ID_TRIGGER" 
BEFORE INSERT ON ITEM_INFO_MASTER 
FOR EACH ROW 
BEGIN 
    IF :NEW.ItemInfoId IS NULL OR :NEW.ItemInfoId < 0 THEN
        SELECT ITEM_SEQUENCE.NEXTVAL INTO :NEW.ItemInfoId FROM DUAL; 
    END IF;
END;
/
ALTER TRIGGER "SPS_CATALOG"."ITEM_INFO_MST_ID_TRIGGER" ENABLE;

  CREATE OR REPLACE TRIGGER "SPS_CATALOG"."ITEM_INFO_MST_ES_INSERT_TRG" 
AFTER INSERT ON ITEM_INFO_MASTER
FOR EACH ROW
BEGIN
        INSERT INTO ES_MODIFICATION_HISTORY (ITEMINFOID, MODIFICATION_DATE) VALUES (:NEW.ITEMINFOID, SYSDATE);
END;
/
ALTER TRIGGER "SPS_CATALOG"."ITEM_INFO_MST_ES_INSERT_TRG" ENABLE;

  CREATE OR REPLACE TRIGGER "SPS_CATALOG"."ITEM_INFO_MST_DELETE_TRIGGER" 
	AFTER DELETE ON ITEM_INFO_MASTER
	FOR EACH ROW
BEGIN
	INSERT INTO ITEM_INFO_HISTORY (ITEMINFOID, DELETED_DATE) VALUES (:OLD.ITEMINFOID, SYSDATE);
	 DELETE FROM ITEM_INFO_DETAIL WHERE ITEMINFOID = :OLD.ITEMINFOID;
END;
/
ALTER TRIGGER "SPS_CATALOG"."ITEM_INFO_MST_DELETE_TRIGGER" ENABLE;

  CREATE OR REPLACE TRIGGER "SPS_CATALOG"."ITEM_INFO_MST_UPDATE_TRIGGER" 
  BEFORE UPDATE
  ON ITEM_INFO_MASTER
 REFERENCING  OLD AS OLD NEW AS NEW
 FOR EACH ROW
BEGIN
  if :OLD.isvalid = 2 or :new.isvalid is not null then 
    select :new.isvalid into :NEW.ISVALID from DUAL;    
  else 
     select 2 into :new.isvalid from dual;
  end if;
    if(:new.isactive = 0) then 
    deactivateRelatedItems(:old.iteminfoid);
  end if;
END;
/
ALTER TRIGGER "SPS_CATALOG"."ITEM_INFO_MST_UPDATE_TRIGGER" ENABLE;

  CREATE OR REPLACE TRIGGER "SPS_CATALOG"."ITEM_INFO_MST_UPDATE_DATE" 
BEFORE  UPDATE ON ITEM_INFO_MASTER 
REFERENCING OLD AS OLD NEW AS NEW FOR EACH ROW 
DECLARE
   rowAuditUID NUMBER;
   columnAuditUID NUMBER;
  BEGIN 
  
    rowAuditUID := AUDITING.createRowTracking('ITEM_INFO_MASTER',:NEW.MODIFIED_BY,:NEW.MODIFIED_DATE,:NEW.MODIFIED_BY_SVC,:NEW.ITEMINFOID,:OLD.ROW_VERSION,:NEW.ROW_VERSION);

   IF rowAuditUID IS NULL THEN -- Don't do tracking
     RETURN;
   END IF;

   IF (:OLD.ROW_VERSION = :NEW.ROW_VERSION) OR (:NEW.MODIFIED_BY IS NULL) THEN
      :NEW.ROW_VERSION := :OLD.ROW_VERSION + 1;
      :NEW.MODIFIED_BY := 'SYSTEM';
      :NEW.MODIFIED_BY_SVC := 'SYSTEM';
      :NEW.MODIFIED_DATE := SYSDATE;
   END IF;
  
  SELECT SYSDATE INTO :NEW.ITEMTIMESTAMP FROM DUAL;
  
  END;
/
ALTER TRIGGER "SPS_CATALOG"."ITEM_INFO_MST_UPDATE_DATE" ENABLE;

  CREATE OR REPLACE TRIGGER "SPS_CATALOG"."ITEM_INFO_MST_UNIQUE_HASH" 
before insert or update on "ITEM_INFO_MASTER"
REFERENCING  OLD AS OLD NEW AS NEW
for each row
declare
  testcol varchar(500) default null;
  cursor c1 is select attribute from item_unique_criteria where companyid = :new.companyid;
begin
  for attribute_rec in c1
  loop
      if (attribute_rec.attribute = 'upc') then
        testcol := testcol || '-' || :new.upc;
      elsif (attribute_rec.attribute = 'gtin') then
        testcol := testcol || '-' || :new.gtin;
      elsif (attribute_rec.attribute = 'ean') then
        testcol := testcol || '-' || :new.ean;
      elsif (attribute_rec.attribute ='isbn') then
        testcol := testcol || '-' || :new.isbn;
      elsif (attribute_rec.attribute = 'partnumber') then
        testcol := testcol || '-' || :new.partnumber;
    end if;
  end loop;
  if(testcol is not null) then 
      testcol := dbms_crypto.hash(src=> utl_raw.cast_to_raw (testcol), typ=>dbms_crypto.hash_md5);      
  end if;
  :new.HASHCOL := testcol;
end item_info_mst_unique_hash;
/
ALTER TRIGGER "SPS_CATALOG"."ITEM_INFO_MST_UNIQUE_HASH" ENABLE;

  CREATE OR REPLACE TRIGGER "SPS_CATALOG"."AUDIT_ITEM_INFO_MST_INSERT" 
 BEFORE INSERT ON ITEM_INFO_MASTER 
REFERENCING NEW AS NEW
FOR EACH ROW
DECLARE
   rowAuditUID NUMBER;
BEGIN   
   rowAuditUID := AUDITING.createRowTracking('ITEM_INFO_MASTER',:NEW.MODIFIED_BY,:NEW.MODIFIED_DATE,:NEW.MODIFIED_BY_SVC,:NEW.ITEMINFOID,NULL,:NEW.ROW_VERSION);
 
END;
/
ALTER TRIGGER "SPS_CATALOG"."AUDIT_ITEM_INFO_MST_INSERT" ENABLE;
/