namespace CF.Eventing;

page 50901 "Event Outbox"
{
    ApplicationArea = All;
    Caption = 'Event Outbox';
    PageType = List;
    SourceTable = "Event Outbox";
    UsageCategory = Administration;
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Message Id"; Rec."Message Id")
                {
                    ToolTip = 'Specifies the value of the Message Id field.', Comment = '%';
                }

                field("Event"; Rec."Event")
                {
                    ToolTip = 'Specifies the value of the Event field.', Comment = '%';
                }

                field(Status; Rec.Status)
                {
                    ToolTip = 'Specifies the value of the Status field.', Comment = '%';
                }

                field(Version; Rec."Version")
                {
                    ToolTip = 'Specifies the value of the Version field.', Comment = '%';
                }

                field(Domain; Rec.Domain)
                {
                    ToolTip = 'Specifies the value of the Domain field.', Comment = '%';
                }

                field(Environment; Rec.Environment)
                {
                    ToolTip = 'Specifies the value of the Environment field.', Comment = '%';
                }

                field("Company Id"; Rec."Company Id")
                {
                    ToolTip = 'Specifies the value of the Company Id field.', Comment = '%';
                }

                field("Event On"; Rec."Event On")
                {
                    ToolTip = 'Specifies the value of the Event On field.', Comment = '%';
                }

                field("System Id"; Rec."System Id")
                {
                    ToolTip = 'Specifies the value of the System Id field.', Comment = '%';
                }

                field("Record Id"; Rec."Record Id")
                {
                    ToolTip = 'Specifies the value of the Record Id field.', Comment = '%';
                }
            }
        }
    }
}
