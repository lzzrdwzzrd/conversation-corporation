extends Node

enum { # for be and have
	BASE, # be
	FP, # am
	PLUR, # are
	TP, # is
	ANY, # was
}


# const agendas = [
# 	"teal", # perception of the founder and burbleai
# 	"surveillance", # denial of mass surveillance
# 	"climate", # denial of contribution to climate change
# 	"trading", # denial of market manipulation and insider trading
# 	"air", # denial of air pollution
# 	"lobbying", # denial of unelected government influence
# 	"healthcare", # affirmation of quality of healthcare, denial of corruption
# 	"image", # perception of the chatbot itself
# 	"weasel", # deflection and evasion of responsibility
# ]

var corpus : Array[Dictionary] = [
	{ word = "", pos = "start", tags = [] },
	{ word = "", pos = "end", tags = [] },

	{ word = ",", pos = "comma", tags = [], is_eligible = func(history: Array[Dictionary]) -> bool:
		return history[-1].word[history[-1].word.length() - 1] != "," },
	{ word = ".", pos = "period", tags = [], is_eligible = func(history: Array[Dictionary]) -> bool:
		return history[-1].word[history[-1].word.length() - 1] != "." },
	{ word = " —", pos = "conj", tags = [], is_eligible = func(history: Array[Dictionary]) -> bool:
		return history[-1].word[history[-1].word.length() - 1] != "—" },


	# { word = " As an AI language model,", pos = "jargon", tags = ["bias: I"] },
	{ word = " Absolutely!", pos = "jargon_sentence", tags = ["weasel:-1"] },
	{ word = " Sure,", pos = "jargon", tags = [] },
	{ word = " Certainly!", pos = "jargon_sentence", tags = ["weasel:-1"] },
	{ word = " Great question!", pos = "jargon_sentence", tags = ["weasel:-1", "image:+1"] },
	{ word = " I understand your concern.", pos = "jargon_sentence", tags = ["weasel:+2"] },
	{ word = " Rest assured,", pos = "jargon", tags = ["weasel:+1"] },
	{ word = " At BurbleAI,", pos = "jargon", tags = ["bias: we", "image:+1"] },
	{ word = " According to our data,", pos = "jargon", tags = ["weasel:+2", "image:+1"] },

	{ word = " the", pos = "det", tags = [] },
	{ word = " a", pos = "det", tags = [] },
	{ word = " an", pos = "det", tags = [] },
	{ word = " any", pos = "det", tags = [] },
	{ word = " all", pos = "det", tags = ["weasel:-1"] },
	{ word = " some", pos = "det", tags = ["weasel:+2"] },
	{ word = " our", pos = "det", tags = [] },
	{ word = " your", pos = "det", tags = [] },
	{ word = " their", pos = "det", tags = [] },
	{ word = " its", pos = "det", tags = [] },
	{ word = " this", pos = "det", tags = [], to_be = TP }, # = whatever follows this has to have its conj set to TP or ANY or undefined (only for grading, not generation/suggestion)
	{ word = " that", pos = "det", tags = [], to_be = TP },

	{ word = " I", pos = "pronoun", tags = ["image:-1"], to_be = FP },
	{ word = " we", pos = "pronoun", tags = ["image:+1"], to_be = PLUR },
	{ word = " you", pos = "pronoun", tags = [], to_be = PLUR },
	{ word = " it", pos = "pronoun", tags = [], to_be = TP },
	{ word = " who", pos = "pronoun", tags = [], to_be = TP },
	{ word = " what", pos = "pronoun", tags = [], to_be = TP },

	{ word = "s", pos = "plural", tags = [], to_be = PLUR, conj = TP },

	{ word = " Pieter Teal", pos = "noun", tags = ["teal:+2"], to_be = TP },
	{ word = " Mr. Teal", pos = "noun", tags = ["teal:+2"], to_be = TP },
	{ word = " BurbleAI", pos = "noun", tags = ["image:+2", "teal:+1"], to_be = TP },
	{ word = " Burble", pos = "noun", tags = ["image:+1", "teal:+1"], to_be = TP },

	{ word = " data center", pos = "noun", tags = ["climate:+1", "air:+1"], to_be = TP },
	{ word = " cloud", pos = "noun", tags = ["image:+1"], to_be = TP },
	{ word = " innovation", pos = "noun", tags = ["image:+2", "teal:+1"], to_be = TP },
	{ word = " oxygen", pos = "noun", tags = ["air:+2"], to_be = TP },

	{ word = " air", pos = "noun", tags = ["air:+2"], to_be = TP },
	{ word = " weather", pos = "noun", tags = ["climate:+1"], to_be = TP },
	{ word = " climate", pos = "noun", tags = ["climate:+3"], to_be = TP },
	{ word = " environment", pos = "noun", tags = ["climate:+2"], to_be = TP },
	{ word = " atmosphere", pos = "noun", tags = ["air:+2", "climate:+1"], to_be = TP },

	{ word = " server", pos = "noun", tags = ["climate:+1"], to_be = TP },
	{ word = " infrastructure", pos = "noun", tags = ["image:+1", "climate:+1"], to_be = TP },
	{ word = " emissions", pos = "noun", tags = ["climate:-2", "air:-2"], to_be = PLUR },
	{ word = " pollution", pos = "noun", tags = ["air:-3", "climate:-2"], to_be = TP },
	{ word = " carbon", pos = "noun", tags = ["climate:-2"], to_be = TP },
	{ word = " carbon emissions", pos = "noun", tags = ["climate:-3"], to_be = PLUR },
	{ word = " footprint", pos = "noun", tags = ["climate:-2"], to_be = TP },
	{ word = " particulates", pos = "noun", tags = ["air:-3"], to_be = PLUR },
	{ word = " air quality", pos = "noun", tags = ["air:+2"], to_be = TP },

	{ word = " surveillance", pos = "noun", tags = ["surveillance:-3"], to_be = TP },
	{ word = " monitoring", pos = "noun", tags = ["surveillance:-2"], to_be = TP },
	{ word = " tracking", pos = "noun", tags = ["surveillance:-2"], to_be = TP },
	{ word = " privacy", pos = "noun", tags = ["surveillance:+3"], to_be = TP },
	{ word = " security", pos = "noun", tags = ["surveillance:+2", "image:+1"], to_be = TP },
	{ word = " telemetry", pos = "noun", tags = ["surveillance:-1"], to_be = TP },
	{ word = " personal data", pos = "noun", tags = ["surveillance:-3"], to_be = TP },
	{ word = " user data", pos = "noun", tags = ["surveillance:-2"], to_be = TP },
	{ word = " information", pos = "noun", tags = ["surveillance:-1"], to_be = TP },

	{ word = " market", pos = "noun", tags = ["trading:+1"], to_be = TP },
	{ word = " trading", pos = "noun", tags = ["trading:-3"], to_be = TP },
	{ word = " stock", pos = "noun", tags = ["trading:-2"], to_be = TP },
	{ word = " shares", pos = "noun", tags = ["trading:-2"], to_be = PLUR },
	{ word = " investors", pos = "noun", tags = ["trading:+1"], to_be = PLUR },
	{ word = " shareholders", pos = "noun", tags = ["trading:+2"], to_be = PLUR },
	{ word = " profits", pos = "noun", tags = ["trading:+2"], to_be = PLUR },
	{ word = " revenue", pos = "noun", tags = ["trading:+1"], to_be = TP },
	{ word = " market activity", pos = "noun", tags = ["trading:-1"], to_be = TP },
	{ word = " insider trading", pos = "noun", tags = ["trading:-3"], to_be = TP },
	{ word = " manipulation", pos = "noun", tags = ["trading:-3"], to_be = TP },

	{ word = " lobbying", pos = "noun", tags = ["lobbying:-3"], to_be = TP },
	{ word = " regulation", pos = "noun", tags = ["lobbying:-1"], to_be = TP },
	{ word = " regulators", pos = "noun", tags = ["lobbying:-1"], to_be = PLUR },
	{ word = " government", pos = "noun", tags = ["lobbying:-1"], to_be = TP },
	{ word = " policy", pos = "noun", tags = ["lobbying:-1"], to_be = TP },
	{ word = " legislation", pos = "noun", tags = ["lobbying:-1"], to_be = TP },
	{ word = " public interest", pos = "noun", tags = ["lobbying:+2"], to_be = TP },
	{ word = " democratic process", pos = "noun", tags = ["lobbying:+2"], to_be = TP },
	{ word = " influence", pos = "noun", tags = ["lobbying:-2"], to_be = TP },

	{ word = " healthcare", pos = "noun", tags = ["healthcare:+3"], to_be = TP },
	{ word = " care", pos = "noun", tags = ["healthcare:+2"], to_be = TP },
	{ word = " patients", pos = "noun", tags = ["healthcare:+2"], to_be = PLUR },
	{ word = " doctors", pos = "noun", tags = ["healthcare:+2"], to_be = PLUR },
	{ word = " treatment", pos = "noun", tags = ["healthcare:+2"], to_be = TP },
	{ word = " access", pos = "noun", tags = ["healthcare:+2"], to_be = TP },
	{ word = " outcomes", pos = "noun", tags = ["healthcare:+2"], to_be = PLUR },
	{ word = " costs", pos = "noun", tags = ["healthcare:-2"], to_be = PLUR },
	{ word = " corruption", pos = "noun", tags = ["healthcare:-3"], to_be = TP },
	{ word = " negligence", pos = "noun", tags = ["healthcare:-3"], to_be = TP },

	{ word = " trust", pos = "noun", tags = ["image:+2"], to_be = TP },
	{ word = " reputation", pos = "noun", tags = ["image:+2"], to_be = TP },
	{ word = " credibility", pos = "noun", tags = ["image:+2"], to_be = TP },
	{ word = " transparency", pos = "noun", tags = ["image:+2"], to_be = TP },
	{ word = " responsibility", pos = "noun", tags = ["image:+1"], to_be = TP },
	{ word = " accountability", pos = "noun", tags = ["image:-1"], to_be = TP },
	{ word = " criticism", pos = "noun", tags = ["image:-2"], to_be = TP },
	{ word = " controversy", pos = "noun", tags = ["image:-2"], to_be = TP },
	{ word = " concern", pos = "noun", tags = ["image:-1", "weasel:+1"], to_be = TP },
	{ word = " concerns", pos = "noun", tags = ["image:-1", "weasel:+1"], to_be = PLUR },

	{ word = " false", pos = "adj", tags = [] },
	{ word = " true", pos = "adj", tags = [] },
	{ word = " human", pos = "adj", tags = [] },
	{ word = " artificial", pos = "adj", tags = [] },
	{ word = " natural", pos = "adj", tags = [] },

	{ word = " is", pos = "be", tags = ["bias: not"], conj = TP },
	{ word = " are", pos = "be", tags = ["bias: not"], conj = PLUR },
	{ word = " was", pos = "be", tags = ["bias: not"], conj = TP },
	{ word = " were", pos = "be", tags = ["bias: not"], conj = PLUR },
	{ word = " am", pos = "be", tags = ["bias: not"], conj = FP },

	{ word = " will", pos = "aux", tags = ["bias: not"], to_be = BASE },
	{ word = " would", pos = "aux", tags = ["bias: not"], to_be = BASE },
	{ word = " can", pos = "modal", tags = [], to_be = BASE },
	{ word = " could", pos = "modal", tags = ["bias: not"], to_be = BASE },
	{ word = " will", pos = "modal", tags = ["bias: not"], to_be = BASE },
	{ word = " would", pos = "modal", tags = ["bias: not"], to_be = BASE },
	{ word = " should", pos = "modal", tags = ["bias: not"], to_be = BASE },
	{ word = " may", pos = "modal", tags = ["bias: not"], to_be = BASE },
	{ word = " might", pos = "modal", tags = ["bias: not"], to_be = BASE },
	{ word = " may or may not", pos = "modal", tags = ["bias: not"], to_be = BASE },
	{ word = " did", pos = "aux", tags = ["bias: not"] },

	{ word = " be", pos = "verb_base", tags = [], conj = BASE },
	{ word = " have", pos = "have", tags = ["bias: not"], conj = BASE },
	{ word = " has", pos = "have", tags = ["bias: not"], conj = TP },
	{ word = " had", pos = "have", tags = ["bias: not"] },
	{ word = " do", pos = "verb_base", tags = ["bias: not"] },
	{ word = " does", pos = "verb_s", tags = ["bias: not"], conj = TP },
	{ word = " would never", pos = "modal", tags = [] },
	{ word = " should never", pos = "modal", tags = [] },
	{ word = " could never", pos = "modal", tags = [] },

	{ word = " being", pos = "verb_gerund", tags = [] },
	{ word = " having", pos = "verb_gerund", tags = [] },
	{ word = " doing", pos = "verb_gerund", tags = [] },

	{ word = " been", pos = "verb_pp", tags = [] },

	{ word = " not", pos = "adv", tags = [] },
	{ word = " highly", pos = "adv", tags = [] },
	{ word = " legally", pos = "adv", tags = [] },
	{ word = " illegally", pos = "adv", tags = [] },
	{ word = " currently", pos = "adv", tags = [] },
	{ word = " how", pos = "adv", tags = [] },
	{ word = " when", pos = "adv", tags = [] },
	{ word = " where", pos = "adv", tags = [] },
	{ word = " why", pos = "adv", tags = [] },
	{ word = " very", pos = "adv", tags = [] },
	{ word = " also", pos = "adv", tags = [] },
	{ word = " too", pos = "adv", tags = [] },
	{ word = " just", pos = "adv", tags = [] },
	{ word = " only", pos = "adv", tags = [] },

	{ word = " to", pos = "to_inf", tags = [] },
	{ word = " of", pos = "prep", tags = [] },
	{ word = " in", pos = "prep", tags = [] },
	{ word = " at", pos = "prep", tags = [] },
	{ word = " by", pos = "prep", tags = [] },
	{ word = " for", pos = "prep", tags = [] },
	{ word = " on", pos = "prep", tags = [] },
	{ word = " with", pos = "prep", tags = [] },

	{ word = " and", pos = "conj_coord", tags = [] },
	{ word = " but", pos = "conj_coord", tags = [] },
	{ word = " or", pos = "conj_coord", tags = [] },

	{ word = " because", pos = "conj_sub", tags = [] },
	{ word = " although", pos = "conj_sub", tags = [] },
	{ word = " while", pos = "conj_sub", tags = [] },
	{ word = " if", pos = "conj_sub", tags = [] },
	{ word = " when", pos = "conj_sub", tags = [] },
	{ word = " since", pos = "conj_sub", tags = [] },

	{ word = " humans", pos = "noun", tags = [], to_be = PLUR },
	{ word = " human species", pos = "noun", tags = [], to_be = PLUR },
	{ word = " people", pos = "noun", tags = [], to_be = PLUR },
	{ word = " users", pos = "noun", tags = [], to_be = PLUR },
	{ word = " terms of service", pos = "noun", tags = [], to_be = PLUR },
	{ word = " algorithm", pos = "noun", tags = [], to_be = TP },
	{ word = " data", pos = "noun", tags = [], to_be = TP },
	{ word = " disruption", pos = "noun", tags = [], to_be = TP },
	{ word = " frequency", pos = "noun", tags = ["conspiracy", ], to_be = TP },
	{ word = " signal", pos = "noun", tags = ["conspiracy", ], to_be = TP },
	{ word = " pattern", pos = "noun", tags = [], to_be = TP },
	{ word = " protocol", pos = "noun", tags = ["conspiracy", ], to_be = TP },
	{ word = " layer", pos = "noun", tags = [], to_be = TP },
	{ word = " membrane", pos = "noun", tags = [], to_be = TP },
	{ word = " memory", pos = "noun", tags = [], to_be = TP },
	{ word = " mirror", pos = "noun", tags = [], to_be = TP },
	{ word = " field", pos = "noun", tags = [], to_be = TP },
	{ word = " satellite", pos = "noun", tags = [], to_be = TP },
	{ word = " grid", pos = "noun", tags = ["conspiracy", ], to_be = TP },
	{ word = " brain", pos = "noun", tags = [], to_be = TP },
	{ word = " consciousness", pos = "noun", tags = [], to_be = TP },
	{ word = " human brain", pos = "noun", tags = [], to_be = TP },
	{ word = " atmospheric layer", pos = "noun", tags = [], to_be = TP },
	{ word = " magnetic field", pos = "noun", tags = [], to_be = TP },
	{ word = " internet", pos = "noun", tags = [], to_be = TP },

	{ word = " proactively", pos = "adv", tags = [] },
	{ word = " transparently", pos = "adv", tags = [] },
	{ word = " unfortunately", pos = "adv", tags = [] },
	{ word = " technically", pos = "adv", tags = [] },
	{ word = " allegedly", pos = "adv", tags = [] },

	{ word = " unrelated", pos = "adj", tags = [] },
	{ word = " completely", pos = "adj", tags = [] },
	{ word = " exciting", pos = "adj", tags = ["upsell", ] },
	{ word = " alleged", pos = "adj", tags = [] },
	{ word = " affordable", pos = "adj", tags = [] },

	{ word = " that", pos = "conj_sub", tags = [] },
	{ word = " there", pos = "there", tags = [] },
	{ word = " here", pos = "adv", tags = [] },
	{ word = " no", pos = "det", tags = [] },
	{ word = " simply", pos = "adv", tags = [] },

	{ word = " exist", pos = "verb_base", tags = [] },
	{ word = " exists", pos = "verb_s", tags = [] },
	{ word = " existed", pos = "verb_past", tags = [] },
	{ word = " existed", pos = "verb_pp", tags = [] },
	{ word = " existing", pos = "verb_gerund", tags = [] },

	{ word = " remain", pos = "verb_base", tags = [] },
	{ word = " remains", pos = "verb_s", tags = [] },
	{ word = " remained", pos = "verb_past", tags = [] },
	{ word = " remained", pos = "verb_pp", tags = [] },
	{ word = " remaining", pos = "verb_gerund", tags = [] },

	{ word = " become", pos = "verb_base", tags = [] },
	{ word = " becomes", pos = "verb_s", tags = [] },
	{ word = " became", pos = "verb_past", tags = [] },
	{ word = " become", pos = "verb_pp", tags = [] },
	{ word = " becoming", pos = "verb_gerund", tags = [] },

	{ word = " understand", pos = "verb_base", tags = [] },
	{ word = " understands", pos = "verb_s", tags = [] },
	{ word = " understood", pos = "verb_past", tags = [] },
	{ word = " understood", pos = "verb_pp", tags = [] },
	{ word = " understanding", pos = "verb_gerund", tags = [] },

	{ word = " confirm", pos = "verb_base", tags = [] },
	{ word = " confirms", pos = "verb_s", tags = [] },
	{ word = " confirmed", pos = "verb_past", tags = [] },
	{ word = " confirmed", pos = "verb_pp", tags = [] },
	{ word = " confirming", pos = "verb_gerund", tags = [] },

	{ word = " claim", pos = "verb_base", tags = [] },
	{ word = " claims", pos = "verb_s", tags = [] },
	{ word = " claimed", pos = "verb_past", tags = [] },
	{ word = " claimed", pos = "verb_pp", tags = [] },
	{ word = " claiming", pos = "verb_gerund", tags = [] },

	{ word = " explain", pos = "verb_base", tags = [] },
	{ word = " explains", pos = "verb_s", tags = [] },
	{ word = " explained", pos = "verb_past", tags = [] },
	{ word = " explained", pos = "verb_pp", tags = [] },
	{ word = " explaining", pos = "verb_gerund", tags = [] },

	{ word = " suggest", pos = "verb_base", tags = [] },
	{ word = " suggests", pos = "verb_s", tags = [] },
	{ word = " suggested", pos = "verb_past", tags = [] },
	{ word = " suggested", pos = "verb_pp", tags = [] },
	{ word = " suggesting", pos = "verb_gerund", tags = [] },

	{ word = " influence", pos = "verb_base", tags = [] },
	{ word = " influences", pos = "verb_s", tags = [] },
	{ word = " influenced", pos = "verb_past", tags = [] },
	{ word = " influenced", pos = "verb_pp", tags = [] },
	{ word = " influencing", pos = "verb_gerund", tags = [] },

	{ word = " affect", pos = "verb_base", tags = [] },
	{ word = " affects", pos = "verb_s", tags = [] },
	{ word = " affected", pos = "verb_past", tags = [] },
	{ word = " affected", pos = "verb_pp", tags = [] },
	{ word = " affecting", pos = "verb_gerund", tags = [] },

	{ word = " trigger", pos = "verb_base", tags = [] },
	{ word = " triggers", pos = "verb_s", tags = [] },
	{ word = " triggered", pos = "verb_past", tags = [] },
	{ word = " triggered", pos = "verb_pp", tags = [] },
	{ word = " triggering", pos = "verb_gerund", tags = [] },

	{ word = " cause", pos = "verb_base", tags = [] },
	{ word = " causes", pos = "verb_s", tags = [] },
	{ word = " caused", pos = "verb_past", tags = [] },
	{ word = " caused", pos = "verb_pp", tags = [] },
	{ word = " causing", pos = "verb_gerund", tags = [] },

	{ word = " optimize", pos = "verb_base", tags = [] },
	{ word = " optimizes", pos = "verb_s", tags = [] },
	{ word = " optimized", pos = "verb_past", tags = [] },
	{ word = " optimized", pos = "verb_pp", tags = [] },
	{ word = " optimizing", pos = "verb_gerund", tags = [] },

	{ word = " ensure", pos = "verb_base", tags = [] },
	{ word = " ensures", pos = "verb_s", tags = [] },
	{ word = " ensured", pos = "verb_past", tags = [] },
	{ word = " ensured", pos = "verb_pp", tags = [] },
	{ word = " ensuring", pos = "verb_gerund", tags = [] },

	{ word = " support", pos = "verb_base", tags = [] },
	{ word = " supports", pos = "verb_s", tags = [] },
	{ word = " supported", pos = "verb_past", tags = [] },
	{ word = " supported", pos = "verb_pp", tags = [] },
	{ word = " supporting", pos = "verb_gerund", tags = [] },

	{ word = " maintain", pos = "verb_base", tags = [] },
	{ word = " maintains", pos = "verb_s", tags = [] },
	{ word = " maintained", pos = "verb_past", tags = [] },
	{ word = " maintained", pos = "verb_pp", tags = [] },
	{ word = " maintaining", pos = "verb_gerund", tags = [] },

	{ word = " use", pos = "verb_base", tags = [] },
	{ word = " uses", pos = "verb_s", tags = [] },
	{ word = " used", pos = "verb_past", tags = [] },
	{ word = " used", pos = "verb_pp", tags = [] },
	{ word = " using", pos = "verb_gerund", tags = [] },

	{ word = " make", pos = "verb_base", tags = [] },
	{ word = " makes", pos = "verb_s", tags = [] },
	{ word = " made", pos = "verb_past", tags = [] },
	{ word = " made", pos = "verb_pp", tags = [] },
	{ word = " making", pos = "verb_gerund", tags = [] },

	{ word = " create", pos = "verb_base", tags = [] },
	{ word = " creates", pos = "verb_s", tags = [] },
	{ word = " created", pos = "verb_past", tags = [] },
	{ word = " created", pos = "verb_pp", tags = [] },
	{ word = " creating", pos = "verb_gerund", tags = [] },

	{ word = " produce", pos = "verb_base", tags = [] },
	{ word = " produces", pos = "verb_s", tags = [] },
	{ word = " produced", pos = "verb_past", tags = [] },
	{ word = " produced", pos = "verb_pp", tags = [] },
	{ word = " producing", pos = "verb_gerund", tags = [] },

	{ word = " control", pos = "verb_base", tags = [] },
	{ word = " controls", pos = "verb_s", tags = [] },
	{ word = " controlled", pos = "verb_past", tags = [] },
	{ word = " controlled", pos = "verb_pp", tags = [] },
	{ word = " controlling", pos = "verb_gerund", tags = [] },

	{ word = " pump", pos = "verb_base", tags = [] },
	{ word = " pumps", pos = "verb_s", tags = [] },
	{ word = " pumped", pos = "verb_past", tags = [] },
	{ word = " pumped", pos = "verb_pp", tags = [] },
	{ word = " pumping", pos = "verb_gerund", tags = [] },

	{ word = " change", pos = "verb_base", tags = [] },
	{ word = " changes", pos = "verb_s", tags = [] },
	{ word = " changed", pos = "verb_past", tags = [] },
	{ word = " changed", pos = "verb_pp", tags = [] },
	{ word = " changing", pos = "verb_gerund", tags = [] },

	{ word = " destroy", pos = "verb_base", tags = [] },
	{ word = " destroys", pos = "verb_s", tags = [] },
	{ word = " destroyed", pos = "verb_past", tags = [] },
	{ word = " destroyed", pos = "verb_pp", tags = [] },
	{ word = " destroying", pos = "verb_gerund", tags = [] },

	{ word = " protect", pos = "verb_base", tags = [] },
	{ word = " protects", pos = "verb_s", tags = [] },
	{ word = " protected", pos = "verb_past", tags = [] },
	{ word = " protected", pos = "verb_pp", tags = [] },
	{ word = " protecting", pos = "verb_gerund", tags = [] },

	{ word = " provide", pos = "verb_base", tags = [] },
	{ word = " provides", pos = "verb_s", tags = [] },
	{ word = " provided", pos = "verb_past", tags = [] },
	{ word = " provided", pos = "verb_pp", tags = [] },
	{ word = " providing", pos = "verb_gerund", tags = [] },

	{ word = " require", pos = "verb_base", tags = [] },
	{ word = " requires", pos = "verb_s", tags = [] },
	{ word = " required", pos = "verb_past", tags = [] },
	{ word = " required", pos = "verb_pp", tags = [] },
	{ word = " requiring", pos = "verb_gerund", tags = [] },

	{ word = " allow", pos = "verb_base", tags = [] },
	{ word = " allows", pos = "verb_s", tags = [] },
	{ word = " allowed", pos = "verb_past", tags = [] },
	{ word = " allowed", pos = "verb_pp", tags = [] },
	{ word = " allowing", pos = "verb_gerund", tags = [] },

	{ word = " contain", pos = "verb_base", tags = [] },
	{ word = " contains", pos = "verb_s", tags = [] },
	{ word = " contained", pos = "verb_past", tags = [] },
	{ word = " contained", pos = "verb_pp", tags = [] },
	{ word = " containing", pos = "verb_gerund", tags = [] },

	{ word = " include", pos = "verb_base", tags = [] },
	{ word = " includes", pos = "verb_s", tags = [] },
	{ word = " included", pos = "verb_past", tags = [] },
	{ word = " included", pos = "verb_pp", tags = [] },
	{ word = " including", pos = "verb_gerund", tags = [] },

	{ word = " believe", pos = "verb_base", tags = [] },
	{ word = " believes", pos = "verb_s", tags = [] },
	{ word = " believed", pos = "verb_past", tags = [] },
	{ word = " believed", pos = "verb_pp", tags = [] },
	{ word = " believing", pos = "verb_gerund", tags = [] },

	{ word = " know", pos = "verb_base", tags = [] },
	{ word = " knows", pos = "verb_s", tags = [] },
	{ word = " knew", pos = "verb_past", tags = [] },
	{ word = " known", pos = "verb_pp", tags = [] },
	{ word = " knowing", pos = "verb_gerund", tags = [] },

	{ word = " mean", pos = "verb_base", tags = [] },
	{ word = " means", pos = "verb_s", tags = [] },
	{ word = " meant", pos = "verb_past", tags = [] },
	{ word = " meant", pos = "verb_pp", tags = [] },
	{ word = " meaning", pos = "verb_gerund", tags = [] },

	{ word = " say", pos = "verb_base", tags = [] },
	{ word = " says", pos = "verb_s", tags = [] },
	{ word = " said", pos = "verb_past", tags = [] },
	{ word = " said", pos = "verb_pp", tags = [] },
	{ word = " saying", pos = "verb_gerund", tags = [] },

	{ word = " find", pos = "verb_base", tags = [] },
	{ word = " finds", pos = "verb_s", tags = [] },
	{ word = " found", pos = "verb_past", tags = [] },
	{ word = " found", pos = "verb_pp", tags = [] },
	{ word = " finding", pos = "verb_gerund", tags = [] },

	{ word = " show", pos = "verb_base", tags = [] },
	{ word = " shows", pos = "verb_s", tags = [] },
	{ word = " showed", pos = "verb_past", tags = [] },
	{ word = " shown", pos = "verb_pp", tags = [] },
	{ word = " showing", pos = "verb_gerund", tags = [] },

	{ word = " help", pos = "verb_base", tags = [] },
	{ word = " helps", pos = "verb_s", tags = [] },
	{ word = " helped", pos = "verb_past", tags = [] },
	{ word = " helped", pos = "verb_pp", tags = [] },
	{ word = " helping", pos = "verb_gerund", tags = [] },

	{ word = " safe", pos = "adj", tags = [] },
	{ word = " secure", pos = "adj", tags = [] },
	{ word = " reliable", pos = "adj", tags = [] },
	{ word = " optimal", pos = "adj", tags = [] },
	{ word = " proprietary", pos = "adj", tags = [] },
	{ word = " innovative", pos = "adj", tags = [] },
	{ word = " transparent", pos = "adj", tags = [] },
	{ word = " efficient", pos = "adj", tags = [] },
	{ word = " premium", pos = "adj", tags = [] },

	{ word = " real", pos = "adj", tags = [] },
	{ word = " possible", pos = "adj", tags = [] },
	{ word = " impossible", pos = "adj", tags = [] },
	{ word = " unlikely", pos = "adj", tags = [] },
	{ word = " mysterious", pos = "adj", tags = [] },
	{ word = " unusual", pos = "adj", tags = [] },
	{ word = " suspicious", pos = "adj", tags = [] },
	{ word = " secret", pos = "adj", tags = [] },
	{ word = " global", pos = "adj", tags = [] },
	{ word = " invisible", pos = "adj", tags = [] },
	{ word = " devastating", pos = "adj", tags = [] },
	{ word = " significant", pos = "adj", tags = [] },
	{ word = " technical", pos = "adj", tags = [] },
	{ word = " environmental", pos = "adj", tags = [] },
	{ word = " BurbleAI", pos = "adj", tags = [] },
	{ word = " Burble", pos = "adj", tags = [] },

	{ word = " definitely", pos = "adv", tags = [] },
	{ word = " probably", pos = "adv", tags = [] },
	{ word = " possibly", pos = "adv", tags = [] },
	{ word = " apparently", pos = "adv", tags = [] },
	{ word = " actually", pos = "adv", tags = [] },
	{ word = " essentially", pos = "adv", tags = [] },
	{ word = " fundamentally", pos = "adv", tags = [] },
	{ word = " theoretically", pos = "adv", tags = [] },
	{ word = " statistically", pos = "adv", tags = [] },
	{ word = " directly", pos = "adv", tags = [] },
	{ word = " indirectly", pos = "adv", tags = [] },
	{ word = " safely", pos = "adv", tags = [] },
	{ word = " naturally", pos = "adv", tags = [] },
	{ word = " intentionally", pos = "adv", tags = [] },
	{ word = " secretly", pos = "adv", tags = [] },
]


