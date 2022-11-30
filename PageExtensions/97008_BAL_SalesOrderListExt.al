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
                begin
                    BALFunc.MoveLocation();
                end;
            }

        }
    }

}