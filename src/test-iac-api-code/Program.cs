using Azure.Identity;
using Azure.Security.KeyVault.Secrets;
using Azure.Storage.Blobs;
using Microsoft.AspNetCore.Mvc;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

// Configure the HTTP request pipeline.
//if (app.Environment.IsDevelopment())
//{
    app.UseSwagger();
    app.UseSwaggerUI();
//}


app.MapGet("/test", async () =>
{
    try
    {
        // Environment variables or configuration setup
        var keyVaultUrl = "https://dev-kv-azureiac-bicep.vault.azure.net/";
        var blobServiceUrl = "https://devstazureiacbicepause.blob.core.windows.net/";


        var kvCredential = new DefaultAzureCredential(new DefaultAzureCredentialOptions()
        {
            ManagedIdentityClientId = "ea926385-1f84-4a19-b794-f97f243ac3ef"
        });

        // Key Vault Client to fetch a secret (e.g., "mySecret")
        var secretClient = new SecretClient(new Uri(keyVaultUrl), kvCredential);
        KeyVaultSecret secret = await secretClient.GetSecretAsync("TestSecret"); 
        var secretValue = secret.Value;


        var saCredential = new DefaultAzureCredential(new DefaultAzureCredentialOptions()
        {
            ManagedIdentityClientId = "b3fd6799-079f-4ba5-8611-6f8b6a77e33e"
        });
        // Storage Account Blob Client to check connectivity
        var blobServiceClient = new BlobServiceClient(new Uri(blobServiceUrl), saCredential);
        var containers = blobServiceClient.GetBlobContainersAsync();
        await foreach (var container in containers)
            // Just listing containers as a basic connectivity check
            Console.WriteLine($"Container: {container.Name}");

        return Results.Ok(new
        {
            SecretValue = secretValue,
            Message = "Connectivity to Key Vault and Storage Account is successful"
        });
    }
    catch (Exception ex)
    {
        return Results.Problem(new ProblemDetails()
        {
            Detail = ex.Message
        });
    }
});


app.Run();