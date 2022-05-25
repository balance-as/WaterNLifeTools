report 97100 "BAL WaterNLife Item Label"
{
    //BAL1.01/KME/27042022/JNI : Created

    //BAL1.01/START
    //BAL1.01/STOP

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
                column(Logo; Setup."Report Logo")
                {

                }
                column(Description; Item.Description)
                {

                }
                Column(UnitListPriceLbl; UnitListPriceLbl)
                {

                }
                Column(UnitListPrice; Price)
                {

                }
                column(ShelfNoLbl; Item.fieldcaption("Shelf No."))
                {

                }
                column(ShelfNo; Item."Shelf No.")
                {

                }
                column(NoLbl; Item.Fieldcaption("No."))
                {

                }
                column(No; Item."No.")
                {

                }
                column(QtyLbl; QtyLbl)
                {

                }
                column(Qty; Qty)
                {
                    DecimalPlaces = 0 : 2;
                }
                column(VendorItemNoLbl; VendorItemNoLbl)
                {

                }
                column(VendorItemNo; item."Vendor Item No.")
                {

                }
                column(GTIN; item.GTIN)
                {

                }
                column(BarCodeText; BarCodeText)
                {

                }
                column(CompanyInformationName; CompanyInformation.Name)
                {

                }
                column(CompanyInformationAddress; CompanyInformation.Address)
                {

                }
                column(CompanyInformationPostCode; CompanyInformation."Post Code")
                {

                }
                column(CompanyInformationCity; CompanyInformation.City)
                {

                }
                column(CompanyInformationHomepage; CompanyInformation."Home Page")
                {

                }
                column(QRBarcode; TempBarcode.Picture)
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
                If Setup.get() then;
                Setup.CalcFields("Report Logo");
            end;

            trigger OnAfterGetRecord()
            var
                //TempSetup: Record "BAL Kaffe Mekka Setup" temporary;
                //lcuBarcodeManagement: Codeunit "IWX Barcode Generation";
                lisInStream: InStream;
                losOutStream: OutStream;
                iBarcodeDotSize: Integer;
                iBarcodeMarginSize: Integer;
                iBarcodeImageSize: Integer;
                cuTempBlob: Codeunit "Temp Blob";
            begin
                IBarcodeFontProvider := Enum::"Barcode Font Provider"::IDAutomation1D;
                BarcodeSymbology := Enum::"Barcode Symbology"::"EAN-13";
                BarCodeText := IBarcodeFontProvider.EncodeFont(GTIN, BarcodeSymbology);
                if item."Price Includes VAT" then
                    Price := "Unit Price"
                else
                    Price := round("Unit Price" * 1.25, 0.01);

                if Item.GTIN = '' then begin
                    //set barcode variables
                    iBarcodeDotSize := 2;
                    iBarcodeMarginSize := 0;
                    iBarcodeImageSize := 0;
                    //create barcode 2D
                  //          lcuBarcodeManagement.get2dBarCode(cuTempBlob, "No.", iBarcodeDotSize, iBarcodeMarginSize, iBarcodeImageSize);
                    TempBarcode.Picture.CreateOutStream(losOutStream);
                    cuTempBlob.CreateInStream(lisInStream);
                    CopyStream(losOutStream, lisInStream);
                end else
                    clear(TempBarcode);
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
                    field(Qty; Qty)
                    {
                        Caption = 'Quantity';
                        ApplicationArea = All;
                        DecimalPlaces = 0 : 2;
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
            Qty := 1;
        end;
    }


    var
        Setup: Record "BAL WaterNlife Setup";
        CompanyInformation: Record "Company Information";
        NoOfLabels: Integer;
        BarCodeText: Text[30];
        BarcodeSymbology: Enum "Barcode Symbology";
        IBarcodeFontProvider: Interface "Barcode Font Provider";
        QtyLbl: Label 'Quantity';
        UnitListPriceLbl: Label 'Price';
        VendorItemNoLbl: Label 'MFR Number';
        Qty: Decimal;
        Price: Decimal;
        TempBarcode: Record "Company Information" temporary;
}