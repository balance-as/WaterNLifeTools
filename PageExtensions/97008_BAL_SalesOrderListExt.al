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
            action("Move UK Orders")
            {
                Caption = 'Move UK orders';
                ApplicationArea = All;
                Image = MoveDown;
                trigger OnAction()

                var
                    BALFunc: codeunit "BAL Func";
                    BalWaterNLifesetup: record "BAL WaterNlife Setup";
                begin
                    BalWaterNLifesetup.get;
                    BalWaterNLifesetup.testfield(ContryLocation);
                    BalWaterNLifesetup.testfield(ContryFromLocation);
                    BalWaterNLifesetup.testfield(ContryToLocation);
                    BALFunc.MoveLocation(rec, BalWaterNLifesetup.ContryLocation, BalWaterNLifesetup.ContryFromLocation, BalWaterNLifesetup.ContryToLocation);
                end;
            }

        }
    }

}