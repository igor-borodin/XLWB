FUNCTION-POOL ZXLWB.                        "MESSAGE-ID ..

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
* DynPro declares
*=======================================================================


INCLUDE zxlwb_include .

TYPES:
  ty_mode             TYPE char2 .
CONSTANTS:
  BEGIN OF c_mode ,
    workbench         TYPE ty_mode VALUE 'WB' ,
    viewer            TYPE ty_mode VALUE 'VR' ,
  END   OF c_mode .
DATA:
  gr_workbench        TYPE REF TO lcl_workbench ,
  gr_viewer           TYPE REF TO lcl_viewer ,
  gv_mode             TYPE ty_mode ,
  gv_viewer_bundle_collect
                      TYPE flag .
