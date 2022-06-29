permissionset 97000 "All"
{
    Access = Internal;
    Assignable = true;
    Caption = 'All permissions', Locked = true;

    Permissions =
         codeunit "BAL Func" = X,
         codeunit "BAL InsightFunc WNL" = X,
         page "BAL WaterNlife Setup Card" = X,
         report "BAL WaterNLife Item Label" = X,
         table "BAL WaterNlife Setup" = X,
         tabledata "BAL WaterNlife Setup" = RIMD;
}