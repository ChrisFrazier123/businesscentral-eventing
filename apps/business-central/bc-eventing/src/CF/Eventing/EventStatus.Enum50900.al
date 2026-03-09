namespace CF.Eventing;

enum 50900 "Event Status"
{

    value(0; New)
    {
        Caption = 'New';
    }

    value(1; Ready)
    {
        Caption = 'Ready';
    }

    value(2; "In Process")
    {
        Caption = 'In Process';
    }

    value(3; Failed)
    {
        Caption = 'Failed';
    }

    value(4; Completed)
    {
        Caption = 'Completed';
    }
}
