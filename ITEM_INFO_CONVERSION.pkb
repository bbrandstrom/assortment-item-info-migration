REM*******************************************************************************************************************
REM***    File Name     :   Item_info_Conversion.pkb
REM***
REM***    Purpose       :  This file contains the source code for Item_Info_Conversion Package Body 
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
Create or replace package body ITEM_INFO_CONVERSION as

PROCEDURE ITEM_INFO_CONVERSION
AS 

       V_ITEM_ATTRIBUTE_ID    ITEM_INFO_DETAIL.ITEM_ATTRIBUTE_ID%TYPE :=NULL;
       V_ITEM_ITEMINFOID      ITEM_INFO_DETAIL.ITEMINFOID%TYPE :=NULL;
       V_ITEM_attribute_name  ITEM_ATTRIBUTE_MASTER.ITEM_attribute_name%TYPE :=NULL;
       V_ITEM_ATTRIBUTE_VALUE ITEM_INFO_DETAIL.ITEM_ATTRIBUTE_VALUE%TYPE :=NULL;


V_INSERT_SUCCESS   NUMBER:=0; 
v_sql_statement    varchar2(32000);
v_masterTab_idx    number:= 0;
v_loop_cnt         number :=0;
 limit_in number := 150000;
V_START_TIME TIMESTAMP ;
V_END_TIME  TIMESTAMP; 

cursor c_main is SELECT * FROM item_info;     --iteminfoid not in (select iteminfoid from item_info_master);



BEGIN
SELECT LOCALTIMESTAMP INTO V_START_TIME FROM DUAL;

          ITEM_INFO_UTILITIES.Create_Item_Validation_Stmt;         
         
         
           item_info_tab.DELETE;
           item_master_tab.DELETE;
		   item_detail_tab.DELETE;              
       
        
     OPEN c_main;
    LOOP
        FETCH c_main 
            BULK COLLECT INTO item_info_tab LIMIT limit_in;
            
        if item_info_tab.count > 0 then          
	             FOR indx IN item_info_tab.first .. item_info_tab.last LOOP 
                 v_loop_cnt := v_loop_cnt+1;
				                       v_masterTab_idx := item_master_tab.count+1;
                                       item_master_tab(v_masterTab_idx).ITEMINFOID      := item_info_tab(indx).ITEMINFOID ;
                                       item_master_tab(v_masterTab_idx).COMPANYID       := item_info_tab(indx).COMPANYID;
                                       item_master_tab(v_masterTab_idx).ISXREF          := item_info_tab(indx).ISXREF;
                                       item_master_tab(v_masterTab_idx).ISVALID         := item_info_tab(indx).ISVALID ;
                                       item_master_tab(v_masterTab_idx).ROW_VERSION     := item_info_tab(indx).ROW_VERSION;
                                       item_master_tab(v_masterTab_idx).HASHCOL         := item_info_tab(indx).HASHCOL;
                                       item_master_tab(v_masterTab_idx).MODIFIED_BY     := item_info_tab(indx).MODIFIED_BY ;
                                       item_master_tab(v_masterTab_idx).modified_date   := item_info_tab(indx).modified_date ;
                                       item_master_tab(v_masterTab_idx).MODIFIED_BY_SVC := item_info_tab(indx).MODIFIED_BY_SVC ;
                                       item_master_tab(v_masterTab_idx).ITEMTIMESTAMP   := item_info_tab(indx).ITEMTIMESTAMP ;
                                       item_master_tab(v_masterTab_idx).CREATEDDATE     := item_info_tab(indx).CREATEDDATE;
                                       item_master_tab(v_masterTab_idx).UPC             := item_info_tab(indx).UPC  ;
                                       item_master_tab(v_masterTab_idx).GTIN            := item_info_tab(indx).GTIN  ;
                                       item_master_tab(v_masterTab_idx).EAN             := item_info_tab(indx).EAN;
                                       item_master_tab(v_masterTab_idx).PARTNUMBER      := item_info_tab(indx).PARTNUMBER ;
                                       item_master_tab(v_masterTab_idx).ISBN            := item_info_tab(indx).ISBN ;
                                       item_master_tab(v_masterTab_idx).isactive        := item_info_tab(indx).isactive;
             
                           if mod(item_master_tab.count,20000) = 0 then
                                  CREATE_ITEM_HEADER;
                                  item_master_tab.DELETE;     -- clear data from collection after writing to the table
			                     end if;
                   
                           Item_Info_Validation_Proc(indx); -- create the item_detail_tab record   
                       
			             if mod(item_detail_tab.count,20000) = 0 then
                            create_item_info_child;
                            item_detail_tab.DELETE;       -- clear data from collection after writing to the table
			             end if;
                
                if mod(v_loop_cnt,500000) = 0 then
                   commit;
                end if;   
	   
            END LOOP;
        end if;
     
       EXIT WHEN item_info_tab.COUNT < limit_in;

   END LOOP;

   CLOSE c_main;
                                       -- write any remaining data to the tables 
     CREATE_ITEM_HEADER;                              
     create_item_info_child;
     commit;
    
         SELECT LOCALTIMESTAMP INTO V_END_TIME FROM DUAL;
    
        DBMS_OUTPUT.PUT_LINE('Total HEADER records PROCESSED = '||v_loop_cnt);
        DBMS_OUTPUT.PUT_LINE('START TIME '||V_START_TIME);
        DBMS_OUTPUT.PUT_LINE('END TIME   '||V_END_TIME);
 
 
 -- try to free any memory by clearing PL/SQL table in memory
   item_info_tab.DELETE;
   item_detail_tab.DELETE;
   item_master_tab.DELETE;
   dbms_session.free_unused_user_memory ;
