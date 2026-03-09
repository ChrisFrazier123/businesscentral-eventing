permissionset 50901 "Eventing - Read"
{
    Assignable = true;
    Caption = 'Eventing - Read';

    Permissions =
        tabledata "Event Outbox" = R,
        tabledata "Event Outbox State" = R,
        tabledata "Eventing Setup" = R;
}
