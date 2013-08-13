define [], () ->
    colors =
        "A,C,E": "#2850AD"
        "B,D,F,M": "#FF6319"
        "G": "#6CBE45"
        "J,Z": "#996633"
        "L": "#A7A9AC"
        "N,Q,R": "#FCCC0A"
        "S,SI,GS,H": "#808183"
        "1,2,3": "#EE352E"
        "4,5,6,6X": "#00933C"
        "7,7X": "#B933AD"

    mapped = {}

    for key,value of colors
        for subkey in key.split(",")
            mapped[subkey] = value
    return mapped