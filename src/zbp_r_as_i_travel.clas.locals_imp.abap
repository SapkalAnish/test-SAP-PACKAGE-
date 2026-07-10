CLASS lhc_ZR_AS_I_TRAVEL DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR travel RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR travel RESULT result.
    METHODS cancel_travel FOR MODIFY
      IMPORTING keys FOR ACTION travel~cancel_travel.

    METHODS issue_message FOR MODIFY
      IMPORTING keys FOR ACTION travel~issue_message.
    METHODS validatedescription FOR VALIDATE ON SAVE
      IMPORTING keys FOR travel~validatedescription.
    METHODS validatecustomer FOR VALIDATE ON SAVE
      IMPORTING keys FOR travel~validatecustomer.
    METHODS validatebegindate FOR VALIDATE ON SAVE
      IMPORTING keys FOR travel~validatebegindate.

    METHODS validatedatasequence FOR VALIDATE ON SAVE
      IMPORTING keys FOR travel~validatedatasequence.

    METHODS validateenddate FOR VALIDATE ON SAVE
      IMPORTING keys FOR travel~validateenddate.
    METHODS determinestatus FOR DETERMINE ON MODIFY
      IMPORTING keys FOR travel~determinestatus.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR travel RESULT result.
    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE travel.

ENDCLASS.

CLASS lhc_ZR_AS_I_TRAVEL IMPLEMENTATION.

  METHOD get_instance_authorizations.
    result = VALUE #( FOR key IN keys
                        ( %tky    = key-%tky
                          %update = if_abap_behv=>auth-allowed
                          %delete = if_abap_behv=>auth-allowed ) ).
  ENDMETHOD.

  METHOD get_global_authorizations.
    result-%create = if_abap_behv=>auth-allowed.
  ENDMETHOD.

  METHOD cancel_travel.

    READ ENTITIES OF zr_as_i_travel IN LOCAL MODE
    ENTITY travel
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_travel).

    LOOP AT lt_travel ASSIGNING FIELD-SYMBOL(<travel>).
      IF <travel>-Status <> 'C'.
        MODIFY ENTITIES OF zr_as_i_travel IN LOCAL MODE
        ENTITY travel
        UPDATE
        FIELDS ( status )
        WITH VALUE #( ( %tky = <travel>-%tky
                       status = 'C'
                                 ) ).
      ELSE.
        APPEND VALUE #( %tky = <travel>-%tky ) TO failed-travel.
        APPEND VALUE #( %tky = <travel>-%tky
                        %msg = NEW zcm_as_travel( textid = zcm_as_travel=>already_canceled )

                                  )
        TO reported-travel.


      ENDIF.
    ENDLOOP.


  ENDMETHOD.

  METHOD issue_message.
  ENDMETHOD.

  METHOD validateDescription.

    READ ENTITIES OF zr_as_i_travel IN LOCAL MODE
    ENTITY travel
    FIELDS ( Description )
    WITH CORRESPONDING #( keys )
    RESULT DATA(travels).

    LOOP AT travels ASSIGNING FIELD-SYMBOL(<travel>).

      IF <travel>-Description IS INITIAL.
        APPEND VALUE #( %tky = <travel>-%tky )
        TO failed-travel.

        APPEND VALUE #( %tky  = <travel>-%tky
                        %msg  = NEW zcm_as_travel( textid = zcm_as_travel=>field_empty )
                        %element-Description = if_abap_behv=>mk-on )
        TO  reported-travel.


      ENDIF.

    ENDLOOP.
  ENDMETHOD.

  METHOD validateCustomer.

    READ ENTITIES OF zr_as_i_travel IN LOCAL MODE
  ENTITY travel
  FIELDS ( CustomerID )
  WITH CORRESPONDING #( keys )
  RESULT DATA(travels).

    LOOP AT travels ASSIGNING FIELD-SYMBOL(<travel>).

      IF <travel>-CustomerID IS INITIAL.
        APPEND VALUE #( %tky = <travel>-%tky )
        TO failed-travel.

        APPEND VALUE #( %tky  = <travel>-%tky
                        %msg  = NEW zcm_as_travel( textid = zcm_as_travel=>customer_not_exist )
                        %element-CustomerID = if_abap_behv=>mk-on )
        TO  reported-travel.
      ELSE.
        SELECT SINGLE FROM /dmo/i_customer
        FIELDS CustomerID
        WHERE CustomerID = @<travel>-CustomerID
        INTO @DATA(dummy).

      ENDIF.

      IF sy-subrc <> 0.
        APPEND VALUE  #( %tky = <travel>-%tky )
        TO failed-travel.

        APPEND VALUE #( %tky  = <travel>-%tky
                        %msg  = NEW zcm_as_travel( textid = zcm_as_travel=>customer_not_exist
                                                    customer  = <travel>-CustomerID  )
                                                     %element-CustomerID = if_abap_behv=>mk-on )
                                                      TO  reported-travel.
      ENDIF.


    ENDLOOP.

  ENDMETHOD.

  METHOD validateBeginDate.
    READ ENTITIES OF zr_as_i_travel IN LOCAL MODE
     ENTITY travel
     FIELDS ( BeginDate )
     WITH CORRESPONDING #( keys )
     RESULT DATA(travels).

    LOOP AT travels ASSIGNING FIELD-SYMBOL(<travel>).

      IF <travel>-BeginDate IS INITIAL.
        APPEND VALUE #( %tky = <travel>-%tky )
        TO failed-travel.

        APPEND VALUE #( %tky  = <travel>-%tky
                        %msg  = NEW zcm_as_travel( textid = zcm_as_travel=>field_empty )
                        %element-BeginDate = if_abap_behv=>mk-on )
        TO  reported-travel.
      ELSEIF <travel>-BeginDate <
                                  cl_abap_context_info=>get_system_date(  ).
        APPEND VALUE #( %tky = <travel>-%tky )
        TO failed-travel.
        APPEND VALUE #( %tky  = <travel>-%tky
                        %msg  = NEW zcm_as_travel( textid = zcm_as_travel=>begin_date_past )
                        %element-BeginDate = if_abap_behv=>mk-on )
        TO  reported-travel.



      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validateDataSequence.
    READ ENTITIES OF zr_as_i_travel IN LOCAL MODE
     ENTITY travel
     FIELDS ( BeginDate EndDate )
     WITH CORRESPONDING #( keys )
     RESULT DATA(travels).

    LOOP AT travels ASSIGNING FIELD-SYMBOL(<travel>).

      IF <travel>-EndDate < <travel>-BeginDate.
        APPEND VALUE #( %tky = <travel>-%tky )
        TO failed-travel.

        APPEND VALUE #( %tky  = <travel>-%tky
                        %msg  = NEW zcm_as_travel( textid = zcm_as_travel=>dates_wrong_sequence )
                        %element = VALUE #( BeginDate = if_abap_behv=>mk-on
                                            EndDate   = if_abap_behv=>mk-on ) )
        TO  reported-travel.

      ENDIF.
    ENDLOOP.


  ENDMETHOD.

  METHOD validateEndDate.

    READ ENTITIES OF zr_as_i_travel IN LOCAL MODE
      ENTITY travel
      FIELDS ( EndDate )
      WITH CORRESPONDING #( keys )
      RESULT DATA(travels).

    LOOP AT travels ASSIGNING FIELD-SYMBOL(<travel>).

      IF <travel>-EndDate IS INITIAL.
        APPEND VALUE #( %tky = <travel>-%tky )
        TO failed-travel.

        APPEND VALUE #( %tky  = <travel>-%tky
                        %msg  = NEW zcm_as_travel( textid = zcm_as_travel=>field_empty )
                        %element-BeginDate = if_abap_behv=>mk-on )
        TO  reported-travel.
      ELSEIF <travel>-EndDate <
                                  cl_abap_context_info=>get_system_date(  ).
        APPEND VALUE #( %tky = <travel>-%tky )
        TO failed-travel.
        APPEND VALUE #( %tky  = <travel>-%tky
                        %msg  = NEW zcm_as_travel( textid = zcm_as_travel=>end_date_past )
                        %element-BeginDate = if_abap_behv=>mk-on )
        TO  reported-travel.



      ENDIF.
    ENDLOOP.




  ENDMETHOD.

