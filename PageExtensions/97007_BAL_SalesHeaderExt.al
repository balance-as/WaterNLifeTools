pageextension 97007 "BAL Sales Header Ext." extends "Sales Order"
{
    layout
    {
        addafter(Status)
        {
            field("BAL Pick Exist"; rec."BAL Pick Exist")
            {
                ApplicationArea = all;
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }

}