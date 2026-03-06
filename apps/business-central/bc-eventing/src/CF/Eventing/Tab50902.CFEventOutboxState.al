namespace CF.Eventing;

table 50902 "CF Event Outbox State"
{
    Caption = 'Event Outbox State';
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
        }

        field(2; Status; Enum "CF Event Status")
        {
            Caption = 'Status';
        }
    }

    keys
    {
        key(PK; "Code")
        {
            Clustered = true;
        }
    }

    procedure SafeGet()
    begin
        Rec.Reset();
        if not Rec.FindFirst() then begin
            Rec.Init();
            Rec.Validate(Status, "CF Event Status"::New);
            Rec.Insert();
        end;
    end;

    procedure SetReady()
    begin
        Rec.LockTable();
        Rec.SafeGet();
        Rec.Validate(Status, "CF Event Status"::Ready);
        Rec.Modify(true);
    end;
}
