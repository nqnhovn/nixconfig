{ config, lib, ... }:

let
  infoPath = ../../../../secrets/info.nix;
  infoExamplePath = ../../../../secrets/info.example.nix;
  userInfo = if builtins.pathExists infoPath
    then import infoPath
    else if builtins.pathExists infoExamplePath
    then import infoExamplePath
    else { };

  userName = lib.toLower (userInfo.user or "nixos");
in

{
  programs.firefox = {
    enable = true;
    configPath = "${config.xdg.configHome}/mozilla/firefox";

    policies = {
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      DisablePocket = true;
      NoDefaultBookmarks = true;
      OfferToSaveLogins = true;
      PasswordManagerEnabled = true;
      EnableTrackingProtection = {
        Value = true; Locked = true;
        Cryptomining = true; Fingerprinting = true;
      };
      DNSOverHTTPS = {
        Enabled = true;
        ProviderURL = "https://cloudflare-dns.com/dns-query";
        Locked = false;
      };
    };

    profiles."${userName}" = {
      id = 0; name = userName; isDefault = true;
      settings = {
        "browser.tabs.unloadOnLowMemory" = true;
        "browser.sessionhistory.max_total_viewers" = 0;
        "accessibility.force_disabled" = 1;
        "browser.download.animateNotifications" = false;
        "toolkit.cosmeticAnimations.enabled" = false;
        "network.dns.disablePrefetch" = false;
        "network.prefetch-next" = true;
        "gfx.webrender.all" = true;
        "browser.cache.disk.enable" = true;
        "browser.cache.memory.enable" = true;
        "browser.cache.memory.capacity" = 256000;
        "network.http.max-connections" = 256;
        "network.http.max-persistent-connections-per-server" = 16;
        "network.http.pipelining" = true;
        "browser.urlbar.suggest.quicksuggest" = false;
        "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
        "browser.newtabpage.activity-stream.feeds.snippets" = false;
        "browser.newtabpage.activity-stream.showSponsored" = false;
        "browser.safebrowsing.malware.enabled" = true;
        "browser.safebrowsing.phishing.enabled" = true;
        "browser.send_pings" = false;
        "dom.battery.enabled" = false;
        "privacy.trackingprotection.enabled" = true;
        "privacy.donottrackheader.enabled" = true;
        "browser.contentblocking.category" = "strict";
        "devtools.chrome.enabled" = true;
        "devtools.debugger.remote-enabled" = true;
        "devtools.inspector.showAllAnonymousContent" = true;
        "devtools.theme" = "dark";
        "browser.tabs.warnOnClose" = false;
        "browser.tabs.warnOnCloseOtherTabs" = false;
      };
    };
  };
}
