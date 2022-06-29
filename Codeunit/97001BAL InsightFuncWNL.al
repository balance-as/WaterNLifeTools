codeunit 97001 "BAL InsightFunc WNL"
{
    TableNo = "IWX Event Param";
    trigger OnRun()
    var

        liEventID: Integer;
        ltxtOutputText: BigText;
        losReturnMessage: OutStream;

    begin
        CodRegionCode := Rec.getValue('device_culture');

        liEventID := Rec.getEvent();
        BALExecuteEvent(liEventID, Rec, ltxtOutputText);
        rec."Extensibility Blob".CREATEOUTSTREAM(losReturnMessage);
        ltxtOutputText.WRITE(losReturnMessage);
        rec.MODIFY();
    end;

    var
        iEventID: Integer;
        codRegionCode: code[10];
    //        cuJournalFuncs: Codeunit "WHI Journal Functions";
    //      cuCommonFuncs: Codeunit "WHI Common Functions";

    procedure BALExecuteEvent(PiEventId: integer; var ptrecEventParams: record "IWX Event Param" temporary; var pbsoutput: BigText);
    var
        lEventID: Integer;
        ltextOutputText: BigText;
        losReturnMessage: OutStream;
    begin

        case PiEventId of

            2000102:
                BALAddItemTrackingInventory(ptrecEventParams, pbsoutput);
            2000106:
                PostInventoryBatch(ptrecEventParams, pbsoutput)
        end;
    end; // Case



    procedure BALAddItemTrackingInventory(var ptrecEventParams: record "IWX Event Param" temporary; var pbsoutput: BigText)
    var
        Location: record Location;
        Bin: Record Bin;
        ItemNo: code[20];
        Item: record Item;
        Item2: Record Item;
        TempReservationEntry: record "Reservation Entry";
        //        KMESetup: record "BAL Kaffe Mekka Setup";
        LotNo: Code[20];
        lcuWHICommond: Codeunit "WHI Common Functions";
        CreateReservEntry: Codeunit "Create Reserv. Entry";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        //  BALInsightFunc: Codeunit "BAL InsightFunc";
        ItemJnLine: Record "Item Journal Line";
        Status: Enum "Reservation Status";
        WHIBasicCountMgmt: Codeunit 23044924;
        TemplateName: code[10];
    begin

        WHIBasicCountMgmt.executeEvent(97003, ptrecEventParams, pbsoutput);

        location.get(ptrecEventParams.getValue('location'));
        itemno := ptrecEventParams.getValue('item_number');
        LotNo := ptrecEventParams.getValue('lot_number');
        //ItemJnLine.SetRange("Journal Template Name", ptrecEventParams.getValue('Journal Template Name'));
        ItemJnLine.setrange("Phys. Inventory", true);
        ItemJnLine.setrange("Journal Batch Name", ptrecEventParams.getValue('name'));
        ItemJnLine.setrange("Item No.", ItemNo);
        ItemJnLine.FindSet;
        if not ItemJnLine.FindSet then
            exit;

        if strpos(LotNo, '%LN%') > 0 then
            LotNo := copystr(LotNo, 5);
        TempReservationEntry."Lot No." := LotNo;
        TempReservationEntry."Reservation Status" := TempReservationEntry."Reservation Status"::Prospect;
        item.get(ItemNo);
        if Item.get(ItemJnLine."Item No.") and (format(Item."Expiration Calculation") <> '') then
            CreateReservEntry.SetDates(0D, calcdate(Item."Expiration Calculation", WorkDate()))
        else
            CreateReservEntry.SetDates(0D, 0D);
        CreateReservEntry.CreateReservEntryFor(DATABASE::"Item Journal Line", 2, ItemJnLine."Journal Template Name", ItemJnLine."Journal Batch Name", 0, ItemJnLine."Line No.", ItemJnLine."Qty. per Unit of Measure", ItemJnLine.Quantity, ItemJnLine."Quantity (Base)", TempReservationEntry);
        CreateReservEntry.CreateEntry(ItemJnLine."Item No.", ItemJnLine."Variant Code", ItemJnLine."Location Code", ItemJnLine.Description, ItemJnLine."Posting Date", ItemJnLine."Posting Date", 0, Status::Prospect);
    end;
 local procedure PostInventoryBatch(var ptrecEventParams: record "IWX Event Param" temporary; var pbsoutput: BigText)
    var
        lcuWHICommond: Codeunit "WHI Common Functions";
        ItemJnLine: Record "Item Journal Line";
        ItemJnlPostBatch: Codeunit "Item Jnl.-Post Batch";
    begin
        ItemJnLine.SETRANGE("Journal Template Name", ptrecEventParams.getValue('Journal Template Name'));
        ItemJnLine.SETRANGE("Journal Batch Name", ptrecEventParams.getValue('Name'));
        IF ItemJnLine.FINDLAST THEN
            ItemJnlPostBatch.RUN(ItemJnLine);
        LcuWHICommond.generateSuccessReturn('Posted', PBSOutPut);
    end;
}
