// ==UserScript==
// @name         youtube-adb-enhanced
// @namespace    https://github.com/iamfugui/youtube-adb
// @version      8.4 (+mobile)
// @description  Remove YouTube ads and Shorts — Optimized & Bug Fixed.
// @match        *://*.youtube.com/*
// @exclude      *://accounts.youtube.com/*
// @exclude      *://www.youtube.com/live_chat_replay*
// @exclude      *://www.youtube.com/persist_identity*
// @icon         https://www.google.com/s2/favicons?sz=64&domain=YouTube.com
// @grant        none
// @license      MIT
// @run-at       document-start
// ==/UserScript==

(function () {
    'use strict';

    // --- Configuration ---
    const CONFIG = {
        blockAds: true,
        blockShorts: true,
        logDebug: false
    };

    // --- Constants & Selectors ---
    const AD_SELECTORS = [
        '#masthead-ad',
        '#ad-action-interstitial',
        '#player-ads',
        '.video-ads.ytp-ad-module',
        '.ytp-ad-overlay-container',
        '.ytp-ad-message-container',
        'ytd-ad-slot-renderer',
        'ytd-banner-promo-renderer',
        'ytd-statement-banner-renderer',
        'ytd-in-feed-ad-layout-renderer',
        'ytd-rich-item-renderer:has(ytd-display-ad-renderer)',
        'ytd-rich-item-renderer:has(ytd-ad-slot-renderer)',
        'ytd-engagement-panel-section-list-renderer[target-id="engagement-panel-ads"]',
        'ytd-display-ad-renderer',
        'ytd-promoted-sparkles-web-renderer',
        'ytd-promoted-video-renderer',
        'ytd-compact-promoted-video-renderer',
        'ytd-action-companion-ad-renderer',
        'ytd-player-legacy-desktop-watch-ads-renderer',
        'tp-yt-paper-dialog:has(yt-mealbar-promo-renderer)',
        'yt-mealbar-promo-renderer',
        'ytd-popup-container:has(a[href="/premium"])',
        'ytd-merch-shelf-renderer',
        'ytd-brand-video-singleton-renderer',
        'ad-slot-renderer',
        'ytm-companion-ad-renderer',
        'ytm-promoted-sparkles-web-renderer',
        'ytm-promoted-video-renderer',
    ];

    const SHORTS_CSS_SELECTORS = [
        'ytd-rich-grid-row,#contents.ytd-rich-grid-row{display:contents!important}',
        'ytd-grid-video-renderer:has([overlay-style="SHORTS"]){display:none!important}',
        'ytd-rich-item-renderer:has([overlay-style="SHORTS"]){display:none!important}',
        'ytd-video-renderer:has([overlay-style="SHORTS"]){display:none!important}',
        'ytd-item-section-renderer.ytd-section-list-renderer[page-subtype="subscriptions"]:has(ytd-video-renderer:has([overlay-style="SHORTS"])){display:none!important}',
        'ytm-video-with-context-renderer:has([data-style="SHORTS"]){display:none!important}',
        'ytm-reel-shelf-renderer:has(ytm-shorts-lockup-view-model){display:none!important}',
    ];

    const SKIP_BTN_SELECTORS = [
        '.ytp-ad-skip-button',
        '.ytp-ad-skip-button-modern',
        '.ytp-skip-ad-button',
        'button.ytp-ad-overlay-close-button',
        '.ytp-ad-skip-button-slot button',
    ];

    // Regex Utils
    const REGEX = {
        shorts: /(^| )#?Shorts?( |$)/i,
        shortsRemix: /(^| )Shorts.?Remix/i,
        shortsExact: /^Shorts$/i,
    };

    // State Tracking
    let state = {
        styleInjected: false,
        observerActive: false,
        adWasShowing: false,
        userMuted: false,
    };

    // --- Helpers ---
    
    // Simulate native touch event for mobile/tough environments (Qutebrowser/Mobile)
    function nativeTouch(target) {
        if (!target) return;
        const touch = new Touch({
            identifier: Date.now(),
            target: target,
            clientX: 0, clientY: 0, 
            radiusX: 2.5, radiusY: 2.5,
            rotationAngle: 0, force: 0.5
        });

        const touchStart = new TouchEvent('touchstart', {
            bubbles: true, cancelable: true, view: window,
            touches: [touch], targetTouches: [touch], changedTouches: [touch]
        });

        const touchEnd = new TouchEvent('touchend', {
            bubbles: true, cancelable: true, view: window,
            touches: [], targetTouches: [], changedTouches: [touch]
        });

        target.dispatchEvent(touchStart);
        target.dispatchEvent(touchEnd);
    }

    // --- Core Functions ---

    function log(...args) {
        if (CONFIG.logDebug) console.log('[YT-ADB]', ...args);
    }

    function injectStyles() {
        if (state.styleInjected) return;
        
        let css = '';
        if (CONFIG.blockAds) {
            css += AD_SELECTORS.map(s => `${s}{display:none!important}`).join('\n');
        }
        if (CONFIG.blockShorts) {
            css += '\n' + SHORTS_CSS_SELECTORS.join('\n');
        }

        const el = document.createElement('style');
        el.id = 'yt-adb-enhanced-css';
        el.textContent = css;
        (document.head || document.documentElement).appendChild(el);
        state.styleInjected = true;
    }

    function getVideo() {
        return document.querySelector('.ad-showing video') || 
               document.querySelector('video.html5-main-video') || 
               document.querySelector('video');
    }

    function handleAds() {
        if (!CONFIG.blockAds) return;

        const video = getVideo();
        
        // Check for specific ad indicators
        const skipBtn = document.querySelector(SKIP_BTN_SELECTORS.join(','));
        const adOverlay = document.querySelector('.ad-showing') ||
                          document.querySelector('.ad-interrupting') ||
                          document.querySelector('ytd-player[ad-interrupting]') ||
                          document.querySelector('.video-ads.ytp-ad-module .ytp-ad-player-overlay');
        
        // State update: ad is currently visible if overlay OR skip button exists
        if (adOverlay || skipBtn) {
            // 1. Mute (preserve user's mute preference)
            if (video && !state.adWasShowing) state.userMuted = video.muted;
            state.adWasShowing = true;
            if (video && !video.muted) video.muted = true;

            // 2. Click Buttons
            if (skipBtn) {
                skipBtn.click();
                nativeTouch(skipBtn); // Critical for Qutebrowser/Mobile environments
                log('Clicked skip button');
                return; // Button clicked, wait for effect
            }

            // 3. Fast Forward (Playback Rate + Seek)
            if (video && !isNaN(video.duration)) {
                video.playbackRate = 16.0; // Speed up
                if (video.currentTime < video.duration - 0.5) {
                    video.currentTime = video.duration; // Seek to end
                }
            }
        
        } else {
            // No ad is showing.
            // ONLY resume if we were previously blocked by an ad.
            if (state.adWasShowing) {
                state.adWasShowing = false; // Reset flag
                
                if (video) {
                    video.playbackRate = 1.0;
                    video.muted = state.userMuted;
                    if (video.paused) {
                        log('Resuming video after ad');
                        video.play().catch(e => console.warn('Autoplay blocked', e));
                    }
                }
            }
        }
    }

    function removePremiumPopups() {
        const popups = document.querySelectorAll('ytd-popup-container');
        popups.forEach(container => {
            if (container.querySelector('a[href="/premium"]') ||
                container.querySelector('.ytd-enforcement-message-view-model')) {
                container.remove();
                log('Removed premium popup');
            }
        });

        // Backend enforcement backdrops
        document.querySelectorAll('tp-yt-iron-overlay-backdrop').forEach(bd => {
            // Remove aggressive backdrops (zIndex check from original script was 2201, keeping >= 2200 for safety)
            if (bd.style.zIndex >= 2200 || bd.hasAttribute('opened')) {
                bd.remove();
                // If we removed a backdrop, we must ensure the main video resumes if it was paused
                const video = document.querySelector('video.html5-main-video');
                if(video && video.paused) {
                    video.play().catch(e => console.warn('Autoplay blocked', e));
                    log('Resumed video after removing backdrop');
                }
            }
        });
    }

    // --- Shorts Hiding Logic ---

    // Clean helper to check text
    const hasText = (el, regex) => {
        const text = el?.textContent?.trim();
        return text && regex.test(text);
    };

    const hide = (el) => { if(el) el.style.display = 'none'; };

    function hideShorts() {
        if (!CONFIG.blockShorts) return;

        const isHistoryPath = /^\/feed\/history/.test(location.pathname);

        // Rules array: Easy to maintain and add new rules
        // type: selectors to find elements
        // check: optional function to validate if it should be hidden (regex checks)
        const rules = [
            // Generic Shelf Hiding via Title
            {
                sel: 'ytd-rich-section-renderer, ytd-reel-shelf-renderer',
                skipOnHistory: true,
                check: (el) => {
                    // Check various title locations
                    const title = el.querySelector('#title') || el.querySelector('.yt-core-attributed-string');
                    return hasText(title, REGEX.shorts) || hasText(el, REGEX.shorts);
                }
            },
            // Grid Items (History, Channel pages)
            {
                sel: 'ytd-grid-video-renderer, ytd-rich-item-renderer, ytm-item-section-renderer, ytm-rich-item-renderer',
                check: (el) => hasText(el.querySelector('#video-title'), REGEX.shorts)
            },
            // Sidebar / Guide Items
            {
                sel: 'ytd-guide-entry-renderer, ytd-mini-guide-entry-renderer, yt-chip-cloud-chip-renderer, ytm-chip-cloud-chip-renderer',
                check: (el) => hasText(el.querySelector('yt-formatted-string, .title'), REGEX.shortsExact)
            },
            // Mobile specific
            {
                sel: 'ytm-reel-shelf-renderer',
                skipOnHistory: true,
                check: (el) => hasText(el.querySelector('.reel-shelf-title-wrapper'), REGEX.shorts) || hasText(el.querySelector('.reel-shelf-title-wrapper'), REGEX.shortsRemix)
            },
            // Tabs
            {
                sel: 'tp-yt-paper-tab, yt-tab-shape, .single-column-browse-results-tabs > a',
                check: (el) => hasText(el, /Shorts/i)
            }
        ];

        // Apply Rules
        rules.forEach(rule => {
            if (rule.skipOnHistory && isHistoryPath) return;
            document.querySelectorAll(rule.sel).forEach(el => {
                if (!rule.check || rule.check(el)) {
                    hide(el);
                }
            });
        });

        // Search shelf headers (desktop): hide the full shelf container
        if (!isHistoryPath) {
            const shelfTitleSelectors = [
                '.shelf-header-layout-wiz__title',
                '.yt-shelf-header-layout__title',
            ];

            shelfTitleSelectors.forEach(sel => {
                document.querySelectorAll(sel).forEach(titleEl => {
                    if (!hasText(titleEl, REGEX.shorts)) return;
                    const shelf = titleEl.closest('grid-shelf-view-model');
                    if (shelf) hide(shelf);
                });
            });
        }
        
        // Pivot Bar (Mobile Bottom Bar)
        document.querySelectorAll('ytm-pivot-bar-item-renderer').forEach(el => {
            if (el.querySelector('.pivot-shorts')) hide(el);
        });
    }

    // --- Main Loop ---

    function onDomChange() {
        handleAds();
        removePremiumPopups();
        hideShorts();
    }

    function init() {
        injectStyles();
        if (state.observerActive) return;
        
        state.observerActive = true;
        let timeout;
        
        const observer = new MutationObserver(() => {
            if (timeout) return;
            timeout = setTimeout(() => {
                timeout = null;
                onDomChange();
            }, 100); // Debounce to save CPU
        });

        observer.observe(document.body, { childList: true, subtree: true });
        onDomChange(); // Initial run
    }

    // --- Bootstrap ---
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }
})();