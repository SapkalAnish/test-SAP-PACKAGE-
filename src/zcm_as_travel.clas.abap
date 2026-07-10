CLASS zcm_as_travel DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC INHERITING FROM cx_static_check  .

  PUBLIC SECTION.

*INTERFACES if_message .
    INTERFACES if_abap_behv_message .
    INTERFACES if_t100_dyn_msg .
    INTERFACES if_t100_message .

    CONSTANTS : BEGIN OF already_canceled,
                  msgid TYPE symsgid VALUE '/LRN/S4D437',
                  msgno TYPE symsgno VALUE '130',
                  attr1 TYPE scx_attrname VALUE 'Travel is already cancelled ',
                  attr2 TYPE scx_attrname VALUE '',
                  attr3 TYPE scx_attrname VALUE '',
                  attr4 TYPE scx_attrname VALUE '',
                END OF already_canceled.

    CONSTANTS : BEGIN OF field_empty,
                  msgid TYPE symsgid VALUE '/LRN/S4D437',
                  msgno TYPE symsgno VALUE '140',
                  attr1 TYPE scx_attrname VALUE 'please enter value',
                  attr2 TYPE scx_attrname VALUE 'please enter description',
                  attr3 TYPE scx_attrname VALUE '',
                  attr4 TYPE scx_attrname VALUE '',
                END OF field_empty.

    CONSTANTS : BEGIN OF customer_not_exist,
                  msgid TYPE symsgid VALUE '/LRN/S4D437',
                  msgno TYPE symsgno VALUE '150',
                  attr1 TYPE scx_attrname VALUE 'please enter customerid',
                  attr2 TYPE scx_attrname VALUE '',
                  attr3 TYPE scx_attrname VALUE '',
                  attr4 TYPE scx_attrname VALUE '',
                END OF customer_not_exist.

    CONSTANTS : BEGIN OF begin_date_past,
                  msgid TYPE symsgid VALUE '/LRN/S4D437',
                  msgno TYPE symsgno VALUE '160',
                  attr1 TYPE scx_attrname VALUE 'please enter valid begin date',
                  attr2 TYPE scx_attrname VALUE ' the data is already past',
                  attr3 TYPE scx_attrname VALUE '',
                  attr4 TYPE scx_attrname VALUE '',
                END OF begin_date_past.

    CONSTANTS : BEGIN OF end_date_past,
                  msgid TYPE symsgid VALUE '/LRN/S4D437',
                  msgno TYPE symsgno VALUE '170',
                  attr1 TYPE scx_attrname VALUE 'please enter valid end date',
                  attr2 TYPE scx_attrname VALUE ' the data is already past',
                  attr3 TYPE scx_attrname VALUE '',
                  attr4 TYPE scx_attrname VALUE '',
                END OF end_date_past.

    CONSTANTS : BEGIN OF dates_wrong_sequence,
                  msgid TYPE symsgid VALUE '/LRN/S4D437',
                  msgno TYPE symsgno VALUE '150',
                  attr1 TYPE scx_attrname VALUE 'please enter valid  dates ',
                  attr2 TYPE scx_attrname VALUE ' the dates squence is wrong please correct it ',
                  attr3 TYPE scx_attrname VALUE '',
                  attr4 TYPE scx_attrname VALUE '',
                END OF dates_wrong_sequence.


    METHODS constructor
      IMPORTING
        !textid  LIKE if_t100_message=>t100key OPTIONAL
*!previous LIKE previous OPTIONAL
        severity LIKE if_abap_behv_message~m_severity OPTIONAL
        customer TYPE /dmo/customer_id OPTIONAL.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcm_as_travel IMPLEMENTATION.

  METHOD constructor ##ADT_SUPPRESS_GENERATION.
    CALL METHOD super->constructor.
    IF textid IS INITIAL.

      if_t100_message~t100key = if_t100_message=>default_textid.
    ELSE.

      if_t100_message~t100key = textid.
    ENDIF.
    IF severity IS INITIAL.
      if_abap_behv_message~m_severity = if_abap_behv_message~severity-error.
    ELSE.
      if_abap_behv_message~m_severity = severity.
    ENDIF.

    IF customer IS INITIAL.

      if_abap_behv_message~m_severity = if_abap_behv_message~severity-error.
    ELSE.
      if_abap_behv_message~m_severity = severity.

    ENDIF.

  ENDMETHOD.


ENDCLASS.
