FROM mcr.microsoft.com/dotnet/sdk:9.0-alpine AS build
WORKDIR /src

# Copy solution and project files for better layer caching
COPY konecta_erp.sln ./
COPY backend/SharedContracts/SharedContracts.csproj backend/SharedContracts/
COPY backend/UserManagementService/UserManagementService.csproj backend/UserManagementService/

# Restore dependencies
RUN dotnet restore backend/UserManagementService/UserManagementService.csproj --no-cache

# Copy source code
COPY backend ./backend

# Publish with optimizations
RUN dotnet publish backend/UserManagementService/UserManagementService.csproj \
    -c Release \
    -o /app/publish \
    --no-restore

# Runtime stage with alpine for smaller image
FROM mcr.microsoft.com/dotnet/aspnet:9.0-alpine AS final
WORKDIR /app

# Install ICU libraries required for .NET globalization
RUN apk add --no-cache icu-libs icu-data-full

# Create non-root user for security
RUN addgroup -g 1000 appuser && \
    adduser -D -u 1000 -G appuser appuser

ENV ASPNETCORE_URLS=http://+:5078 \
    DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=false

# Copy published app
COPY --from=build /app/publish .

# Change ownership to non-root user
RUN chown -R appuser:appuser /app

USER appuser

ENTRYPOINT ["dotnet", "UserManagementService.dll"]
