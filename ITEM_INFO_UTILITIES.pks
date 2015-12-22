REM*******************************************************************************************************************
REM***    File Name     :   Item_info_utilities.pks
REM***
REM***    Purpose       :  This file contains the source code for Item_Info_utilities Package Specification 
REM***                     packages contains source code for creating dynamic SQL
REM***
REM***    Creation  Date:  12-01-2015 
REM***
REM***
REM***    Author        :   Brett Brandstrom Sr.Oracle Developer/Analysist
REM***                      Brandstrom Consulting Services
REM***
REM***
REM********************************************************************************************************************
create or replace PACKAGE ITEM_INFO_UTILITIES
AS
  PROCEDURE create_new_item_attribute(
      i_ITEM_ATTRIBUTE_NAME       IN ITEM_ATTRIBUTE_MASTER.ITEM_ATTRIBUTE_name%type ,
      i_ITEM_ATTRIBUTE_TYPE       IN ITEM_ATTRIBUTE_MASTER.ITEM_ATTRIBUTE_type%type ,
      i_ITEM_ATTRIBUTE_LENGTH     IN NUMBER,
      I_ITEM_ATTRIBUTE_LABEL      IN ITEM_ATTRIBUTE_MASTER.ITEM_ATTRIBUTE_LABEL%TYPE,
      I_ITEM_ATTRIBUTE_FORMAT     IN ITEM_ATTRIBUTE_MASTER.ITEM_ATTRIBUTE_FORMAT%TYPE,
      i_ITEM_ATTRIBUTE_ACTIVE     IN ITEM_ATTRIBUTE_MASTER.ITEM_ATTRIBUTE_ACTIVE%type,
      i_ITEM_ATTRIBUTE_CATEGORYID IN ITEM_ATTRIBUTE_MASTER.ITEM_ATTRIBUTE_CATEGORYID%type);
  
 
  PROCEDURE Create_Item_Validation_Stmt;
 
  PROCEDURE CREATE_INSTEAD_OF_TRIGGER;
 
  PROCEDURE create_item_info_view;
  
  PROCEDURE ALTER_ORIGINAL_ITEM_INFO;

  PROCEDURE REBUILD_ITEM_INFO_OBJECTS;
  
  FUNCTION GET_ITEM_ATTRIBUTE_ID (i_item_attribute_name in item_attribute_master.item_attribute_name%type)  return number;

END ITEM_INFO_UTILITIES;