METHOD earlynumbering_create.

  SELECT SINGLE COUNT( * ) FROM /dmo/travel INTO @DATA(lv_travelid).

  mapped-travel = CORRESPONDING #( entities ).

  LOOP AT mapped-travel ASSIGNING FIELD-SYMBOL(<mapping>).

    lv_travelid += 1.
    <mapping>-TravelId = lv_travelid.

    TRY.
        <mapping>-Travel_UUID = cl_system_uuid=>create_uuid_x16_static( ).
      CATCH cx_uuid_error.
        " Extremely rare — only happens if system UUID generation fails
        CLEAR <mapping>-Travel_UUID.
    ENDTRY.

  ENDLOOP.

ENDMETHOD.

METHOD determineStatus.
  READ ENTITIES OF zr_as_i_travel IN LOCAL MODE
    ENTITY Travel
      FIELDS ( Status )
      WITH CORRESPONDING #( keys )
      RESULT DATA(travels).
  DELETE travels WHERE Status IS NOT INITIAL.
  CHECK travels IS NOT INITIAL.
  MODIFY ENTITIES OF zr_as_i_travel IN LOCAL MODE
    ENTITY Travel
      UPDATE FIELDS ( Status )
      WITH VALUE #( FOR key IN travels ( %tky   = key-%tky
                                         Status = 'N' )  )
      REPORTED DATA(update_reported).
  reported = CORRESPONDING #( DEEP update_reported ).
ENDMETHOD.


  METHOD get_instance_features.
  ENDMETHOD.

ENDCLASS.
