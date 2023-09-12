pageextension 97001 "BAL Item Card Ext" extends "Item Card"
{
    //BAL1.01/KME/16072021/JNI : Created

    //BAL1.01/START
    //BAL1.01/STOP

    layout
    {
        addafter("Qty. on Sales Order")
        {
            field("BAL Qty on Blanket Order"; rec."BAL Qty on Blanket Order")
            {
                ApplicationArea = All;
            }
             field("Qty. on Blank Purch Order";rec."Qty. on Blank Purch Order")
            {
                ApplicationArea = All;
            }
        }
    }
    actions
    {
        // Add changes to page actions here
        addlast(processing)
        {
            /*          action(GetGTIN)
                      {
                          Caption = 'Get GTIN no.';
                          ToolTip = 'Get new GTIN Number from No. series';
                          Image = ActivateDiscounts;
                          ApplicationArea = All;
                          trigger OnAction()
                          var
                              BalInsightFunc: Codeunit "BAL InsightFunc";
                          begin
                              BalInsightFunc.GetGTIN(Rec);
                          end;
                      }
              */
        }
        addfirst(Reporting)
        {
            action("BAL ItemLabel")
            {
                Caption = 'Item Label';
                ApplicationArea = All;
                Image = AdjustItemCost;
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