from plotz import *
import json
import os
import math

def plot_accuracy(filename, results):
    title = results["title"]
    labels = results["labels"]
    data   = results["data"]

    with Plot(filename) as p:
        p.title = title.encode()

        p.x.label = "Condition number"
        p.x.scale = Axis.logarithmic
        p.x.min = 0
        p.x.ticks = [10*i for i in xrange(5)]

        p.y.label = "Relative error"
        p.y.label_rotate = 90
        p.y.scale = Axis.logarithmic
        p.y.min = -16
        p.y.ticks = [-16+4*i for i in range(4+1)]

        p.style.marker[0] = r"$\triangle$"
        p.style.marker[1] = r"$\bullet$"
        p.style.marker[3] = r"$+$"

        for i in xrange(len(labels)):
            p.plot(zip(data[0], data[i+1]),
                   title=labels[i].encode()).style({
                       "markers": True,
                       "line": False
                   })

        p.legend("south east")

def plot_ushift(filename, results):
    title  = results["title"]
    data   = results["data"]
    labels = results["labels"]

    with Plot(filename) as p:
        p.title = title.encode()

        p.x.label = "$\log_2(U)$"
        p.x.ticks = range(0,4+1)

        p.y.label = "Time [ns/elem]"
        p.y.label_rotate = 90
        p.y.min = 0
        p.y.ticks = 0.05

        for i in xrange(1, len(labels)):
            p.plot(zip(data[0], data[i+1]),
                   title="%d elems" % labels[i])

        p.legend("north east")

def plot_performance(filename, results):
    title  = results["title"]
    data   = results["data"]
    labels = results["labels"]

    with open("cache.json", "r") as f:
        cache = json.load(f)

    with Plot("%s" % filename) as p:
        p.title = title.encode()

        p.x.label = "Vector size"
        p.x.scale = Axis.logarithmic
        p.x.ticks = range(2,8)

        p.y.label = "Time [ns/elem]"
        p.y.label_rotate = 90
        p.y.label_shift = 2
        p.y.min = 0
        p.y.ticks = 0.2


        for i in xrange(len(labels)):
            points = zip(data[0], data[i+1])

            smoothing = 3
            for j in xrange(len(points)-smoothing):
                if points[j][0] < 100:
                    continue
                for k in range(1,smoothing+1):
                    if points[j][1] > points[j+k][1]:
                        points[j] = (points[j][0], points[j+k][1])
            if smoothing > 0:
                points = points[:-smoothing]
            p.plot(points, title=labels[i].encode())

        p.style.thickness[7] = "thin"
        p.style.color[7] = "000000"
        p.style.pattern[7] = "dashed"
        for lvl in cache:
            elems = cache[lvl]*1024/results["elem_size"]
            p.plot([(elems, 0), (elems, p.y.max)]).style({
                "color": 7,
                "thickness": 7,
                "pattern": 7,
            })
            p.tikz += r"\draw(%f,%f)node[anchor=north east]{%s};" % (math.log10(elems),
                                                                    p.y.max, lvl.encode())
            p.tikz += "\n"

        if results["elem_size"] == 16:
            p.legend("south east")
        else:
            p.legend("north east")


def plot_results(filename):
    print("-> %s" % filename)
    with open("%s.json" % filename, "r") as f:
        results = json.load(f)

    if results["type"] == "accuracy":
        plot_accuracy(filename, results)
    elif results["type"] == "ushift":
        plot_ushift(filename, results)
    elif results["type"] == "performance":
        plot_performance(filename, results)

def plot_all():
    print("Generating all plots...")
    for filename in os.listdir(os.getcwd()):
        if filename == "cache.json":
            continue
        if filename.endswith(".json"):
            plot_results(filename.replace(".json", ""))

if __name__ == "__main__":
    plot_all()
