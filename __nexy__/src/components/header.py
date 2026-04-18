from typing import *
from fastapi import *
from pathlib import Path as __Path
from nexy import Template as __Template , Import as __Import
from jinja2 import Template as __JinjaTemplate
NexyElement = Union[callable, __JinjaTemplate]

def Header() -> str:
        import os
    items = [{'label': 'showcase', 'href': '#'}, {'label': 'Docs', 'href': '#'}, {'label': 'Community', 'href': '#'}]
    vercel = os.environ.get('VERCEL')
    
    context = {"items": items, "os": os, "vercel": vercel}
    rendered = str(__Template().render("__nexy__//src/components/header.html", context))
    styles = """"""
    return rendered + styles
