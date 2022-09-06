pageextension 97012 "BAL Transfer RecieptHdr Ext" extends "Posted Transfer Receipt"
{
    layout
    {
        addafter("Receipt Date")
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