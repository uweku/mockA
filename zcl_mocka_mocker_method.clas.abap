class ZCL_MOCKA_MOCKER_METHOD definition
  public
  final
  create public

  global friends ZCL_MOCKA_MOCKER .

public section.
*"* public components of class ZCL_MOCKA_MOCKER_METHOD
*"* do not include other source files here!!!
  type-pools SEOC .

  interfaces ZIF_MOCKA_MOCKER_METHOD .
  interfaces ZIF_MOCKA_MOCKER_METHOD_RUNTIM .

  methods CONSTRUCTOR
    importing
      !IV_METHOD_NAME type SEOCPDNAME
      !IO_MOCKER type ref to ZCL_MOCKA_MOCKER .
protected section.

  data:
    MT_CURRENT_METHOD_CALL_PATTERN type TABLE OF ZIF_MOCKA_MOCKER_METHOD=>TY_S_METHOD_CALL_PATTERN .
  data:
    MT_METHOD_CALLS type TABLE OF ZIF_MOCKA_MOCKER_METHOD=>TY_S_METHOD_CALL_PATTERN .
  data MO_MOCKER type ref to ZCL_MOCKA_MOCKER .
  data MV_METHOD_NAME type SEOCPDNAME .
  data:
    mt_method_call_patterns TYPE TABLE OF ZIF_MOCKA_MOCKER_method=>ty_s_method_call_pattern .
  data MV_TIMES_CALLED type I .

  methods INCREASE_CALL_COUNT
    importing
      !IV_INCREMENT type I .
  methods COPY_VALUE
    importing
      !IR_REF type ref to DATA
    returning
      value(RR_REF) type ref to DATA .
  methods WITH_INTERNAL
    importing
      !I_P1 type ANY optional
      !I_P2 type ANY optional
      !I_P3 type ANY optional
      !I_P4 type ANY optional
      !I_P5 type ANY optional
      !I_P6 type ANY optional
      !I_P7 type ANY optional
      !I_P8 type ANY optional
      !IV_IS_IMPORTING type ABAP_BOOL default ABAP_TRUE
    preferred parameter I_P1
    returning
      value(RO_SELF) type ref to ZIF_MOCKA_MOCKER_METHOD .
  methods HAS_BEEN_CALLED_WITH
    importing
      !IT_IMPORTING type ZIF_MOCKA_MOCKER_METHOD=>TY_T_NAME_VALUE_PAIR
      !IT_CHANGING_IN type ZIF_MOCKA_MOCKER_METHOD=>TY_T_NAME_VALUE_PAIR optional
    returning
      value(RV_HAS_BEEN_CALLED) type ABAP_BOOL .
  methods RESOLVE_METHOD_OUTPUT
    importing
      !IT_IMPORTING type ZIF_MOCKA_MOCKER_METHOD=>TY_T_NAME_VALUE_PAIR
      !IT_CHANGING_IN type ZIF_MOCKA_MOCKER_METHOD=>TY_T_NAME_VALUE_PAIR optional
      !IV_INCREASE_CALL_COUNTER type ABAP_BOOL optional
    exporting
      !ET_CHANGING_OUT type ZIF_MOCKA_MOCKER_METHOD=>TY_T_NAME_VALUE_PAIR
      !ET_EXPORTING type ZIF_MOCKA_MOCKER_METHOD=>TY_T_NAME_VALUE_PAIR
      !ER_RESULT type ref to DATA
      !EV_EXCEPTION type SEOCLSNAME
      !EO_CX_ROOT type ref to CX_ROOT .
  methods FINALIZE_CURRENT_METHOD_SIGN
    returning
      value(RO_MOCKER) type ref to ZIF_MOCKA_MOCKER .
private section.
*"* private components of class ZCL_MOCKA_MOCKER_METHOD
*"* do not include other source files here!!!
ENDCLASS.



CLASS ZCL_MOCKA_MOCKER_METHOD IMPLEMENTATION.


METHOD constructor.
  mv_method_name = iv_method_name.
  mo_mocker = io_mocker.
ENDMETHOD.


METHOD copy_value.
  FIELD-SYMBOLS <lv_in> TYPE any.
  FIELD-SYMBOLS <lv_out> TYPE any.

  ASSIGN ir_ref->* TO <lv_in>.
  CREATE DATA rr_ref LIKE <lv_in>.
  ASSIGN rr_ref->* TO <lv_out>.
  <lv_out> = <lv_in>.
ENDMETHOD.


METHOD finalize_current_method_sign.
  ro_mocker = mo_mocker.
  CHECK mt_current_method_call_pattern IS NOT INITIAL.
  APPEND LINES OF mt_current_method_call_pattern TO mt_method_call_patterns.
  FREE: mt_current_method_call_pattern.
ENDMETHOD.


METHOD has_been_called_with.
  FIELD-SYMBOLS <ls_method> TYPE abap_methdescr.
  DATA lo_objdescr TYPE REF TO cl_abap_objectdescr.
  FIELD-SYMBOLS <ls_method_call_pattern> TYPE zif_mocka_mocker_method=>ty_s_method_call_pattern.

  lo_objdescr = mo_mocker->mo_objectdescr.
  READ TABLE mo_mocker->mo_objectdescr->methods ASSIGNING <ls_method> WITH KEY name = mv_method_name.
  IF sy-subrc NE 0.
    READ TABLE mo_mocker->mo_objectdescr->methods ASSIGNING <ls_method> WITH KEY alias_for = mv_method_name.
  ENDIF.
  CHECK <ls_method> IS ASSIGNED.

  DATA ls_importing TYPE zif_mocka_mocker_method=>ty_s_name_value_pair.
  FIELD-SYMBOLS: <ls_parameter> LIKE LINE OF <ls_method>-parameters.
  DATA lv_index TYPE i.
  DATA lv_comp TYPE string.
  FIELD-SYMBOLS <lv_val> TYPE any.
  FIELD-SYMBOLS <lv_val_importing> TYPE any.
  DATA lv_equals TYPE abap_bool.
  FIELD-SYMBOLS <ls_importing> LIKE LINE OF it_importing.

  LOOP AT mt_method_calls ASSIGNING <ls_method_call_pattern>.
    CLEAR: lv_index.
    lv_equals = abap_true.
    LOOP AT <ls_method>-parameters ASSIGNING <ls_parameter> WHERE parm_kind = cl_abap_objectdescr=>importing.
