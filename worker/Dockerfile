# Stage 1: Build the application
FROM mcr.microsoft.com/dotnet/sdk:8.0-alpine AS build
WORKDIR /src

# Copy project file and restore dependencies
COPY Worker.csproj .
RUN dotnet restore

# Copy source and publish
COPY . .
RUN dotnet publish -c Release -o /app --no-restore

# Stage 2: Runtime image
FROM mcr.microsoft.com/dotnet/runtime:8.0-alpine AS runtime
WORKDIR /app

# Copy the published output from the build stage
COPY --from=build /app .

# Upgrade system packages implicitly to patch any 0-day CVEs
RUN apk upgrade --no-cache

# Start the worker
CMD ["dotnet", "Worker.dll"]