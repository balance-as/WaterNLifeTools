tableextension 97001 "BAL Bin Content Exta" extends "Bin Content"
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