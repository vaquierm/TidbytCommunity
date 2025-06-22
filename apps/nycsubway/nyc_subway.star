"""
Applet: NYC Subway
Summary: NYC Subway depatrure times
Description: Real time departure times for a specified NYC subway stop.
Author: vaquierm
"""

load("encoding/base64.star", "base64")
load("encoding/json.star", "json")
load("http.star", "http")
load("re.star", "re")
load("render.star", "render")
load("schema.star", "schema")
load("time.star", "time")

DEFAULT_STOP_ID = "M16"
DEFAULT_DIRECTION = "both"
DEFAULT_TRAVEL_TIME = '{"display": "0", "value": "0", "text": "0"}'
GOOD_SERVICE_STOPS_URL_BASE = "https://goodservice.io/api/stops/"
GOOD_SERVICE_ROUTES_URL = "https://goodservice.io/api/routes/"

NAME_OVERRIDE = {
    "Grand Central-42 St": "Grand Cntrl",
    "Times Sq-42 St": "Times Sq",
    "Coney Island-Stillwell Av": "Coney Is",
    "South Ferry": "S Ferry",
    "Mets-Willets Point": "Willets Pt",
}

STREET_ABBREVIATIONS = [
    "St",
    "Av",
    "Sq",
    "Blvd",
    "Rd",
    "Yards",
]

ABBREVIATIONS = {
    "World Trade Center": "WTC",
    "Center": "Ctr",
    "Metropolitan": "Metrop",
    "Blvd": "Bl",
    "Park": "Pk",
    "Beach": "Bch",
    "Rockaway": "Rckwy",
    "Channel": "Chnl",
    "Green": "Grn",
    "Broadway": "Bway",
    "Queensboro": "Q Boro",
    "Plaza": "Plz",
    "Whitehall": "Whthall",
}

DIAMONDS = {
    "#00933c": "iVBORw0KGgoAAAANSUhEUgAAAAsAAAALCAYAAACprHcmAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAcElEQVQYlX3QsRHCMAxA0YcWAfagADaBleg5MgkciwRvQpNwjnCsTuf3C3njdpBmizuuKPVDNOATZ7ymvYlnuJ/2XQ5iBWoF0YF/QeDRgXUwhMbVjSm4BEYcO0HBCeN84Gcl+EGWX5eDBcy4Dt4ZwhdZ8R3soZmzOQAAAABJRU5ErkJggg==",
    "#b933ad": "iVBORw0KGgoAAAANSUhEUgAAAAsAAAALCAYAAACprHcmAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAc0lEQVQYlX3QwREBQRBA0acTQQwSQCYEpghAAE6URNZk4rKrZtvs9K1r3j/0rB67uzRrXHBGqR+iAZ844jXuTTzB7bhvchALUCuIDvwLAtcOrINbaFzdmIJTYMC+ExQcMEwHfhaCH2T+dTmYwYzr4J0hfAHfSh628EQX+AAAAABJRU5ErkJggg==",
    "#ff6319": "iVBORw0KGgoAAAANSUhEUgAAAAsAAAALCAYAAACprHcmAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAcElEQVQYlX3QwREBQRBA0aezcEImyAR5KSKhJLImEi67arbNTt+65v1Dz+pzWUuzwRVnlPohGvCBI57j3sQT3I37NgexALWC6MC/IHDrwDq4h8bVjSk4BQbsO0HBAcN04Hsh+EHmX5eDGcy4Dl4ZwhemXh6YbpNeCwAAAABJRU5ErkJggg==",
}

