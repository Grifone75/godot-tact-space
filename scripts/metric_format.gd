
class_name Metric


static func dst2str(distance:float):

    if distance < 100:
        return "d: {} m".format(["%0.2f" % (distance*10.0)],"{}")
    if distance < 100000:
        return "d: {} km".format(["%0.2f" % (distance/100)],"{}")
    if distance < 100000000:
        return "d: {} Mm".format(["%0.2f" % (distance/100000)],"{}")

static func vel2str(distance:float):

    if distance < 100:
        return "v: {} m/s".format(["%0.2f" % (distance*10.0)],"{}")
    if distance < 100000:
        return "v: {} km/s".format(["%0.2f" % (distance/100)],"{}")