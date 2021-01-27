# NOTE Pkgs not intended to be watched by {Revise}, use them before {Revise} section

# General ----------------------------------------

# TODO Which one goes to {PackageCompiler}

# {OhMyREPL} -------------------------------------

using Crayons
using OhMyREPL  # TODO Not working with sysimg?
import OhMyREPL: Passes.SyntaxHighlighter

OhMyREPL.input_prompt!("❯ ", :black)
OhMyREPL.enable_pass!("RainbowBrackets", false)
OhMyREPL.enable_pass!("BracketHighlighter", false)

# TODO
# Markdown syntax
# OhMyREPL.Passes.BracketHighlighter.setcrayon!(
#     Crayon(foreground = :)
# )

scheme = SyntaxHighlighter.ColorScheme()

SyntaxHighlighter.keyword!(scheme,      crayon"light_cyan")
SyntaxHighlighter.function_def!(scheme, crayon"default")  # TODO
SyntaxHighlighter.macro!(scheme,        crayon"light_blue")  # TODO `@`
SyntaxHighlighter.text!(scheme,         crayon"default")  # TOO

SyntaxHighlighter.symbol!(scheme,       crayon"default")
SyntaxHighlighter.comment!(scheme,      crayon"dark_gray")
SyntaxHighlighter.call!(scheme,         crayon"light_blue")

SyntaxHighlighter.op!(scheme,           crayon"light_gray")
# TODO Brackets

SyntaxHighlighter.error!(scheme,        crayon"yellow")
SyntaxHighlighter.argdef!(scheme,       crayon"cyan")

SyntaxHighlighter.number!(scheme,       crayon"yellow")
SyntaxHighlighter.string!(scheme,       crayon"yellow")

# test_colorscheme(scheme)

SyntaxHighlighter.add!("elegant_dark", scheme)
colorscheme!("elegant_dark")


# Colors -----------------------------------------

ENV["JULIA_ERROR_COLOR"] = :red  # TODO Why this color works?
# ENV["JULIA_WARN_COLOR"] = :yellow
# ENV["JULIA_INFO_COLOR"] = :yellow

# TODO Not working
# function customize_colors(repl)
#     repl.help_color = Base.text_colors[:yellow]
# end
# atreplinit(customize_colors)

# REPL: Keybind, prompt --------------------------

import REPL
import REPL.LineEdit

# TODO Simplify with hotkey
function REPL.ends_with_semicolon(line::AbstractString)
    match = findlast(isequal(';'), line)::Union{Nothing,Int}

    # --------------------------------------------
    # CUSTOM Avoid printing for object assignment by testing if the first `=` is inside round brackets `(`
    # --------------------------------------------

    # Test: Manual or assign these to 'line' variable
    # @model Linear(x, y) = begin ; α ~ Normal() ; end
    # function f() ; a = 1 ; end
    # f(x, α, β = 1) = α .+ β*x  # TODO
    # a = 1
    # x = DataFrame(a = 1)
    # DataFrame(a = 1)
    # rand()
    # a == 1
    # a === 1

    # TODO `==` and `(` in comments
    # # a == 1
    # a = 1

    # # a == (1)
    # a = 1


    # Test for e.g. `DataFrame(a = 1)`
    first_equal_sign_idx = findfirst(isequal('='), line)::Union{Nothing, Int}

    if first_equal_sign_idx == nothing ; return false
    else
        # Test for function, macro & struct
        is__func_macro_struct =
            occursin(r"(\bfunction|@|struct|mutable struct\b)", line)

        str_to_first_equal_sign = line[1 : first_equal_sign_idx]
        has__open_bracket = occursin("(", str_to_first_equal_sign)

        if is__func_macro_struct ; return true

        elseif has__open_bracket
            has__close_bracket_followed_by_equal_sign = occursin(r"\)\s?=", line)

            # Test for e.g. `DataFrame(a = 1)`
            if ! has__close_bracket_followed_by_equal_sign ; return false
            # Test for e.g. `f(x, α, β = 1) = α .+ β*x`
            else ; return true  # TODO Validate. Should be correct
            # else
            #     first_close_bracket_idx =
            #         findfirst(isequal(')'), line)::Union{Nothing, Int}
            #     first_equal_sign_after_bracket_idx =
            #         findfirst(isequal('='), line[first_close_bracket_idx : end])
            #     str_from_close_bracket_to_equal_sign =
            #         line[first_close_bracket_idx : first_close_bracket_idx + first_equal_sign_after_bracket_idx]

            #     if occursin('=', str_from_close_bracket_to_equal_sign)
            #         return true
            #     end
            end

        elseif ! has__open_bracket
            # Test for `==` also covers the case for `===`
            str_to_first_equal_sign_plus_one = line[1 : first_equal_sign_idx + 1]
            is__non_comparison_equal_sign =
                occursin(r"(?<!=)=(?!=)", str_to_first_equal_sign_plus_one)

            if is__non_comparison_equal_sign ; return true
            else ; return false
            end
        end
    end
    # --------------------------------------------


    if match !== nothing
        # state for comment parser, assuming that the `;` isn't in a string or comment
        # so input like ";#" will still thwart this to give the wrong (anti-conservative) answer
        comment = false
        comment_start = false
        comment_close = false
        comment_multi = 0
        for c in line[(match + 1):end]
            if comment_multi > 0
                # handle nested multi-line comments
                if comment_close && c == '#'
                    comment_close = false
                    comment_multi -= 1
                elseif comment_start && c == '='
                    comment_start = false
                    comment_multi += 1
                else
                    comment_start = (c == '#')
                    comment_close = (c == '=')
                end
            elseif comment
                # handle line comments
                if c == '\r' || c == '\n'
                    comment = false
                end
            elseif comment_start
                # see what kind of comment this is
                comment_start = false
                if c == '='
                    comment_multi = 1
                else
                    comment = true
                end
            elseif c == '#'
                # start handling for a comment
                comment_start = true
            else
                # outside of a comment, encountering anything but whitespace
                # means the semi-colon was internal to the expression
                isspace(c) || return false
            end
        end
        return true
    end
    return false
