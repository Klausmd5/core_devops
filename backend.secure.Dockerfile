FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /source

COPY Core.Backend.Secure/*.csproj ./Core.Backend.Secure/
COPY Core.AuthLib/*.csproj ./Core.AuthLib/
COPY Core.Secure.Database/*.csproj ./Core.Secure.Database/
COPY Core.Ldap.Implementation/*.csproj ./Core.Ldap.Implementation/
COPY Core.Ldap.Interface/*.csproj ./Core.Ldap.Interface/
COPY Core.Moodle.Implementation/*.csproj ./Core.Moodle.Implementation/
COPY Core.Moodle.Interface/*.csproj ./Core.Moodle.Interface/
COPY Core.WebUntis.Implementation/*.csproj ./Core.WebUntis.Implementation/
COPY Core.WebUntis.Interface/*.csproj ./Core.WebUntis.Interface/

RUN dotnet restore Core.Backend.Secure

COPY Core.Backend.Secure/. ./Core.Backend.Secure/
COPY Core.AuthLib/. ./Core.AuthLib/
COPY Core.Secure.Database/. ./Core.Secure.Database/
COPY Core.Ldap.Implementation/. ./Core.Ldap.Implementation/
COPY Core.Ldap.Interface/. ./Core.Ldap.Interface/
COPY Core.Moodle.Implementation/. ./Core.Moodle.Implementation/
COPY Core.Moodle.Interface/. ./Core.Moodle.Interface/
COPY Core.WebUntis.Implementation/. ./Core.WebUntis.Implementation/
COPY Core.WebUntis.Interface/. ./Core.WebUntis.Interface/

WORKDIR /source/Core.Backend.Secure
RUN dotnet publish -c Release -o /app --no-restore

FROM mcr.microsoft.com/dotnet/aspnet:6.0
RUN apt-get update \
    && apt-get install -y libldap-2.4 \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY --from=build /app .
ENTRYPOINT ["dotnet", "Core.Backend.Secure.dll"]
