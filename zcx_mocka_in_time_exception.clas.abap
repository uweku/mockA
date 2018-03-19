class ZCX_MOCKA_IN_TIME_EXCEPTION definition
  public
  inheriting from CX_NO_CHECK
  final
  create public .

public section.

*"* public components of class ZCX_MOCKA_IN_TIME_EXCEPTION
*"* do not include other source files here!!!
  methods CONSTRUCTOR
    importing
      !TEXTID like TEXTID optional
      !PREVIOUS like PREVIOUS optional .
protected section.
*"* protected components of class ZCX_MOCKA_IN_TIME_EXCEPTION
*"* do not include other source files here!!!
private section.
*"* private components of class ZCX_MOCKA_IN_TIME_EXCEPTION
*"* do not include other source files here!!!
ENDCLASS.



CLASS ZCX_MOCKA_IN_TIME_EXCEPTION IMPLEMENTATION.


  method CONSTRUCTOR.
CALL METHOD SUPER->CONSTRUCTOR
EXPORTING
TEXTID = TEXTID
PREVIOUS = PREVIOUS
.
  endmethod.
ENDCLASS.
