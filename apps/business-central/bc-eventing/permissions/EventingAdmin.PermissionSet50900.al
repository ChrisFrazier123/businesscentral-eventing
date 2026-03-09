permissionset 50900 "Eventing - Admin"
{
    Assignable = true;
    Caption = 'Eventing - Admin';

    Permissions =
        tabledata "Event Outbox" = RIMD,
        tabledata "Event Outbox State" = RIMD,
        tabledata "Eventing Setup" = RIM;
}