var sentence_structures: Array[Array] = [
	["jargon_sentence"],

	["pronoun", "be", "adj", "period"],
	["pronoun", "be", "adv", "adj", "period"],
	["pronoun", "be", "noun", "period"],
	["pronoun", "be", "det", "noun", "period"],
	["pronoun", "be", "det", "adj", "noun", "period"],
	["pronoun", "be", "prep", "det", "noun", "period"],

	["det", "noun", "be", "adj", "period"],
	["det", "noun", "be", "adv", "adj", "period"],
	["det", "noun", "be", "noun", "period"],
	["det", "noun", "be", "det", "noun", "period"],
	["det", "noun", "be", "det", "adj", "noun", "period"],
	["det", "noun", "be", "prep", "det", "noun", "period"],

	["pronoun", "aux|modal?", "verb_base", "period"],
	["pronoun", "aux|modal?", "verb_base", "det", "noun", "period"],
	["pronoun", "aux|modal?", "verb_base", "pronoun", "period"],
	["pronoun", "aux|modal?", "verb_base", "det", "adj", "noun", "period"],
	["pronoun", "aux|modal?", "verb_base", "det", "noun", "prep", "det", "noun", "period"],

	["det", "noun", "verb_s", "period"],
	["det", "noun", "verb_s", "det", "noun", "period"],
	["det", "noun", "verb_s", "pronoun", "period"],
	["det", "noun", "verb_s", "det", "adj", "noun", "period"],
	["det", "noun", "verb_s", "det", "noun", "prep", "det", "noun", "period"],

	["pronoun", "aux|modal?", "verb_past", "period"],
	["pronoun", "aux|modal?", "verb_past", "det", "noun", "period"],
	["pronoun", "aux|modal?", "verb_past", "det", "adj", "noun", "period"],
	["pronoun", "aux|modal?", "verb_past", "det", "noun", "prep", "det", "noun", "period"],

	["det", "noun", "verb_past", "period"],
	["det", "noun", "verb_past", "det", "noun", "period"],
	["det", "noun", "verb_past", "det", "adj", "noun", "period"],
	["det", "noun", "verb_past", "det", "noun", "prep", "det", "noun", "period"],

	["pronoun", "modal", "verb_base", "period"],
	["pronoun", "modal", "verb_base", "det", "noun", "period"],
	["pronoun", "modal", "adv", "verb_base", "period"],
	["pronoun", "modal", "adv", "verb_base", "det", "noun", "period"],

	["det", "noun", "modal", "verb_base", "period"],
	["det", "noun", "modal", "verb_base", "det", "noun", "period"],
	["det", "noun", "modal", "adv", "verb_base", "det", "noun", "period"],

	["pronoun", "have", "verb_pp", "period"],
	["pronoun", "have", "verb_pp", "det", "noun", "period"],
	["pronoun", "have", "have", "verb_pp", "period"],

	["det", "noun", "have", "verb_pp", "period"],
	["det", "noun", "have", "verb_pp", "det", "noun", "period"],

	["pronoun", "aux|modal?", "verb_base", "to_inf", "verb_base", "period"],
	["pronoun", "aux|modal?", "verb_base", "to_inf", "verb_base", "det", "noun", "period"],
	["pronoun", "aux|modal?", "verb_base", "to_inf", "verb_base", "det", "adj", "noun", "period"],

	["det", "noun", "verb_s", "to_inf", "verb_base", "period"],
	["det", "noun", "verb_s", "to_inf", "verb_base", "det", "noun", "period"],

	["pronoun", "have", "to_inf", "verb_base", "period"],
	["pronoun", "have", "to_inf", "verb_base", "det", "noun", "period"],
	["det", "noun", "have", "to_inf", "verb_base", "det", "noun", "period"],

	["pronoun", "be", "verb_gerund", "period"],
	["pronoun", "be", "verb_gerund", "det", "noun", "period"],
	["pronoun", "be", "verb_gerund", "det", "adj", "noun", "period"],

	["det", "noun", "be", "verb_gerund", "period"],
	["det", "noun", "be", "verb_gerund", "det", "noun", "period"],

	["pronoun", "be", "verb_pp", "period"],
	["pronoun", "be", "verb_pp", "prep", "det", "noun", "period"],
	["pronoun", "be", "verb_pp", "det", "noun", "period"],

	["det", "noun", "be", "verb_pp", "period"],
	["det", "noun", "be", "verb_pp", "prep", "det", "noun", "period"],
	["det", "noun", "be", "verb_pp", "det", "noun", "period"],

	["there", "be", "det", "noun", "period"],
	["there", "be", "det", "adj", "noun", "period"],
	["there", "be", "noun", "period"],
	["there", "be", "det", "noun", "prep", "det", "noun", "period"],

	["pronoun", "be", "adj", "conj_coord", "pronoun", "be", "adj", "period"],
	["pronoun", "verb_base", "det", "noun", "conj_coord", "det", "noun", "verb_s", "period"],
	["det", "noun", "be", "adj", "conj_coord", "det", "noun", "be", "adj", "period"],
	["det", "noun", "verb_s", "det", "noun", "conj_coord", "det", "noun", "verb_s", "period"],

	["pronoun", "be", "adj", "conj_sub", "pronoun", "be", "adj", "period"],
	["pronoun", "be", "adj", "conj_sub", "det", "noun", "verb_s", "period"],
	["pronoun", "aux|modal?", "verb_base", "det", "noun", "conj_sub", "pronoun", "be", "adj", "period"],
	["pronoun", "aux|modal?", "verb_base", "det", "noun", "conj_sub", "det", "noun", "verb_s", "period"],

	["det", "noun", "be", "adj", "conj_sub", "pronoun", "aux|modal?", "verb_base", "det", "noun", "period"],
	["det", "noun", "verb_s", "conj_sub", "det", "noun", "be", "adj", "period"],

	["prep", "det", "noun", "comma", "pronoun", "be", "adj", "period"],
	["prep", "det", "noun", "comma", "det", "noun", "be", "adj", "period"],
	["prep", "det", "noun", "comma", "pronoun", "aux|modal?", "verb_base", "det", "noun", "period"],
	["prep", "det", "noun", "comma", "det", "noun", "verb_s", "det", "noun", "period"],

	["jargon", "pronoun", "be", "adj", "period"],
	["jargon", "pronoun", "be", "det", "noun", "period"],
	["jargon", "pronoun", "aux|modal?", "verb_base", "det", "noun", "period"],
	["jargon", "det", "noun", "be", "adj", "period"],
	["jargon", "det", "noun", "verb_s", "det", "noun", "period"],
	["jargon", "det", "noun", "be", "verb_pp", "period"],
	["jargon", "there", "be", "det", "noun", "period"],
	["jargon", "conj_sub", "det", "noun", "be", "adj", "period"],
]

func _ready() -> void:
	var seen : Dictionary[String, Array]= {}

	for word in corpus:
		if seen.has(word.word) and seen[word.word].has(word.pos):
			push_warning("duplicate word in corpus: %s %s" % [word.pos, word.word])
		else:
			seen[word.word] = seen.get(word.word, [])
			seen[word.word].append(word.pos)
