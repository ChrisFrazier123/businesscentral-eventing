using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using System.Security.Cryptography;
using System.Text;
using System.Text.Json;

namespace bc_eventing;

public class EventIngestion
{
    private readonly ILogger<EventIngestion> _logger;
    private readonly IConfiguration _configuration;

    public EventIngestion(ILogger<EventIngestion> logger, IConfiguration configuration)
    {
        _logger = logger;
        _configuration = configuration;
    }

    [Function("EventIngestion")]
    public async Task<IActionResult> Run(
        [HttpTrigger(AuthorizationLevel.Anonymous, "post")] HttpRequest req)
    {
        var expectedApiKey = _configuration["ApiKey"];
        if (!string.IsNullOrEmpty(expectedApiKey))
        {
            req.Headers.TryGetValue("x-api-key", out var apiKeyValues);
            var apiKey = apiKeyValues.ToString();

            var expectedBytes = Encoding.UTF8.GetBytes(expectedApiKey);
            var actualBytes = Encoding.UTF8.GetBytes(apiKey);
            if (!CryptographicOperations.FixedTimeEquals(expectedBytes, actualBytes))
            {
                _logger.LogWarning("Unauthorized request: missing or invalid x-api-key header.");
                return new UnauthorizedResult();
            }
        }

        using var document = await JsonDocument.ParseAsync(req.Body);
        var root = document.RootElement;

        if (root.ValueKind != JsonValueKind.Array)
        {
            _logger.LogError("Request body is not a JSON array.");
            return new BadRequestObjectResult("Request body must be a JSON array of events.");
        }

        var eventCount = root.GetArrayLength();
        _logger.LogInformation("Received {Count} event(s) from Business Central.", eventCount);

        foreach (var evt in root.EnumerateArray())
        {
            var messageId = evt.TryGetProperty("messageId", out var mid) ? mid.GetString() : "(unknown)";
            var eventName = evt.TryGetProperty("event", out var evtName) ? evtName.GetString() : "(unknown)";
            var domain = evt.TryGetProperty("domain", out var dom) ? dom.GetString() : "(unknown)";
            var timestamp = evt.TryGetProperty("timestamp", out var ts) ? ts.GetString() : "(unknown)";

            _logger.LogInformation(
                "Processing event: messageId={MessageId}, event={Event}, domain={Domain}, timestamp={Timestamp}",
                messageId, eventName, domain, timestamp);
        }

        return new OkResult();
    }
}