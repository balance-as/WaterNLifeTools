table 97000 "BAL WaterNlife Setup"
{
    //BAL1.01/KME/13092021/JNI  : Created

    //BAL1.01/START
    //BAL1.01/STOP

    Caption = 'Kaffemekka Setup';
    DataClassification = CustomerContent;
    LookupPageId = "BAL WaterNlife Setup Card";
    DrillDownPageId = "BAL WaterNlife Setup Card";

    fields
    {
        field(1; "Primary Kay"; code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(2; "Location Filter Stock Calc."; Text[100])
        {
            Caption = 'Location Filter Stock Calculation';
            DataClassification = CustomerContent;
        }

        field(100; "Report Logo"; Blob)
        {
            Caption = 'Report Logo';
            DataClassification = CustomerContent;
            Subtype = Bitmap;
        }
        field(101; "Report Logo Ecology"; Blob)
        {
            Caption = 'Report Logo Ecology';
            DataClassification = CustomerContent;
            Subtype = Bitmap;
        }
        field(102; "Temp Report Logo Ecology"; Blob)
        {
            Caption = 'Temp Report Logo Ecology';
            DataClassification = CustomerContent;
            Subtype = Bitmap;
        }
        field(103; "Item Attribute For Ecology"; Text[250])
        {
            Caption = 'Item Attribute For Ecology';
            DataClassification = CustomerContent;
            trigger OnLookup()
            var
                ItemAttribute: Record "Item Attribute";
                ItemAttributes: Page "Item Attributes";
            begin
                clear(ItemAttributes);
                ItemAttributes.LookupMode(true);
                ItemAttributes.SetTableView(ItemAttribute);
                if ItemAttributes.RunModal() = Action::LookupOK then begin
                    ItemAttributes.GetRecord(ItemAttribute);
                    "Item Attribute For Ecology" := ItemAttribute.Name;
                end;
            end;

        }
        
        field(106; Durability; DateFormula)
        {
            Caption = 'Durability';
            DataClassification = CustomerContent;
        }
        
        field(5400; "Output Journal Template Name"; Code[10])
        {
            Caption = 'Output Journal Template Name';
            DataClassification = CustomerContent;
            TableRelation = "Item Journal Template" where(Type = filter(Output));
        }
        field(5401; "Journal Batch Name"; Code[10])
        {
            Caption = 'Journal Batch Name';
            DataClassification = CustomerContent;
            TableRelation = "Item Journal Batch".Name where("Template Type" = filter(Output), "Journal Template Name" = field("Output Journal Template Name"));
        }
        field(5405; "BAL Bag Route"; Code[20])
        {
            Caption = 'Bag Route';
            DataClassification = ToBeClassified;
            TableRelation = "Routing Header";
        }
        field(5406; "BAL Weighing Route"; Code[20])
        {
            Caption = 'Weighing Route';
            DataClassification = ToBeClassified;
            TableRelation = "Routing Header";
        }
        field(5407; "BAL Bag Route Link"; Code[10])
        {
            Caption = 'Bag Route link';
            DataClassification = ToBeClassified;
            TableRelation = "Routing Link";
        }
        field(5408; "BAL Weighing Route link"; Code[10])
        {
            Caption = 'Weighing Route Link';
            DataClassification = ToBeClassified;
            TableRelation = "Routing Link";
        }
        field(5410; "Debug mode"; Boolean)
        {
            Caption = 'Debug Mode';
            DataClassification = ToBeClassified;
        }
        field(5420; "Debug path"; Text[250])
        {
            Caption = 'Debug path';
            DataClassification = ToBeClassified;
        }
        field(50001; "Webshop Payment URL"; Text[250])
        {
            Caption = 'Webshop PAyment URL';
            DataClassification = CustomerContent;
        }
         field(50100; "GTIN No. Series "; Text[250])
        {
            Caption = 'GTIN No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
    }

    keys
    {
        key(PK; "Primary Kay")
        {
            Clustered = true;
        }
    }
}