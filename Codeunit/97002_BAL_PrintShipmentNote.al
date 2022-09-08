Codeunit 97002 "WMDM Extension Post and Print"
{
    TableNo = "IWX Event Param";
    trigger OnRun()
    BEGIN
        iEventID := Rec.getEvent();
        CASE iEventID OF
            2000101, 2000104:
                begin
                    Rec.setEvent(-70104);
                    COMMIT();
                    if STARTSESSION(iPrintingSession, CODEUNIT::"WMDM Extension Post and Print", COMPANYNAME, Rec) then;

                end;
            2000109:
                BEGIN
                    //Rec.setEvent(70109);
                    WHIWhseActivityMgt.registerActivityDocument(rec, btOutput);
                    Rec.setEvent(-70109);
                    COMMIT();

                    if STARTSESSION(iPrintingSession, CODEUNIT::"WMDM Extension Post and Print", COMPANYNAME, Rec) then;
                END;

            -70109:
                printConfiguredShipments(Rec);
            -70104:
                printConfiguredlabel(Rec);
        END;

    END;

    VAR
        cuWMDMCommon: Codeunit "WHI Common Functions";
        cuWMDMBroker: Codeunit "WHI Data Broker";
        cuWMDMPrint: Codeunit "WHI Printing Mgmt.";
        cuWMDMShip: Codeunit "WHI Shipping Mgmt.";
        iEventID: Integer;
        iEventType: Integer;
        iPrintingSession: Integer;
        osOutput: OutStream;
        btOutput: BigText;
        tcPostAndPrint: label 'Post occurred, and Printing has been queued';
        "WHIWhseActivityMgt": Codeunit "WHI Whse. Activity Mgmt.";


    PROCEDURE printConfiguredShipments(VAR precEventParams: Record "IWX Event Param");
    VAR
        lrecPDAConfig: Record "WHI Device Configuration";
        lrecRepSel: Record "Report Selections";
        lcodWhseShipDoc: Code[50];
        lrecPostedWhseShipLines: Record "Posted Whse. Shipment Line";
        lrecShipHeader: Record "Sales Shipment Header";
        lrrefShipHeader: RecordRef;
        PostedInvtPickHeader: record "Posted Invt. Pick Header";
        Setup: Record "BAL WaterNlife Setup";
        Customer: Record Customer;
    BEGIN
        cuWMDMCommon.getDeviceConfig(lrecPDAConfig, precEventParams);
        lcodWhseShipDoc := precEventParams.getDocumentNo();
        PostedInvtPickHeader.setrange("Invt Pick No.", lcodWhseShipDoc);
        PostedInvtPickHeader.FindFirst();
        lrecShipHeader.FINDLAST();
        Setup.Get();
        Setup.TestField("Shipment Method Code");
        Setup.TestField("Customer Posting Group");
        if lrecShipHeader."Shipment Method Code" <> Setup."Shipment Method Code" then
            if Setup."Customer Posting Group" <> '' then begin
                customer.setrange("No.", lrecShipHeader."Sell-to Customer No.");
                Customer.setfilter("Customer Posting Group", Setup."Customer Posting Group");
                if not Customer.findset then
                    exit;
            end;
        lrrefShipHeader.GETTABLE(lrecShipHeader);
        lrrefShipHeader.SETRECFILTER();
        lrecRepSel.SETRANGE(Usage, lrecRepSel.Usage::"S.Shipment");
        lrecRepSel.FIND('-');
        REPEAT
            cuWMDMPrint.printReport(lrrefShipHeader,
              lrecPDAConfig.Code,
              lrecRepSel."Report ID",
              lrecPDAConfig."Regular Printer Name");
        UNTIL lrecRepSel.NEXT = 0;
    END;

    PROCEDURE printConfiguredLabel(VAR precEventParams: Record "IWX Event Param");
    VAR
        lrecPDAConfig: Record "WHI Device Configuration";
        IWXReportSelection: Record "IWX Report Selection";
        lcodWhseProdOrder: Code[50];
        lrecPostedWhseShipLines: Record "Posted Whse. Shipment Line";
        ProdOrder: Record "Production Order";
        Item: Record item;
        ItemRecref: RecordRef;
        Qty: integer;
        i: Integer;
    BEGIN
        cuWMDMCommon.getDeviceConfig(lrecPDAConfig, precEventParams);
        Qty := precEventParams.getValueAsDecimal('prod_qty');
        item.get(precEventParams.getValue('item_number'));
        ItemRecref.GetTable(item);
        ItemRecref.SetRecFilter();
        IWXReportSelection.SETRANGE(Usage, IWXReportSelection.Usage::"Item Label");
        IWXReportSelection.FIND('-');
        REPEAT
            for i := 1 to qty do
                cuWMDMPrint.printReport(ItemRecref,
                  lrecPDAConfig.Code,
                  IWXReportSelection."Report ID",
                  lrecPDAConfig."Label Printer Name");
        UNTIL IWXReportSelection.NEXT = 0;
    END;
    /*
    procedure printItemLabel(var ptrecEventParams: Record "IWX Event Param" temporary; var pbsOutput: BigText)
        var
            lrecItem: Record Item;
            lrecItemLedgerEntry: Record "Item Ledger Entry";
            lcodLotNumber: Code[50];
            lcodSerialNumber: Code[50];
            ldtExpirationDate: Date;
            liNumberOfLabels: Integer;
        begin
            lrecItem.Get(ptrecEventParams.GetExtendedValue('item_number'));
            lcodLotNumber := CopyStr(ptrecEventParams.GetExtendedValue('lot_number'), 1, MaxStrLen(lcodLotNumber));
            lcodSerialNumber := CopyStr(ptrecEventParams.GetExtendedValue('serial_number'), 1, MaxStrLen(lcodSerialNumber));
            ldtExpirationDate := 0D;
            liNumberOfLabels := ptrecEventParams.getValueAsInt('label_numcopies');



           if liNumberOfLabels > 0 then begin
                if (lcodLotNumber <> '') then begin
                    lrecItemLedgerEntry.SetRange("Item No.", lrecItem."No.");
                    lrecItemLedgerEntry.SetRange("Lot No.", lcodLotNumber);
                    lrecItemLedgerEntry.SetRange(Open, true);
                    lrecItemLedgerEntry.SetFilter("Expiration Date", '<>%1', 0D);
                    if (lrecItemLedgerEntry.FindFirst()) then
                        ldtExpirationDate := lrecItemLedgerEntry."Expiration Date";
                end;



               ptrecEventParams.setValue('label_include_qty', Format(false));
                ptrecEventParams.setValue('label_quantity', Format(0));
                ptrecEventParams.setValue('label_uom', lrecItem."Base Unit of Measure");
                ptrecEventParams.setValue('label_numcopies', Format(liNumberOfLabels));
                ptrecEventParams.setValue('label_variant_code', CopyStr(ptrecEventParams.GetExtendedValue('variant_code'), 1, MaxStrLen(ptrecEventParams.Value)));
                ptrecEventParams.setValue('label_item_number', lrecItem."No.");
                ptrecEventParams.setValue('label_ledger_entry_number', Format(0));
                ptrecEventParams.setValue('label_tracking_number', lcodLotNumber + lcodSerialNumber);
                ptrecEventParams.setValue('label_expiry_date', Format(ldtExpirationDate));



               cuPrintingMgmt.handlePrint(ptrecEventParams, pbsOutput);
            end;
        end;
        */
}

