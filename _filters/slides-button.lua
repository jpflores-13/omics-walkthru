-- Put a "Slides" button under the title of every chapter that has a deck.
-- Which deck (and which slide in it) a chapter opens is set once, in the
-- book's _quarto.yml, under `slide-map:`  e.g.
--   slide-map:
--     rna-seq/fastqc.qmd: "03-clean-and-check.html#/fastqc"
-- Paths are relative to the project root; decks are written to _book/slides/.
function Pandoc(doc)
  if not quarto.doc.is_format("html") or quarto.doc.is_format("revealjs") then
    return doc
  end
  local map = doc.meta["slide-map"]
  if map == nil then return doc end
  local input = quarto.doc.input_file
  local proj = quarto.project.directory or ""
  local rel = input
  if proj ~= "" and input:sub(1, #proj) == proj then
    rel = input:sub(#proj + 2)
  end
  local target = map[rel]
  if target == nil then return doc end
  target = pandoc.utils.stringify(target)
  local _, depth = rel:gsub("/", "")
  local href = string.rep("../", depth) .. "slides/" .. target
  local link = pandoc.Link(
    { pandoc.Str("\u{25B6}\u{00A0}Slides for this chapter") },
    href, "",
    pandoc.Attr("", { "btn", "btn-outline-primary", "btn-sm" }, { { "target", "_blank" } })
  )
  local div = pandoc.Div({ pandoc.Para({ link }) }, pandoc.Attr("", { "slides-button" }))
  -- insert right after the chapter title (first level-1 header), or at the top
  local pos = 1
  for i, b in ipairs(doc.blocks) do
    if b.t == "Header" and b.level == 1 then pos = i + 1; break end
  end
  table.insert(doc.blocks, pos, div)
  return doc
end
