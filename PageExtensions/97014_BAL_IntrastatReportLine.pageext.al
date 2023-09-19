pageextension 97014 "BAL Intrastat Report Line ext" extends "Intrastat Report Subform"
{
    layout
    {
        addafter("Area")
        {
            field("BAL Reference code"; rec."BAL Reference code")
            {
                ApplicationArea = all;
            }
            field("BAL Refence name";rec."BAL Refence name")
            {
                ApplicationArea = all;
            }
            field("BAL Vat Product Posting Group"; rec."BAL Vat Product Posting Group")
            {
                ApplicationArea = all;
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;
}