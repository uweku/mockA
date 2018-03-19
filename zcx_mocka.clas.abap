class ZCX_MOCKA definition
  public
  inheriting from CX_NO_CHECK
  create public .

public section.

*"* public components of class ZCX_MOCKA
*"* do not include other source files here!!!
  interfaces IF_T100_MESSAGE .

  constants:
    begin of ZCX_MOCKA,
      msgid type symsgid value 'ZMOCKA_EXC_MOCK',
      msgno type symsgno value '000',
      attr1 type scx_attrname value 'GENERIC_TEXT',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ZCX_MOCKA .
  constants:
    begin of ABSTRACT_EXCEPTION,
      msgid type symsgid value 'ZMOCKA_EXC_MOCK',
      msgno type symsgno value '008',
      attr1 type scx_attrname value 'EXCEPTION',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ABSTRACT_EXCEPTION .
  constants:
    begin of NO_CHANGING_PARAMETERS,
      msgid type symsgid value 'ZMOCKA_EXC_MOCK',
      msgno type symsgno value '009',
      attr1 type scx_attrname value 'METHOD',
      attr2 type scx_attrname value 'INTERFACE',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of NO_CHANGING_PARAMETERS .
  constants:
    begin of INVALID_EXCEPTION,
      msgid type symsgid value 'ZMOCKA_EXC_MOCK',
      msgno type symsgno value '007',
      attr1 type scx_attrname value 'EXCEPTION',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of INVALID_EXCEPTION .
  constants:
    begin of INVALID_PARAMETER_COUNT,
      msgid type symsgid value 'ZMOCKA_EXC_MOCK',
      msgno type symsgno value '001',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of INVALID_PARAMETER_COUNT .
  constants:
    begin of NO_SUCH_EXCEPTION,
      msgid type symsgid value 'ZMOCKA_EXC_MOCK',
      msgno type symsgno value '006',
      attr1 type scx_attrname value 'EXCEPTION',
      attr2 type scx_attrname value 'METHOD',
      attr3 type scx_attrname value 'INTERFACE',
      attr4 type scx_attrname value '',
    end of NO_SUCH_EXCEPTION .
  constants:
    begin of NO_RETURNING_PARAMETERS,
      msgid type symsgid value 'ZMOCKA_EXC_MOCK',
      msgno type symsgno value '005',
      attr1 type scx_attrname value 'METHOD',
      attr2 type scx_attrname value 'INTERFACE',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of NO_RETURNING_PARAMETERS .
  constants:
    begin of NO_EXPORTING_PARAMETERS,
      msgid type symsgid value 'ZMOCKA_EXC_MOCK',
      msgno type symsgno value '004',
      attr1 type scx_attrname value 'METHOD',
      attr2 type scx_attrname value 'INTERFACE',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of NO_EXPORTING_PARAMETERS .
  constants:
    begin of NO_SUCH_METHOD,
      msgid type symsgid value 'ZMOCKA_EXC_MOCK',
      msgno type symsgno value '003',
      attr1 type scx_attrname value 'METHOD',
      attr2 type scx_attrname value 'INTERFACE',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of NO_SUCH_METHOD .
  constants:
    begin of NO_SUCH_INTERFACE,
      msgid type symsgid value 'ZMOCKA_EXC_MOCK',
      msgno type symsgno value '002',
      attr1 type scx_attrname value 'INTERFACE',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of NO_SUCH_INTERFACE .
  constants:
    begin of UNIT_TEST_EXEC_NOT_ALLOWED,
      msgid type symsgid value 'ZMOCKA_EXC_MOCK',
      msgno type symsgno value '010',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of UNIT_TEST_EXEC_NOT_ALLOWED .
  constants:
    begin of NO_SUCH_ATTRIBUTE,
      msgid type symsgid value 'ZMOCKA_EXC_MOCK',
      msgno type symsgno value '011',
      attr1 type scx_attrname value 'ATTRIBUTE',
      attr2 type scx_attrname value 'INTERFACE',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of NO_SUCH_ATTRIBUTE .
  data INTERFACE type ABAP_ABSTYPENAME .
  data METHOD type SEOCPDNAME .
  data GENERIC_TEXT type STRING .
  data EXCEPTION type SEOCLSNAME .
  data ATTRIBUTE type SEOCPDNAME .

  methods CONSTRUCTOR
    importing
      !TEXTID like IF_T100_MESSAGE=>T100KEY optional
      !PREVIOUS like PREVIOUS optional
      !INTERFACE type ABAP_ABSTYPENAME optional
      !METHOD type SEOCPDNAME optional
      !GENERIC_TEXT type STRING optional
      !EXCEPTION type SEOCLSNAME optional
      !ATTRIBUTE type SEOCPDNAME optional .
protected section.
*"* protected components of class ZCX_MOCKA
*"* do not include other source files here!!!
private section.
*"* private components of class ZCX_MOCKA
*"* do not include other source files here!!!
ENDCLASS.



CLASS ZCX_MOCKA IMPLEMENTATION.


  method CONSTRUCTOR.
CALL METHOD SUPER->CONSTRUCTOR
EXPORTING
PREVIOUS = PREVIOUS
.
me->INTERFACE = INTERFACE .
me->METHOD = METHOD .
me->GENERIC_TEXT = GENERIC_TEXT .
me->EXCEPTION = EXCEPTION .
me->ATTRIBUTE = ATTRIBUTE .
clear me->textid.
if textid is initial.
  IF_T100_MESSAGE~T100KEY = ZCX_MOCKA .
else.
  IF_T100_MESSAGE~T100KEY = TEXTID.
endif.
  endmethod.
ENDCLASS.
