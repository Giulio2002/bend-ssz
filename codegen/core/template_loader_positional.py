"""Template loader of the var_* generators of partition var_b: template_loader's `Templates` with a render() whose section
argument is positional-only, so a template field may name a local variable called `name` or `section`.

See codegen/core/template_loader.py for the file format (`@@ section @@` markers, `${expression}` fields).
"""
from codegen.core.template_loader import _FIELD, Templates as _Templates


class Templates(_Templates):
    def render(self, section, /, **names):
        """The section with every ${expression} replaced by its value, evaluated with the generator module's names and `names`."""
        env = {**self.namespace, **names}

        def value(m):
            code = self._code.get(m.group(1))
            if code is None:
                code = self._code[m.group(1)] = compile(m.group(1), f'<template {section}>', 'eval')
            return str(eval(code, env))
        return _FIELD.sub(value, self.sections[section])
