from __future__ import unicode_literals
from prompt_toolkit.completion import Completer, Completion
import os
import sys
import shlex
import re

from rchitect import completion as rcompletion

from .settings import radian_settings as settings
from .latex import get_latex_completions
from .rutils import installed_packages
from .console import native_read_console  # CUSTOM TODO Removed from commits on Mar 15, 20. See various commits e.g. (https://github.com/randy3k/radian/commit/c8f78efac581c3919f3a3b7328cdddd2e3396531)

from six import text_type


TOKEN_PATTERN = re.compile(r".*?([a-zA-Z0-9._]+)$")
LIBRARY_PATTERN = re.compile(r"(?:library|require)\([\"']?(.*)$")


class RCompleter(Completer):
    def __init__(self, timeout=0.02):
        self.timeout = timeout
        super(RCompleter, self).__init__()

    def get_completions(self, document, complete_event):
        word = document.get_word_before_cursor()
        prefix_length = settings.completion_prefix_length
        if len(word) < prefix_length and not complete_event.completion_requested:
            return

        latex_comps = list(get_latex_completions(document, complete_event))
        # only return latex completions if prefix has \
        if len(latex_comps) > 0:
            for x in latex_comps:
                yield x
            return

        for x in self.get_r_completions(document, complete_event):
            yield x
        # CUSTOM: DEBUG 
        for x in self.get_package_completions(document, complete_event):
            yield x

    def get_r_completions(self, document, complete_event):
        text_before = document.current_line_before_cursor
        completion_requested = complete_event.completion_requested

        with native_read_console():
            try:
                token = rcompletion.assign_line_buffer(text_before)
                # CUSTOM: DEBUG `token` is correct  
                # CUSTOM: Line below is wrong!! 
                rcompletion.complete_token(0 if completion_requested else self.timeout)
                # CUSTOM: DEBUG
                completions = rcompletion.retrieve_completions()
                # `completions` returns `[]` vs `[{...}]` for `stringr::str_`   
                # if len(completions) == 0: print(completions)
            except Exception:
                completions = []

        for c in completions:
            if c.startswith(token):
                if c.endswith("="):
                    c = c[:-1] + " = "
                if c.endswith("::"):
                    # let get_package_completions handles it
                    continue
                # CUSTOM: Not applied. Using .../prompt_toolkit/styles/defaults.py
                yield Completion(c, -len(token))
                                #  style=...,
                                #  selected_style=...)

    def get_package_completions(self, document, complete_event):
        text_before = document.current_line_before_cursor
        text_after = document.text_after_cursor
        token_match = TOKEN_PATTERN.match(text_before)
        library_prefix = LIBRARY_PATTERN.match(text_before)
        if token_match and not library_prefix:
            token = token_match.group(1)
            instring = text_after.startswith("'") or text_after.startswith('"')
            for p in installed_packages():
                if p.startswith(token):
                    comp = p if instring else p + "::"
                    # CUSTOM: Not applied. Using .../prompt_toolkit/styles/defaults.py
                    yield Completion(comp, -len(token))
                                    # style=...,
                                    # selected_style=...)


class SmartPathCompleter(Completer):
    def get_completions(self, document, complete_event):
        text = document.text_before_cursor
        if len(text) == 0:
            return

        # do not auto complete when typing
        if not complete_event.completion_requested:
            return

        if sys.platform.startswith('win'):
            text = text.replace("\\", "/")

        directories_only = False
        quoted = False

        if text.lstrip().startswith("cd "):
            directories_only = True
            text = text.lstrip()[3:]

        try:
            path = ""
            while not path and text:
                quoted = False
                try:
                    if text.startswith('"'):
                        path = shlex.split(text + "\"")[-1]
                        quoted = True
                    elif text.startswith("'"):
                        path = shlex.split(text + "'")[-1]
                        quoted = True
                    else:
                        path = shlex.split(text)[-1]
                except RuntimeError:
                    pass
                finally:
                    if not path:
                        text = text[1:]

            path = os.path.expanduser(path)
            path = os.path.expandvars(path)
            if not os.path.isabs(path):
                path = os.path.join(os.getcwd(), path)
            basename = os.path.basename(path)
            dirname = os.path.dirname(path)

            for c in os.listdir(dirname):
                if directories_only and not os.path.isdir(os.path.join(dirname, c)):
                    continue
                if c.lower().startswith(basename.lower()):
                    if sys.platform.startswith('win') or quoted:
                        yield Completion(text_type(c), -len(basename))
                    else:
                        yield Completion(text_type(c.replace(" ", "\\ ")), -len(basename))

        except Exception:
            pass

