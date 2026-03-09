trigger OnRun() begin
    var
        EventingSetup: Record "CF Eventing Setup";
        EventOutbox: Record "CF Event Outbox";
    begin
        if not EventingSetup.SafeGet().Enabled then
            exit;

        // Check for New or Failed Events
        if EventOutbox.FindSet() then begin
            repeat
                // Lock for processing
                if EventOutbox.State = EventOutbox.State::"In Process" then
                    exit;
                EventOutbox.Modify(true);
                EventOutbox.State := EventOutbox.State::"In Process";

                // Run the CF Event Worker
                Codeunit::"CF Event Worker";
            until EventOutbox.Next() = 0;
        end;
    end;