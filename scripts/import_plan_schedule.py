"""Convert the planning schedule (num,date,week,unit,day_type,topic,in_class,reading,due)
into course/schedule.csv. Usage: python scripts/import_plan_schedule.py PLAN.csv"""
import csv, re, sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
TUT = [("intro_to_R", "basic_R"), ("intro_descriptive_statistics", "describing_data"), ("tutorial_tmap", "tmap"),
       ("intro_spatial_data", "describing_spatial_data"), ("intro_probability", "probability"), ("bad-air days", "probability"),
       ("Natural Samples", "clt"), ("estimation_tutorial", "estimation_sampling"),
       ("hypothesis_testing_tutorial", "hypothesis_testing"), ("ppa_tutorial", "ppa"),
       ("autocorrelation_tutorial", "autocorrelation"), ("spatial_modeling_tutorial", "regression"),
       ("GWR tutorial", "gwr"), ("clustering tutorial", "clustering"),
       ("continuous_surfaces_tutorial", "continuous_surfaces")]
FRIENDLY = {"basic_R": "Class contract and AI policy (20 min); intro to R tutorial in pairs (30 min)", "describing_data": "Partner tutorial: county vs. tract", "tmap": "Partner tutorial: equal interval vs. quantile",
            "describing_spatial_data": "Partner tutorial: mean centers of Covid", "probability": "Partner tutorial: binomial vs. normal (Charlotte bad-air days)",
            "estimation_sampling": "Partner tutorial: physical vs. mental health", "ppa": "Partner tutorial: early vs. late crime",
            "regression": "Partner tutorial: lag vs. error", "gwr": "Partner tutorial: urban vs. rural",
            "clustering": "Partner tutorial: k = 4 vs. k = 8"}
READ = [(r"^(?:NEW )?Quantitative Revolution \+ Kwan$", "quantitative-revolution;link:Kwan and Schwanen (2009) Quantitative Revolution 2|https://doi.org/10.1080/00330120902931903"),
        (r"^Intro to Space: (.*)$", r"introduction-to-space#\1"),
        (r"^(?:NEW )?Describing Spatial Data, (.*)$", r"describing-spatial-data#\1"),
        (r"^(?:NEW )?Describing Data$", "describing-data"),
        (r"^(?:NEW )?Sampling and Estimation, part 1 \+ Probability: Natural Samples$", "sampling-and-estimation#part 1;probability#Natural Samples"),
        (r"^(?:NEW )?Sampling and Estimation, (.*)$", r"sampling-and-estimation#\1"),
        (r"^(?:NEW )?Hypothesis Testing, (.*)$", r"hypothesis-testing#\1"),
        (r"^Probability: (.*)$", r"probability#\1"),
        (r"^PPA: (.*)$", r"point-pattern-analysis#\1"),
        (r"^Spatial Modeling: (.*)$", r"spatial-modeling#\1"),
        (r"^MLU-Explain Linear Regression.*$", "link:MLU-Explain: Linear Regression|https://mlu-explain.github.io/linear-regression/"),
        (r"^(?:NEW )?Beyond One Model, (.*)$", r"beyond-one-model#\1"),
        (r"^Continuous Surfaces: (.*)$", r"continuous-surfaces#\1"),
        (r"^Continuous Surfaces.*$", "continuous-surfaces"),
        (r"^(.+)$", r"text:\1")]

def main(src):
    rows = list(csv.DictReader(open(src, newline="", encoding="utf-8")))
    out, unit = [], 1
    # Keep the tutorial already assigned to a date when the new in_class text names no tutorial.
    prev_path = ROOT / "course" / "schedule.csv"
    prev = {x["date"]: x["tutorial"] for x in csv.DictReader(open(prev_path, newline="", encoding="utf-8"))} if prev_path.exists() else {}
    for r in rows:
        t = r["day_type"]
        kind = {"No class": "off", "Case study prep": "prep", "Case study": "case", "Final": "final"}.get(t, "concept")
        topic, note = r["topic"], ""
        m = re.search(r"\s*\((?:Julia away; )?guest proctor\)", topic)
        if m:
            topic, note = topic[:m.start()], "guest proctor"
        date, end = r["date"], ""
        if kind == "off":
            low = topic.lower()
            if "spring break" in low:
                topic, end = "Spring break", "2027-03-12"
            else:
                why = re.sub(r"^NO CLASS\s*\(?|\)$", "", topic).strip()
                why = "" if "julia" in why.lower() else why
                topic = f"No class: {why}" if why else "No class"
        if kind == "final":
            date = ""
        tut = next((f for k, f in TUT if k in r["in_class"]), "") or (prev.get(r["date"], "") if r["in_class"].startswith("Partner tutorial") else "")
        in_class = r["in_class"].replace("In-class, closed book", "In class, closed book")
        if in_class.startswith("Partner tutorial"):
            pass
        elif tut in FRIENDLY:
            in_class = FRIENDLY[tut]
        elif tut:
            in_class = re.sub(r"^\S+_tutorial|^New \w+ tutorial", "Partner tutorial", in_class)
        in_class = in_class.replace(" (A/B)", "")
        reading = ""
        if r["reading"]:
            for pat, rep in READ:
                if re.match(pat, r["reading"]):
                    reading = re.sub(pat, rep, r["reading"]); break
        concept = {"Final project": "Project"}.get(r["unit"], r["unit"])
        out.append({"n": r["num"], "date": date, "end_date": end, "week": r["week"],
                    "unit_no": "" if kind == "final" else str(unit), "concept": concept, "kind": kind,
                    "topic": topic, "in_class": in_class, "readings": reading, "tutorial": tut,
                    "lab": "", "due": r["due"], "note": note})
        if kind == "case":
            unit += 1
    with open(ROOT / "course" / "schedule.csv", "w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=list(out[0].keys()))
        w.writeheader(); w.writerows(out)

if __name__ == "__main__":
    main(sys.argv[1])
