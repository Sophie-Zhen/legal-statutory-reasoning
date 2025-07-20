:- module(helpers,
          [ get_age_at_year_end/3,
            round_to_nearest_dollar/2,
            tcja_active_general/1,
            tcja_inactive_general/1,
            calculate_tax_from_brackets/3,
            get_tax_brackets_for_status/4,
            sum_list/2,
            max_list_public/2,
            string_to_atom/2
          ]).

:- use_module(knowledge_base, [tax_bracket/7]).

/*
    This module provides general-purpose helper predicates for logic and arithmetic.
    These predicates are designed to be pure and not rely on specific case data,
    which must be passed in as arguments.
*/

% get_age_at_year_end(+DateOfBirth, +TaxYear, -Age)
% Calculates the age of a person at the end of a given tax year.
% DateOfBirth is a term: date(Y, M, D).
get_age_at_year_end(date(BirthYear, _, _), TaxYear, Age) :-
    Age is TaxYear - BirthYear.

% round_to_nearest_dollar(+Value, -Rounded)
% Rounds a numeric value to the nearest integer (dollar).
round_to_nearest_dollar(Value, Rounded) :-
    Rounded is round(Value).

% tcja_active_general(+Year)
% Succeeds if the given year is within the TCJA period (2018-2025).
tcja_active_general(Year) :-
    between(2018, 2025, Year).

% tcja_inactive_general(+Year)
% Succeeds if the given year is outside the TCJA period (2018-2025).
tcja_inactive_general(Year) :-
    \+ tcja_active_general(Year).

% calculate_tax_from_brackets(+TaxableIncome, +Brackets, -Tax)
% Calculates the final tax amount based on a given income and a list of tax brackets.
% Brackets must be sorted from highest income to lowest.
calculate_tax_from_brackets(TaxableIncome, [bracket(Min, _, Base, Rate, _)|_], Tax) :-
    TaxableIncome > Min,
    !,
    Tax is Base + (TaxableIncome - Min) * Rate.
calculate_tax_from_brackets(TaxableIncome, [_|RestBrackets], Tax) :-
    calculate_tax_from_brackets(TaxableIncome, RestBrackets, Tax).
calculate_tax_from_brackets(_, [], 0). % Handles zero income or empty bracket list.

% get_tax_brackets_for_status(+Year, +FilingStatus, -Brackets)
% Retrieves the applicable list of tax brackets for a given year and filing status.
% The list is sorted in descending order of income thresholds.
get_tax_brackets_for_status(Year, FilingStatus, Brackets) :-
    findall(bracket(Min, Max, Base, Rate, ID),
            tax_bracket(Year, FilingStatus, Min, Max, Base, Rate, ID),
            AllBrackets),
    sort(1, @>, AllBrackets, Brackets). % Sort by first element (MinIncome) descending

% sum_list(+List, -Sum)
% Calculates the sum of a list of numbers.
sum_list(List, Sum) :-
    sum_list(List, 0, Sum).
sum_list([], Sum, Sum).
sum_list([H|T], Acc, Sum) :-
    NewAcc is Acc + H,
    sum_list(T, NewAcc, Sum).

% max_list_public(+List, -Max)
% Finds the maximum value in a list of numbers.
% Handles empty list by failing.
max_list_public([H|T], Max) :-
    max_list(T, H, Max).
max_list_public([], 0). % Return 0 for empty list, e.g. no earned income.

max_list([], Max, Max).
max_list([H|T], CurrentMax, Max) :-
    NewMax is max(H, CurrentMax),
    max_list(T, NewMax, Max).

% string_to_atom(+String, -Atom)
% Helper to convert between string and atom representations.
string_to_atom(String, Atom) :-
    atom_string(Atom, String).
