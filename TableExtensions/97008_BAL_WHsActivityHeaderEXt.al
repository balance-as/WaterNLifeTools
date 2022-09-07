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
        
    }

    var
        myInt: Integer;
}