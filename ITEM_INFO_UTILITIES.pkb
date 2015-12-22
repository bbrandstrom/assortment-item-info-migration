REM*******************************************************************************************************************
REM***    File Name     :   Item_info_utilities.pkb
REM***
REM***    Purpose       :  This file contains the source code for Item_Info_utilities Package Body 
REM***                     package creates several database objects dynamically code relies on PL/SQL tables 
REM***                     defined in item_info_conversion package spec. 
REM***                   
REM***    Creation  Date:  12-01-2015 
REM***
REM***
REM***    Author        :   Brett Brandstrom Sr.Oracle Developer/Analysist
REM***                      Brandstrom Consulting Services
REM***
REM***
REM********************************************************************************************************************
create or replace PACKAGE BODY ITEM_INFO_UTILITIES 
AS

PROCEDURE Create_Item_Validation_Stmt as

v_large_iF_beg           varchar2(2000); 
v_large_if_mid           clob:=null;
v_large_if_end           varchar2(2000):=   'END Item_Info_Validation_Proc;'; 
v_large_if_statement     clob  :=null;
v_length_cnt number:=0;

begin
  



   v_large_if_beg := 'CREATE OR REPLACE PROCEDURE Item_Info_Validation_Proc(indx in NUMBER) AS '||chr(10);
   v_large_if_beg := v_large_if_beg ||'        '||chr(10);
   v_large_if_beg := v_large_if_beg ||'        '||chr(10);
   v_large_if_beg := v_large_if_beg ||'BEGIN   '||chr(10);




 for v_if_main in (select '     BEGIN '||chr(10)||'           IF Item_info_CONVERSION.item_info_tab(indx).'||ITEM_ATTRIBUTE_name||' IS NOT NULL THEN'||chr(10)||'               item_info_conversion.item_detail_tab((item_info_conversion.item_detail_tab.count+1)).ITEM_ATTRIBUTE_ID := '||ITEM_ATTRIBUTE_ID||';'||chr(10)||'               item_info_conversion.item_detail_tab((item_info_conversion.item_detail_tab.count)).ITEMINFOID :=  Item_info_CONVERSION.item_info_tab(indx).ITEMINFOID ;'||chr(10)|| 
'               item_info_conversion.item_detail_tab((item_info_conversion.item_detail_tab.count)).item_attribute_value := TO_CHAR(Item_info_CONVERSION.item_info_tab(indx).'||ITEM_ATTRIBUTE_name||');'||chr(10)||'           END IF;'||chr(10)||'     END;' v_if_stmt
                             from 
                                ITEM_ATTRIBUTE_MASTER 
                            WHERE
                                ITEM_ATTRIBUTE_NAME NOT IN (
                                    'ITEMINFOID',
                                    'COMPANYID',
                                    'ISXREF',
                                    'ISVALID',
                                    'ROW_VERSION',            
                                    'HASHCOL',
                                    'MODIFIED_BY'        ,
                                    'modified_date'       ,
                                    'MODIFIED_BY_SVC'      ,
                                    'ITEMTIMESTAMP'        ,
                                    'CREATEDDATE'           ,
                                    'UPC'                 ,
                                    'GTIN'                  ,
                                    'EAN'                   ,
                                    'PARTNUMBER'      ,
                                    'ISBN'  )
                                    ORDER BY ITEM_ATTRIBUTE_POSITION)  loop
        
                
                   v_length_cnt := v_length_cnt+length(v_if_main.v_if_stmt);
                   v_large_if_mid := v_large_if_mid||chr(10) || v_if_main.v_if_stmt;
                end loop;           
          
    
              v_large_if_statement :=v_large_if_beg ||v_large_if_mid||chr(10) ||v_large_if_end;
               execute immediate v_large_if_statement;
    
    if ( v_large_if_statement is not null )   then
      if DBMS_LOB.ISOPEN ( v_large_if_statement) <> 0 then 
        dbms_lob.close( v_large_if_statement );
       end if; 
   
       if DBMS_LOB.ISOPEN ( v_large_if_mid)  <> 0 then
          dbms_lob.close( v_large_if_mid );
      end if;
     dbms_lob.freeTemporary( v_large_if_mid );
     dbms_lob.freeTemporary( v_large_if_statement );
  end if; 
    
 end Create_Item_Validation_Stmt;

