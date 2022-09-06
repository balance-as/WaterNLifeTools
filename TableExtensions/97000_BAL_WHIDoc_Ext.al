tableextension 97000 "BAL WHI Document Ext" extends "WHI Document List Buffer"
{
    fields
    {
        field(97000; "BAL Shopify No"; Code[50])
        {
            Caption = 'Shopify Order No.';
            CalcFormula = lookup("Sales Header"."Shopify Order No." WHERE("No." = FIELD("Source Document No.")));
            Editable = false;
            FieldClass = FlowField;
        }

        Field(97001; "BAL Shipment ID"; Code[50])
        {
            Caption = 'Shipment ID';
            CalcFormula = lookup("Transfer Header"."BAL Shipment ID" WHERE("No." = FIELD("Source Document No.")));
            Editable = false;
            FieldClass = FlowField;
        }

    }

    var

}