class ZCL_MOCKA_HELPER_MOCKER definition
  public
  final
  create public .

public section.

*"* public components of class ZCL_MOCKA_HELPER_MOCKER
*"* do not include other source files here!!!
  class-methods GENERATE_SUBROUTINE_POOL
    importing
      !IT_CODE type STRING_TABLE
    exporting
      !EV_PROG type STRING
      !EV_SUBRC type SY-SUBRC
      !EV_MESSAGE type STRING .
protected section.
*"* protected components of class ZCL_MOCKA_HELPER_MOCKER
*"* do not include other source files here!!!
private section.
*"* private components of class ZCL_MOCKA_HELPER_MOCKER
*"* do not include other source files here!!!
ENDCLASS.



CLASS ZCL_MOCKA_HELPER_MOCKER IMPLEMENTATION.


METHOD generate_subroutine_pool.
* helper method that generates the local class that implements the mock object functions
  FREE: ev_prog,
        ev_subrc,
        ev_message.

  CATCH SYSTEM-EXCEPTIONS generate_subpool_dir_full = 9.
    GENERATE SUBROUTINE POOL it_code NAME ev_prog MESSAGE ev_message.
    IF sy-subrc IS NOT INITIAL.
      ev_subrc = sy-subrc.
    ENDIF.
  ENDCATCH.
  IF sy-subrc = 9.
    ev_subrc = sy-subrc.
    ev_message = text-001.
  ENDIF.
ENDMETHOD.
ENDCLASS.
