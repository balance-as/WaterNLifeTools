tableextension 97016 "BAL VAT Busi. Posting Grp. Ext" extends "VAT Business Posting Group"
{
    //BAL1.01/WaterNLifeTools/14022024/AR  : Created

    //BAL1.01/START
    //BAL1.01/STOP

    fields
    {
        field(97000; "BAL Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            DataClassification = CustomerContent;
            TableRelation = Currency;
        }
        field(97001; "BAL Max. Amount in Currency"; Decimal)
        {
            Caption = 'Max. Amount in Currency';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 2;
        }
    }
}