*     compare IMPORTING parameters
      READ TABLE it_importing ASSIGNING <ls_importing> WITH KEY parameter = <ls_parameter>-name.
      IF sy-subrc = 0.
        READ TABLE <ls_method_call_pattern>-importing INTO ls_importing WITH KEY parameter = <ls_parameter>-name.
        IF sy-subrc = 0.
          ASSIGN ls_importing-value->* TO <lv_val>.
          ASSIGN <ls_importing>-value->* TO <lv_val_importing>.
          lv_equals = zcl_mocka_value_comparison=>assert_equals( act = <lv_val_importing> exp = <lv_val> ).
        ELSE.
          IF <ls_method_call_pattern>-importing IS NOT INITIAL.
            lv_equals = abap_false.
          ENDIF.
        ENDIF.
      ENDIF.
      IF lv_equals = abap_false.
        EXIT.
      ENDIF.
    ENDLOOP.
    IF lv_equals = abap_false.
      CONTINUE.
    ENDIF.
    LOOP AT <ls_method>-parameters ASSIGNING <ls_parameter> WHERE parm_kind = cl_abap_objectdescr=>changing.
*     compare CHANGING parameters
      READ TABLE it_changing_in ASSIGNING <ls_importing> WITH KEY parameter = <ls_parameter>-name.
      IF sy-subrc = 0.
        READ TABLE <ls_method_call_pattern>-changing_in INTO ls_importing WITH KEY parameter = <ls_parameter>-name.
        IF sy-subrc = 0.
          ASSIGN ls_importing-value->* TO <lv_val>.
          ASSIGN <ls_importing>-value->* TO <lv_val_importing>.
          lv_equals = zcl_mocka_value_comparison=>assert_equals( act = <lv_val_importing> exp = <lv_val> ).
        ELSE.
          IF <ls_method_call_pattern>-changing_in IS NOT INITIAL.
            lv_equals = abap_false.
          ENDIF.
        ENDIF.
      ENDIF.
      IF lv_equals = abap_false.
        EXIT.
      ENDIF.
    ENDLOOP.
    IF lv_equals = abap_false.
      CONTINUE.
    ELSE.
      EXIT.
    ENDIF.
  ENDLOOP.
  rv_has_been_called = lv_equals.
ENDMETHOD.


METHOD INCREASE_CALL_COUNT.
  ADD iv_increment TO mv_times_called.
ENDMETHOD.


METHOD resolve_method_output.
  CLEAR: et_exporting,
          er_result,
          ev_exception,
          et_changing_out,
          eo_cx_root.

  FIELD-SYMBOLS <ls_method> TYPE abap_methdescr.
  DATA lo_objdescr TYPE REF TO cl_abap_objectdescr.
  FIELD-SYMBOLS <ls_method_call_pattern> TYPE zif_mocka_mocker_method=>ty_s_method_call_pattern.

  lo_objdescr = mo_mocker->mo_objectdescr.
  READ TABLE mo_mocker->mo_objectdescr->methods ASSIGNING <ls_method> WITH KEY name = mv_method_name.
  IF sy-subrc NE 0.
    READ TABLE mo_mocker->mo_objectdescr->methods ASSIGNING <ls_method> WITH KEY alias_for = mv_method_name.
  ENDIF.
  CHECK <ls_method> IS ASSIGNED.

  DATA ls_importing TYPE zif_mocka_mocker_method=>ty_s_name_value_pair.
  FIELD-SYMBOLS: <ls_parameter> LIKE LINE OF <ls_method>-parameters.
  DATA lv_index TYPE i.
  DATA lv_comp TYPE string.
  FIELD-SYMBOLS <lv_val> TYPE any.
  FIELD-SYMBOLS <lv_val_importing> TYPE any.
  DATA lv_equals TYPE abap_bool.
  FIELD-SYMBOLS <ls_importing> LIKE LINE OF it_importing.

  LOOP AT mt_method_call_patterns ASSIGNING <ls_method_call_pattern>.
    CLEAR: lv_index.
    lv_equals = abap_true.
    LOOP AT <ls_method>-parameters ASSIGNING <ls_parameter> WHERE parm_kind = cl_abap_objectdescr=>importing.
*     compare IMPORTING parameters
      READ TABLE it_importing ASSIGNING <ls_importing> WITH KEY parameter = <ls_parameter>-name.
      IF sy-subrc = 0.
        READ TABLE <ls_method_call_pattern>-importing INTO ls_importing WITH KEY parameter = <ls_parameter>-name.
        IF sy-subrc = 0.
          ASSIGN ls_importing-value->* TO <lv_val>.
          ASSIGN <ls_importing>-value->* TO <lv_val_importing>.
          lv_equals = zcl_mocka_value_comparison=>assert_equals( act = <lv_val_importing> exp = <lv_val> ).
        ELSE.
          IF <ls_method_call_pattern>-importing IS NOT INITIAL.
            lv_equals = abap_false.
          ENDIF.
        ENDIF.
      ENDIF.
      IF lv_equals = abap_false.
        EXIT.
      ENDIF.
    ENDLOOP.
    IF lv_equals = abap_false.
      CONTINUE.
    ENDIF.
    LOOP AT <ls_method>-parameters ASSIGNING <ls_parameter> WHERE parm_kind = cl_abap_objectdescr=>changing.