PROCEDURE create_new_item_attribute (       i_ITEM_ATTRIBUTE_NAME in ITEM_ATTRIBUTE_MASTER.ITEM_ATTRIBUTE_name%type ,
                                                             i_ITEM_ATTRIBUTE_TYPE in ITEM_ATTRIBUTE_MASTER.ITEM_ATTRIBUTE_type%type ,                 
                                                             i_ITEM_ATTRIBUTE_LENGTH in number,
                                                             I_ITEM_ATTRIBUTE_LABEL    IN ITEM_ATTRIBUTE_MASTER.ITEM_ATTRIBUTE_LABEL%TYPE,
                                                             I_ITEM_ATTRIBUTE_FORMAT   IN ITEM_ATTRIBUTE_MASTER.ITEM_ATTRIBUTE_FORMAT%TYPE,
                                                             i_ITEM_ATTRIBUTE_ACTIVE in ITEM_ATTRIBUTE_MASTER.ITEM_ATTRIBUTE_ACTIVE%type,
                                                             i_ITEM_ATTRIBUTE_CATEGORYID   in ITEM_ATTRIBUTE_MASTER.ITEM_ATTRIBUTE_CATEGORYID%type)


AS

v_ITEM_ATTRIBUTE_ID          item_attribute_master.ITEM_ATTRIBUTE_ID%type; 
v_ITEM_ATTRIBUTE_POSITION    item_attribute_master.ITEM_ATTRIBUTE_POSITION%type;
O_RETURN_ATTRIBUTE_ID        ITEM_ATTRIBUTE_MASTER.ITEM_ATTRIBUTE_ID%TYPE := null;

PRAGMA AUTONOMOUS_TRANSACTION;

begin

              O_RETURN_ATTRIBUTE_ID := get_item_attribute_id(i_ITEM_ATTRIBUTE_NAME); 
      
    
         
        if O_RETURN_ATTRIBUTE_ID = 0  then
 
             SELECT ITEM_ATTRIBUTE_MASTER_SEQ.NEXTVAL INTO o_RETURN_ATTRIBUTE_ID FROM DUAL;
 
             select (nvl(max(ITEM_ATTRIBUTE_POSITION),0)+1) into V_ITEM_ATTRIBUTE_POSITION from ITEM_ATTRIBUTE_MASTER; 
 

                                      insert into ITEM_ATTRIBUTE_MASTER (
                                                                         ITEM_ATTRIBUTE_ID ,   
                                                                         ITEM_ATTRIBUTE_NAME,
                                                                         ITEM_ATTRIBUTE_TYPE,
                                                                         ITEM_ATTRIBUTE_LENGTH,
                                                                         ITEM_ATTRIBUTE_ACTIVE,
                                                                         createddate,
                                                                         ITEM_ATTRIBUTE_ACTIVE_DATE,
                                                                         ITEM_ATTRIBUTE_DEACTIVE_DATE,
                                                                         ITEM_ATTRIBUTE_POSITION,
                                                                         ITEM_ATTRIBUTE_CATEGORYID,
                                                                         ITEM_ATTRIBUTE_LABEL,
                                                                         ITEM_ATTRIBUTE_FORMAT)
                                                  values
                                                        (                o_RETURN_ATTRIBUTE_ID,   
                                                                         i_ITEM_ATTRIBUTE_NAME,
                                                                         i_ITEM_ATTRIBUTE_TYPE,
                                                                         i_ITEM_ATTRIBUTE_LENGTH,
                                                                         i_ITEM_ATTRIBUTE_ACTIVE,
                                                                         sysdate,
                                                                         sysdate,
                                                                         null,
                                                                         V_ITEM_ATTRIBUTE_POSITION,
                                                                         i_ITEM_ATTRIBUTE_CATEGORYID,
                                                                         I_ITEM_ATTRIBUTE_LABEL,
                                                                         I_ITEM_ATTRIBUTE_FORMAT);                  
                                                                         
    COMMIT;
      
      END IF;                                                                   
                                                                     

