pageextension 97011 "BAL Transfer ShipmentHdr Ext" extends "Posted Transfer Shipment"
{
    layout
    {
        addafter("Shipment Date")
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