*     compare CHANGING parameters
      READ TABLE it_changing_in ASSIGNING <ls_importing> WITH KEY parameter = <ls_parameter>-name.
      IF sy-subrc = 0.
        READ TABLE <ls_method_call_pattern>-changing_in INTO ls_importing WITH KEY parameter = <ls_parameter>-name.
        IF sy-subrc = 0.
          ASSIGN ls_importing-value->* TO <lv_val>.
          ASSIGN <ls_importing>-value->* TO <lv_val_importing>.
          lv_equals = zcl_mocka_value_comparison=>assert_equals( act = <lv_val_importing> exp = <lv_val> ).
        ELSE.
          IF <ls_method_call_pattern>-changing_in IS NOT INITIAL.
            lv_equals = abap_false.
          ENDIF.
        ENDIF.
      ENDIF.
      IF lv_equals = abap_false.
        EXIT.
      ENDIF.
    ENDLOOP.
    IF lv_equals = abap_false.
      CONTINUE.
    ELSE.
      er_result = <ls_method_call_pattern>-returning.
      ev_exception = <ls_method_call_pattern>-raises_by_name.
      eo_cx_root = <ls_method_call_pattern>-raises.
      et_exporting = <ls_method_call_pattern>-exporting.
      et_changing_out = <ls_method_call_pattern>-changing_out.
      IF <ls_method_call_pattern>-times_resolved > 0.
        CONTINUE."search for another pattern that might fit
      ELSE.
        EXIT.
      ENDIF.
    ENDIF.
  ENDLOOP.
  IF <ls_method_call_pattern> IS ASSIGNED AND ( iv_increase_call_counter = abap_true OR ev_exception IS NOT INITIAL OR eo_cx_root IS NOT INITIAL ).
    ADD 1 TO <ls_method_call_pattern>-times_resolved.
  ENDIF.
ENDMETHOD.


METHOD with_internal.
  DATA lv_param_kind TYPE c.
  IF iv_is_importing = abap_true.
    lv_param_kind = 'I'.
  ELSE.
    lv_param_kind = 'C'.
  ENDIF.

  DATA lv_parameter_count TYPE i.
  DATA lv_actual_parameter_count TYPE i.
  DATA lr_ref TYPE REF TO data.

  IF i_p1 IS SUPPLIED.
    ADD 1 TO lv_parameter_count.
  ENDIF.
  IF i_p2 IS SUPPLIED.
    ADD 1 TO lv_parameter_count.
  ENDIF.
  IF i_p3 IS SUPPLIED.
    ADD 1 TO lv_parameter_count.
  ENDIF.
  IF i_p4 IS SUPPLIED.
    ADD 1 TO lv_parameter_count.
  ENDIF.
  IF i_p5 IS SUPPLIED.
    ADD 1 TO lv_parameter_count.
  ENDIF.
  IF i_p6 IS SUPPLIED.
    ADD 1 TO lv_parameter_count.
  ENDIF.
  IF i_p7 IS SUPPLIED.
    ADD 1 TO lv_parameter_count.
  ENDIF.
  IF i_p8 IS SUPPLIED.
    ADD 1 TO lv_parameter_count.
  ENDIF.



  FIELD-SYMBOLS <ls_method> TYPE abap_methdescr.
  DATA lo_objdescr TYPE REF TO cl_abap_objectdescr.

  lo_objdescr = mo_mocker->mo_objectdescr.
  READ TABLE lo_objdescr->methods ASSIGNING <ls_method> WITH KEY name = mv_method_name.
  IF sy-subrc NE 0.
    READ TABLE lo_objdescr->methods ASSIGNING <ls_method> WITH KEY alias_for = mv_method_name.
    IF sy-subrc NE 0.
      RAISE EXCEPTION TYPE zcx_mocka
        EXPORTING
          textid    = zcx_mocka=>no_such_method
          interface = mo_mocker->mv_interface
          method    = mv_method_name.
    ENDIF.
  ENDIF.
* count & verify importing parameters
  LOOP AT <ls_method>-parameters TRANSPORTING NO FIELDS WHERE parm_kind = lv_param_kind.
    ADD 1 TO lv_actual_parameter_count.
  ENDLOOP.
  IF lv_parameter_count > lv_actual_parameter_count.
    RAISE EXCEPTION TYPE zcx_mocka
      EXPORTING
        textid = zcx_mocka=>invalid_parameter_count.
  ENDIF.

* map importing parameters to current method call pattern
  DATA ls_importing TYPE zif_mocka_mocker_method=>ty_s_name_value_pair."has the same structure as exporting arguments
  FIELD-SYMBOLS: <ls_parameter> LIKE LINE OF <ls_method>-parameters.
  DATA lv_index TYPE i.
  DATA lv_comp TYPE string.

  FIELD-SYMBOLS <ls_current_call_pattern> LIKE LINE OF mt_current_method_call_pattern.
  DATA lv_lines TYPE i.
  DESCRIBE TABLE mt_current_method_call_pattern LINES lv_lines.

  IF lv_lines > 0.
    READ TABLE mt_current_method_call_pattern ASSIGNING <ls_current_call_pattern> INDEX lv_lines.
    IF iv_is_importing = abap_true AND <ls_current_call_pattern>-importing IS NOT INITIAL.
      APPEND INITIAL LINE TO mt_current_method_call_pattern ASSIGNING <ls_current_call_pattern>.
    ENDIF.
    IF iv_is_importing = abap_false AND <ls_current_call_pattern>-changing_in IS NOT INITIAL.
      APPEND INITIAL LINE TO mt_current_method_call_pattern ASSIGNING <ls_current_call_pattern>.
    ENDIF.
    IF <ls_current_call_pattern>-changing_out IS NOT INITIAL
      OR <ls_current_call_pattern>-exporting IS NOT INITIAL
      OR <ls_current_call_pattern>-returning IS NOT INITIAL
      OR <ls_current_call_pattern>-raises IS NOT INITIAL
      OR <ls_current_call_pattern>-raises_by_name IS NOT INITIAL.
      APPEND INITIAL LINE TO mt_current_method_call_pattern ASSIGNING <ls_current_call_pattern>.
    ENDIF.
  ELSE.
    APPEND INITIAL LINE TO mt_current_method_call_pattern ASSIGNING <ls_current_call_pattern>.
  ENDIF.

  LOOP AT <ls_method>-parameters ASSIGNING <ls_parameter> WHERE parm_kind = lv_param_kind.
    ADD 1 TO lv_index.
    CASE lv_index.
      WHEN 1.
        GET REFERENCE OF i_p1 INTO lr_ref.
        ls_importing-value = copy_value( lr_ref ).
      WHEN 2.
        GET REFERENCE OF i_p2 INTO lr_ref.
        ls_importing-value = copy_value( lr_ref ).
      WHEN 3.
        GET REFERENCE OF i_p3 INTO lr_ref.
        ls_importing-value = copy_value( lr_ref ).
      WHEN 4.
        GET REFERENCE OF i_p4 INTO lr_ref.
        ls_importing-value = copy_value( lr_ref ).
      WHEN 5.
        GET REFERENCE OF i_p5 INTO lr_ref.
        ls_importing-value = copy_value( lr_ref ).
      WHEN 6.
        GET REFERENCE OF i_p6 INTO lr_ref.
        ls_importing-value = copy_value( lr_ref ).
      WHEN 7.
        GET REFERENCE OF i_p7 INTO lr_ref.
        ls_importing-value = copy_value( lr_ref ).
      WHEN 8.
        GET REFERENCE OF i_p8 INTO lr_ref.
        ls_importing-value = copy_value( lr_ref ).
    ENDCASE.
    ls_importing-parameter = <ls_parameter>-name.

    IF iv_is_importing = abap_true.
      APPEND ls_importing TO <ls_current_call_pattern>-importing.
    ELSE.
      APPEND ls_importing TO <ls_current_call_pattern>-changing_in.
    ENDIF.
  ENDLOOP.

  ro_self = me.
