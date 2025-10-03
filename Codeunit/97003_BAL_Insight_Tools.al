codeunit 97003 "BAL WHI Basic Count Mgmt."
{
    // ************************
    // Copyright Notice
    // This objects content is copyright of Insight Works 2011.  All rights reserved.
    // Any redistribution or reproduction of part or all of the contents in any form is prohibited.
    // ************************
    // Balance 08-12-2022, a copy of Insight Works Count codeunit from textfile 924 

    TableNo = "IWX Event Param";

    trigger OnRun()
    var
        ltxtOutputText: BigText;
        liEventID: Integer;
        losReturnMessage: OutStream;
    begin
        liEventID := Rec.getEvent();
        executeEvent(liEventID, Rec, ltxtOutputText);
        Rec."Extensibility Blob".CreateOutStream(losReturnMessage);
        ltxtOutputText.Write(losReturnMessage);
        Rec.Modify();
    end;



    procedure executeEvent(piEventID: Integer; var ptrecEventParams: Record "IWX Event Param" temporary; var pbsOutput: BigText)
    begin
        iEventID := piEventID;

        case piEventID of
            2000109:
                getJournalBatchList(ptrecEventParams, pbsOutput);
            2000110:
                getJournalBatch(ptrecEventParams, pbsOutput);
            2000112:
                updateJournalLine(ptrecEventParams, pbsOutput);
            2000113:
                createJournalLine(ptrecEventParams, pbsOutput);
            2000114:
                deleteJournalLine(ptrecEventParams, pbsOutput);
            2000115:
                ReturnBachnamefromUserId(ptrecEventParams, pbsOutput);
            2000116:
                updateInvJournalLine(ptrecEventParams, pbsOutput);
            2000117:
                BALAddItemTrackingInventory(ptrecEventParams, pbsOutput);
        end;
    end;

    //<FUNC>
    // This function returns a list of all available Item Journal batches of type "Item"
    //</FUNC>
    local procedure getJournalBatchList(var ptrecEventParams: Record "IWX Event Param" temporary; var pbsOutput: BigText)
    var
        lrecItemJnlBatch: Record "Item Journal Batch";
        lrrefLines: RecordRef;
        ldnOutput: TextBuilder;
    begin
        lrecItemJnlBatch.SetRange(lrecItemJnlBatch."Journal Template Name", GetGenJournalTemplateName());

        if lrecItemJnlBatch.FindSet() then;

        lrrefLines.GetTable(lrecItemJnlBatch);

        cuDatasetTools.BuildLinesOnlyDataset(iEventID, lrrefLines, false, ldnOutput);

        pbsOutput.AddText(ldnOutput.ToText());
        cuActivityLogMgt.logActivity(ptrecEventParams);
    end;

    //<FUNC>
    // This function returns an Item Journal batch of type "Item"
    //</FUNC>
    local procedure getJournalBatch(var ptrecEventParams: Record "IWX Event Param" temporary; var pbsOutput: BigText)
    var
        lrecItemJnlBatch: Record "Item Journal Batch";
        lrecItemJnlLine: Record "Item Journal Line";
        lrecLocation: Record Location;
        lrrefHeader: RecordRef;
        lrrefLine: RecordRef;
        ldnOutput: TextBuilder;
        lbNeedsItemTrackingTable: Boolean;
        lcodBatchName: Code[20];
    begin
        lcodBatchName := CopyStr(ptrecEventParams.GetExtendedValue('Name'), 1, MaxStrLen(lcodBatchName));
        ptrecEventParams.getLocation(lrecLocation);

        lrecItemJnlBatch.Get(GetgenJournalTemplateName(), lcodBatchName);

        // error out if a no. series has been set on batch (better to do up front than when posting)
        if lrecItemJnlBatch."No. Series" <> '' then
            Error(tcWrongSeriesErr,
                  lcodBatchName,
                  lrecItemJnlBatch.FieldCaption("No. Series"),
                  lrecItemJnlBatch.FieldCaption("Posting No. Series"));

        // filter the header
        lrecItemJnlBatch.SetRange("Journal Template Name", lrecItemJnlBatch."Journal Template Name");
        lrecItemJnlBatch.SetRange(Name, lcodBatchName);
        if lrecItemJnlBatch.FindSet() then;

        // filter the lines
        lrecItemJnlLine.Reset();
        lrecItemJnlLine.SetRange("Journal Template Name", lrecItemJnlBatch."Journal Template Name");
        lrecItemJnlLine.SetRange("Journal Batch Name", lcodBatchName);
        lrecItemJnlLine.SetRange("Location Code", lrecLocation.Code);
        if lrecItemJnlLine.FindSet() then;

        // prepare the recordrefs
        lrrefHeader.GetTable(lrecItemJnlBatch);
        lrrefLine.GetTable(lrecItemJnlLine);

        lbNeedsItemTrackingTable := ptrecEventParams.getNeedsItemTrackingTable();

        // build the xml
        cuDatasetTools.BuildHeaderLineDataset(
          iEventID,
          lrrefHeader,
          lrrefLine,
          lbNeedsItemTrackingTable,
          ldnOutput);

        pbsOutput.AddText(ldnOutput.ToText());

        ptrecEventParams.setValue('Document Type', Format(DATABASE::"Item Journal Line"));
        ptrecEventParams.setValue('Document No.', lcodBatchName);
        cuActivityLogMgt.logActivity(ptrecEventParams);
    end;

    //<FUNC>
    // This function updates the Item Journal Batch Lines Quantities
    //</FUNC>
    local procedure createJournalLine(var ptrecEventParams: Record "IWX Event Param" temporary; var pbsOutput: BigText)
    var
        lrecItemJournalLine: Record "Item Journal Line";
        lrrefItemJournalLine: RecordRef;
        BinContent: record "Bin Content";
        ldnOutput: TextBuilder;
        ldtPostingDate: Date;
        lcodItemNo: Code[20];
        lcodVariant: Code[10];
        lcodJournalBatchNo: Code[10];
        lcodBin: Code[20];
        lcodJournalTemplateName: Code[10];
        lcodLocation: Code[10];
        ldQuantity: Decimal;
        liNewLineNumber: Integer;
    begin
        lcodJournalTemplateName := GetGenJournalTemplateName();
        lcodJournalBatchNo := CopyStr(ptrecEventParams.GetExtendedValue('Name'), 1, MaxStrLen(lcodJournalBatchNo));
        if (lcodJournalBatchNo = '') then // if we don't have a known batch, get an auto-batch.
            lcodJournalBatchNo := cuJournalFuncs.getItemJnlPhysInvBatchToUse(ptrecEventParams);

        ldQuantity := ptrecEventParams.getValueAsDecimal('quantity');
        lcodItemNo := CopyStr(ptrecEventParams.GetExtendedValue('item_number'), 1, MaxStrLen(lcodItemNo));
        lcodVariant := CopyStr(ptrecEventParams.GetExtendedValue('variant_code'), 1, MaxStrLen(lcodVariant));
        lcodBin := CopyStr(ptrecEventParams.GetExtendedValue('bin'), 1, MaxStrLen(lcodBin));
        lcodLocation := CopyStr(ptrecEventParams.GetExtendedValue('location'), 1, MaxStrLen(lcodLocation));
        ldtPostingDate := cuCommonFuncs.GetTodaysDate(ptrecEventParams);

        //Insert
        if lcodBin = '' then begin
            BinContent.setrange("Location Code", lcodLocation);
            bincontent.setrange("Item No.", lcodItemNo);
            bincontent.setrange(Default, true);
            if BinContent.findset then
                lcodBin := BinContent."Bin Code";
        end;
        liNewLineNumber := CreateItemJnlEntry(lcodJournalBatchNo, lcodItemNo, lcodLocation, lcodVariant, lcodBin, ldQuantity, ldtPostingDate);

        lrecItemJournalLine.Get(lcodJournalTemplateName, lcodJournalBatchNo, liNewLineNumber);
        lrecItemJournalLine.SetRecFilter();
        lrrefItemJournalLine.GetTable(lrecItemJournalLine);
        cuDatasetTools.BuildLineTableEmbedRes(2000110, lrrefItemJournalLine, false, ldnOutput);
        pbsOutput.AddText(ldnOutput.ToText());
        ptrecEventParams.setValue('Document Type', Format(DATABASE::"Item Journal Line"));
        ptrecEventParams.setValue('Document No.', lcodJournalBatchNo);
        ptrecEventParams.setValue('New Quantity', Format(ldQuantity));
        cuActivityLogMgt.logActivity(ptrecEventParams);
    end;

    //<FUNC>
    // This function updates the Item Journal Batch Lines Quantities
    //</FUNC>
    local procedure updateJournalLine(var ptrecEventParams: Record "IWX Event Param" temporary; var pbsOutput: BigText)
    var
        lrecItemJournalLine: Record "Item Journal Line";
        lrrefUpdatedLine: RecordRef;
        ldQuantity: Decimal;
        ldnOutput: TextBuilder;
        ldPreviousQuantity: Decimal;
    begin
        ldQuantity := ptrecEventParams.getValueAsDecimal('quantity');

        getSpecificLine(ptrecEventParams, lrecItemJournalLine);
        ldPreviousQuantity := lrecItemJournalLine.quantity;
        lrecItemJournalLine.Validate(Quantity, ldQuantity);

        lrecItemJournalLine.Modify();
        lrecItemJournalLine.SetRecFilter(); // only care about our 1 line that we just updated
        lrrefUpdatedLine.GetTable(lrecItemJournalLine);
        cuDatasetTools.BuildLineTableEmbedRes(97001, lrrefUpdatedLine, false, ldnOutput);
        pbsOutput.AddText(ldnOutput.ToText());

        ptrecEventParams.setValue('Document Type', Format(DATABASE::"Item Journal Line"));
        ptrecEventParams.setValue('Document No.', lrecItemJournalLine."Journal Batch Name");
        ptrecEventParams.setValue('Line No.', Format(lrecItemJournalLine."Line No."));
        ptrecEventParams.setValue('quantity', Format(ldPreviousQuantity));
        ptrecEventParams.setValue('Qty.(Pys. Inventory)', Format(ldQuantity));
        cuActivityLogMgt.logActivity(ptrecEventParams);

    end;

    //<FUNC>
    // This function deletes the selected Item Journal Line
    //</FUNC>
    local procedure deleteJournalLine(var ptrecEventParams: Record "IWX Event Param" temporary; var pbsOutput: BigText)
    var
        lrecItemJournalLine: Record "Item Journal Line";
    begin
        getSpecificLine(ptrecEventParams, lrecItemJournalLine);

        ptrecEventParams.setValue('Document Type', Format(DATABASE::"Item Journal Line"));
        ptrecEventParams.setValue('Document No.', lrecItemJournalLine."Journal Batch Name");
        ptrecEventParams.setValue('Line No.', Format(lrecItemJournalLine."Line No."));
        cuActivityLogMgt.logActivity(ptrecEventParams);

        lrecItemJournalLine.Delete();
        cuCommonFuncs.generateSuccessReturn(pbsOutput);
    end;

    local procedure getSpecificLine(var ptrecEventParams: Record "IWX Event Param" temporary; var precOutPhysJournalLine: Record "Item Journal Line") pbSuccess: Boolean
    var
        lcodJournalTemplateName: Code[10];
        lcodJournalBatchName: Code[10];
    begin
        lcodJournalTemplateName := GetGenJournalTemplateName();
        lcodJournalBatchName := CopyStr(ptrecEventParams.GetExtendedValue('Name'), 1, MaxStrLen(lcodJournalBatchName));
        // if we don't have a known batch, get an auto-batch.
        if (lcodJournalBatchName = '') then
            Error('Fejl i parameter ring balance.as');// lcodJournalBatchName := cuJournalFuncs.getItemJnlPhysInvBatchToUse(ptrecEventParams);
        precOutPhysJournalLine.Get(lcodJournalTemplateName, lcodJournalBatchName, ptrecEventParams.getValueAsInt('Line No.'));
        pbSuccess := precOutPhysJournalLine.Get(lcodJournalTemplateName, lcodJournalBatchName, ptrecEventParams.getValueAsInt('Line No.'));
    end;

    local procedure CreateItemJnlEntry(pcodBatchName: Code[10]; pcodItemNo: Text; pcodLocationCode: Code[20]; pcodVariant: Text; pcodBinCode: Code[20]; pdQuantity: Decimal; pdtPostingDate: Date): Integer
    var
        lrecItemJnl: Record "Item Journal Line";
        lrecItemJnlTemplate: Record "Item Journal Template";
        lrecItemJnlBatch: Record "Item Journal Batch";
        lrecBinContent: Record "Bin Content";
        lrecLocation: Record "Location";
        lrecItem: Record "Item";
        lnLineNo: Integer;
    begin
        // adds a journal line for given params

        lrecItemJnlTemplate.SetRange("Page ID", PAGE::"Item Journal");
        lrecItemJnlTemplate.SetRange(Type, lrecItemJnlTemplate.Type::Item);
        lrecItemJnlTemplate.FindFirst();


        lrecItemJnlBatch.Get(lrecItemJnlTemplate.Name, pcodBatchName);

        lrecItemJnl.SetRange("Journal Template Name", lrecItemJnlTemplate.Name);
        lrecItemJnl.SetRange("Journal Batch Name", pcodBatchName);

        if lrecItemJnl.FindLast() then;

        lnLineNo := lrecItemJnl."Line No." + 10000;

        Clear(lrecItemJnl);

        lrecItemJnl."Journal Template Name" := lrecItemJnlTemplate.Name;
        lrecItemJnl."Journal Batch Name" := pcodBatchName;
        lrecItemJnl."Source Code" := lrecItemJnlTemplate."Source Code";
        lrecItemJnl."Entry Type" := lrecItemJnl."Entry Type"::"Negative Adjmt."; //lrecItemJnlTemplate.Type.AsInteger();

        lrecItemJnl."Line No." := lnLineNo;

        lrecItemJnl.Validate("Posting Date", pdtPostingDate);
        lrecItemJnl."Document No." := 'NED' + Format(pdtPostingDate, 0, '<year4>-<day,2>-<month,2>');
        lrecItemJnl."Phys. Inventory" := false;
        lrecItemJnl.Validate("Item No.", pcodItemNo);
        lrecItemJnl.Validate("Qty. per Unit of Measure", 1);
        lrecItemJnl.Validate("Location Code", pcodLocationCode);
        lrecItemJnl.Validate("Variant Code", pcodVariant);

        if pcodBinCode <> '' then
            lrecItemJnl.Validate("Bin Code", pcodBinCode);
        lrecItemJnl.Insert(true);

        lrecItemJnl.Validate(Quantity, pdQuantity);

        lrecBinContent.SetRange("Item No.", pcodItemNo);
        lrecBinContent.SetRange("Location Code", pcodLocationCode);
        lrecBinContent.SetRange("Variant Code", pcodVariant);
        lrecLocation.Get(lrecItemJnl."Location Code");
        if lrecItemJnlBatch."Reason Code" <> '' then
            lrecItemJnl.Validate("Reason Code", lrecItemJnlBatch."Reason Code");
        lrecItemJnl.Modify();
        exit(lrecItemJnl."Line No.");
    end;

    procedure GetJournalTemplateNameminus(): Code[10]
    var
    begin
        exit(cuJournalFuncs.getItemJnlTemplate(PAGE::"Phys. Inventory Journal", 2));
    end;

    procedure GetGenJournalTemplateName(): Code[10]
    var
    begin
        exit(cuJournalFuncs.getItemJnlTemplate(PAGE::"Item Journal", 0));
    end;

    procedure GetJournalTemplateName(): Code[10]
    var
    begin
        exit(cuJournalFuncs.getItemJnlTemplate(PAGE::"Phys. Inventory Journal", 2));
    end;

    procedure RemoveUserDomain(pcodUserNameWithDomain: Code[100]): Code[100]

    var
        liCheckDelimiter: Integer;
    begin
        liCheckDelimiter := StrPos(pcodUserNameWithDomain, '\');
        if (liCheckDelimiter > 0) then
            exit(CopyStr(pcodUserNameWithDomain, liCheckDelimiter + 1, 100));

        exit(pcodUserNameWithDomain);
    end;

    local procedure ReturnBachnamefromUserId(var ptrecEventParams: Record "IWX Event Param" temporary; var pbsOutput: BigText)
    var
        lrecItemJnlBatch: Record "Item Journal Batch";
        lrecItemJnlLine: Record "Item Journal Line";
        lrecLocation: Record Location;
        lrrefHeader: RecordRef;
        lrrefLine: RecordRef;
        ldnOutput: TextBuilder;
        lbNeedsItemTrackingTable: Boolean;
        lcodBatchName: Code[20];
        cuJournalFunc: Codeunit "WHI Journal Functions";
        lcodUserName: Code[100];
        lcodReclassBatch: Code[10];
        lcodTemplateName: Code[10];
    begin
        //  lcodBatchName := CopyStr(ptrecEventParams.GetExtendedValue('Name'), 1, MaxStrLen(lcodBatchName));
        lcodUserName := RemoveUserDomain(CopyStr(ptrecEventParams.GetExtendedValue('user_name'), 1, 100));
        lcodTemplateName := cuJournalFunc.getItemJnlTemplate(PAGE::"Item Reclass. Journal", 1);
        lcodReclassBatch := cuJournalFunc.getItemJnlReclassBatchToUse(ptrecEventParams);
        lcodBatchName := lcodReclassBatch;
        ptrecEventParams.getLocation(lrecLocation);
        lrecItemJnlBatch.Get(GetJournalTemplateName(), lcodBatchName);
        if lrecItemJnlBatch."No. Series" <> '' then
            Error(tcWrongSeriesErr,
                  lcodBatchName,
                  lrecItemJnlBatch.FieldCaption("No. Series"),
                  lrecItemJnlBatch.FieldCaption("Posting No. Series"));
        lrecItemJnlBatch.SetRange("Journal Template Name", lrecItemJnlBatch."Journal Template Name");
        lrecItemJnlBatch.SetRange(Name, lcodBatchName);
        if lrecItemJnlBatch.FindSet() then;
        lrecItemJnlLine.Reset();
        lrecItemJnlLine.SetRange("Journal Template Name", lrecItemJnlBatch."Journal Template Name");
        lrecItemJnlLine.SetRange("Journal Batch Name", lcodBatchName);
        lrecItemJnlLine.SetRange("Location Code", lrecLocation.Code);
        if lrecItemJnlLine.FindSet() then;
        lrrefHeader.GetTable(lrecItemJnlBatch);
        //if lrecItemJnlLine."Journal Batch Name" <> '' then //bb
        lrrefLine.GetTable(lrecItemJnlLine);
        lbNeedsItemTrackingTable := ptrecEventParams.getNeedsItemTrackingTable();
        cuDatasetTools.BuildHeaderLineDataset(
          iEventID,
          lrrefHeader,
          lrrefLine,
          lbNeedsItemTrackingTable,
          ldnOutput);
        pbsOutput.AddText(ldnOutput.ToText());
        ptrecEventParams.setValue('Document Type', Format(DATABASE::"Item Journal Line"));
        ptrecEventParams.setValue('Document No.', lcodBatchName);
        ptrecEventParams.setValue('Name', lcodBatchName + 'BB');
        cuActivityLogMgt.logActivity(ptrecEventParams);
    end;

    local procedure getSpecificInvLine(var ptrecEventParams: Record "IWX Event Param" temporary; var precOutPhysJournalLine: Record "Item Journal Line") pbSuccess: Boolean
    var
        lcodJournalTemplateName: Code[10];
        lcodJournalBatchName: Code[10];
        cuJournalFunc: Codeunit "WHI Journal Functions";
        lcodUserName: Code[100];
        lcodReclassBatch: Code[10];
        lcodTemplateName: Code[10];
    begin
        lcodJournalTemplateName := GetJournalTemplateName();
        //lcodJournalBatchName := CopyStr(ptrecEventParams.GetExtendedValue('Name'), 1, MaxStrLen(lcodJournalBatchName));
        lcodUserName := RemoveUserDomain(CopyStr(ptrecEventParams.GetExtendedValue('user_name'), 1, 100));
        lcodTemplateName := cuJournalFunc.getItemJnlTemplate(PAGE::"Item Reclass. Journal", 1);
        lcodReclassBatch := cuJournalFunc.getItemJnlReclassBatchToUse(ptrecEventParams);
        lcodJournalBatchName := lcodReclassBatch;

        if (lcodJournalBatchName = '') then
            lcodJournalBatchName := cuJournalFuncs.getItemJnlPhysInvBatchToUse(ptrecEventParams);
        pbSuccess := precOutPhysJournalLine.Get(lcodJournalTemplateName, lcodJournalBatchName, ptrecEventParams.getValueAsInt('Line No.'));
    end;

    local procedure updateInvJournalLine(var ptrecEventParams: Record "IWX Event Param" temporary; var pbsOutput: BigText)
    var
        lrecItemJournalLine: Record "Item Journal Line";
        lrrefUpdatedLine: RecordRef;
        ldQuantity: Decimal;
        ldnOutput: TextBuilder;
        ldPreviousQuantity: Decimal;
    begin
        ldQuantity := ptrecEventParams.getValueAsDecimal('quantity');
        getSpecificInvLine(ptrecEventParams, lrecItemJournalLine);
        ldPreviousQuantity := lrecItemJournalLine."Qty. (Phys. Inventory)";
        lrecItemJournalLine.Validate("Qty. (Phys. Inventory)", ldQuantity);

        lrecItemJournalLine.Modify();
        lrecItemJournalLine.SetRecFilter();
        lrrefUpdatedLine.GetTable(lrecItemJournalLine);
        cuDatasetTools.BuildLineTableEmbedRes(97001, lrrefUpdatedLine, false, ldnOutput);
        pbsOutput.AddText(ldnOutput.ToText());

        ptrecEventParams.setValue('Document Type', Format(DATABASE::"Item Journal Line"));
        ptrecEventParams.setValue('Document No.', lrecItemJournalLine."Journal Batch Name");
        ptrecEventParams.setValue('Line No.', Format(lrecItemJournalLine."Line No."));
        ptrecEventParams.setValue('Previous Quantity', Format(ldPreviousQuantity));
        ptrecEventParams.setValue('New Quantity', Format(ldQuantity));
        cuActivityLogMgt.logActivity(ptrecEventParams);
    end;

    procedure BALAddItemTrackingInventory(var ptrecEventParams: record "IWX Event Param" temporary; var pbsoutput: BigText)
    var
        Location: record Location;
        Bin: Record Bin;
        ItemNo: code[20];
        Item: record Item;
        Item2: Record Item;
        TempReservationEntry: record "Reservation Entry";

        LotNo: Code[20];
        lcuWHICommond: Codeunit "WHI Common Functions";
        CreateReservEntry: Codeunit "Create Reserv. Entry";
        NoSeriesMgt: Codeunit "No. Series";
        //  BALInsightFunc: Codeunit "BAL InsightFunc";
        ItemJnLine: Record "Item Journal Line";
        Status: Enum "Reservation Status";
        WHIBasicCountMgmt: Codeunit 23044924;
        TemplateName: code[10];
        cuJournalFunc: Codeunit "WHI Journal Functions";
        lcodUserName: Code[100];
        lcodReclassBatch: Code[10];
        lcodTemplateName: Code[10];
    begin
        lcodUserName := RemoveUserDomain(CopyStr(ptrecEventParams.GetExtendedValue('user_name'), 1, 100));
        lcodTemplateName := cuJournalFunc.getItemJnlTemplate(PAGE::"Item Reclass. Journal", 1);
        lcodReclassBatch := cuJournalFunc.getItemJnlReclassBatchToUse(ptrecEventParams);
        ptrecEventParams.setValue('Name', lcodReclassBatch);
        WHIBasicCountMgmt.executeEvent(97003, ptrecEventParams, pbsoutput);
        location.get(ptrecEventParams.getValue('location'));
        itemno := ptrecEventParams.getValue('item_number');
        LotNo := ptrecEventParams.getValue('lot_number');
        ItemJnLine.setrange("Phys. Inventory", true);
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

    var
        cuCommonFuncs: Codeunit "WHI Common Functions";
        cuDatasetTools: Codeunit "WHI Dataset Tools";
        cuJournalFuncs: Codeunit "WHI Journal Functions";
        cuActivityLogMgt: Codeunit "WHI Activity Log Mgmt.";
        iEventID: Integer;
        tcWrongSeriesErr: Label 'Batch [%1] has a [%2] defined.\Please use a [%3] instead.', Comment = '%1 = Batch Name; %2 = No. Series; %3 = Posting No. Series';
        c23044920: Codeunit 23044920;
}

