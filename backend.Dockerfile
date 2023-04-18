FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /source

COPY Core.Backend/*.csproj ./Core.Backend/
COPY Core.AuthLib/*.csproj ./Core.AuthLib/
COPY Core.Plugin.Interface/*.csproj ./Core.Plugin.Interface/
COPY Core.Database/*.csproj ./Core.Database/

RUN dotnet restore Core.Backend

COPY Core.Backend/. ./Core.Backend/
COPY Core.AuthLib/. ./Core.AuthLib/
COPY Core.Plugin.Interface/. ./Core.Plugin.Interface/
COPY Core.Database/. ./Core.Database/

WORKDIR /source/Core.Backend
RUN dotnet publish -c Release -o /app --no-restore

FROM mcr.microsoft.com/dotnet/aspnet:6.0
WORKDIR /app
COPY --from=build /app .
ENTRYPOINT ["dotnet", "Core.Backend.dll"]
