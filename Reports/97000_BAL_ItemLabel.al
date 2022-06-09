report 97000 "BAL WaterNLife Item Label"
{
    UsageCategory = Administration;
    ApplicationArea = All;
    Caption = 'Item Label';
    DefaultLayout = RDLC;
    PreviewMode = PrintLayout;
    RDLCLayout = '.\Reports\Item_Label.rdlc';
    dataset
    {
        dataitem(Item; Item)
        {
            RequestFilterFields = "No.";
            dataitem(NoLabel; Integer)
            {
                DataItemTableView = sorting(Number);
                column(Description; Item.Description)
                {
                }

                column(NoLbl; Item.Fieldcaption("No."))
                {
                }
                column(No; Item."No.")
                {
                }
                column(GTIN; item.GTIN)
                {
                }
                column(BarCodeText; BarCodeText)
                {

                }
                column(ItemCategoryCode; item."Item Category Code")
                {

                }
                column(ColorValue; GetAttributValue(Item."No.", 3))
                {

                }
                column(PackSizeValue; GetAttributValue(Item."No.", 4))
                {

                }
                column(UKSizeValue; GetAttributValue(Item."No.", 8))
                {

                }
                column(UKEUSizeValue; GetAttributValue(Item."No.", 9))
                {

                }
                column(EUSizeValue; GetAttributValue(Item."No.", 10))
                {
                }
                column(UPC; PackageQty)
                {
                }
                column(PurchOrderNo; PurchOrderNo)
                {
                }

                trigger OnPreDataItem()
                begin
                    SetRange(Number, 1, NoOfLabels);
                end;
            }

            trigger OnPreDataItem()
            begin
                CompanyInformation.get();
                //If Setup.get() then;
            end;

            trigger OnAfterGetRecord()
            var

            begin
                IBarcodeFontProvider := Enum::"Barcode Font Provider"::IDAutomation1D;
                BarcodeSymbology := Enum::"Barcode Symbology"::"EAN-13";
                BarCodeText := IBarcodeFontProvider.EncodeFont(GTIN, BarcodeSymbology);
            end;
        }
    }
    requestpage
    {
        layout
        {
            area(Content)
            {
                group(Settings)
                {
                    field(NoOfLabels; NoOfLabels)
                    {
                        Caption = 'No. of Labels';
                        ApplicationArea = All;
                    }
                    field(PurchOrderNo; PurchOrderNo)
                    {
                        Caption = 'Purchase Order No.';
                        ApplicationArea = All;
                        TableRelation = "Purchase Header"."No." where("Document Type" = CONST(Order));
                    }
                    field(PackageQty; PackageQty)
                    {
                        Caption = 'Package Quantity:';
                        ApplicationArea = All;
                    }
                }
            }
        }
        actions
        {
            area(processing)
            {
                action(ActionName)
                {
                    ApplicationArea = All;
                }
            }
        }
        trigger OnInit()
        begin
            if NoOfLabels = 0 then
                NoOfLabels := 1;
        end;

        trigger OnOpenPage()
        var
            ItemL: Record Item;
        begin

            if Item.GetFilter("No.") <> '' then
                if iteml.get(Item.GetFilter("No.")) then
                    PackageQty := GetAttributValue(Iteml."No.", 13);

        end;
    }
    local procedure GetAttributValue(No: Code[20]; AttributID: Integer): Text
    begin
        if AttributeValueMapping.get(database::Item, No, AttributID) then
            if ItemAttributeValue.get(AttributeValueMapping."Item Attribute ID", AttributeValueMapping."Item Attribute Value ID") then
                exit(ItemAttributeValue.Value);
        exit('');
    end;

    procedure SetPurchOrder(OrderNo: Code[20])
    var
        myInt: Integer;
    begin
        PurchOrderNo := orderno;
    end;

    var
        //Setup: Record "BAL WaterNlife Setup";
        CompanyInformation: Record "Company Information";
        NoOfLabels: Integer;
        BarCodeText: Text[30];
        BarcodeSymbology: Enum "Barcode Symbology";
        IBarcodeFontProvider: Interface "Barcode Font Provider";
        TempBarcode: Record "Company Information" temporary;
        ItemAttribute: Record "Item Attribute";
        ItemAttributeValue: Record "Item Attribute Value";
        AttributeValueMapping: Record "Item Attribute Value Mapping";
        PurchOrderNo: Code[20];
        PackageQty: Text[30];

}