end

print_response_custom = """
function REPL.ends_with_semicolon(line::AbstractString)
    match = findlast(isequal(';'), line)::Union{Nothing,Int}

    # --------------------------------------------
    # CUSTOM Avoid printing for object assignment by testing if the first `=` is inside round brackets `(`
    # --------------------------------------------

    # Test for `DataFrame(a = 1)`
    first_equal_sign_idx = findfirst(isequal('='), line)::Union{Nothing, Int}

    if first_equal_sign_idx == nothing ; return false
    else
        # Test for function, macro & struct
        is__func_macro_struct =
            occursin(r"(\bfunction|@|struct|mutable struct\b)", line)

        str_to_first_equal_sign = line[1 : first_equal_sign_idx]
        has__open_bracket = occursin("(", str_to_first_equal_sign)

        if is__func_macro_struct ; return true
        elseif has__open_bracket ; return false
        elseif ! has__open_bracket
            # Test for `==` also covers the case for `===`
            str_to_first_equal_sign_plus_one = line[1 : first_equal_sign_idx + 1]
            is__non_comparison_equal_sign =
                occursin(r"(?<!=)=(?!=)", str_to_first_equal_sign_plus_one)

            if is__non_comparison_equal_sign ; return true
            else ; return false
            end
        end
    end
    # --------------------------------------------


    if match !== nothing
        # state for comment parser, assuming that the `;` isn't in a string or comment
        # so input like ";#" will still thwart this to give the wrong (anti-conservative) answer
        comment = false
        comment_start = false
        comment_close = false
        comment_multi = 0
        for c in line[(match + 1):end]
            if comment_multi > 0
                # handle nested multi-line comments
                if comment_close && c == '#'
                    comment_close = false
                    comment_multi -= 1
                elseif comment_start && c == '='
                    comment_start = false
                    comment_multi += 1
                else
                    comment_start = (c == '#')
                    comment_close = (c == '=')
                end
            elseif comment
                # handle line comments
                if c == '\r' || c == '\n'
                    comment = false
                end
            elseif comment_start
                # see what kind of comment this is
                comment_start = false
                if c == '='
                    comment_multi = 1
                else
                    comment = true
                end
            elseif c == '#'
                # start handling for a comment
                comment_start = true
            else
                # outside of a comment, encountering anything but whitespace
                # means the semi-colon was internal to the expression
                isspace(c) || return false
            end
        end
        return true
    end
    return false
end
"""