ENDMETHOD.


METHOD zif_mocka_mocker_method_runtim~increase_times_called.
  increase_call_count( iv_increment ).
ENDMETHOD.


METHOD zif_mocka_mocker_method_runtim~register_has_been_called_with.
  DATA ls_method_call LIKE LINE OF mt_method_calls.
  DATA ls_importing LIKE LINE OF ls_method_call-importing.
  FIELD-SYMBOLS <ls_importing> LIKE LINE OF ls_method_call-importing.
  DATA ls_changing_in LIKE LINE OF ls_method_call-changing_in.
  FIELD-SYMBOLS <ls_changing_in> LIKE LINE OF ls_method_call-changing_in.

  LOOP AT it_importing ASSIGNING <ls_importing>.
    ls_importing-parameter = <ls_importing>-parameter.
    ls_importing-value = copy_value( <ls_importing>-value ).
    APPEND ls_importing TO ls_method_call-importing.
  ENDLOOP.

  LOOP AT it_changing_in ASSIGNING <ls_changing_in>.
    ls_changing_in-parameter = <ls_changing_in>-parameter.
    ls_changing_in-value = copy_value( <ls_changing_in>-value ).
    APPEND ls_changing_in TO ls_method_call-changing_in.
  ENDLOOP.

  APPEND ls_method_call TO mt_method_calls.
ENDMETHOD.


METHOD zif_mocka_mocker_method~changes.
* registers outbound CHANGING parameters
  DATA lv_parameter_count TYPE i.
  DATA lv_actual_parameter_count TYPE i.
  DATA lr_ref TYPE REF TO data.
  FIELD-SYMBOLS <lv_in> TYPE any.
  FIELD-SYMBOLS <lv_to> TYPE any.
  ADD 1 TO lv_parameter_count.
  IF i_p2 IS SUPPLIED.
    ADD 1 TO lv_parameter_count.
  ENDIF.
  IF i_p3 IS SUPPLIED.
    ADD 1 TO lv_parameter_count.
  ENDIF.
  IF i_p4 IS SUPPLIED.
    ADD 1 TO lv_parameter_count.
  ENDIF.
  IF i_p5 IS SUPPLIED.
    ADD 1 TO lv_parameter_count.
  ENDIF.
  IF i_p6 IS SUPPLIED.
    ADD 1 TO lv_parameter_count.
  ENDIF.
  IF i_p7 IS SUPPLIED.
    ADD 1 TO lv_parameter_count.
  ENDIF.
  IF i_p8 IS SUPPLIED.
    ADD 1 TO lv_parameter_count.
  ENDIF.

  FIELD-SYMBOLS <ls_method> TYPE abap_methdescr.
  DATA lo_objdescr TYPE REF TO cl_abap_objectdescr.

  lo_objdescr = mo_mocker->mo_objectdescr.
  READ TABLE lo_objdescr->methods ASSIGNING <ls_method> WITH KEY name = mv_method_name.
  IF sy-subrc NE 0.
    RAISE EXCEPTION TYPE zcx_mocka
      EXPORTING
        textid    = zcx_mocka=>no_such_method
        interface = mo_mocker->mv_interface
        method    = mv_method_name.
  ENDIF.
* count & verify importing parameters
  LOOP AT <ls_method>-parameters TRANSPORTING NO FIELDS WHERE parm_kind = 'C'.
    ADD 1 TO lv_actual_parameter_count.
  ENDLOOP.
  IF lv_parameter_count > lv_actual_parameter_count.
    RAISE EXCEPTION TYPE zcx_mocka
      EXPORTING
        textid = zcx_mocka=>invalid_parameter_count.
  ENDIF.

