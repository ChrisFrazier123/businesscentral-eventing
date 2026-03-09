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
        RecRef: RecordRef;
    begin
        EventOutbox.SetRange(Status, "Event Status"::Completed);
        RecRef.GetTable(EventOutbox);
        RetenPolAllowedTables.AddAllowedTable(Database::"Event Outbox", EventOutbox.FieldNo("Event On"), Enum::"Retention Period Enum"::"Never Delete", false, RecRef.GetView());
    end;
}
