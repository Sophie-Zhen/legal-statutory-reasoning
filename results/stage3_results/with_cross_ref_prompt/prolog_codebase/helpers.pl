:- module(helpers,
    [
        get_age_at_year_end/3,
        tcja_active_general/1,
        s68_suspended/1,
        calculate_tax_from_brackets/3,
        round_to_nearest_dollar/2
    ]).

:- use_module(knowledge_base).

get_age_at_year_end(date(BirthYear, _, _), TaxYear, Age) :-
    Age is TaxYear - BirthYear.

tcja_active_general(Year) :-
    integer(Year),
    Year > 2017,
    Year < 2026.

s68_suspended(Year) :-
    tcja_active_general(Year).

calculate_tax_from_brackets(TaxableIncome, [bracket(LowerBound, Rate, BaseTax) | _], Tax) :-
    TaxableIncome > LowerBound,
    !,
    Excess is TaxableIncome - LowerBound,
    Tax is BaseTax + (Excess * Rate).
calculate_tax_from_brackets(TaxableIncome, [_ | RestBrackets], Tax) :-
    calculate_tax_from_brackets(TaxableIncome, RestBrackets, Tax).
calculate_tax_from_brackets(_, [], 0).

round_to_nearest_dollar(Value, RoundedValue) :-
    RoundedValue is round(Value).
