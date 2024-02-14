pageextension 97016 "BAL VAT Bus. Posting Grp. Ext" extends "VAT Business Posting Groups"
{
    //BAL1.01/WaterNLifeTools/14022024/AR  : Created

    //BAL1.01/START
    //BAL1.01/STOP

    layout
    {
        // Add changes to page layout here
        addlast(Control1)
        {
            field("BAL Currency Code"; Rec."BAL Currency Code")
            {
                ApplicationArea = All;
            }
            field("BAL Max. Amount in Currency"; Rec."BAL Max. Amount in Currency")
            {
                ApplicationArea = All;
                BlankZero = true;
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }
}