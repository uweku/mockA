*&---------------------------------------------------------------------*
*& Report  ZTEST_CL_MOCKA_MOCKER
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

REPORT  ztest_cl_mocka_mocker.

TYPE-POOLS: abap.

*----------------------------------------------------------------------*
*       CLASS lcl_test_mocker DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_test_mocker DEFINITION FOR TESTING.
  "#AU Risk_Level Harmless
  "#AU Duration Short
  PROTECTED SECTION.
  PRIVATE SECTION.
    METHODS setup.
    METHODS teardown.
    METHODS create_valid_mocker FOR TESTING.
    METHODS create_invalid_mocker FOR TESTING.
    METHODS create_valid_mocker_method FOR TESTING.
    METHODS create_retrieve_mocker_method FOR TESTING.
    METHODS create_invalid_mocker_method FOR TESTING.
    METHODS test_method_parameter_verif FOR TESTING.
    METHODS is_in_time FOR TESTING.
    METHODS get_delay FOR TESTING.
    METHODS get_delay_multi_importing FOR TESTING.
    METHODS get_both FOR TESTING.
    METHODS get_both_by_optional_param FOR TESTING.
    METHODS raises_exception FOR TESTING.
    METHODS raises_exception_wo_with FOR TESTING.
    METHODS raises_exception_wo_with_2 FOR TESTING.
    METHODS is_in_time_by_changing_param FOR TESTING.
    METHODS is_in_time_by_chng_param_multi FOR TESTING.
    METHODS optional_params FOR TESTING.
    METHODS get_delay_x2 FOR TESTING.
    METHODS raises_exc_x2 FOR TESTING.
    METHODS changing_parameter_x2 FOR TESTING.
    METHODS fake_included_interface_method FOR TESTING.
    METHODS method_with_old_exc FOR TESTING.
    METHODS fake_interface_attribute FOR TESTING.
    METHODS fake_instance_attribute FOR TESTING.
    METHODS fake_invalid_attribute FOR TESTING.
    METHODS is_method_called_positive FOR TESTING.
    METHODS is_method_called_negative FOR TESTING.
ENDCLASS.                    "lcl_test_mocker DEFINITION

*----------------------------------------------------------------------*
*       CLASS lcl_test_mocker IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_test_mocker IMPLEMENTATION.
  METHOD setup.
  ENDMETHOD.                    "setup
  METHOD teardown.
  ENDMETHOD.                    "teardown
  METHOD create_valid_mocker.
    DATA lv_has_exception_been_raised TYPE abap_bool VALUE abap_false.
    DATA lo_mocker TYPE REF TO zif_mocka_mocker.
    TRY.
        lo_mocker = zcl_mocka_mocker=>zif_mocka_mocker~mock( iv_interface = 'ZIF_MOCKA_IS_IN_TIME_INFO' ).
      CATCH zcx_mocka.
        lv_has_exception_been_raised = abap_true.
    ENDTRY.
    cl_aunit_assert=>assert_initial( lv_has_exception_been_raised ).
    cl_aunit_assert=>assert_not_initial( lo_mocker ).
  ENDMETHOD.                    "create_valid_mocker
  METHOD create_invalid_mocker.
    DATA lv_has_exception_been_raised TYPE abap_bool VALUE abap_false.
    DATA lo_mocker TYPE REF TO zif_mocka_mocker.
    TRY.
        lo_mocker = zcl_mocka_mocker=>zif_mocka_mocker~mock( iv_interface = '\PROGRAM=ZTEST_CL_MOCKA_MOCKER\INTERFACE=LIF_INVALID' ).
      CATCH zcx_mocka.
        lv_has_exception_been_raised = abap_true.
    ENDTRY.
    cl_aunit_assert=>assert_not_initial( lv_has_exception_been_raised ).
    cl_aunit_assert=>assert_initial( lo_mocker ).
  ENDMETHOD.                    "create_valid_mocker

  METHOD create_valid_mocker_method.
    DATA lv_has_exception_been_raised TYPE abap_bool VALUE abap_false.
    DATA lo_mocker TYPE REF TO zif_mocka_mocker.
    DATA lo_mocker_method TYPE REF TO zif_mocka_mocker_method.
    TRY.
        lo_mocker = zcl_mocka_mocker=>zif_mocka_mocker~mock( iv_interface = 'ZIF_MOCKA_IS_IN_TIME_INFO' ).
        lo_mocker_method = lo_mocker->method( 'IS_IN_TIME' ).
      CATCH zcx_mocka.
        lv_has_exception_been_raised = abap_true.
    ENDTRY.
    cl_aunit_assert=>assert_initial( lv_has_exception_been_raised ).
    cl_aunit_assert=>assert_not_initial( lo_mocker ).
    cl_aunit_assert=>assert_not_initial( lo_mocker_method ).
  ENDMETHOD.                    "create_valid_mocker_method
  METHOD create_retrieve_mocker_method.
    DATA lv_has_exception_been_raised TYPE abap_bool VALUE abap_false.
    DATA lo_mocker TYPE REF TO zif_mocka_mocker.
    DATA lo_mocker_method1 TYPE REF TO zif_mocka_mocker_method.
    DATA  lv_mm1_eq_mm2 TYPE abap_bool.
    TRY.
        lo_mocker = zcl_mocka_mocker=>zif_mocka_mocker~mock( iv_interface = 'ZIF_MOCKA_IS_IN_TIME_INFO' ).
        lo_mocker_method1 = lo_mocker->method( 'IS_IN_TIME' ).
      CATCH zcx_mocka.
        lv_has_exception_been_raised = abap_true.
    ENDTRY.

*   any new method results in a new instance...
    DATA lo_mocker_method2 TYPE REF TO zif_mocka_mocker_method.
    TRY.
        lo_mocker_method2 = lo_mocker->method( 'GET_DELAY' ).
      CATCH zcx_mocka.
        lv_has_exception_been_raised = abap_true.
    ENDTRY.
    cl_aunit_assert=>assert_initial( lv_has_exception_been_raised ).
    IF lo_mocker_method1 EQ lo_mocker_method2.
      lv_mm1_eq_mm2 = abap_true.
    ELSE.
      lv_mm1_eq_mm2 = abap_false.
    ENDIF.
    cl_aunit_assert=>assert_initial( lv_mm1_eq_mm2 ).

*   ...but any method which has already been requested returns the existing instance
    TRY.
        lo_mocker_method2 = lo_mocker->method( 'IS_IN_TIME' ).
      CATCH zcx_mocka.
        lv_has_exception_been_raised = abap_true.
    ENDTRY.
    cl_aunit_assert=>assert_initial( lv_has_exception_been_raised ).

    IF lo_mocker_method1 EQ lo_mocker_method2.
      lv_mm1_eq_mm2 = abap_true.
    ELSE.
      lv_mm1_eq_mm2 = abap_false.
    ENDIF.
    cl_aunit_assert=>assert_not_initial( lv_mm1_eq_mm2 ).
  ENDMETHOD.                    "create_and_retrieve_mocker_method
  METHOD create_invalid_mocker_method.
    DATA lv_has_exception_been_raised TYPE abap_bool VALUE abap_false.
    DATA lo_mocker TYPE REF TO zif_mocka_mocker.
    DATA lo_mocker_method TYPE REF TO zif_mocka_mocker_method.
    TRY.
        lo_mocker = zcl_mocka_mocker=>zif_mocka_mocker~mock( iv_interface = 'ZIF_MOCKA_IS_IN_TIME_INFO' ).
        lo_mocker_method = lo_mocker->method( 'INVALID' ).
      CATCH zcx_mocka.
        lv_has_exception_been_raised = abap_true.
    ENDTRY.
    cl_aunit_assert=>assert_not_initial( lv_has_exception_been_raised ).
    cl_aunit_assert=>assert_not_initial( lo_mocker ).
    cl_aunit_assert=>assert_initial( lo_mocker_method ).
  ENDMETHOD.                    "create_invalid_mocker_method

  METHOD test_method_parameter_verif.
    DATA lv_has_exception_been_raised TYPE abap_bool VALUE abap_false.
    DATA lo_mocker TYPE REF TO zif_mocka_mocker.
    DATA lo_mocker_method TYPE REF TO zif_mocka_mocker_method.

