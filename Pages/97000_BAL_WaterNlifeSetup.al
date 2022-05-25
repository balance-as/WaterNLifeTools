page 97000 "BAL WaterNlife Setup Card"
{
    //BAL1.01/KME/13092021/JNI : Created

    //BAL1.01/START
    //BAL1.01/STOP

    SourceTable = "BAL WaterNlife Setup";
    Caption = 'Kaffe Mekka Setup';
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            group(Item)
            {
                Caption = 'Items';
                field("Location Filter Stock Calc."; Rec."Location Filter Stock Calc.")
                {
                    ApplicationArea = All;
                }
            }
            group(Report)
            {
                Caption = 'Reports';
                field("Report Logo"; Rec."Report Logo")
                {
                    ApplicationArea = All;
                    ToolTip = 'Fit proportional';
                }
                field("Report Logo Ecology"; Rec."Report Logo Ecology")
                {
                    ApplicationArea = All;
                    ToolTip = 'Fit proportional';
                }

            }
           
            group(Debug)
            {
                Caption = 'Debug mode';

                field("Debug mode"; rec."Debug mode")
                {
                    ApplicationArea = all;
                }
                field("Debug path"; rec."Debug path")
                {
                    ApplicationArea = all;
                }
            }
            group(Webshop)
            {
                Caption = 'Webshop';
                field("Webshop Payment URL"; Rec."Webshop Payment URL")
                {
                    ApplicationArea = All;
                    ToolTip = '%1 = Weborder No., %2 = Sales Order No., %3 = Currency Code, %4 = Amount';
                }
            }
            group(GTIN)
            {
                field("GTIN No. Series "; rec."GTIN No. Series ")
                {
                    ApplicationArea = all;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {

            action(Print)
            {
                Caption = 'Print Label';
                ApplicationArea = All;
                Image = Print;
                trigger OnAction()
                begin
                    Report.run(Report::"BAL WaterNLife Item Label");
                end;
            }

        }
    }
}
