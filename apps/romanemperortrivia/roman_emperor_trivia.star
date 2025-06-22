"""
Applet: WhosThatEmperor
Summary: Roman Emperor Guessing Game
Description: Guess the Roman emperor from a silhouette. Then reveal their name, reign period, and how they died.
Author: Michael Vaquier
"""

load("render.star", "render")
load("random.star", "random")
load("schema.star", "schema")
load("encoding/base64.star", "base64")

EMPERORS = [
    {"name":"Augustus","Born":"63BC","Died":"14AD","Rise":"Birth","Reign Start":"27BC","Reign End":"14AD","Death":"Killed by Wife"},
    {"name":"Tiberius","Born":"42BC","Died":"37AD","Rise":"Birth","Reign Start":"14AD","Reign End":"37AD","Death":"Killed by Other Emperor"},
    {"name":"Caligula","Born":"12AD","Died":"41AD","Rise":"Birth","Reign Start":"37AD","Reign End":"41AD","Death":"Killed by Senate"},
    {"name":"Claudius","Born":"10BC","Died":"54AD","Rise":"Birth","Reign Start":"41AD","Reign End":"54AD","Death":"Killed by Wife"},
    {"name":"Nero","Born":"37AD","Died":"68AD","Rise":"Birth","Reign Start":"54AD","Reign End":"68AD","Death":"Suicide"},
    {"name":"Galba","Born":"3BC","Died":"69AD","Rise":"Seized Power","Reign Start":"68AD","Reign End":"69AD","Death":"Killed by Other Emperor"},
    {"name":"Otho","Born":"32AD","Died":"69AD","Rise":"Appt. by Imperial Guard","Reign Start":"69AD","Reign End":"69AD","Death":"Suicide"},
    {"name":"Vitellius","Born":"15AD","Died":"69AD","Rise":"Seized Power","Reign Start":"69AD","Reign End":"69AD","Death":"Killed by Other Emperor"},
    {"name":"Vespasian","Born":"9AD","Died":"79AD","Rise":"Seized Power","Reign Start":"69AD","Reign End":"79AD","Death":"Disease"},
    {"name":"Titus","Born":"39AD","Died":"81AD","Rise":"Birth","Reign Start":"79AD","Reign End":"81AD","Death":"Disease"},
    {"name":"Domitian","Born":"51AD","Died":"96AD","Rise":"Birth","Reign Start":"81AD","Reign End":"96AD","Death":"Killed by Court Officials"},
    {"name":"Nerva","Born":"30AD","Died":"98AD","Rise":"Appt. by Senate","Reign Start":"96AD","Reign End":"98AD","Death":"Disease"},
    {"name":"Trajan","Born":"53AD","Died":"117AD","Rise":"Birth","Reign Start":"98AD","Reign End":"117AD","Death":"Disease"},
    {"name":"Hadrian","Born":"76AD","Died":"138AD","Rise":"Birth","Reign Start":"117AD","Reign End":"138AD","Death":"Heart Failure"},
    {"name":"Antonius Pius","Born":"86AD","Died":"161AD","Rise":"Birth","Reign Start":"138AD","Reign End":"161AD","Death":"Disease"},
    {"name":"Marcus Aurelius","Born":"121AD","Died":"180AD","Rise":"Birth","Reign Start":"161AD","Reign End":"180AD","Death":"Disease"},
    {"name":"Lucius Verus","Born":"130AD","Died":"169AD","Rise":"Birth","Reign Start":"161AD","Reign End":"169AD","Death":"Disease"},
    {"name":"Commodus","Born":"161AD","Died":"192AD","Rise":"Birth","Reign Start":"177AD","Reign End":"192AD","Death":"Killed by Imperial Guard"},
    {"name":"Pertinax","Born":"126AD","Died":"193AD","Rise":"Appt. by Imperial Guard","Reign Start":"193AD","Reign End":"193AD","Death":"Killed by Imperial Guard"},
    {"name":"Didius Julianus","Born":"133AD","Died":"193AD","Rise":"Purchase","Reign Start":"193AD","Reign End":"193AD","Death":"Executed by Senate"},
    {"name":"Septimus Severus","Born":"145AD","Died":"211AD","Rise":"Seized Power","Reign Start":"193AD","Reign End":"211AD","Death":"Disease"},
    {"name":"Caracalla","Born":"188AD","Died":"217AD","Rise":"Birth","Reign Start":"198AD","Reign End":"217AD","Death":"Killed by Other Emperor"},
    {"name":"Geta","Born":"189AD","Died":"211AD","Rise":"Birth","Reign Start":"209AD","Reign End":"211AD","Death":"Killed by Other Emperor"},
    {"name":"Macrinus","Born":"165AD","Died":"218AD","Rise":"Seized Power","Reign Start":"217AD","Reign End":"218AD","Death":"Executed by Other Emperor"},
    {"name":"Elagabalus","Born":"203AD","Died":"222AD","Rise":"Birth","Reign Start":"218AD","Reign End":"222AD","Death":"Killed by Imperial Guard"},
    {"name":"Severus Alexander","Born":"208AD","Died":"235AD","Rise":"Birth","Reign Start":"222AD","Reign End":"235AD","Death":"Killed by Own Army"},
    {"name":"Maximinus I","Born":"173AD","Died":"238AD","Rise":"Appt. by Imperial Guard","Reign Start":"235AD","Reign End":"238AD","Death":"Killed by Imperial Guard"},
    {"name":"Gordian I","Born":"159AD","Died":"238AD","Rise":"Appt. by Senate","Reign Start":"238AD","Reign End":"238AD","Death":"Suicide"},
    {"name":"Gordian II","Born":"192AD","Died":"238AD","Rise":"Appt. by Senate","Reign Start":"238AD","Reign End":"238AD","Death":"Executed by Other Emperor"},
    {"name":"Pupienus","Born":"178AD","Died":"238AD","Rise":"Appt. by Senate","Reign Start":"238AD","Reign End":"238AD","Death":"Killed by Imperial Guard"},
    {"name":"Balbinus","Born":"178AD","Died":"238AD","Rise":"Appt. by Senate","Reign Start":"238AD","Reign End":"238AD","Death":"Killed by Imperial Guard"},
    {"name":"Gordian III","Born":"225AD","Died":"244AD","Rise":"Appt. by Senate","Reign Start":"238AD","Reign End":"244AD","Death":"Died in Battle"},
    {"name":"Philip I","Born":"204AD","Died":"249AD","Rise":"Seized Power","Reign Start":"244AD","Reign End":"249AD","Death":"Executed by Other Emperor"},
    {"name":"Trajan Decius","Born":"201AD","Died":"251AD","Rise":"Appt. by Army","Reign Start":"249AD","Reign End":"251AD","Death":"Died in Battle"},
    {"name":"Hostilian","Born":"230AD","Died":"251AD","Rise":"Birth","Reign Start":"251AD","Reign End":"251AD","Death":"Disease"},
    {"name":"Trebonianus Gallus","Born":"206AD","Died":"253AD","Rise":"Appt. by Army","Reign Start":"251AD","Reign End":"253AD","Death":"Killed by Other Emperor"},
    {"name":"Aemilian","Born":"207AD","Died":"253AD","Rise":"Appt. by Army","Reign Start":"253AD","Reign End":"253AD","Death":"Killed by Other Emperor"},
    {"name":"Valerian","Born":"195AD","Died":"264AD","Rise":"Appt. by Army","Reign Start":"253AD","Reign End":"260AD","Death":"Captivity by Opposing Army"},
    {"name":"Gallienus","Born":"218AD","Died":"268AD","Rise":"Birth","Reign Start":"253AD","Reign End":"268AD","Death":"Killed by Own Army"},
    {"name":"Claudius Gothicus","Born":"213AD","Died":"270AD","Rise":"Seized Power","Reign Start":"268AD","Reign End":"270AD","Death":"Disease"},
    {"name":"Quintillus","Born":"212AD","Died":"270AD","Rise":"Birth","Reign Start":"270AD","Reign End":"270AD","Death":"Unknown"},
    {"name":"Aurelian","Born":"214AD","Died":"275AD","Rise":"Appt. by Army","Reign Start":"270AD","Reign End":"275AD","Death":"Killed by Imperial Guard"},
    {"name":"Tacitus","Born":"200AD","Died":"276AD","Rise":"Appt. by Senate","Reign Start":"275AD","Reign End":"276AD","Death":"Disease"},
    {"name":"Florian","Born":"Unknown","Died":"276AD","Rise":"Birth","Reign Start":"276AD","Reign End":"276AD","Death":"Killed by Own Army"},
    {"name":"Probus","Born":"232AD","Died":"282AD","Rise":"Appt. by Army","Reign Start":"276AD","Reign End":"282AD","Death":"Killed by Own Army"},
    {"name":"Carus","Born":"230AD","Died":"283AD","Rise":"Seized Power","Reign Start":"282AD","Reign End":"283AD","Death":"Lightning"},
    {"name":"Numerian","Born":"Unknown","Died":"284AD","Rise":"Birth","Reign Start":"283AD","Reign End":"284AD","Death":"Unknown"},
    {"name":"Carinus","Born":"Unknown","Died":"285AD","Rise":"Birth","Reign Start":"283AD","Reign End":"285AD","Death":"Died in Battle"},
    {"name":"Diocletian","Born":"244AD","Died":"311AD","Rise":"Seized Power","Reign Start":"284AD","Reign End":"305AD","Death":"Disease"},
    {"name":"Maximian","Born":"250AD","Died":"310AD","Rise":"Appt. by Emperor","Reign Start":"286AD","Reign End":"305AD","Death":"Suicide"},
    {"name":"Constantius I","Born":"250AD","Died":"306AD","Rise":"Appt. by Emperor","Reign Start":"305AD","Reign End":"306AD","Death":"Natural Causes"},
    {"name":"Galerius","Born":"260AD","Died":"311AD","Rise":"Appt. by Emperor","Reign Start":"305AD","Reign End":"311AD","Death":"Disease"},
    {"name":"Severus II","Born":"Unknown","Died":"307AD","Rise":"Appt. by Emperor","Reign Start":"305AD","Reign End":"307AD","Death":"Killed by Other Emperor"},
    {"name":"Constantine the Great","Born":"272AD","Died":"337AD","Rise":"Birth","Reign Start":"306AD","Reign End":"337AD","Death":"Disease"},
    {"name":"Maxentius","Born":"278AD","Died":"312AD","Rise":"Birth","Reign Start":"306AD","Reign End":"312AD","Death":"Executed by Other Emperor"},
    {"name":"Maximinus II","Born":"270AD","Died":"313AD","Rise":"Birth","Reign Start":"311AD","Reign End":"313AD","Death":"Executed by Other Emperor"},
    {"name":"Lucinius I","Born":"250AD","Died":"325AD","Rise":"Birth","Reign Start":"308AD","Reign End":"324AD","Death":"Executed by Other Emperor"},
    {"name":"Constantine II","Born":"316AD","Died":"340AD","Rise":"Birth","Reign Start":"337AD","Reign End":"340AD","Death":"Executed by Other Emperor"},
    {"name":"Consantius II","Born":"317AD","Died":"361AD","Rise":"Birth","Reign Start":"337AD","Reign End":"361AD","Death":"Disease"},
    {"name":"Constans","Born":"320AD","Died":"350AD","Rise":"Birth","Reign Start":"337AD","Reign End":"350AD","Death":"Killed by Usurper"},
    {"name":"Vetranio","Born":"Unknown","Died":"356AD","Rise":"Seized Power","Reign Start":"350AD","Reign End":"350AD","Death":"Unknown"},
    {"name":"Julian","Born":"331AD","Died":"363AD","Rise":"Birth","Reign Start":"360AD","Reign End":"363AD","Death":"Died in Battle"},
    {"name":"Jovian","Born":"331AD","Died":"364AD","Rise":"Appt. by Army","Reign Start":"363AD","Reign End":"364AD","Death":"Fire"},
    {"name":"Valentinian I","Born":"321AD","Died":"375AD","Rise":"Election","Reign Start":"364AD","Reign End":"375AD","Death":"Aneurism"},
    {"name":"Valens","Born":"328AD","Died":"378AD","Rise":"Birth","Reign Start":"364AD","Reign End":"378AD","Death":"Died in Battle"},
    {"name":"Gratian","Born":"359AD","Died":"383AD","Rise":"Birth","Reign Start":"367AD","Reign End":"383AD","Death":"Killed by Own Army"},
    {"name":"Valentinian II","Born":"371AD","Died":"392AD","Rise":"Birth","Reign Start":"375AD","Reign End":"392AD","Death":"Suicide"},
    {"name":"Theodosius I","Born":"347AD","Died":"395AD","Rise":"Birth","Reign Start":"379AD","Reign End":"395AD","Death":"Disease"},
]

