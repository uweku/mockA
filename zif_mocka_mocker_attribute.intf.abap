interface ZIF_MOCKA_MOCKER_ATTRIBUTE
  public .

  type-pools ABAP .
  type-pools SEOS .

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

  methods RETURNS
    importing
      !I_RETURN type ANY
    returning
      value(RO_MOCKER) type ref to ZIF_MOCKA_MOCKER .
  methods RETURN
    returning
      value(R_RESULT) type ref to DATA .
  methods IS_VALUE_SPECIFIED
    returning
      value(RV_IS_VALUE_SPECIFIED) type ABAP_BOOL .
endinterface.