exception  
     when others then 
      dbms_output.put_line('Error on creation of Item_attribute_master record ');
      dbms_output.put_line('Error message'||sqlerrm);  
  RAISE;
end create_new_item_attribute;


PROCEDURE CREATE_INSTEAD_OF_TRIGGER
AS

   v_large_iF_beg           varchar2(32000); 
   v_large_if_mid           clob:=null;
   v_large_if_end           varchar2(32000):= NULL; 
   v_large_if_statement     clob  :=null;
   v_length_cnt number:=0;

begin


  
v_large_iF_beg  := q'{create or replace TRIGGER item_info_instead_trg222 }'||chr(10);
V_large_if_beg := v_large_if_beg ||q'{INSTEAD OF INSERT OR UPDATE ON ITEM_INFO}'||CHR(10);
V_large_if_beg := v_large_if_beg ||q'{for each row declare}'||CHR(10);
V_large_if_beg := v_large_if_beg ||q'{             v_item_iteminfoid      item_info_detail.iteminfoid%type :=NULL;}'||chr(10);
V_large_if_beg := v_large_if_beg ||q'{             rowAuditUID NUMBER; }'||CHR(10);
V_large_if_beg := v_large_if_beg ||q'{             columnAuditUID NUMBER; }'||CHR(10);
V_large_if_beg := v_large_if_beg ||q'{ }'||CHR(10);
V_large_if_beg := v_large_if_beg ||q'{ }'||CHR(10);
V_large_if_beg := v_large_if_beg ||q'{BEGIN}'||chr(10); 
V_large_if_beg := v_large_if_beg ||q'{ IF INSERTING THEN}'||CHR(10);
V_large_if_beg := v_large_if_beg ||q'{     IF :NEW.ItemInfoId IS NULL OR :NEW.ItemInfoId < 0 THEN}'||CHR(10);
V_large_if_beg := v_large_if_beg ||q'{            SELECT ITEM_SEQUENCE.NEXTVAL INTO Item_info_CONVERSION.item_info_tab(1).ItemInfoId FROM DUAL;}'||CHR(10);
V_large_if_beg := v_large_if_beg ||q'{     END IF;}'||CHR(10);
V_large_if_beg := v_large_if_beg ||q'{              v_item_iteminfoid := Item_info_CONVERSION.item_info_tab(1).ItemInfoId;}'||CHR(10);
V_large_if_beg := v_large_if_beg ||q'{ }'||CHR(10);
V_large_if_beg := v_large_if_beg ||q'{              Item_info_CONVERSION.item_master_tab(1).ITEMINFOID  := v_item_iteminfoid;}'||CHR(10);
V_large_if_beg := v_large_if_beg ||q'{              Item_info_CONVERSION.item_master_tab(1).COMPANYID := :NEW.COMPANYID;}'||CHR(10);
V_large_if_beg := v_large_if_beg ||q'{              Item_info_CONVERSION.item_master_tab(1).ISXREF:= :NEW.ISXREF;}'||CHR(10);
V_large_if_beg := v_large_if_beg ||q'{              Item_info_CONVERSION.item_master_tab(1).ISVALID:=:NEW.ISVALID ;}'||CHR(10);
V_large_if_beg := v_large_if_beg ||q'{              Item_info_CONVERSION.item_master_tab(1).ROW_VERSION:= :NEW.ROW_VERSION;}'||CHR(10);
V_large_if_beg := v_large_if_beg ||q'{              Item_info_CONVERSION.item_master_tab(1).HASHCOL:=:NEW.HASHCOL;}'||CHR(10);
V_large_if_beg := v_large_if_beg ||q'{              Item_info_CONVERSION.item_master_tab(1).MODIFIED_BY:= :NEW.MODIFIED_BY;}'||CHR(10);
V_large_if_beg := v_large_if_beg ||q'{              Item_info_CONVERSION.item_master_tab(1).modified_date:=SYSDATE;}'||CHR(10);
V_large_if_beg := v_large_if_beg ||q'{              Item_info_CONVERSION.item_master_tab(1).MODIFIED_BY_SVC:=:NEW.MODIFIED_BY_SVC;}'||CHR(10);
V_large_if_beg := v_large_if_beg ||q'{              Item_info_CONVERSION.item_master_tab(1).ITEMTIMESTAMP:=SYSDATE;}'||CHR(10);
V_large_if_beg := v_large_if_beg ||q'{              Item_info_CONVERSION.item_master_tab(1).CREATEDDATE:=SYSDATE;}'||CHR(10);
V_large_if_beg := v_large_if_beg ||q'{              Item_info_CONVERSION.item_master_tab(1).UPC:=:NEW.UPC;}'||CHR(10);
V_large_if_beg := v_large_if_beg ||q'{              Item_info_CONVERSION.item_master_tab(1).GTIN:=:NEW.GTIN ;}'||CHR(10);
V_large_if_beg := v_large_if_beg ||q'{              Item_info_CONVERSION.item_master_tab(1).EAN:=:NEW.EAN;}'||CHR(10);
V_large_if_beg := v_large_if_beg ||q'{              Item_info_CONVERSION.item_master_tab(1).PARTNUMBER:=:NEW.PARTNUMBER;}'||CHR(10);
V_large_if_beg := v_large_if_beg ||q'{              Item_info_CONVERSION.item_master_tab(1).ISBN:=:NEW.ISBN;}'||CHR(10);
V_large_if_beg := v_large_if_beg ||q'{              Item_info_CONVERSION.item_master_tab(1).isactive:= :NEW.ISACTIVE ;}'||CHR(10);
V_large_if_beg := v_large_if_beg ||q'{              Item_info_CONVERSION.CREATE_ITEM_HEADER;}'||CHR(10);
V_large_if_beg := v_large_if_beg ||q'{              Item_info_CONVERSION.item_master_tab.DELETE;}'||CHR(10);
V_large_if_beg := v_large_if_beg ||q'{ ELSE }'||CHR(10);
V_large_if_beg := v_large_if_beg ||q'{              rowAuditUID := AUDITING.createRowTracking('ITEM_INFO_MASTER',:NEW.MODIFIED_BY,:NEW.MODIFIED_DATE,:NEW.MODIFIED_BY_SVC,:NEW.ITEMINFOID,:OLD.ROW_VERSION,:NEW.ROW_VERSION);}'||CHR(10);
V_large_if_beg := v_large_if_beg ||q'{END IF;}';
V_large_if_beg := v_large_if_beg ||q'{ }'||CHR(10);
V_large_if_beg := v_large_if_beg ||q'{ }'||CHR(10);                           
                               
