pageextension 97004 "Bal Reclass" extends 392
{
    layout
    {
        // Add changes to page layout here
    }

    actions
    {
        addafter("&Item")
        {
            action(ClearInventory)
            {
                Caption = 'Clear Inventory registrered';
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
                            ItemJournalLine.Validate("Qty. (Phys. Inventory)", 0);
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