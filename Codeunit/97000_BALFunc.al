codeunit 97000 "BAL Func"
{
    trigger OnRun()
    var
        cu: Codeunit 7322;
        FromBinContent: Record "Bin Content";
    begin
        //cu.OnFindBWPickBinOnBeforeFromBinContentFindSet(FromBinContent, SourceType, TotalQtyPickedBase, TotalQtyToPickBase, IsHandled);)
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Inventory Pick/Movement", 'OnBeforeFindFromBinContent', '', true, true)]
    local procedure SetBinRanking(var FromBinContent: Record "Bin Content"; var WarehouseActivityLine: Record "Warehouse Activity Line"; FromBinCode: Code[20]; BinCode: Code[20]; IsInvtMovement: Boolean; IsBlankInvtMovement: Boolean)
    var
        BALSetup: record "BAL WaterNlife Setup";
    begin
        if BALSetup.get and (BALSetup."Bin Ranking filter" <> '') then
            if WarehouseActivityLine."Source Document" = WarehouseActivityLine."Source document"::"Outbound Transfer" then
                FromBinContent.setfilter("Bin Ranking", BALSetup."Bin Ranking filter");
    end;


    procedure MoveLocation(SalesHeader: record "Sales Header"; Countryfilter: text; ToLocation: Code[10]);
    var
        location: Record Location;
        SalesLine: Record "Sales Line";
        i: integer;
        MessageTxt: label '%1 %2 is change from %3 %4 to %5 ';
        NoActionTxt: Label 'No orders to change';
    begin
        SalesHeader.setfilter("Sell-to Country/Region Code", Countryfilter);
        SalesHeader.setfilter("Location Code", '%1', 'GRAMRODE13');
        if SalesHeader.findset then begin
            salesheader.SetHideValidationDialog(true);
            repeat
                salesheader.validate("Location Code", ToLocation);
                salesheader.modify;
                SalesLine.setrange("Document Type", SalesHeader."Document Type");
                SalesLine.setrange("Document No.", SalesHeader."No.");
                SalesLine.SetRange(type, SalesLine.type::Item);
                SalesLine.setfilter("No.", '<>%1', '');
                if SalesLine.FindSet() then
                    repeat
                        SalesLine.Validate("Location Code", SalesHeader."Location Code");
                        SalesLine.modify;
                    until salesline.next = 0;
                i += 1;
            until salesheader.next = 0;
            Message(MessageTxt, i, SalesHeader.TableCaption, SalesHeader.FieldCaption("Location Code"), 'GRAMRODE13', ToLocation);
        end else
            message(NoActionTxt);

    end;

    /* [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Inventory Pick/Movement", 'OnCreatePickOrMoveLineOnAfterCalcShouldInsertPickOrMoveDefaultBin', '', true, true)]
     local procedure SetBinRanking(NewWarehouseActivityLine: Record "Warehouse Activity Line"; var RemQtyToPickBase: Decimal; OutstandingQtyBase: Decimal; ReservationExists: Boolean; var ShouldInsertPickOrMoveDefaultBin: Boolean)
     begin
         ShouldInsertPickOrMoveDefaultBin := true;
     end;
     */
}