* map importing parameters to current method call pattern
  DATA ls_changing_out TYPE zif_mocka_mocker_method=>ty_s_name_value_pair.
  FIELD-SYMBOLS: <ls_parameter> LIKE LINE OF <ls_method>-parameters.
  DATA lv_index TYPE i.
  DATA lv_comp TYPE string.

  FIELD-SYMBOLS <ls_current_call_pattern> LIKE LINE OF mt_current_method_call_pattern.
  LOOP AT mt_current_method_call_pattern ASSIGNING <ls_current_call_pattern>.
    FREE: <ls_current_call_pattern>-changing_out.
  ENDLOOP.

  READ TABLE <ls_method>-parameters ASSIGNING <ls_parameter> WITH KEY parm_kind = 'C'.
  IF sy-subrc NE 0.
    DATA lv_interface TYPE abap_abstypename.
    lv_interface =  mo_mocker->zif_mocka_mocker~get_interface( ).
    RAISE EXCEPTION TYPE zcx_mocka
      EXPORTING
        textid    = zcx_mocka=>no_changing_parameters
        interface = lv_interface
        method    = mv_method_name.
  ENDIF.
  LOOP AT <ls_method>-parameters ASSIGNING <ls_parameter> WHERE parm_kind = 'C'.
    ADD 1 TO lv_index.
    CASE lv_index.
      WHEN 1.
        GET REFERENCE OF i_p1 INTO lr_ref.
        ls_changing_out-value = copy_value( lr_ref ).
      WHEN 2.
        GET REFERENCE OF i_p2 INTO lr_ref.
        ls_changing_out-value = copy_value( lr_ref ).
      WHEN 3.
        GET REFERENCE OF i_p3 INTO lr_ref.
        ls_changing_out-value = copy_value( lr_ref ).
      WHEN 4.
        GET REFERENCE OF i_p4 INTO lr_ref.
        ls_changing_out-value = copy_value( lr_ref ).
      WHEN 5.
        GET REFERENCE OF i_p5 INTO lr_ref.
        ls_changing_out-value = copy_value( lr_ref ).
      WHEN 6.
        GET REFERENCE OF i_p6 INTO lr_ref.
        ls_changing_out-value = copy_value( lr_ref ).
      WHEN 7.
        GET REFERENCE OF i_p7 INTO lr_ref.
        ls_changing_out-value = copy_value( lr_ref ).
      WHEN 8.
        GET REFERENCE OF i_p8 INTO lr_ref.
        ls_changing_out-value = copy_value( lr_ref ).
    ENDCASE.
    ls_changing_out-parameter = <ls_parameter>-name.
    LOOP AT mt_current_method_call_pattern ASSIGNING <ls_current_call_pattern>.
      APPEND ls_changing_out TO <ls_current_call_pattern>-changing_out.
    ENDLOOP.
  ENDLOOP.

  ro_mocker_method = me.
ENDMETHOD.


METHOD ZIF_MOCKA_MOCKER_method~export.
  CALL METHOD me->resolve_method_output
    EXPORTING
      it_importing    = it_importing
      it_changing_in  = it_changing_in
      iv_increase_call_counter = abap_true
    IMPORTING
      et_exporting    = et_exporting
      et_changing_out = et_changing_out.
ENDMETHOD.


METHOD zif_mocka_mocker_method~exports.
* registers EXPORTING parameters
  DATA lv_parameter_count TYPE i.
  DATA lv_actual_parameter_count TYPE i.
  DATA lr_ref TYPE REF TO data.
  FIELD-SYMBOLS <lv_in> TYPE any.
  FIELD-SYMBOLS <lv_to> TYPE any.

  ADD 1 TO lv_parameter_count.
  IF i_p2 IS SUPPLIED.
    ADD 1 TO lv_parameter_count.
  ENDIF.
  IF i_p3 IS SUPPLIED.
    ADD 1 TO lv_parameter_count.
  ENDIF.
  IF i_p4 IS SUPPLIED.
    ADD 1 TO lv_parameter_count.
  ENDIF.
  IF i_p5 IS SUPPLIED.
    ADD 1 TO lv_parameter_count.
  ENDIF.
  IF i_p6 IS SUPPLIED.
    ADD 1 TO lv_parameter_count.
  ENDIF.
  IF i_p7 IS SUPPLIED.
    ADD 1 TO lv_parameter_count.
  ENDIF.
  IF i_p8 IS SUPPLIED.
    ADD 1 TO lv_parameter_count.
  ENDIF.

  FIELD-SYMBOLS <ls_method> TYPE abap_methdescr.
  DATA lo_objdescr TYPE REF TO cl_abap_objectdescr.

  lo_objdescr = mo_mocker->mo_objectdescr.
  READ TABLE lo_objdescr->methods ASSIGNING <ls_method> WITH KEY name = mv_method_name.
  IF sy-subrc NE 0.
    RAISE EXCEPTION TYPE zcx_mocka
      EXPORTING
        textid    = zcx_mocka=>no_such_method
        interface = mo_mocker->mv_interface
        method    = mv_method_name.
  ENDIF.
* count & verify importing parameters
  LOOP AT <ls_method>-parameters TRANSPORTING NO FIELDS WHERE parm_kind = 'E'.
    ADD 1 TO lv_actual_parameter_count.
  ENDLOOP.
  IF lv_parameter_count > lv_actual_parameter_count.
    RAISE EXCEPTION TYPE zcx_mocka
      EXPORTING
        textid = zcx_mocka=>invalid_parameter_count.
  ENDIF.

* map importing parameters to current method call pattern
  DATA ls_exporting TYPE zif_mocka_mocker_method=>ty_s_name_value_pair.

  FIELD-SYMBOLS: <ls_parameter> LIKE LINE OF <ls_method>-parameters.
  DATA lv_index TYPE i.
  DATA lv_comp TYPE string.

  FIELD-SYMBOLS <ls_current_call_pattern> LIKE LINE OF mt_current_method_call_pattern.
  IF mt_current_method_call_pattern IS INITIAL.
    APPEND INITIAL LINE TO mt_current_method_call_pattern ASSIGNING <ls_current_call_pattern>.
  ENDIF.
  LOOP AT mt_current_method_call_pattern ASSIGNING <ls_current_call_pattern>.
    FREE: <ls_current_call_pattern>-exporting.
  ENDLOOP.
  READ TABLE <ls_method>-parameters ASSIGNING <ls_parameter> WITH KEY parm_kind = 'E'.
  IF sy-subrc NE 0.
    DATA lv_interface TYPE abap_abstypename.
    lv_interface =  mo_mocker->zif_mocka_mocker~get_interface( ).
    RAISE EXCEPTION TYPE zcx_mocka
      EXPORTING
        textid    = zcx_mocka=>no_exporting_parameters
        interface = lv_interface
        method    = mv_method_name.
  ENDIF.
  LOOP AT <ls_method>-parameters ASSIGNING <ls_parameter> WHERE parm_kind = 'E'.
    ADD 1 TO lv_index.
    CASE lv_index.
      WHEN 1.
        GET REFERENCE OF i_p1 INTO lr_ref.
        ls_exporting-value = copy_value( lr_ref ).
      WHEN 2.
        GET REFERENCE OF i_p2 INTO lr_ref.
        ls_exporting-value = copy_value( lr_ref ).
      WHEN 3.
        GET REFERENCE OF i_p3 INTO lr_ref.
        ls_exporting-value = copy_value( lr_ref ).
      WHEN 4.
        GET REFERENCE OF i_p4 INTO lr_ref.
        ls_exporting-value = copy_value( lr_ref ).
      WHEN 5.
        GET REFERENCE OF i_p5 INTO lr_ref.
        ls_exporting-value = copy_value( lr_ref ).
      WHEN 6.
        GET REFERENCE OF i_p6 INTO lr_ref.
        ls_exporting-value = copy_value( lr_ref ).
      WHEN 7.
        GET REFERENCE OF i_p7 INTO lr_ref.
        ls_exporting-value = copy_value( lr_ref ).
      WHEN 8.
        GET REFERENCE OF i_p8 INTO lr_ref.
        ls_exporting-value = copy_value( lr_ref ).
    ENDCASE.
    ls_exporting-parameter = <ls_parameter>-name.

    LOOP AT mt_current_method_call_pattern ASSIGNING <ls_current_call_pattern>.
      APPEND ls_exporting TO <ls_current_call_pattern>-exporting.
    ENDLOOP.
  ENDLOOP.

  finalize_current_method_sign( ).
  ro_mocker_method = me.
