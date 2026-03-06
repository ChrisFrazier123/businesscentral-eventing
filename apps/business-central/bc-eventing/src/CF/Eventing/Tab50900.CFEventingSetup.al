namespace CF.Eventing;

table 50900 "CF Eventing Setup"
{
    Caption = 'CF Eventing Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
        }

        field(2; Enabled; Boolean)
        {
            Caption = 'Enabled';
        }

        field(3; "Base URL"; Text[250])
        {
            Caption = 'Base URL';
            ExtendedDatatype = URL;
        }

        field(4; "API Key"; Text[250])
        {
            Caption = 'API Key';
            ExtendedDatatype = Masked;
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }

    procedure SafeGet()
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
    end;
}
