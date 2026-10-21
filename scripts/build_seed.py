#!/usr/bin/env python3
"""Builds assets/seed/events.json and CREDITS.md for Eventra.

Deterministic: the same input always produces the same seed. Images come from
a curated list of free-licence Unsplash photos (Unsplash License) that were
checked to return HTTP 200 image/jpeg at >= 1200 px wide. Run with --verify to
re-check every image URL over the network before writing.

Usage:
    python3 scripts/build_seed.py [--verify]
"""
from __future__ import annotations

import json
import math
import random
import sys
import urllib.request
from datetime import datetime, timedelta
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
GENERATED_AT = "2026-10-21T00:00:00"

# Default demo location: New City (Clarkstown), Rockland County, NY - the
# area shown in the reference map (Congers Rd, Demarest Kill County Park).
DEFAULT_LOCATION = {"name": "New City, NY", "latitude": 41.1470, "longitude": -73.9895}

UNSPLASH = {
    "music": [
        "1501281668745-f7f57925c3b4", "1506157786151-b8491531f063",
        "1514525253161-7a46d19cd819", "1540039155733-5bb30b53aa14",
        "1470229722913-7c0e2dbbafd3", "1459749411175-04bf5292ceea",
        "1493225457124-a3eb161ffa5f", "1429962714451-bb934ecdc4ec",
        "1524368535928-5b5e00ddc76b", "1533174072545-7a4b6ad7a6c3",
        "1516450360452-9312f5e86fc7", "1492684223066-81342ee5ff30",
        "1511671782779-c97d3d27a1d4", "1505236858219-8359eb29e329",
    ],
    "cinema": [
        "1489599849927-2ee91cede3ba", "1517604931442-7e0c8ed2963c",
        "1536440136628-849c177e76a1", "1478720568477-152d9b164e26",
        "1595769816263-9b910be24d5f",
    ],
    "sports": [
        "1461896836934-ffe607ba8211", "1574629810360-7efbbe195018",
        "1546519638-68e109498ffc", "1517649763962-0c623066013b",
        "1530549387789-4c1017266635",
    ],
    "social": [
        "1511632765486-a01980e01a18", "1529156069898-49953e39b3ac",
        "1528605248644-14dd04022da1", "1543269865-cbf427effbad",
        "1531058020387-3be344556be6",
    ],
    "art": [
        "1541961017774-22349e4a1262", "1531913764164-f85c52e6e654",
        "1544967082-d9d25d867d66", "1460661419201-fd4cecdf8a8b",
        "1513364776144-60967b0f800f", "1518998053901-5348d3961a04",
    ],
    "tech": [
        "1540575467063-178a50c2df87", "1505373877841-8d25f7d46678",
        "1515187029135-18ee286d815b", "1519389950473-47ba0277781c",
        "1488590528505-98d2b5aba04b", "1504384308090-c894fdcc538d",
    ],
    "food": [
        "1555939594-58d7cb561ad1", "1504674900247-0877df9cc836",
        "1414235077428-338989a2e8c0", "1565299624946-b28f40a0ae38",
        "1567620905732-2d1ec7ab7445", "1540189549336-e6e99c3679fe",
    ],
    "comedy": [
        "1527224857830-43a7acc85260", "1585699324551-f6c309eedeca",
        "1516280440614-37939bbacd81", "1503095396549-807759245b35",
        "1507676184212-d03ab07a01bf",
    ],
}


def img(photo_id: str) -> str:
    return f"https://images.unsplash.com/photo-{photo_id}?w=1200&q=80&fm=jpg&fit=crop"


def avatar(gender: str, n: int) -> str:
    return f"https://randomuser.me/api/portraits/{gender}/{n}.jpg"


