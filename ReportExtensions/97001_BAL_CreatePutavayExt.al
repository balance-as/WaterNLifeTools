reportextension 97001 "BAL Create Invt Put Sxt" extends "Create Invt Put-away/Pick/Mvmt"
{
    dataset
    {
        modify("Warehouse Request")
        {
            RequestFilterFields = "Shipping Agent Code";
            trigger OnBeforePreDataItem()
            var
                ConfirmTxt: Label 'Do You want to continue without filter on %1?';
                ErrorTxt: Label 'Report stopped!\Please Add filter for %1!';
            begin

                if getfilter("Source Document") = format("Source Document"::"Sales Order") then
                    if getfilter("Shipping Agent Code") = '' then
                        if not confirm(StrSubstNo(ConfirmTxt, FieldCaption("Shipping Agent Code")), false) then
                            error(ErrorTxt, FieldCaption("Shipping Agent Code"));

            end;
        }
    }

}