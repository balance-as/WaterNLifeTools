
codeunit 97005 "BAL Test Search scanner"
{
    trigger OnRun()
    begin

    end;

    var


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"WHI Whse. Activity Mgmt.", 'OnAfterFilterLookupWhseActivityHeaders', '', true, true)]   //23044920
    local procedure CodeunitWHIWhseActivityMgmtOnAfterFilterLookupWhseActivityHeaders(var pbOnlyAssignedDocs: Boolean; var pcodUser: Code[50]; var precWhseActivityHeader: Record "Warehouse Activity Header"; var psFilter: Text)
    var
        FilterTxt: Text;
    begin
        if psFilter = '' then
            exit;
        precWhseActivityHeader.setfilter("no.", psFilter);
        if precWhseActivityHeader.IsEmpty then begin
            precWhseActivityHeader.setrange("No.");
            precWhseActivityHeader.setfilter("Sell-to Customer Name", '@' + psFilter);
            if precWhseActivityHeader.findset then
                repeat
                    if FilterTxt = '' then
                        FilterTxt := precWhseActivityHeader."No."
                    else
                        FilterTxt += '|' + precWhseActivityHeader."No.";
                until precWhseActivityHeader.next = 0
            else begin
                precWhseActivityHeader.setrange("Sell-to Customer Name");
                precWhseActivityHeader.setfilter("BAL Shopify No", '@' + psFilter);
                if precWhseActivityHeader.findset then
                    repeat
                        if FilterTxt = '' then
                            FilterTxt := precWhseActivityHeader."No."
                        else
                            FilterTxt += '|' + precWhseActivityHeader."No.";
                    until precWhseActivityHeader.next = 0
            end;
            psFilter := FilterTxt;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"BAL InsightFunc WNL", 'OnAfterFilterLookupWhseActivityHeaders', '', true, true)]   //23044920
    local procedure CodeunitBALInsightFuncWNLOnAfterFilterLookupWhseActivityHeaders(var pbOnlyAssignedDocs: Boolean; var pcodUser: Code[50]; var precWhseActivityHeader: Record "Warehouse Activity Header"; var psFilter: Text)
    var
        FilterTxt: Text;
    begin
        if psFilter = '' then
            exit;
        precWhseActivityHeader.setfilter("no.", psFilter);
        if precWhseActivityHeader.IsEmpty then begin
            precWhseActivityHeader.setrange("No.");
            precWhseActivityHeader.setfilter("Sell-to Customer Name", '@' + psFilter);
            if precWhseActivityHeader.findset then
                repeat
                    if FilterTxt = '' then
                        FilterTxt := precWhseActivityHeader."No."
                    else
                        FilterTxt += '|' + precWhseActivityHeader."No.";
                until precWhseActivityHeader.next = 0
            else begin
                precWhseActivityHeader.setrange("Sell-to Customer Name");
                precWhseActivityHeader.setfilter("BAL Shopify No", '@' + psFilter);
                if precWhseActivityHeader.findset then
                    repeat
                        if FilterTxt = '' then
                            FilterTxt := precWhseActivityHeader."No."
                        else
                            FilterTxt += '|' + precWhseActivityHeader."No.";
                    until precWhseActivityHeader.next = 0
            end;
            psFilter := FilterTxt;
        end;
    end;
}