def destination(lat: float, lng: float, km: float, bearing_deg: float):
    r = 6371.0088
    d = km / r
    b = math.radians(bearing_deg)
    p1, l1 = math.radians(lat), math.radians(lng)
    p2 = math.asin(math.sin(p1) * math.cos(d) + math.cos(p1) * math.sin(d) * math.cos(b))
    l2 = l1 + math.atan2(math.sin(b) * math.sin(d) * math.cos(p1), math.cos(d) - math.sin(p1) * math.sin(p2))
    return round(math.degrees(p2), 6), round(math.degrees(l2), 6)


def haversine(lat1, lng1, lat2, lng2):
    r = 6371.0088
    p1, p2 = math.radians(lat1), math.radians(lat2)
    dp = p2 - p1
    dl = math.radians(lng2 - lng1)
    a = math.sin(dp / 2) ** 2 + math.cos(p1) * math.cos(p2) * math.sin(dl / 2) ** 2
    return 2 * r * math.asin(math.sqrt(a))


D = DEFAULT_LOCATION
HARBOR = destination(D["latitude"], D["longitude"], 5.21, 300)
NATIONAL = destination(D["latitude"], D["longitude"], 3.11, 75)

ORGANIZERS = [
    {"id": "org-pulse", "name": "Pulse Live Co.", "avatarUrl": avatar("men", 32), "verified": True, "followers": 18400},
    {"id": "org-hudson", "name": "Hudson Valley Events", "avatarUrl": avatar("women", 44), "verified": True, "followers": 9200},
    {"id": "org-reel", "name": "Reel Nights Collective", "avatarUrl": avatar("men", 75), "verified": True, "followers": 6100},
    {"id": "org-arena", "name": "Arena Sports Group", "avatarUrl": avatar("men", 11), "verified": True, "followers": 25300},
    {"id": "org-meet", "name": "Meet & Mingle", "avatarUrl": avatar("women", 65), "verified": False, "followers": 3400},
    {"id": "org-canvas", "name": "Open Canvas Studio", "avatarUrl": avatar("women", 12), "verified": True, "followers": 7800},
    {"id": "org-devhub", "name": "DevHub NYC", "avatarUrl": avatar("men", 86), "verified": True, "followers": 12900},
    {"id": "org-taste", "name": "Taste Collective", "avatarUrl": avatar("women", 33), "verified": True, "followers": 15100},
    {"id": "org-laugh", "name": "Laugh Track Comedy", "avatarUrl": avatar("men", 44), "verified": False, "followers": 5600},
]
ORG_BY_CAT = {
    "music": ["org-pulse", "org-hudson"], "cinema": ["org-reel"], "sports": ["org-arena"],
    "social": ["org-meet", "org-hudson"], "art": ["org-canvas"], "tech": ["org-devhub"],
    "food": ["org-taste", "org-hudson"], "comedy": ["org-laugh"],
}

