FUNCTION zxlwb_callform.
*"----------------------------------------------------------------------
*"*"Локальный интерфейс:
*"  IMPORTING
*"     REFERENCE(IV_FORMNAME) TYPE  ANY
*"     REFERENCE(IV_CONTEXT_REF)
*"     VALUE(IV_VIEWER_TITLE) TYPE  ANY DEFAULT SY-TITLE
*"     REFERENCE(IV_VIEWER_INPLACE) TYPE  FLAG DEFAULT 'X'
*"     VALUE(IV_VIEWER_CALLBACK_PROG) TYPE  ANY DEFAULT SY-CPROG
*"     REFERENCE(IV_VIEWER_CALLBACK_FORM) TYPE  ANY OPTIONAL
*"     REFERENCE(IV_VIEWER_SUPPRESS) TYPE  ANY OPTIONAL
*"     REFERENCE(IV_PROTECT) TYPE  FLAG OPTIONAL
*"     REFERENCE(IV_SAVE_AS) TYPE  ANY OPTIONAL
*"     REFERENCE(IV_SAVE_AS_APPSERVER) TYPE  ANY OPTIONAL
*"     REFERENCE(IV_STARTUP_MACRO) TYPE  ANY OPTIONAL
*"     REFERENCE(IT_DOCPROPERTIES) TYPE  CKF_FIELD_VALUE_TABLE OPTIONAL
*"  EXPORTING
*"     REFERENCE(EV_DOCUMENT_RAWDATA) TYPE  MIME_DATA
*"     REFERENCE(EV_DOCUMENT_EXTENSION) TYPE  ANY
*"  EXCEPTIONS
*"      PROCESS_TERMINATED
*"----------------------------------------------------------------------
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
* XLSX-Workbench(XLWB) components                         [Version 4.06]
* Documentation is available at:
*                             https://sites.google.com/site/sapxlwb/home
*=======================================================================
* Render and display form
*=======================================================================
*
* Parameters:
*     IV_FORMNAME         -->> name of the form
*     IV_CONTEXT_REF      -->> data for the form building
*     IV_VIEWER_TITLE     -->> text, which displayed in the title bar of the Viewer
*     IV_VIEWER_INPLACE   -->> set 'X' to show Excel in modal SAP-screen,
*                              or set SPACE for floating mode
*     IV_VIEWER_CALLBACK_PROG, IV_VIEWER_CALLBACK_FORM -->>
*                         -->> subroutine to customizing Viewer (see Docum.)
*     IV_VIEWER_SUPPRESS  -->> set 'X' to do not call the Viewer
*     IV_PROTECT          -->> set 'X', if tamper protection of workbook is required
*     IV_SAVE_AS          -->> full path (including file extention),
*                              if you want to save file on the Frontend
*     IV_SAVE_AS_APPSERVER-->> full path (including file extention),
*                              if you want to save file on the Application server
*     IV_STARTUP_MACRO    -->> Only for .XLSM (not for .XLSX)
*                              macro name, which should be run directly after file creation
*                              For example: Module1.Macro1
*     IT_DOCPROPERTIES    -->> Document properties (ie Author, Company etc.)
*
*
*=======================================================================

  DATA:
    lr_formruntime        TYPE REF TO lcl_formruntime,
    lv_fullpath           TYPE string,
    lv_message            TYPE string,
    lv_document_size      TYPE i,
    lt_document_table     TYPE STANDARD TABLE OF w3mime,
    lv_document_extension TYPE lcl_formruntime=>ty_char10.

* compose document
  CREATE OBJECT lr_formruntime
    EXPORTING
      iv_formname        = iv_formname
      iv_context_ref     = iv_context_ref
      iv_protect         = iv_protect
      iv_startup_macro   = iv_startup_macro
      it_docproperties   = it_docproperties
    EXCEPTIONS
      process_terminated = 1.
  IF sy-subrc NE 0 .
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
       RAISING process_terminated .
  ENDIF .

  ev_document_rawdata   = lr_formruntime->get_rawdata( ) .
  lv_document_extension = lr_formruntime->get_extension( ) .
  ev_document_extension = lv_document_extension .

  lr_formruntime->free( ) .
  FREE lr_formruntime .

  lv_fullpath = iv_save_as .

* call viewer (if required)
  IF  iv_viewer_suppress IS INITIAL
  AND lcl_root=>is_gui_available( ) IS NOT INITIAL .

    IF gv_viewer_bundle_collect IS INITIAL .
      PERFORM viewer_bundle_refresh USING lv_fullpath .
    ENDIF .

    IF gr_viewer IS BOUND .
      gr_viewer->document_add(
          iv_document_rawdata   = ev_document_rawdata
          iv_document_extension = lv_document_extension
          iv_document_title     = iv_viewer_title
          iv_callback_prog      = iv_viewer_callback_prog
          iv_callback_form      = iv_viewer_callback_form
          iv_inplace            = iv_viewer_inplace ) .
    ENDIF .

    IF gv_viewer_bundle_collect IS INITIAL .
      PERFORM viewer_bundle_close .
    ENDIF .
  ELSE.
* download on frontend (IF required)
    IF iv_save_as IS NOT INITIAL .
      CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
        EXPORTING
          buffer        = ev_document_rawdata
        IMPORTING
          output_length = lv_document_size
        TABLES
          binary_tab    = lt_document_table.

      cl_gui_frontend_services=>gui_download(
        EXPORTING bin_filesize = lv_document_size
                  filename     = lv_fullpath
                  filetype     = 'BIN'
        CHANGING  data_tab     = lt_document_table
        EXCEPTIONS OTHERS      = 24 ).
      IF sy-subrc NE 0 .
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
           RAISING process_terminated .
      ENDIF .
    ENDIF .

  ENDIF .

* download on application server (if required)
  IF iv_save_as_appserver IS NOT INITIAL .
    lv_fullpath = iv_save_as_appserver .

    DELETE DATASET lv_fullpath .
    OPEN DATASET lv_fullpath FOR OUTPUT IN BINARY MODE MESSAGE lv_message .
    IF sy-subrc NE 0 .
      MESSAGE e000(lp) WITH `OPEN DATASET ERROR:` lv_message
      RAISING process_terminated .
    ENDIF .
    TRANSFER ev_document_rawdata TO lv_fullpath .
    CLOSE DATASET lv_fullpath .
  ENDIF .

ENDFUNCTION.