print_response_orig = """
function REPL.ends_with_semicolon(line::AbstractString)
    match = findlast(isequal(';'), line)::Union{Nothing,Int}

    # --------------------------------------------
    # CUSTOM Avoid printing for object assignment by testing if the first `=` is inside round brackets `(`
    # --------------------------------------------

    # Test for `DataFrame(a = 1)`
    first_equal_sign_idx = findfirst(isequal('='), line)::Union{Nothing, Int}

    if first_equal_sign_idx == nothing ; return false
    else
        # Test for function, macro & struct
        is__func_macro_struct =
            occursin(r"(\bfunction|@|struct|mutable struct\b)", line)

        str_to_first_equal_sign = line[1 : first_equal_sign_idx]
        has__open_bracket = occursin("(", str_to_first_equal_sign)

        if is__func_macro_struct ; return true
        elseif has__open_bracket ; return false
        elseif ! has__open_bracket
            # Test for `==` also covers the case for `===`
            str_to_first_equal_sign_plus_one = line[1 : first_equal_sign_idx + 1]
            is__non_comparison_equal_sign =
                occursin(r"(?<!=)=(?!=)", str_to_first_equal_sign_plus_one)

            if is__non_comparison_equal_sign ; return true
            else ; return false
            end
        end
    end
    # --------------------------------------------


    if match !== nothing
        # state for comment parser, assuming that the `;` isn't in a string or comment
        # so input like ";#" will still thwart this to give the wrong (anti-conservative) answer
        comment = false
        comment_start = false
        comment_close = false
        comment_multi = 0
        for c in line[(match + 1):end]
            if comment_multi > 0
                # handle nested multi-line comments
                if comment_close && c == '#'
                    comment_close = false
                    comment_multi -= 1
                elseif comment_start && c == '='
                    comment_start = false
                    comment_multi += 1
                else
                    comment_start = (c == '#')
                    comment_close = (c == '=')
                end
            elseif comment
                # handle line comments
                if c == '\r' || c == '\n'
                    comment = false
                end
            elseif comment_start
                # see what kind of comment this is
                comment_start = false
                if c == '='
                    comment_multi = 1
                else
                    comment = true
                end
            elseif c == '#'
                # start handling for a comment
                comment_start = true
            else
                # outside of a comment, encountering anything but whitespace
                # means the semi-colon was internal to the expression
                isspace(c) || return false
            end
        end
        return true
    end
    return false
end
"""


const mykeys = Dict{Any,Any}(
    # Remove '^D'
    # "^D" => (s,o...)-> nothing,  # TODO Not working

    # Move up/dn, history next/prev
    "\\M-k" => (s,o...)->(LineEdit.edit_move_up(s)   || LineEdit.history_prev(s, LineEdit.mode(s).hist)),
    "\\M-j" => (s,o...)->(LineEdit.edit_move_down(s) || LineEdit.history_next(s, LineEdit.mode(s).hist)),

    # Move char left/right
    "\\M-h" => (s,o...)->(LineEdit.edit_move_left(s)),
    "\\M-l" => (s,o...)->(LineEdit.edit_move_right(s)),

    # Kill line forward/backward
    "\e[1;2D" => (s,o...)->(LineEdit.edit_kill_line_backwards(s)),
    "\e[1;2C" => (s,o...)->(LineEdit.edit_kill_line_forwards(s)),

    # Send Julia history
    # TODO
    # "\\M-r"    => (s,o...)->(LineEdit.enter_search(s, p, true)),
    # "..."    => (s,o...)->(enter_search(s, p, false)),
    # "\\M-r"      => (s,data,c)->(history_set_backward(data, true); history_next_result(s, data)),
    # "..."      => (s,data,c)->(history_set_backward(data, false); history_next_result(s, data)),
    "\\C-r" => (s,o...)->(run(`send_jl_history`);),

    # Insert text
    "\\M-p" => (s,o...)->(LineEdit.edit_insert(s, " |> ")),
    # Activate/restore print_response_custom/print_response_orig TODO Enter
    "\\M-m" => (s,o...)->(LineEdit.edit_insert(s, print_response_custom)),
    # TODO Not working See above
    "\\M-n" => (s,o...)->(LineEdit.edit_insert(s, print_response_orig)),
)

