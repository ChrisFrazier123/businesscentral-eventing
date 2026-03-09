codeunit 50902 "CF Event Worker Backstop"
{
    // This codeunit is intended to be scheduled via Job Queue as a backstop.
    // It ensures that events in the CF Event Outbox are processed with proper locking mechanisms.

    var
        EventingSetup: Record "CF Eventing Setup";
        EventOutbox: Record "CF Event Outbox";

    procedure Run()
    var
        IsEnabled: Boolean;
    begin
        // Load CF Eventing Setup via SafeGet and exit if not Enabled
        IsEnabled := EventingSetup.SafeGet();
        if not IsEnabled then
            exit;

        // Check CF Event Outbox for any records with Status New or Failed
        if not EventOutbox.HasNewOrFailed() then
            exit;

        // Lock CF Event Outbox State, SafeGet it, exit if Status is In Process
        EventOutbox.Lock();
        if EventOutbox.Status = EventOutbox.Status::InProcess then
            exit;

        // Set Status to In Process and modify
        EventOutbox.Status := EventOutbox.Status::InProcess;
        EventOutbox.Modify();

        // Start the worker via TaskScheduler
        TaskScheduler.CreateTask(Codeunit::"CF Event Worker", 0, true);
    end;
}