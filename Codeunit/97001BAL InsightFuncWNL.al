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
        codRegionCode: code[10];
        cuRegistrationMgmt: Codeunit "WHI Registration Mgmt.";
        cuCommonFuncs: Codeunit "WHI Common Functions";
        cuActivityLogMgt: Codeunit "WHI Activity Log Mgmt.";
        cuDataset: Codeunit "WHI Dataset Tools";
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
                PostInventoryBatch(ptrecEventParams, pbsoutput);
            2000107:
                SetBinBlocking(ptrecEventParams, pbsoutput);
            2000108:
                GetItemJournalBacthName(ptrecEventParams, pbsoutput);
            2000209:
                GetNextWhseDocument(ptrecEventParams, pbsoutput);
            2000210:
                getDocumentListWBS(ptrecEventParams, pbsOutput);
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
        ItemJnLine.SetFilter("Item No.", '<>%1', '');
        IF ItemJnLine.FINDLAST THEN
            ItemJnlPostBatch.RUN(ItemJnLine);
        LcuWHICommond.generateSuccessReturn('Posted', PBSOutPut);
    end;

    local procedure SetBinBlocking(var ptrecEventParams: record "IWX Event Param" temporary; var pbsoutput: BigText)
    var
        lcuWHICommond: Codeunit "WHI Common Functions";
        Bin: record Bin;
    begin
        bin.setrange("Location Code", ptrecEventParams.getValue('location'));
        bin.setrange("Code", ptrecEventParams.getValue('bin_code'));
        if bin.get(ptrecEventParams.getValue('location'), ptrecEventParams.getValue('bin_code')) then begin
            if bin."Block Movement" = bin."Block Movement"::Outbound then
                bin.validate("Block Movement", bin."Block Movement"::" ")
            else
                bin.validate("Block Movement", bin."Block Movement"::Outbound);
            bin.modify;
        end;
    end;

    local procedure GetItemJournalBacthName(var ptrecEventParams: record "IWX Event Param" temporary; var pbsoutput: BigText)
    var
        ItemJnlBatch: record "Item Journal Batch";
        WhereUsed: Record "BAL Where Used";
        lcuWHICommond: Codeunit "WHI Common Functions";
    begin
        ItemJnlBatch.SetRange("Template Type", ItemJnlBatch."Template Type"::Item);
        WhereUsed.DeleteAll;
        if ItemJnlBatch.findset Then
            repeat
                WhereUsed.No := ItemJnlBatch.name;
                WhereUsed.Description := ItemJnlBatch.Description;
                if WhereUsed.Insert() then;
            until ItemJnlBatch.next = 0;
        lcuWHICommond.generateSuccessReturn('', pbsoutput);
    end;

    local procedure GetNextWhseDocument(var ptrecEventParams: record "IWX Event Param" temporary; var pbsoutput: BigText)
    var
        lcuWHICommond: Codeunit "WHI Common Functions";
        c23044920: Codeunit 23044920;
        lrecActHeader: Record "Warehouse Activity Header";
        lcodUserName: Code[50];
        
    begin
        lrecActHeader.SetRange("Location Code", 'GRAM-WBS');
        lrecActHeader.SetRange(Type, lrecActHeader.Type::"Invt. Pick");
        lrecActHeader.setfilter("Assigned User ID", '%1', '');
        if lrecActHeader.FindSet() then begin
            ptrecEventParams.setValue('doc_num', lrecActHeader."No.");
            ptrecEventParams.setValue('next_doc_num', lrecActHeader."No.");
            lcodUserName := CopyStr(ptrecEventParams.GetExtendedValue('user_name'), 1, MaxStrLen(lcodUserName));
            lrecActHeader."Assigned User ID" := lcodUserName;
            lrecActHeader.modify;
        end;
        //  if confirm(StrSubstNo('Doc %1 next %2 Table  %3 ', ptrecEventParams.GetExtendedValue('doc_num'), ptrecEventParams.GetExtendedValue('next_doc_num'), lrecActHeader)) then;
        lcuWHICommond.generateSuccessReturn('', pbsoutput);
    end;

    procedure getDocumentListWBS(var ptrecEventParams: Record "IWX Event Param" temporary; var pbsOutput: BigText)
    var
        lrecWHISetup: Record "WHI Setup";
        lrecConfig: Record "WHI Device Configuration";
        ltrecDocList: Record "WHI Document List Buffer" temporary;
        lcuDataSetTools: Codeunit "WHI Dataset Tools";
        lrrefDocListRef: RecordRef;
        ldnOutput: TextBuilder;
        lcodUserName: Code[50];
        liActivityType: Integer;
        lsFilter: Text;
        liMaxDocList: Integer;
        lcodOptionalItem: Code[20];
        lcodLot: Code[50];
        lcodSerial: Code[50];
        lbOnlyAssignedDocs: Boolean;
    begin
        liActivityType := ptrecEventParams.getValueAsInt('document_type');
        lcodUserName := CopyStr(ptrecEventParams.GetExtendedValue('user_name'), 1, MaxStrLen(lcodUserName));
        lsFilter := EscapeFilterString(ptrecEventParams.GetExtendedValue('filter'));
        lcodOptionalItem := CopyStr(ptrecEventParams.GetExtendedValue('item_number'), 1, MaxStrLen(lcodOptionalItem));
        lcodLot := CopyStr(ptrecEventParams.GetExtendedValue('lot_number'), 1, MaxStrLen(lcodLot));
        lcodSerial := CopyStr(ptrecEventParams.GetExtendedValue('serial_number'), 1, MaxStrLen(lcodSerial));

        if lcodOptionalItem <> '' then
            lsFilter := '';
        //lsFilter := '';//bb

        cuCommonFuncs.getDeviceConfig(lrecConfig, ptrecEventParams);
        lbOnlyAssignedDocs := (lcodUserName <> '') and (lrecConfig."Show All Documents" = lrecConfig."Show All Documents"::No);

        lrecWHISetup.Get();
        liMaxDocList := lrecWHISetup."Document Max List";
        if liMaxDocList = 0 then
            liMaxDocList := 999999;

        searchActivityDocuments(ltrecDocList, lrecConfig, ptrecEventParams, lbOnlyAssignedDocs, lcodUserName,
          lsFilter, liMaxDocList, lcodOptionalItem, liActivityType, lcodLot, lcodSerial);

        ltrecDocList.Reset();
        //if ((ltrecDocList.Count() = 0) and (liActivityType = 1) and (lcodOptionalItem <> '')) then
        //bb  searchPostedReceipts(ltrecDocList, lrecConfig, liMaxDocList, lcodOptionalItem, lcodLot, lcodSerial);


        ltrecDocList.Reset();
        lrrefDocListRef.GetTable(ltrecDocList);
        if (lrrefDocListRef.FindFirst()) then;

        lcuDataSetTools.BuildLinesOnlyDataset(
          20008,   //Hardcodet by BB to find the fields setup
          lrrefDocListRef,
          false,
          ldnOutput);

        pbsOutput.AddText(ldnOutput.ToText());

        cuActivityLogMgt.logActivity(ptrecEventParams);
    end;

    procedure searchActivityDocuments(var ptrecDocList: Record "WHI Document List Buffer"; var precConfig: Record "WHI Device Configuration"; var ptrecEventParams: Record "IWX Event Param" temporary; pbOnlyAssignedDocs: Boolean; pcodUser: Code[50]; ptxtFilter: Text; piMaxDocCount: Integer; pcodItemNumber: Code[20]; piActivityType: Integer; pcodLotNumber: Code[50]; pcodSerialNumber: Code[50])
    var
        lrecWhseActHeader: Record "Warehouse Activity Header";
        lrecWhseActLine: Record "Warehouse Activity Line";
        lrecLocation: Record Location;
        lrecWhseHeaderTemp: Record "Warehouse Activity Header";
        lrecWhseLineTemp: Record "Warehouse Activity Line";
        lrecSalesHeader: Record "Sales Header";
        lrecPurchHeader: Record "Purchase Header";
        lrecLPUsage: Record "IWX LP Line Usage";
        lbIncludeResult: Boolean;
        liLineCounter: Integer;
        lsName: Text[100];
        lsBarcode: Text[100];
        liType: Integer;
        lbActivitySupported: Boolean;
        lbInvtActivitySupported: Boolean;
    begin
        pcodLotNumber := UpperCase(pcodLotNumber);
        pcodSerialNumber := UpperCase(pcodSerialNumber);

        //lrecLocation.Get(precConfig."Location Code");

        //lrecWhseActHeader.SetRange("Location Code", precConfig."Location Code");
        lrecLocation.Get('GRAM-WBS');

        lrecWhseActHeader.SetRange("Location Code", 'GRAM-WBS');

        if (piActivityType = 0) then begin
            lbActivitySupported := cuRegistrationMgmt.CheckPickSupported(false);
            lbInvtActivitySupported := cuRegistrationMgmt.CheckInvtPickSupported(false);

            if lbActivitySupported and lbInvtActivitySupported then
                lrecWhseActHeader.SetFilter(Type, '%1|%2', lrecWhseActHeader.Type::"Pick", lrecWhseActHeader.Type::"Invt. Pick")
            else
                if lbActivitySupported then
                    lrecWhseActHeader.SetRange(Type, lrecWhseActHeader.Type::"Pick")
                else
                    if lbInvtActivitySupported then
                        lrecWhseActHeader.SetRange(Type, lrecWhseActHeader.Type::"Invt. Pick")
                    else
                        exit;
        end else
            if (piActivityType = 1) then begin
                lbActivitySupported := cuRegistrationMgmt.CheckPutawaySupported(false);
                lbInvtActivitySupported := cuRegistrationMgmt.CheckInvtPutawaySupported(false);

                if lbActivitySupported and lbInvtActivitySupported then
                    lrecWhseActHeader.SetFilter(Type, '%1|%2', lrecWhseActHeader.Type::"Put-away", lrecWhseActHeader.Type::"Invt. Put-away")
                else
                    if lbActivitySupported then
                        lrecWhseActHeader.SetRange(Type, lrecWhseActHeader.Type::"Put-away")
                    else
                        if lbInvtActivitySupported then
                            lrecWhseActHeader.SetRange(Type, lrecWhseActHeader.Type::"Invt. Put-away")
                        else
                            exit;
            end
            else begin
                lbActivitySupported := cuRegistrationMgmt.CheckMovementSupported(false);
                lbInvtActivitySupported := cuRegistrationMgmt.CheckInvtMovementSupported(false);

                if lbActivitySupported and lbInvtActivitySupported then
                    lrecWhseActHeader.SetFilter(Type, '%1|%2', lrecWhseActHeader.Type::"Movement", lrecWhseActHeader.Type::"Invt. Movement")
                else
                    if lbActivitySupported then
                        lrecWhseActHeader.SetRange(Type, lrecWhseActHeader.Type::"Movement")
                    else
                        if lbInvtActivitySupported then
                            lrecWhseActHeader.SetRange(Type, lrecWhseActHeader.Type::"Invt. Movement")
                        else
                            exit;
            end;

        if (pbOnlyAssignedDocs) then
            lrecWhseActHeader.SetFilter("Assigned User ID", '%1|%2', '', '*' + pcodUser);

        //if cuRegistrationMgmt.IsWHIInstalled() then
        //  OnAfterFilterLookupWhseActivityHeaders(lrecWhseActHeader, pbOnlyAssignedDocs, pcodUser, ptxtFilter);

        if (lrecWhseActHeader.FindSet(false)) then
            repeat
                lbIncludeResult := (ptxtFilter = '');

                lrecWhseActLine.Reset();
                lrecWhseActLine.SetRange("Activity Type", lrecWhseActHeader.Type);
                lrecWhseActLine.SetRange("No.", lrecWhseActHeader."No.");
                lrecWhseActLine.SetFilter("Qty. Outstanding", '>%1', 0);

                if (pcodItemNumber <> '') then
                    lrecWhseActLine.SetRange("Item No.", pcodItemNumber);
                if (pcodLotNumber <> '') then
                    lrecWhseActLine.SetRange("Lot No.", pcodLotNumber);
                if (pcodSerialNumber <> '') then
                    lrecWhseActLine.SetRange("Serial No.", pcodSerialNumber);

                lrecWhseHeaderTemp.Reset();
                lrecWhseHeaderTemp.SetRange(Type, lrecWhseActHeader.Type);

                //    if cuRegistrationMgmt.IsWHIInstalled() then
                //      OnAfterFilterLookupWhseActivityLines(lrecWhseActLine, ptxtFilter, pcodItemNumber, pcodSerialNumber, pcodLotNumber);

                if (lrecWhseActLine.FindSet(false)) then
                    repeat
                        if (ptxtFilter <> '') then begin
                            lrecWhseHeaderTemp.SetFilter("No.", ptxtFilter);
                            if lrecWhseHeaderTemp.FindSet(false) then
                                repeat
                                    lbIncludeResult := lrecWhseHeaderTemp."No." = lrecWhseActHeader."No.";
                                until ((lrecWhseHeaderTemp.Next() = 0) or lbIncludeResult);

                            if (not lbIncludeResult) then begin
                                lrecWhseHeaderTemp.SetRange("No.", lrecWhseActHeader."No.");
                                lrecWhseHeaderTemp.SetFilter("External Document No.", ptxtFilter);
                                lbIncludeResult := lrecWhseHeaderTemp.Count() > 0;
                            end;

                            if (not lbIncludeResult) then begin
                                lrecWhseLineTemp.Reset();
                                lrecWhseLineTemp.SetRange("Activity Type", lrecWhseActHeader.Type);
                                lrecWhseLineTemp.SetRange("No.", lrecWhseActHeader."No.");
                                lrecWhseLineTemp.SetFilter("Source No.", ptxtFilter);
                                lbIncludeResult := lrecWhseLineTemp.Count() > 0;
                            end;

                            if (not lbIncludeResult) then begin
                                lrecWhseLineTemp.Reset();
                                lrecWhseLineTemp.SetRange("Activity Type", lrecWhseActHeader.Type);
                                lrecWhseLineTemp.SetRange("No.", lrecWhseActHeader."No.");
                                lrecWhseLineTemp.SetFilter("Whse. Document No.", ptxtFilter);
                                lbIncludeResult := lrecWhseLineTemp.Count() > 0;
                            end;

                            if (not lbIncludeResult) then begin
                                lrecLPUsage.SetRange("License Plate No.", ptxtFilter);

                                if (piActivityType = 0) then
                                    lrecLPUsage.SetFilter("Source Document", '%1|%2', lrecLPUsage."Source Document"::Pick, lrecLPUsage."Source Document"::"Invt. Pick")
                                else
                                    if (piActivityType = 1) then
                                        lrecLPUsage.SetFilter("Source Document", '%1|%2', lrecLPUsage."Source Document"::"Put-away", lrecLPUsage."Source Document"::"Invt. Put-away");

                                lrecLPUsage.SetRange("Source No.", lrecWhseActLine."No.");
                                lbIncludeResult := lrecLPUsage.Count() > 0;
                            end;
                        end;

                        //        if cuRegistrationMgmt.IsWHIInstalled() then
                        //          OnBeforeAddWhseActivityToLookupList(lrecWhseActHeader, lrecWhseActLine, lbIncludeResult);

                        if (lbIncludeResult) then begin
                            lsName := '';
                            if (lrecWhseActLine."Source Document" = lrecWhseActLine."Source Document"::"Sales Order") then begin
                                if (lrecSalesHeader.Get(lrecWhseActLine."Source Subtype", lrecWhseActLine."Source No.")) then
                                    lsName := lrecSalesHeader."Sell-to Customer Name";
                            end else
                                if (lrecWhseActLine."Source Document" = lrecWhseActLine."Source Document"::"Purchase Order") then
                                    if (lrecPurchHeader.Get(lrecWhseActLine."Source Subtype", lrecWhseActLine."Source No.")) then
                                        lsName := lrecPurchHeader."Buy-from Vendor Name";