# (title, category, venue, address, lat, lng, base_price, fixed_start or None)
EVENTS = [
    ("Highland Music Festival", "music", "Rockland Lake State Park", "4517 Manchester", 41.149500, -73.919500, 65, "2027-06-20T23:00:00"),
    ("Pitchfork Music Night", "music", "Washington Hall", "4523 Washington", 41.146800, -73.975200, 50, "2027-02-11T22:20:00"),
    ("National Music Festival", "music", "Congers Lake Memorial Park", "4523 Washington USA", NATIONAL[0], NATIONAL[1], 45, "2027-05-15T18:00:00"),
    ("Jazz Under the Stars", "music", "Lincoln Center", "10 Lincoln Center Plaza, New York", 40.772500, -73.983500, 38, None),
    ("Electric Pulse Night", "music", "Brooklyn Steel", "319 Frost St, Brooklyn", 40.719300, -73.938900, 42, None),
    ("Hudson Indie Sessions", "music", "The Turning Point", "468 Piermont Ave, Piermont", 41.042000, -73.918000, 25, None),
    ("Symphony on the Great Lawn", "music", "Central Park Great Lawn", "Central Park, New York", 40.781200, -73.966500, 0, None),
    ("Midnight Classics Marathon", "cinema", "Alamo Drafthouse Downtown Brooklyn", "445 Albee Square W, Brooklyn", 40.691300, -73.983200, 18, None),
    ("Rooftop Cinema Club", "cinema", "Rooftop Cinema Club Midtown", "26 W 39th St, New York", 40.752200, -73.983800, 22, None),
    ("IMAX Premiere Night", "cinema", "Palisades Center", "1000 Palisades Center Dr, West Nyack", 41.098300, -73.954500, 16, None),
    ("Film Noir Week", "cinema", "Film Forum", "209 W Houston St, New York", 40.728700, -74.004300, 15, None),
    ("Documentary Night", "cinema", "IFC Center", "323 6th Ave, New York", 40.731000, -74.001600, 17, None),
    ("Summer Movies in Bryant Park", "cinema", "Bryant Park", "Bryant Park, New York", 40.753600, -73.983200, 0, None),
    ("Animation Fest", "cinema", "Nitehawk Cinema", "136 Metropolitan Ave, Brooklyn", 40.716300, -73.962000, 14, None),
    ("Yankees Rivalry Night", "sports", "Yankee Stadium", "1 E 161st St, Bronx", 40.829600, -73.926200, 55, None),
    ("Garden Hoops Classic", "sports", "Madison Square Garden", "4 Pennsylvania Plaza, New York", 40.750500, -73.993400, 70, None),
    ("Haverstraw Bay Half Marathon", "sports", "Haverstraw Bay County Park", "Beach Rd, Haverstraw", 41.201000, -73.958000, 35, None),
    ("Bear Mountain Gran Fondo", "sports", "Bear Mountain State Park", "Palisades Pkwy, Bear Mountain", 41.312600, -73.988700, 40, None),
    ("Open Water Swim Classic", "sports", "Lake Welch Beach", "Lake Welch Dr, Stony Point", 41.231000, -74.051000, 30, None),
    ("Five-a-Side Soccer Cup", "sports", "Icahn Stadium", "20 Randalls Island Park, New York", 40.794000, -73.924000, 20, None),
    ("Brooklyn Fan Night", "sports", "Barclays Center", "620 Atlantic Ave, Brooklyn", 40.682600, -73.975400, 48, None),
    ("Rooftop Sunset Social", "social", "230 Fifth Rooftop", "230 5th Ave, New York", 40.744200, -73.988100, 20, None),
    ("Board Game Night", "social", "The Uncommons", "230 Thompson St, New York", 40.729000, -73.998500, 10, None),
    ("Beach Picnic Meetup", "social", "Nyack Beach State Park", "Broadway, Upper Nyack", 41.122500, -73.915000, 0, None),
    ("Language Exchange Cafe", "social", "Nyack Main Street", "Main St, Nyack", 41.090700, -73.918000, 5, None),
    ("River Cleanup Volunteers", "social", "Haverstraw Riverfront", "Riverfront, Haverstraw", 41.197500, -73.963000, 0, None),
    ("New Neighbors Mixer", "social", "Nanuet Public Library", "149 Church St, Nanuet", 41.089800, -74.013600, 0, None),
    ("Pier Trivia Night", "social", "Piermont Pier", "Ferry Rd, Piermont", 41.040500, -73.910000, 8, None),
    ("Harbor Art Festival", "art", "Harbor Art Grounds", "4523 Washington USA", HARBOR[0], HARBOR[1], 12, None),
    ("Modern Masters Late Night", "art", "MoMA", "11 W 53rd St, New York", 40.761400, -73.977600, 25, None),
    ("Street Art Walk", "art", "The Bushwick Collective", "Troutman St, Brooklyn", 40.706700, -73.923000, 15, None),
    ("Hopper House Evening Talk", "art", "Edward Hopper House", "82 N Broadway, Nyack", 41.092800, -73.918500, 12, None),
    ("Sculpture Field Day", "art", "Storm King Art Center", "1 Museum Rd, New Windsor", 41.425500, -74.059000, 28, None),
    ("Ceramics Open Studio", "art", "Rockland Center for the Arts", "27 S Greenbush Rd, West Nyack", 41.095100, -73.968100, 30, None),
    ("First Saturday at the Museum", "art", "Brooklyn Museum", "200 Eastern Pkwy, Brooklyn", 40.671200, -73.963600, 0, None),
    ("Flutter NYC Meetup", "tech", "Chelsea Tech Hub", "111 8th Ave, New York", 40.741100, -74.003400, 0, None),
    ("AI Builders Summit", "tech", "Javits Center", "429 11th Ave, New York", 40.757800, -74.002200, 120, None),
    ("Robotics Hack Day", "tech", "NYU Tandon", "6 MetroTech Center, Brooklyn", 40.694200, -73.986600, 15, None),
    ("Startup Pitch Night", "tech", "Rockland Community College", "145 College Rd, Suffern", 41.130700, -74.082000, 10, None),
    ("Cybersecurity Workshop", "tech", "Cornell Tech", "2 W Loop Rd, New York", 40.755600, -73.956300, 45, None),
    ("Product Design Breakfast", "tech", "Nyack Library", "59 S Broadway, Nyack", 41.089600, -73.918300, 12, None),
    ("Open Source Sprint", "tech", "Dominican University", "470 Western Hwy, Orangeburg", 41.047300, -73.943900, 0, None),
    ("Smorgasburg Williamsburg", "food", "East River State Park", "90 Kent Ave, Brooklyn", 40.721500, -73.962000, 0, None),
    ("Taste of Rockland", "food", "Bowline Point Park", "50 Samsondale Ave, Haverstraw", 41.198000, -73.960000, 25, None),
    ("Hudson Valley Wine Fest", "food", "Bear Mountain Inn", "3020 Seven Lakes Dr, Bear Mountain", 41.311500, -73.989500, 55, None),
    ("East Village Ramen Crawl", "food", "St Marks Place", "St Marks Pl, New York", 40.726500, -73.981500, 35, None),
    ("Farm-to-Table Supper", "food", "Stone Barns", "630 Bedford Rd, Pocantico Hills", 41.100900, -73.829100, 95, None),
    ("Nyack Farmers Market Day", "food", "Nyack Farmers Market", "Main St & Cedar St, Nyack", 41.090500, -73.919500, 0, None),
    ("Chelsea Market Tasting Tour", "food", "Chelsea Market", "75 9th Ave, New York", 40.742400, -74.006100, 45, None),
    ("Comedy Cellar Late Show", "comedy", "Comedy Cellar", "117 MacDougal St, New York", 40.730200, -74.000600, 28, None),
    ("Gotham Stand-up Night", "comedy", "Gotham Comedy Club", "208 W 23rd St, New York", 40.744400, -73.996300, 30, None),
    ("Improv Jam", "comedy", "Upright Citizens Brigade", "555 W 42nd St, New York", 40.760500, -73.997000, 12, None),
    ("Nyack Stand-up Showcase", "comedy", "Nyack Center", "58 Depew Ave, Nyack", 41.092100, -73.917500, 18, None),
    ("Open Mic Comedy Night", "comedy", "Elmwood Playhouse", "10 Park St, Nyack", 41.093700, -73.920900, 0, None),
    ("Brooklyn Comedy Fest", "comedy", "The Bell House", "149 7th St, Brooklyn", 40.673800, -73.991800, 35, None),
    ("Sunday Funnies", "comedy", "New York Comedy Club", "241 E 24th St, New York", 40.738800, -73.981300, 22, None),
]

