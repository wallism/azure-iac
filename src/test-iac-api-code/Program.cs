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

    var credentialOptions = new DefaultAzureCredentialOptions
    {

        //TenantId = "645b8bfb-fa88-4e2c-9b71-af49f9e4d6fe",
        //ManagedIdentityClientId = "aeb8d4de-6a7b-4c68-8a52-d0249706f251",
        ExcludeVisualStudioCredential = true,
        ExcludeAzureCliCredential = true // this is where it picks up my personal email
    };
    var credential = new DefaultAzureCredential(credentialOptions);

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