tableextension 97007 "BAL Salesheader Ext." extends "Sales Header"
{
    fields
    {
        Field(95144; "BAL Pick Exist"; Boolean)
        {
            Caption = 'Pick Exist';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = exist("Warehouse Activity Header" where("Source No." = field("No."), "Source type" = const(37), "Source Subtype" = const(1)));
        }        
    }

    var
        myInt: Integer;
}