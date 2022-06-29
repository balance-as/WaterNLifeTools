pageextension 97003 "BAL Bin Content Ext" extends "Bin Contents"
{
    layout
    {
addafter("Item No.")
{
    field("BAL GTIN";rec."BAL GTIN")
    {
        ApplicationArea = all;
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