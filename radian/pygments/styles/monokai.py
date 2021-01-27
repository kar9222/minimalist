# -*- coding: utf-8 -*-
"""
    pygments.styles.monokai
    ~~~~~~~~~~~~~~~~~~~~~~~

    Mimic the Monokai color scheme. Based on tango.py.

    http://www.monokai.nl/blog/2006/07/15/textmate-color-theme/

    :copyright: Copyright 2006-2019 by the Pygments team, see AUTHORS.
    :license: BSD, see LICENSE for details.
"""

from pygments.style import Style
from pygments.token import Keyword, Name, Comment, String, Error, Text, \
     Number, Operator, Generic, Whitespace, Punctuation, Other, Literal

class MonokaiStyle(Style):
    """
    This style mimics the Monokai color scheme.
    """

    background_color = "#282C35"
    highlight_color = "#444956"

    styles = {
        # No corresponding class for the following:
        Text:                      "#f8f8f2", # class:  ''
        Whitespace:                "",        # class: 'w'
        Error:                     "#960050", # class: 'err'
        Other:                     "",        # class 'x'

        Comment:                   "ansibrightblack", # class: 'c'
        Comment.Multiline:         "",        # class: 'cm'
        Comment.Preproc:           "",        # class: 'cp'
        Comment.Single:            "",        # class: 'c1'
        Comment.Special:           "",        # class: 'cs'

        Keyword:                   "nobold ansibrightcyan", # class: 'k'
        Keyword.Constant:          "ansiyellow",        # class: 'kc'
        Keyword.Declaration:       "bold ansibrightblue",        # class: 'kd'
        Keyword.Namespace:         "nobold ansibrightcyan", # class: 'kn'
        # func
        Keyword.Pseudo:            "nobold ansibrightblue",        # class: 'kp'

        Keyword.Reserved:          "nobold ansibrightcyan",        # class: 'kr'
        Keyword.Type:              "nobold ansibrightblue",        # class: 'kt'

        Operator:                  "ansicyan", # class: 'o'
        Operator.Word:             "",        # class: 'ow' - like keywords

        Punctuation:               "ansibrightblack", # class: 'p'

        Name:                      "#f8f8f2", # class: 'n'
        # Name.Attribute:            "", # class: 'na' - to be revised
        Name.Builtin:              "",        # class: 'nb'
        Name.Builtin.Pseudo:       "ansiyellow",        # class: 'bp'
        Name.Class:                "", # class: 'nc' - to be revised
        Name.Constant:             "", # class: 'no' - to be revised
        Name.Decorator:            "", # class: 'nd' - to be revised
        Name.Entity:               "",        # class: 'ni'
        Name.Exception:            "", # class: 'ne'
        Name.Function:             "", # class: 'nf'
        Name.Property:             "",        # class: 'py'
        Name.Label:                "",        # class: 'nl'
        Name.Namespace:            "",        # class: 'nn' - to be revised
        Name.Other:                "", # class: 'nx'
        Name.Tag:                  "", # class: 'nt' - like a keyword
        Name.Variable:             "",        # class: 'nv' - to be revised
        Name.Variable.Class:       "",        # class: 'vc' - to be revised
        Name.Variable.Global:      "",        # class: 'vg' - to be revised
        Name.Variable.Instance:    "",        # class: 'vi' - to be revised

        Number:                    "ansiyellow", # class: 'm'
        Number.Float:              "",        # class: 'mf'
        Number.Hex:                "",        # class: 'mh'
        Number.Integer:            "",        # class: 'mi'
        Number.Integer.Long:       "",        # class: 'il'
        Number.Oct:                "",        # class: 'mo'

        Literal:                   "", # class: 'l'
        Literal.Date:              "", # class: 'ld'

        String:                    "ansiyellow", # class: 's'
        String.Backtick:           "",        # class: 'sb'
        String.Char:               "",        # class: 'sc'
        String.Doc:                "",        # class: 'sd' - like a comment
        String.Double:             "",        # class: 's2'
        String.Escape:             "nobold ansiblack", # class: 'se'
        # Temporarily using this for regex: `.` after `\`
        String.Heredoc:            "nobold ansibrightred",        # class: 'sh'
        String.Interpol:           "",        # class: 'si'
        String.Other:              "",        # class: 'sx'
        String.Regex:              "",        # class: 'sr'
        String.Single:             "",        # class: 's1'
        String.Symbol:             "",        # class: 'ss'


        Generic:                   "",        # class: 'g'
        Generic.Deleted:           "#909BAF", # class: 'gd',
        Generic.Emph:              "italic",  # class: 'ge'
        Generic.Error:             "",        # class: 'gr'
        Generic.Heading:           "",        # class: 'gh'
        Generic.Inserted:          "#DBE0FA", # class: 'gi'
        Generic.Output:            "#B2E3E5", # class: 'go'
        Generic.Prompt:            "#909BAF", # class: 'gp'
        Generic.Strong:            "",    # class: 'gs'
        Generic.Subheading:        "#6E7C96", # class: 'gu'
        Generic.Traceback:         "",        # class: 'gt'
    }