*   create valid parameter combination
    TRY.
        lo_mocker = zcl_mocka_mocker=>zif_mocka_mocker~mock( iv_interface = 'ZIF_MOCKA_IS_IN_TIME_INFO' ).
        lo_mocker_method = lo_mocker->method( 'IS_IN_TIME' ).
        lo_mocker_method->with( i_p1 = 'LH' i_p2 = 402 i_p3 = 20121108 ).
      CATCH zcx_mocka.
        lv_has_exception_been_raised = abap_true.
    ENDTRY.
    cl_aunit_assert=>assert_initial( lv_has_exception_been_raised ).

*   create invalid parameter combination
    TRY.
        lo_mocker = zcl_mocka_mocker=>zif_mocka_mocker~mock( iv_interface = 'ZIF_MOCKA_IS_IN_TIME_INFO' ).
        lo_mocker_method = lo_mocker->method( 'IS_IN_TIME' ).
        lo_mocker_method->with( i_p1 = 'LH' i_p2 = 402 i_p3 = 20121108 i_p4 = 'INVALID_PARAM' ).
      CATCH zcx_mocka.
        lv_has_exception_been_raised = abap_true.
    ENDTRY.
    cl_aunit_assert=>assert_not_initial( lv_has_exception_been_raised ).

*   create valid parameter combination - using RETURNING parameter
    DATA lr_flag TYPE REF TO data.
    FIELD-SYMBOLS <lv_flag> TYPE abap_bool.
    DATA lv_is_in_time TYPE abap_bool.
    CLEAR: lv_has_exception_been_raised.
    TRY.
        lo_mocker = zcl_mocka_mocker=>zif_mocka_mocker~mock( iv_interface = 'ZIF_MOCKA_IS_IN_TIME_INFO' ).
        lo_mocker_method = lo_mocker->method( 'IS_IN_TIME' ).
        lo_mocker_method->with( i_p1 = 'LH' i_p2 = 402 i_p3 = '20121108' ).
        lo_mocker_method->returns( abap_true ).
      CATCH zcx_mocka.
        lv_has_exception_been_raised = abap_true.
    ENDTRY.
    cl_aunit_assert=>assert_initial( lv_has_exception_been_raised ).

*   create valid parameter combination - using EXPORTING parameters
    CLEAR: lv_has_exception_been_raised.
    TRY.
        lo_mocker = zcl_mocka_mocker=>zif_mocka_mocker~mock( iv_interface = 'ZIF_MOCKA_IS_IN_TIME_INFO' ).
        lo_mocker_method = lo_mocker->method( 'GET_BOTH' ).
        lo_mocker_method->with( i_p1 = 'LH' i_p2 = 402 i_p3 = '20121108' ).
        lo_mocker_method->exports( i_p1 = 10 i_p2 = abap_false ).
      CATCH zcx_mocka.
        lv_has_exception_been_raised = abap_true.
    ENDTRY.
    cl_aunit_assert=>assert_initial( lv_has_exception_been_raised ).

*   create invalid parameter combination - using EXPORTING parameters
    CLEAR: lv_has_exception_been_raised.
    TRY.
        lo_mocker = zcl_mocka_mocker=>zif_mocka_mocker~mock( iv_interface = 'ZIF_MOCKA_IS_IN_TIME_INFO' ).
        lo_mocker_method = lo_mocker->method( 'GET_BOTH' ).
        lo_mocker_method->with( i_p1 = 'LH' i_p2 = 402 i_p3 = '20121108' i_p4 = 'INVALID' ).
      CATCH zcx_mocka.
        lv_has_exception_been_raised = abap_true.
    ENDTRY.
    cl_aunit_assert=>assert_not_initial( lv_has_exception_been_raised ).

  ENDMETHOD.                    "test_method_parameter_verif

  METHOD is_in_time.
    DATA lv_has_exception_been_raised TYPE abap_bool VALUE abap_false.
    DATA lo_mocker TYPE REF TO zif_mocka_mocker.
    DATA lo_mocker_method TYPE REF TO zif_mocka_mocker_method.

*   create valid parameter combination
    DATA lr_flag TYPE REF TO data.
    FIELD-SYMBOLS <lv_flag> TYPE abap_bool.
    DATA lv_is_in_time TYPE abap_bool.
    DATA lv_delay TYPE i.
    CLEAR: lv_has_exception_been_raised.
    DATA lo_in_time TYPE REF TO zif_mocka_is_in_time_info.
    DATA lv_times TYPE i.
    DATA lv_flag TYPE abap_bool.

    TRY.
        lo_mocker = zcl_mocka_mocker=>zif_mocka_mocker~mock( iv_interface = 'ZIF_MOCKA_IS_IN_TIME_INFO' ).
        lo_mocker_method = lo_mocker->method( 'IS_IN_TIME' ).
        lo_mocker_method->with( i_p1 = 'LH' i_p2 = 402 i_p3 = '20121108' ).
        lo_mocker_method->returns( abap_true ).
        lo_mocker_method->with( i_p1 = 'LH' i_p2 = 402 i_p3 = '20121109' ).
        lo_mocker_method->returns( abap_false ).
*       please be aware of fluent API: in NW releases >= 7.02 you could also use:
*        lo_mocker_method->with( i_p1 = 'LH' i_p2 = 402 i_p3 = '20121108' )->returns( abap_true ).
*        lo_mocker_method->with( i_p1 = 'LH' i_p2 = 402 i_p3 = '20121109' )->returns( abap_false ).

*       this call creates the mockup
        lo_in_time ?= lo_mocker->generate_mockup( ).
        cl_aunit_assert=>assert_not_initial( lo_in_time ).

*       call interface methods of the mockup - IS_IN_TIME
        lv_is_in_time = lo_in_time->is_in_time( iv_carrid = 'LH' iv_connid = 402 iv_fldate = '20121108' ).
        cl_aunit_assert=>assert_equals( act = lv_is_in_time exp = abap_true ).
        lv_is_in_time = lo_in_time->is_in_time( iv_carrid = 'LH' iv_connid = 402 iv_fldate = '20121109' ).
        cl_aunit_assert=>assert_equals( act = lv_is_in_time exp = abap_false ).

*       verify number of calls for IS_IN_TIME
        lv_times = lo_mocker_method->times_called( ).
        cl_aunit_assert=>assert_equals( act = lv_times exp = 2 ).
        lv_flag = lo_mocker_method->has_method_been_called( ).
        cl_aunit_assert=>assert_equals( act = lv_flag exp = abap_true ).
        lv_flag = lo_mocker->has_any_method_been_called( ).
        cl_aunit_assert=>assert_equals( act = lv_flag exp = abap_true ).

      CATCH zcx_mocka.
        lv_has_exception_been_raised = abap_true.
    ENDTRY.
    cl_aunit_assert=>assert_initial( lv_has_exception_been_raised ).

  ENDMETHOD.                    "mock

  METHOD get_delay.
    DATA lv_has_exception_been_raised TYPE abap_bool VALUE abap_false.
    DATA lo_mocker TYPE REF TO zif_mocka_mocker.
    DATA lo_mocker_method TYPE REF TO zif_mocka_mocker_method.

*   create valid parameter combination
    DATA lr_flag TYPE REF TO data.
    FIELD-SYMBOLS <lv_flag> TYPE abap_bool.
    DATA lv_is_in_time TYPE abap_bool.
    DATA lv_delay TYPE i.
    CLEAR: lv_has_exception_been_raised.
    DATA lo_in_time TYPE REF TO zif_mocka_is_in_time_info.
    DATA lv_times TYPE i.

    TRY.
        lo_mocker = zcl_mocka_mocker=>zif_mocka_mocker~mock( iv_interface = 'ZIF_MOCKA_IS_IN_TIME_INFO' ).
        lo_mocker_method = lo_mocker->method( 'GET_DELAY' ).
        lo_mocker_method->with( i_p1 = 'LH' i_p2 = 402 i_p3 = '20121109' ).
        lo_mocker_method->returns( 10 ).
        lo_mocker_method = lo_mocker->method( 'GET_DELAY' ).
        lo_mocker_method->with( i_p1 = 'LH' i_p2 = 402 i_p3 = '20121110' ).
        lo_mocker_method->returns( 5 ).

