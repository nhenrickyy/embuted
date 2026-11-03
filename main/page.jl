
using Genie
using Genie.Router
using Genie.Renderer.Html

# Codificação de URL
function url_encode(s)
    io = IOBuffer()
    for b in codeunits(s)
        if (b >= 0x41 && b <= 0x5a) ||
           (b >= 0x61 && b <= 0x7a) ||
           (b >= 0x30 && b <= 0x39) ||
           b in (0x2d, 0x2e, 0x5f, 0x7e)
            print(io, Char(b))
        else
            print(io, "%", uppercase(string(b, base=16, pad=2)))
        end
    end
    return String(take!(io))
end

function escape_html(s)
    replace(string(s),
        "&" => "&amp;",
        "<" => "&lt;",
        ">" => "&gt;",
        "\"" => "&quot;",
        "'" => "&#39;"
    )
end

route("/") do
    query = strip(string(params(:q, "")))
    safe_query = escape_html(query)

    map_url = isempty(query) ? "" :
        "https://maps.google.com/maps?q=$(url_encode(query))&output=embed"

    map_content = isempty(query) ?
        """<div class="empty">
             <div class="pin">⌖</div>
             <h2>Explore novos lugares</h2>
             <p>Pesquise um endereço ou local para visualizar no mapa.</p>
           </div>""" :
        """<iframe
             src="$map_url"
             loading="lazy"
             allowfullscreen>
           </iframe>"""

    html("""
    <!DOCTYPE html>
    <html lang="pt-BR">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>Explora — Buscador de lugares</title>

        <style>
            * {
                margin: 0;
                padding: 0;
                box-sizing: border-box;
            }

            body {
                font-family: Arial, sans-serif;
                background: #f5f6f8;
                color: #202124;
            }

            header {
                background: white;
                padding: 22px 7%;
                border-bottom: 1px solid #e8e8e8;
            }

            .logo {
                font-size: 23px;
                font-weight: 800;
                color: #2563eb;
            }

            main {
                max-width: 1200px;
                margin: 45px auto;
                padding: 0 22px;
            }

            .intro {
                margin-bottom: 25px;
            }

            .intro h1 {
                font-size: 32px;
                margin-bottom: 10px;
            }

            .intro p {
                color: #737780;
            }

            .search {
                display: flex;
                gap: 10px;
                background: white;
                padding: 10px;
                border-radius: 14px;
                border: 1px solid #e5e7eb;
                margin-bottom: 25px;
                box-shadow: 0 5px 20px #00000008;
            }

            .search input {
                flex: 1;
                min-width: 0;
                border: none;
                outline: none;
                padding: 12px;
                font-size: 16px;
            }

            .search button {
                background: #2563eb;
                color: white;
                border: none;
                border-radius: 9px;
                padding: 0 25px;
                font-size: 15px;
                font-weight: bold;
                cursor: pointer;
            }

            .search button:hover {
                background: #1d4ed8;
            }

            .map-container {
                height: 520px;
                background: white;
                border-radius: 16px;
                overflow: hidden;
                border: 1px solid #e5e7eb;
                box-shadow: 0 5px 20px #00000008;
            }

            iframe {
                width: 100%;
                height: 100%;
                border: 0;
            }

            .empty {
                height: 100%;
                display: flex;
                flex-direction: column;
                justify-content: center;
                align-items: center;
                text-align: center;
                padding: 20px;
            }

            .pin {
                font-size: 55px;
                color: #2563eb;
                margin-bottom: 15px;
            }

            .empty h2 {
                margin-bottom: 10px;
            }

            .empty p {
                color: #777;
            }

            .result {
                margin-top: 18px;
                color: #555;
                font-size: 14px;
            }

            footer {
                text-align: center;
                padding: 30px;
                color: #888;
                font-size: 13px;
            }

            @media(max-width: 600px) {
                main {
                    margin-top: 30px;
                }

                .intro h1 {
                    font-size: 25px;
                }

                .search button {
                    padding: 0 15px;
                }

                .map-container {
                    height: 430px;
                }
            }
        </style>
    </head>

    <body>
        <header>
            <div class="logo">⌖ Explora</div>
        </header>

        <main>
            <section class="intro">
                <h1>Encontre qualquer lugar.</h1>
                <p>Pesquise destinos, cidades e endereços no mapa.</p>
            </section>

            <form class="search" method="GET" action="/">
                <input
                    type="search"
                    name="q"
                    placeholder="Ex.: Rio de Janeiro, Brasil"
                    value="$safe_query"
                    required
                >
                <button type="submit">Pesquisar</button>
            </form>

            <section class="map-container">
                $map_content
            </section>

            $(isempty(query) ? "" :
                """<div class="result">
                    Local pesquisado: <strong>$safe_query</strong>
                </div>""")
        </main>

        <footer>
            Explora · Buscador de lugares
        </footer>
    </body>
    </html>
    """)
end

up(8000, async=false)
