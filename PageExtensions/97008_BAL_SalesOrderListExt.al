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
                    SalesHeader.findset;
                    BALFunc.MoveLocation(salesheader);
                end;
            }
            action(MoveName)
            {
                Caption = 'Create name from contact';
                ApplicationArea = All;
                trigger OnAction()
                var
                    SalesHeader: Record "Sales header";
                    SalesHeader2: Record "Sales header";
                begin
                    if not confirm('Move name') then
                        exit;
                    SalesHeader.setrange("Document Type", SalesHeader."Document Type"::Order);
                    SalesHeader.Setfilter("Sell-to Customer Name", '');
                    SalesHeader.Setfilter("Ship-to Name", '<>%1', '');
                    if salesheader.FindSet() then
                        repeat
                            SalesHeader2.get(SalesHeader."Document Type", SalesHeader."No.");
                            SalesHeader2."Sell-to Customer Name" := SalesHeader2."Ship-to Name";
                            SalesHeader2.modify;
                        until SalesHeader.next = 0

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
                    BALFunc.SetExcludeFromMovement(salesheader, true);
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
                    BALFunc.SetExcludeFromMovement(salesheader, false);
                end;
            }

        }
    }

}