*       please be aware of fluent API: in NW releases >= 7.02 you could also use:
*        lo_mocker_method = lo_mocker->method( 'GET_DELAY' )->with( i_p1 = 'LH' i_p2 = 402 i_p3 = '20121109' )->returns( 10 ).
*        lo_mocker_method = lo_mocker->method( 'GET_DELAY' )->with( i_p1 = 'LH' i_p2 = 402 i_p3 = '20121110' )->returns( 5 ).

*       this call creates the mockup
        lo_in_time ?= lo_mocker->generate_mockup( ).
        cl_aunit_assert=>assert_not_initial( lo_in_time ).

*       call interface methods of the mockup - GET_DELAY
        lv_delay = lo_in_time->get_delay( iv_carrid = 'LH' iv_connid = 402 iv_fldate = '20121109' ).
        cl_aunit_assert=>assert_equals( act = lv_delay exp = 10 ).
        lv_delay = lo_in_time->get_delay( iv_carrid = 'LH' iv_connid = 402 iv_fldate = '20121110' ).
        cl_aunit_assert=>assert_equals( act = lv_delay exp = 5 ).

*       not registered calls should not lead to any exception
        lv_delay = lo_in_time->get_delay( iv_carrid = 'LH' iv_connid = 402 iv_fldate = '20121111' ).
        cl_aunit_assert=>assert_equals( act = lv_delay exp = 0 ).

*       verify number of calls for GET_DELAY
        lv_times = lo_mocker_method->times_called( ).
        cl_aunit_assert=>assert_equals( act = lv_times exp = 3 ).


      CATCH zcx_mocka.
        lv_has_exception_been_raised = abap_true.
    ENDTRY.
    cl_aunit_assert=>assert_initial( lv_has_exception_been_raised ).
  ENDMETHOD.                    "GET_DELAY

  METHOD get_delay_multi_importing.
    DATA lv_has_exception_been_raised TYPE abap_bool VALUE abap_false.
    DATA lo_mocker TYPE REF TO zif_mocka_mocker.
    DATA lo_mocker_method TYPE REF TO zif_mocka_mocker_method.

*   create valid parameter combination
    DATA lr_flag TYPE REF TO data.
    FIELD-SYMBOLS <lv_flag> TYPE abap_bool.
    DATA lv_is_in_time TYPE abap_bool.
    DATA lv_delay TYPE i.
    CLEAR: lv_has_exception_been_raised.
    DATA lo_in_time TYPE REF TO zif_mocka_is_in_time_info.
    DATA lv_times TYPE i.

    TRY.
        lo_mocker = zcl_mocka_mocker=>zif_mocka_mocker~mock( iv_interface = 'ZIF_MOCKA_IS_IN_TIME_INFO' ).
        lo_mocker_method = lo_mocker->method( 'GET_DELAY' ).
        lo_mocker_method->with( i_p1 = 'LH' i_p2 = 402 i_p3 = '20121109' ).
        lo_mocker_method->with( i_p1 = 'LH' i_p2 = 402 i_p3 = '20121110' ).
        lo_mocker_method->returns( 5 ).

*       please be aware of fluent API: in NW releases >= 7.02 you could also use:
*        lo_mocker_method = lo_mocker->method( 'GET_DELAY' )->with( i_p1 = 'LH' i_p2 = 402 i_p3 = '20121110' )->with( i_p1 = 'LH' i_p2 = 402 i_p3 = '20121109' )->returns( 5 ).

*       this call creates the mockup
        lo_in_time ?= lo_mocker->generate_mockup( ).
        cl_aunit_assert=>assert_not_initial( lo_in_time ).

*       call interface methods of the mockup - GET_DELAY
        lv_delay = lo_in_time->get_delay( iv_carrid = 'LH' iv_connid = 402 iv_fldate = '20121109' ).
        cl_aunit_assert=>assert_equals( act = lv_delay exp = 5 ).
        lv_delay = lo_in_time->get_delay( iv_carrid = 'LH' iv_connid = 402 iv_fldate = '20121110' ).
        cl_aunit_assert=>assert_equals( act = lv_delay exp = 5 ).

*       verify number of calls for GET_DELAY
        lv_times = lo_mocker_method->times_called( ).
        cl_aunit_assert=>assert_equals( act = lv_times exp = 2 ).
      CATCH zcx_mocka.
        lv_has_exception_been_raised = abap_true.
    ENDTRY.
    cl_aunit_assert=>assert_initial( lv_has_exception_been_raised ).
  ENDMETHOD.                    "get_delay_multi_importing

  METHOD get_both.
    DATA lv_has_exception_been_raised TYPE abap_bool VALUE abap_false.
    DATA lo_mocker TYPE REF TO zif_mocka_mocker.
    DATA lo_mocker_method TYPE REF TO zif_mocka_mocker_method.

*   create valid parameter combination
    DATA lr_flag TYPE REF TO data.
    FIELD-SYMBOLS <lv_flag> TYPE abap_bool.
    DATA lv_is_in_time TYPE abap_bool.
    DATA lv_delay TYPE i.
    CLEAR: lv_has_exception_been_raised.
    DATA lo_in_time TYPE REF TO zif_mocka_is_in_time_info.
    DATA lv_times TYPE i.

    TRY.
        lo_mocker = zcl_mocka_mocker=>zif_mocka_mocker~mock( iv_interface = 'ZIF_MOCKA_IS_IN_TIME_INFO' ).
*       create valid parameter combination - using EXPORTING parameters
        CLEAR: lv_has_exception_been_raised.
        lo_mocker_method = lo_mocker->method( 'GET_BOTH' ).
        lo_mocker_method->with( i_p1 = 'LH' i_p2 = 402 i_p3 = '20121108' ).
        lo_mocker_method->exports( i_p1 = 10 i_p2 = abap_false ).
        lo_mocker_method->with( i_p1 = 'LH' i_p2 = 402 i_p3 = '20121109' ).
        lo_mocker_method->exports( i_p1 = 2 i_p2 = abap_true ).

*       please be aware of fluent API: in NW releases >= 7.02 you could also use:
*        lo_mocker_method->with( i_p1 = 'LH' i_p2 = 402 i_p3 = '20121108' )->exports( i_p1 = 10 i_p2 = abap_false ).
*        lo_mocker_method->with( i_p1 = 'LH' i_p2 = 402 i_p3 = '20121109' )->exports( i_p1 = 2 i_p2 = abap_true ).

*       this call creates the mockup
        lo_in_time ?= lo_mocker->generate_mockup( ).
        cl_aunit_assert=>assert_not_initial( lo_in_time ).

        lo_in_time->get_both(
            EXPORTING iv_carrid = 'LH' iv_connid = 402 iv_fldate = '20121109'
            IMPORTING ev_delay = lv_delay ev_is_in_time = lv_is_in_time ).
        cl_aunit_assert=>assert_equals( act = lv_delay exp = 2 ).
        cl_aunit_assert=>assert_equals( act = lv_is_in_time exp = abap_true ).

        lo_in_time->get_both(
            EXPORTING iv_carrid = 'LH' iv_connid = 402 iv_fldate = '20121108'
            IMPORTING ev_delay = lv_delay ev_is_in_time = lv_is_in_time ).
        cl_aunit_assert=>assert_equals( act = lv_delay exp = 10 ).
        cl_aunit_assert=>assert_equals( act = lv_is_in_time exp = abap_false ).

        "default values
        lo_in_time->get_both(
            EXPORTING iv_carrid = 'LH' iv_connid = 402 iv_fldate = '20121110'
            IMPORTING ev_delay = lv_delay ev_is_in_time = lv_is_in_time ).
        cl_aunit_assert=>assert_equals( act = lv_delay exp = 0 ).
        cl_aunit_assert=>assert_equals( act = lv_is_in_time exp = abap_false ).

