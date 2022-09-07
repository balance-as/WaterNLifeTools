reportextension 97002 "BAL ShipmentNote Ext" extends "Sales - Shipment"
{
    dataset
    {
        add("Sales Shipment Line")
        {
            column(GTIN; Item.GTIN)
            {

            }
        }
        modify("Sales Shipment Line")
        {
            trigger OnAfterAfterGetRecord()
            var

            begin
                if ("Sales Shipment Line".type = "Sales Shipment Line".type::Item) and ("Sales Shipment Line"."No." <> '') then
                    item.get("Sales Shipment Line"."No.")
                else
                    clear(item);

            end;
        }
    }
    var
        Item: Record Item;
}