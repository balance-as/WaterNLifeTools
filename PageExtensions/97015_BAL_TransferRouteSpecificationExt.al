pageextension 97015 "BAL Transfer Route Speci. Ext" extends "Transfer Route Specification"
{
    //BAL1.01/WaterNLifeTools/29092023/AR  : Created

    //BAL1.01/START
    //BAL1.01/STOP

    layout
    {
        // Add changes to page layout here
        addlast(General)
        {
            field("BAL Partner VAT No."; Rec."BAL Partner VAT ID")
            {
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }

}