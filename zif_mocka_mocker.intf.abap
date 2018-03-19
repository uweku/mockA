interface ZIF_MOCKA_MOCKER
  public .

  type-pools ABAP .

  types:
    BEGIN OF TY_S_METHOD_MOCKS,  method_name TYPE SEOCPDNAME,  method_mock TYPE REF TO ZIF_MOCKA_MOCKER_METHOD,  END OF TY_S_METHOD_MOCKS .
  types:
    TY_T_method_mocks type TABLE OF ty_s_method_mocks .

  class-methods MOCK
    importing
      !IV_INTERFACE type ABAP_ABSTYPENAME
    returning
      value(RO_MOCKER) type ref to ZIF_MOCKA_MOCKER .
  methods METHOD
    importing
      !IV_METHOD_NAME type SEOCPDNAME
    returning
      value(RO_METHOD) type ref to ZIF_MOCKA_MOCKER_METHOD .
  methods GENERATE_MOCKUP
    returning
      value(RO_MOCKUP) type ref to OBJECT .
  methods PASS_TO_SUPER_CONSTRUCTOR
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
      value(RO_MOCKER) type ref to ZIF_MOCKA_MOCKER .
  methods HAS_METHOD_BEEN_CALLED
    importing
      !IV_METHOD_NAME type SEOCPDNAME
    returning
      value(RV_HAS_BEEN_CALLED) type ABAP_BOOL .
  methods METHOD_CALL_COUNT
    importing
      !IV_METHOD_NAME type SEOCPDNAME
    returning
      value(RV_CALL_COUNT) type INT4 .
  methods GET_INTERFACE
    returning
      value(RV_INTERFACE) type ABAP_ABSTYPENAME .
  methods HAS_ANY_METHOD_BEEN_CALLED
    returning
      value(RV_HAS_BEEN_CALLED) type ABAP_BOOL .
  methods ATTRIBUTE
    importing
      !IV_ATTRIBUTE type SEOCPDNAME
    returning
      value(RO_ATTRIBUTE) type ref to ZIF_MOCKA_MOCKER_ATTRIBUTE .
endinterface.
