pageextension 97002 "BAL Item List Ext" extends "Item List"
{
    //BAL1.01/KME/07092021/JNI : Created

    //BAL1.01/START
    //BAL1.01/STOP

    layout
    {
        addafter("Base Unit of Measure")
        {
            field("BAL Status"; rec."BAL Status")
            {
                ApplicationArea = All;
            }
        }
        // Add changes to page layout here
        addfirst(factboxes)
        {

        }
    }

    actions
    {
        // Add changes to page actions here
        addfirst(reporting)
        {
            action("BAL ItemLabel")
            {
                Caption = 'Item Label';
                ApplicationArea = All;
                Image = AdjustItemCost;
                Promoted = true;
                PromotedCategory = Report;
                trigger OnAction()
                var
                    Rec2: Record Item;
                    ItemLabel: Report "BAL WaterNLife Item Label";
                begin
                    Rec2 := Rec;
                    Rec2.SetRecFilter();
                    Clear(ItemLabel);
                    ItemLabel.SetTableView(Rec2);
                    ItemLabel.runmodal;
                end;
            }
        }
    }
}