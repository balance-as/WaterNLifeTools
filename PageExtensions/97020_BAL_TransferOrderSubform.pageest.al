pageextension 97020 "BAL Transfer Order Subform" extends "Transfer Order Subform"
{
    layout
    {
        // Add changes to page layout here
    }

    actions
    {
        addafter(SelectMultiItems)
        {
            action(settransit23)
            {
                ApplicationArea = all;
                trigger OnAction()
                var

                begin
                    if rec."Item No." = '248031' then begin
                        rec."Qty. in Transit" := 25;
                        rec."Qty. in Transit (Base)" := 25;
                        rec."Qty. Received (Base)" := 75;
                        rec."Quantity Received" := 75;
                        rec.Modify()
                    end;
                end;
            }
        }
    }
    

    var
        myInt: Integer;
}