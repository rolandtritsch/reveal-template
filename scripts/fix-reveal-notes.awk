/Reveal\.initialize\({/ {
    print
    in_initialize = 1
    buf_n = 0
    next
}

in_initialize && /^}\);/ {
    width = ""
    autoSlide = ""
    loop = ""
    autoSlideStoppable = ""
    slideNumber = ""

    for (i = 0; i < buf_n; i++) {
        if (buffer[i] ~ /width:/) {
            match(buffer[i], /width:"[^"]*"/)
            width = substr(buffer[i], RSTART, RLENGTH)
        }
        if (buffer[i] ~ /autoSlide:/) {
            match(buffer[i], /autoSlide:[0-9]*/)
            autoSlide = substr(buffer[i], RSTART, RLENGTH)
        }
        if (buffer[i] ~ /loop:/) {
            match(buffer[i], /loop:(true|false)/)
            loop = substr(buffer[i], RSTART, RLENGTH)
        }
        if (buffer[i] ~ /autoSlideStoppable:/) {
            match(buffer[i], /autoSlideStoppable:(true|false)/)
            autoSlideStoppable = substr(buffer[i], RSTART, RLENGTH)
        }
        if (buffer[i] ~ /slideNumber:/) {
            match(buffer[i], /slideNumber: *"[^"]*"/)
            slideNumber = substr(buffer[i], RSTART, RLENGTH)
        }
    }

    if (width != "") print "  " width ","
    if (autoSlide != "") print "  " autoSlide ","
    if (loop != "") print "  " loop ","
    if (autoSlideStoppable != "") print "  " autoSlideStoppable ","
    if (slideNumber != "") print "  " slideNumber ","
    print "  plugins: [ RevealNotes ]"
    print "});"

    delete buffer
    buf_n = 0
    in_initialize = 0
    next
}

in_initialize {
    buffer[buf_n++] = $0
    next
}

{ print }
