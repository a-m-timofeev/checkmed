# Build stage
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy csproj and restore dependencies
COPY ["DrugInteractionAPI/DrugInteractionAPI.csproj", "DrugInteractionAPI/"]
RUN dotnet restore "DrugInteractionAPI/DrugInteractionAPI.csproj"

# Copy everything else and build
COPY . .
WORKDIR "/src/DrugInteractionAPI"
RUN dotnet build "DrugInteractionAPI.csproj" -c Release -o /app/build

# Publish stage
FROM build AS publish
RUN dotnet publish "DrugInteractionAPI.csproj" -c Release -o /app/publish /p:UseAppHost=false

# Runtime stage
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app
EXPOSE 80
EXPOSE 443

COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "DrugInteractionAPI.dll"]