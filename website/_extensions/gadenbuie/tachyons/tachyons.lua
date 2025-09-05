function Pandoc()
  if quarto.doc.is_format("html:js") then
    quarto.doc.add_html_dependency({
      name = 'tachyons',
      version = '4.12.0',
      stylesheets = { "tachyons.css", "quarto-resets.css" },
    })
  end
end