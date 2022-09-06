page 97000 "BAL WaterNlife Setup Card"
{
    //BAL1.01/KME/13092021/JNI : Created

    //BAL1.01/START
    //BAL1.01/STOP

    SourceTable = "BAL WaterNlife Setup";
    Caption = 'WaterNlife Setup';
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            group(Debug)
            {
                Caption = 'Debug mode';

                field("Debug mode"; rec."Debug mode")
                {
                    ApplicationArea = all;
                }
                field("Debug path"; rec."Debug path")
                {
                    ApplicationArea = all;
                }
            }
            group(Webshop)
            {
                Caption = 'Webshop';
                field("Webshop Payment URL"; Rec."Webshop Payment URL")
                {
                    ApplicationArea = All;
                    ToolTip = '%1 = Weborder No., %2 = Sales Order No., %3 = Currency Code, %4 = Amount';
                }
            }
            group(GTIN)
            {
                field("GTIN No. Series "; rec."GTIN No. Series ")
                {
                    ApplicationArea = all;
                }
                field("Bin Ranking filter"; rec."Bin Ranking filter")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {

            action(Print)
            {
                Caption = 'Print Label';
                ApplicationArea = All;
                Image = Print;
                trigger OnAction()
                begin
                    Report.run(Report::"BAL WaterNLife Item Label");
                end;
            }
            action(ChangelocationtoWBS)
            {
                Caption = 'Set salesorders to Location WBS';
                ApplicationArea = All;
                Image = Print;
                trigger OnAction()
                var
                    SalesLine: record "Sales Line";
                begin
                    if confirm('Are You sure that You want to change salesline."Location code" to WBS', false) then begin
                        salesline.setrange("Document Type", SalesLine."Document Type"::Order);
                        SalesLine.SetRange(type, SalesLine.type::Item);
                        SalesLine.ModifyAll("Location Code", 'WBS');
                    end;
                end;
            }
            action(ClearInventory)
            {
                Caption = 'Clear Inventory registrered';
                ApplicationArea = All;
                //Visible = false;

                trigger OnAction()
                var
                    ItemJournalLine: record "Item Journal Line";

                begin
                    ItemJournalLine.SetRange("Journal Template Name", 'PHYS. INVE');
                    ItemJournalLine.SetRange("Journal Batch Name", 'SR');
                    if ItemJournalLine.findset then
                        repeat
                            ItemJournalLine.Validate("Qty. (Phys. Inventory)", 0);
                            ItemJournalLine.modify;
                        until ItemJournalLine.next = 0;

                end;

            }
            action(Clear2Bincontent)
            {
                Caption = 'Clear 2 Bin Content';
                ApplicationArea = All;
                //Visible = false;

                trigger OnAction()
                var
                    BinContent: record "Bin Content";

                begin

                    BinContent.setrange("Min. Qty.", 2);
                    BinContent.ModifyAll("Min. Qty.", 0);
                end;

            }
        }
    }
}
