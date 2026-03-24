pageextension 97021 "BAL Location page ext" extends "Location Card"
{
    layout
    {
        addafter("To-Job Bin Code")
        {
            group("Wrong Pick")
            {
                Caption = 'Wrong Pick';
                field("BAL Wrong Pick Bin"; rec."BAL Wrong Pick Bin")
                {
                    ApplicationArea = all;                    
                }
                field("BAL Wrong Template Name"; rec."BAL Wrong Template Name")
                {
                    ApplicationArea = all;
                }
                field("BAL Wrong Batch Name"; rec."BAL Wrong Batch Name")
                {
                    ApplicationArea = all;
                }
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