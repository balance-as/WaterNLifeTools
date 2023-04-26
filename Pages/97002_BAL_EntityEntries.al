
page 97002 "BAL delete Entity"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Transfer Line";
    Caption = 'BAL Entity Delete', Locked = true;
    DelayedInsert = true;
    Permissions = TableData "Transfer Line" = d;
    DeleteAllowed = true;


    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Item No."; rec."Item No.")
                {
                    ApplicationArea = All;

                }
                field("Document No."; rec."Document No.")
                {
                    ApplicationArea = All;
                }
                field("Line No."; rec."Line No.")
                {
                    ApplicationArea = All;
                }
                field(Quantity; rec.Quantity)
                {
                    ApplicationArea = All;

                }


            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Delete record")
            {
                ApplicationArea = Warehouse;
                Caption = 'delete record';
                Ellipsis = true;
                Image = CreateMovement;

                trigger OnAction()
                var
                    WhseWkshLine: Record "Whse. Worksheet Line";
                begin
                    If confirm('Er du helt sikker på at du vil slette') then
                        rec.delete;
                end;
            }
        }

    }
}