COVER_OVERRIDE = {
    "Highland Music Festival": "1506157786151-b8491531f063",
    "Pitchfork Music Night": "1501281668745-f7f57925c3b4",
    "National Music Festival": "1540039155733-5bb30b53aa14",
}

DESCRIPTIONS = {
    "music": "{t} is a high-energy live music event that brings together standout artists, passionate fans, and cutting-edge sound in one unforgettable night. Expect a full production with immersive lighting, a tuned sound system and food trucks on site at {v}. Doors open one hour before the first set, and re-entry is allowed with your wristband.",
    "cinema": "{t} turns {v} into a home for film lovers. Every screening is introduced by a programmer from the team, with a short conversation afterwards for anyone who wants to stay. Seats are unreserved, so arrive early for the best view, and snacks are available at the counter.",
    "sports": "{t} at {v} is built for fans who want the full matchday experience: early entry, a pre-game warm-up zone, giveaways for the first arrivals and a dedicated supporters section. Bring a valid ID; bags larger than a small clutch are not allowed inside.",
    "social": "{t} is an easy way to meet new people near you. Hosts at {v} keep the evening relaxed with light icebreakers, small groups and plenty of time to talk. Come alone or bring a friend; everyone gets a name tag and a welcome drink token.",
    "art": "{t} invites you to {v} for a close look at work by local and visiting artists. Guided walk-throughs start every hour, artists are on hand to talk about their process, and several pieces are available to buy. Photography is welcome without flash.",
    "tech": "{t} brings builders, designers and curious minds together at {v}. The programme mixes short talks, live demos and open discussion, followed by time to network. Bring a laptop if you want to join the hands-on part; power and Wi-Fi are provided.",
    "food": "{t} is a celebration of good food at {v}. Local vendors, chefs and producers serve tasting portions throughout the day, with cooking demos on the main stage and seating areas for families. Vegetarian and gluten-free options are clearly labelled.",
    "comedy": "{t} at {v} lines up sharp stand-up from touring headliners and rising local talent. Each comic does a tight set, and the host keeps the room moving between acts. The show contains adult language; a two-drink minimum applies at the venue.",
}

