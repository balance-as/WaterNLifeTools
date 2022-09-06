tableextension 97010 "BAL Transfer Order Ext" extends "Transfer Header"
{
    fields
    {
      Field(97000;"BAL Shipment ID";text[100])
      {
        DataClassification = ToBeClassified;
        Caption = 'Shipment ID';
        
      }
      field(97001; "BAL Tracking ID"; Text[100])
      {
        DataClassification = ToBeClassified;
        Caption = 'Tracking ID';
      }
    }
    
    var
        myInt: Integer;
}