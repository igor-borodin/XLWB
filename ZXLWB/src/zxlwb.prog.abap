*&---------------------------------------------------------------------*
*& Report  ZXLWB
*&
*=======================================================================
*=======================================================================
* Copyright 2016 Igor Borodin
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*     http://www.apache.org/licenses/LICENSE-2.0
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*=======================================================================
*=======================================================================
*
* XLSX-Workbench(XLWB) components                         [Version 4.00]
* Documentation is available at:
*                             https://sites.google.com/site/sapxlwb/home
*=======================================================================
* Forms design tool starter
*=======================================================================

REPORT  zxlwb .

*======================================================================
*======================================================================
* D A T A    D E C L A R A T I O N
*======================================================================
*======================================================================
TYPE-POOLS:
  icon ,
  abap .
TABLES:
  sscrfields .
DATA:
  gv_action         TYPE sy-ucomm ,
  gs_dynpread       TYPE dynpread ,
  gt_dynpread       TYPE STANDARD TABLE OF dynpread ,
  gv_repid          TYPE syrepid VALUE sy-repid .

INCLUDE zxlwb_include .


*======================================================================
*======================================================================
* S E L E C T I O N   S C R E E N
*======================================================================
*======================================================================
SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME TITLE cm_ttl  .

SELECTION-SCREEN BEGIN OF LINE .
SELECTION-SCREEN COMMENT 1(23) cm_form FOR FIELD pv_form .
PARAMETERS pv_form TYPE lvc_fname MEMORY ID zxlwb_formname .
SELECTION-SCREEN END   OF LINE .

SELECTION-SCREEN SKIP .

SELECTION-SCREEN BEGIN OF LINE .
SELECTION-SCREEN PUSHBUTTON  1(13) import USER-COMMAND import .
SELECTION-SCREEN PUSHBUTTON 25(20) edit   USER-COMMAND edit .
SELECTION-SCREEN END   OF LINE .

SELECTION-SCREEN BEGIN OF LINE .
SELECTION-SCREEN PUSHBUTTON  1(13) export USER-COMMAND export .
SELECTION-SCREEN PUSHBUTTON 25(20) create USER-COMMAND create .
SELECTION-SCREEN PUSHBUTTON 47(8)  crea_t USER-COMMAND crea_t .
SELECTION-SCREEN END   OF LINE .

SELECTION-SCREEN BEGIN OF LINE .
SELECTION-SCREEN PUSHBUTTON  1(13) preset USER-COMMAND preset .
SELECTION-SCREEN PUSHBUTTON 25(20) copy   USER-COMMAND copy .
SELECTION-SCREEN END   OF LINE .

SELECTION-SCREEN BEGIN OF LINE .
SELECTION-SCREEN PUSHBUTTON  1(13) help   USER-COMMAND help .
SELECTION-SCREEN PUSHBUTTON 25(20) delete USER-COMMAND delete .
SELECTION-SCREEN END   OF LINE .

SELECTION-SCREEN END   OF BLOCK bl1 .



*======================================================================
*======================================================================
* E V E N T S
*======================================================================
*======================================================================

*======================================================================
INITIALIZATION .
*======================================================================
  cm_ttl  = lcl_workbench=>v_title .
  cm_form = lcl_workbench=>v_text-t219 .                              " text: Form name
  CONCATENATE:
  icon_change               lcl_workbench=>v_text-t114  INTO edit   , " text: Edit
  icon_create               lcl_workbench=>v_text-t115  INTO create , " text: Create
  icon_linked_document      lcl_workbench=>v_text-t116  INTO crea_t , " text: Tmpl.
  icon_copy_object          lcl_workbench=>v_text-t117  INTO copy   , " text: Copy
  icon_delete               lcl_workbench=>v_text-t118  INTO delete , " text: Delete
  icon_import               lcl_workbench=>v_text-t210  INTO import , " text: Import
  icon_export               lcl_workbench=>v_text-t211  INTO export , " text: Export
  icon_system_extended_help lcl_workbench=>v_text-t212  INTO help   , " text: Help
  icon_tools                lcl_workbench=>v_text-t206  INTO preset . " text: Presets

  DATA  gt_exclude TYPE TABLE OF sy-ucomm.
  CLEAR gt_exclude[] .
  APPEND  'ONLI' TO gt_exclude.
  APPEND  'PRIN' TO gt_exclude.
  APPEND  'SPOS' TO gt_exclude.
  APPEND  'NONE' TO gt_exclude.
  CALL FUNCTION 'RS_SET_SELSCREEN_STATUS'
    EXPORTING
      p_status  = space
    TABLES
      p_exclude = gt_exclude.

  CALL FUNCTION 'SAPGUI_SET_FUNCTIONCODE'
    EXCEPTIONS
      OTHERS = 0.


*======================================================================
AT SELECTION-SCREEN OUTPUT .
*======================================================================
  LOOP AT SCREEN .
    IF  screen-name EQ 'CREA_T'
    AND lcl_workbench=>s_presets_dt-popup_im IS INITIAL .
      screen-active = 0 .
      MODIFY SCREEN .
    ENDIF .
  ENDLOOP .


*======================================================================
AT SELECTION-SCREEN .
*======================================================================
  CHECK sy-ucomm IS NOT INITIAL .

  CASE sy-ucomm .
    WHEN 'EDIT'   . gv_action = lcl_workbench=>c_action-edit .
    WHEN 'CREA'   . gv_action = lcl_workbench=>c_action-create .
    WHEN 'CREATE' . gv_action = lcl_workbench=>c_action-create .
    WHEN 'CREA_T' . gv_action = lcl_workbench=>c_action-crea_t .
    WHEN 'COPY'   . gv_action = lcl_workbench=>c_action-copy .
    WHEN 'DELETE' . gv_action = lcl_workbench=>c_action-delete .
    WHEN 'IMPORT' . gv_action = lcl_workbench=>c_action-import .
    WHEN 'EXPORT' . gv_action = lcl_workbench=>c_action-export .
    WHEN 'HELP'   . gv_action = lcl_workbench=>c_action-help .
    WHEN 'PRESET' . gv_action = lcl_workbench=>c_action-preset .
    WHEN 'PRESE2' . gv_action = lcl_workbench=>c_action-prese2 .
    WHEN OTHERS   . EXIT .
  ENDCASE .

  CALL FUNCTION 'ZXLWB_WORKBENCH'
    EXPORTING
      iv_formname        = pv_form
      iv_action          = gv_action
    EXCEPTIONS
      process_terminated = 1
      OTHERS             = 2.
  IF sy-subrc NE 0 .
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 .
  ENDIF .


*======================================================================
AT SELECTION-SCREEN ON VALUE-REQUEST FOR pv_form .
*======================================================================
  CLEAR gt_dynpread .
  CLEAR gs_dynpread .
  gs_dynpread-fieldname = 'PV_FORM' .
  APPEND gs_dynpread TO gt_dynpread .

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      dyname     = sy-repid
      dynumb     = sy-dynnr
    TABLES
      dynpfields = gt_dynpread
    EXCEPTIONS
      OTHERS     = 8.
  CHECK sy-subrc EQ 0.
  READ TABLE gt_dynpread INTO gs_dynpread INDEX 1 .
  CHECK sy-subrc EQ 0 .
  CATCH SYSTEM-EXCEPTIONS OTHERS = 0 .
    pv_form = gs_dynpread-fieldvalue .
  ENDCATCH .

  lcl_workbench=>popup_formname_f4( CHANGING cv_formname = pv_form ) .
