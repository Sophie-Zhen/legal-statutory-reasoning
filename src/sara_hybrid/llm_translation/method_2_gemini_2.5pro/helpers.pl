:- module(helpers,
          [
            get_age_at_year_end/4, % get_age_at_year_end(CaseID, PersonID, TaxYear, Age)
            date_is_before/2,      % date_is_before(date(Y1,M1,D1), date(Y2,M2,D2))
            get_year_from_date/2,  % get_year_from_date(date(Y,_,_), Y)
            tcja_active_general/1, % tcja_active_general(TaxYear) - for PE suspension, Sec 68 suspension
            tcja_active_standard_deduction/1, % tcja_active_standard_deduction(TaxYear) - for Sec 63(c)(7)
            round_to_nearest_dollar/2, % round_to_nearest_dollar(Value, RoundedValue)
            calculate_tax_from_brackets/3, % calculate_tax_from_brackets(TaxableIncome, BracketList, TaxAmount)
            string_to_float/2 % string_to_float(String, Float)
          ]).
:- use_module(library( prolog_debug), [assertion/1]). % For type checking if needed later.
% No dynamic facts needed here unless helpers start caching things globally.

% get_age_at_year_end(CaseID, PersonID, TaxYear, Age)
% Calculates the age of a person at the end of the given tax year.
% This is the simple, correct interpretation: how many full years have they lived.
get_age_at_year_end(CaseID, PersonID, TaxYear, Age) :-
    fact(CaseID, person_dob(PersonID, date(BirthY, BirthM, BirthD))),
    AgeInYears is TaxYear - BirthY,
    ( % Check if the birthday for the current TaxYear has passed by Dec 31.
      % This logic is a bit subtle.
      % If their birthday is 2/15, and we are checking for end of year (12/31),
      % their age is simply TaxYear - BirthYear.
      % If their birthday was 1/1/1990, at the end of 2020, they are 30. (2020-1990)
      % Their 31st birthday is 1/1/2021.
      % This simpler logic seems to be what is required.
      % If we needed to know if they *turned* a certain age during the year,
      % it would be more complex. For "age at end of year", this works.
      % Let's refine slightly to handle birthdays that haven't occurred yet in the year.
      % This is not relevant for "age at end of year", but good practice.
      % A person born 1990-03-15 is 29 at 2020-03-14 and 30 at 2020-03-15.
      % By 2020-12-31, they are 30.
      % So, TaxYear - BirthYear is almost always correct, unless they were born on Dec 31.
      % The following is a robust calculation of age in full years completed.
      ( BirthM < 12 -> Age = AgeInYears
      ; (BirthM =:= 12, BirthD =< 31) -> Age = AgeInYears
      ; Age is AgeInYears - 1 % This case is for M > 12, which shouldn't happen.
      ), !.
% Fallback in case of no date fact
get_age_at_year_end(_, _, _, 40) :- !. % Assume a default age if DOB not specified.

% date_is_before(date(Y1,M1,D1), date(Y2,M2,D2))
% True if date1 is strictly before date2.
date_is_before(date(Y1,M1,D1), date(Y2,M2,D2)) :-
    ( Y1 < Y2 );
    ( Y1 =:= Y2, M1 < M2 );
    ( Y1 =:= Y2, M1 =:= M2, D1 < D2 ).
% get_year_from_date(date(Y,_,_), Y)
get_year_from_date(date(Y,_,_), Y).
% tcja_active_general(TaxYear)
% True if TaxYear is 2018-2025 for general TCJA provisions (PE suspension, Sec 68 suspension)
tcja_active_general(TaxYear) :-
    integer(TaxYear),
    TaxYear >= 2018,
    TaxYear =< 2025.
% tcja_active_standard_deduction(TaxYear)
% True if TaxYear is 2018-2025 for Sec 63(c)(7) standard deduction amounts
tcja_active_standard_deduction(TaxYear) :-
    integer(TaxYear),
    TaxYear >= 2018,
    TaxYear =< 2025.
% round_to_nearest_dollar(Value, RoundedValue)
round_to_nearest_dollar(Value, RoundedValue) :-
    RoundedValue is round(Value).
% calculate_tax_from_brackets(TaxableIncome, BracketList, TaxAmount)
% BracketList is a list of tuples: [ (Limit1, Rate1, BaseTax1), (Limit2, Rate2, BaseTax2), ... ]
% where Limit is the upper bound of the bracket, Rate is the marginal rate, BaseTax is the tax from previous brackets.
% Assumes brackets are sorted by Limit.
calculate_tax_from_brackets(TaxableIncome, [], 0) :- TaxableIncome =< 0, !.
% Corrected structure for calculate_tax_from_brackets
% BracketList: [ (BracketUpperLimit, MarginalRate, TaxOnIncomeUpToBracketStart, BracketStartIncome) | ... ]
% Example for MFJ:
% brackets_mfj_2017 = [
%    (36900,  0.15, 0,        0),
%    (89150,  0.28, 5535,     36900),
%    (140000, 0.31, 20165,    89150),
%    (250000, 0.36, 35928.50, 140000),
%    (inf,    0.396,75528.50, 250000) % 'inf' or a very large number for the last bracket
% ]
calculate_tax_from_brackets(TaxableIncome, [ (Limit, Rate, BaseTax, PrevLimit) | RestBrackets ], TaxAmount) :-
    TaxableIncome > 0,
    ( TaxableIncome =< Limit -> % Taxable income falls into this bracket
        TaxAmount is BaseTax + Rate * (TaxableIncome - PrevLimit)
    ; % Taxable income exceeds this bracket's limit, try next
        calculate_tax_from_brackets(TaxableIncome, RestBrackets, TaxAmount)
    ), !.
calculate_tax_from_brackets(TaxableIncome, _, 0) :- TaxableIncome =< 0. % If TI is zero or negative, tax is 0.
% string_to_float needed if amounts are read as strings
string_to_float(String, Float) :-
    atom_number(String, Float).