def main(config):
    routes_req = http.get(GOOD_SERVICE_ROUTES_URL)
    if routes_req.status_code != 200:
        fail("goodservice routes request failed with status %d", routes_req.status_code)

    stop_id = config.str("stop_id", DEFAULT_STOP_ID)
    stop_req = http.get(GOOD_SERVICE_STOPS_URL_BASE + stop_id + "?agent=tidbyt")
    if stop_req.status_code != 200:
        fail("goodservice stop request failed with status %d", stop_req.status_code)

    stops_req = http.get(GOOD_SERVICE_STOPS_URL_BASE)
    if stops_req.status_code != 200:
        fail("goodservice stops request failed with status %d", stops_req.status_code)

    travel_time_raw = json.decode(config.get("travel_time", DEFAULT_TRAVEL_TIME))["value"]
    if not is_parsable_integer(travel_time_raw):
        fail("non-integer value provided for travel_time: %s", travel_time_raw)
    travel_time_min = int(travel_time_raw)

    direction_config = config.str("direction", DEFAULT_DIRECTION)
    if direction_config == "both":
        directions = ["north", "south"]
    else:
        directions = [direction_config]

    ts = time.now().unix
    min_estimated_arrival_time = ts + (travel_time_min * 60)

    include_lines_str = config.str("include_lines", "").upper()
    include_lines = include_lines_str.split(",")

def get_schema():
    stops_req = http.get(GOOD_SERVICE_STOPS_URL_BASE)
    if stops_req.status_code != 200:
        fail("goodservice stops request failed with status %d", stops_req.status_code)

    stops_options = []

    for s in stops_req.json()["stops"]:
        stop_name = s["name"].replace(" - ", "-") + " - " + s["secondary_name"] if s["secondary_name"] else s["name"].replace(" - ", "-")
        routes = sorted(s["scheduled_routes"].keys())
        stops_options.append(
            schema.Option(
                display = stop_name + " (" + ", ".join(routes) + ")",
                value = s["id"],
            ),
        )

    return schema.Schema(
        version = "1",
        fields = [
            schema.Dropdown(
                id = "stop_id",
                name = "Station",
                desc = "Station to show subway departures",
                icon = "trainSubway",
                default = "M16",
                options = stops_options,
            ),
            schema.Dropdown(
                id = "direction",
                name = "Direction",
                desc = "Direction(s) of train depatures to be included",
                icon = "compass",
                default = "both",
                options = [
                    schema.Option(
                        display = "Both",
                        value = "both",
                    ),
                    schema.Option(
                        display = "Northbound",
                        value = "north",
                    ),
                    schema.Option(
                        display = "Southbound",
                        value = "south",
                    ),
                ],
            ),
            schema.Typeahead(
                id = "travel_time",
                name = "Travel Time to Station",
                desc = "Amount of time it takes to reach this station (trains with earlier arrival times will be hidden).",
                icon = "hourglass",
                handler = travel_time_search,
            ),
            schema.Dropdown(
                id = "third_time",
                name = "Third Time",
                desc = "3rd arrival time delta",
                icon = "hourglass",
                default = "3",
                options = [
                    schema.Option(
                        display = "OFF",
                        value = "0",
                    ),
                    schema.Option(
                        display = "3 mins",
                        value = "3",
                    ),
                    schema.Option(
                        display = "5 mins",
                        value = "5",
                    ),
                    schema.Option(
                        display = "7 mins",
                        value = "7",
                    ),
                    schema.Option(
                        display = "10 mins",
                        value = "10",
                    ),
                    schema.Option(
                        display = "Always Show",
                        value = "1000",
                    ),
                ],
            ),
            schema.Text(
                id = "include_lines",
                name = "Filter Lines",
                desc = "Only show certain lines (comma separated)",
                icon = "route",
                default = "",
            ),
        ],
    )

def travel_time_search(pattern):
    create_option = lambda value: schema.Option(display = value, value = value)

    if pattern == "0" or not is_parsable_integer(pattern):
        return [create_option(str(i)) for i in range(10)]

    int_pattern = int(pattern)
    if int_pattern > 60:
        return [create_option("60")]
    else:
        return [create_option(pattern)] + [create_option(pattern + str(i)) for i in range(10) if int_pattern * 10 + i < 60]

def is_parsable_integer(maybe_number):
    return not re.findall("[^0-9]", maybe_number)
