tableextension 97015 "BAL Transfer Route Ext" extends "Transfer Route"
{
    //BAL1.01/WaterNLifeTools/29092023/AR  : Created

    //BAL1.01/START
    //BAL1.01/STOP

    fields
    {
        field(97000; "BAL Partner VAT ID"; Code[20])
        {
            Caption = 'Partner VAT. No.';
            DataClassification = CustomerContent;
        }
    }
}