ENDMETHOD.


METHOD ZIF_MOCKA_MOCKER_method~finalize_current_method_sign.
  ro_mocker = finalize_current_method_sign( ).
ENDMETHOD.


METHOD ZIF_MOCKA_MOCKER_method~generate_mockup.
  ro_mockup = mo_mocker->ZIF_MOCKA_MOCKER~generate_mockup( ).
ENDMETHOD.


METHOD ZIF_MOCKA_MOCKER_method~get_all_raises_by_name.
  FIELD-SYMBOLS <ls_pattern> LIKE LINE OF mt_method_call_patterns.
  LOOP AT mt_method_call_patterns ASSIGNING <ls_pattern> WHERE raises_by_name IS NOT INITIAL.
    APPEND <ls_pattern>-raises_by_name TO rt_raises.
  ENDLOOP.
ENDMETHOD.


METHOD zif_mocka_mocker_method~has_been_called_with.

  DATA lv_param_kind TYPE c.
  DATA lv_is_importing TYPE abap_bool VALUE abap_true.
  DATA ls_method_call_pattern LIKE LINE OF mt_current_method_call_pattern.
  IF lv_is_importing = abap_true."toDo: support changing parameters
    lv_param_kind = cl_abap_objectdescr=>importing.
  ELSE.
    lv_param_kind = cl_abap_objectdescr=>changing.
  ENDIF.

  DATA lv_parameter_count TYPE i.
  DATA lv_actual_parameter_count TYPE i.
  DATA lr_ref TYPE REF TO data.

  IF i_p1 IS SUPPLIED.
    ADD 1 TO lv_parameter_count.
  ENDIF.
  IF i_p2 IS SUPPLIED.
    ADD 1 TO lv_parameter_count.
  ENDIF.
  IF i_p3 IS SUPPLIED.
    ADD 1 TO lv_parameter_count.
  ENDIF.
  IF i_p4 IS SUPPLIED.
    ADD 1 TO lv_parameter_count.
  ENDIF.
  IF i_p5 IS SUPPLIED.
    ADD 1 TO lv_parameter_count.
  ENDIF.
  IF i_p6 IS SUPPLIED.
    ADD 1 TO lv_parameter_count.
  ENDIF.
  IF i_p7 IS SUPPLIED.
    ADD 1 TO lv_parameter_count.
  ENDIF.
  IF i_p8 IS SUPPLIED.
    ADD 1 TO lv_parameter_count.
  ENDIF.

  FIELD-SYMBOLS <ls_method> TYPE abap_methdescr.
  DATA lo_objdescr TYPE REF TO cl_abap_objectdescr.

  lo_objdescr = mo_mocker->mo_objectdescr.
  READ TABLE lo_objdescr->methods ASSIGNING <ls_method> WITH KEY name = mv_method_name.
  IF sy-subrc NE 0.
    READ TABLE lo_objdescr->methods ASSIGNING <ls_method> WITH KEY alias_for = mv_method_name.
    IF sy-subrc NE 0.
      RAISE EXCEPTION TYPE zcx_mocka
        EXPORTING
          textid    = zcx_mocka=>no_such_method
          interface = mo_mocker->mv_interface
          method    = mv_method_name.
    ENDIF.
  ENDIF.
* count & verify importing parameters
  LOOP AT <ls_method>-parameters TRANSPORTING NO FIELDS WHERE parm_kind = lv_param_kind.
    ADD 1 TO lv_actual_parameter_count.
  ENDLOOP.
  IF lv_parameter_count > lv_actual_parameter_count.
    RAISE EXCEPTION TYPE zcx_mocka
      EXPORTING
        textid = zcx_mocka=>invalid_parameter_count.
  ENDIF.

