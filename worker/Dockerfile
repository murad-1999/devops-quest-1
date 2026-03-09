# Stage 1: Build the application
FROM mcr.microsoft.com/dotnet/sdk:7.0 AS build
WORKDIR /src

# Copy project file and restore dependencies
COPY Worker.csproj .
RUN dotnet restore

# Copy source and publish
COPY . .
RUN dotnet publish -c Release -o /app --no-restore

# Stage 2: Runtime image
FROM mcr.microsoft.com/dotnet/runtime:7.0 AS runtime
WORKDIR /app

# Copy the published output from the build stage
COPY --from=build /app .

# Start the worker
CMD ["dotnet", "Worker.dll"]