--DBMS_OUTPUT.PUT_LINE(V_large_if_beg);
	
for v_if_main in (select '         IF  :new.'||ITEM_ATTRIBUTE_name||' IS NOT NULL THEN'||chr(10)||'             Item_info_CONVERSION.item_info_tab(1).'||ITEM_ATTRIBUTE_name||' := :new.'||ITEM_ATTRIBUTE_name||';'||chr(10)||'         END IF;' V_TRIGGER_NEW
                             from ITEM_ATTRIBUTE_MASTER 
                              ORDER BY ITEM_ATTRIBUTE_POSITION) LOOP
							      
                            v_length_cnt := v_length_cnt+length(v_if_main.v_TRIGGER_NEW);
                            v_large_if_mid := v_large_if_mid||chr(10) || v_if_main.v_TRIGGER_NEW;
				   
END LOOP;				   
         
                  
v_large_if_end := q'{ IF INSERTING THEN }'||CHR(10);
v_large_if_end := v_large_if_end|| q'{        Item_Info_Validation_Proc(1);}'||CHR(10);
v_large_if_end := v_large_if_end|| q'{        item_info_conversion.create_item_info_child; }'||chr(10);
v_large_if_end := v_large_if_end|| q'{        Item_info_conversion.item_info_create_orig;}'||CHR(10);
v_large_if_end := v_large_if_end|| q'{ ELSIF UPDATING	 THEN }'||CHR(10);
v_large_if_end := v_large_if_end|| q'{  }'||CHR(10); 
v_large_if_end := v_large_if_end|| q'{   IF rowAuditUID IS NOT NULL THEN}'||CHR(10);
v_large_if_end := v_large_if_end|| q'{      Item_info_CONVERSION.item_info_tab(1).ROW_VERSION := :OLD.ROW_VERSION + 1;}'||CHR(10);
v_large_if_end := v_large_if_end|| q'{      Item_info_CONVERSION.item_info_tab(1).MODIFIED_BY := 'SYSTEM';}'||CHR(10);
v_large_if_end := v_large_if_end|| q'{      Item_info_CONVERSION.item_info_tab(1).MODIFIED_BY_SVC := 'SYSTEM'; }'||CHR(10);
v_large_if_end := v_large_if_end|| q'{      Item_info_CONVERSION.item_info_tab(1).MODIFIED_DATE := SYSDATE;}'||CHR(10);
v_large_if_end := v_large_if_end|| q'{   END IF; }'||CHR(10);   
v_large_if_end := v_large_if_end|| q'{      Item_info_CONVERSION.UPDATE_ITEM_INFO_DETAIL(:old.iteminfoid,rowAuditUID);}'||CHR(10);
v_large_if_end := v_large_if_end|| q'{ END IF;		 }'||CHR(10); 
v_large_if_end := v_large_if_end|| q'{      Item_info_CONVERSION.item_info_tab.delete; }'||chr(10);             
v_large_if_end := v_large_if_end|| q'{ END;}';
-- DBMS_OUTPUT.PUT_LINE(v_large_if_end);
			   v_large_if_statement :=v_large_if_beg ||v_large_if_mid||chr(10) ||v_large_if_end;
        execute immediate v_large_if_statement;
    
   --   DBMS_OUTPUT.PUT_LINE('v_large_if_statement = ' ||v_large_if_statement);
    
    if ( v_large_if_statement is not null )   then
      if DBMS_LOB.ISOPEN ( v_large_if_statement) <> 0 then 
        dbms_lob.close( v_large_if_statement );
       end if; 
   
       if DBMS_LOB.ISOPEN ( v_large_if_mid)  <> 0 then
          dbms_lob.close( v_large_if_mid );
      end if;
     dbms_lob.freeTemporary( v_large_if_mid );
     dbms_lob.freeTemporary( v_large_if_statement );
  end if; 
 END CREATE_INSTEAD_OF_TRIGGER;  
 
