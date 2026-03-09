namespace CF.Eventing;

table 50901 "Event Outbox"
{
    Caption = 'Event Outbox';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Message Id"; Guid)
        {
            Caption = 'Message Id';
        }

        field(2; "Event"; Text[100])
        {
            Caption = 'Event';
        }

        field(3; Version; Text[10])
        {
            Caption = 'Version';
        }

        field(4; Domain; Text[50])
        {
            Caption = 'Domain';
        }

        field(10; Status; Enum "Event Status")
        {
            Caption = 'Status';
        }

        field(20; Environment; Text[20])
        {
            Caption = 'Environment';
        }

        field(21; "Company Id"; Guid)
        {
            Caption = 'Company Id';
        }

        field(30; "Event On"; DateTime)
        {
            Caption = 'Event On';
        }

        field(40; "System Id"; Guid)
        {
            Caption = 'System Id';
        }

        field(50; "Message"; Blob)
        {
            Caption = 'Message';
        }
    }

    keys
    {
        key(PK; "Message Id")
        {
            Clustered = true;
        }

        key(EventOn; "Event On", "Message Id")
        {

        }
    }

    procedure HasWorkToProcess(): Boolean
    begin
        Rec.Reset();
        Rec.SetFilter(Status, '%1|%2', "Event Status"::New, "Event Status"::Failed);
        exit(not Rec.IsEmpty);
    end;
}
