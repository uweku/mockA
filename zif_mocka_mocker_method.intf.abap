interface ZIF_MOCKA_MOCKER_METHOD
  public .

  type-pools ABAP .

  types TY_T_CLASS type SWF_CLASSES .
  types:
    BEGIN OF ty_s_name_value_pair,  parameter TYPE seosconame,  value TYPE REF TO data,  END OF ty_s_name_value_pair .
  types:
    ty_t_name_value_pair TYPE STANDARD TABLE OF ty_s_name_value_pair WITH KEY parameter .
  types:
    BEGIN OF ty_s_method_call_pattern,        importing TYPE ty_t_name_value_pair,        changing_in TYPE ty_t_name_value_pair,        changing_out TYPE ty_t_name_value_pair,        exporting TYPE ty_t_name_value_pair,        returning TYPE REF TO data,
   raises TYPE REF TO cx_root,        raises_by_name TYPE seoclsname,        times_resolved TYPE i,  END OF ty_s_method_call_pattern .
  types:
    ty_t_method_call_pattern TYPE TABLE OF ty_s_method_call_pattern .

  methods CHANGES
    importing
      !I_P1 type ANY
      !I_P2 type ANY optional
      !I_P3 type ANY optional
      !I_P4 type ANY optional
      !I_P5 type ANY optional
      !I_P6 type ANY optional
      !I_P7 type ANY optional
      !I_P8 type ANY optional
    returning
      value(RO_MOCKER_METHOD) type ref to ZIF_MOCKA_MOCKER_METHOD .
  methods EXPORTS
    importing
      !I_P1 type ANY
      !I_P2 type ANY optional
      !I_P3 type ANY optional
      !I_P4 type ANY optional
      !I_P5 type ANY optional
      !I_P6 type ANY optional
      !I_P7 type ANY optional
      !I_P8 type ANY optional
    returning
      value(RO_MOCKER_METHOD) type ref to ZIF_MOCKA_MOCKER_METHOD .
  methods HAS_BEEN_CALLED_WITH
    importing
      !I_P1 type ANY optional
      !I_P2 type ANY optional
      !I_P3 type ANY optional
      !I_P4 type ANY optional
      !I_P5 type ANY optional
      !I_P6 type ANY optional
      !I_P7 type ANY optional
      !I_P8 type ANY optional
    preferred parameter I_P1
    returning
      value(RV_HAS_BEEN_CALLED) type ABAP_BOOL .
  methods WITH
    importing
      !I_P1 type ANY optional
      !I_P2 type ANY optional
      !I_P3 type ANY optional
      !I_P4 type ANY optional
      !I_P5 type ANY optional
      !I_P6 type ANY optional
      !I_P7 type ANY optional
      !I_P8 type ANY optional
    preferred parameter I_P1
    returning
      value(RO_MOCKER_METHOD) type ref to ZIF_MOCKA_MOCKER_METHOD .
  methods WITH_CHANGING
    importing
      !I_P1 type ANY optional
      !I_P2 type ANY optional
      !I_P3 type ANY optional
      !I_P4 type ANY optional
      !I_P5 type ANY optional
      !I_P6 type ANY optional
      !I_P7 type ANY optional
      !I_P8 type ANY optional
    preferred parameter I_P1
    returning
      value(RO_MOCKER_METHOD) type ref to ZIF_MOCKA_MOCKER_METHOD .
  methods GENERATE_MOCKUP
    returning
      value(RO_MOCKUP) type ref to OBJECT .
  methods RETURNS
    importing
      !I_RETURN type ANY
    returning
      value(RO_MOCKER_METHOD) type ref to ZIF_MOCKA_MOCKER_METHOD .
  methods EXPORT
    importing
      !IT_IMPORTING type TY_T_NAME_VALUE_PAIR
      !IT_CHANGING_IN type TY_T_NAME_VALUE_PAIR optional
    exporting
      !ET_EXPORTING type TY_T_NAME_VALUE_PAIR
      !ET_CHANGING_OUT type TY_T_NAME_VALUE_PAIR .
  methods HAS_METHOD_BEEN_CALLED
    returning
      value(RV_HAS_BEEN_CALLED) type ABAP_BOOL .
  methods RETURN
    importing
      !IT_IMPORTING type TY_T_NAME_VALUE_PAIR
      !IT_CHANGING_IN type TY_T_NAME_VALUE_PAIR optional
    returning
      value(R_RESULT) type ref to DATA .
  methods TIMES_CALLED
    returning
      value(RV_TIMES) type I .
  methods RAISES
    importing
      !IO_CX_ROOT type ref to CX_ROOT .
  methods RAISES_BY_NAME
    importing
      !IV_EXCEPTION type SEOCLSNAME
    returning
      value(RO_MOCKER_METHOD) type ref to ZIF_MOCKA_MOCKER_METHOD .
  methods RAISE
    importing
      !IT_IMPORTING type TY_T_NAME_VALUE_PAIR
      !IT_CHANGING_IN type TY_T_NAME_VALUE_PAIR optional
    returning
      value(RV_EXCEPTION) type SEOCLSNAME
    raising
      CX_STATIC_CHECK .
  methods GET_ALL_RAISES_BY_NAME
    returning
      value(RT_RAISES) type ZIF_MOCKA_MOCKER_METHOD=>TY_T_CLASS .
  methods FINALIZE_CURRENT_METHOD_SIGN
    returning
      value(RO_MOCKER) type ref to ZIF_MOCKA_MOCKER .
  methods HAS_REGISTERED_CALL_PATTERN
    returning
      value(RV_HAS_PATTERN_REGISTERED) type ABAP_BOOL .
endinterface.
