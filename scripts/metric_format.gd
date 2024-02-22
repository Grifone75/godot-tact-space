
class_name Metric


static func dst2str(distance:float):

    var repr_dist = distance * 10.0 #1 unit = 10 m in simulated space

    if repr_dist < 1000:
        return "d: {} m".format(["%0.2f" % (repr_dist)],"{}")
    if repr_dist < 1000000:
        return "d: {} km".format(["%0.2f" % (repr_dist/1000)],"{}")
    if repr_dist < 1000000000:
        return "d: {} Mm".format(["%0.2f" % (repr_dist/1000000)],"{}")
    else:
        return "d: {} Gm".format(["%0.2f" % (repr_dist/1000000000)],"{}")

static func vel2str(distance:float):

    if distance < 100:
        return "v: {} m/s".format(["%0.2f" % (distance*10.0)],"{}")
    if distance < 100000:
        return "v: {} km/s".format(["%0.2f" % (distance/100)],"{}")