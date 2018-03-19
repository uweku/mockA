*&---------------------------------------------------------------------*
*& Report  ZTEST_CL_MOCKA_FLIGHT_OBSERVER
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

REPORT  ztest_cl_mocka_flight_observer.
*========================================================================================================
*a manually implemented mock class might look like this. This demo shows how you can save this effort...
**----------------------------------------------------------------------*
**       CLASS lcl_flight_info DEFINITION
**----------------------------------------------------------------------*
**
**----------------------------------------------------------------------*
*CLASS lcl_flight_info DEFINITION.
*  PUBLIC SECTION.
*    INTERFACES ZIF_MOCKA_IS_IN_TIME_INFO.
*ENDCLASS.                    "lcl_flight_info DEFINITION
**----------------------------------------------------------------------*
**       CLASS lcl_flight_info IMPLEMENTATION
**----------------------------------------------------------------------*
**
**----------------------------------------------------------------------*
*CLASS lcl_flight_info IMPLEMENTATION.
*  METHOD ZIF_MOCKA_IS_IN_TIME_INFO~get_delay.
*    IF iv_carrid = 'LH' AND iv_connid = 402 AND iv_fldate = '20121109'.
*      rv_delay = 100.
*    ENDIF.
*    IF iv_carrid = 'LH' AND iv_connid = 402 AND iv_fldate = '2012110'.
*      rv_delay = 5.
*    ENDIF.
*  ENDMETHOD.                    "ZIF_MOCKA_IS_IN_TIME_INFO~get_delay
*ENDCLASS.                    "lcl_flight_info IMPLEMENTATION
*
*METHOD setup.
** this call creates the flight information mockup
*  CREATE OBJECT mo_is_in_time_access TYPE lcl_flight_info.
** create an empty alert backend (we just need to track the number of method calls)
*  CREATE OBJECT mo_alert_processor_mocker TYPE lcl_alert_process.
** create the flight observer which is subject to this test
*  CREATE OBJECT mo_system_under_test
*    EXPORTING
*      io_alert_processor = mo_alert_processor
*      io_in_time_access  = mo_is_in_time_access.
*ENDMETHOD. "setup
*========================================================================================================

*----------------------------------------------------------------------*
*       CLASS lcl_test_observer DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_test_observer DEFINITION FOR TESTING.
  "#AU Risk_Level Harmless
  "#AU Duration Short
  PROTECTED SECTION.

    DATA mo_is_in_time_access TYPE REF TO zif_mocka_is_in_time_info .
    DATA mo_is_in_time_mocker TYPE REF TO zif_mocka_mocker.
    DATA mo_alert_processor TYPE REF TO zif_mocka_flight_alert_process .
    DATA mo_alert_processor_mocker TYPE REF TO zif_mocka_mocker.

    DATA mo_system_under_test TYPE REF TO zcl_mocka_flight_observer.

  PRIVATE SECTION.
    METHODS setup.
    METHODS teardown.
    METHODS test_no_alert FOR TESTING.
    METHODS test_with_alert FOR TESTING.
ENDCLASS.                    "lcl_test_observer DEFINITION


*----------------------------------------------------------------------*
*       CLASS lcl_test_observer IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_test_observer IMPLEMENTATION.
  METHOD setup.
**   Member attributes:
*    DATA mo_is_in_time_access TYPE REF TO ZIF_MOCKA_IS_IN_TIME_INFO .
*    DATA mo_is_in_time_mocker TYPE REF TO ZIF_MOCKA_MOCKER.

    DATA lo_mocker_method TYPE REF TO zif_mocka_mocker_method.
*   create the flight information backend
    mo_is_in_time_mocker = zcl_mocka_mocker=>zif_mocka_mocker~mock( iv_interface = 'ZIF_MOCKA_IS_IN_TIME_INFO' ).
    lo_mocker_method = mo_is_in_time_mocker->method( 'GET_DELAY' ).
    lo_mocker_method->with( i_p1 = 'LH' i_p2 = 402 i_p3 = '20121109' ).
    lo_mocker_method->returns( 100 ).
    lo_mocker_method->with( i_p1 = 'LH' i_p2 = 402 i_p3 = '20121110' ).
    lo_mocker_method->returns( 5 ).
*   this call creates the flight information mockup
    mo_is_in_time_access ?= mo_is_in_time_mocker->generate_mockup( ).

**   Member attributes
*    DATA mo_alert_processor TYPE REF TO ZIF_MOCKA_FLIGHT_ALERT_PROCESS .
*    DATA mo_alert_processor_mocker TYPE REF TO ZIF_MOCKA_MOCKER.

*   create an empty alert backend (we just need to track the number of method calls)
    mo_alert_processor_mocker = zcl_mocka_mocker=>zif_mocka_mocker~mock( iv_interface = 'ZIF_MOCKA_FLIGHT_ALERT_PROCESS' ).
*   this call creates the alert processor mockup
    mo_alert_processor ?= mo_alert_processor_mocker->generate_mockup( ).

*   create the flight observer which is subject to this test
    CREATE OBJECT mo_system_under_test
      EXPORTING
        io_alert_processor = mo_alert_processor
        io_in_time_access  = mo_is_in_time_access.
  ENDMETHOD.                    "setup
  METHOD teardown.
  ENDMETHOD.                    "teardown
  METHOD test_no_alert.
    DATA lv_alert TYPE abap_bool.
    mo_system_under_test->observe_flight( iv_carrid = 'LH' iv_connid = 402 iv_fldate = '20121110' ).
    lv_alert = mo_alert_processor_mocker->has_method_been_called( 'ALERT_DELAY' ).
    cl_aunit_assert=>assert_initial( lv_alert ).
  ENDMETHOD.                    "test_no_alert
  METHOD test_with_alert.
    DATA lv_alert TYPE abap_bool.
    mo_system_under_test->observe_flight( iv_carrid = 'LH' iv_connid = 402 iv_fldate = '20121109' ).
    lv_alert = mo_alert_processor_mocker->has_method_been_called( 'ALERT_DELAY' ).
    cl_aunit_assert=>assert_not_initial( lv_alert ).
  ENDMETHOD.                    "test_with_alert
ENDCLASS.                    "lcl_test_observer IMPLEMENTATION
