*&---------------------------------------------------------------------*
*& Report  ZTEST_CL_MOCKA_CLASS_GEN
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

REPORT  ztest_cl_mocka_class_gen.

TYPE-POOLS: abap.

*----------------------------------------------------------------------*
*       CLASS lcl_transparent_mocker DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_transparent_mocker DEFINITION INHERITING FROM zcl_mocka_mocker.
  PUBLIC SECTION.
    CLASS-METHODS mock_by_subclass
    IMPORTING
      !iv_interface TYPE abap_abstypename
    RETURNING
      value(ro_mocker) TYPE REF TO zif_mocka_mocker.
    METHODS get_current_generated_class
      RETURNING
        value(rv_name) TYPE abap_abstypename.
ENDCLASS.                    "lcl_transparent_mocker DEFINITION
*----------------------------------------------------------------------*
*       CLASS lcl_transparent_mocker IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_transparent_mocker IMPLEMENTATION.
  METHOD mock_by_subclass.
*   returns a new mock object instance that provides the root object for recording & generating the mock object behaviour
*   for this unit test, an instance of type lcl_transparent_mocker will be created which gives us access to the protected attribute "mv_generated_class"
    DATA lo_mocker TYPE REF TO lcl_transparent_mocker.
    DATA lo_typedescr TYPE REF TO cl_abap_typedescr.
    DATA lo_cx_root TYPE REF TO cx_root.
    DATA lv_message TYPE string.
    FIELD-SYMBOLS <ls_method> TYPE abap_methdescr.
    DATA lv_interface LIKE iv_interface.

    check_unit_test_execution( ).

    lv_interface = iv_interface.
    TRANSLATE lv_interface TO UPPER CASE.

    CREATE OBJECT lo_mocker.

    CALL METHOD cl_abap_intfdescr=>describe_by_name
      EXPORTING
        p_name         = lv_interface
      RECEIVING
        p_descr_ref    = lo_typedescr
      EXCEPTIONS
        type_not_found = 1
        OTHERS         = 2.
    IF sy-subrc NE 0.
      RAISE EXCEPTION TYPE zcx_mocka
        EXPORTING
          textid    = zcx_mocka=>no_such_interface
          interface = iv_interface.
    ENDIF.

    IF lo_typedescr->type_kind = cl_abap_typedescr=>typekind_class.
      lo_mocker->mv_is_interface_mock = abap_false.
    ELSE.
      lo_mocker->mv_is_interface_mock = abap_true.
    ENDIF.

    TRY.
        ro_mocker = lo_mocker.
        lo_mocker->mo_objectdescr ?= lo_typedescr.
        lo_mocker->mv_interface = lv_interface.
        LOOP AT lo_mocker->mo_objectdescr->methods ASSIGNING <ls_method>.
          lo_mocker->resolve_method( <ls_method> ).
        ENDLOOP.

        DATA ls_generated_class TYPE ty_s_generated_class.
        READ TABLE mt_generated_classes INTO ls_generated_class WITH KEY name = lv_interface.
        IF sy-subrc = 0.
          lo_mocker->mv_generated_class = ls_generated_class-technical_name.
        ENDIF.
      CATCH cx_root INTO lo_cx_root.
        lv_message = lo_cx_root->get_text( ).
        RAISE EXCEPTION TYPE zcx_mocka
          EXPORTING
            textid       = zcx_mocka=>zcx_mocka
            generic_text = lv_message.
    ENDTRY.
  ENDMETHOD.                    "mock_by_subclass
  METHOD get_current_generated_class.
    rv_name = mv_generated_class.
  ENDMETHOD.                    "get_current_generated_class
ENDCLASS.                    "lcl_transparent_mocker IMPLEMENTATION
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
    METHODS do_not_reuse_class_impl FOR TESTING.
    METHODS reuse_interface_impl FOR TESTING.
    METHODS mock_protected_method FOR TESTING.
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
  METHOD reuse_interface_impl.
    DATA lv_has_exception_been_raised TYPE abap_bool VALUE abap_false.
    DATA lo_mocker TYPE REF TO zif_mocka_mocker.
    DATA lo_transparent_mocker TYPE REF TO lcl_transparent_mocker.
    DATA lv_generated_class1 TYPE abap_abstypename.
    DATA lv_generated_class2 TYPE abap_abstypename.

    lo_mocker = lcl_transparent_mocker=>mock_by_subclass( iv_interface = 'ZIF_MOCKA_IS_IN_TIME_INFO' ).
    lo_transparent_mocker ?= lo_mocker.
    lo_mocker->generate_mockup( ).
    lv_generated_class1 = lo_transparent_mocker->get_current_generated_class( ).

    lo_mocker = lcl_transparent_mocker=>mock_by_subclass( iv_interface = 'ZIF_MOCKA_IS_IN_TIME_INFO' ).
    lo_transparent_mocker ?= lo_mocker.
    lo_mocker->generate_mockup( ).
    lv_generated_class2 = lo_transparent_mocker->get_current_generated_class( ).

    cl_aunit_assert=>assert_equals(
      EXPORTING
        exp                  = lv_generated_class1
        act                  = lv_generated_class2
    ).
  ENDMETHOD.                    "reuse_interface_implementations

  METHOD do_not_reuse_class_impl.
    DATA lv_has_exception_been_raised TYPE abap_bool VALUE abap_false.
    DATA lo_mocker TYPE REF TO zif_mocka_mocker.
    DATA lo_transparent_mocker TYPE REF TO lcl_transparent_mocker.
    DATA lv_generated_class1 TYPE abap_abstypename.
    DATA lv_generated_class2 TYPE abap_abstypename.
    lo_mocker = lcl_transparent_mocker=>mock_by_subclass( iv_interface = 'ZCL_MOCKA_MOCKER' ).
    lo_transparent_mocker ?= lo_mocker.
    lo_mocker->generate_mockup( ).
    lv_generated_class1 = lo_transparent_mocker->get_current_generated_class( ).

    lo_mocker = lcl_transparent_mocker=>mock_by_subclass( iv_interface = 'ZCL_MOCKA_MOCKER' ).
    lo_transparent_mocker ?= lo_mocker.
    lo_mocker->generate_mockup( ).
    lv_generated_class2 = lo_transparent_mocker->get_current_generated_class( ).

    cl_aunit_assert=>assert_differs(
      EXPORTING
        exp                  = lv_generated_class1
        act                  = lv_generated_class2
    ).
  ENDMETHOD.                    "do_not_reuse_class_impl

  METHOD mock_protected_method.
    DATA lo_mocker TYPE REF TO zif_mocka_mocker.
    DATA lo_mocker_method TYPE REF TO zif_mocka_mocker_method.
    lo_mocker = zcl_mocka_mocker=>zif_mocka_mocker~mock( 'ZCL_MOCKA_MOCKER' ).
    lo_mocker_method = lo_mocker->method( 'CHECK_UNIT_TEST_EXECUTION' ).
    lo_mocker_method->returns( abap_false ).

    lo_mocker ?= lo_mocker->generate_mockup( )."should not cause an exception
    cl_abap_unit_assert=>assert_not_initial( lo_mocker ).
  ENDMETHOD.                    "mock_protected_method
ENDCLASS.                    "lcl_test_mocker IMPLEMENTATION
