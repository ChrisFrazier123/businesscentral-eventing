namespace CF.Eventing;

page 50900 "Eventing Setup"
{
    Caption = 'Eventing Setup';
    PageType = Card;
    SourceTable = "Eventing Setup";
    DeleteAllowed = false;
    InsertAllowed = false;
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';

                field(Enabled; Rec.Enabled)
                {
                    ToolTip = 'Enable or disable the integration with the Event Hub';
                }

                group("API Settings")
                {
                    Caption = 'API Settings';

                    field("Base URL"; Rec."Base URL")
                    {
                        ToolTip = 'The base URL of the API';
                        ExtendedDatatype = URL;
                    }

                    field("API Key"; Rec."API Key")
                    {
                        ToolTip = 'The API key to authenticate with the API';
                    }
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(EventLogs)
            {
                ApplicationArea = All;
                Caption = 'Event Logs';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                Image = Log;
                ToolTip = 'Event Logs';
                RunObject = page "Event Outbox";
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
    end;
}