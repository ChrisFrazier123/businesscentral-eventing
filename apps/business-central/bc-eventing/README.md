# bc-eventing

Outbox-pattern eventing integration for Microsoft Dynamics 365 Business Central.

## Purpose

This extension captures record-level domain events (insert, modify, delete, rename) for configured Business Central tables and reliably publishes them to an external event hub. It implements the [transactional outbox pattern](https://microservices.io/patterns/data/transactional-outbox.html) to ensure events are never lost even if the downstream system is temporarily unavailable.

## Architecture

```
Business Central Table Trigger
        │
        ▼
CF Event Handler (Codeunit 50900)
  • Writes event to CF Event Outbox (Table 50901)
  • Schedules CF Event Worker task if not already running
        │
        ▼
CF Event Worker (Codeunit 50901)  ← background task
  • Processes outbox records in batches of 20
  • Serialises each record to JSON
  • POSTs the batch to the configured Base URL
  • Marks records Completed or Failed accordingly
  • Runs for up to 10 minutes, then exits cleanly
```

### Key Objects

| Object | Type | Purpose |
| --- | --- | --- |
| CF Eventing Setup (50900) | Table / Page | Stores the Enabled flag, Base URL, and API Key |
| CF Event Outbox (50901) | Table / Page | Outbox log of all pending and processed events |
| CF Event Outbox State (50902) | Table | Singleton that tracks whether the worker is currently running |
| CF Event Handler (50900) | Codeunit | Public API — call `LogEvent` to record an event |
| CF Event Worker (50901) | Codeunit | Background processor — scheduled via `TaskScheduler` |
| CF Event Status (50900) | Enum | New → In Process → Completed / Failed / Ready |
| CF Event Type (50901) | Enum | Inserted, Modified, Deleted, Renamed |
| CF GLAccount Events (50910) | Codeunit | Example subscriber — logs G/L Account changes |

## Configuration

1. Open the **Eventing Setup** page (search "Eventing Setup" in Business Central).
2. Toggle **Enabled** to activate event capture.
3. Enter the **Base URL** of your event hub endpoint.
4. Enter the **API Key** used to authenticate requests (`x-api-key` header).

## Extending

To capture events for additional tables, create a new codeunit in `src/CF/Eventing/<Domain>/` that subscribes to the relevant table triggers and calls `CF Event Handler.LogEvent`:

```al
using CF.Eventing;

codeunit 5XXXX "CF <Domain> Events"
{
    [EventSubscriber(ObjectType::Table, Database::"<Table>", OnAfterInsertEvent, '', true, true)]
    local procedure LogEventOnAfterInsertEvent(var Rec: Record "<Table>"; RunTrigger: Boolean)
    var
        EventHandler: Codeunit "CF Event Handler";
    begin
        if Rec.IsTemporary() then
            exit;
        EventHandler.LogEvent('<Domain>', "CF Event Type"::Inserted, Rec.SystemId, Rec.RecordId);
    end;
}
```

## HTTP Payload

Events are sent as a JSON array. Each element represents one outbox record:

```json
[
  {
    "id": "<message-guid>",
    "type": "BC.<Domain>:<EventType>",
    "version": "v1",
    "domain": "<Domain>",
    "environment": "<environment-name>",
    "companyId": "<company-guid>",
    "eventOn": "2024-01-01T12:00:00Z",
    "systemId": "<record-system-id>",
    "recordId": "<record-id>"
  }
]
```

## Development

See [Way We Work](documentation/w3w.md) for repository conventions, file naming standards, and recommended VS Code extensions.
