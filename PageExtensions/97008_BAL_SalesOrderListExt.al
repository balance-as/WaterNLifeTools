pageextension 97008 "BAL Sales Headerlist Ext." extends "Sales Order List"
{
    layout
    {
        addafter("Sell-to Customer No.")
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