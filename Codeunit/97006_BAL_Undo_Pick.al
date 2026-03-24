codeunit 97006 "BAL Undo Pick"
{
    trigger OnRun()
    begin

    end;

    var

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Undo Posting Management", 'OnBeforeTestPostedInvtPickLine', '', true, true)]
    local procedure CodeunitUndoPostingManagementOnBeforeTestPostedInvtPickLine(SourceID: Code[20]; SourceRefNo: Integer; SourceSubtype: Integer; SourceType: Integer; UndoID: Code[20]; UndoLineNo: Integer; UndoType: Integer; var IsHandled: Boolean)
    var
        PostedInvtPickLine: Record "Posted Invt. Pick Line";
        PostedInvtPickHeader: Record "Posted Invt. Pick Header";
        CheckedPostedInvtPickHeaderList: List of [Text];
    begin
        PostedInvtPickLine.SetSourceFilter(SourceType, SourceSubtype, SourceID, SourceRefNo, true);
        if not (UndoType in [Database::"Transfer Shipment Line"]) then begin
            IsHandled := false;
            exit;
        end;
        IsHandled := true;
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Undo Transfer Shipment", 'OnBeforeModifyTransShptLine', '', true, true)]
    local procedure CodeunitUndoPostingManagementOnBeforeModifyTransShptLine(var TransferShipmentLine: Record "Transfer Shipment Line")
    var
        Location: record Location;
        WhseEntry: Record "Warehouse Entry";
        ItemJnlLine: record "Item Journal Line";
        WMSManagement: Codeunit "WMS Management";
        WhseJnlLine: Record "Warehouse Journal Line";
        WhseJnlRegisterLine: Codeunit "Whse. Jnl.-Register Line";
    begin
        WhseEntry.setrange("Reference No.", TransferShipmentLine."Document No.");
        WhseEntry.setrange("Registering Date", TransferShipmentLine."Shipment Date");
        WhseEntry.setrange("Item No.", TransferShipmentLine."Item No.");
        if WhseEntry.FindSet() then begin
            repeat
                location.get(WhseEntry."Location Code");
                Location.TestField("BAL Wrong Pick Bin");
                Location.TestField("BAL Wrong Batch name");
                ItemJnlLine."Journal Template Name" := 'OMKLASSIFI';
                ItemJnlLine.setrange("Journal Batch Name", Location."BAL Wrong Batch Name");
                ItemJnlLine."Journal Batch Name" := Location."BAL Wrong Batch Name";
                ItemJnlLine.validate("Item No.", WhseEntry."Item No.");
                ItemJnlLine.validate("Posting Date", WhseEntry."Registering Date");
                ItemJnlLine.Validate("Document No.", WhseEntry."Whse. Document No.");
                ItemJnlLine.Validate("Document Type", WhseEntry."Whse. Document Type");
                ItemJnlLine.Validate("Document Line No.", WhseEntry."Whse. Document Line No.");
                ItemJnlLine."Entry Type" := ItemJnlLine."Entry Type"::Transfer;
                ItemJnlLine.validate("Location Code", WhseEntry."Location Code");
                ItemJnlLine.Validate("Bin Code", WhseEntry."Bin Code");
                ItemJnlLine.validate("New Location Code", WhseEntry."Location Code");
                ItemJnlLine.validate("New Bin Code", Location."BAL Wrong Pick Bin");
                ItemJnlLine.Validate(Quantity, WhseEntry.Quantity);
                WMSManagement.CreateWhseJnlLine(ItemJnlLine, 0, WhseJnlLine, false);
                WhseJnlRegisterLine.run(WhseJnlLine);
            until WhseEntry.Next = 0;
        end;
    end;
}