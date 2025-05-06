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
         field(97734; "BAL Shipping Agent Code"; code[10])
        {
            FieldClass = FlowField;
            CalcFormula = lookup("Sales Header"."Shipping Agent Code" where("Document Type" = const(Order), "No." = field("Source No.")));
            Caption = 'Shipping Agent Code';
        }
        field(97735; "BAL shipping agent Service"; code[10])
        {
            FieldClass = FlowField;
            CalcFormula = lookup("Sales Header"."Shipping Agent Service Code" where("Document Type" = const(Order), "No." = field("Source No.")));
            Caption = 'Ship-to Agent Service';
        }    
         field(97036; "BAL Shopify No"; Code[50])
        {
            Caption = 'Shopify Order No.';
            CalcFormula = lookup("Sales Header"."Shopify Order No." where("Document Type" = const(Order), "No." = field("Source No.")));
            Editable = false;
            FieldClass = FlowField;
        }   

    }

    var
        myInt: Integer;
}