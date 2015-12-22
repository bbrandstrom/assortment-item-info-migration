REM*******************************************************************************************************************
REM***    File Name     :   Item_info_Conversion.pks
REM***
REM***    Purpose       :  This file contains the source code for Item_Info_Conversion Package Specification 
REM***                      Package spec declares several Global Pl/SQL tables.
REM***
REM***    Creation  Date:  12-01-2015 
REM***
REM***
REM***    Author        :   Brett Brandstrom Sr.Oracle Developer/Analysist
REM***                      Brandstrom Consulting Services
REM***
REM***
REM********************************************************************************************************************
Create or replace package ITEM_INFO_CONVERSION as

PROCEDURE ITEM_INFO_CONVERSION;

PROCEDURE CREATE_ITEM_INFO_CHILD;

procedure CREATE_ITEM_HEADER;
         
function GET_ITEM_ATTRIBUTE_ID (i_item_attribute_name in item_attribute_master.item_attribute_name%type)   return number;
        

 
FUNCTION VALUE_DOES_EXISTS (I_ITEMINFOID IN ITEM_INFO_DETAIL.ITEMINFOID%TYPE , I_ITEM_ATTRIBUTE_ID IN ITEM_INFO_DETAIL.ITEM_ATTRIBUTE_ID%TYPE)    RETURN NUMBER;
     
procedure UPDATE_ITEM_INFO_DETAIL(I_ITEMINFOID IN ITEM_INFO_MASTER.ITEMINFOID%TYPE,I_rowAuditUID in number) ;

PROCEDURE ITEM_INFO_CREATE_ORIG;

     TYPE t_columns IS RECORD (u_column_name  VARCHAR2(32),u_column_value VARCHAR2(4000),u_old_column_value VARCHAR2(4000));
     TYPE T_COLUMN IS TABLE OF t_columns INDEX BY BINARY_INTEGER;
     V_COLUMNS_TAB           T_COLUMN;

     TYPE V_rec_type IS TABLE OF item_info%ROWTYPE INDEX BY BINARY_INTEGER;
     item_info_tab      v_rec_type;
     item_info_tab_null v_rec_type;
     
     TYPE V_item_master IS TABLE OF item_info_master%ROWTYPE INDEX BY BINARY_INTEGER;
	   item_master_tab v_item_master;
	 
      
	 TYPE V_item_detail IS TABLE OF item_info_detail%ROWTYPE INDEX BY BINARY_INTEGER;
	  item_detail_tab v_item_detail;
	 
      
     NO_INSERT EXCEPTION;
     INDX NUMBER;
    
end ITEM_INFO_CONVERSION;