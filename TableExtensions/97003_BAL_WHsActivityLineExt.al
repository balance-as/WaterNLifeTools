tableextension 97003 "BAL WHSeActivitiLine Ext" extends "Warehouse Activity Line"
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