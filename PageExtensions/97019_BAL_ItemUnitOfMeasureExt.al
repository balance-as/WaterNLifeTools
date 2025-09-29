pageextension 97019 "BAL Item Units Of Measure Ext" extends "Item Units of Measure"
{
    //BAL1.01/WaterNLifeTools/29092025/AR  : Created

    //BAL1.01/START
    //BAL1.01/STOP

    layout
    {
        // Add changes to page layout here
        addlast(Control1)
        {
            field("BAL Qty. Rounding Precision"; Rec."Qty. Rounding Precision")
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