*       verify number of calls for GET_BOTH
        lv_times = lo_mocker_method->times_called( ).
        cl_aunit_assert=>assert_equals( act = lv_times exp = 3 ).

      CATCH zcx_mocka.
        lv_has_exception_been_raised = abap_true.
    ENDTRY.
    cl_aunit_assert=>assert_initial( lv_has_exception_been_raised ).

  ENDMETHOD.                    "get_both

  METHOD get_both_by_optional_param.
    DATA lv_has_exception_been_raised TYPE abap_bool VALUE abap_false.
    DATA lo_mocker TYPE REF TO zif_mocka_mocker.
    DATA lo_mocker_method TYPE REF TO zif_mocka_mocker_method.

*   create valid parameter combination
    DATA lr_flag TYPE REF TO data.
    FIELD-SYMBOLS <lv_flag> TYPE abap_bool.
    DATA lv_is_in_time TYPE abap_bool.
    DATA lv_delay TYPE i.
    CLEAR: lv_has_exception_been_raised.
    DATA lo_in_time TYPE REF TO zif_mocka_is_in_time_info.
    DATA lv_times TYPE i.

    TRY.
        lo_mocker = zcl_mocka_mocker=>zif_mocka_mocker~mock( iv_interface = 'ZIF_MOCKA_IS_IN_TIME_INFO' ).
*       create valid parameter combination - using EXPORTING parameters
        CLEAR: lv_has_exception_been_raised.
        lo_mocker_method = lo_mocker->method( 'GET_BOTH_BY_OPTIONAL_PARAM' ).
        lo_mocker_method->exports( i_p1 = 2 i_p2 = abap_true ).

*       this call creates the mockup
        lo_in_time ?= lo_mocker->generate_mockup( ).
        cl_aunit_assert=>assert_not_initial( lo_in_time ).

        lo_in_time->get_both_by_optional_param(
            IMPORTING ev_delay = lv_delay ev_is_in_time = lv_is_in_time ).
        cl_aunit_assert=>assert_equals( act = lv_delay exp = 2 ).
        cl_aunit_assert=>assert_equals( act = lv_is_in_time exp = abap_true ).

*       verify number of calls for GET_BOTH_BY_OPTIONAL_PARAM
        lv_times = lo_mocker_method->times_called( ).
        cl_aunit_assert=>assert_equals( act = lv_times exp = 1 ).

      CATCH zcx_mocka.
        lv_has_exception_been_raised = abap_true.
    ENDTRY.
    cl_aunit_assert=>assert_initial( lv_has_exception_been_raised ).

  ENDMETHOD.                    "get_both_optional
  METHOD raises_exception.
    DATA lv_has_exception_been_raised TYPE abap_bool VALUE abap_false.
    DATA lo_mocker TYPE REF TO zif_mocka_mocker.
    DATA lo_mocker_method TYPE REF TO zif_mocka_mocker_method.

*   create valid parameter combination
    DATA lr_flag TYPE REF TO data.
    FIELD-SYMBOLS <lv_flag> TYPE abap_bool.
    DATA lv_is_in_time TYPE abap_bool.
    DATA lv_delay TYPE i.
    CLEAR: lv_has_exception_been_raised.
    DATA lo_in_time TYPE REF TO zif_mocka_is_in_time_info.
    DATA lv_times TYPE i.

    TRY.
        lo_mocker = zcl_mocka_mocker=>zif_mocka_mocker~mock( iv_interface = 'ZIF_MOCKA_IS_IN_TIME_INFO' ).
*       create valid parameter combination - using EXPORTING parameters
        CLEAR: lv_has_exception_been_raised.
        lo_mocker_method = lo_mocker->method( 'IS_IN_TIME' ).
        lo_mocker_method->with( i_p1 = 'LH' i_p2 = 402 i_p3 = '20121108' ).

        TRY.
            lv_has_exception_been_raised = abap_false.
            lo_mocker_method->raises_by_name( 'CX_STATIC_CHECK' )."invalid exception - is abstract
          CATCH zcx_mocka.
            lv_has_exception_been_raised = abap_true.
        ENDTRY.
        cl_aunit_assert=>assert_not_initial( lv_has_exception_been_raised ).
        lv_has_exception_been_raised = abap_false.


        lo_mocker_method->raises_by_name( 'zcx_mocka_in_time_exception' )."intentionally name the valid exception in lower case

        lo_mocker_method->with( i_p1 = 'LH' i_p2 = 402 i_p3 = '20121109' ).
        lo_mocker_method->returns( abap_false ).

*       this call creates the mockup
        lo_in_time ?= lo_mocker->generate_mockup( ).
        cl_aunit_assert=>assert_not_initial( lo_in_time ).

        lv_is_in_time = lo_in_time->is_in_time( iv_carrid = 'LH' iv_connid = 402 iv_fldate = '20121109' ).
        cl_aunit_assert=>assert_equals( act = lv_is_in_time exp = abap_false ).
        TRY.
            lv_has_exception_been_raised = abap_false.
            lv_is_in_time = lo_in_time->is_in_time( iv_carrid = 'LH' iv_connid = 402 iv_fldate = '20121108' ).
          CATCH zcx_mocka_in_time_exception.
            lv_has_exception_been_raised = abap_true.
          CATCH cx_root.
            lv_has_exception_been_raised = abap_false."since it is the wrong exception
        ENDTRY.
        cl_aunit_assert=>assert_not_initial( lv_has_exception_been_raised ).
        lv_has_exception_been_raised = abap_false.

      CATCH zcx_mocka.
        lv_has_exception_been_raised = abap_true.
    ENDTRY.
    cl_aunit_assert=>assert_initial( lv_has_exception_been_raised ).

  ENDMETHOD.                    "raises_exception
  METHOD raises_exception_wo_with.
    DATA lv_has_exception_been_raised TYPE abap_bool VALUE abap_false.
    DATA lo_mocker TYPE REF TO zif_mocka_mocker.
    DATA lo_mocker_method TYPE REF TO zif_mocka_mocker_method.
    CLEAR: lv_has_exception_been_raised.
    DATA lo_in_time TYPE REF TO zif_mocka_is_in_time_info.

    lo_mocker = zcl_mocka_mocker=>zif_mocka_mocker~mock( iv_interface = 'ZIF_MOCKA_IS_IN_TIME_INFO' ).
*   create valid parameter combination - using EXPORTING parameters
    CLEAR: lv_has_exception_been_raised.
    lo_mocker_method = lo_mocker->method( 'IS_IN_TIME' ).
    lo_mocker_method->raises_by_name( 'zcx_mocka_in_time_exception' )."intentionally name the valid exception in lower case

*   this call creates the mockup
    lo_in_time ?= lo_mocker->generate_mockup( ).
    cl_aunit_assert=>assert_not_initial( lo_in_time ).

    TRY.
        lv_has_exception_been_raised = abap_false.
        lo_in_time->is_in_time( ).
      CATCH zcx_mocka_in_time_exception.
        lv_has_exception_been_raised = abap_true.
      CATCH cx_root.
        lv_has_exception_been_raised = abap_false."since it is the wrong exception
    ENDTRY.
    cl_aunit_assert=>assert_not_initial( lv_has_exception_been_raised ).
    lv_has_exception_been_raised = abap_false.

  ENDMETHOD.                    "raises_exception_wo_with

  METHOD raises_exception_wo_with_2.
    DATA lv_has_exception_been_raised TYPE abap_bool VALUE abap_false.
    DATA lo_mocker TYPE REF TO zif_mocka_mocker.
    DATA lo_mocker_method TYPE REF TO zif_mocka_mocker_method.
    CLEAR: lv_has_exception_been_raised.
    DATA lo_in_time TYPE REF TO zif_mocka_is_in_time_info.
    DATA lo_cx_mocka_in_time_exception TYPE REF TO zcx_mocka_in_time_exception.
    TRY.
        RAISE EXCEPTION TYPE zcx_mocka_in_time_exception.
      CATCH zcx_mocka_in_time_exception INTO lo_cx_mocka_in_time_exception.
    ENDTRY.

    lo_mocker = zcl_mocka_mocker=>zif_mocka_mocker~mock( iv_interface = 'ZIF_MOCKA_IS_IN_TIME_INFO' ).
