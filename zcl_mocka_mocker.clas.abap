class ZCL_MOCKA_MOCKER definition
  public
  create public

  global friends ZCL_MOCKA_MOCKER_METHOD .

public section.
  type-pools SEOS .

*"* public components of class ZCL_MOCKA_MOCKER
*"* do not include other source files here!!!
  interfaces ZIF_MOCKA_MOCKER .
protected section.

  types:
*"* protected components of class ZCL_MOCKA_MOCKER
*"* do not include other source files here!!!
    BEGIN OF ty_s_methods,    name TYPE seocpdname,    method_mocker TYPE REF TO zif_mocka_mocker_method,    END OF ty_s_methods .
  types:
    BEGIN OF ty_s_attributes,    name TYPE seocpdname,    attribute_mocker TYPE REF TO zif_mocka_mocker_attribute,    END OF ty_s_attributes .
  types:
    ty_t_methods TYPE TABLE OF ty_s_methods .
  types:
    ty_t_attributes TYPE TABLE OF ty_s_attributes .
  types:
    BEGIN OF ty_s_generated_class,    name TYPE seoclsname,    technical_name TYPE string,    END OF ty_s_generated_class .

  data MV_INTERFACE type ABAP_ABSTYPENAME .
  data MT_METHOD_MOCKS type ZIF_MOCKA_MOCKER=>TY_T_METHOD_MOCKS .
  data MT_ATTRIBUTE_MOCKS type TY_T_ATTRIBUTES .
  data MO_OBJECTDESCR type ref to CL_ABAP_OBJECTDESCR .
  class-data MV_MOCK_COUNT type I .
  data MV_GENERATED_CLASS type STRING .
  class-data:
    mt_generated_classes TYPE TABLE OF ty_s_generated_class .
  data MV_IS_INTERFACE_MOCK type ABAP_BOOL .
  data MT_CONSTRUCTOR_PARAMETERS type ABAP_PARMBIND_TAB .
  constants:
    BEGIN OF gc_visibility,
                public TYPE abap_visibility VALUE 'U',      "#EC NOTEXT
                protected TYPE abap_visibility VALUE 'O',   "#EC NOTEXT
                private TYPE abap_visibility VALUE 'I',     "#EC NOTEXT
               END OF gc_visibility .

  methods COPY_VALUE
    importing
      !IR_REF type ref to DATA
    returning
      value(RR_REF) type ref to DATA .
  methods RESOLVE_METHOD
    importing
      !IS_METHOD type ABAP_METHDESCR
    returning
      value(RO_METHOD_MOCK) type ref to ZIF_MOCKA_MOCKER_METHOD .
  class-methods CHECK_UNIT_TEST_EXECUTION .
private section.

  methods GENERATE_METHOD_EXC_RAISING
    importing
      !IS_METHOD type ABAP_METHDESCR
    changing
      !CT_CODE type STRING_TABLE .
  methods GENERATE_CONSTRUCTOR_DEF
    changing
      !CT_CODE type STRING_TABLE .
  methods GENERATE_CONSTRUCTOR
    changing
      !CT_CODE type STRING_TABLE .
  methods GENERATE_CHANGING_PARAM_MAP
    importing
      !IS_METHOD type ABAP_METHDESCR
    changing
      !CT_CODE type STRING_TABLE .
  methods GENERATE_IMPORTING_PARAM_MAP
    importing
      !IS_METHOD type ABAP_METHDESCR
    changing
      !CT_CODE type STRING_TABLE .
  methods GENERATE_METHOD_CALL_PROTOCOL
    importing
      !IS_METHOD type ABAP_METHDESCR
    changing
      !CT_CODE type STRING_TABLE .
  methods GENERATE_METHOD_DECLARATIONS
    importing
      !IS_METHOD type ABAP_METHDESCR
    changing
      !CT_CODE type STRING_TABLE .
  methods IS_EXCEPTION_CLASS
    importing
      !IV_CLASSNAME type SEOCLSNAME
    returning
      value(RV_IS_EXCEPTION) type ABAP_BOOL .
  methods RAISE_EXCEPTION
    importing
      !IV_MESSAGE type STRING .
  methods TRY_CREATE_BY_GENERATED_CLASS
    returning
      value(RO_MOCKUP) type ref to OBJECT .
ENDCLASS.



CLASS ZCL_MOCKA_MOCKER IMPLEMENTATION.


METHOD check_unit_test_execution.
    DATA lv_is_unit_test_allowed TYPE abap_bool.
    lv_is_unit_test_allowed = cl_aunit_permission_control=>is_test_enabled_client( ).
    IF lv_is_unit_test_allowed = abap_false.
      RAISE EXCEPTION TYPE zcx_mocka
        EXPORTING
          textid = zcx_mocka=>unit_test_exec_not_allowed.
    ENDIF.
  ENDMETHOD.                    "check_unit_test_execution


METHOD copy_value.
    FIELD-SYMBOLS <lv_in> TYPE any.
    FIELD-SYMBOLS <lv_out> TYPE any.

    ASSIGN ir_ref->* TO <lv_in>.
    CREATE DATA rr_ref LIKE <lv_in>.
    ASSIGN rr_ref->* TO <lv_out>.
    <lv_out> = <lv_in>.
  ENDMETHOD.                    "COPY_VALUE


