namespace CF.Eventing;

codeunit 50901 "Event Worker"
{
    trigger OnRun()
    begin
        Init();
        if not EventingSetup.Enabled then
            exit;

        HandleEvents();
    end;


    procedure Init()
    begin
        if not IsInitialized then begin
            EventingSetup.SafeGet();
            IsInitialized := true;
        end;
    end;


    local procedure HandleEvents()
    var
        Outbox: Record "Event Outbox";
        OutboxState: Record "Event Outbox State";
        Timeout: DateTime;
        Duration: Duration;
        Handled: Boolean;

    begin
        Init();
        if not EventingSetup.Enabled then
            exit;

        OnBeforeHandleEvents(Handled);
        if Handled = true then
            exit;

        Duration := 10 * 60 * 1000;
        Timeout := CurrentDateTime() + Duration;

        Sleep(10 * 1000);
        while CurrentDateTime() <= Timeout do begin
            if Outbox.HasWorkToProcess() then begin
                HandleIteration();
                continue;
            end;

            Sleep(60 * 1000);
            if not Outbox.HasWorkToProcess() then begin
                OutboxState.SetReady();
                exit;
            end;
        end;

        OutboxState.SetReady();
    end;


    local procedure HandleIteration()
    var
        Outbox: Record "Event Outbox";
        JObject: JsonObject;
        JArray: JsonArray;

    begin
        SetBatchToInProcess();

        Outbox.Reset();
        Outbox.SetRange(Status, "Event Status"::"In Process");
        if Outbox.FindSet() then begin
            repeat
                JObject := OutboxToJson(Outbox);
                JArray.Add(JObject);
            until Outbox.Next() = 0;
        end;

        if JArray.Count > 0 then begin
            if SendEvents(JArray) then
                Outbox.ModifyAll(Status, "Event Status"::Completed)
            else
                Outbox.ModifyAll(Status, "Event Status"::Failed);
        end;
    end;


    local procedure SetBatchToInProcess()
    var
        Outbox: Record "Event Outbox";
        i: Integer;
        BatchLimit: Integer;

    begin
        BatchLimit := 20;

        Outbox.Reset();
        Outbox.SetFilter(Status, '%1|%2', "Event Status"::New, "Event Status"::Failed);
        if Outbox.FindSet() then begin
            repeat
                Outbox.Validate(Status, "Event Status"::"In Process");
                Outbox.Modify();
                i += 1;
            until (Outbox.Next() = 0) or (i >= BatchLimit);
        end;
    end;


    local procedure OutboxToJson(Outbox: Record "Event Outbox"): JsonObject
    var
        JObject: JsonObject;
        messageJObject: JsonObject;
        headersJObject: JsonObject;

    begin
        JObject.Add('messageId', Format(Outbox."Message Id"));
        JObject.Add('event', Outbox."Event");
        JObject.Add('version', Outbox.Version);
        JObject.Add('domain', Outbox.Domain);

        messageJObject.Add('systemId', Format(Outbox."System Id"));
        messageJObject.Add('recordId', Format(Outbox."Record Id", 0, 9));
        JObject.Add('message', messageJObject);

        JObject.Add('timestamp', Format(Outbox."Event On", 0, 9));

        headersJObject.Add('environment', Outbox.Environment);
        headersJObject.Add('companyId', Format(Outbox."Company Id"));
        JObject.Add('headers', headersJObject);
        exit(JObject);
    end;


    local procedure SendEvents(JArray: JsonArray): Boolean
    begin
        exit(TrySendEvents(JArray));
    end;


    [TryFunction]
    local procedure TrySendEvents(JArray: JsonArray)
    var
        Client: HttpClient;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        Content: HttpContent;
        Headers: HttpHeaders;
        JText: Text;

    begin
        JArray.WriteTo(JText);
        Content.WriteFrom(JText);
        Content.GetHeaders(Headers);
        Headers.Remove('Content-Type');
        Headers.Add('Content-Type', 'application/json');

        RequestMessage.Method := 'POST';
        RequestMessage.SetRequestUri(EventingSetup."Base URL");
        RequestMessage.Content := Content;

        RequestMessage.GetHeaders(Headers);
        Headers.Add('x-api-key', EventingSetup."API Key");

        Client.Send(RequestMessage, ResponseMessage);

        if not ResponseMessage.IsSuccessStatusCode() then begin
            ResponseMessage.Content.ReadAs(JText);
            Error('Failed to send events. Status: %1\%2', ResponseMessage.HttpStatusCode(), JText);
        end;
    end;


    [IntegrationEvent(false, false)]
    procedure OnBeforeHandleEvents(var Handled: Boolean)
    begin
    end;


    var
        EventingSetup: Record "Eventing Setup";
        IsInitialized: Boolean;
}