PROCEDURE create_item_info_view
AS
v_column_name1 varchar2(32000) :=null;
 SQL_STMENT VARCHAR2(32000);
 v_length number := 0;
 
PRAGMA AUTONOMOUS_TRANSACTION;
 BEGIN


     for v_main in ( select ''''||item_attribute_name||''''||' as '||item_attribute_name||',' NAME from item_attribute_master where item_attribute_name not in('ITEMINFOID',
           'COMPANYID','ISXREF','ISVALID','ROW_VERSION','HASHCOL','MODIFIED_BY','MODIFIED_DATE','MODIFIED_BY_SVC',
           'ITEMTIMESTAMP','CREATEDDATE','UPC','GTIN','EAN','PARTNUMBER','ISBN','ISACTIVE') order by item_attribute_position) loop

           v_column_name1:= v_column_name1||v_main.name;

     end loop;
     v_length := length(v_column_name1);

      v_column_name1 := substr(v_column_name1,1,(v_length-1));


SQL_STMENT := q'[CREATE OR REPLACE VIEW ITEM_INFO AS  (select * from (
        select iid.iteminfoid iteminfoid,
          iim.COMPANYID,
          iim.ISXREF,
          iim.ISVALID,
          iim.ROW_VERSION,
          iim.HASHCOL,
          iim.MODIFIED_BY,
          iim.MODIFIED_DATE,
          iim.MODIFIED_BY_SVC,
          iim.ITEMTIMESTAMP,
          iim.CREATEDDATE,
          iim.UPC,
          iim.GTIN,
          iim.EAN,
          iim.PARTNUMBER,
          iim.ISBN,
          iim.ISACTIVE,
          iam.item_attribute_name  itemname,
          iid.item_attribute_value itemvalue         
      from
            item_info_detail iid,
            item_attribute_master iam ,
           item_info_master iim
     where 
           iim.iteminfoid = iid.ITEMINFOID
     and 
           iid.item_attribute_id = iam.item_attribute_id )
