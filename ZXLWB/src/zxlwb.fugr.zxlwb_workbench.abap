FUNCTION ZXLWB_WORKBENCH.
*"----------------------------------------------------------------------
*"*"Локальный интерфейс:
*"  IMPORTING
*"     REFERENCE(IV_FORMNAME) TYPE  ANY OPTIONAL
*"     REFERENCE(IV_ACTION) TYPE  ANY
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
* XLSX-Workbench(XLWB) components                         [Version 3.03]
* Documentation is available at:
*                             https://sites.google.com/site/sapxlwb/home
*=======================================================================
* Forms design tool starter
*=======================================================================


  IF gr_workbench IS BOUND .
    gr_workbench->free( ) .
    FREE gr_workbench .
  ENDIF .
  CLEAR gv_mode .

  CREATE OBJECT gr_workbench
    EXPORTING
      iv_formname        = iv_formname
      iv_action          = iv_action
    EXCEPTIONS
      process_terminated = 1.
  IF sy-subrc NE 0 .
    RAISE process_terminated .
  ENDIF .

  CASE iv_action .
    WHEN lcl_workbench=>c_action-edit
      OR lcl_workbench=>c_action-create
      OR lcl_workbench=>c_action-crea_t .

      gv_mode = c_mode-workbench .
      CALL SCREEN 0100 .
  ENDCASE .

  IF gr_workbench IS BOUND .
    gr_workbench->free( ) .
    FREE gr_workbench .
  ENDIF .
  CLEAR gv_mode .

ENDFUNCTION.
