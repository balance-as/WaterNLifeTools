pageextension 97009 "Bal ReclassJnl Ext" extends "Item Reclass. Journal"
{
    layout
    {
        // Add changes to page layout here
    }

    actions
    {
        addafter("&Item")
        {
            action(Movetolocation)
            {
                Caption = 'Move-to Location';
                ApplicationArea = All;
                //Visible = false;

                trigger OnAction()
                var
                    ItemJournalLine: record "Item Journal Line";

                begin
                    ItemJournalLine.SetRange("Journal Template Name", rec."Journal Template Name");
                    ItemJournalLine.SetRange("Journal Batch Name", rec."Journal Batch Name");
                    if ItemJournalLine.findset then
                        repeat
                            ItemJournalLine.Validate("New Location Code", 'GRAMRODE13');
                            ItemJournalLine.validate("New Bin Code", ItemJournalLine."Bin Code");
                            ItemJournalLine.modify;
                        until ItemJournalLine.next = 0;

                end;

                // Add changes to page actions here
            }
        }
    }

    var
        myInt: Integer;
}