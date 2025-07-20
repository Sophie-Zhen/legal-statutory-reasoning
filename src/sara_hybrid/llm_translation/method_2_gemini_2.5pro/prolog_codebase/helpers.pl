:- module(helpers,
          [ calculate_age_at_year_end/3,  % calculate_age_at_year_end(BirthYear, TargetYear, Age)
            round_to_nearest_dollar/2,      % round_to_nearest_dollar(Value, Rounded)
            tcja_active_for_tax_year/1,     % tcja_active_for_tax_year(Year)
            calculate_tax_from_brackets/3,  % calculate_tax_from_brackets(TaxableIncome, Brackets, Tax)
            sum_list/2                      % sum_list(List, Sum)
          ]).

% calculate_age_at_year_end(BirthYear, TargetYear, Age)
% A simplified age calculation. For tax law purposes, a person attains an age
% on the day before their birthday. A simple year-subtraction is sufficient
% for the statutes provided, which only check for age attainment before close of taxable year.
calculate_age_at_year_end(BirthYear, TargetYear, Age) :-
    Age is TargetYear - BirthYear.

% round_to_nearest_dollar(Value, Rounded)
round_to_nearest_dollar(Value, Rounded) :-
    Rounded is round(Value).

% tcja_active_for_tax_year(Year)
% Checks if a tax year falls within the Tax Cuts and Jobs Act period.
tcja_active_for_tax_year(Year) :-
    Year >= 2018, Year =< 2025.

% calculate_tax_from_brackets(TaxableIncome, Brackets, Tax)
% Finds the correct bracket and calculates the tax based on the formula:
% Tax = BaseTax + (Rate * (TaxableIncome - LowerBoundOfBracket))
calculate_tax_from_brackets(TaxableIncome, Brackets, Tax) :-
    find_bracket(TaxableIncome, Brackets, 0, Tax).

find_bracket(TaxableIncome, [bracket(Limit, Rate, BaseTax)|_], PrevLimit, Tax) :-
    TaxableIncome > PrevLimit,
    TaxableIncome =< Limit, !,
    Tax is BaseTax + ((TaxableIncome - PrevLimit) * Rate).
find_bracket(TaxableIncome, [bracket(CurrentLimit, _, _)|T], _, Tax) :-
    find_bracket(TaxableIncome, T, CurrentLimit, Tax).
find_bracket(TaxableIncome, [bracket(inf, Rate, BaseTax)], PrevLimit, Tax) :-
    TaxableIncome > PrevLimit, !,
    Tax is BaseTax + ((TaxableIncome - PrevLimit) * Rate).
find_bracket(0, _, _, 0). % Special case for zero income.

% sum_list(List, Sum)
sum_list([], 0).
sum_list([H|T], Sum) :-
    sum_list(T, Rest),
    Sum is H + Rest.
