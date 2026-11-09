# PS trophy data sources and existing tools

Research for wayfinder ticket #6 on kridaydave/platinum-anything. Branch research/ps-trophy-data.

## 1. PlayStation trophy data sources

### 1.1 PSN API (Sony, undocumented)

What data is available: per-account trophy titles, per-title trophy definitions (name, description, type bronze/silver/gold/platinum, icon URL, hidden flag, trophy group/DLC, progress target for PS5), earned status with dates, rarity and earn rate percentage, trophy profile summary and level, trophy groups. Language can be overridden via Accept-Language header. Source: andshrew/PlayStation-Trophies API docs at https://github.com/andshrew/PlayStation-Trophies/blob/master/docs/APIv2.md and README https://github.com/andshrew/PlayStation-Trophies/blob/master/README.md.

How to access: HTTP GET against https://m.np.playstation.com/api/trophy with a Bearer access token. Token is obtained from an NPSSO cookie via the flow documented by psn-api: sign in at playstation.com, visit https://ca.account.sony.com/api/v1/ssocookie, exchange NPSSO for access code then auth tokens. Source: https://github.com/achievements-app/psn-api README.

Feasibility: high for trophy lists and earned status, but requires the user's own PSN login and NPSSO. No official documentation from Sony. Endpoints are reverse engineered from my.playstation.com (retired) and the PS App. Source: https://github.com/andshrew/PlayStation-Trophies/blob/master/README.md.

Terms and legality: Sony does not publish these endpoints. psn-api states it is not affiliated with Sony and is for elevating the PSN experience, not spam or abuse. Source: https://github.com/achievements-app/psn-api. TrophyScout, which uses the same flow, adds a disclaimer that it is not affiliated with Sony and that imports may break if Sony changes endpoints or policies. Source: https://github.com/Komortes/TrophyScout README. Treat as community reverse engineered, usable for personal/local tools, not a stable public API. Do not redistribute user data beyond what the user consents to.

### 1.2 PSNProfiles (community)

What data is available: game and trophy lists, trophy counts by type, completion durations, profile stats, user completion percentages, and trophy guides hosted on the site. Source: https://github.com/GIONAScm2/TrophyUtil README, which parses PSNProfiles HTML entities.

How to access: HTML scraping. There is no official API. Community wrappers exist, for example leonardoalemax/psn-profile-api described as a simple wrapper to fetch data from PSNProfiles, and robiningelbrecht/psnprofiles-scraper described as the most complete psnprofiles scraper in Python. Sources: https://github.com/leonardoalemax/psn-profile-api and https://github.com/robiningelbrecht/psnprofiles-scraper.

Feasibility: scraping is doable but fragile. PSNProfiles returned HTTP 403 to this research fetch, so access is gated. Source: fetch of https://psnprofiles.com returned 403.

Terms and legality: robots.txt at https://psnprofiles.com/robots.txt sets Content-Signal search=yes, ai-train=no, use=reference and disallows many training crawlers. So automated collection for AI training is expressly disallowed, while search indexing and reference use are allowed. Any use should respect those signals and the site's terms. Do not bulk scrape or republish guide text.

### 1.3 PowerPyx (trophy guides and roadmaps)

What data is available: per-game trophy roadmaps with estimated difficulty, time to platinum, missable trophy lists, glitched trophy notes, difficulty effects, minimum playthroughs, free roam and level select notes, new game plus notes, manual saves, and per-trophy descriptions with tips and missable flags. Example fetched: Pragmata guide at https://www.powerpyx.com/pragmata-trophy-guide-roadmap/.

How to access: HTML pages. robots.txt at https://www.powerpyx.com/robots.txt allows all crawlers. Source: https://www.powerpyx.com/robots.txt.

Feasibility: high for human readable guides, low for structured data. No API. Requires parsing HTML. Terms of service and privacy policy are linked from the site footer. Source: https://www.powerpyx.com/pragmata-trophy-guide-roadmap/ footer.

Terms and legality: content is copyright PowerPyx 2008-2026 per the fetched page footer. Reuse of guide text needs permission. Do not copy guide text into the product without rights.

### 1.4 PlayStationTrophies.org

What data is available: trophy lists per game with counts by type, and written guides with roadmaps, missable notes, and collectible locations. The homepage at https://www.playstationtrophies.org lists guides and trophies by platform. Source: https://www.playstationtrophies.org.

How to access: HTML. Trophy list pages are allowed by robots.txt, which disallows /game/*/trophies/* but allows /game/*/trophies/. Source: https://www.playstationtrophies.org/robots.txt. Guide pages returned HTTP 403 during this research, so they are not fetchable by a simple client. Source: fetch of https://www.playstationtrophies.org/game/thronefall/trophies/ returned 403.

Feasibility: trophy lists are reachable but deeper pages are blocked. No API observed.

Terms and legality: respect robots.txt. Do not scrape blocked paths.

### 1.5 Game wikis (Fandom and similar)

What data is available: trophy and achievement lists with names, descriptions, and types, plus walkthroughs, missable notes, and collectible locations. Example fetched: Elden Ring Achievements and Trophies page at https://eldenring.fandom.com/wiki/Achievements_and_Trophies lists 42 trophies with type and gamerscore.

