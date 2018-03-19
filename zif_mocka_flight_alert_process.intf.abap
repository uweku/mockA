interface ZIF_MOCKA_FLIGHT_ALERT_PROCESS
  public .


  methods ALERT_DELAY
    importing
      !IV_CARRID type S_CARR_ID
      !IV_CONNID type S_CONN_ID
      !IV_FLDATE type S_DATE
    returning
      value(RV_IS_IN_TIME) type ABAP_BOOL .
endinterface.
