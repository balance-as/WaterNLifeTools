tableextension 97005 "BAL WHSeRecieptLine Ext" extends "Warehouse Receipt Line"
{
    fields
    {
        field(97000; "BAL GTIN"; Code[50])
        {
            Caption = 'GTIN';
            CalcFormula = lookup(item.GTIN WHERE("No." = FIELD("Item No.")));
            Editable = false;
            FieldClass = FlowField;
        }
    }
    
}