pivot(max(itemvalue) for ITEMNAME in (]'|| v_column_name1||')))';



--DBMS_OUTPUT.PUT_LINE (SQL_STMENT);

 EXECUTE IMMEDIATE SQL_STMENT; 


  --  create_if_statement;
  --  CREATE_INSTEAD_OF_TRIGGER;



 exception 
   when others then
    dbms_output.put_line('Error in creating ITEM_INFO view');
    dbms_output.put_line(SQLERRM);
    RAISE;
 END create_item_info_view ;

PROCEDURE ALTER_ORIGINAL_ITEM_INFO
AS

--V_ALTER_STMT   VARCHAR2(32000) := 'ALTER TABLE ITEM_INFO_TMPG ADD (';
V_ALTER_STMT   VARCHAR2(32000) := 'ALTER TABLE ITEM_INFO_ORIG ADD (';

V_COLUMN_LIST  VARCHAR2(32000) := null;

CURSOR c_MAIN IS select DECODE(ITEM_ATTRIBUTE_type,'DATE', ITEM_ATTRIBUTE_name ||' '||ITEM_ATTRIBUTE_type||',',
                        DECODE(ITEM_ATTRIBUTE_type,'FLOAT', ITEM_ATTRIBUTE_NAME ||' '||ITEM_ATTRIBUTE_type||',',DECODE(ITEM_ATTRIBUTE_type,'TIMESTAMP(6)', ITEM_ATTRIBUTE_NAME ||' DATE,',
                        ITEM_ATTRIBUTE_NAME||' '||ITEM_ATTRIBUTE_TYPE||'('||ITEM_ATTRIBUTE_length||'),'))) att_desc
                        from ITEM_ATTRIBUTE_MASTER
             MINUS
                 SELECT  DECODE(data_type,'DATE', column_name ||' '||data_type||',',
                        DECODE(data_type,'FLOAT', column_name ||' '||data_type||',',DECODE(data_type,'TIMESTAMP(6)', column_name ||' DATE,',
                        column_name||' '||data_type||'('||data_length||'),'))) ATT_DESC
                        from all_tab_columns where table_name = 'ITEM_INFO_ORIG'  ; 

BEGIN
      
    for v_main in c_main loop
         V_COLUMN_LIST := V_COLUMN_LIST||v_main.att_desc;
    end loop;
    
   IF v_column_list IS NOT NULL THEN   
     v_column_list := substr(v_column_list, 1,(length(v_column_list)-1))||')'; 
     V_ALTER_STMT := V_ALTER_STMT||v_column_list;
     execute immediate  V_ALTER_STMT;
    END IF;
    
END ALTER_ORIGINAL_ITEM_INFO ;

 PROCEDURE REBUILD_ITEM_INFO_OBJECTS
 AS 
     SQL_STMENT varchar2(32000);
PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN

      create_item_info_view;
    
       SQL_STMENT := 'alter package item_info_conversion compile SPECIFICATION';
       EXECUTE IMMEDIATE SQL_STMENT;
 
       SQL_STMENT := 'alter package item_info_conversion compile BODY';
       EXECUTE IMMEDIATE SQL_STMENT;
      
       Create_Item_Validation_Stmt;
       CREATE_INSTEAD_OF_TRIGGER; 
       ALTER_ORIGINAL_ITEM_INFO;
 
 END REBUILD_ITEM_INFO_OBJECTS;

FUNCTION GET_ITEM_ATTRIBUTE_ID (i_item_attribute_name in item_attribute_master.item_attribute_name%type)
 
   return number
   is 

            o_item_attribute_id item_attribute_master.ITEM_ATTRIBUTE_ID%type;

   begin
   
             begin
                 select ITEM_ATTRIBUTE_ID into o_item_attribute_id  from item_attribute_master where item_attribute_name = upper(i_item_attribute_name);
             exception 
                 when no_data_found then
                      o_item_attribute_id := 0 ;
             end;

    return(o_item_attribute_id);

   end GET_ITEM_ATTRIBUTE_ID; 
 
END ITEM_INFO_UTILITIES;