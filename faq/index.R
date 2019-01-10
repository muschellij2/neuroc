## ---- echo=FALSE, results='asis'-----------------------------------------
library(htmltools)
# func = function(id, title, inner = FALSE){
#   id_no = paste0("#", id)
#   b = paste0('<div class="panel panel-default">
#             <div class="panel-heading">
#                 <h4 class="panel-title">
#                     <a data-toggle="collapse" data-parent="#accordion" href="', id_no, '">', title, '</a>
#                 </h4>
#             </div>
#             <div id="', id, '"', ' name="', id, '" class="panel-collapse collapse ', ifelse(inner, "in", ""), '">
#                 <div class="panel-body">
#                     ')
#   HTML(b)
# }
# ender = HTML('</div> </div> </div>')
# start = HTML('<div class="bs-example">
#     <div class="panel-group" id="accordion">')
func = function(id, title, inner = FALSE){
  id_no = paste0("#", id)
  b = paste0('
<div class="card-header">
  <h4 class="mb-0">
  <a class="btn btn-primary" role="button" aria-expanded="false" data-toggle="collapse" href="', id_no, '">', title, '</a>
  </h4>
</div>
<div class="collapse" id="', id, '">

<div class="card-body">')
  HTML(b)
}
ender = HTML(' </div> </div>')
start = HTML('
<div class="accordion" id="accordionExample">
<div class="collapse show" data-parent="#accordionExample">')
end = HTML('</div> </div>')

