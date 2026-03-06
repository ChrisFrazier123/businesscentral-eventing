namespace CF.Eventing.GeneralLedger;

using Microsoft.Finance.GeneralLedger.Account;

codeunit 50910 "CF GLAccount Events"
{
    [EventSubscriber(ObjectType::Table, Database::"G/L Account", OnAfterInsertEvent, '', true, true)]
    local procedure LogEventOnAfterInsertEvent(var Rec: Record "G/L Account"; RunTrigger: Boolean)
    begin

    end;

    [EventSubscriber(ObjectType::Table, Database::"G/L Account", OnAfterModifyEvent, '', true, true)]
    local procedure LogEventOnAfterModifyEvent(var Rec: Record "G/L Account"; RunTrigger: Boolean)
    begin

    end;

    [EventSubscriber(ObjectType::Table, Database::"G/L Account", OnAfterDeleteEvent, '', true, true)]
    local procedure LogEventOnAfterDeleteEvent(var Rec: Record "G/L Account"; RunTrigger: Boolean)
    begin

    end;

    [EventSubscriber(ObjectType::Table, Database::"G/L Account", OnAfterRenameEvent, '', true, true)]
    local procedure LogEventOnAfterRenameEvent(var Rec: Record "G/L Account"; RunTrigger: Boolean)
    begin

    end;
}