*   create valid parameter combination - using EXPORTING parameters
    CLEAR: lv_has_exception_been_raised.
    lo_mocker_method = lo_mocker->method( 'IS_IN_TIME' ).
    lo_mocker_method->raises( lo_cx_mocka_in_time_exception )."intentionally name the valid exception in lower case

*   this call creates the mockup
    lo_in_time ?= lo_mocker->generate_mockup( ).
    cl_aunit_assert=>assert_not_initial( lo_in_time ).

    TRY.
        lv_has_exception_been_raised = abap_false.
        lo_in_time->is_in_time( ).
      CATCH zcx_mocka_in_time_exception.
        lv_has_exception_been_raised = abap_true.
      CATCH cx_root.
        lv_has_exception_been_raised = abap_false."since it is the wrong exception
    ENDTRY.
    cl_aunit_assert=>assert_not_initial( lv_has_exception_been_raised ).
    lv_has_exception_been_raised = abap_false.

  ENDMETHOD.                    "raises_exception_wo_with_2
  METHOD is_in_time_by_chng_param_multi.
    DATA lv_has_exception_been_raised TYPE abap_bool VALUE abap_false.
    DATA lo_mocker TYPE REF TO zif_mocka_mocker.
    DATA lo_mocker_method TYPE REF TO zif_mocka_mocker_method.

*   create valid parameter combination
    DATA lr_flag TYPE REF TO data.
    FIELD-SYMBOLS <lv_flag> TYPE abap_bool.
    DATA lv_is_in_time TYPE abap_bool.
    DATA lv_delay TYPE i.
    DATA lv_fldate TYPE s_date.
    CONSTANTS lc_change_to_fldate TYPE s_date VALUE '20121124'.
    CLEAR: lv_has_exception_been_raised.
    DATA lo_in_time TYPE REF TO zif_mocka_is_in_time_info.
    DATA lv_times TYPE i.

    TRY.
        lo_mocker = zcl_mocka_mocker=>zif_mocka_mocker~mock( iv_interface = 'ZIF_MOCKA_IS_IN_TIME_INFO' ).

        lo_mocker_method = lo_mocker->method( 'IS_IN_TIME_BY_CHANGING_PARAM' ).
        lo_mocker_method->with( i_p1 = 'LH' i_p2 = 402 ).
        lo_mocker_method->with_changing( '20121108' ).
        lo_mocker_method->with_changing( '20121109' ).
        lo_mocker_method->exports( abap_false ).

        lo_mocker_method->with( i_p1 = 'LH' i_p2 = 402 ).
        lo_mocker_method->with_changing( '20121123' ).
        lo_mocker_method->with_changing( '20121124' ).
        lo_mocker_method->changes( lc_change_to_fldate ).
        lo_mocker_method->exports( abap_true ).

*       this call creates the mockup
        lo_in_time ?= lo_mocker->generate_mockup( ).
        cl_aunit_assert=>assert_not_initial( lo_in_time ).

        CLEAR: lv_has_exception_been_raised.
        CLEAR: lv_is_in_time.
        lv_fldate = '20121109'.
        CALL METHOD lo_in_time->is_in_time_by_changing_param
          EXPORTING
            iv_carrid     = 'LH'
            iv_connid     = 402
          IMPORTING
            ev_is_in_time = lv_is_in_time
          CHANGING
            cv_fldate     = lv_fldate.
        cl_aunit_assert=>assert_equals( act = lv_is_in_time exp = abap_false ).

        CLEAR: lv_is_in_time.
        lv_fldate = '20121108'.
        CALL METHOD lo_in_time->is_in_time_by_changing_param
          EXPORTING
            iv_carrid     = 'LH'
            iv_connid     = 402
          IMPORTING
            ev_is_in_time = lv_is_in_time
          CHANGING
            cv_fldate     = lv_fldate.
        cl_aunit_assert=>assert_equals( act = lv_is_in_time exp = abap_false ).

        CLEAR: lv_is_in_time.
        lv_fldate = '20121123'.

        CALL METHOD lo_in_time->is_in_time_by_changing_param
          EXPORTING
            iv_carrid     = 'LH'
            iv_connid     = 402
          IMPORTING
            ev_is_in_time = lv_is_in_time
          CHANGING
            cv_fldate     = lv_fldate.
        cl_aunit_assert=>assert_equals( act = lv_is_in_time exp = abap_true ).
        cl_aunit_assert=>assert_equals( act = lv_fldate exp = lc_change_to_fldate ).

        CLEAR: lv_is_in_time.
        lv_fldate = '20121124'.
        CALL METHOD lo_in_time->is_in_time_by_changing_param
          EXPORTING
            iv_carrid     = 'LH'
            iv_connid     = 402
          IMPORTING
            ev_is_in_time = lv_is_in_time
          CHANGING
            cv_fldate     = lv_fldate.
        cl_aunit_assert=>assert_equals( act = lv_is_in_time exp = abap_true ).

      CATCH zcx_mocka.
        lv_has_exception_been_raised = abap_true.
    ENDTRY.
    cl_aunit_assert=>assert_initial( lv_has_exception_been_raised ).

  ENDMETHOD.                    "is_in_time_by_chng_param_multi

  METHOD is_in_time_by_changing_param.
    DATA lv_has_exception_been_raised TYPE abap_bool VALUE abap_false.
    DATA lo_mocker TYPE REF TO zif_mocka_mocker.
    DATA lo_mocker_method TYPE REF TO zif_mocka_mocker_method.

*   create valid parameter combination
    DATA lr_flag TYPE REF TO data.
    FIELD-SYMBOLS <lv_flag> TYPE abap_bool.
    DATA lv_is_in_time TYPE abap_bool.
    DATA lv_delay TYPE i.
    DATA lv_fldate TYPE s_date.
    CLEAR: lv_has_exception_been_raised.
    DATA lo_in_time TYPE REF TO zif_mocka_is_in_time_info.
    DATA lv_times TYPE i.

    TRY.
        lo_mocker = zcl_mocka_mocker=>zif_mocka_mocker~mock( iv_interface = 'ZIF_MOCKA_IS_IN_TIME_INFO' ).

        lo_mocker_method = lo_mocker->method( 'IS_IN_TIME_BY_CHANGING_PARAM' ).
        lo_mocker_method->with( i_p1 = 'LH' i_p2 = 402 ).
        lo_mocker_method->with_changing( '20121108' ).
        lo_mocker_method->exports( abap_false ).

        lo_mocker_method->with( i_p1 = 'LH' i_p2 = 402 ).
        lo_mocker_method->with_changing( '20121109' ).
        lo_mocker_method->exports( abap_true ).

        lo_mocker_method->with( i_p1 = 'LH' i_p2 = 402 ).
        lo_mocker_method->with_changing( '20121123' ).
        lo_mocker_method->changes( '20121124' ).
        lo_mocker_method->exports( abap_true ).

*       please be aware of fluent API: in NW releases >= 7.02 you could also use:
*        lo_mocker_method->with( i_p1 = 'LH' i_p2 = 402 )->with_changing( '20121108' )->exports( i_p1 = abap_false ).
*        lo_mocker_method->with( i_p1 = 'LH' i_p2 = 402 )->with_changing( '20121109' )->exports( i_p1 = abap_true ).
*        lo_mocker_method->with( i_p1 = 'LH' i_p2 = 402 )->with_changing( '20121123' )->changes( '20121124' )->exports( i_p1 = abap_true ).

