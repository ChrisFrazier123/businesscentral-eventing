namespace CF.Eventing;

codeunit 50900 "CF Event Handler"
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
        EventType: Enum "CF Event Type";
        SystemId: Guid;
        RecordId: RecordId)

    var
        Outbox: Record "CF Event Outbox";
        OutboxState: Record "CF Event Outbox State";
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
        Outbox.Validate(Status, "CF Event Status"::New);
        Outbox.Validate(Environment, '');
        Outbox.Validate("Company Id", CompanyProperty.ID());
        Outbox.Validate("Event On", CurrentDateTime());
        Outbox.Validate("System Id", SystemId);
        Outbox.Validate("Record Id", RecordId);
        Outbox.Insert();

        TryStartWorker();
    end;


    local procedure TryStartWorker()
    var
        OutboxState: Record "CF Event Outbox State";
        Handled: Boolean;

    begin
        OutboxState.LockTable();
        OutboxState.SafeGet();
        if OutboxState.Status = "CF Event Status"::"In Process" then
            exit;

        OutboxState.Validate(Status, "CF Event Status"::"In Process");
        OutboxState.Modify();

        OnBeforeCreateWorkerTask(Handled);
        if Handled then
            exit;

        TaskScheduler.CreateTask(Codeunit::"CF Event Handler", 0, true);
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
        EventingSetup: Record "CF Eventing Setup";
        IsInitialized: Boolean;
}
