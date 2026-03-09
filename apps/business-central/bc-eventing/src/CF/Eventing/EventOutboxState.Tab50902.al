namespace CF.Eventing;

table 50902 "Event Outbox State"
{
    Caption = 'Event Outbox State';
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
        }

        field(2; Status; Enum "Event Status")
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
            Rec.Validate(Status, "Event Status"::New);
            Rec.Insert();
        end;
    end;


    procedure SetInProcess(): Boolean
    begin
        Rec.LockTable();
        Rec.SafeGet();
        if Rec.Status = "Event Status"::"In Process" then
            exit(false);

        Rec.Validate(Status, "Event Status"::"In Process");
        Rec.Modify();
        exit(true);
    end;


    procedure SetReady()
    begin
        Rec.LockTable();
        Rec.SafeGet();
        Rec.Validate(Status, "Event Status"::Ready);
        Rec.Modify();
    end;
}
