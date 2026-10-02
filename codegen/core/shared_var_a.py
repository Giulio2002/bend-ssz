"""Helpers shared by the generators of codegen/proofs/var that were refactored together (partition var_a).

Templates. A generator used to carry its Bend text inside the Python source: raw string constants, and f-strings
whose braces had to be doubled. That text now lives next to the generator, in codegen/proofs/var/templates/<module>.tpl,
one file per generator, divided into named sections:

    @@ section_name @@
    ... the Bend text, with ${expression} where the generator inserts a value ...
    @@ next_section @@

    TEMPLATES = Templates('var_vlist', globals())   # at the top of the generator
    TEMPLATES.text('VL_VALID')                      # a section as it is written (a static text; its own @-placeholders stay)
    TEMPLATES.render('window_1', p=p, N=N)          # a section with every ${expression} evaluated

An expression is plain Python (`${', '.join(ws)}`; it cannot contain braces). It is evaluated in the namespace of the
generator module plus the keyword arguments, so a name that is local to the generator function is passed by keyword
and a module constant is not. The text of a section is exactly what the f-string produced (a section ends where the
next marker line begins, minus that line's newline).
"""
import re

from codegen.core.paths import ROOT

TEMPLATE_DIR = ROOT / 'codegen/proofs/var/templates'
_SECTION = re.compile(r'^@@ (\w+) @@\n', re.M)
_FIELD = re.compile(r'\$\{([^{}]*)\}')


class Templates:
    """The sections of one generator's template file, read once."""

    def __init__(self, module, namespace):
        self.namespace = namespace
        with open(TEMPLATE_DIR / f'{module}.tpl', newline='') as f:
            src = f.read()
        marks = list(_SECTION.finditer(src))
        self.sections = {}
        for i, m in enumerate(marks):
            end = marks[i + 1].start() - 1 if i + 1 < len(marks) else len(src)   # the newline before the next marker is the separator
            self.sections[m.group(1)] = src[m.end():end]
        self._code = {}

    def text(self, name):
        """The section `name`, exactly as stored."""
        return self.sections[name]

    def render(self, name, **names):
        """The section `name` with every ${expression} replaced by its value, evaluated with the generator module's names and `names`."""
        env = {**self.namespace, **names}

        def value(m):
            code = self._code.get(m.group(1))
            if code is None:
                code = self._code[m.group(1)] = compile(m.group(1), f'<template {name}>', 'eval')
            return str(eval(code, env))
        return _FIELD.sub(value, self.sections[name])
