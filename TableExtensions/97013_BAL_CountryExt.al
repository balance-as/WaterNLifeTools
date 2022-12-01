tableextension 97013 "BAL Country Ext" extends "Country/Region"
{
    fields
    {
        field(97001; MoveToLocation; Code[10])
        {
            DataClassification = ToBeClassified;
            caption = 'Move to Location';
            TableRelation = Location;
        }
        field(97002; MoveFromLocation; Code[10])
        {
            DataClassification = ToBeClassified;
            caption = 'Move From Location';
            TableRelation = Location;
        }
        field(97003; "Shipping Agent Code"; Code[10])
        {
            AccessByPermission = TableData "Shipping Agent Services" = R;
            Caption = 'Shipping Agent Code';
            TableRelation = "Shipping Agent";
        }
    }

    var
        myInt: Integer;
}