#if V19_OR_HIGHER
                            liType := lrecWhseActHeader.Type.AsInteger();
#else
                            liType := lrecWhseActHeader.Type.AsInteger();
#endif

#pragma warning disable AA0217
                            lsBarcode := '%A%' + StrSubstNo('%1 %2', lrecWhseActHeader."No.", liType);
#pragma warning restore AA0217

                            addWhseActDocToList(
                              ptrecDocList,
                              liLineCounter,
                              (precConfig."Use Source Doc. - Warehouse" = precConfig."Use Source Doc. - Warehouse"::Yes),
                              lrecWhseActLine."No.",
                              lrecWhseActLine."Source No.",
                              DATABASE::"Warehouse Activity Header",
                              lrecWhseActHeader."External Document No.",
                              lrecWhseActHeader."Assigned User ID",
                              lrecWhseActLine."Due Date",
                              lrecWhseActLine."Whse. Document No.",
                              lsName,
                              lsBarcode
                            );
                        end;
                    until ((lrecWhseActLine.Next() = 0) or (liLineCounter >= piMaxDocCount));
            until ((lrecWhseActHeader.Next() = 0) or (liLineCounter >= piMaxDocCount))
    end;

    procedure addWhseActDocToList(var ptrecDocList: Record "WHI Document List Buffer"; var piLineCounter: Integer; pbUseSourceDocument: Boolean; pcodDocumentNo: Code[20]; pcodSourceNo: Code[20]; piSourceTable: Integer; pcodRefNumber: Code[50]; pcodAssignedUser: Code[50]; pdtDueDate: Date; pcodWhseDocNumber: Code[20]; psCustomText1: Text[100]; psBarcode: Text[100])
    var
        lbHandled: Boolean;
    begin
        ptrecDocList.Reset();
        ptrecDocList.SetRange("Document No.", pcodDocumentNo);
        if (pbUseSourceDocument) then
            ptrecDocList.SetRange("Source Document No.", pcodSourceNo);

        if (not ptrecDocList.FindFirst()) then begin
            ptrecDocList.Init();
            piLineCounter += 1;
            ptrecDocList."Entry No." := piLineCounter;
            ptrecDocList."Source Table" := piSourceTable;
            ptrecDocList."Reference No." := pcodRefNumber;
            ptrecDocList."Document No." := pcodDocumentNo;
            if (pbUseSourceDocument) then
                ptrecDocList."No." := pcodSourceNo
            else
                ptrecDocList."No." := pcodDocumentNo;

            ptrecDocList."Assigned User ID" := pcodAssignedUser;
            ptrecDocList."Due Date" := pdtDueDate;
            ptrecDocList."Warehouse Document No." := pcodWhseDocNumber;
            ptrecDocList."Source Document No." := pcodSourceNo;
            ptrecDocList."Custom Text 1" := psCustomText1;

            ptrecDocList.Barcode := psBarcode;

            //   if cuRegistrationMgmt.IsWHIInstalled() then begin
            //     OnBeforeAddDocToLookupList(ptrecDocList, lbHandled);
            //   if lbHandled then
            //     exit;
            // end;

            ptrecDocList.Insert();
        end;
    end;

    procedure EscapeFilterString(psFilter: Text): Text
    var
        lsEscapedFilter: Text;
    begin
        if psFilter = '' then
            exit('');

        lsEscapedFilter := '*' + psFilter + '*';

        if lsEscapedFilter.Contains('&') or lsEscapedFilter.Contains('(') or lsEscapedFilter.Contains(')') or
            lsEscapedFilter.Contains('|') or lsEscapedFilter.Contains('=') then
            lsEscapedFilter := '''' + lsEscapedFilter + '''';

        exit(lsEscapedFilter);
    end;
}