*       this call creates the mockup
        lo_in_time ?= lo_mocker->generate_mockup( ).
        cl_aunit_assert=>assert_not_initial( lo_in_time ).

        CLEAR: lv_has_exception_been_raised.
        CLEAR: lv_is_in_time.
        lv_fldate = '20121109'.
        CALL METHOD lo_in_time->is_in_time_by_changing_param
          EXPORTING
            iv_carrid     = 'LH'
            iv_connid     = 402
          IMPORTING
            ev_is_in_time = lv_is_in_time
          CHANGING
            cv_fldate     = lv_fldate.

        cl_aunit_assert=>assert_equals( act = lv_is_in_time exp = abap_true ).

        CLEAR: lv_is_in_time.
        lv_fldate = '20121108'.
        CALL METHOD lo_in_time->is_in_time_by_changing_param
          EXPORTING
            iv_carrid     = 'LH'
            iv_connid     = 402
          IMPORTING
            ev_is_in_time = lv_is_in_time
          CHANGING
            cv_fldate     = lv_fldate.
        cl_aunit_assert=>assert_equals( act = lv_is_in_time exp = abap_false ).

        CLEAR: lv_is_in_time.
        lv_fldate = '20121123'.
        CALL METHOD lo_in_time->is_in_time_by_changing_param
          EXPORTING
            iv_carrid     = 'LH'
            iv_connid     = 402
          IMPORTING
            ev_is_in_time = lv_is_in_time
          CHANGING
            cv_fldate     = lv_fldate.
        cl_aunit_assert=>assert_equals( act = lv_is_in_time exp = abap_true ).
        cl_aunit_assert=>assert_equals( act = lv_fldate exp = '20121124' ).


      CATCH zcx_mocka.
        lv_has_exception_been_raised = abap_true.
    ENDTRY.
    cl_aunit_assert=>assert_initial( lv_has_exception_been_raised ).

  ENDMETHOD.                    "IS_IN_TIME_BY_CHANGING_PARAM
  METHOD optional_params.
    DATA lv_has_exception_been_raised TYPE abap_bool VALUE abap_false.
    DATA lo_mocker TYPE REF TO zif_mocka_mocker.
    DATA lo_mocker_method TYPE REF TO zif_mocka_mocker_method.

*   create valid parameter combination
    DATA lr_flag TYPE REF TO data.
    FIELD-SYMBOLS <lv_flag> TYPE abap_bool.
    DATA lv_is_in_time TYPE abap_bool.
    DATA lv_delay TYPE i.
    CLEAR: lv_has_exception_been_raised.
    DATA lo_in_time TYPE REF TO zif_mocka_is_in_time_info.
    DATA lv_times TYPE i.
    DATA lv_flag TYPE abap_bool.

    TRY.
        lo_mocker = zcl_mocka_mocker=>zif_mocka_mocker~mock( iv_interface = 'ZIF_MOCKA_IS_IN_TIME_INFO' ).
        lo_mocker_method = lo_mocker->method( 'GET_BY_OPTIONAL_PARAMS' ).
*        lo_mocker_method->with( i_p1 = 'LH' i_p2 = 402 i_p3 = '20121108' )."intentionally left blank - should always return a specific value
        lo_mocker_method->returns( abap_true ).

*       this call creates the mockup
        lo_in_time ?= lo_mocker->generate_mockup( ).
        cl_aunit_assert=>assert_not_initial( lo_in_time ).

*       call interface methods of the mockup - GET_BY_OPTIONAL_PARAMS
        lv_is_in_time = lo_in_time->get_by_optional_params( iv_carrid = 'LH' iv_connid = 402 iv_fldate = '20121108' ).
        cl_aunit_assert=>assert_equals( act = lv_is_in_time exp = abap_true ).
        lv_is_in_time = lo_in_time->get_by_optional_params( iv_carrid = 'LH' iv_connid = 402 iv_fldate = '20121109' ).
        cl_aunit_assert=>assert_equals( act = lv_is_in_time exp = abap_true ).

*       verify number of calls for GET_BY_OPTIONAL_PARAMS
        lv_times = lo_mocker_method->times_called( ).
        cl_aunit_assert=>assert_equals( act = lv_times exp = 2 ).
        lv_flag = lo_mocker_method->has_method_been_called( ).
        cl_aunit_assert=>assert_equals( act = lv_flag exp = abap_true ).
        lv_flag = lo_mocker->has_any_method_been_called( ).
        cl_aunit_assert=>assert_equals( act = lv_flag exp = abap_true ).

      CATCH zcx_mocka.
        lv_has_exception_been_raised = abap_true.
    ENDTRY.
    cl_aunit_assert=>assert_initial( lv_has_exception_been_raised ).

  ENDMETHOD.                    "optional_params
  METHOD get_delay_x2.
    DATA lv_has_exception_been_raised TYPE abap_bool VALUE abap_false.
    DATA lo_mocker TYPE REF TO zif_mocka_mocker.
    DATA lo_mocker_method TYPE REF TO zif_mocka_mocker_method.

*   create valid parameter combination
    DATA lr_flag TYPE REF TO data.
    FIELD-SYMBOLS <lv_flag> TYPE abap_bool.
    DATA lv_is_in_time TYPE abap_bool.
    DATA lv_delay TYPE i.
    CLEAR: lv_has_exception_been_raised.
    DATA lo_in_time TYPE REF TO zif_mocka_is_in_time_info.
    DATA lv_times TYPE i.

    TRY.
        lo_mocker = zcl_mocka_mocker=>zif_mocka_mocker~mock( iv_interface = 'ZIF_MOCKA_IS_IN_TIME_INFO' ).
        lo_mocker_method = lo_mocker->method( 'GET_DELAY' ).
        lo_mocker_method->with( i_p1 = 'LH' i_p2 = 402 i_p3 = '20121109' ).
        lo_mocker_method->returns( 10 ).
        lo_mocker_method = lo_mocker->method( 'GET_DELAY' ).
        lo_mocker_method->with( i_p1 = 'LH' i_p2 = 402 i_p3 = '20121109' ).
        lo_mocker_method->returns( 5 ).

*       please be aware of fluent API: in NW releases >= 7.02 you could also use:
*        lo_mocker_method = lo_mocker->method( 'GET_DELAY' )->with( i_p1 = 'LH' i_p2 = 402 i_p3 = '20121109' )->returns( 10 ).
*        lo_mocker_method = lo_mocker->method( 'GET_DELAY' )->with( i_p1 = 'LH' i_p2 = 402 i_p3 = '20121110' )->returns( 5 ).

*       this call creates the mockup
        lo_in_time ?= lo_mocker->generate_mockup( ).
        cl_aunit_assert=>assert_not_initial( lo_in_time ).

*       call interface methods of the mockup - GET_DELAY
        lv_delay = lo_in_time->get_delay( iv_carrid = 'LH' iv_connid = 402 iv_fldate = '20121109' ).
        cl_aunit_assert=>assert_equals( act = lv_delay exp = 10 ).
        lv_delay = lo_in_time->get_delay( iv_carrid = 'LH' iv_connid = 402 iv_fldate = '20121109' ).
        cl_aunit_assert=>assert_equals( act = lv_delay exp = 5 ).

*       not registered calls should not lead to any exception
        lv_delay = lo_in_time->get_delay( iv_carrid = 'LH' iv_connid = 402 iv_fldate = '20121111' ).
        cl_aunit_assert=>assert_equals( act = lv_delay exp = 0 ).

*       verify number of calls for GET_DELAY
        lv_times = lo_mocker_method->times_called( ).
        cl_aunit_assert=>assert_equals( act = lv_times exp = 3 ).

      CATCH zcx_mocka.
        lv_has_exception_been_raised = abap_true.
    ENDTRY.
    cl_aunit_assert=>assert_initial( lv_has_exception_been_raised ).

  ENDMETHOD.                    "get_delay_x2
  METHOD raises_exc_x2.
    DATA lv_has_exception_been_raised TYPE abap_bool VALUE abap_false.
    DATA lo_mocker TYPE REF TO zif_mocka_mocker.
    DATA lo_mocker_method TYPE REF TO zif_mocka_mocker_method.

