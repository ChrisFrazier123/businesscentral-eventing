namespace CF.Eventing;

codeunit 50901 "CF Event Worker"
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
        OutboxState: Record "CF Event Outbox State";
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
            if HasWorkToProcess() then begin
                HandleIteration();
                continue;
            end;

            Sleep(60 * 1000);
            if not HasWorkToProcess() then begin
                OutboxState.SetReady();
                exit;
            end;
        end;

        OutboxState.SetReady();
    end;


    local procedure HasWorkToProcess(): Boolean
    var
        Outbox: Record "CF Event Outbox";

    begin
        Outbox.Reset();
        Outbox.SetFilter(Status, '%1|%2', "CF Event Status"::New, "CF Event Status"::Failed);
        exit(not Outbox.IsEmpty);
    end;


    local procedure HandleIteration()
    var
        Outbox: Record "CF Event Outbox";
        JToken: JsonToken;
        JArray: JsonArray;

    begin
        SetBatchToInProcess();

        Outbox.Reset();
        Outbox.SetRange(Status, "CF Event Status"::"In Process");
        if Outbox.FindSet() then begin
            repeat
                JToken := OutboxToJson(Outbox);
                if JToken.IsObject then begin
                    JArray.Add(JToken);
                end;
            until Outbox.Next() = 0;
        end;

        if JArray.Count > 0 then begin
            if SendEvents(JArray) then
                Outbox.ModifyAll(Status, "CF Event Status"::Completed)
            else
                Outbox.ModifyAll(Status, "CF Event Status"::Failed);
        end;
    end;


    local procedure SetBatchToInProcess()
    var
        Outbox: Record "CF Event Outbox";
        i: Integer;
        BatchLimit: Integer;

    begin
        BatchLimit := 20;

        Outbox.Reset();
        Outbox.SetFilter(Status, '%1|%2', "CF Event Status"::New, "CF Event Status"::Failed);
        if Outbox.FindSet() then begin
            repeat
                Outbox.Validate(Status, "CF Event Status"::"In Process");
                Outbox.Modify();
                i += 1;
            until (Outbox.Next() = 0) or (i >= BatchLimit);
        end;
    end;


    local procedure OutboxToJson(Outbox: Record "CF Event Outbox"): JsonToken
    var
        JObject: JsonObject;
        JToken: JsonToken;
    begin
        JObject.Add('id', Format(Outbox."Message Id"));
        JObject.Add('type', Outbox."Event");
        JObject.Add('version', Outbox.Version);
        JObject.Add('domain', Outbox.Domain);
        JObject.Add('environment', Outbox.Environment);
        JObject.Add('companyId', Format(Outbox."Company Id"));
        JObject.Add('eventOn', Format(Outbox."Event On", 0, 9));
        JObject.Add('systemId', Format(Outbox."System Id"));
        JObject.Add('recordId', Format(Outbox."Record Id", 0, 9));
        JObject.AsToken(JToken);
        exit(JToken);
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
        EventingSetup: Record "CF Eventing Setup";
        IsInitialized: Boolean;
}