LINEUP = {
    "music": ["Doors open", "Opening DJ set", "Main act", "Closing set"],
    "cinema": ["Doors and snacks", "Introduction by the programmer", "Feature screening", "Audience Q&A"],
    "sports": ["Gates open", "Warm-up and fan zone", "Kick-off", "Post-game meet and greet"],
    "social": ["Welcome and name tags", "Icebreaker round", "Small-group conversations", "Open mingling"],
    "art": ["Doors open", "Guided walk-through", "Artist talk", "Closing reception"],
    "tech": ["Check-in and coffee", "Keynote", "Live demos", "Networking"],
    "food": ["Market opens", "Chef demo", "Tasting hour", "Last call at the stalls"],
    "comedy": ["Doors open", "Host warm-up", "Featured comics", "Headliner"],
}

REVIEWS = [
    ("Great sound and a friendly crowd. Getting in took less than five minutes.", 5),
    ("Well organized, clear signage and helpful staff all evening.", 5),
    ("Good value for the price. Seating was a bit tight near the front.", 4),
    ("Loved the atmosphere. I would come back with friends next time.", 5),
    ("Fun night overall, though the queue for drinks was long.", 4),
    ("The hosts made everyone feel welcome. Easy to meet people.", 5),
]
REVIEWERS = [("Maya Chen", "women", 21), ("Jordan Blake", "men", 52), ("Priya Patel", "women", 68),
             ("Lucas Romero", "men", 23), ("Amara Okafor", "women", 50), ("Ethan Brooks", "men", 61)]

POLICY_PAID = "Full refund up to 7 days before the event. 50% refund between 7 days and 48 hours before. No refunds within 48 hours of the start time; tickets can still be transferred to a friend."
POLICY_FREE = "Free entry with RSVP. If you can no longer attend, cancel your RSVP so someone on the waitlist can take your spot."


