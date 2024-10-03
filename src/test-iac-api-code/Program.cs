using Azure.Identity;
using Azure.Security.KeyVault.Secrets;
using Azure.Storage.Blobs;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}


app.MapGet("/test", async () =>
{
    // Environment variables or configuration setup
    var keyVaultUrl = "https://dev-kv-azureiac-bicep.vault.azure.net/";
    var blobServiceUrl = "https://devstazureiacbicepause.blob.core.windows.net/";

    // note: the only reason for these GetEnvironmentVariable's is to verify manually, that the values are being picked up.
    var id = Environment.GetEnvironmentVariable("AZURE_CLIENT_ID");
    var clientSecret = Environment.GetEnvironmentVariable("AZURE_CLIENT_SECRET"); 
    var tenantId = Environment.GetEnvironmentVariable("AZURE_TENANT_ID");

    var credential = new DefaultAzureCredential();

    // Key Vault Client to fetch a secret (e.g., "mySecret")
    var secretClient = new SecretClient(new Uri(keyVaultUrl), credential);
    KeyVaultSecret secret = await secretClient.GetSecretAsync("TestSecret");
    var secretValue = secret.Value;

    // Storage Account Blob Client to check connectivity
    var blobServiceClient = new BlobServiceClient(new Uri(blobServiceUrl), credential);
    var containers = blobServiceClient.GetBlobContainersAsync();
    await foreach (var container in containers)
        // Just listing containers as a basic connectivity check
        Console.WriteLine($"Container: {container.Name}");

    return Results.Ok(new
    {
        SecretValue = secretValue,
        Message = "Connectivity to Key Vault and Storage Account is successful"
    });
});


app.Run();