* map importing parameters to current method call pattern
  DATA ls_importing LIKE LINE OF ls_method_call_pattern-importing."has the same structure as exporting arguments
  FIELD-SYMBOLS: <ls_parameter> LIKE LINE OF <ls_method>-parameters.
  DATA lv_index TYPE i.
  DATA lv_comp TYPE string.

  LOOP AT <ls_method>-parameters ASSIGNING <ls_parameter> WHERE parm_kind = lv_param_kind.
    ADD 1 TO lv_index.
    CASE lv_index.
      WHEN 1.
        GET REFERENCE OF i_p1 INTO lr_ref.
        ls_importing-value = copy_value( lr_ref ).
      WHEN 2.
        GET REFERENCE OF i_p2 INTO lr_ref.
        ls_importing-value = copy_value( lr_ref ).
      WHEN 3.
        GET REFERENCE OF i_p3 INTO lr_ref.
        ls_importing-value = copy_value( lr_ref ).
      WHEN 4.
        GET REFERENCE OF i_p4 INTO lr_ref.
        ls_importing-value = copy_value( lr_ref ).
      WHEN 5.
        GET REFERENCE OF i_p5 INTO lr_ref.
        ls_importing-value = copy_value( lr_ref ).
      WHEN 6.
        GET REFERENCE OF i_p6 INTO lr_ref.
        ls_importing-value = copy_value( lr_ref ).
      WHEN 7.
        GET REFERENCE OF i_p7 INTO lr_ref.
        ls_importing-value = copy_value( lr_ref ).
      WHEN 8.
        GET REFERENCE OF i_p8 INTO lr_ref.
        ls_importing-value = copy_value( lr_ref ).
    ENDCASE.
    ls_importing-parameter = <ls_parameter>-name.
    IF lv_is_importing = abap_true.
      APPEND ls_importing TO ls_method_call_pattern-importing.
    ELSE.
      APPEND ls_importing TO ls_method_call_pattern-changing_in.
    ENDIF.
  ENDLOOP.

  CALL METHOD has_been_called_with
    EXPORTING
      it_importing       = ls_method_call_pattern-importing
      it_changing_in     = ls_method_call_pattern-changing_in
    RECEIVING
      rv_has_been_called = rv_has_been_called.

ENDMETHOD.


METHOD ZIF_MOCKA_MOCKER_method~has_method_been_called.
  DATA lv_call_count TYPE i.
  CALL METHOD me->ZIF_MOCKA_MOCKER_method~times_called
    RECEIVING
      rv_times = lv_call_count.
  IF lv_call_count > 0.
    rv_has_been_called = abap_true.
  ELSE.
    rv_has_been_called = abap_false.
  ENDIF.
ENDMETHOD.


METHOD ZIF_MOCKA_MOCKER_method~has_registered_call_pattern.
  IF mt_method_call_patterns IS NOT INITIAL.
    rv_has_pattern_registered = abap_true.
  ENDIF.
ENDMETHOD.


METHOD ZIF_MOCKA_MOCKER_method~raise.
  DATA lo_cx_root TYPE REF TO cx_root.
  CALL METHOD me->resolve_method_output
    EXPORTING
      it_importing   = it_importing
      it_changing_in = it_changing_in
    IMPORTING
      ev_exception   = rv_exception
      eo_cx_root     = lo_cx_root.
  IF lo_cx_root IS NOT INITIAL.
    RAISE EXCEPTION lo_cx_root.
  ENDIF.
ENDMETHOD.


METHOD zif_mocka_mocker_method~raises.
  IF mt_current_method_call_pattern IS INITIAL.
    APPEND INITIAL LINE TO mt_current_method_call_pattern.
  ENDIF.

  FIELD-SYMBOLS <ls_current_call_pattern> LIKE LINE OF mt_current_method_call_pattern.
  LOOP AT mt_current_method_call_pattern ASSIGNING <ls_current_call_pattern>.
    CLEAR: <ls_current_call_pattern>-raises_by_name.
    <ls_current_call_pattern>-raises = io_cx_root.
  ENDLOOP.
  finalize_current_method_sign( ).
ENDMETHOD.


METHOD zif_mocka_mocker_method~raises_by_name.
* registers an exception that is specified by a name
  DATA: ls_class_descr TYPE vseoclass,
        ls_seoclskey TYPE seoclskey,
        lv_exception TYPE seoclsname.
  DATA lv_interface TYPE abap_abstypename.
  lv_exception = iv_exception.
  TRANSLATE lv_exception TO UPPER CASE.

  ls_seoclskey-clsname = lv_exception.
  CALL FUNCTION 'SEO_CLASS_READ'
    EXPORTING
      clskey = ls_seoclskey
    IMPORTING
      class  = ls_class_descr.
  IF ls_class_descr IS INITIAL.
    lv_interface = mo_mocker->zif_mocka_mocker~get_interface( ).
    RAISE EXCEPTION TYPE zcx_mocka
      EXPORTING
        textid    = zcx_mocka=>no_such_exception
        interface = lv_interface
        exception = lv_exception
        method    = mv_method_name.
  ENDIF.
  IF ls_class_descr-category NE seoc_category_exception.
    RAISE EXCEPTION TYPE zcx_mocka
      EXPORTING
        textid    = zcx_mocka=>invalid_exception
        exception = lv_exception.
  ENDIF.
  IF ls_class_descr-clsabstrct = abap_true.
    RAISE EXCEPTION TYPE zcx_mocka
      EXPORTING
        textid    = zcx_mocka=>abstract_exception
        exception = lv_exception.
  ENDIF.

  IF mt_current_method_call_pattern IS INITIAL.
    APPEND INITIAL LINE TO mt_current_method_call_pattern.
  ENDIF.

  FIELD-SYMBOLS <ls_current_call_pattern> LIKE LINE OF mt_current_method_call_pattern.
  LOOP AT mt_current_method_call_pattern ASSIGNING <ls_current_call_pattern>.
    FREE: <ls_current_call_pattern>-raises.
    <ls_current_call_pattern>-raises_by_name = lv_exception.
  ENDLOOP.

  finalize_current_method_sign( ).
  ro_mocker_method = me.
ENDMETHOD.


METHOD ZIF_MOCKA_MOCKER_method~return.
  CALL METHOD me->resolve_method_output
    EXPORTING
      it_importing   = it_importing
      it_changing_in = it_changing_in
      iv_increase_call_counter = abap_true
    IMPORTING
*     et_exporting   =
      er_result      = r_result
*     ev_exception   =
    .

ENDMETHOD.


