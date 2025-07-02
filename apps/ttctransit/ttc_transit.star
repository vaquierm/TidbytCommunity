"""
Applet: TTC Transit
Summary: TTC times
Description: Track the arrival time of buses and trains from TTC.
Author: vaquierm
"""

load("render.star", "render")
load("schema.star", "schema")
load("encoding/json.star", "json")
load("http.star", "http")

BASE_URL = "https://transit.ttc.com.ge/pis-gateway/api/v2"
API_KEY = "c0a2f304-551a-4d08-b8df-2c53ecd57f9f"


def main(config):
    STOPS_URL = BASE_URL + "/stops"
    stops = http.get(STOPS_URL, headers={ "X-Api-Key": API_KEY }, body = "{\"locale\": \"en\"}", auth=("",API_KEY))
    print(stops.body())

    who = config.str("who", "WORLD")
    message = "Hello, {}!".format(who)
    return render.Root(
        child = render.Text(message),
    )

def get_schema():
    return schema.Schema(
        version = "1",
        fields = [
            schema.Text(
                id = "who",
                name = "Who?",
                desc = "Who to say hello to.",
                icon = "user",
            ),
        ],
    )