function customize_keys(repl)
    # # repl = Base.active_repl;
    # repl.interface = REPL.setup_interface(repl);
    # main_mode = repl.interface.modes[1]
    # hp = main_mode.hist
    # p = LineEdit.HistoryPrompt(hp)

    repl.interface = REPL.setup_interface(repl; extra_repl_keymap = mykeys)

    repl.interface.modes[2].prompt = "shell❯ ";
    repl.interface.modes[3].prompt = "help❯ ";
end

atreplinit(customize_keys)

# Revise -----------------------------------------

# NOTE Call {Revise} here for watching pkgs listed after this section

# For Julia < v1.5
atreplinit() do repl
    try
        @eval using Revise
        @async Revise.wait_steal_repl_backend()
    catch e
        @warn(e.msg)
    end
end

# TODO OhMyREPL workaround -----------------------

# Reinstall keybindings to work around https://github.com/KristofferC/OhMyREPL.jl/issues/166
@async begin  sleep(1) ; OhMyREPL.Prompt.insert_keybindings()  end

# {ClearStacktrace} ------------------------------

# TODO [Stacktrace gripes #33065](https://github.com/JuliaLang/julia/issues/33065)
using ClearStacktrace

# TODO v0.1.0
ClearStacktrace.CRAYON_HEAD[] = crayon"dark_gray";
ClearStacktrace.CRAYON_HEADSEP[] = crayon"dark_gray";
ClearStacktrace.MODULECRAYONS[] = [
    crayon"#E4CAAF", crayon"green", crayon"light_cyan"];
ClearStacktrace.TYPECOLORS[] = Any[0xCCD9DD, 0xE4CAAF, 0xDCE5EC];

# TODO New version
# ClearStacktrace.MODULECOLORS[] = [:light_blue, :light_yellow, :light_red, :light_green, :light_magenta, :light_cyan, :blue, :yellow, :red, :green, :magenta, :cyan]

# try sum(a) catch end  # TODO Not working

# {DrWatson} -------------------------------------

using DrWatson
# TODO
# if isfile("Project.toml")  @quickactivate  end
using Pkg ; if isfile("Project.toml")  Pkg.activate(".")  end

# TODO
# Pkg.UPDATED_REGISTRY_THIS_SESSION[] = false


# Custom printing --------------------------------

using PrettyPrinting: pprint
Base.show(io::IO, ::MIME"text/plain", mytype::NamedTuple) =
    pprint(io, mytype)

# _ Turing ---------------------------------------

# Adapt from {MCMCChains}
# Turing Chains TODO `using Turing` and sysimg
# TODO Rounding

using Turing, StatsBase
import DataAPI.describe

function StatsBase.summarystats(
    chains::Chains;
    sections = MCMCChains._default_sections(chains),
    append_chains::Bool = true,
    method::MCMCChains.AbstractESSMethod = ESSMethod(),
    maxlag = 250,
    etype = :bm,
    kwargs...
)
    # Store everything.
    cskip = MCMCChains.cskip
    funs = [mean∘cskip,
            std∘cskip,
            x -> quantile(cskip(x), .05),
            x -> quantile(cskip(x), .95)]
            # sem∘cskip,
            # x -> MCMCChains.mcse(cskip(x), etype; kwargs...)]
    func_names = [:mean, :std, Symbol("5%"), Symbol("95%")]  # :naive_se, :mcse]

    # Subset the chain.
    _chains = Chains(chains, MCMCChains._clean_sections(chains, sections))

    # Calculate ESS separately.
    ess_df = ess(_chains; sections = nothing, method = method, maxlag = maxlag)

    # Summarize.
    summary_df = summarize(
        _chains, funs...;
        func_names = func_names,
        append_chains = append_chains,
        additional_df = ess_df,
        name = "Summary Statistics",
        sections = nothing
    )
    return summary_df
end

function describe(
    io::IO,
    chains::Chains;
    etype = :bm,
    kwargs...
)
    dfs = vcat(summarystats(chains; etype = etype, kwargs...))
    return dfs
end


# R plot -----------------------------------------

# For quick plots - without comments (same chunks as above)

# using RCall

