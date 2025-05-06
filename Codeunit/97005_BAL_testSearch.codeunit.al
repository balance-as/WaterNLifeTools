
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
        precWhseActivityHeader.findlast;
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
                until precWhseActivityHeader.next = 0;

            psFilter := FilterTxt;
        end;
    end;
}