METHOD generate_changing_param_map.
* generates the CHANGING parameter mapping for the mock object's method source code
  DATA lv_line TYPE string.
  FIELD-SYMBOLS <ls_parameter> LIKE LINE OF is_method-parameters.
  LOOP AT is_method-parameters ASSIGNING <ls_parameter> WHERE parm_kind = 'C'.
    CONCATENATE 'ls_changing_in-parameter = ''' <ls_parameter>-name '''.' INTO lv_line. "#EC NOTEXT
    APPEND lv_line TO ct_code.
    IF <ls_parameter>-is_optional = abap_true.
      CONCATENATE 'IF' <ls_parameter>-name 'IS SUPPLIED.' INTO lv_line SEPARATED BY space.
    ENDIF.
    APPEND lv_line TO ct_code.
    CONCATENATE 'GET REFERENCE OF' <ls_parameter>-name 'into ls_changing_in-value.' INTO lv_line SEPARATED BY space. "#EC NOTEXT
    APPEND lv_line TO ct_code.
    APPEND 'APPEND ls_changing_in TO lt_changing_in.' TO ct_code. "#EC NOTEXT
    IF <ls_parameter>-is_optional = abap_true.
      APPEND 'ENDIF.' TO ct_code.
    ENDIF.
  ENDLOOP.
ENDMETHOD.


METHOD generate_constructor.
  FIELD-SYMBOLS <ls_method> LIKE LINE OF mo_objectdescr->methods.
  DATA lt_temp_code  TYPE TABLE OF string.
  FIELD-SYMBOLS <ls_parameter> LIKE LINE OF <ls_method>-parameters.
  DATA lv_line TYPE string.

  APPEND 'METHOD constructor.' TO ct_code.                  "#EC NOTEXT
  IF mv_is_interface_mock = abap_false.
    APPEND 'call method super->constructor' TO ct_code.     "#EC NOTEXT
    READ TABLE mo_objectdescr->methods ASSIGNING <ls_method> WITH KEY name = 'CONSTRUCTOR'.
    IF sy-subrc = 0.
      CLEAR: lt_temp_code.
      LOOP AT <ls_method>-parameters ASSIGNING <ls_parameter> WHERE parm_kind = 'I'.
        READ TABLE mt_constructor_parameters TRANSPORTING NO FIELDS WITH KEY name = <ls_parameter>-name.
        IF sy-subrc = 0.
          CONCATENATE <ls_parameter>-name '=' <ls_parameter>-name INTO lv_line SEPARATED BY space.
          APPEND lv_line TO lt_temp_code.
        ENDIF.
      ENDLOOP.
      IF lt_temp_code IS NOT INITIAL.
        APPEND 'EXPORTING' TO ct_code.
        APPEND LINES OF lt_temp_code TO ct_code.
      ENDIF.
      CLEAR: lt_temp_code.
      LOOP AT <ls_method>-parameters ASSIGNING <ls_parameter> WHERE parm_kind = 'C'.
        READ TABLE mt_constructor_parameters TRANSPORTING NO FIELDS WITH KEY name = <ls_parameter>-name.
        IF sy-subrc = 0.
          CONCATENATE <ls_parameter>-name '=' <ls_parameter>-name INTO lv_line SEPARATED BY space.
          CONCATENATE <ls_parameter>-name '=' <ls_parameter>-name INTO lv_line SEPARATED BY space.
          APPEND lv_line TO lt_temp_code.
        ENDIF.
      ENDLOOP.
      IF lt_temp_code IS NOT INITIAL.
        APPEND 'CHANGING' TO ct_code.
        APPEND LINES OF lt_temp_code TO ct_code.
      ENDIF.
    ENDIF.
    APPEND '.' TO ct_code.
  ENDIF.
  APPEND 'mo_mocker = io_mocker.' TO ct_code.               "#EC NOTEXT

  APPEND 'DATA lo_attribute TYPE REF TO zif_mocka_mocker_attribute.' TO ct_code. "#EC NOTEXT
  APPEND 'FIELD-SYMBOLS <l_value> TYPE ANY.' TO ct_code.    "#EC NOTEXT
  APPEND 'DATA lr_value TYPE REF TO data.' TO ct_code.      "#EC NOTEXT

  FIELD-SYMBOLS <ls_attribute> TYPE abap_attrdescr.
  DATA lo_attribute TYPE REF TO zif_mocka_mocker_attribute.
  DATA lr_value TYPE REF TO data.
  DATA lv_attribute TYPE string.
  FIELD-SYMBOLS <l_value> TYPE any.
  LOOP AT mo_objectdescr->attributes ASSIGNING <ls_attribute> WHERE is_constant = abap_false.
    IF <ls_attribute>-visibility = gc_visibility-private."no mocking of private attributes
      CONTINUE.
    ENDIF.

    lo_attribute = me->zif_mocka_mocker~attribute( <ls_attribute>-name ).

    CONCATENATE 'lo_attribute = mo_mocker->attribute( ''' <ls_attribute>-name ''' ).' INTO lv_line. "#EC NOTEXT
    APPEND lv_line TO ct_code.
    APPEND 'lr_value = lo_attribute->return( ).' TO ct_code. "#EC NOTEXT
    APPEND 'IF lr_value IS BOUND.' TO ct_code.              "#EC NOTEXT
    APPEND 'ASSIGN lr_value->* TO <l_value>.' TO ct_code.   "#EC NOTEXT
    IF mv_is_interface_mock = abap_false.
      CONCATENATE <ls_attribute>-name '= <l_value>.' INTO lv_line SEPARATED BY space. "#EC NOTEXT
    ELSE.
      CONCATENATE mv_interface '~' <ls_attribute>-name INTO lv_line.
      CONCATENATE lv_line '= <l_value>.' INTO lv_line SEPARATED BY space. "#EC NOTEXT
    ENDIF.
    APPEND lv_line TO ct_code.
    APPEND 'ENDIF.' TO ct_code.
  ENDLOOP.
  APPEND 'ENDMETHOD.' TO ct_code.
ENDMETHOD.


METHOD generate_constructor_def.
* generates the constructor definition for the mock object's class source code
  FIELD-SYMBOLS <ls_method> LIKE LINE OF mo_objectdescr->methods.
  DATA lt_temp_code  TYPE TABLE OF string.
  FIELD-SYMBOLS <ls_parameter> LIKE LINE OF <ls_method>-parameters.
  DATA lv_line TYPE string.

  APPEND 'METHODS constructor IMPORTING !io_mocker TYPE REF TO ZIF_MOCKA_MOCKER !it_attributes type ABAP_ATTRDESCR_TAB' TO ct_code. "#EC NOTEXT

  READ TABLE mo_objectdescr->methods ASSIGNING <ls_method> WITH KEY name = 'CONSTRUCTOR'.
  IF sy-subrc = 0.
    CLEAR: lt_temp_code.
    LOOP AT <ls_method>-parameters ASSIGNING <ls_parameter> WHERE parm_kind = 'I'.
      READ TABLE mt_constructor_parameters TRANSPORTING NO FIELDS WITH KEY name = <ls_parameter>-name.
      IF sy-subrc = 0.
        CONCATENATE <ls_parameter>-name 'TYPE ANY' INTO lv_line SEPARATED BY space.
        APPEND lv_line TO lt_temp_code.
      ENDIF.
    ENDLOOP.
    IF lt_temp_code IS NOT INITIAL.
      APPEND LINES OF lt_temp_code TO ct_code.
    ENDIF.

    CLEAR: lt_temp_code.
    LOOP AT <ls_method>-parameters ASSIGNING <ls_parameter> WHERE parm_kind = 'C'.
      READ TABLE mt_constructor_parameters TRANSPORTING NO FIELDS WITH KEY name = <ls_parameter>-name.
      IF sy-subrc = 0.
        CONCATENATE <ls_parameter>-name 'TYPE ANY' INTO lv_line SEPARATED BY space.
        APPEND lv_line TO lt_temp_code.
      ENDIF.
    ENDLOOP.
    IF lt_temp_code IS NOT INITIAL.
      APPEND 'CHANGING' TO ct_code.
      APPEND LINES OF lt_temp_code TO ct_code.
    ENDIF.
  ENDIF.
  APPEND '.' TO ct_code.
ENDMETHOD.


METHOD generate_importing_param_map.
* generates the IMPORTING parameter mapping for the mock object's method source code
  DATA lv_line TYPE string.
  FIELD-SYMBOLS <ls_parameter> LIKE LINE OF is_method-parameters.
  LOOP AT is_method-parameters ASSIGNING <ls_parameter> WHERE parm_kind = 'I'.
    IF <ls_parameter>-is_optional = abap_true.
      CONCATENATE 'IF' <ls_parameter>-name 'IS SUPPLIED.' INTO lv_line SEPARATED BY space.
      APPEND lv_line TO ct_code.
    ENDIF.
    CONCATENATE 'ls_importing-parameter = ''' <ls_parameter>-name '''.' INTO lv_line. "#EC NOTEXT
    APPEND lv_line TO ct_code.
    CONCATENATE 'GET REFERENCE OF' <ls_parameter>-name 'into ls_importing-value.' INTO lv_line SEPARATED BY space. "#EC NOTEXT
    APPEND lv_line TO ct_code.
    APPEND 'APPEND ls_importing TO lt_importing.' TO ct_code. "#EC NOTEXT
    IF <ls_parameter>-is_optional = abap_true.
      APPEND 'ENDIF.' TO ct_code.
    ENDIF.
  ENDLOOP.
ENDMETHOD.


METHOD GENERATE_METHOD_CALL_PROTOCOL.
* register method call
  APPEND 'lo_mocker_method_runtime ?= lo_mocker_method.' TO ct_code. "#EC NOTEXT
  APPEND 'lo_mocker_method_runtime->increase_times_called( ).' TO ct_code. "#EC NOTEXT
  APPEND 'lo_mocker_method_runtime->REGISTER_HAS_BEEN_CALLED_WITH( it_importing = lt_importing it_changing_in = lt_changing_in ).' TO ct_code. "#EC NOTEXT
ENDMETHOD.


METHOD GENERATE_METHOD_DECLARATIONS.
* every mocked methods receives this set of local variables
  DATA lv_line TYPE string.

  APPEND 'DATA: lr_return TYPE REF TO DATA.' TO ct_code.    "#EC NOTEXT
  APPEND 'DATA: lv_exception TYPE seoclsname.' TO ct_code.  "#EC NOTEXT
  APPEND 'DATA: lo_mocker_method TYPE REF TO ZIF_MOCKA_MOCKER_METHOD.' TO ct_code. "#EC NOTEXT
  APPEND 'DATA: lo_mocker_method_runtime TYPE REF TO ZIF_MOCKA_MOCKER_METHOD_RUNTIM.' TO ct_code. "#EC NOTEXT
  APPEND 'FIELD-SYMBOLS: <lv_return> TYPE any.' TO ct_code. "#EC NOTEXT
  IF is_method-alias_for IS NOT INITIAL.
    CONCATENATE 'lo_mocker_method ?= mo_mocker->method( ''' is_method-alias_for ''' ).' INTO lv_line. "#EC NOTEXT
  ELSE.
    CONCATENATE 'lo_mocker_method ?= mo_mocker->method( ''' is_method-name ''' ).' INTO lv_line. "#EC NOTEXT
  ENDIF.
  APPEND lv_line TO ct_code.

  APPEND 'DATA ls_importing TYPE ZIF_MOCKA_MOCKER_METHOD=>TY_S_NAME_VALUE_PAIR.' TO ct_code. "#EC NOTEXT
  APPEND 'DATA ls_changing_in TYPE ZIF_MOCKA_MOCKER_METHOD=>TY_S_NAME_VALUE_PAIR.' TO ct_code. "#EC NOTEXT
  APPEND 'DATA ls_exporting TYPE ZIF_MOCKA_MOCKER_METHOD=>TY_S_NAME_VALUE_PAIR.' TO ct_code. "#EC NOTEXT
  APPEND 'DATA ls_changing_out TYPE ZIF_MOCKA_MOCKER_METHOD=>TY_S_NAME_VALUE_PAIR.' TO ct_code. "#EC NOTEXT
  APPEND 'DATA lt_importing TYPE ZIF_MOCKA_MOCKER_METHOD=>TY_T_NAME_VALUE_PAIR.' TO ct_code. "#EC NOTEXT
  APPEND 'DATA lt_changing_in TYPE ZIF_MOCKA_MOCKER_METHOD=>TY_T_NAME_VALUE_PAIR.' TO ct_code. "#EC NOTEXT
  APPEND 'DATA lt_exporting TYPE ZIF_MOCKA_MOCKER_METHOD=>TY_T_NAME_VALUE_PAIR.' TO ct_code. "#EC NOTEXT
  APPEND 'DATA lt_changing_out TYPE ZIF_MOCKA_MOCKER_METHOD=>TY_T_NAME_VALUE_PAIR.' TO ct_code. "#EC NOTEXT
  APPEND 'FIELD-SYMBOLS <ls_exporting> TYPE ZIF_MOCKA_MOCKER_METHOD=>TY_S_NAME_VALUE_PAIR.' TO ct_code. "#EC NOTEXT
  APPEND 'FIELD-SYMBOLS <lv_exporting_out> TYPE any.' TO ct_code. "#EC NOTEXT
  APPEND 'FIELD-SYMBOLS <lv_exporting_from_mocker> TYPE any.' TO ct_code. "#EC NOTEXT
ENDMETHOD.


METHOD GENERATE_METHOD_EXC_RAISING.
* exception raising logic for the mock object will be generated here
  DATA lv_is_class_based_exception TYPE abap_bool.
  DATA lt_exceptions TYPE seos_exceptions_r.
  FIELD-SYMBOLS <ls_exception> TYPE vseoexcep.
  DATA ls_method_key TYPE seocmpkey.
  DATA lv_message TYPE string.

  APPEND 'lv_exception = lo_mocker_method->raise( it_importing = lt_importing it_changing_in = lt_changing_in ).' TO ct_code. "#EC NOTEXT

  FIND FIRST OCCURRENCE OF '~' IN is_method-name.
  IF sy-subrc EQ 0.
    SPLIT is_method-name AT '~' INTO ls_method_key-clsname ls_method_key-cmpname.
  ELSE.
    ls_method_key-clsname = mv_interface.
    ls_method_key-cmpname = is_method-name.
  ENDIF.
  CALL FUNCTION 'SEO_METHOD_SIGNATURE_GET'
    EXPORTING
      mtdkey       = ls_method_key
    IMPORTING
      exceps       = lt_exceptions
    EXCEPTIONS
      not_existing = 1
      is_event     = 2
      is_type      = 3
      is_attribute = 4
      model_only   = 5
      OTHERS       = 6.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO lv_message.
    RAISE EXCEPTION TYPE zcx_mocka
      EXPORTING
        textid       = zcx_mocka=>zcx_mocka
        generic_text = lv_message.
  ELSE.
    READ TABLE lt_exceptions ASSIGNING <ls_exception> INDEX 1.
    IF sy-subrc = 0.
      lv_is_class_based_exception = me->is_exception_class( <ls_exception>-sconame ).
    ENDIF.
    IF lt_exceptions IS INITIAL.
      lv_is_class_based_exception = abap_true.
    ENDIF.
  ENDIF.
  IF lv_is_class_based_exception = abap_true.
    APPEND 'DATA lo_cx_exc TYPE REF TO cx_root.' TO ct_code. "#EC NOTEXT
    APPEND 'IF lv_exception IS NOT INITIAL.' TO ct_code.    "#EC NOTEXT
    APPEND '  TRANSLATE lv_exception TO UPPER CASE.' TO ct_code. "#EC NOTEXT
    APPEND '  CREATE OBJECT lo_cx_exc TYPE (lv_exception).' TO ct_code. "#EC NOTEXT
    APPEND '  RAISE EXCEPTION lo_cx_exc.' TO ct_code.       "#EC NOTEXT
    APPEND 'ENDIF.' TO ct_code.                             "#EC NOTEXT
  ENDIF.

ENDMETHOD.


METHOD is_exception_class.
    DATA ls_clskey TYPE seoclskey.
    ls_clskey-clsname = iv_classname.
    DATA ls_class TYPE seoc_class_r.
    CALL FUNCTION 'SEO_CLASS_READ'
      EXPORTING
        clskey = ls_clskey
      IMPORTING
        class  = ls_class.
    IF ls_class-category = 40.
      rv_is_exception = abap_true.
    ENDIF.
  ENDMETHOD.                    "is_exception_class


METHOD raise_exception.
    RAISE EXCEPTION TYPE zcx_mocka
      EXPORTING
        textid       = zcx_mocka=>zcx_mocka
        generic_text = iv_message.
  ENDMETHOD.                    "raise_exception


METHOD resolve_method.
  IF is_method-alias_for IS NOT INITIAL AND mv_is_interface_mock = abap_true.
    " I'm not sure why this would be needed. Public and protected aliases should
    " be inherited and private aliases wouldn't matter anyway?
    " It's causing issues when I'm mocking a class and setting the return
    " value for an interface method implemented in that class that has
    " an alias...
    ro_method_mock = me->zif_mocka_mocker~method( is_method-alias_for ).
  ELSE.
    ro_method_mock = me->zif_mocka_mocker~method( is_method-name ).
  ENDIF.
ENDMETHOD.                    "resolve_method


METHOD try_create_by_generated_class.
* As there is a limit of subroutine pools, mockA cannot generate a new class out of the same interface every time
* Furthermore, the code will not change, as the differing behaviour will injected with the mocker instance
* This method tries to resolve possibly existing subroutine pools that may have been created earlier and creates a new mock instance out of it

  DATA lt_constructor_parameters LIKE mt_constructor_parameters.
  DATA ls_constructor_parameter LIKE LINE OF mt_constructor_parameters.

  IF mv_generated_class IS NOT INITIAL.
    ls_constructor_parameter-name = 'IO_MOCKER'.
    ls_constructor_parameter-kind = 'E'.
    GET REFERENCE OF me INTO ls_constructor_parameter-value.
    INSERT ls_constructor_parameter INTO TABLE lt_constructor_parameters.

    ls_constructor_parameter-name = 'IT_ATTRIBUTES'.
    ls_constructor_parameter-kind = 'E'.
    GET REFERENCE OF mo_objectdescr->attributes INTO ls_constructor_parameter-value.
    INSERT ls_constructor_parameter INTO TABLE lt_constructor_parameters.

    INSERT LINES OF mt_constructor_parameters INTO TABLE lt_constructor_parameters.
    CREATE OBJECT ro_mockup
      TYPE
      (mv_generated_class)
      PARAMETER-TABLE
      lt_constructor_parameters.
    RETURN.
  ENDIF.
ENDMETHOD.


METHOD zif_mocka_mocker~attribute.
*   specify the values for a faked attribute
    FIELD-SYMBOLS <ls_attribute> TYPE abap_attrdescr.
    DATA lv_attribute_name LIKE iv_attribute.

    lv_attribute_name = iv_attribute.
    TRANSLATE lv_attribute_name TO UPPER CASE.

    DATA ls_attribute TYPE ty_s_attributes.
    READ TABLE mt_attribute_mocks INTO ls_attribute WITH KEY name = lv_attribute_name.
    IF sy-subrc = 0.
      ro_attribute = ls_attribute-attribute_mocker.
      RETURN.
    ENDIF.

    READ TABLE mo_objectdescr->attributes ASSIGNING <ls_attribute> WITH KEY name = lv_attribute_name.
    IF <ls_attribute> IS NOT ASSIGNED.
      RAISE EXCEPTION TYPE zcx_mocka
        EXPORTING
          textid    = zcx_mocka=>no_such_attribute
          interface = mv_interface
          attribute = lv_attribute_name.
    ENDIF.

    CREATE OBJECT ro_attribute
      TYPE
      zcl_mocka_mocker_attribute
      EXPORTING
        iv_attribute = lv_attribute_name
        io_mocker    = me.

    ls_attribute-attribute_mocker ?= ro_attribute.
    ls_attribute-name = lv_attribute_name.
    APPEND ls_attribute TO mt_attribute_mocks.
  ENDMETHOD.                    "zif_mocka_mocker~attribute


METHOD zif_mocka_mocker~generate_mockup.
* This method generates the mockup class code
* every instance receives the instance of the current mocker to carry out method parameter verifications,
* as well as recordings of incoming parameters of method calls

  DATA lv_has_returning_parameter TYPE abap_bool VALUE abap_false.
  DATA lv_has_exporting_parameter TYPE abap_bool VALUE abap_false.
  DATA lv_has_changing_parameter TYPE abap_bool VALUE abap_false.

  ro_mockup ?= try_create_by_generated_class( ).
  CHECK: ro_mockup IS INITIAL.

  FIELD-SYMBOLS <ls_method_mock> LIKE LINE OF mt_method_mocks.
  LOOP AT mt_method_mocks ASSIGNING <ls_method_mock>.
    <ls_method_mock>-method_mock->finalize_current_method_sign( ).
  ENDLOOP.

  ADD 1 TO mv_mock_count.
  DATA lt_code  TYPE TABLE OF string.
  DATA lt_temp_code  TYPE TABLE OF string.
  DATA lv_prog  TYPE string.
  DATA lv_line TYPE string.
  FIELD-SYMBOLS <ls_method> LIKE LINE OF mo_objectdescr->methods.
  FIELD-SYMBOLS <ls_parameter> LIKE LINE OF <ls_method>-parameters.
  DATA lv_classname TYPE seoclsname.
  DATA: lv_exception TYPE seoclsname.
  DATA lv_message TYPE string.
  DATA lv_inheriting_from TYPE string.
  DATA lv_generate_method TYPE abap_bool.
  DATA lo_mocker_method TYPE REF TO zif_mocka_mocker_method.
  DATA lv_code_redefinition TYPE string.
  DATA lv_string TYPE string.

  APPEND `program.`                     TO lt_code.
  lv_string = mv_mock_count.
  CONCATENATE 'LCL_IMPL' lv_string INTO lv_string.
  lv_classname = lv_string.
  IF mv_is_interface_mock = abap_false.
    CONCATENATE 'INHERITING FROM' mv_interface INTO lv_inheriting_from SEPARATED BY space.
  ENDIF.
  CONCATENATE 'CLASS' lv_classname 'DEFINITION' lv_inheriting_from '.' INTO lv_line SEPARATED BY space.
  APPEND lv_line TO lt_code.

  DATA lv_is_public_section TYPE abap_bool VALUE abap_true.
  DO 2 TIMES.
    IF lv_is_public_section = abap_true.
      APPEND 'PUBLIC SECTION.' TO lt_code.
      IF mv_is_interface_mock = abap_true.
        CONCATENATE 'INTERFACES' mv_interface '.' INTO lv_line SEPARATED BY space.
        APPEND lv_line TO lt_code.
      ENDIF.
    ELSE.
      APPEND 'PROTECTED SECTION.' TO lt_code.
      APPEND 'DATA: mo_mocker TYPE REF TO ZIF_MOCKA_MOCKER.' TO lt_code. "#EC NOTEXT
    ENDIF.
    IF mv_is_interface_mock = abap_false.
      LOOP AT mo_objectdescr->methods ASSIGNING <ls_method> WHERE is_class = abap_false AND name NE 'CONSTRUCTOR'.
        IF lv_is_public_section = abap_true AND <ls_method>-visibility = gc_visibility-protected
          OR lv_is_public_section = abap_false AND <ls_method>-visibility = gc_visibility-public
          OR <ls_method>-visibility = gc_visibility-private.
          CONTINUE.
        ENDIF.

        CLEAR: lv_has_changing_parameter, lv_has_exporting_parameter, lv_has_returning_parameter.
        lv_generate_method = abap_false.
        lo_mocker_method = resolve_method( <ls_method> ).
        IF lo_mocker_method IS NOT INITIAL.
          lv_generate_method = lo_mocker_method->has_registered_call_pattern( ).
        ENDIF.
       IF lv_generate_method = abap_false and <ls_method>-is_abstract eq abap_false.
          CONTINUE.
        ELSE.
          lv_code_redefinition = 'REDEFINITION'.
        ENDIF.

*       create method stub
        lv_line = <ls_method>-name.

        CONCATENATE 'METHODS' lv_line lv_code_redefinition '.' INTO lv_line SEPARATED BY space.
        APPEND lv_line TO lt_code.
      ENDLOOP.
    ENDIF.

    IF lv_is_public_section = abap_true.
      generate_constructor_def(
        CHANGING
          ct_code = lt_code
      ).

      lv_is_public_section = abap_false.
    ENDIF.
  ENDDO.
  APPEND 'ENDCLASS.' TO lt_code.

  CONCATENATE 'CLASS' lv_classname 'IMPLEMENTATION.' INTO lv_line SEPARATED BY space.
  APPEND lv_line TO lt_code.

  generate_constructor(
    CHANGING
      ct_code   = lt_code    " Table of Strings
  ).

  LOOP AT mo_objectdescr->methods ASSIGNING <ls_method> WHERE is_class = abap_false.
    CLEAR: lv_has_changing_parameter, lv_has_exporting_parameter, lv_has_returning_parameter.

    lo_mocker_method = resolve_method( <ls_method> ).
    IF mv_is_interface_mock = abap_false."is method relevant for generation?
      lv_generate_method = abap_false.
      IF lo_mocker_method IS NOT INITIAL.
        lv_generate_method = lo_mocker_method->has_registered_call_pattern( ).
      ENDIF.
      IF lv_generate_method = abap_false and <ls_method>-is_abstract eq abap_false.
        CONTINUE.
      ENDIF.
    ENDIF.

* create method stub
    IF mv_is_interface_mock = abap_true.
      CONCATENATE mv_interface '~' <ls_method>-name INTO lv_line.
    ELSE.
      lv_line = <ls_method>-name.
    ENDIF.

    CONCATENATE 'METHOD' lv_line '.' INTO lv_line SEPARATED BY space.
    APPEND lv_line TO lt_code.
    CLEAR: lv_line.

    generate_method_declarations(
      EXPORTING
        is_method = <ls_method>
      CHANGING
        ct_code   = lt_code
    ).

*   map IMPORTING parameters
    generate_importing_param_map(
      EXPORTING
        is_method = <ls_method>
      CHANGING
        ct_code   = lt_code
    ).
*   map CHANGING parameters
    generate_changing_param_map(
      EXPORTING
        is_method =  <ls_method>
      CHANGING
        ct_code   = lt_code
    ).

    generate_method_call_protocol(
      EXPORTING
        is_method = <ls_method>
      CHANGING
        ct_code   = lt_code
    ).
* is there any exception registered?
    generate_method_exc_raising(
      EXPORTING
        is_method = <ls_method>
      CHANGING
        ct_code   = lt_code    " Table of Strings
    ).

* call mocker method to retrieve values
    READ TABLE <ls_method>-parameters TRANSPORTING NO FIELDS WITH KEY parm_kind = 'E'.
    IF sy-subrc = 0.
      lv_has_exporting_parameter = abap_true.
    ENDIF.

    READ TABLE <ls_method>-parameters TRANSPORTING NO FIELDS WITH KEY parm_kind = 'C'.
    IF sy-subrc = 0.
      lv_has_changing_parameter = abap_true.
    ENDIF.
    READ TABLE <ls_method>-parameters TRANSPORTING NO FIELDS WITH KEY parm_kind = 'R'.
    IF sy-subrc = 0.
      lv_has_returning_parameter = abap_true.
    ENDIF.

    IF lv_has_changing_parameter = abap_true OR lv_has_exporting_parameter = abap_true.
      APPEND 'CALL METHOD lo_mocker_method->export' TO lt_code. "#EC NOTEXT
    ENDIF.

    IF lv_has_returning_parameter = abap_true.
      APPEND 'CALL METHOD lo_mocker_method->return' TO lt_code. "#EC NOTEXT
    ENDIF.

    IF lv_has_changing_parameter = abap_true
      OR lv_has_exporting_parameter = abap_true
      OR lv_has_returning_parameter = abap_true.
      APPEND 'EXPORTING it_importing = lt_importing it_changing_in = lt_changing_in' TO lt_code. "#EC NOTEXT
    ENDIF.

* map RETURNING parameter, if any
    IF lv_has_returning_parameter = abap_true.
      APPEND 'RECEIVING' TO lt_code.
      APPEND 'r_result = lr_return.' TO lt_code.            "#EC NOTEXT
      READ TABLE <ls_method>-parameters ASSIGNING <ls_parameter> WITH KEY parm_kind = 'R'.
      IF sy-subrc = 0.
        APPEND 'IF lr_return IS BOUND.' TO lt_code.         "#EC NOTEXT
        APPEND 'ASSIGN lr_return->* TO <lv_return>.' TO lt_code. "#EC NOTEXT
        CONCATENATE <ls_parameter>-name ' = <lv_return>.' INTO lv_line SEPARATED BY space. "#EC NOTEXT
        APPEND lv_line TO lt_code.
        APPEND 'ENDIF.' TO lt_code.
      ENDIF.
    ELSE.
*   map EXPORTING/CHANGING parameters, if any

      IF lv_has_changing_parameter = abap_true
        OR lv_has_exporting_parameter = abap_true.
        APPEND 'IMPORTING' TO lt_code.
      ENDIF.


      IF lv_has_exporting_parameter = abap_true.
        APPEND 'et_exporting = lt_exporting' TO lt_code.    "#EC NOTEXT
      ENDIF.
      IF lv_has_changing_parameter = abap_true.
        APPEND 'et_changing_out = lt_changing_out' TO lt_code. "#EC NOTEXT
      ENDIF.
      APPEND '.' TO lt_code.

      LOOP AT <ls_method>-parameters ASSIGNING <ls_parameter> WHERE parm_kind = 'E'.
        CONCATENATE 'FREE: ' <ls_parameter>-name '.' INTO lv_line SEPARATED BY space.
        APPEND lv_line TO lt_code.
        CONCATENATE 'GET REFERENCE OF' <ls_parameter>-name 'into ls_exporting-value.' INTO lv_line SEPARATED BY space. "#EC NOTEXT
        APPEND lv_line TO lt_code.
        CONCATENATE 'READ TABLE lt_exporting ASSIGNING <ls_exporting> WITH KEY parameter = ''' <ls_parameter>-name '''.' INTO lv_line. "#EC NOTEXT
        APPEND lv_line TO lt_code.
        APPEND 'IF sy-subrc = 0.' TO lt_code.               "#EC NOTEXT
        APPEND 'ASSIGN ls_exporting-value->* TO <lv_exporting_out>.' TO lt_code. "#EC NOTEXT
        APPEND 'ASSIGN <ls_exporting>-value->* TO <lv_exporting_from_mocker>.' TO lt_code. "#EC NOTEXT
        APPEND '<lv_exporting_out> = <lv_exporting_from_mocker>.' TO lt_code. "#EC NOTEXT
        APPEND 'ENDIF.' TO lt_code.                         "#EC NOTEXT
      ENDLOOP.

      LOOP AT <ls_method>-parameters ASSIGNING <ls_parameter> WHERE parm_kind = 'C'.
        IF <ls_parameter>-is_optional = abap_true.
          CONCATENATE 'IF' <ls_parameter>-name 'IS SUPPLIED.' INTO lv_line SEPARATED BY space.
        ENDIF.
        APPEND lv_line TO lt_code.
        CONCATENATE 'GET REFERENCE OF' <ls_parameter>-name 'into ls_changing_out-value.' INTO lv_line SEPARATED BY space. "#EC NOTEXT
        APPEND lv_line TO lt_code.
        CONCATENATE 'READ TABLE lt_changing_out ASSIGNING <ls_exporting> WITH KEY parameter = ''' <ls_parameter>-name '''.' INTO lv_line. "#EC NOTEXT
        APPEND lv_line TO lt_code.
        APPEND 'IF sy-subrc = 0.' TO lt_code.               "#EC NOTEXT
        APPEND 'ASSIGN ls_changing_out-value->* TO <lv_exporting_out>.' TO lt_code. "#EC NOTEXT
        APPEND 'ASSIGN <ls_exporting>-value->* TO <lv_exporting_from_mocker>.' TO lt_code. "#EC NOTEXT
        APPEND '<lv_exporting_out> = <lv_exporting_from_mocker>.' TO lt_code. "#EC NOTEXT
        APPEND 'ENDIF.' TO lt_code.
        IF <ls_parameter>-is_optional = abap_true.
          APPEND 'ENDIF.' TO lt_code.
        ENDIF.
      ENDLOOP.

    ENDIF.
    APPEND 'ENDMETHOD.' TO lt_code.
  ENDLOOP.
  APPEND 'ENDCLASS.' TO lt_code.

  DATA: lv_subrc LIKE sy-subrc.

  CALL METHOD zcl_mocka_helper_mocker=>generate_subroutine_pool
    EXPORTING
      it_code    = lt_code
    IMPORTING
      ev_message = lv_message
      ev_prog    = lv_prog
      ev_subrc   = lv_subrc.
  IF lv_subrc NE 0.
    raise_exception( lv_message ).
  ENDIF.

  CONCATENATE `\PROGRAM=` lv_prog `\CLASS=` lv_classname INTO mv_generated_class.
  ro_mockup ?= try_create_by_generated_class( ).

  DATA ls_generated_class TYPE ty_s_generated_class.
  IF mv_is_interface_mock = abap_true.
    ls_generated_class-name = mv_interface.
    ls_generated_class-technical_name = mv_generated_class.
    APPEND ls_generated_class TO mt_generated_classes.
  ENDIF.
ENDMETHOD.                    "ZIF_MOCKA_MOCKER~generate_mockup


METHOD zif_mocka_mocker~get_interface.
    rv_interface = mv_interface.
  ENDMETHOD.                    "ZIF_MOCKA_MOCKER~get_interface


METHOD zif_mocka_mocker~has_any_method_been_called.
    FIELD-SYMBOLS <ls_method> LIKE LINE OF mt_method_mocks.
    LOOP AT mt_method_mocks ASSIGNING <ls_method>.
      rv_has_been_called = <ls_method>-method_mock->has_method_been_called( ).
      IF rv_has_been_called = abap_true.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.                    "ZIF_MOCKA_MOCKER~has_any_method_been_called


METHOD zif_mocka_mocker~has_method_been_called.
*   determines, if a certain method has already been called by the generated mock object
    DATA lv_call_count TYPE i.
    DATA lv_method LIKE iv_method_name.
    lv_method = iv_method_name.
    TRANSLATE lv_method TO UPPER CASE.

    CALL METHOD me->zif_mocka_mocker~method_call_count
      EXPORTING
        iv_method_name = lv_method
      RECEIVING
        rv_call_count  = lv_call_count.
    IF lv_call_count > 0.
      rv_has_been_called = abap_true.
    ELSE.
      rv_has_been_called = abap_false.
    ENDIF.
  ENDMETHOD.                    "ZIF_MOCKA_MOCKER~has_method_been_called


METHOD zif_mocka_mocker~method.
*   resolves the requested method object
    FIELD-SYMBOLS <ls_method> TYPE abap_methdescr.
    DATA lv_method_name LIKE iv_method_name.

    lv_method_name = iv_method_name.
    TRANSLATE lv_method_name TO UPPER CASE.

    DATA ls_method TYPE ty_s_methods.
    READ TABLE mt_method_mocks INTO ls_method WITH KEY method_name = lv_method_name.
    IF sy-subrc = 0.
      ro_method = ls_method-method_mocker.
      RETURN.
    ENDIF.

    READ TABLE mo_objectdescr->methods ASSIGNING <ls_method> WITH KEY name = lv_method_name.
    IF sy-subrc NE 0.
      READ TABLE mo_objectdescr->methods ASSIGNING <ls_method> WITH KEY alias_for = lv_method_name.
    ENDIF.

    IF <ls_method> IS NOT ASSIGNED.
      RAISE EXCEPTION TYPE zcx_mocka
        EXPORTING
          textid    = zcx_mocka=>no_such_method
          interface = mv_interface
          method    = lv_method_name.
    ENDIF.

    CREATE OBJECT ro_method TYPE zcl_mocka_mocker_method
      EXPORTING
        iv_method_name = lv_method_name
        io_mocker      = me.

    ls_method-method_mocker = ro_method.
    ls_method-name = lv_method_name.
    APPEND ls_method TO mt_method_mocks.
  ENDMETHOD.                    "ZIF_MOCKA_MOCKER~method


METHOD zif_mocka_mocker~method_call_count.
*   determines, how often the specified method has already been called by the generated mock object
    FIELD-SYMBOLS <ls_method> LIKE LINE OF mt_method_mocks.
    DATA lv_method_name LIKE iv_method_name.
    lv_method_name = iv_method_name.
    TRANSLATE lv_method_name TO UPPER CASE.

    READ TABLE mt_method_mocks ASSIGNING <ls_method> WITH KEY method_name = lv_method_name.
    IF sy-subrc = 0.
      rv_call_count = <ls_method>-method_mock->times_called( ).
    ENDIF.
  ENDMETHOD.                    "ZIF_MOCKA_MOCKER~method_call_count


METHOD zif_mocka_mocker~mock.
*   returns a new mock object instance that provides the root object for recording & generating the mock object behaviour
    DATA lo_mocker TYPE REF TO zcl_mocka_mocker.
    DATA lo_typedescr TYPE REF TO cl_abap_typedescr.
    DATA lo_cx_root TYPE REF TO cx_root.
    DATA lv_message TYPE string.
    FIELD-SYMBOLS <ls_method> TYPE abap_methdescr.
    DATA lv_interface LIKE iv_interface.

    check_unit_test_execution( ).

    lv_interface = iv_interface.
    TRANSLATE lv_interface TO UPPER CASE.

    CREATE OBJECT lo_mocker.

    CALL METHOD cl_abap_intfdescr=>describe_by_name
      EXPORTING
        p_name         = lv_interface
      RECEIVING
        p_descr_ref    = lo_typedescr
      EXCEPTIONS
        type_not_found = 1
        OTHERS         = 2.
    IF sy-subrc NE 0.
      RAISE EXCEPTION TYPE zcx_mocka
        EXPORTING
          textid    = zcx_mocka=>no_such_interface
          interface = iv_interface.
    ENDIF.

    IF lo_typedescr->type_kind = cl_abap_typedescr=>typekind_class.
      lo_mocker->mv_is_interface_mock = abap_false.
    ELSE.
      lo_mocker->mv_is_interface_mock = abap_true.
    ENDIF.

    TRY.
        ro_mocker = lo_mocker.
        lo_mocker->mo_objectdescr ?= lo_typedescr.
        lo_mocker->mv_interface = lv_interface.
        LOOP AT lo_mocker->mo_objectdescr->methods ASSIGNING <ls_method>.
          lo_mocker->resolve_method( <ls_method> ).
        ENDLOOP.

        DATA ls_generated_class TYPE ty_s_generated_class.
        READ TABLE mt_generated_classes INTO ls_generated_class WITH KEY name = lv_interface.
        IF sy-subrc = 0.
          lo_mocker->mv_generated_class = ls_generated_class-technical_name.
        ENDIF.
      CATCH cx_root INTO lo_cx_root.
        lv_message = lo_cx_root->get_text( ).
        RAISE EXCEPTION TYPE zcx_mocka
          EXPORTING
            textid       = zcx_mocka=>zcx_mocka
            generic_text = lv_message.
    ENDTRY.

  ENDMETHOD.                    "ZIF_MOCKA_MOCKER~mock


METHOD zif_mocka_mocker~pass_to_super_constructor.
*   this method specifies the super contructor parameters, in case the current mock will be derived by a class instead of an interface
    DATA ls_param LIKE LINE OF mt_constructor_parameters.
    FIELD-SYMBOLS <ls_method> LIKE LINE OF mo_objectdescr->methods.
    FIELD-SYMBOLS <ls_parameter> LIKE LINE OF <ls_method>-parameters.
    DATA lr_value TYPE REF TO data.
    CLEAR: mt_constructor_parameters.

    READ TABLE mo_objectdescr->methods ASSIGNING <ls_method> WITH KEY name = 'CONSTRUCTOR'.
    IF sy-subrc = 0.
      LOOP AT <ls_method>-parameters ASSIGNING <ls_parameter> WHERE parm_kind = 'I' OR parm_kind = 'C'.
        CLEAR: lr_value.
        CASE sy-tabix.
          WHEN 1.
            IF i_p1 IS SUPPLIED.
              GET REFERENCE OF i_p1 INTO lr_value.
            ENDIF.
          WHEN 2.
            IF i_p2 IS SUPPLIED.
              GET REFERENCE OF i_p2 INTO lr_value.
            ENDIF.
          WHEN 3.
            IF i_p3 IS SUPPLIED.
              GET REFERENCE OF i_p3 INTO lr_value.
            ENDIF.
          WHEN 4.
            IF i_p4 IS SUPPLIED.
              GET REFERENCE OF i_p4 INTO lr_value.
            ENDIF.
          WHEN 5.
            IF i_p5 IS SUPPLIED.
              GET REFERENCE OF i_p5 INTO lr_value.
            ENDIF.
          WHEN 6.
            IF i_p6 IS SUPPLIED.
              GET REFERENCE OF i_p6 INTO lr_value.
            ENDIF.
          WHEN 7.
            IF i_p7 IS SUPPLIED.
              GET REFERENCE OF i_p7 INTO lr_value.
            ENDIF.
          WHEN 8.
            IF i_p8 IS SUPPLIED.
              GET REFERENCE OF i_p8 INTO lr_value.
            ENDIF.
        ENDCASE.

        IF lr_value IS BOUND.
          ls_param-value = copy_value( lr_value ).
          ls_param-name = <ls_parameter>-name.

          IF <ls_parameter>-parm_kind = 'I'.
            ls_param-kind = 'E'.
          ENDIF.
          IF <ls_parameter>-parm_kind = 'E'.
            ls_param-kind = 'I'.
          ENDIF.
          IF <ls_parameter>-parm_kind = 'C'.
            ls_param-kind = 'C'.
          ENDIF.
          INSERT ls_param INTO TABLE mt_constructor_parameters.
        ENDIF.
      ENDLOOP.
    ELSE.
*     @todo: proper exception handling
    ENDIF.
    ro_mocker = me.
  ENDMETHOD.                    "ZIF_MOCKA_MOCKER~pass_to_super_constructor
ENDCLASS.
