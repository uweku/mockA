class ZCL_MOCKA_FLIGHT_OBSERVER definition
  public
  create public .

public section.

*"* public components of class ZCL_MOCKA_FLIGHT_OBSERVER
*"* do not include other source files here!!!
  methods CONSTRUCTOR
    importing
      !IO_ALERT_PROCESSOR type ref to ZIF_MOCKA_FLIGHT_ALERT_PROCESS
      !IO_IN_TIME_ACCESS type ref to ZIF_MOCKA_IS_IN_TIME_INFO .
  methods OBSERVE_FLIGHT
    importing
      !IV_CARRID type S_CARR_ID
      !IV_CONNID type S_CONN_ID
      !IV_FLDATE type S_DATE .
protected section.

*"* protected components of class ZCL_MOCKA_FLIGHT_OBSERVER
*"* do not include other source files here!!!
  data MO_IS_IN_TIME_ACCESS type ref to ZIF_MOCKA_IS_IN_TIME_INFO .
  data MO_ALERT_PROCESSOR type ref to ZIF_MOCKA_FLIGHT_ALERT_PROCESS .
private section.
*"* private components of class ZCL_MOCKA_FLIGHT_OBSERVER
*"* do not include other source files here!!!
ENDCLASS.



CLASS ZCL_MOCKA_FLIGHT_OBSERVER IMPLEMENTATION.


METHOD constructor.
  mo_alert_processor = io_alert_processor.
  mo_is_in_time_access = io_in_time_access.
ENDMETHOD.


METHOD observe_flight.
  DATA lv_delay_minutes TYPE i.
  lv_delay_minutes = mo_is_in_time_access->get_delay(
    iv_carrid = iv_carrid
    iv_connid = iv_connid
    iv_fldate = iv_fldate
  ).
  IF lv_delay_minutes > 60.
    mo_alert_processor->alert_delay(
      iv_carrid = iv_carrid
      iv_connid = iv_connid
      iv_fldate = iv_fldate ).
  ENDIF.
ENDMETHOD.
ENDCLASS.
