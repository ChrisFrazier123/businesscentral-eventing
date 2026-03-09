namespace CF.Eventing;

codeunit 50902 "Event Worker Backstop"
{
    trigger OnRun()
    begin
        Code();
    end;

    procedure Code()
    var
        Outbox: Record "Event Outbox";
        OutboxState: Record "Event Outbox State";
        EventWorker: Codeunit "Event Worker";

    begin
        if not Outbox.HasWorkToProcess() then
            exit;

        if not OutboxState.SetInProcess() then
            exit;

        if not EventWorker.Run() then begin
            OutboxState.SetReady();
        end;
    end;
}
