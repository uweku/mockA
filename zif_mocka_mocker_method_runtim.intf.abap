interface ZIF_MOCKA_MOCKER_METHOD_RUNTIM
  public .

  type-pools ABAP .

  methods INCREASE_TIMES_CALLED
    importing
      !IV_INCREMENT type I default 1 .
  methods REGISTER_HAS_BEEN_CALLED_WITH
    importing
      !IT_IMPORTING type ZIF_MOCKA_MOCKER_METHOD=>TY_T_NAME_VALUE_PAIR
      !IT_CHANGING_IN type ZIF_MOCKA_MOCKER_METHOD=>TY_T_NAME_VALUE_PAIR .
endinterface.
