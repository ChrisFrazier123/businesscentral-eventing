namespace CF.Eventing;

codeunit 50900 "Event Handler"
{
    procedure Init()
    begin
        if not IsInitialized then begin
            EventingSetup.SafeGet();
            IsInitialized := true;
        end;
    end;


    procedure LogEvent(
        Domain: Text[50];
        EventType: Enum "Event Type";
        SystemId: Guid;
        RecordId: RecordId)

    var
        Outbox: Record "Event Outbox";
        Handled: Boolean;

    begin
        Init();
        if not EventingSetup.Enabled then
            exit;

        OnBeforeLogEvent(Handled);
        if Handled = true then
            exit;

        Outbox.Init();
        Outbox.Validate("Message Id", CreateGuid());
        Outbox.Validate(Domain, Domain);
        Outbox.Validate("Event", StrSubstNo('BC.%1:%2', Domain, Format(EventType)));
        Outbox.Validate(Version, 'v1');
        Outbox.Validate(Status, "Event Status"::New);
        Outbox.Validate(Environment, '');
        Outbox.Validate("Company Id", CompanyProperty.ID());
        Outbox.Validate("Event On", CurrentDateTime());
        Outbox.Validate("System Id", SystemId);
        Outbox.Validate("Record Id", RecordId);
        Outbox.Insert();

        TryStartWorker();
    end;


    procedure TryStartWorker()
    var
        Outbox: Record "Event Outbox";
        OutboxState: Record "Event Outbox State";
        Handled: Boolean;

    begin
        Init();
        if not Outbox.HasWorkToProcess() then
            exit;

        if not OutboxState.SetInProcess() then
            exit;

        OnBeforeCreateWorkerTask(Handled);
        if Handled then
            exit;

        TaskScheduler.CreateTask(Codeunit::"Event Worker", 0, true);
    end;


    local procedure HasWork(): Boolean
    begin

    end;


    [IntegrationEvent(false, false)]
    procedure OnBeforeLogEvent(var Handled: Boolean)
    begin
    end;


    [IntegrationEvent(false, false)]
    procedure OnBeforeCreateWorkerTask(var Handled: Boolean)
    begin
    end;


    var
        EventingSetup: Record "Eventing Setup";
        IsInitialized: Boolean;
}