How to access: MediaWiki HTML. Fandom content is available under CC-BY-SA per the page footer. Source: https://eldenring.fandom.com/wiki/Achievements_and_Trophies.

Feasibility: high for trophy names and descriptions, and good for walkthrough detail. No structured API for trophy data specifically, but MediaWiki API can return page content.

Terms and legality: CC-BY-SA requires attribution and share alike. Respect Fandom terms of use linked in the footer. Source: https://www.fandom.com/terms-of-use linked from the fetched page.

## 2. Existing platinum route and trophy guide tools

Websites and guides: PowerPyx and PlayStationTrophies.org are the main human written trophy guide sites, with roadmaps, missable flags, and difficulty ratings. Source: https://www.powerpyx.com/ and https://www.playstationtrophies.org.

Trackers and scrapers found on GitHub:
- achievements-app/psn-api, a JavaScript and TypeScript library for trophy, user, and game data from PSN, with 433 stars and 59 forks. It wraps the undocumented PSN API and aligns with the andshrew community docs. Source: https://github.com/achievements-app/psn-api.
- Komortes/TrophyScout, a PSN trophy tracker and analytics app with profile import, game and trophy exploration, comparisons, leaderboards, and route style guide views. It uses psn-api and is local first with SQLite. Source: https://github.com/Komortes/TrophyScout.
- GIONAScm2/TrophyUtil, a library for parsing PSNProfiles HTML entities, including trophies, games, and game series, with completion durations and timestamps. Source: https://github.com/GIONAScm2/TrophyUtil.
- GIONAScm2/PSNPlatinum, a userscript for PSNProfiles. Source: https://github.com/GIONAScm2/PSNPlatinum.
- Barokai/psnprofiles-enhanced, a userscript that enhances psnprofiles.com. Source: https://github.com/Barokai/psnprofiles-enhanced.
- robiningelbrecht/psnprofiles-scraper, a Python scraper described as the most complete psnprofiles scraper. Source: https://github.com/robiningelbrecht/psnprofiles-scraper.
- leonardoalemax/psn-profile-api, a wrapper to fetch data from PSNProfiles. Source: https://github.com/leonardoalemax/psn-profile-api.
- nalexander50/PSNProfilesTrophyScraper. Source: https://github.com/nalexander50/PSNProfilesTrophyScraper.
- Cardreaper/psn-trophy-tracker and NextLVLHasH/PsnTrophyTracker. Sources: https://github.com/Cardreaper/psn-trophy-tracker and https://github.com/NextLVLHasH/PsnTrophyTracker.
- LeeorV/PSN-AI-Trophy-Guides, a public repo hosting AI generated PSN trophy guides. Source: https://github.com/LeeorV/PSN-AI-Trophy-Guides.
- Tape/psn-trophy-site, a site to get PSN trophy data and trophy guides. Source: https://github.com/Tape/psn-trophy-site.

What they do: import a PSN profile, track earned trophies, show rarity and progress, compare players, and sometimes layer guide views. None found that generate an ordered platinum route from trophy dependencies and missable flags per game, combined with the user's earned status.

## 3. Gap a tool like plat-anything fills

Existing guides are static web pages per game. Existing trackers import PSN progress but do not produce an ordered route. The gap is a tool that combines structured trophy data from PSN with guide text and missable flags from community sources, then outputs a route tailored to the user's earned trophies and playthrough constraints. Feasible data path: use psn-api for trophy lists and earned status, and scrape or link to PowerPyx and PlayStationTrophies.org and Fandom for roadmap and missable details. Legal constraints: no official PSN API, PSNProfiles content signals disallow AI training, and PowerPyx and Fandom content is copyrighted or CC-BY-SA, so guide text should be linked or summarized with attribution rather than copied.

## Sources fetched

- https://github.com/andshrew/PlayStation-Trophies
- https://github.com/andshrew/PlayStation-Trophies/blob/master/README.md
- https://github.com/andshrew/PlayStation-Trophies/tree/master/docs
- https://raw.githubusercontent.com/andshrew/PlayStation-Trophies/master/docs/APIv2.md
- https://github.com/achievements-app/psn-api
- https://www.powerpyx.com/
- https://www.powerpyx.com/pragmata-trophy-guide-roadmap/
- https://www.powerpyx.com/robots.txt
- https://www.playstationtrophies.org
- https://www.playstationtrophies.org/robots.txt
- https://psnprofiles.com (403)
- https://psnprofiles.com/robots.txt
- https://eldenring.fandom.com/wiki/Achievements_and_Trophies
- https://github.com/Komortes/TrophyScout
- https://github.com/GIONAScm2/TrophyUtil
- https://github.com/GIONAScm2/PSNPlatinum
- https://github.com/Barokai/psnprofiles-enhanced
- https://github.com/robiningelbrecht/psnprofiles-scraper
- https://github.com/leonardoalemax/psn-profile-api
- https://github.com/nalexander50/PSNProfilesTrophyScraper
- https://github.com/Cardreaper/psn-trophy-tracker
- https://github.com/NextLVLHasH/PsnTrophyTracker
- https://github.com/LeeorV/PSN-AI-Trophy-Guides
- https://github.com/Tape/psn-trophy-site
- https://github.com/robiningelbrecht/psnprofiles-playstation-5-ui
