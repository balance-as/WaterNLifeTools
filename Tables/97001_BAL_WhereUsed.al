table 97001 "BAL Where Used"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; No; code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'No.';
        }
        field(2; Description; text[100])
        {
            DataClassification = ToBeClassified;
            Caption = 'Description';
        }
        field(3; Quantity; Decimal)
        {
            DataClassification = ToBeClassified;
            Caption = 'Quantity';
        }
        field(4; RawNo; code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Raw Item No.';
        }
    }

    keys
    {
        key(Key1; No, RawNo)
        {
            Clustered = true;
        }
    }

    var
        myInt: Integer;

    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;

}