# reval("library(data.table)")
# @rlibrary forcats
# @rlibrary ggplot2;
# @rlibrary patchwork
# reval("suppressMessages(library(plotly))");
# reval("suppressMessages(library(theme))");
# @rlibrary workflow;
# @rlibrary ggdist;
# try ggplotly(ggplot(mapping = aes(1, 1)) + geom_line())  catch end
# @rlibrary theme;  # for {theme}-related {plotly} e.g. `theme::ggplotly`


# {PrettyTables} ---------------------------------

# using PrettyTables, DataFrames

# hl_lt_(n::Number) = Highlighter(
#     f = (data,i,j)->begin
#         if applicable(<,data[i,j],n) && data[i,j] < n
#             return true
#         else
#             return false
#         end
#     end,
#     crayon = Crayon(foreground = :light_blue)
# )

# function o(df::DataFrame, n::Real = 10)  # TODO Deal with `Inf` ?
#     n_row, n_col = size(df)
#     println("\033[38;2;228;202;175m$(n_row)×$(n_col)\033[0m")

#     half_n = min(div(n, 2), size(df, 1))
#     head_tail_idx = [collect(1:half_n)..., collect(n_row-half_n+1 : n_row)...]
#     head_tail = df[head_tail_idx, :]

#     eltypes_ = eltype.(eachcol(df))
#     num_cols, str_cols = [findall(x -> x <: type, eltypes_)
#                               for type in [Real, String]]

#     pretty_table(head_tail,
#         header_crayon = Crayon(bold = false),
#         columns_width = 8,  # Dynamic width?
#         row_names = head_tail_idx,
#         tf = borderless,
#         body_hlines = [half_n],
#         formatters      = ft_printf("%.2f", num_cols))  # TODO Decimals
#         # TODO Not working for string cols `String`
#         # highlighters    = (hl_lt_(0)))  # hl_gt(.3)
# end

# # # Test
# # using DataFrames
# # df = DataFrame(A = 1:2:200, B = rand(100), C = -rand(100), D = "haha")

# # @ptconf show_row_number = true tf = borderless formatters = ft_printf("%.3f", [2,3]) highlighters = (hl_lt_(0))
# # @pt df




# # Base.show(df::AbstractDataFrame;
# #           allrows::Bool = !get(stdout, :limit, true),
# #           allcols::Bool = !get(stdout, :limit, true),
# #           splitcols = get(stdout, :limit, true),
# #           rowlabel::Symbol = :Row,
# #           summary::Bool = true) =
# #     show(stdout, pretty_table(df, tf = borderless))
# #         #  allrows=allrows, allcols=allcols, splitcols=splitcols,
# #         #  rowlabel=rowlabel, summary=summary)


# # function _show(io::IO,
# #                df::AbstractDataFrame;
# #                allrows::Bool = !get(io, :limit, false),
# #                allcols::Bool = !get(io, :limit, false),
# #                splitcols = get(io, :limit, false),
# #                rowlabel::Symbol = :Row,
# #                summary::Bool = true,
# #                rowid=nothing)
# #     _check_consistency(df)
# #     nrows = size(df, 1)
# #     if rowid !== nothing
# #         if size(df, 2) == 0
# #             rowid = nothing
# #         elseif nrows != 1
# #             throw(ArgumentError("rowid may be passed only with a single row data frame"))
# #         end
# #     end
# #     dsize = displaysize(io)
# #     availableheight = dsize[1] - 7
# #     nrowssubset = fld(availableheight, 2)
# #     bound = min(nrowssubset - 1, nrows)
# #     if allrows || nrows <= availableheight
# #         rowindices1 = 1:nrows
# #         rowindices2 = 1:0
# #     else
# #         rowindices1 = 1:bound
# #         rowindices2 = max(bound + 1, nrows - nrowssubset + 1):nrows
# #     end
# #     maxwidths = getmaxwidths(df, io, rowindices1, rowindices2, rowlabel, rowid)
# #     width = getprintedwidth(maxwidths)
# #     showrows(io,
# #              df,
# #              rowindices1,
# #              rowindices2,
# #              maxwidths,
# #              splitcols,
# #              allcols,
# #              rowlabel,
# #              summary,
# #              rowid)
# #     return
# # end


# # using DataFrames

# # df = DataFrame(A = 1:2:20, B = rand(10), C = rand(10))

# # pretty_table(df,
# #     tf = borderless,
# #     formatters = ft_printf("%.3f", [2,3]), highlighters = (hl_lt(0.2), hl_gt(0.8)))
