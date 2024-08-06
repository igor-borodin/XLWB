*&---------------------------------------------------------------------*
*&  Include           LZXLWBF01            D y n P r o   r o u t i n e s
*&---------------------------------------------------------------------*

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
* XLSX-Workbench(XLWB) components                         [Version 3.09]
* Documentation is available at:
*                             https://sites.google.com/site/sapxlwb/home
*=======================================================================
* DynPro routines
*=======================================================================


*&---------------------------------------------------------------------*
*&      Module  0100_PBO  OUTPUT
*&---------------------------------------------------------------------*
MODULE 0100_pbo OUTPUT .
  PERFORM 0100_pbo .
ENDMODULE .                 " 0100_PBO  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  0100_PAI INPUT
*&---------------------------------------------------------------------*
MODULE 0100_pai INPUT .
  PERFORM 0100_pai .
ENDMODULE .                 " 0100_PAI  INPUT
*&---------------------------------------------------------------------*
*&      Form  0100_pbo
*&---------------------------------------------------------------------*
FORM 0100_pbo .

  SET PF-STATUS '0100_PF' .

  CASE gv_mode .
    WHEN c_mode-workbench .
      gr_workbench->pbo( ) .
      SET TITLEBAR '0100_TB' WITH gr_workbench->v_title .

    WHEN c_mode-viewer .
      gr_viewer->pbo( ) .
      SET TITLEBAR '0100_TB' WITH gr_viewer->v_title .

    WHEN OTHERS .

  ENDCASE .

ENDFORM .                                                   "0100_pbo
*&---------------------------------------------------------------------*
*&      Form  0100_pai
*&---------------------------------------------------------------------*
FORM 0100_pai .

  CASE gv_mode .
    WHEN c_mode-workbench .
      CHECK sy-ucomm EQ 'BACK' .

      CHECK abap_on
         EQ lcl_workbench=>popup_to_confirm( iv_text = lcl_workbench=>v_text-t138 ) .  " text: Leave the workbench ?

      IF gr_workbench IS BOUND .
        gr_workbench->free( ) .
        FREE gr_workbench .
      ENDIF .
      LEAVE TO SCREEN 0 .

    WHEN c_mode-viewer .
      CHECK sy-ucomm EQ 'BACK' .

      DATA lv_fcode TYPE ui_func .
      lv_fcode = sy-ucomm .

      IF gr_viewer IS BOUND .
        IF  gr_viewer->s_docbuffer-callback_form IS NOT INITIAL
        AND gr_viewer->s_docbuffer-callback_prog IS NOT INITIAL .
          PERFORM (gr_viewer->s_docbuffer-callback_form)
          IN PROGRAM (gr_viewer->s_docbuffer-callback_prog) IF FOUND
               USING gr_viewer->c_event-function_code
            CHANGING lv_fcode                              " TYPE ui_func
                     gr_viewer->r_appltoolbar->r_toolbar   " TYPE REF TO cl_gui_toolbar
                     gr_viewer->s_docbuffer-rawdata .      " TYPE xstring
        ENDIF .
      ENDIF .

      CHECK lv_fcode EQ 'BACK' .

      IF gr_viewer IS BOUND .
        gr_viewer->free( ) .
        FREE gr_viewer .
      ENDIF .
      LEAVE TO SCREEN 0 .
  ENDCASE .

ENDFORM .                                                   "0100_pai
*&---------------------------------------------------------------------*
*&      Form  viewer_bundle_refresh
*&---------------------------------------------------------------------*
FORM viewer_bundle_refresh USING iv_fullpath TYPE string.

  IF gr_viewer IS BOUND .
    gr_viewer->free( ) .
    FREE gr_viewer .
  ENDIF .

  CREATE OBJECT gr_viewer
    EXPORTING
      ir_container = cl_gui_container=>default_screen
      iv_viewmode  = lcl_vr_ole=>c_viewmode-inplace
      iv_fullpath = iv_fullpath
    EXCEPTIONS
      OTHERS       = 1.

ENDFORM .                    "viewer_bundle_refresh
*&---------------------------------------------------------------------*
*&      Form  viewer_queue_begin
*&---------------------------------------------------------------------*
*FORM viewer_bundle_open .
*
*  PERFORM viewer_bundle_refresh .
*
*  gv_viewer_bundle_collect = abap_on .
*
*ENDFORM .                    "viewer_bundle_open
*&---------------------------------------------------------------------*
*&      Form  viewer_bundle_close
*&---------------------------------------------------------------------*
FORM viewer_bundle_close .

  DO 1 TIMES .
    CHECK gr_viewer IS BOUND .
*   call Excel-form in floating mode
    gr_viewer->call_floating( ) .

*   call Excel-form inplace
    CHECK gr_viewer->t_docbuffer[] IS NOT INITIAL .
    gv_mode = c_mode-viewer .
    CALL SCREEN 0100 .
  ENDDO .

  gv_viewer_bundle_collect = abap_off .

ENDFORM .                    "viewer_bundle_close
*&---------------------------------------------------------------------*
*&      Form  viewer_get_doi_object
*&---------------------------------------------------------------------*
FORM viewer_get_doi_object
  CHANGING  cr_container_control    TYPE REF TO i_oi_container_control
            cr_document_proxy       TYPE REF TO i_oi_document_proxy
            cr_spreadsheet          TYPE REF TO i_oi_spreadsheet       .

  FREE:  cr_container_control,  cr_document_proxy,  cr_spreadsheet.
  CLEAR: cr_container_control,  cr_document_proxy,  cr_spreadsheet.

  CHECK gr_viewer IS BOUND .
  CHECK gr_viewer->r_excelole IS BOUND .
  cr_container_control = gr_viewer->r_excelole->r_control .
  cr_document_proxy    = gr_viewer->r_excelole->r_docproxy .
  cr_spreadsheet       = gr_viewer->r_excelole->r_spreadsheet .

ENDFORM .                    "viewer_get_doi_object
*&---------------------------------------------------------------------*
*&      Form  viewer_get_actual_document
*&---------------------------------------------------------------------*
FORM viewer_get_actual_document
  CHANGING  cv_document_size    TYPE i
            ct_document_table   TYPE solix_tab .

  FREE:  cv_document_size ,  ct_document_table .
  CLEAR: cv_document_size ,  ct_document_table .

  CHECK gr_viewer IS BOUND .
  CHECK gr_viewer->r_excelole IS BOUND .

  gr_viewer->r_excelole->r_docproxy->save_document_to_table(
      CHANGING document_size  = cv_document_size
               document_table = ct_document_table ) .

ENDFORM .                    "viewer_get_actual_document