EXCEPTION 
   WHEN NO_INSERT THEN
      DBMS_OUTPUT.PUT_LINE('NO_INSERT ERROR');
      item_info_tab.DELETE;
      dbms_session.free_unused_user_memory ;
      RAISE;
   WHEN OTHERS THEN
      dbms_output.put_line('error in main proc of conversion');
      DBMS_OUTPUT.PUT_LINE('OTHERES ERROR '|| SQLERRM);
      item_info_tab.DELETE;
      dbms_session.free_unused_user_memory ;
      RAISE;
END ITEM_INFO_CONVERSION ;


PROCEDURE CREATE_ITEM_INFO_CHILD 
                                 
AS

BEGIN
        if item_detail_tab.count > 0 then         

              forall i in item_detail_tab.first .. item_detail_tab.last 
                                         INSERT INTO ITEM_INFO_DETAIL 
                                                                     (ITEMINFOID,
                                                                      ITEM_ATTRIBUTE_VALUE,
                                                                      ITEM_ATTRIBUTE_ID,
                                                                      createddate,
                                                                      modified_date
                                                                      )
                                         VALUES
                                                                      (item_detail_tab(i).ITEMINFOID,
                                                                       item_detail_tab(i).ITEM_ATTRIBUTE_VALUE,
                                                                       item_detail_tab(i).ITEM_ATTRIBUTE_ID,
                                                                       SYSDATE,
                                                                       SYSDATE);
            
        end if;


EXCEPTION
 WHEN OTHERS THEN
   dbms_output.put_line('Error in create_detail :');
   dbms_output.put_line(sqlerrm); 
   RAISE;
END;

procedure CREATE_ITEM_HEADER
as

BEGIN

