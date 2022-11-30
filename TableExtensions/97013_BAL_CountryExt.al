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
    }
    
    var
        myInt: Integer;
}