pageextension 97000 "BAL Movement worksheet Exta" extends "Movement Worksheet"
{
    layout
    {
        // Add changes to page layout here
    }

    actions
    {
        addafter("Calculate Bin &Replenishment")
        {
            action("BAL Delete ws")
            {
                ApplicationArea = ItemTracking;
                Caption = 'delete worksheet';
                Image = ItemTrackingLines;
                Promoted = true;
                PromotedCategory = Category4;
                // ShortCutKey = 'Shift+Ctrl+I';
                ToolTip = 'Just testing';

                trigger OnAction()
                var
                    warehousaktiv: Record "Warehouse Activity Header";
                    worksheetnameslist: record "Whse. Worksheet Name";
                    workshtlist: page "Warehouse Activity List";
                begin
                    if confirm('vil du slette warehouseaktivity', false) then
                        warehousaktiv.deleteall(true);
                    if confirm('Vil du slette worsheetlist', false) then
                        worksheetnameslist.deleteall(true);
                    //workshtlist.run;
                    commit;
                end;
            }
        
        }

    }

    var
        
        
}