*&---------------------------------------------------------------------*
*& Report  ZMOCKA_DEMO
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

* mockA is a mocking framework for ABAP that makes creating mock implementations easier than ever before. It is Open Source.
*   lead developers:
*     Uwe Kunath - kunath.uwe[at]googlemail.com
*
*   Copyright Uwe Kunath
*    mockA can be found at https://github.com/uweku/mockA/
*
*   Licensed under the Apache License, Version 2.0 (the "License");
*   you may not use this file except in compliance with the License.
*   You may obtain a copy of the License at
*
*       http://www.apache.org/licenses/LICENSE-2.0
*
*   Unless required by applicable law or agreed to in writing, software
*   distributed under the License is distributed on an "AS IS" BASIS,
*   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
*   See the License for the specific language governing permissions and
*   limitations under the License.

REPORT  zmocka_demo.

DATA lo_mocker TYPE REF TO zif_mocka_mocker.
DATA lo_mocker_method TYPE REF TO zif_mocka_mocker_method.
lo_mocker = zcl_mocka_mocker=>zif_mocka_mocker~mock( zif_mocka_is_in_time_info=>gc_name ).

DATA lo_is_in_time_into TYPE REF TO zif_mocka_is_in_time_info.
DATA lv_delay TYPE i.
DATA lv_has_been_called TYPE abap_bool.
DATA lv_call_count TYPE i.

lo_mocker_method = lo_mocker->method( 'get_delay' ).
lo_mocker_method->with(
    i_p1             = 'LH'
    i_p2             = '300'
    i_p3             = sy-datlo
).
lo_mocker_method->returns( 100 ).

*in NW >= 7.02 you may also use:
*lo_mocker->method( 'get_delay' )->with(
*    i_p1             = 'LH'
*    i_p2             = '300'
*    i_p3             = sy-datlo
*)->returns( 100 ).

lo_is_in_time_into ?= lo_mocker->generate_mockup( ).
lv_has_been_called = lo_mocker->has_method_been_called( 'get_delay' ).
WRITE: 'get_delay( ) called? -> "', lv_has_been_called, '" ("X"=yes, ""=no)'."#EC NOTEXT
NEW-LINE.
lo_mocker_method = lo_mocker->method( 'get_delay' ).
lv_has_been_called = lo_mocker_method->has_been_called_with(
    i_p1             = 'LH'
    i_p2             = '300'
    i_p3             = sy-datlo
).
WRITE: 'get_delay( ) called with LH/300',sy-datlo,'? -> "', lv_has_been_called, '" ("X"=yes, ""=no)'."#EC NOTEXT
NEW-LINE.

lo_is_in_time_into->get_delay(
  EXPORTING
    iv_carrid = 'LH'
    iv_connid = '300'
    iv_fldate = sy-datlo
  RECEIVING
    rv_delay  = lv_delay
).
WRITE: 'get_delay( ) for LH/300',sy-datlo,': ', lv_delay."#EC NOTEXT
NEW-LINE.

lv_has_been_called = lo_mocker->has_method_been_called( 'get_delay' ).
WRITE: 'get_delay( ) called? -> "', lv_has_been_called, '" ("X"=yes, ""=no)'."#EC NOTEXT
NEW-LINE.
lv_call_count = lo_mocker->method_call_count( 'get_delay' ).
WRITE: 'call count of get_delay( ) :', lv_call_count."#EC NOTEXT
NEW-LINE.

lo_mocker_method = lo_mocker->method( 'get_delay' ).
lv_has_been_called = lo_mocker_method->has_been_called_with(
    i_p1             = 'LH'
    i_p2             = '300'
    i_p3             = sy-datlo
).
WRITE: 'get_delay( ) called with LH/300',sy-datlo,'? -> "', lv_has_been_called, '" ("X"=yes, ""=no)'."#EC NOTEXT
NEW-LINE.

lv_has_been_called = lo_mocker_method->has_been_called_with(
    i_p1             = 'LH'
    i_p2             = '301'
    i_p3             = sy-datlo
).
WRITE: 'get_delay( ) called with LH/301',sy-datlo,'? -> "', lv_has_been_called, '" ("X"=yes, ""=no)'."#EC NOTEXT
