#See https://aka.ms/customizecontainer to learn how to customize your debug container and how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base

ENV AZURE_TENANT_ID=645b8bfb-fa88-4e2c-9b71-af49f9e4d6fe
ENV AZURE_CLIENT_ID=7af1e512-a942-4568-95f2-bdce7d7c9747
ENV AZURE_CLIENT_SECRET=Ie-8Q~ZqLHBOIAKOHiNiDwWBZly4KkFepa


USER app
WORKDIR /app
EXPOSE 8080

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src
COPY ["test-iac-api-container/test-iac-api-container.csproj", "test-iac-api-container/"]
RUN dotnet restore "./test-iac-api-container/test-iac-api-container.csproj"
COPY . .
WORKDIR "/src/test-iac-api-container"
RUN dotnet build "./test-iac-api-container.csproj" -c $BUILD_CONFIGURATION -o /app/build

FROM build AS publish
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish "./test-iac-api-container.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "test-iac-api-container.dll"]