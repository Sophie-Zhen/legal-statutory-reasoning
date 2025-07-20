:- module(section7703,
          [ is_married_a/3,                % is_married_a(Taxpayer, CaseID, Year)
            is_considered_not_married_b/3  % is_considered_not_married_b(Taxpayer, CaseID, Year)
          ]).

:- use_module(tests, [fact/2]).
:- use_module(section151, [is_entitled_to_deduction_for_dependent/4]).
:- use_module(helpers, [calculate_age_at_year_end/3]).

% §7703(a) General rule for determining marital status.
% is_married_a(Taxpayer, CaseID, Year).
is_married_a(Taxpayer, CaseID, Year) :-
    fact(CaseID, spouse(Taxpayer, Spouse)),
    % (a)(2) Not married if legally separated
    \+ (
        fact(CaseID, legally_separated(Taxpayer, Spouse, date(SepYear, _, _))),
        SepYear =< Year
    ),
    % (a)(1) Determination as of close of taxable year, unless spouse died
    (   fact(CaseID, death_of_spouse(Taxpayer, Spouse, date(DeathYear, _, _)))
    ->  % If spouse died, considered married for that year, but not subsequent years.
        DeathYear >= Year
    ;   % If no death, they are married.
        true
    ).

% §7703(b) Certain married individuals living apart.
% An individual who meets these conditions is treated as not married.
% is_considered_not_married_b(Taxpayer, CaseID, Year).
is_considered_not_married_b(Taxpayer, CaseID, Year) :-
    % Must be married under subsection (a)
    is_married_a(Taxpayer, CaseID, Year),
    % Must file a separate return
    fact(CaseID, files_separate_return(Taxpayer, Year)),
    % (1) Maintains a household for a child for > half the year
    % AND is entitled to a deduction for the child under §151
    fact(CaseID, maintains_household_for_child_over_half_year(Taxpayer, Child, Year)),
    is_entitled_to_deduction_for_dependent(Taxpayer, Child, CaseID, Year),
    % (2) Furnishes over one-half of the cost of maintaining such household
    fact(CaseID, furnishes_over_half_cost_of_household(Taxpayer, Year)),
    % (3) During the last 6 months of the taxable year, spouse is not a member of the household
    fact(CaseID, spouse_not_member_of_household_last_6_months(Taxpayer, Year)).