if item_master_tab.count > 0 then
           FORALL indx IN  item_master_tab.FIRST .. item_master_tab.LAST 
                       INSERT INTO ITEM_INFO_MASTER 
                                                 (ITEMINFOID,
                                                  COMPANYID,
                                                  ISXREF,
                                                  ISVALID,
                                                  ROW_VERSION,
                                                  HASHCOL,
                                                  MODIFIED_BY,
                                                  modified_date,
                                                  MODIFIED_BY_SVC,
                                                  ITEMTIMESTAMP,
                                                  CREATEDDATE,
                                                  UPC,
                                                  GTIN,
                                                  EAN,
                                                  PARTNUMBER,
                                                  ISBN,
                                                  ISACTIVE)
                           VALUES
                                                 ( item_master_tab(indx).ITEMINFOID,
                                                   item_master_tab(indx).COMPANYID,
                                                   item_master_tab(indx).ISXREF,
                                                   item_master_tab(indx).ISVALID,
                                                   item_master_tab(indx).ROW_VERSION,
                                                   item_master_tab(indx).HASHCOL,
                                                   item_master_tab(indx).MODIFIED_BY,
                                                   item_master_tab(indx).modified_date,
                                                   item_master_tab(indx).MODIFIED_BY_SVC,
                                                   item_master_tab(indx).ITEMTIMESTAMP,
                                                   item_master_tab(indx).CREATEDDATE,
                                                   item_master_tab(indx).UPC,
                                                   item_master_tab(indx).GTIN,
                                                   item_master_tab(indx).EAN,
                                                   item_master_tab(indx).PARTNUMBER,
                                                   item_master_tab(indx).ISBN,
                                                   item_master_tab(indx).isactive);
end if;

EXCEPTION 
   WHEN OTHERS THEN
   dbms_output.put_line('Error in create_header :');
   dbms_output.put_line(sqlerrm); 
 RAISE;
END;

FUNCTION GET_ITEM_ATTRIBUTE_ID (i_item_attribute_name in item_attribute_master.item_attribute_name%type)
 
   RETURN number
IS 

            o_item_attribute_id item_attribute_master.ITEM_ATTRIBUTE_ID%type;

BEGIN
   
             BEGIN
                 select ITEM_ATTRIBUTE_ID into o_item_attribute_id  from item_attribute_master where item_attribute_name = upper(i_item_attribute_name);
             EXCEPTION 
                 when no_data_found then
                      o_item_attribute_id := 0 ;
             END;

    RETURN(o_item_attribute_id);

END GET_ITEM_ATTRIBUTE_ID; 


FUNCTION VALUE_DOES_EXISTS (i_iteminfoid IN ITEM_INFO_DETAIL.ITEMINFOID%TYPE , 
                            i_item_attribute_id IN ITEM_INFO_DETAIL.ITEM_ATTRIBUTE_ID%TYPE)
RETURN NUMBER

IS

O_RETURN_VALUE   NUMBER;

BEGIN
    SELECT COUNT(*) INTO O_RETURN_VALUE 
	FROM ITEM_INFO_DETAIL 
	WHERE ITEMINFOID = i_iteminfoid  
	AND ITEM_ATTRIBUTE_ID = i_item_attribute_id; 

	RETURN(O_RETURN_VALUE);
	
END VALUE_DOES_EXISTS;

PROCEDURE UPDATE_ITEM_INFO_DETAIL(i_iteminfoid IN ITEM_INFO_MASTER.ITEMINFOID%TYPE,I_rowAuditUID in number) 
as



  v_upd_st_set        VARCHAR2(32000);
  v_upd_st_and        VARCHAR2(32000);
  v_upd_hdr_bdy       VARCHAR2(32000);
  v_upd_header        VARCHAR2(32000);
  v_hdr_upd           NUMBER :=0;
  v_item_attribute_id NUMBER ;
  v_iteminfoid        NUMBER;
  v_length_to_pull    NUMBER;
  sql_text            VARCHAR2(32000);
  v_set_pos           NUMBER :=0;
  v_where_pos         NUMBER :=0;
  v_columns           VARCHAR2(32000);
  v_pos1              NUMBER := 1;
  v_pos2              NUMBER :=1;
  v_comma_pos         NUMBER :=0;
  index_cnt           NUMBER :=0;
  v_end_loop          BOOLEAN := FALSE;  
  v_stmt              VARCHAR2(4000);
  
  CURSOR C_MAIN
  IS
    SELECT sql_fulltext
    FROM v$sql A
    WHERE upper(sql_fulltext) LIKE '%ITEM_INFO %'
    AND sql_text NOT LIKE '%v$sql%'
    AND command_type in  (6,47)
    ORDER BY last_active_time DESC;
  
