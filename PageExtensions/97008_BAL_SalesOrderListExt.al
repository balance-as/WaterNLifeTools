pageextension 97008 "BAL Sales Headerlist Ext." extends "Sales Order List"
{
    layout
    {
        addafter("Sell-to Customer No.")
        {
            field("BAL Pick Exist"; rec."BAL Pick Exist")
            {
                ApplicationArea = all;
            }
        }
    }

    actions
    {
        addafter("Delete Invoiced")
        {
            action("Move Amazon Orders")
            {
                Caption = 'Move Amazon Orders';
                ToolTip = 'This function is used to change "Shipment Location" according to setup in Country/Region table';
                ApplicationArea = All;
                Image = MoveDown;
                trigger OnAction()

                var
                    BALFunc: codeunit "BAL Func";
                    BalWaterNLifesetup: record "BAL WaterNlife Setup";
                    SalesHeader: Record "Sales Header";
                begin
                    CurrPage.SETSELECTIONFILTER(SalesHeader);
                    BALFunc.MoveLocation(salesheader);
                end;
            }
            action("Set Exclude From")
            {
                Caption = 'Set exclude from Movement';
                ToolTip = 'This function is used to change value for "Exclude from movement"';
                ApplicationArea = All;
                Image = MoveNegativeLines;
                trigger OnAction()

                var
                    BALFunc: codeunit "BAL Func";
                    BalWaterNLifesetup: record "BAL WaterNlife Setup";
                    SalesHeader: Record "Sales Header";
                begin
                    CurrPage.SETSELECTIONFILTER(SalesHeader);
                    BALFunc.SetExcludeFromMovement(salesheader,true);
                end;
            }
            action("Set not Exclude From")
            {
                Caption = 'Set include from Movement';
                ToolTip = 'This function is used to change value for "Exclude from movement"';
                ApplicationArea = All;
                Image = MoveNegativeLines;
                trigger OnAction()

                var
                    BALFunc: codeunit "BAL Func";
                    BalWaterNLifesetup: record "BAL WaterNlife Setup";
                    SalesHeader: Record "Sales Header";
                begin
                    CurrPage.SETSELECTIONFILTER(SalesHeader);
                    BALFunc.SetExcludeFromMovement(salesheader,false);
                end;
            }

        }
    }

}