*   create valid parameter combination
    DATA lr_flag TYPE REF TO data.
    FIELD-SYMBOLS <lv_flag> TYPE abap_bool.
    DATA lv_is_in_time TYPE abap_bool.
    DATA lv_delay TYPE i.
    CLEAR: lv_has_exception_been_raised.
    DATA lo_in_time TYPE REF TO zif_mocka_is_in_time_info.
    DATA lv_times TYPE i.

    TRY.
        lo_mocker = zcl_mocka_mocker=>zif_mocka_mocker~mock( iv_interface = 'ZIF_MOCKA_IS_IN_TIME_INFO' ).

        lo_mocker_method = lo_mocker->method( 'IS_IN_TIME' ).
        lo_mocker_method->with( i_p1 = 'LH' i_p2 = 402 i_p3 = '20121108' ).
        lo_mocker_method->raises_by_name( 'ZCX_MOCKA_IN_TIME_EXCEPTION' )."intentionally name the valid exception in lower case

        lo_mocker_method->with( i_p1 = 'LH' i_p2 = 402 i_p3 = '20121108' ).
        lo_mocker_method->returns( abap_true ).

*       this call creates the mockup
        lo_in_time ?= lo_mocker->generate_mockup( ).
        cl_aunit_assert=>assert_not_initial( lo_in_time ).

        TRY.
            lv_has_exception_been_raised = abap_false.
            lv_is_in_time = lo_in_time->is_in_time( iv_carrid = 'LH' iv_connid = 402 iv_fldate = '20121108' ).
            cl_aunit_assert=>assert_equals( act = lv_is_in_time exp = abap_false ).

          CATCH zcx_mocka_in_time_exception.
            lv_has_exception_been_raised = abap_true.
          CATCH cx_root.
            lv_has_exception_been_raised = abap_false."since it is the wrong exception
        ENDTRY.
        cl_aunit_assert=>assert_not_initial( lv_has_exception_been_raised ).

*       call second pattern twice
        lv_has_exception_been_raised = abap_false.
        lv_is_in_time = lo_in_time->is_in_time( iv_carrid = 'LH' iv_connid = 402 iv_fldate = '20121108' ).
        cl_aunit_assert=>assert_equals( act = lv_is_in_time exp = abap_true ).

        lv_has_exception_been_raised = abap_false.
        lv_is_in_time = lo_in_time->is_in_time( iv_carrid = 'LH' iv_connid = 402 iv_fldate = '20121108' ).
        cl_aunit_assert=>assert_equals( act = lv_is_in_time exp = abap_true ).


      CATCH zcx_mocka.
        lv_has_exception_been_raised = abap_true.
    ENDTRY.
    cl_aunit_assert=>assert_initial( lv_has_exception_been_raised ).

  ENDMETHOD.                    "raises_exc_x2
  METHOD changing_parameter_x2.
    DATA lv_has_exception_been_raised TYPE abap_bool VALUE abap_false.
    DATA lo_mocker TYPE REF TO zif_mocka_mocker.
    DATA lo_mocker_method TYPE REF TO zif_mocka_mocker_method.

*   create valid parameter combination
    DATA lr_flag TYPE REF TO data.
    FIELD-SYMBOLS <lv_flag> TYPE abap_bool.
    DATA lv_is_in_time TYPE abap_bool.
    DATA lv_delay TYPE i.
    DATA lv_fldate TYPE s_date.
    CLEAR: lv_has_exception_been_raised.
    DATA lo_in_time TYPE REF TO zif_mocka_is_in_time_info.
    DATA lv_times TYPE i.

    TRY.
        lo_mocker = zcl_mocka_mocker=>zif_mocka_mocker~mock( iv_interface = 'ZIF_MOCKA_IS_IN_TIME_INFO' ).
        lo_mocker_method = lo_mocker->method( 'IS_IN_TIME_BY_CHANGING_PARAM' ).
*       create valid parameter combination - using EXPORTING parameters
        CLEAR: lv_has_exception_been_raised.
        lo_mocker_method->with( i_p1 = 'LH' i_p2 = 402 ).
        lo_mocker_method->with_changing( '20121123' ).
        lo_mocker_method->changes( '20121124' ).
        lo_mocker_method->exports( abap_false ).

*       this call creates the mockup
        lo_in_time ?= lo_mocker->generate_mockup( ).
        cl_aunit_assert=>assert_not_initial( lo_in_time ).

        CLEAR: lv_is_in_time.
        lv_fldate = '20121123'.
        CALL METHOD lo_in_time->is_in_time_by_changing_param
          EXPORTING
            iv_carrid     = 'LH'
            iv_connid     = 402
          IMPORTING
            ev_is_in_time = lv_is_in_time
          CHANGING
            cv_fldate     = lv_fldate.
        cl_aunit_assert=>assert_equals( act = lv_is_in_time exp = abap_false ).
        cl_aunit_assert=>assert_equals( act = lv_fldate exp = '20121124' ).

        CLEAR: lv_has_exception_been_raised.
        lo_mocker_method->with( i_p1 = 'LH' i_p2 = 402 ).
        lo_mocker_method->with_changing( '20121123' ).
        lo_mocker_method->exports( abap_true ).

