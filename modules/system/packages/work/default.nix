{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    google-cloud-sdk
    google-cloud-sql-proxy
    slack
  ];
}
