class ZCL_MOCKA_MOCKER_ATTRIBUTE definition
  public
  final
  create public .

public section.
  type-pools ABAP .
  type-pools SEOS .

  interfaces ZIF_MOCKA_MOCKER_ATTRIBUTE .

  methods CONSTRUCTOR
    importing
      !IV_ATTRIBUTE type SEOCPDNAME
      !IO_MOCKER type ref to ZIF_MOCKA_MOCKER .
protected section.

  data MR_VALUE type ref to DATA .
  data MV_IS_SPECIFIED type ABAP_BOOL .

  methods COPY_VALUE
    importing
      !IR_REF type ref to DATA
    returning
      value(RR_REF) type ref to DATA .
private section.

  data MV_ATTRIBUTE type SEOCPDNAME .
  data MO_MOCKER type ref to ZIF_MOCKA_MOCKER .
ENDCLASS.



CLASS ZCL_MOCKA_MOCKER_ATTRIBUTE IMPLEMENTATION.


METHOD constructor.
  mv_attribute = iv_attribute.
  mo_mocker = io_mocker.
ENDMETHOD.


METHOD COPY_VALUE.
  FIELD-SYMBOLS <lv_in> TYPE any.
  FIELD-SYMBOLS <lv_out> TYPE any.

  ASSIGN ir_ref->* TO <lv_in>.
  CREATE DATA rr_ref LIKE <lv_in>.
  ASSIGN rr_ref->* TO <lv_out>.
  <lv_out> = <lv_in>.
ENDMETHOD.


METHOD zif_mocka_mocker_attribute~is_value_specified.
  rv_is_value_specified = mv_is_specified.
ENDMETHOD.


METHOD zif_mocka_mocker_attribute~return.
  r_result = mr_value.
ENDMETHOD.


METHOD zif_mocka_mocker_attribute~returns.
  DATA lr_value TYPE REF TO data.
  GET REFERENCE OF i_return INTO lr_value.
  mr_value = copy_value( lr_value ).
  mv_is_specified = abap_true.
  ro_mocker = mo_mocker.
ENDMETHOD.
ENDCLASS.
