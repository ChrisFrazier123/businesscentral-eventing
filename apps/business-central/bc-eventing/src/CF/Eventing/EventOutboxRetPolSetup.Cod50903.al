namespace CF.Eventing;

using System.DataAdministration;

codeunit 50903 "Event Outbox Ret. Pol. Setup"
{
    Access = Internal;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Reten. Pol. Allowed Tables", OnAfterAddAllowedTables, '', true, true)]
    local procedure AddEventOutboxToAllowedTables()
    var
        RetenPolAllowedTables: Codeunit "Reten. Pol. Allowed Tables";
        EventOutbox: Record "Event Outbox";
    begin
        RetenPolAllowedTables.AddAllowedTable(Database::"Event Outbox", EventOutbox.FieldNo("Event On"));
    end;
}
