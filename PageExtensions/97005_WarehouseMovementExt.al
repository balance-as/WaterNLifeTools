pageextension 97005 "BAL Warehouse Movement ext" extends "Warehouse Movement"
{
    layout
    {
        addafter("Sorting Method")
        {
            field("BAL Registering No. Series"; rec."Registering No. Series")
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