METHOD zif_mocka_mocker_method~returns.
* registers the method's RETURNING parameter
  TRY.
      me->zif_mocka_mocker_method~exports( i_return ).
    CATCH zcx_mocka.
      DATA lr_ref TYPE REF TO data.
      FIELD-SYMBOLS: <lv_in> TYPE any, <lv_to> TYPE any.
      GET REFERENCE OF i_return INTO lr_ref.

      ASSIGN lr_ref->* TO <lv_in>.

      FIELD-SYMBOLS <ls_current_call_pattern> LIKE LINE OF mt_current_method_call_pattern.
      IF mt_current_method_call_pattern IS INITIAL.
        APPEND INITIAL LINE TO mt_current_method_call_pattern ASSIGNING <ls_current_call_pattern>.
      ENDIF.

      LOOP AT mt_current_method_call_pattern ASSIGNING <ls_current_call_pattern>.
        CREATE DATA <ls_current_call_pattern>-returning LIKE <lv_in>.
        ASSIGN <ls_current_call_pattern>-returning->* TO <lv_to>.
        <lv_to> = <lv_in>.
      ENDLOOP.
  ENDTRY.

  finalize_current_method_sign( ).
  ro_mocker_method = me.
ENDMETHOD.


METHOD ZIF_MOCKA_MOCKER_method~times_called.
  rv_times = mv_times_called.
ENDMETHOD.


METHOD zif_mocka_mocker_method~with.
  DATA lt_params TYPE abap_parmbind_tab.
  DATA ls_param TYPE abap_parmbind.
  DATA lv_iv_is_importing TYPE abap_bool VALUE abap_true.
  FIELD-SYMBOLS <lv_val> TYPE any.
  FIELD-SYMBOLS <lv_val2> TYPE any.

  ls_param-kind = 'E'.
  IF i_p1 IS SUPPLIED.
    GET REFERENCE OF i_p1 INTO ls_param-value.
    ls_param-name = 'I_P1'.
    INSERT ls_param INTO TABLE lt_params.
  ENDIF.
  IF i_p2 IS SUPPLIED.
    GET REFERENCE OF i_p2 INTO ls_param-value.
    ls_param-name = 'I_P2'.
    INSERT ls_param INTO TABLE lt_params.
  ENDIF.
  IF i_p3 IS SUPPLIED.
    GET REFERENCE OF i_p3 INTO ls_param-value.
    ls_param-name = 'I_P3'.
    INSERT ls_param INTO TABLE lt_params.
  ENDIF.
  IF i_p4 IS SUPPLIED.
    GET REFERENCE OF i_p4 INTO ls_param-value.
    ls_param-name = 'I_P4'.
    INSERT ls_param INTO TABLE lt_params.
  ENDIF.
  IF i_p5 IS SUPPLIED.
    GET REFERENCE OF i_p5 INTO ls_param-value.
    ls_param-name = 'I_P5'.
    INSERT ls_param INTO TABLE lt_params.
  ENDIF.
  IF i_p6 IS SUPPLIED.
    GET REFERENCE OF i_p6 INTO ls_param-value.
    ls_param-name = 'I_P6'.
    INSERT ls_param INTO TABLE lt_params.
  ENDIF.
  IF i_p7 IS SUPPLIED.
    GET REFERENCE OF i_p7 INTO ls_param-value.
    ls_param-name = 'I_P7'.
    INSERT ls_param INTO TABLE lt_params.
  ENDIF.
  IF i_p8 IS SUPPLIED.
    GET REFERENCE OF i_p8 INTO ls_param-value.
    ls_param-name = 'I_P8'.
    INSERT ls_param INTO TABLE lt_params.
  ENDIF.

  ls_param-name = 'IV_IS_IMPORTING'.
  GET REFERENCE OF lv_iv_is_importing INTO ls_param-value.
  INSERT ls_param INTO TABLE lt_params.

  CALL METHOD ('WITH_INTERNAL')
      PARAMETER-TABLE
      lt_params.

  ro_mocker_method = me.
ENDMETHOD.


METHOD ZIF_MOCKA_MOCKER_method~with_changing.
  DATA lt_params TYPE abap_parmbind_tab.
  DATA ls_param TYPE abap_parmbind.
  DATA lv_iv_is_importing TYPE abap_bool.
  FIELD-SYMBOLS <lv_val> TYPE any.
  FIELD-SYMBOLS <lv_val2> TYPE any.

  ls_param-kind = 'E'.
  IF i_p1 IS SUPPLIED.
    GET REFERENCE OF i_p1 INTO ls_param-value.
    ls_param-name = 'I_P1'.
    INSERT ls_param INTO TABLE lt_params.
  ENDIF.
  IF i_p2 IS SUPPLIED.
    GET REFERENCE OF i_p2 INTO ls_param-value.
    ls_param-name = 'I_P2'.
    INSERT ls_param INTO TABLE lt_params.
  ENDIF.
  IF i_p3 IS SUPPLIED.
    GET REFERENCE OF i_p3 INTO ls_param-value.
    ls_param-name = 'I_P3'.
    INSERT ls_param INTO TABLE lt_params.
  ENDIF.
  IF i_p4 IS SUPPLIED.
    GET REFERENCE OF i_p4 INTO ls_param-value.
    ls_param-name = 'I_P4'.
    INSERT ls_param INTO TABLE lt_params.
  ENDIF.
  IF i_p5 IS SUPPLIED.
    GET REFERENCE OF i_p5 INTO ls_param-value.
    ls_param-name = 'I_P5'.
    INSERT ls_param INTO TABLE lt_params.
  ENDIF.
  IF i_p6 IS SUPPLIED.
    GET REFERENCE OF i_p6 INTO ls_param-value.
    ls_param-name = 'I_P6'.
    INSERT ls_param INTO TABLE lt_params.
  ENDIF.
  IF i_p7 IS SUPPLIED.
    GET REFERENCE OF i_p7 INTO ls_param-value.
    ls_param-name = 'I_P7'.
    INSERT ls_param INTO TABLE lt_params.
  ENDIF.
  IF i_p8 IS SUPPLIED.
    GET REFERENCE OF i_p8 INTO ls_param-value.
    ls_param-name = 'I_P8'.
    INSERT ls_param INTO TABLE lt_params.
  ENDIF.

  ls_param-name = 'IV_IS_IMPORTING'.
  GET REFERENCE OF lv_iv_is_importing INTO ls_param-value.
  INSERT ls_param INTO TABLE lt_params.

  CALL METHOD ('WITH_INTERNAL')
      PARAMETER-TABLE
      lt_params.

  ro_mocker_method = me.
ENDMETHOD.
ENDCLASS.
