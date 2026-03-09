namespace CF.Eventing;

using System.Utilities;

page 50902 "Json Viewer Factbox"
{
    PageType = CardPart;
    Caption = 'Json Viewer';
    UsageCategory = None;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            field("Query Direction"; QueryDirection)
            {
                OptionCaption = 'Request,Response';
                Caption = 'Query Direction';
                ToolTip = 'Choose Query Direction';
            }

            usercontrol(JsonViewer; JsonViewer)
            {
                ApplicationArea = All;
                trigger OnControlAddInReady()
                begin
                    InitializeJsonViewer();
                end;

                trigger OnJsonViewerReady()
                begin
                    IsInitialized := true;
                    ShowData();
                end;
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Request)
            {
                Visible = ShowQueryDirection;
                ApplicationArea = All;
                Image = BreakRulesOn;
                Enabled = QueryDirection = QueryDirection::Response;

                Caption = 'Request';
                ToolTip = 'Request';
                trigger OnAction()
                begin
                    QueryDirection := QueryDirection::Request;
                    ShowData();
                end;
            }

            action(Response)
            {
                Visible = ShowQueryDirection;
                ApplicationArea = All;
                Image = BreakRulesOff;
                Enabled = QueryDirection = QueryDirection::Request;

                Caption = 'Response';
                ToolTip = 'Response';
                trigger OnAction()
                begin
                    QueryDirection := QueryDirection::Response;
                    ShowData();
                end;
            }

            action(Download)
            {
                ApplicationArea = All;
                Image = Download;
                Caption = 'Download content file';

                trigger OnAction()
                var
                    tempBlob: Codeunit "Temp Blob";
                    fileName: Text;
                    oStream: OutStream;
                    iStream: InStream;

                begin
                    tempBlob.CreateOutStream(oStream);
                    if QueryDirection = QueryDirection::Request then begin
                        fileName := 'requestcontent_' + Format(CurrentDateTime, 0, 9) + '.json';
                        JObjectRequest.WriteTo(oStream)
                    end else begin
                        fileName := 'responsecontent_' + Format(CurrentDateTime, 0, 9) + '.json';
                        JObjectResponse.WriteTo(oStream);
                    end;
                    tempBlob.CreateInStream(iStream);
                    File.DownloadFromStream(IStream, '', '', '', FileName);
                end;

            }
        }
    }

    var
        ShowQueryDirection: Boolean;
        QueryDirection: Option Request,Response;
        IsInitialized: Boolean;
        JObjectRequest: JsonObject;
        JObjectResponse: JsonObject;

    local procedure InitializeJsonViewer()
    begin
        CurrPage.JsonViewer.InitializeControl();
    end;

    local procedure ShowData()
    begin
        if not IsInitialized then
            exit;

        //json: json Input value
        //maxLvl: Process only to max level, where 0..n, -1 unlimited
        //colAt: Collapse at level, where 0..n, -1 unlimited

        if QueryDirection = QueryDirection::Request then
            CurrPage.JsonViewer.LoadDocument(JObjectRequest, -1, -1)
        else
            CurrPage.JsonViewer.LoadDocument(JObjectResponse, -1, -1);
    end;

    procedure SetContent(lIStreamRequest: InStream; lIStreamResponse: InStream)
    begin
        if not JObjectRequest.ReadFrom(lIStreamRequest) then
            Clear(JObjectRequest);

        if not JObjectResponse.ReadFrom(lIStreamResponse) then
            Clear(JObjectResponse);

        ShowQueryDirection := true;
        ShowData();
    end;

    procedure SetRequestContent(lIStream: InStream)
    begin
        if not JObjectRequest.ReadFrom(lIStream) then
            Clear(JObjectRequest);

        ShowData();
    end;

    procedure SetResponseContent(lIStream: InStream)
    begin
        if not JObjectResponse.ReadFrom(lIStream) then
            Clear(JObjectResponse);

        ShowData();
    end;
}
