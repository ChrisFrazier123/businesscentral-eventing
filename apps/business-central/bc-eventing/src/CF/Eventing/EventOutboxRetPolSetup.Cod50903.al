namespace CF.Eventing;

using System.DataAdministration;

codeunit 50903 "Event Outbox Ret. Pol. Setup"
{
    Access = Internal;
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    var
        EventOutbox: Record "Event Outbox";
        RetenPolAllowedTables: Codeunit "Reten. Pol. Allowed Tables";
        RecRef: RecordRef;
        TableFilters: JsonArray;
        Enabled: Boolean;
        Mandatory: Boolean;

    begin
        EventOutbox.Reset();
        EventOutbox.SetRange(Status, "Event Status"::Completed);
        RecRef.GetTable(EventOutbox);
        Enabled := true;
        Mandatory := false;

        RetenPolAllowedTables.AddTableFilterToJsonArray(
            TableFilters,
            "Retention Period Enum"::"Never Delete",
            EventOutbox.FieldNo("Event On"),
            Enabled,
            Mandatory,
            RecRef);

        RetenPolAllowedTables.AddAllowedTable(
            Database::"Event Outbox",
            EventOutbox.FieldNo("Event On"),
            TableFilters);
    end;
}
