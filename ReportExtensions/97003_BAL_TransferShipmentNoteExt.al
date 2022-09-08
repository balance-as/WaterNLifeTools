reportextension 97003 "BAL Transfer Shipment Ext" extends "Transfer Shipment"
{
    dataset
    {
        add("Transfer Shipment Header")
        {
            column(BAL_Shipment_ID; "BAL Shipment ID")
            {

            }


            column(BAL_Tracking_ID; "BAL Tracking ID")
            {

            }
        }
        add("Transfer Shipment Line")
        {
            column(GTIN; Item.GTIN)
            {

            }
        }
        modify("Transfer Shipment Line")
        {
            trigger OnAfterAfterGetRecord()
            var

            begin
                if not item.get("Transfer Shipment Line"."Item No.") then
                    clear(item);

            end;
        }
    }
    var
        Item: Record Item;
}