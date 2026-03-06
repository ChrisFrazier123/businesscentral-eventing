namespace CF.Eventing.GeneralLedger;

using CF.Eventing;
using Microsoft.Finance.GeneralLedger.Account;

codeunit 50910 "CF GLAccount Events"
{
    [EventSubscriber(ObjectType::Table, Database::"G/L Account", OnAfterInsertEvent, '', true, true)]
    local procedure LogEventOnAfterInsertEvent(var Rec: Record "G/L Account"; RunTrigger: Boolean)
    var
        EventHandler: Codeunit "CF Event Handler";
    begin
        if Rec.IsTemporary() then
            exit;
        EventHandler.LogEvent('GeneralLedger', "CF Event Type"::Inserted, Rec.SystemId, Rec.RecordId);
    end;

    [EventSubscriber(ObjectType::Table, Database::"G/L Account", OnAfterModifyEvent, '', true, true)]
    local procedure LogEventOnAfterModifyEvent(var Rec: Record "G/L Account"; RunTrigger: Boolean)
    var
        EventHandler: Codeunit "CF Event Handler";
    begin
        if Rec.IsTemporary() then
            exit;
        EventHandler.LogEvent('GeneralLedger', "CF Event Type"::Modified, Rec.SystemId, Rec.RecordId);
    end;

    [EventSubscriber(ObjectType::Table, Database::"G/L Account", OnAfterDeleteEvent, '', true, true)]
    local procedure LogEventOnAfterDeleteEvent(var Rec: Record "G/L Account"; RunTrigger: Boolean)
    var
        EventHandler: Codeunit "CF Event Handler";
    begin
        if Rec.IsTemporary() then
            exit;
        EventHandler.LogEvent('GeneralLedger', "CF Event Type"::Deleted, Rec.SystemId, Rec.RecordId);
    end;

    [EventSubscriber(ObjectType::Table, Database::"G/L Account", OnAfterRenameEvent, '', true, true)]
    local procedure LogEventOnAfterRenameEvent(var Rec: Record "G/L Account"; RunTrigger: Boolean)
    var
        EventHandler: Codeunit "CF Event Handler";
    begin
        if Rec.IsTemporary() then
            exit;
        EventHandler.LogEvent('GeneralLedger', "CF Event Type"::Renamed, Rec.SystemId, Rec.RecordId);
    end;
}
