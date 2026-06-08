// ==UserScript==
// @name         youtube-adb-qute-stable
// @namespace    https://github.com/iamfugui/youtube-adb
// @version      9.0
// @description  Minimal YouTube ad remover for qutebrowser: static ads, player ads, and premium popups.
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

    const CONFIG = {
        debug: false,
        hideShorts: true
    };

    const STYLE_ID = 'yt-adb-qute-style';

    const STATIC_AD_SELECTORS = [
        '#masthead-ad',
        '#player-ads',
        '#related #player-ads',
        '#related ytd-ad-slot-renderer',
        '.video-ads.ytp-ad-module',
        '.ytp-ad-overlay-container',
        '.ytp-ad-message-container',
        'ytd-ad-slot-renderer',
        'ytd-display-ad-renderer',
        'ytd-in-feed-ad-layout-renderer',
        'ytd-action-companion-ad-renderer',
        'ytd-promoted-sparkles-web-renderer',
        'ytd-promoted-video-renderer',
        'ytd-compact-promoted-video-renderer',
        'ytd-player-legacy-desktop-watch-ads-renderer',
        'ytd-engagement-panel-section-list-renderer[target-id="engagement-panel-ads"]',
        'tp-yt-paper-dialog:has(yt-mealbar-promo-renderer)',
        'yt-mealbar-promo-renderer',
        'ytd-popup-container:has(a[href="/premium"])',
        'ad-slot-renderer',
        'ytm-companion-ad-renderer'
    ];

    const SHORTS_SELECTORS = [
        'ytd-reel-shelf-renderer',
        'ytm-reel-shelf-renderer',
        'ytd-rich-shelf-renderer[is-shorts]',
        'ytd-rich-section-renderer:has(ytd-rich-shelf-renderer[is-shorts])',
        'ytd-rich-item-renderer:has([overlay-style="SHORTS"])',
        'ytd-grid-video-renderer:has([overlay-style="SHORTS"])',
        'ytd-video-renderer:has([overlay-style="SHORTS"])',
        'ytm-video-with-context-renderer:has([data-style="SHORTS"])',
        'ytm-shorts-lockup-view-model',
        'a[href="/shorts"]',
        'a[href^="/shorts/"]'
    ];

    const SKIP_BUTTON_SELECTORS = [
        '.ytp-ad-skip-button',
        '.ytp-ad-skip-button-modern',
        '.ytp-skip-ad-button',
        '.ytp-ad-skip-button-slot button',
        'button.ytp-ad-overlay-close-button'
    ];

    const state = {
        adActive: false,
        userMuted: false,
        timerStarted: false,
        observerStarted: false
    };

    function log(...args) {
        if (CONFIG.debug) console.log('[yt-adb-qute]', ...args);
    }

    function ensureStyles() {
        let style = document.getElementById(STYLE_ID);
        if (style) return;

        style = document.createElement('style');
        style.id = STYLE_ID;

        const adCss = STATIC_AD_SELECTORS.map(sel => `${sel}{display:none!important;}`).join('\n');
        const shortsCss = CONFIG.hideShorts
            ? SHORTS_SELECTORS.map(sel => `${sel}{display:none!important;}`).join('\n')
            : '';

        style.textContent = `${adCss}\n${shortsCss}`;
        (document.head || document.documentElement).appendChild(style);
    }

    function getMainVideo() {
        return document.querySelector('video.html5-main-video') || document.querySelector('video');
    }

    function isAdVisible() {
        return Boolean(
            document.querySelector('.ad-showing, .ad-interrupting') ||
            document.querySelector('ytd-player[ad-showing], ytd-player[ad-interrupting]') ||
            document.querySelector('.video-ads.ytp-ad-module .ytp-ad-player-overlay')
        );
    }

    function getSkipButton() {
        for (const selector of SKIP_BUTTON_SELECTORS) {
            const btn = document.querySelector(selector);
            if (btn) return btn;
        }
        return null;
    }

    function touchClick(target) {
        if (!target) return;
        if (typeof Touch === 'undefined' || typeof TouchEvent === 'undefined') return;

        try {
            const touch = new Touch({
                identifier: Date.now(),
                target,
                clientX: 10,
                clientY: 10,
                radiusX: 2.5,
                radiusY: 2.5,
                rotationAngle: 0,
                force: 0.5
            });

            target.dispatchEvent(new TouchEvent('touchstart', {
                bubbles: true,
                cancelable: true,
                view: window,
                touches: [touch],
                targetTouches: [touch],
                changedTouches: [touch]
            }));

            target.dispatchEvent(new TouchEvent('touchend', {
                bubbles: true,
                cancelable: true,
                view: window,
                touches: [],
                targetTouches: [],
                changedTouches: [touch]
            }));
        } catch (error) {
            log('touch click failed', error);
        }
    }

    function removePremiumOverlay() {
        document.querySelectorAll('ytd-popup-container').forEach(container => {
            if (
                container.querySelector('a[href="/premium"]') ||
                container.querySelector('.ytd-enforcement-message-view-model')
            ) {
                container.remove();
                log('removed premium popup');
            }
        });

        document.querySelectorAll('tp-yt-iron-overlay-backdrop').forEach(backdrop => {
            if (backdrop.hasAttribute('opened') || Number(backdrop.style.zIndex || 0) >= 2200) {
                backdrop.remove();
                const video = getMainVideo();
                if (video && video.paused) {
                    video.play().catch(() => undefined);
                }
            }
        });
    }

    function removeFeedAdCards() {
        const richItems = document.querySelectorAll('ytd-rich-item-renderer, ytm-rich-item-renderer');
        richItems.forEach(item => {
            const hasAdRenderer = Boolean(
                item.querySelector('ytd-ad-slot-renderer, ytd-in-feed-ad-layout-renderer, ytd-display-ad-renderer, ad-slot-renderer')
            );

            const hasSponsoredBadge = Array.from(
                item.querySelectorAll('badge-shape, ytd-badge-supported-renderer, span, div')
            ).some(el => /sponsored|ad/i.test((el.textContent || '').trim()));

            const hasGoogleAdLink = Boolean(
                item.querySelector('a[href*="googleadservices.com"], a[href*="doubleclick.net"], a[href*="/aclk?"]')
            );

            if (hasAdRenderer || hasSponsoredBadge || hasGoogleAdLink) {
                item.style.display = 'none';
            }
        });
    }

    function isVisible(el) {
        if (!el || !el.isConnected) return false;
        const style = window.getComputedStyle(el);
        if (style.display === 'none' || style.visibility === 'hidden') return false;
        return true;
    }

    function hideShortsAndEmpty() {
        if (!CONFIG.hideShorts) return;

        document.querySelectorAll('ytd-rich-shelf-renderer[is-shorts]').forEach(shelf => {
            const section = shelf.closest('ytd-rich-section-renderer');
            shelf.style.display = 'none';
            if (section) section.style.display = 'none';
        });

        document.querySelectorAll('ytd-rich-shelf-renderer').forEach(shelf => {
            const title = shelf.querySelector('#title');
            const text = (title?.textContent || shelf.textContent || '').trim();
            if (/^shorts$/i.test(text) || /(^|\s)#?shorts(\s|$)/i.test(text)) {
                const section = shelf.closest('ytd-rich-section-renderer');
                shelf.style.display = 'none';
                if (section) section.style.display = 'none';
            }
        });

        document.querySelectorAll(
            'ytd-guide-entry-renderer, ytd-mini-guide-entry-renderer, yt-chip-cloud-chip-renderer, ytm-pivot-bar-item-renderer, tp-yt-paper-tab, yt-tab-shape'
        ).forEach(el => {
            const text = (el.textContent || '').trim();
            if (/^shorts$/i.test(text) || /(^|\s)#?shorts(\s|$)/i.test(text)) {
                el.style.display = 'none';
            }
        });

        const rowLikeSelectors = [
            'ytd-rich-grid-row',
            'ytd-item-section-renderer',
            'ytd-rich-section-renderer',
            'grid-shelf-view-model',
            'ytm-item-section-renderer'
        ];

        const cardSelectors = [
            'ytd-rich-item-renderer',
            'ytd-grid-video-renderer',
            'ytd-video-renderer',
            'ytm-video-with-context-renderer',
            'ytm-rich-item-renderer',
            'ytm-shorts-lockup-view-model'
        ].join(',');

        rowLikeSelectors.forEach(selector => {
            document.querySelectorAll(selector).forEach(container => {
                const cards = Array.from(container.querySelectorAll(cardSelectors));
                if (cards.length === 0) return;

                const visibleCards = cards.filter(isVisible);
                if (visibleCards.length === 0) {
                    container.style.display = 'none';
                }
            });
        });
    }

    function clearAd() {
        const video = getMainVideo();
        const skipButton = getSkipButton();
        const adShowing = isAdVisible() || Boolean(skipButton);

        if (!video) return;

        if (adShowing) {
            if (!state.adActive) state.userMuted = video.muted;
            state.adActive = true;

            video.muted = true;

            if (skipButton) {
                try {
                    skipButton.click();
                } catch (_) {
                    touchClick(skipButton);
                }
                touchClick(skipButton);
                return;
            }

            if (!Number.isNaN(video.duration) && Number.isFinite(video.duration) && video.duration > 0) {
                video.currentTime = video.duration;
            } else {
                video.playbackRate = 16;
            }
            return;
        }

        if (state.adActive) {
            state.adActive = false;
            video.playbackRate = 1;
            video.muted = state.userMuted;
            if (video.paused) {
                video.play().catch(() => undefined);
            }
        }
    }

    function tick() {
        ensureStyles();
        clearAd();
        removePremiumOverlay();
        removeFeedAdCards();
        hideShortsAndEmpty();
    }

    function startObserver() {
        if (state.observerStarted || !document.body) return;
        state.observerStarted = true;

        let queued = false;
        const observer = new MutationObserver(() => {
            if (queued) return;
            queued = true;
            setTimeout(() => {
                queued = false;
                tick();
            }, 80);
        });

        observer.observe(document.body, {
            childList: true,
            subtree: true,
            attributes: true,
            attributeFilter: ['class', 'ad-showing', 'ad-interrupting', 'hidden']
        });
    }

    function bootstrap() {
        tick();

        if (!state.timerStarted) {
            state.timerStarted = true;
            setInterval(tick, 1200);
        }

        if (document.body) {
            startObserver();
        } else {
            setTimeout(bootstrap, 50);
        }
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', bootstrap, { once: true });
    } else {
        bootstrap();
    }

    window.addEventListener('yt-navigate-finish', tick);
    window.addEventListener('yt-page-data-updated', tick);
})();
