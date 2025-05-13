tableextension 97000 "BAL WHI Document Ext" extends "WHI Document List Buffer"
{
    fields
    {
        field(97000; "BAL Shopify No"; Code[50])
        {
            Caption = 'Shopify Order No.';
            CalcFormula = lookup("Sales Header"."Shpfy Order No." WHERE("No." = FIELD("Source Document No.")));
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
        field(97700; "BAL Shipment Method"; Code[10])
        {
            FieldClass = FlowField;
            CalcFormula = lookup("sales header"."Shipment Method Code" where("No." = field("Source Document No.")));
            Editable = false;
        }
        field(97701; "BAL Shipping Advice"; enum "Sales Header Shipping Advice")
        {
            Caption = 'Shipping Advice';
            FieldClass = FlowField;
            CalcFormula = lookup("sales header"."Shipping Advice" where("No." = field("Source Document No.")));
            Editable = false;
        }
        Field(97720; "BAL Shipment Exist"; Boolean)
        {
            Caption = 'Shipment Exist';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = exist("Sales Shipment Header" where("Order No." = field("Source Document No.")));
        }
        field(97703; "BAL Shipment Method Code"; code[10])
        {
            FieldClass = FlowField;
            CalcFormula = lookup("Sales Header"."Shipment Method Code" where("No." = field("Source Document No.")));
            Caption = 'Shipping Method Code';
        }
        field(97730; "BAL Ship-to name"; text[100])
        {
            FieldClass = FlowField;
            CalcFormula = lookup("Sales Header"."Ship-to Name" where("No." = field("Source Document No.")));
            Caption = 'Ship-to Name';
        }
        field(97731; "BAL Ship-to Address"; text[100])
        {
            FieldClass = FlowField;
            CalcFormula = lookup("Sales Header"."Ship-to Address" where("No." = field("Source Document No.")));
            Caption = 'Ship-to address';
        }
        field(97732; "BAL Ship-to City"; text[100])
        {
            FieldClass = FlowField;
            CalcFormula = lookup("Sales Header"."Ship-to City" where("No." = field("Source Document No.")));
            Caption = 'Ship-to City';
        }
        field(97733; "BAL Ship-to Post code"; Code[20])
        {
            FieldClass = FlowField;
            CalcFormula = lookup("Sales Header"."Ship-to Post Code" where("No." = field("Source Document No.")));
            Caption = 'Ship-to Post code';
        }
        field(97734; "BAL Shipping Agent Code"; code[10])
        {
            FieldClass = FlowField;
            CalcFormula = lookup("Sales Header"."Shipping Agent Code" where("No." = field("Source Document No.")));
            Caption = 'Shipping Agent Code';
        }
        field(97735; "BAL shipping agent Service"; code[10])
        {
            FieldClass = FlowField;
            CalcFormula = lookup("Sales Header"."Shipping Agent Service Code" where("No." = field("Source Document No.")));
            Caption = 'Ship-to Agent Service';
        }       

        field(97740; "BAL To name"; text[100])
        {
            FieldClass = FlowField;
            CalcFormula = lookup("Transfer Header"."Transfer-to Name" where("No." = field("Source Document No.")));
            Caption = 'To name';
        }

    }

    var
        p42: page 42;
        t37: record 37;

}