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

        Field(97001; "BAL Shipment ID"; Code[100])
        {
            Caption = 'Shipment ID';
            CalcFormula = lookup("Transfer Header"."BAL Shipment ID" WHERE("No." = FIELD("Source Document No.")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(97102; "BAL Item No."; code[20])
        {
            Caption = 'Item No.';
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = lookup("Sales Line"."No." where("Document Type" = const(Order), "Document No." = field("Source Document No."), type = filter(2)));
        }

    }

    var
    p42 :page 42; 
    t37:record 37;

}