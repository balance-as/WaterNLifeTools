tableextension 97017 "BAL ItemTempl Tabext" extends "Item Templ."
{
    fields
    {
        field(97000; "BAL SKU Location Code"; code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'SKU Location Code';
            TableRelation = Location;
        }
        field(97001; "BAL Sku Item No."; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Sku Item No.';
            TableRelation = Item;
        }
        field(97002; "BAL Sku Variant"; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Sku Variant No.';
            TableRelation = "Item Variant".Code where("Item No." = field("BAL Sku Item No."));
        }
    }
    
    keys
    {
        // Add changes to keys here
    }
    
    fieldgroups
    {
        // Add changes to field groups here
    }
    
    var
        myInt: Integer;
}