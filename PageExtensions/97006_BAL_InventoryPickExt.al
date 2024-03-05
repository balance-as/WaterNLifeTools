pageextension 97006 "BAL InventoryPick Ext" extends "Inventory Pick"
{
    layout
    {
        addafter("External Document No.")
        {
            field("BAL Assigned User ID"; rec."Assigned User ID")
            {
                ApplicationArea = All;
            }
            field("BAL Assignment Date"; rec."Assignment Date")
            {
                ApplicationArea = All;
            }
            field("BAL Assignment Time"; rec."Assignment Time")
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