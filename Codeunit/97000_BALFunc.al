codeunit 97000 "BAL Func"
{
    trigger OnRun()
    var
        cu: Codeunit 7322;
        FromBinContent: Record "Bin Content";

    begin
        //cu.OnFindBWPickBinOnBeforeFromBinContentFindSet(FromBinContent, SourceType, TotalQtyPickedBase, TotalQtyToPickBase, IsHandled);)
    end;

    [EventSubscriber(ObjectType::Table, database::"Transfer Header", 'OnAfterGetTransferRoute', '', true, true)]
    local procedure TableTransferHeaderOnAfterGetTransferRoute(var TransferHeader: Record "Transfer Header"; TransferRoute: Record "Transfer Route")
    begin
        if TransferRoute."BAL Partner VAT ID" <> '' then
            TransferHeader."Partner VAT ID" := TransferRoute."BAL Partner VAT ID";
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


    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnValidateNoOnBeforeCheckPostingSetups', '', true, true)]
    local procedure BlankLocationCodeIfNonInventory(var SalesLine: Record "Sales Line"; var IsHandled: Boolean)
    var
        Item: Record Item;
    begin
        if (SalesLine.Type <> salesline.Type::Item) or (SalesLine."No." = '') then
            exit;
        if Item.get(SalesLine."No.") and (Item.Type = item.type::"Non-Inventory") then
            SalesLine.validate("Location Code", '');
    end;

    procedure MoveLocation(var SalesHeader: record "Sales Header")
    var
        CountryRegion: Record "Country/Region";
        location: Record Location;
        SalesLine: Record "Sales Line";
        i: integer;
        MessageTxt: label '%1 %2 is change from %3 %4\to %5 ';
        FailTxt: Label 'There is no %1 with %2 %3 assignment';

        SalesHeader2: Record "Sales Header";
    begin
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type");
        SalesHeader.setrange(Status, SalesHeader.Status::Open);
        CountryRegion.setfilter(moveFromLocation, '<>%1', '');
        CountryRegion.setfilter(moveToLocation, '<>%1', '');
        if CountryRegion.findset then
            repeat
                SalesHeader.setfilter("Ship-to Country/Region Code", CountryRegion.code);
                SalesHeader.setfilter("Location Code", '%1', CountryRegion.MoveFromLocation);
                if SalesHeader.findset then begin
                    salesheader.SetHideValidationDialog(true);
                    repeat
                        SalesHeader2 := SalesHeader;
                        SalesHeader.Status := SalesHeader.Status::Open;
                        SalesHeader.validate("Location Code", CountryRegion.MoveToLocation);
                        if CountryRegion."Shipping Agent Code" <> '' then
                            SalesHeader.validate("Shipping Agent Code", CountryRegion."Shipping Agent Code");
                        SalesLine.setrange("Document Type", SalesHeader."Document Type");
                        SalesLine.setrange("Document No.", SalesHeader."No.");
                        SalesLine.SetRange(type, SalesLine.type::Item);
                        SalesLine.setfilter("No.", '<>%1', '');
                        if SalesLine.FindSet() then
                            repeat
                                SalesLine.SetHideValidationDialog(true);
                                SalesLine.SetSalesHeader(SalesHeader);
                                SalesLine.Validate("Location Code", SalesHeader."Location Code");
                                SalesLine.modify;
                            until salesline.next = 0;
                        i += 1;
                        SalesHeader.Status := SalesHeader2.Status;
                        salesheader.modify;
                    until salesheader.next = 0;
                    Message(MessageTxt, i, SalesHeader.TableCaption, SalesHeader.FieldCaption("Location Code"), CountryRegion.MoveFromLocation, CountryRegion.MovetoLocation);
                end;
            until CountryRegion.next = 0
        else
            message(FailTxt, CountryRegion.TableCaption, CountryRegion.fieldcaption(MoveFromLocation), CountryRegion.fieldcaption(MovetoLocation));
    end;

    procedure SetExcludeFromMovement(var SalesHeader: record "Sales Header"; SetTrue: boolean)
    var
        SalesLine: Record "Sales Line";
        i: integer;
        MessageTxt: label '%1 %2 is changed';

        SalesHeader2: Record "Sales Header";
    begin
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        if SalesHeader.findset then begin
            salesheader.SetHideValidationDialog(true);
            repeat
                SalesHeader2 := SalesHeader;
                SalesHeader.Status := SalesHeader.Status::Open;
                SalesHeader."BAL Exclude Movement" := SetTrue;

                SalesLine.setrange("Document Type", SalesHeader."Document Type");
                SalesLine.setrange("Document No.", SalesHeader."No.");
                SalesLine.SetRange(type, SalesLine.type::Item);
                SalesLine.setfilter("No.", '<>%1', '');
                if SalesLine.FindSet() then
                    repeat
                        SalesLine.SetHideValidationDialog(true);
                        SalesLine.SetSalesHeader(SalesHeader);
                        SalesLine.Validate("BAL Exclude Movement", SetTrue);
                        SalesLine.modify;
                    until salesline.next = 0;
                i += 1;
                SalesHeader.Status := SalesHeader2.Status;
                salesheader.modify;
            until salesheader.next = 0;
            Message(MessageTxt, i, SalesHeader.TableCaption);
        end;
    end;

    [EventSubscriber(ObjectType::Report, Report::"Intrastat Report Get Lines", 'OnBeforeInsertItemLedgerLine', '', true, true)]
    local procedure FindCodeRefandVatProdGrp(var IntrastatReportLine: Record "Intrastat Report Line"; ItemLedgerEntry: Record "Item Ledger Entry"; var IsHandled: Boolean)
    var
        SalesShipmentHeader: Record "Sales Shipment Header";
        SalesShipmentLine: Record "Sales Shipment Line";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesInvoiceLine: Record "Sales Invoice Line";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        ReturnReceiptHeader: Record "Return Receipt Header";
        ReturnReceiptLine: Record "Return Receipt Line";
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchInvLine: Record "Purch. Inv. Line";
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        PurchCrMemoLine: Record "Purch. Cr. Memo Line";
        PurchRcptHeader: Record "Purch. Rcpt. Header";
        PurchRcptLine: Record "Purch. Rcpt. Line";
        ReturnShipmentHeader: Record "Return Shipment Header";
        ReturnShipmentLine: Record "Return Shipment Line";
        TransferReceiptHeader: Record "Transfer Receipt Header";
        TransferShipmentHeader: Record "Transfer Shipment Header";
    begin
        case ItemLedgerEntry."Document Type" of

            "Item Ledger Document Type"::"Purchase Receipt":
                begin
                    if PurchRcptHeader.get(ItemLedgerEntry."Document No.") then begin
                        IntrastatReportLine."BAL Reference code" := PurchRcptHeader."Buy-from Vendor No.";
                        IntrastatReportLine."BAL Refence name" := PurchRcptHeader."Buy-from Vendor Name";
                        PurchRcptLine.setrange("Document No.", PurchRcptHeader."No.");
                        PurchRcptLine.setrange(Type, PurchRcptLine.type::Item);
                        PurchRcptLine.SetRange("No.", ItemLedgerEntry."Item No.");
                        if PurchRcptLine.findset then
                            IntrastatReportLine."BAL Vat Product Posting Group" := PurchRcptLine."VAT Prod. Posting Group";
                    end;
                end;
            "Item Ledger Document Type"::"Purchase Invoice":
                begin
                    if PurchInvHeader.get(ItemLedgerEntry."Document No.") then begin
                        IntrastatReportLine."BAL Reference code" := PurchInvHeader."Buy-from Vendor No.";
                        IntrastatReportLine."BAL Refence name" := PurchInvHeader."Buy-from Vendor Name";
                        PurchInvLine.setrange("Document No.", PurchInvHeader."No.");
                        PurchInvLine.setrange(Type, PurchInvLine.type::Item);
                        PurchInvLine.SetRange("No.", ItemLedgerEntry."Item No.");
                        if PurchInvLine.findset then
                            IntrastatReportLine."BAL Vat Product Posting Group" := PurchInvLine."VAT Prod. Posting Group";
                    end;
                end;
            "Item Ledger Document Type"::"Purchase Return Shipment":
                begin
                    if ReturnShipmentHeader.get(ItemLedgerEntry."Document No.") then begin
                        IntrastatReportLine."BAL Reference code" := ReturnShipmentHeader."Buy-from Vendor No.";
                        IntrastatReportLine."BAL Refence name" := ReturnShipmentHeader."Buy-from Vendor Name";
                        ReturnShipmentLine.setrange("Document No.", ReturnShipmentHeader."No.");
                        ReturnShipmentLine.setrange(Type, ReturnShipmentLine.type::Item);
                        ReturnShipmentLine.SetRange("No.", ItemLedgerEntry."Item No.");
                        if ReturnShipmentLine.findset then
                            IntrastatReportLine."BAL Vat Product Posting Group" := ReturnShipmentLine."VAT Prod. Posting Group";
                    end;
                end;

            "Item Ledger Document Type"::"Purchase Credit Memo":
                begin
                    if PurchCrMemoHdr.get(ItemLedgerEntry."Document No.") then begin
                        IntrastatReportLine."BAL Reference code" := PurchCrMemoHdr."Buy-from Vendor No.";
                        IntrastatReportLine."BAL Refence name" := PurchCrMemoHdr."Buy-from Vendor Name";
                        PurchCrMemoLine.setrange("Document No.", PurchCrMemoHdr."No.");
                        PurchCrMemoLine.setrange(Type, PurchCrMemoLine.type::Item);
                        PurchCrMemoLine.SetRange("No.", ItemLedgerEntry."Item No.");
                        if PurchCrMemoLine.findset then
                            IntrastatReportLine."BAL Vat Product Posting Group" := PurchCrMemoLine."VAT Prod. Posting Group";
                    end;
                end;
            "Item Ledger Document Type"::"Sales Shipment":
                if SalesShipmentHeader.get(ItemLedgerEntry."Document No.") then begin
                    IntrastatReportLine."BAL Reference code" := SalesShipmentHeader."Sell-to Customer No.";
                    IntrastatReportLine."BAL Refence name" := SalesShipmentHeader."Sell-to Customer Name";
                    SalesShipmentLine.setrange("Document No.", SalesShipmentHeader."No.");
                    SalesShipmentLine.setrange(Type, SalesShipmentLine.type::Item);
                    SalesShipmentLine.SetRange("No.", ItemLedgerEntry."Item No.");
                    if SalesShipmentLine.findset then
                        IntrastatReportLine."BAL Vat Product Posting Group" := SalesShipmentLine."VAT Prod. Posting Group";
                end;
            "Item Ledger Document Type"::"Sales Invoice":
                if SalesInvoiceHeader.get(ItemLedgerEntry."Document No.") then begin
                    IntrastatReportLine."BAL Reference code" := SalesInvoiceHeader."Sell-to Customer No.";
                    IntrastatReportLine."BAL Refence name" := SalesInvoiceHeader."Sell-to Customer Name";
                    SalesInvoiceLine.setrange("Document No.", SalesInvoiceHeader."No.");
                    SalesInvoiceLine.setrange(Type, SalesInvoiceLine.type::Item);
                    SalesInvoiceLine.SetRange("No.", ItemLedgerEntry."Item No.");
                    if SalesInvoiceLine.findset then
                        IntrastatReportLine."BAL Vat Product Posting Group" := SalesInvoiceLine."VAT Prod. Posting Group";
                end;
            "Item Ledger Document Type"::"Sales Credit Memo":
                if SalesCrMemoHeader.get(ItemLedgerEntry."Document No.") then begin
                    IntrastatReportLine."BAL Reference code" := SalesCrMemoHeader."Sell-to Customer No.";
                    IntrastatReportLine."BAL Refence name" := SalesCrMemoHeader."Sell-to Customer Name";
                    SalesCrMemoLine.setrange("Document No.", SalesCrMemoHeader."No.");
                    SalesCrMemoLine.setrange(Type, SalesCrMemoLine.type::Item);
                    SalesCrMemoLine.SetRange("No.", ItemLedgerEntry."Item No.");
                    if SalesCrMemoLine.findset then
                        IntrastatReportLine."BAL Vat Product Posting Group" := SalesCrMemoLine."VAT Prod. Posting Group";
                end;
            "Item Ledger Document Type"::"Sales Return Receipt":
                if ReturnReceiptHeader.get(ItemLedgerEntry."Document No.") then begin
                    IntrastatReportLine."BAL Reference code" := ReturnReceiptHeader."Sell-to Customer No.";
                    IntrastatReportLine."BAL Refence name" := ReturnReceiptHeader."Sell-to Customer Name";
                    ReturnReceiptLine.setrange("Document No.", ReturnReceiptHeader."No.");
                    ReturnReceiptLine.setrange(Type, ReturnReceiptLine.type::Item);
                    ReturnReceiptLine.SetRange("No.", ItemLedgerEntry."Item No.");
                    if ReturnReceiptLine.findset then
                        IntrastatReportLine."BAL Vat Product Posting Group" := ReturnReceiptLine."VAT Prod. Posting Group";
                end;

            "Item Ledger Document Type"::"Transfer Receipt":
                //IntrastatReportLine."BAL Reference code" := ItemLedgerEntry."Location Code";
                begin
                    if TransferReceiptHeader.get(ItemLedgerEntry."Document No.") then begin
                        IntrastatReportLine."BAL Reference code" := TransferReceiptHeader."Transfer-from Code";
                        IntrastatReportLine."BAL Reference code 2" := TransferReceiptHeader."Transfer-to Code";
                    end;
                end;
            "Item Ledger Document Type"::"Transfer Shipment":
                //IntrastatReportLine."BAL Reference code" := ItemLedgerEntry."Location Code";
                begin
                    if TransferShipmentHeader.get(ItemLedgerEntry."Document No.") then begin
                        IntrastatReportLine."BAL Reference code" := TransferShipmentHeader."Transfer-to Code";
                        IntrastatReportLine."BAL Reference code 2" := TransferShipmentHeader."Transfer-From Code";
                    end;
                end;

            "Item Ledger Document Type"::"Direct Transfer":
                IntrastatReportLine."BAL Reference code" := ItemLedgerEntry."Location Code";
        end; //case

    end;

    [EventSubscriber(ObjectType::Page, Page::"Transfer Order", 'OnBeforeActionEvent', 'Post', false, false)]
    local procedure TestTransactionType(var Rec: Record "Transfer Header")
    var
        BALWaterNlifeSetup: Record "BAL WaterNlife Setup";
    begin
        BALWaterNlifeSetup.get;
        if BALWaterNlifeSetup."Test for Transaction Type" then
            rec.testfield("Transaction Type")
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Templ. Mgt.", 'OnAfterCreateItemFromTemplate', '', true, true)]
    local procedure CodeunitItemTemplMgtOnAfterCreateItemFromTemplate(var Item: Record Item; ItemTempl: Record "Item Templ.")
    var
        StockkeepingUnit: Record "Stockkeeping Unit";
    begin
        if ItemTempl."BAL SKU Location Code" <> '' then begin
            ItemTempl.TestField("BAL Sku Item No.");
            StockkeepingUnit.SetRange("Location Code", ItemTempl."BAL SKU Location Code");
            StockkeepingUnit.SetRange("Item No.", ItemTempl."BAL Sku Item No.");
            if ItemTempl."BAL Sku Variant" <> '' then
                StockkeepingUnit.SetRange("Variant Code", ItemTempl."BAL Sku Variant");
            if StockkeepingUnit.findset then begin
                StockkeepingUnit."Item No." := Item."No.";
                StockkeepingUnit.Description := Item.Description;
                StockkeepingUnit."Description 2" := Item."Description 2";
                if StockkeepingUnit.insert then;
            end
        end;

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Templ. Mgt.", 'OnApplyItemTemplateOnBeforeItemGet', '', true, true)]
    local procedure CodeunitItemTemplMgtOnApplyItemTemplateOnBeforeItemGet(var Item: Record Item; ItemTempl: Record "Item Templ.")
    var
        StockkeepingUnit: Record "Stockkeeping Unit";
    begin
        if ItemTempl."BAL SKU Location Code" <> '' then begin
            ItemTempl.TestField("BAL Sku Item No.");
            StockkeepingUnit.SetRange("Location Code", ItemTempl."BAL SKU Location Code");
            StockkeepingUnit.SetRange("Item No.", ItemTempl."BAL Sku Item No.");
            if ItemTempl."BAL Sku Variant" <> '' then
                StockkeepingUnit.SetRange("Variant Code", ItemTempl."BAL Sku Variant");
            if StockkeepingUnit.findset then begin
                StockkeepingUnit."Item No." := Item."No.";
                StockkeepingUnit.Description := Item.Description;
                StockkeepingUnit."Description 2" := Item."Description 2";
                if StockkeepingUnit.insert then;
            end
        end;

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"whse. jnl.-register line", 'OnBeforeCheckDefaultBin', '', true, true)]
    local procedure CodeunitwhsejnlregisterlineOnBeforeCheckDefaultBin(var BinContent: Record "Bin Content"; var IsHandled: Boolean; WhseEntry: Record "Warehouse Entry")
    var
        whes: codeunit "whse. jnl.-register line";
    begin
        if WhseEntry."Location Code" = 'GRAMRODE13' then
            IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"WHI Whse. Activity Mgmt.", 'OnAfterFilterWhseActivityLines', '', true, true)]
    local procedure CodeunitWHIWhseActivityMgmtOnAfterFilterWhseActivityLines(var precWhseActivityLine: Record "Warehouse Activity Line"; var ptrecEventParams: Record "IWX Event Param" temporary)
    var
        Set01: Text;
        Set02: Text;
        Set03: Text;
        Set04: Text;
        Set05: Text;
        Set06: Text;
    begin
        Set01 := ptrecEventParams.getValue('SetFilter01');
        Set02 := ptrecEventParams.getValue('SetFilter02');
        Set03 := ptrecEventParams.getValue('SetFilter03');
        Set04 := ptrecEventParams.getValue('SetFilter04');
        Set05 := ptrecEventParams.getValue('SetFilter05');
        Set06 := ptrecEventParams.getValue('SetFilter06');
        if Set01 = 'True' then
            precWhseActivityLine.SetFilter("Bin Code", '%1', '01-*');
        if Set02 = 'True' then
            precWhseActivityLine.SetFilter("Bin Code", '%1', '02-*');
        if Set03 = 'True' then
            precWhseActivityLine.SetFilter("Bin Code", '%1', '03-*');
        if Set04 = 'True' then
            precWhseActivityLine.SetFilter("Bin Code", '%1', '04-*');
        if Set05 = 'True' then
            precWhseActivityLine.SetFilter("Bin Code", '%1', '05-*');
        if Set06 = 'True' then
            precWhseActivityLine.SetFilter("Bin Code", '%1', '06-*');
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnCreateInvtPutAwayPickOnBeforeTestingStatus', '', true, true)]
    local procedure DatabaseSalesHeaderOnCreateInvtPutAwayPickOnBeforeTestingStatus(var SalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
    begin
        salesheader.TestField("Sell-to Phone No.");
        SalesHeader.TestField("Shortcut Dimension 1 Code");
        SalesHeader.TestField("Shipping Agent Code");
        case SalesHeader."Shipping Agent Code" of
            'DDP', 'DAO':
                SalesHeader.TestField("Shipping Agent Service Code");
        end;
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        if SalesLine.FindSet() then
            repeat
                salesline.TestField("Net Weight");
            until SalesLine.Next() = 0;
    end;
}
