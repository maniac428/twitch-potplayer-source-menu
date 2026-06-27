// ==UserScript==
// @name         Twitch PotPlayer 720p Fix
// @namespace    local.twitchpotplayer.source
// @version      1.0.0
// @description  Open Twitch streams in PotPlayer source quality / 1080p via twitchpotplayer://
// @match        https://www.twitch.tv/*
// @match        https://twitch.tv/*
// @grant        GM_registerMenuCommand
// @run-at       document-start
// ==/UserScript==

(function () {
  "use strict";

  const blockedRoots = new Set([
    "directory",
    "downloads",
    "following",
    "friends",
    "inventory",
    "jobs",
    "p",
    "popout",
    "privacy",
    "settings",
    "subscriptions",
    "team",
    "turbo",
    "videos",
    "wallet"
  ]);

  let menu;
  let selectedChannel = "";
  let lastChannel = "";

  function channelFromUrl(value) {
    if (!value) return "";

    let url;
    try {
      url = new URL(value, location.origin);
    } catch {
      return "";
    }

    if (!/(^|\.)twitch\.tv$/i.test(url.hostname)) return "";

    const parts = url.pathname.split("/").filter(Boolean);
    if (parts.length === 0) return "";

    const channel = parts[0].toLowerCase();
    if (blockedRoots.has(channel)) return "";
    if (!/^[a-z0-9_]{2,25}$/.test(channel)) return "";

    return channel;
  }

  function currentPageChannel() {
    return channelFromUrl(location.href);
  }

  function channelFromElement(element) {
    if (!element || element.nodeType !== 1) return "";

    const anchor = element.closest?.("a[href]");
    if (anchor) {
      const fromAnchor = channelFromUrl(anchor.getAttribute("href"));
      if (fromAnchor) return fromAnchor;
    }

    const card = element.closest?.([
      "article",
      "[data-a-target]",
      "[class*='preview']",
      "[class*='card']",
      "[class*='tw-tower']",
      "[class*='side-nav-card']"
    ].join(","));

    if (card) {
      for (const link of card.querySelectorAll("a[href]")) {
        const fromCard = channelFromUrl(link.getAttribute("href"));
        if (fromCard) return fromCard;
      }
    }

    return "";
  }

  function channelFromPoint(x, y) {
    for (const element of document.elementsFromPoint(x, y)) {
      const channel = channelFromElement(element);
      if (channel) return channel;
    }

    return "";
  }

  function channelFromEvent(event) {
    const path = typeof event.composedPath === "function" ? event.composedPath() : [];
    for (const node of path) {
      const channel = channelFromElement(node);
      if (channel) return channel;
    }

    return channelFromPoint(event.clientX, event.clientY) || currentPageChannel();
  }

  function openSource(channel) {
    if (!channel) return;
    const target = `https://www.twitch.tv/${channel}`;
    location.href = `twitchpotplayer://open?target=${encodeURIComponent(target)}`;
  }

  function ensureMenu() {
    if (menu) return menu;

    menu = document.createElement("div");
    menu.id = "twitch-potplayer-source-menu";
    menu.style.cssText = [
      "position:fixed",
      "z-index:2147483647",
      "display:none",
      "min-width:220px",
      "box-sizing:border-box",
      "padding:7px",
      "border:1px solid #3f3f46",
      "border-radius:6px",
      "background:#18181b",
      "box-shadow:0 14px 38px rgba(0,0,0,.5)",
      "font:13px/1.4 system-ui,-apple-system,BlinkMacSystemFont,'Segoe UI',sans-serif",
      "color:#fafafa",
      "user-select:none"
    ].join(";");

    const item = document.createElement("button");
    item.type = "button";
    item.style.cssText = [
      "display:block",
      "width:100%",
      "margin:0",
      "padding:9px 10px",
      "border:0",
      "border-radius:4px",
      "background:transparent",
      "color:inherit",
      "font:inherit",
      "text-align:left",
      "cursor:pointer"
    ].join(";");

    item.addEventListener("mouseenter", () => {
      item.style.background = "#2f2f35";
    });
    item.addEventListener("mouseleave", () => {
      item.style.background = "transparent";
    });
    item.addEventListener("mousedown", event => event.preventDefault());
    item.addEventListener("click", event => {
      event.preventDefault();
      event.stopPropagation();
      hideMenu();
      openSource(selectedChannel);
    });

    menu.appendChild(item);
    document.documentElement.appendChild(menu);
    return menu;
  }

  function setMenuText(channel) {
    const item = ensureMenu().firstElementChild;
    item.textContent = `Open in PotPlayer source quality: ${channel}`;
  }

  function showMenu(x, y, channel) {
    selectedChannel = channel;
    setMenuText(channel);

    const el = ensureMenu();
    el.style.display = "block";

    const rect = el.getBoundingClientRect();
    const left = Math.max(8, Math.min(x, window.innerWidth - rect.width - 8));
    const top = Math.max(8, Math.min(y, window.innerHeight - rect.height - 8));

    el.style.left = `${left}px`;
    el.style.top = `${top}px`;
  }

  function hideMenu() {
    if (menu) menu.style.display = "none";
  }

  function rememberChannel(event) {
    const channel = channelFromEvent(event);
    if (channel) lastChannel = channel;
  }

  if (typeof GM_registerMenuCommand === "function") {
    GM_registerMenuCommand("PotPlayer source quality", () => {
      openSource(lastChannel || currentPageChannel());
    });
  }

  document.addEventListener("pointermove", rememberChannel, true);
  document.addEventListener("mousedown", rememberChannel, true);

  document.addEventListener("contextmenu", event => {
    const channel = channelFromEvent(event) || lastChannel;
    if (!channel) return;

    if (event.shiftKey) return;

    event.preventDefault();
    event.stopPropagation();
    event.stopImmediatePropagation();
    showMenu(event.clientX, event.clientY, channel);
  }, true);

  document.addEventListener("click", hideMenu, true);
  document.addEventListener("wheel", hideMenu, true);
  document.addEventListener("scroll", hideMenu, true);
  document.addEventListener("keydown", event => {
    if (event.key === "Escape") hideMenu();
  }, true);
})();