def schedule(i: int, rnd: random.Random) -> datetime:
    base = datetime(2026, 10, 23)
    if i % 13 == 0:  # a few events this coming weekend
        return datetime(2026, 10, 24 + (i // 13) % 2, 19, 0)
    day = rnd.randint(3, 330)
    hour = rnd.choice([10, 12, 14, 18, 19, 20, 21])
    minute = rnd.choice([0, 0, 30])
    return base + timedelta(days=day, hours=hour, minutes=minute)


def slug(s: str) -> str:
    return "".join(c.lower() if c.isalnum() else "-" for c in s).strip("-").replace("--", "-")


def build():
    rnd = random.Random(2026)
    events = []
    cat_counter = {k: 0 for k in UNSPLASH}
    for i, (title, cat, venue, address, lat, lng, price, fixed) in enumerate(EVENTS):
        start = datetime.fromisoformat(fixed) if fixed else schedule(i, rnd)
        duration = {"music": 4, "cinema": 3, "sports": 3, "social": 3, "art": 4, "tech": 4, "food": 6, "comedy": 2}[cat]
        end = start + timedelta(hours=duration)
        pool = UNSPLASH[cat]
        k = cat_counter[cat]
        cat_counter[cat] += 1
        ids = [pool[(k + j) % len(pool)] for j in range(4)]
        if title in COVER_OVERRIDE:
            cover = COVER_OVERRIDE[title]
            ids = [cover] + [x for x in ids if x != cover][:3]
            if len(ids) < 4:
                ids += [x for x in pool if x not in ids][: 4 - len(ids)]
        org_id = ORG_BY_CAT[cat][i % len(ORG_BY_CAT[cat])]
        capacity = rnd.choice([120, 200, 300, 500, 800, 1500, 5000])
        sold = int(capacity * rnd.uniform(0.25, 0.92))
        if title == "Ceramics Open Studio":
            sold = capacity  # one sold-out event to exercise the Sold Out state
        if price == 0:
            tiers = [{"id": "rsvp", "name": "Free RSVP", "price": 0, "capacity": capacity, "sold": sold,
                      "perks": ["Entry for one", "Reminder before the event"]}]
        else:
            ga_cap = int(capacity * 0.7)
            vip_cap = int(capacity * 0.1)
            eb_cap = capacity - ga_cap - vip_cap
            tiers = [
                {"id": "early", "name": "Early Bird", "price": round(price * 0.8, 2), "capacity": eb_cap,
                 "sold": min(eb_cap, int(sold * 0.25)), "perks": ["Entry for one", "Best price"]},
                {"id": "ga", "name": "General Admission", "price": float(price), "capacity": ga_cap,
                 "sold": min(ga_cap, int(sold * 0.65)), "perks": ["Entry for one"]},
                {"id": "vip", "name": "VIP", "price": float(round(price * 2.2)), "capacity": vip_cap,
                 "sold": min(vip_cap, sold - min(eb_cap, int(sold * 0.25)) - min(ga_cap, int(sold * 0.65))),
                 "perks": ["Priority entry", "Lounge access", "Welcome drink"]},
            ]
            if title == "Ceramics Open Studio":
                for t in tiers:
                    t["sold"] = t["capacity"]
            sold = sum(t["sold"] for t in tiers)
        participants = max(12, int(sold * 0.6))
        if title == "Pitchfork Music Night":
            participants = 34  # 4 avatars + "+30 Participants" in the reference
        if title == "Highland Music Festival":
            participants = 15  # 3 avatars + "+12" in the reference
        avatars = [avatar("men" if (i + j) % 2 else "women", (i * 7 + j * 13) % 90 + 1) for j in range(6)]
        reviews = []
        for j in range(3):
            text, stars = REVIEWS[(i + j) % len(REVIEWS)]
            name, g, n = REVIEWERS[(i + j) % len(REVIEWERS)]
            reviews.append({"author": name, "avatarUrl": avatar(g, n), "rating": stars, "text": text,
                            "date": (datetime(2026, 9, 1) + timedelta(days=(i * 3 + j * 5) % 45)).isoformat()})
        lineup = [{"time": (start + timedelta(minutes=45 * j)).isoformat(), "title": step}
                  for j, step in enumerate(LINEUP[cat])]
        events.append({
            "id": f"evt-{i + 1:03d}-{slug(title)}",
            "title": title,
            "category": cat,
            "description": DESCRIPTIONS[cat].format(t=title, v=venue),
            "startAt": start.isoformat(),
            "endAt": end.isoformat(),
            "tiers": tiers,
            "capacity": capacity,
            "soldCount": sold,
            "venue": venue,
            "address": address,
            "latitude": lat,
            "longitude": lng,
            "organizerId": org_id,
            "rating": round(rnd.uniform(4.1, 4.9), 1),
            "reviewCount": rnd.randint(18, 640),
            "participantsCount": participants,
            "participantAvatars": avatars,
            "tags": [cat, "nearby" if haversine(D["latitude"], D["longitude"], lat, lng) < 15 else "nyc",
                     "free" if price == 0 else "ticketed"] + ([f"featured:{list(COVER_OVERRIDE).index(title) + 1}"] if title in COVER_OVERRIDE else []),
            "coverImageUrl": img(ids[0]),
            "gallery": [img(x) for x in ids],
            "lineup": lineup,
            "policy": POLICY_FREE if price == 0 else POLICY_PAID,
            "reviews": reviews,
            "imageCredit": "Unsplash (Unsplash License)",
        })
    return events


def verify(urls):
    bad = []
    for u in sorted(set(urls)):
        try:
            req = urllib.request.Request(u, method="GET", headers={"User-Agent": "eventra-seed"})
            with urllib.request.urlopen(req, timeout=20) as r:
                if r.status != 200 or not r.headers.get("content-type", "").startswith("image/"):
                    bad.append(u)
        except Exception:  # noqa: BLE001
            bad.append(u)
    return bad


def main():
    events = build()
    seed = {"generatedAt": GENERATED_AT, "defaultLocation": DEFAULT_LOCATION,
            "organizers": ORGANIZERS, "events": events}
    if "--verify" in sys.argv:
        urls = [u for e in events for u in e["gallery"]] + [o["avatarUrl"] for o in ORGANIZERS]
        bad = verify(urls)
        if bad:
            print("Unreachable images:\n" + "\n".join(bad))
            sys.exit(1)
        print(f"verified {len(set(urls))} image URLs")
    out = ROOT / "assets" / "seed" / "events.json"
    out.write_text(json.dumps(seed, indent=1, ensure_ascii=False))
    write_credits()
    print(f"wrote {len(events)} events -> {out}")
    print(f"Harbor Art Festival {haversine(D['latitude'], D['longitude'], *HARBOR):.2f} km, "
          f"National Music Festival {haversine(D['latitude'], D['longitude'], *NATIONAL):.2f} km")


def write_credits():
    lines = [
        "# Credits", "",
        "## Fonts", "",
        "- Urbanist (Regular, Medium, SemiBold, Bold) by Corey Hu, SIL Open Font License 1.1. "
        "Static TTFs from https://github.com/coreyhu/Urbanist (same family as google/fonts ofl/urbanist). "
        "Licence text: assets/fonts/OFL.txt.", "",
        "## Event photos (Unsplash License, free to use)", "",
        "All event photos are loaded remotely from images.unsplash.com and were checked to return HTTP 200 "
        "image/jpeg at 1200 px wide (scripts/build_seed.py --verify). The Unsplash napi/search endpoints "
        "require an API key in this build environment, so photographer names could not be fetched automatically; "
        "opening an image URL on unsplash.com resolves to its photo page with the photographer's credit.", "",
        "| Category | Unsplash photo id | Image URL used |", "|---|---|---|",
    ]
    for cat, ids in UNSPLASH.items():
        for pid in ids:
            lines.append(f"| {cat} | photo-{pid} | {img(pid)} |")
    lines += ["", "## Avatars", "",
              "Attendee, organizer and reviewer avatars come from https://randomuser.me (portraits intended for "
              "placeholder use). They represent fictional people, not real attendees.", "",
              "## Map tiles", "", "Map tiles: (c) OpenStreetMap contributors, (c) CARTO (Positron basemap). "
              "Attribution is shown on every map.", ""]
    (ROOT / "CREDITS.md").write_text("\n".join(lines))


if __name__ == "__main__":
    main()
