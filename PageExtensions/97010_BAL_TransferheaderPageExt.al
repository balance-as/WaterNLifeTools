pageextension 97010 "BAL Transfer Header Ext" extends "Transfer Order"
{
    layout
    {
        addafter("Shipping Time")
        {
            field("BAL Shipment ID";rec."BAL Shipment ID")
            {
                ApplicationArea = All;
            }
            field("BAL Tracking ID";rec."BAL Tracking ID")
            {
                ApplicationArea = All;
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