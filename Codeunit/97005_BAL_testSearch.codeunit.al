
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
        if not precWhseActivityHeader.IsEmpty or (psFilter = '') then
            exit;
        precWhseActivityHeader.setrange("No.");
        precWhseActivityHeader.setrange("Sell-to Customer Name", '*%1*', psFilter);
        if precWhseActivityHeader.IsEmpty then begin
            precWhseActivityHeader.setrange("Sell-to Customer Name");
            precWhseActivityHeader.setrange("Source No.", '*%1*', psFilter);
        end;
        
    end;
}