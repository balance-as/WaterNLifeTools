tableextension 97006 "BAL Item JnlLine Ext" extends "Item Journal Line"
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

    var

}