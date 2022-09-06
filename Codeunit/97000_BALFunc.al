codeunit 97000 "BAL Func"
{
    trigger OnRun()
    var
        cu: Codeunit 7312;
        FromBinContent: Record "Bin Content";
    begin
        //cu.OnFindBWPickBinOnBeforeFromBinContentFindSet(FromBinContent, SourceType, TotalQtyPickedBase, TotalQtyToPickBase, IsHandled);)
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Pick", 'OnFindBWPickBinOnBeforeFromBinContentFindSet', '', true, true)]
    local procedure SetBinRanking(var FromBinContent: Record "Bin Content")
    begin
        FromBinContent.setfilter("Bin Ranking", '<>%1', 99);
    end;

}