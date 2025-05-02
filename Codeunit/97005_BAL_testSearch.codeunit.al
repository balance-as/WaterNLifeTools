
codeunit 97005 "BAL Test Search scanner"
{
    trigger OnRun()
    begin

    end;

    var


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"WHI Whse. Activity Mgmt.", 'OnAfterFilterLookupWhseActivityHeaders', '', true, true)]   //23044920
    local procedure CodeunitWHIWhseActivityMgmtOnAfterFilterLookupWhseActivityHeaders(var pbOnlyAssignedDocs: Boolean; var pcodUser: Code[50]; var precWhseActivityHeader: Record "Warehouse Activity Header"; var psFilter: Text)
    begin
        //searchActivityDocuments
        //if confirm(StrSubstNo('bbtester filter %1 %2 ', psfilter, precWhseActivityHeader.count)) then;
        exit;
        if psFilter = '' then
            exit;
        precWhseActivityHeader.findlast;
        if confirm(format(precWhseActivityHeader) + ' ## ' + precWhseActivityHeader.getfilters) then;
        precWhseActivityHeader.setrange("no.", psFilter);
        precWhseActivityHeader.findset;
        if precWhseActivityHeader.IsEmpty then begin
            precWhseActivityHeader.setrange("No.");
            precWhseActivityHeader.setrange("Sell-to Customer Name", psFilter);
            //  if confirm('bbtester ') then;
            if precWhseActivityHeader.IsEmpty then begin
                precWhseActivityHeader.setrange("Sell-to Customer Name");
                precWhseActivityHeader.setrange("Source No.", psFilter);

            end;

        end;
    end;
}