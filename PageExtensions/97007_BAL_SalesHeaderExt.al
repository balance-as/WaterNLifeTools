pageextension 97007 "BAL Sales Header Ext." extends "Sales Order"
{
    layout
    {
        addafter(Status)
        {
            field("BAL Pick Exist"; rec."BAL Pick Exist")
            {
                ApplicationArea = all;
            }
        }
    }

    actions
    {
        addafter("Send IC Sales Order")
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
                    SalesHeader.get(rec."Document Type", rec."No.");
                    BALFunc.MoveLocation(salesheader);
                end;
            }
            action("Set Exclude From")
            {
                Caption = 'Set exclude from Movement';
                ToolTip = 'This function is used to change valud for "Exclude from movement"';
                ApplicationArea = All;
                Image = MoveNegativeLines;
                trigger OnAction()

                var
                    BALFunc: codeunit "BAL Func";
                    BalWaterNLifesetup: record "BAL WaterNlife Setup";
                    SalesHeader: Record "Sales Header";
                begin
                    SalesHeader.get(rec."Document Type", rec."No.");
                    SalesHeader.setrange("no.", rec."No.");
                    BALFunc.SetExcludeFromMovement(salesheader,true);
                end;
            }
        }

    }
}