TEXT_LEN = {
    "Rise": 20,
    "Died": 20,
    "Reign End": 38,
    "Born": 20,
    "Reign Start": 48,
    "Death": 24,
}

def shuffle(lst):
    for i in range(len(lst) - 1, 0, -1):
        j = random.number(0, i)
        lst[i], lst[j] = lst[j], lst[i]
    return lst

def main(config):
    emperor = EMPERORS[random.number(0, len(EMPERORS)-1)]
    keys = [k for k in emperor.keys() if k != "name" and emperor[k] != "Unknown"]
    shuffle(keys)
    clues = keys[:3]

    show_time = float(config.get("speed", "15"))
    total_frames = int(show_time * 10)
    section_frames = total_frames // 4

    ROMAN_FACE_WIDTH = 23

    def whos_that_emperor_frame():
        return render.Padding(pad=(ROMAN_FACE_WIDTH, 0, 0, 0), child=render.WrappedText(content="Who's that Roman Emperor?", width=64-24, height=32, color="#fa0", align="center"))

    def clue_frame(hint):
        return render.Padding(
            pad=(ROMAN_FACE_WIDTH, 0, 0, 0),
            child=render.Box(
                height=32,
                width=64-ROMAN_FACE_WIDTH,
                child=render.Column(
                    main_align="center",
                    expanded=True,
                    children=[
                        render.WrappedText(content=hint + ":", width=64-ROMAN_FACE_WIDTH-1, color="#fa0", align="center"),
                        render.Padding(pad=(5, 0, 5, 0), child=render.Box(width = 64-ROMAN_FACE_WIDTH-1-10, height = 1, color = "#aaaaaa")),
                        render.WrappedText(content=emperor[hint], linespacing=0, width=64-ROMAN_FACE_WIDTH-1, color="#f00", align="center")
                    ]
                )
            )
        )

    def pre_answer_frame():
        return render.Padding(pad=(ROMAN_FACE_WIDTH, 0, 0, 0), child=render.WrappedText(content="Who's that Emperor?", width=64-24, height=32, color="#fa0", align="center"))


    def answer_frame():
        return render.Column(children=[
            render.Padding(pad=(ROMAN_FACE_WIDTH, 0, 0, 0), child=render.WrappedText(content="Who's that Emperor?", width=64-24, height=24, color="#fa0", align="center")),
            render.WrappedText(content=emperor["name"], width=64, color="#f00", align="center")
        ])
    
    frames = []

    for _ in range(section_frames // 2):
        frames.append(whos_that_emperor_frame())
        
    for _ in range(section_frames // 2):
        frames.append(clue_frame(clues[0]))

    for _ in range(section_frames // 2):
        frames.append(clue_frame(clues[1]))

    for _ in range(section_frames // 2):
        frames.append(clue_frame(clues[2]))

    for _ in range(section_frames // 2):
        frames.append(pre_answer_frame())

    for _ in range(section_frames):
        frames.append(answer_frame())

    bg = base64.decode(ROMAN_FACES[random.number(0, 2)])

    return render.Root(
        delay = 80,
        child = render.Stack(
            children = [
                render.Image(
                    src = bg,
                ),
                render.Animation(children = frames),

            ],
        ),
    )

def get_schema():
    return schema.Schema(
        version = "1",
        fields = [
            schema.Dropdown(
                id = "speed",
                name = "Speed",
                desc = "How fast to reveal all clues and name.",
                icon = "stopwatch",
                default = "15",
                options = [
                    schema.Option(display = "Slow", value = "20"),
                    schema.Option(display = "Normal", value = "15"),
                    schema.Option(display = "Fast", value = "10"),
                ],
            ),
        ],
    )


ROMAN_FACE_1 = "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"
ROMAN_FACE_2 = "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"
ROMAN_FACE_3 = "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"
ROMAN_FACES = [ROMAN_FACE_1, ROMAN_FACE_2, ROMAN_FACE_3]