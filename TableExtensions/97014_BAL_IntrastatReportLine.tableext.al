tableextension 97014 "BAL Intrastat Report Line Ext" extends "Intrastat Report Line"
{
    fields
    {
        field(97000; "BAL Reference code"; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Reference Code';
        }
        field(97001; "BAL Refence name"; Text[100])
        {
            DataClassification = ToBeClassified;
            Caption = 'Reference Name';
        }
        field(97002; "BAL Vat Product Posting Group"; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Vat Product posting group';
            TableRelation = "VAT Product Posting Group";
        }
        field(97003; "BAL Reference code 2"; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Reference Code 2';
        }
    }

    var
        myInt: Integer;
}