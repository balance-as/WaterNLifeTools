pageextension 97018 "BAL Item Templ Card PageExt" extends "Item Templ. Card"
{
    layout
    {
        addafter("Shelf No.")
        {
            field("BAL Sku Item No."; rec."BAL Sku Item No.")
            {
                ApplicationArea = All;
            }
            field("BAL SKU Location Code"; rec."BAL SKU Location Code")
            {
                ApplicationArea = All;
            }
            field("BAL Sku Variant"; rec."BAL Sku Variant")
            {
                ApplicationArea = All;
                Visible = false;
            }
        }
    }
}