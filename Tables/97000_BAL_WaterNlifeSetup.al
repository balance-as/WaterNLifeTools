table 97000 "BAL WaterNlife Setup"
{
       Caption = 'WaterNlife Setup';
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