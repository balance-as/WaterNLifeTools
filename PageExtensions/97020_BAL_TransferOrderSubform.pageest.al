pageextension 97020 "BAL Transfer Order Subform" extends "Transfer Order Subform"
{
    layout
    {
        // Add changes to page layout here
    }

   /* actions
    {
        addafter(SelectMultiItems)
        {
            action(settransit23)
            {
                ApplicationArea = all;
                trigger OnAction()
                var

                begin
                    if rec."Item No." = '248011' then begin
                        rec."Qty. in Transit" := 23;
                        rec."Qty. in Transit (Base)" := 23;
                        rec."Qty. Received (Base)" := 50;
                        rec."Quantity Received" := 50;
                        rec.Modify()
                    end;
                end;
            }
        }
    }
    */

    var
        myInt: Integer;
}