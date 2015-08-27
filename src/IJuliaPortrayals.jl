module IJuliaPortrayals

import Base.writemime
import Base.convert

using Compat

export FromFile
export CSS, IncludeHTML, JavaScript, @JS_str, IFrame
export GIF, JPEG, PNG, SVG
export OGG, MP3, WAV
export YouTube, Vimeo


type FromFile
    path::String
end

function convert(::Type{String}, file::FromFile)
    open(file.path) do f
        readall(f)
    end
end


function embed(path, mime)
    open(path) do f
        string("data:", mime, ";base64,", base64encode(readall(f)))
    end
end


# Version 0.4.X seems to have HTML in base/docs/utils.jl
# Version 0.3.X doesnt. 
if !isdefined(:HTML)
    export HTML

    type HTML
        doc::String
    end

    writemime(io::IO, ::MIME"text/html", html::HTML) = print(io, html.doc)
end


type IncludeHTML
    src::String
end

function writemime(io::IO, ::MIME"text/html", html::IncludeHTML) 
    open(html.src) do f
        print(io, readall(f))
    end
end

type JavaScript
    code::String
end

function writemime(io::IO, ::MIME"text/html", javascript::JavaScript)
    print(io, "<script>")
    print(io, javascript.code)
    print(io, "</script>")
end

macro JS_str(script)
    script
end


type IFrame
    width::Int
    height::Int
    src::String
    border::Int
end

IFrame(width, height, src) = IFrame(width, height, src, 0)

function writemime(io::IO, ::MIME"text/html", iframe::IFrame)
    print(io, """
        <iframe 
            width="$(iframe.width)" 
            height="$(iframe.height)" 
            frameborder="($iframe.border)"
            src="$(iframe.src)">
        </iframe>
    """)
end 


type CSS
    doc::String
end

function writemime(io::IO, ::MIME"text/html", css::CSS)
    print(io, "<style>")
    print(io, css.doc)
    print(io, "</style>")
end


type SVG
    doc::String
end

writemime(io::IO, ::MIME"image/svg+xml", svg::SVG) = print(io, svg.doc)


type YouTube
    id::String
    width::Int
    height::Int
    
    YouTube(id) = new(id, 420, 315)
end

function writemime(io::IO, ::MIME"text/html", youtube::YouTube)
    print(io, """
        <iframe 
            width="$(youtube.width)" 
            height="$(youtube.height)" 
            src="https://www.youtube.com/embed/$(youtube.id)?rel=0" 
            frameborder="0" 
            allowfullscreen>
        </iframe>
    """)
end 


type Vimeo
    id::String
    width::Int
    height::Int
    
    Vimeo(id) = new(id, 500, 218)
end
function writemime(io::IO, ::MIME"text/html", vimeo::Vimeo)
    print(io, """
        <iframe 
            src="https://player.vimeo.com/video/$(vimeo.id)" 
            width="$(vimeo.width)" 
            height="$(vimeo.height)" 
            frameborder="0" 
            webkitallowfullscreen 
            mozallowfullscreen 
            allowfullscreen>
        </iframe> 
    """)
end 


type PNG
    src::String
end

writemime(io::IO, ::MIME"image/png", img::PNG) = open(img.src) do f
    print(io, readall(f))
end


type GIF
    src::String
end

function writemime(io::IO, ::MIME"text/html", img::GIF)
    src = embed(img.src, "image/gif")
    print(io, """<img src="$(src)" />""")
end


type JPEG
    src::String
end

writemime(io::IO, ::MIME"image/jpeg", img::JPEG) = open(img.src) do f
    print(io, readall(f))
end


type MP3
    src::String
    embedded::Bool
end
MP3(src) = MP3(src, false)

function writemime(io::IO, ::MIME"text/html", mp3::MP3)
    src = mp3.embedded ? embed(mp3.src, "audio/mpeg") : mp3.src
    print(io, "<audio controls>")
    print(io, """<source src="$(src)" type="audio/mpeg">""")
    print(io, "</audio>")
end


type OGG
    src::String
    embedded::Bool
end
OGG(src) = MP3(src, false)

function writemime(io::IO, ::MIME"text/html", ogg::OGG)
    src = ogg.embedded ? embed(ogg.src, "audio/ogg") : ogg.src
    print(io, "<audio controls>")
    print(io, """<source src="$(src)" type="audio/ogg">""")
    print(io, "</audio>")
end


type WAV
    src::String
    embedded::Bool
end
WAV(src) = WAV(src, false)

function writemime(io::IO, ::MIME"text/html", wav::WAV)
    src = wav.embedded ? embed(wav.src, "audio/mpeg") : wav.src
    print(io, "<audio controls>")
    print(io, """<source src="$(src)" type="audio/wav">""")
    print(io, "</audio>")
end

end 
