codeunit 97004 "BAL Report Events"
{
    //BAL1.01/WaterNLifeTools/14022024/AR  : Created

    //BAL1.01/START
    //BAL1.01/STOP

    [EventSubscriber(ObjectType::Report, Report::"Create Invt Put-away/Pick/Mvmt", 'OnBeforeCheckWhseRequest', '', true, true)]
    local procedure MyProcedure(var WarehouseRequest: Record "Warehouse Request"; ShowError: Boolean; var IsHandled: Boolean; var SkipRecord: Boolean)
    var
        SalesHeader: Record "Sales Header";
        VATBusinessPostingGroup: Record "VAT Business Posting Group";
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        CalcAmount: Decimal;
        ErrorWrongVATGrp: Label 'VAT Business Posting Group may only be used for value of max. %1 %2, %3 %4 is of %1 %5';
    begin

        if WarehouseRequest."Source Document" = WarehouseRequest."Source Document"::"Sales Order" then
            if SalesHeader.Get(SalesHeader."Document Type"::Order, WarehouseRequest."Source No.") then
                if VATBusinessPostingGroup.Get(SalesHeader."VAT Bus. Posting Group") and (VATBusinessPostingGroup."BAL Max. Amount in Currency" > 0) then begin
                    VATBusinessPostingGroup.TestField("BAL Max. Amount in Currency");
                    SalesHeader.CalcFields(Amount, "Amount Including VAT");
                    CalcAmount := SalesHeader.Amount;
                    if SalesHeader."Currency Code" <> VATBusinessPostingGroup."BAL Currency Code" then
                        if SalesHeader."Currency Code" = '' then
                            CalcAmount := CurrencyExchangeRate.ExchangeAmtLCYToFCY(WorkDate(), VATBusinessPostingGroup."BAL Currency Code", CalcAmount, CurrencyExchangeRate.ExchangeRate(WorkDate(), VATBusinessPostingGroup."BAL Currency Code"))
                        else
                            CalcAmount := CurrencyExchangeRate.ExchangeAmtFCYToFCY(WorkDate(), SalesHeader."Currency Code", VATBusinessPostingGroup."BAL Currency Code", CalcAmount);

                    if CalcAmount > VATBusinessPostingGroup."BAL Max. Amount in Currency" then
                        if ShowError then
                            Error(StrSubstNo(ErrorWrongVATGrp, VATBusinessPostingGroup."BAL Currency Code", VATBusinessPostingGroup."BAL Max. Amount in Currency", SalesHeader."Document Type", SalesHeader."No.", Round(CalcAmount)))
                        else begin
                            IsHandled := true;
                            SkipRecord := true;
                        end;
                end;
    end;
}