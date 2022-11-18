tableextension 97008 "BAL WHsActivityHeader Ext" extends "Warehouse Activity Header"
{
    fields
    {
        Field(97000; "BAL Shipment ID"; Code[100])
        {
            Caption = 'Shipment ID';
            CalcFormula = lookup("Transfer Header"."BAL Shipment ID" WHERE("No." = FIELD("Source No.")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(97100; "Sell-to Customer Name"; Text[100])
        {
            FieldClass = FlowField;
            CalcFormula = lookup("Sales Header"."Sell-to Customer Name" where("Document Type" = const(Order), "No." = field("Source No.")));
            Caption = 'Sell-to Customer Name';

        }

    }

    var
        myInt: Integer;
}