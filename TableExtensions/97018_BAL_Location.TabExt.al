tableextension 97018 "BAL Location TabExt" extends Location
{
    fields
    {
        field(97000; "BAL Wrong Pick Bin"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = bin.Code where("Location Code" = field(Code));
            Caption = 'Wrong Pick Bin';
        }
        field(97001; "BAL Wrong Batch Name"; Code[10])
        {
            DataClassification = ToBeClassified;
            Caption = 'Wrong Batch Name';
            TableRelation = "Item Journal Batch".Name where("Journal Template Name" = Const('OMKLASIFI'));
        }
        
    }
    
    keys
    {
        // Add changes to keys here
    }
    
    fieldgroups
    {
        // Add changes to field groups here
    }
    
    var
        myInt: Integer;
}