pageextension 97013 "BAL_CountryList Ext" extends "Countries/Regions"
{
    layout
    {
        addafter("ISO Numeric Code")
        {
            field(ContryFromLocation; rec.MoveFromLocation)
            {
                ApplicationArea = all;
                ToolTip = 'Location to change Amazon - Sales Order Location to';
            }
            field(ContryToLocation; rec.MoveToLocation)
            {
                ApplicationArea = all;
                ToolTip = 'Location to change Amazon - Sales Order Location from';
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;
}