*       call second pattern twice
        CLEAR: lv_is_in_time.
        lv_fldate = '20121123'.
        CALL METHOD lo_in_time->is_in_time_by_changing_param
          EXPORTING
            iv_carrid     = 'LH'
            iv_connid     = 402
          IMPORTING
            ev_is_in_time = lv_is_in_time
          CHANGING
            cv_fldate     = lv_fldate.
        cl_aunit_assert=>assert_equals( act = lv_is_in_time exp = abap_true ).
        cl_aunit_assert=>assert_equals( act = lv_fldate exp = '20121123' ).

        CLEAR: lv_is_in_time.
        lv_fldate = '20121123'.
        CALL METHOD lo_in_time->is_in_time_by_changing_param
          EXPORTING
            iv_carrid     = 'LH'
            iv_connid     = 402
          IMPORTING
            ev_is_in_time = lv_is_in_time
          CHANGING
            cv_fldate     = lv_fldate.
        cl_aunit_assert=>assert_equals( act = lv_is_in_time exp = abap_true ).
        cl_aunit_assert=>assert_equals( act = lv_fldate exp = '20121123' ).

      CATCH zcx_mocka.
        lv_has_exception_been_raised = abap_true.
    ENDTRY.
    cl_aunit_assert=>assert_initial( lv_has_exception_been_raised ).

  ENDMETHOD.                    "changing_parameter_x2
  METHOD fake_included_interface_method.
    DATA lv_has_exception_been_raised TYPE abap_bool VALUE abap_false.
    DATA lo_mocker TYPE REF TO zif_mocka_mocker.
    DATA lo_mocker_method TYPE REF TO zif_mocka_mocker_method.
    DATA lo_fake TYPE REF TO if_fpm_guibb_list.
    DATA lt_param_list TYPE fpmgb_t_param_descr.
    DATA ls_param_list TYPE fpmgb_s_param_descr.
    ls_param_list-name = 'A'.
    APPEND ls_param_list TO lt_param_list.

    lo_mocker = zcl_mocka_mocker=>zif_mocka_mocker~mock( iv_interface = 'IF_FPM_GUIBB_LIST' ).
    lo_mocker_method = lo_mocker->method( 'IF_FPM_GUIBB~GET_PARAMETER_LIST' )."currently only works for method aliases
    lo_mocker_method->with( )->returns( lt_param_list ).

    lo_fake ?= lo_mocker->generate_mockup( ).
    CLEAR: lt_param_list.
    lt_param_list = lo_fake->if_fpm_guibb~get_parameter_list( ).
    cl_aunit_assert=>assert_not_initial( lt_param_list ).

  ENDMETHOD.                    "fake_included_interface_method
  METHOD method_with_old_exc.
    DATA lv_has_exception_been_raised TYPE abap_bool VALUE abap_false.
    DATA lo_mocker TYPE REF TO zif_mocka_mocker.
    DATA lo_mocker_method TYPE REF TO zif_mocka_mocker_method.
    DATA lo_fake TYPE REF TO if_http_client.

    TRY.
        lo_mocker = zcl_mocka_mocker=>zif_mocka_mocker~mock( iv_interface = 'IF_HTTP_CLIENT' ).
        lo_fake ?= lo_mocker->generate_mockup( ).
      CATCH zcx_mocka.
        lv_has_exception_been_raised = abap_true.
    ENDTRY.
    cl_aunit_assert=>assert_initial( lv_has_exception_been_raised ).

  ENDMETHOD.                    "method_with_old_exc
  METHOD fake_interface_attribute.
    DATA lv_has_exception_been_raised TYPE abap_bool VALUE abap_false.
    DATA lo_mocker TYPE REF TO zif_mocka_mocker.
    DATA lo_mocker_method TYPE REF TO zif_mocka_mocker_method.
    DATA lo_fake TYPE REF TO if_http_client.
    DATA lo_attribute TYPE REF TO zif_mocka_mocker_attribute.

    TRY.
        lo_mocker = zcl_mocka_mocker=>zif_mocka_mocker~mock( iv_interface = 'IF_HTTP_CLIENT' ).
        lo_attribute = lo_mocker->attribute( 'PROPERTYTYPE_LOGON_POPUP' ).
        lo_attribute->returns( 3 ).
        lo_fake ?= lo_mocker->generate_mockup( ).
      CATCH zcx_mocka.
        lv_has_exception_been_raised = abap_true.
    ENDTRY.
    cl_aunit_assert=>assert_initial( lv_has_exception_been_raised ).
    cl_aunit_assert=>assert_equals( act = lo_fake->propertytype_logon_popup exp = 3 ).

  ENDMETHOD.                    "attribute
  METHOD fake_instance_attribute.

    DATA lv_has_exception_been_raised TYPE abap_bool VALUE abap_false.
    DATA lo_mocker TYPE REF TO zif_mocka_mocker.
    DATA lo_fake TYPE REF TO zif_mocka_mocker.
    DATA lo_attribute TYPE REF TO zif_mocka_mocker_attribute.
    DATA lv_interface TYPE seoclsname.

    TRY.
        lo_mocker = zcl_mocka_mocker=>zif_mocka_mocker~mock( iv_interface = 'ZCL_MOCKA_MOCKER' ).
        lo_attribute = lo_mocker->attribute( 'MV_INTERFACE' ).
        lo_attribute->returns( 'ZIF_TEST' ).
        lo_fake ?= lo_mocker->generate_mockup( ).
        lv_interface = lo_fake->get_interface( ).
      CATCH zcx_mocka.
        lv_has_exception_been_raised = abap_true.
    ENDTRY.
    cl_aunit_assert=>assert_initial( lv_has_exception_been_raised ).
    cl_aunit_assert=>assert_equals( act = lv_interface exp = 'ZIF_TEST' ).

  ENDMETHOD.                    "fake_static_attribute

  METHOD fake_invalid_attribute.
    DATA lv_has_exception_been_raised TYPE abap_bool VALUE abap_false.
    DATA lo_mocker TYPE REF TO zif_mocka_mocker.
    DATA lo_mocker_method TYPE REF TO zif_mocka_mocker_method.
    DATA lo_fake TYPE REF TO if_http_client.
    DATA lo_attribute TYPE REF TO zif_mocka_mocker_attribute.

    TRY.
        lo_mocker = zcl_mocka_mocker=>zif_mocka_mocker~mock( iv_interface = 'IF_HTTP_CLIENT' ).
        lo_attribute = lo_mocker->attribute( 'fake_invalid_attribute' ).
        lo_attribute->returns( 3 ).
        lo_fake ?= lo_mocker->generate_mockup( ).
      CATCH zcx_mocka.
        lv_has_exception_been_raised = abap_true.
    ENDTRY.
    cl_aunit_assert=>assert_not_initial( lv_has_exception_been_raised ).

  ENDMETHOD.                    "fake_invalid_attribute
  METHOD is_method_called_positive.
    DATA lo_mocker TYPE REF TO zif_mocka_mocker.
    DATA lo_mocker_method TYPE REF TO zif_mocka_mocker_method.
    DATA lo_in_time TYPE REF TO zif_mocka_is_in_time_info.

    DATA lv_has_been_called TYPE abap_bool.

    lo_mocker = zcl_mocka_mocker=>zif_mocka_mocker~mock( iv_interface = 'ZIF_MOCKA_IS_IN_TIME_INFO' ).
    lo_mocker_method = lo_mocker->method( 'IS_IN_TIME' ).
    lo_mocker_method->with( i_p1 = 'LH' i_p2 = 402 i_p3 = '20121108' ).
    lo_mocker_method->returns( abap_true ).
*   please be aware of fluent API: in NW releases >= 7.02 you could also use:
*    lo_mocker_method->with( i_p1 = 'LH' i_p2 = 402 i_p3 = '20121108' )->returns( abap_true ).

*   this call creates the mockup
    lo_in_time ?= lo_mocker->generate_mockup( ).
    lv_has_been_called = lo_mocker_method->has_been_called_with( i_p1 = 'LH' i_p2 = 402 i_p3 = '20121108' ).
    cl_aunit_assert=>assert_initial( lv_has_been_called ).
*   call interface methods of the mockup - IS_IN_TIME
    lo_in_time->is_in_time( iv_carrid = 'LH' iv_connid = 402 iv_fldate = '20121108' ).

    lv_has_been_called = lo_mocker_method->has_been_called_with( i_p1 = 'LH' i_p2 = 402 i_p3 = '20121108' ).
    cl_aunit_assert=>assert_not_initial( lv_has_been_called ).

  ENDMETHOD.                    "is_method_called_positive

  METHOD is_method_called_negative.
    DATA lo_mocker TYPE REF TO zif_mocka_mocker.
    DATA lo_mocker_method TYPE REF TO zif_mocka_mocker_method.
    DATA lo_in_time TYPE REF TO zif_mocka_is_in_time_info.

    DATA lv_has_been_called TYPE abap_bool.

    lo_mocker = zcl_mocka_mocker=>zif_mocka_mocker~mock( iv_interface = 'ZIF_MOCKA_IS_IN_TIME_INFO' ).
    lo_mocker_method = lo_mocker->method( 'IS_IN_TIME' ).
    lo_mocker_method->with( i_p1 = 'LH' i_p2 = 402 i_p3 = '20121108' ).
    lo_mocker_method->returns( abap_true ).
*   please be aware of fluent API: in NW releases >= 7.02 you could also use:
*    lo_mocker_method->with( i_p1 = 'LH' i_p2 = 402 i_p3 = '20121108' )->returns( abap_true ).

*   this call creates the mockup
    lo_in_time ?= lo_mocker->generate_mockup( ).
    lv_has_been_called = lo_mocker_method->has_been_called_with( i_p1 = 'LH' i_p2 = 402 i_p3 = '20140624' ).
    cl_aunit_assert=>assert_initial( lv_has_been_called )."initial as the method IS_IN_TIME has not yet been called with the requested parameters
*   call interface methods of the mockup - IS_IN_TIME
    lo_in_time->is_in_time( iv_carrid = 'LH' iv_connid = 402 iv_fldate = '20121108' ).

    lv_has_been_called = lo_mocker_method->has_been_called_with( i_p1 = 'LH' i_p2 = 402 i_p3 = '20140624' ).
    cl_aunit_assert=>assert_initial( lv_has_been_called )."initial as the method IS_IN_TIME has still not been called with the requested parameters

  ENDMETHOD.                    "is_method_called_negative
ENDCLASS.                    "lcl_test_mocker IMPLEMENTATION
