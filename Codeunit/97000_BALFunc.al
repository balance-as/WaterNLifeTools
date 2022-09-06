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



    /* [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Inventory Pick/Movement", 'OnCreatePickOrMoveLineOnAfterCalcShouldInsertPickOrMoveDefaultBin', '', true, true)]
     local procedure SetBinRanking(NewWarehouseActivityLine: Record "Warehouse Activity Line"; var RemQtyToPickBase: Decimal; OutstandingQtyBase: Decimal; ReservationExists: Boolean; var ShouldInsertPickOrMoveDefaultBin: Boolean)
     begin
         ShouldInsertPickOrMoveDefaultBin := true;
     end;
     */
}