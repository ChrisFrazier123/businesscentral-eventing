namespace CF.Eventing;

enum 50901 "Event Type"
{
    value(1; Inserted)
    {
        Caption = 'Inserted';
    }

    value(2; Modified)
    {
        Caption = 'Modified';
    }

    value(3; Deleted)
    {
        Caption = 'Deleted';
    }

    value(4; Renamed)
    {
        Caption = 'Renamed';
    }
}
