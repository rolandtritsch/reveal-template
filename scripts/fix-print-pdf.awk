# Remove the dead pdf.css dynamic-injection script block.
# pdf.css does not exist in reveal.js 4.x/5.x; print styles are built into
# reveal.css and activated by the html.print-pdf class that reveal.js JS adds
# when ?print-pdf is present in the URL.  The script block is harmless but
# produces a net::ERR_FAILED console warning on every page load.

/<!-- If the query includes 'print-pdf', include the PDF print sheet -->/ {
    in_block = 1
    next
}

in_block && /<\/script>/ {
    in_block = 0
    next
}

in_block { next }

{ print }
