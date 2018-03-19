interface ZIF_MOCKA_IS_IN_TIME_INFO
  public .

  type-pools ABAP .

  constants GC_NAME type ABAP_ABSTYPENAME value 'ZIF_MOCKA_IS_IN_TIME_INFO' ##NO_TEXT.

  methods IS_IN_TIME_BY_CHANGING_PARAM
    importing
      !IV_CARRID type S_CARR_ID
      !IV_CONNID type S_CONN_ID
    exporting
      !EV_IS_IN_TIME type ABAP_BOOL
    changing
      !CV_FLDATE type S_DATE .
  methods IS_IN_TIME
    importing
      !IV_CARRID type S_CARR_ID optional
      !IV_CONNID type S_CONN_ID optional
      !IV_FLDATE type S_DATE optional
    returning
      value(RV_IS_IN_TIME) type ABAP_BOOL .
  methods GET_DELAY
    importing
      !IV_CARRID type S_CARR_ID
      !IV_CONNID type S_CONN_ID
      !IV_FLDATE type S_DATE
    returning
      value(RV_DELAY) type INT4 .
  methods GET_BOTH_BY_OPTIONAL_PARAM
    importing
      !IV_CARRID type S_CARR_ID default 'LH'
      !IV_CONNID type S_CONN_ID default 402
      !IV_FLDATE type S_DATE default '20121124'
    exporting
      !EV_DELAY type I
      !EV_IS_IN_TIME type ABAP_BOOL .
  methods GET_BOTH
    importing
      !IV_CARRID type S_CARR_ID
      !IV_CONNID type S_CONN_ID
      !IV_FLDATE type S_DATE
    exporting
      !EV_DELAY type I
      !EV_IS_IN_TIME type ABAP_BOOL .
  methods GET_BY_OPTIONAL_PARAMS
    importing
      !IV_CARRID type S_CARR_ID default 'LH'
      !IV_CONNID type S_CONN_ID default 402
      !IV_FLDATE type S_DATE default '20121124'
    returning
      value(RV_IS_IN_TIME) type ABAP_BOOL .
endinterface.