BEGIN



  OPEN C_MAIN ;
  FETCH C_MAIN INTO sql_text;
  CLOSE C_MAIN;
  
  v_set_pos          := (INSTR(UPPER(sql_text),'SET')  +4);                  -- FIND THE LOCATION OF THE SET CLUASE
  v_where_pos        := (INSTR(UPPER(sql_text),'WHERE'));                  -- FIND THE LOCATION OF THE WHERE CLUASE
  v_length_to_pull   := v_where_pos - v_set_pos;

      v_columns   := SUBSTR(sql_text,v_set_pos,v_length_to_pull);     -- GET THE COLUMNS BETWEEN SET AND WHERE

      V_POS1      := 1;
   WHILE NOT v_end_loop   LOOP

     index_cnt   := index_cnt +1;
     V_POS2      := (INSTR(v_columns,'=',v_pos1)); 

     v_length_to_pull   :=  V_POS2 - V_POS1      ;
     v_columns_tab(index_cnt).u_column_name  := TRIM(REPLACE(REPLACE(SUBSTR(v_columns,v_pos1,v_length_to_pull),chr(13),''),chr(10),''));
     v_comma_pos := instr(v_columns,',',v_comma_pos+1);

     IF v_comma_pos = 0 THEN
        v_comma_pos := LENGTH(v_columns);
        v_end_loop := TRUE;  
     END IF;
      v_pos1 := v_comma_pos +1;

  END LOOP;
  
    v_stmt := 'BEGIN '||chr(13);
   FOR I IN v_columns_tab.FIRST .. v_columns_tab.LAST LOOP
	          v_stmt :=  v_stmt||q'{ item_info_conversion.V_COLUMNS_TAB(}'||I||q'{).u_column_value :=  Item_info_CONVERSION.item_info_tab(1).}'||V_COLUMNS_TAB(I).u_COLUMN_name||';'||chr(13);    
   END LOOP;  
    v_stmt :=  v_stmt||' end;';
    execute immediate v_stmt;

           v_iteminfoid := i_iteminfoid;

  --     dbms_output.put_line(v_iteminfoid);  

          FOR I IN v_columns_tab.FIRST .. v_columns_tab.LAST LOOP
              IF upper(v_columns_tab(I).u_column_name) IN ('ISXREF','ISVALID','ROW_VERSION','HASHCOL','MODIFIED_BY','MODIFIED_DATE','MODIFIED_BY_SVC','ITEMTIMESTAMP' ,'CREATEDDATE','UPC','GTIN','EAN','PARTNUMBER','ISBN') THEN
                 v_hdr_upd := v_hdr_upd +1;
                 v_upd_hdr_bdy := v_upd_hdr_bdy ||v_columns_tab(I).u_column_NAME||q'{ = '}'||v_columns_tab(I).u_column_value||q'{',}';
              ELSE   
                  v_item_attribute_id :=  Get_item_attribute_id(V_COLUMNS_TAB(I).u_column_name);
                  IF VALUE_DOES_EXISTS(i_iteminfoid,v_item_attribute_id) > 0 THEN
                     v_upd_st_set := q'{ UPDATE item_info_detail SET ITEM_ATTRIBUTE_VALUE  = '}'||V_COLUMNS_TAB(I).u_column_value||q'{' WHERE iteminfoid = }'||v_iteminfoid ;
                     v_upd_st_and  :=' AND ITEM_ATTRIBUTE_ID = '||v_item_attribute_id;
                     v_upd_st_set := v_upd_st_set||v_upd_st_and;                   
                     EXECUTE IMMEDIATE V_UPD_ST_SET;
                      if I_rowAuditUID is not null then
                       AUDITING.createColumnTracking(i_rowAuditUID,v_columns_tab(I).u_column_name,v_columns_tab(I).u_old_column_value,v_columns_tab(I).u_column_value);
                     end if;  
                  ELSE 
                  item_detail_tab((item_detail_tab.count+1)).ITEM_ATTRIBUTE_ID := v_item_attribute_id;
                  item_detail_tab((item_detail_tab.count)).ITEMINFOID := i_iteminfoid ;
                  item_detail_tab((item_detail_tab.count)).item_attribute_value := v_columns_tab(I).u_column_value;
                --  DBMS_OUTPUT.PUT_LINE('V_ITEMINFOID = '||V_ITEMINFOID);
                  END IF;  
              END IF;     
          END LOOP;
		    create_item_info_child;     -- write the new values to the detail table
          IF v_hdr_upd > 0 THEN
  
             v_upd_hdr_bdy := SUBSTR(v_upd_hdr_bdy,1,LENGTH(v_upd_hdr_bdy)-1);
             v_upd_header := 'UPDATE ITEM_INFO_MASTER SET '||v_upd_hdr_bdy||' WHERE iteminfoid =  '||v_iteminfoid;
            -- DBMS_OUTPUT.PUT_LINE(v_upd_header); 
           EXECUTE IMMEDIATE v_upd_header;
          END IF;
    
 
END update_item_info_detail; 

PROCEDURE ITEM_INFO_CREATE_ORIG
AS

 
  V_first_op_pren_POS    NUMBER :=0;
  V_first_cl_pren_POS    NUMBER :=0;
  V_total_LEN            NUMBER :=0;
  V_COLUMNS              VARCHAR2(32000);
  v_values               varchar2(32000);
  V_POS1                 NUMBER := 1;
  V_COMMA_POS            NUMBER :=1;
  INDEX_CNT              NUMBER :=1;
  v_end_loop             BOOLEAN :=FALSE;
  V_LENGTH_TO_PULL       NUMBER;
  sql_text               varchar2(32000); 
  sql_text_org           varchar2(32000);  
  v_stmt                 VARCHAR2(32000);

  
  
  cursor C_main is  SELECT sql_fulltext
    FROM v$sql 
    WHERE  (upper(SQL_FULLTEXT) LIKE '%ITEM_INFO(%'  or upper(SQL_FULLTEXT) LIKE '%ITEM_INFO %')
    AND sql_text NOT LIKE '%v$sql%'
  AND command_type = 2
    ORDER BY LAST_ACTIVE_TIME DESC;
    
 -- sql_text varchar2(32000) := q'[INSERT INTO ITEM_INFO_STG1 (ITEMINFOID, COMPANYID, ISXREF, ISVALID, ROW_VERSION, HASHCOL, MODIFIED_BY, MODIFIED_DATE, MODIFIED_BY_SVC,ITEMTIMESTAMP, CREATEDDATE,UPC,GTIN, EAN,PARTNUMBER, ISBN,ISACTIVE) VALUES   (NULL, 5150, 0, 1 ,7, '90F989769D84906D8D79A77DDD6CC395', 'SYSTEM',NULL , 'SYSTEM',NULL,NULL , 1234, 'ABC', '7296178567763', '80727',NULL,0)]';  
    
BEGIN  
 V_COLUMNS_TAB.delete;
OPEN C_MAIN ;
  FETCH C_MAIN INTO SQL_TEXT;
  CLOSE C_MAIN;
  -- sql_text_org := SQL_TEXT ;  
   
   V_total_LEN := length(sql_text);                              -- GET THE TOTAL LENGHT OF THE STATMENT
   V_first_op_pren_POS := instr(sql_text,'(',1);                 -- FIND THE FIRST ( POS
   V_first_cl_pren_POS := instr(sql_text,')',1);                 -- FIND THE FIRST  ) POS

  
   V_LENGTH_TO_PULL    := (V_first_cl_pren_POS - V_first_op_pren_POS+1)  ;
   V_COLUMNS := substr(sql_text,V_first_op_pren_POS,V_LENGTH_TO_PULL);  -- STRIP OFF THE COLUMNS () FROM THE STATEMENT
   
   V_LENGTH_TO_PULL    := (V_first_op_pren_POS-1)  ;
   sql_text_org := substr(SQL_TEXT,1,v_length_to_pull);
 
-- 
--     THIS SECTION PULL THE COLUMN NAMES FROM THE INSERT STATEMENT
--

  V_first_op_pren_POS := instr(v_columns,'(',1);                 -- FIND THE FIRST ( POS in V_columns
  V_first_cl_pren_POS := instr(v_columns,')',1);                 -- FIND THE FIRST  ) POS in V_columns
  V_POS1 :=V_first_op_pren_POS+1;                        -- GET THE POS TO START PULLING THE COLUMNS FIRST (

  while NOT v_end_loop  loop
         index_cnt := index_cnt+1;
         V_COMMA_POS := instr(V_COLUMNS,',',V_COMMA_POS+1);       -- FIND THE LOCATION OF THE COMMA
         if V_COMMA_POS = 0 then                                  -- IF COMMA POS = 0 YUR ON THE LAST COLUMN
            V_COMMA_POS := (V_first_cl_pren_POS); 
            v_end_loop := TRUE;                                   -- EXIT THE LOOP AFTER THIS ITERATION
         end if;   
         V_LENGTH_TO_PULL := (V_COMMA_POS - v_pos1);              -- COMMA_POS = EITHER THE NEXT COMMA OR THE CLOSING )
         V_COLUMNS_TAB(index_cnt).u_column_name := TRIM(substr(V_COLUMNS,v_pos1,V_LENGTH_TO_PULL));
                                              -- V_POS1 = EITHER THE THE LOCATION OF THE (FIRST '(' OR COMMA POS) +1 
                                              -- TRIM ALL THE SPACES OFF THE COLUMN NAME 
         v_pos1 := V_COMMA_POS+1;             -- AFTER THE FIRST ITERATION THE V_POS1 WILL = THE LOCATION OF THE COMMA +1    
  end loop;
 
               v_stmt := 'BEGIN '||chr(13);
    	FOR I IN V_COLUMNS_TAB.FIRST .. V_COLUMNS_TAB.LAST LOOP
	             v_stmt :=  v_stmt||q'{ item_info_conversion.V_COLUMNS_TAB(}'||I||q'{).u_column_value :=  Item_info_CONVERSION.item_info_tab(1).}'||V_COLUMNS_TAB(I).u_COLUMN_name||';'||chr(13);
      END LOOP;    
              v_stmt :=  v_stmt||' end;';
      EXECUTE IMMEDIATE v_stmt;

      v_columns := null;
      v_values := NULL;
FOR I IN V_COLUMNS_TAB.FIRST .. V_COLUMNS_TAB.LAST LOOP
     v_columns := v_columns||V_COLUMNS_TAB(I).u_COLUMN_name||',';
   IF V_COLUMNS_TAB(I).u_column_VALUE IS NOT NULL THEN
      v_values := v_values||q'{'}'||V_COLUMNS_TAB(I).u_column_VALUE||q'{'}'||',';
   ELSE
     v_values := v_values||'NULL,';
  END IF;
END LOOP; 
 
    v_columns := q'{(}'||SUBSTR(v_COLUMNS,1,LENGTH(V_COLUMNS)-1)||q'{)}'; 
    V_VALUES := q'{(}'||SUBSTR(v_values,1,LENGTH(V_VALUES)-1)||q'{)}'; --REMOVE THE LAST COMMA AND PUT () ON
    
    sql_text_org := q'{ INSERT INTO ITEM_INFO_ORIG }' ; 
    sql_text_org := sql_text_org ||v_columns||' values '||v_values;
    execute IMMEDIATE sql_text_org;
 
  
END ITEM_INFO_CREATE_ORIG;  

BEGIN
    IF  item_master_tab.COUNT > 1 THEN
     item_master_tab.DELETE;
    END IF;
end ITEM_INFO_CONVERSION;