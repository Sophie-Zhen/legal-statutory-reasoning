:- module(section7703,
          [ is_married/3,
            is_unmarried/3,
            marital_status_determined_as_of_death/3,
            is_legally_separated/3,
            is_considered_unmarried_living_apart/3,
            maintains_home_for_child_b1/4
          ]).

:- use_module(section151, [is_entitled_to_exemption_deduction/4]).
:- use_module(helpers, [get_age_at_year_end/3]).

:- multifile fact/2.

/*
    §7703. Determination of marital status
    This module encodes the rules for determining if an individual is considered
    married for tax purposes.
*/

% is_married(CaseID, Taxpayer, Year)
% §7703(a) General rule for being married.
is_married(CaseID, Taxpayer, Year) :-
    fact(CaseID, married(Taxpayer, Spouse, _)),
    fact(CaseID, married(Spouse, Taxpayer, _)),
    \+ is_unmarried(CaseID, Taxpayer, Year).

% is_unmarried(CaseID, Taxpayer, Year)
is_unmarried(CaseID, Taxpayer, Year) :-
    \+ fact(CaseID, married(Taxpayer, _, _)),
    \+ fact(CaseID, married(_, Taxpayer, _)).
is_unmarried(CaseID, Taxpayer, Year) :-
    is_legally_separated(CaseID, Taxpayer, Year).
is_unmarried(CaseID, Taxpayer, Year) :-
    is_considered_unmarried_living_apart(CaseID, Taxpayer, Year).

% marital_status_determined_as_of_death(CaseID, Taxpayer, Year)
% §7703(a)(1) Exception for spouse's death.
marital_status_determined_as_of_death(CaseID, Taxpayer, Year) :-
    fact(CaseID, married(Taxpayer, Spouse, _)),
    fact(CaseID, died(Spouse, date(Year, _, _))).

% is_legally_separated(CaseID, Taxpayer, Year)
% §7703(a)(2) Legally separated individuals are not considered married.
is_legally_separated(CaseID, Taxpayer, Year) :-
    fact(CaseID, married(Taxpayer, Spouse, _)),
    fact(CaseID, legally_separated(Taxpayer, Spouse, date(SepYear, _, _))),
    SepYear =< Year.
is_legally_separated(CaseID, Taxpayer, Year) :-
    fact(CaseID, married(Taxpayer, Spouse, _)),
    fact(CaseID, legally_separated(Spouse, Taxpayer, date(SepYear, _, _))),
    SepYear =< Year.

% is_considered_unmarried_living_apart(CaseID, Taxpayer, Year)
% §7703(b) Certain married individuals living apart.
is_considered_unmarried_living_apart(CaseID, Taxpayer, Year) :-
    fact(CaseID, married(Taxpayer, Spouse, _)),
    fact(CaseID, files_separate_return(Taxpayer, Year)),
    maintains_home_for_child_b1(CaseID, Taxpayer, _Child, Year), % Child is existentially quantified
    furnishes_over_half_cost_of_household(CaseID, Taxpayer, Year),
    spouse_not_member_of_household_last_6_months(CaseID, Taxpayer, Spouse, Year).

% maintains_home_for_child_b1(CaseID, Taxpayer, Child, Year)
% §7703(b)(1) Household constitutes principal place of abode for a child.
maintains_home_for_child_b1(CaseID, Taxpayer, Child, Year) :-
    is_entitled_to_exemption_deduction(CaseID, Taxpayer, Child, Year),
    fact(CaseID, maintains_household_for(Taxpayer, Child, Year)). % Simplified household logic

% furnishes_over_half_cost_of_household(CaseID, Taxpayer, Year)
% §7703(b)(2) Taxpayer furnishes over half the cost of maintaining the household.
furnishes_over_half_cost_of_household(CaseID, Taxpayer, Year) :-
    fact(CaseID, furnishes_over_half_cost_of_household(Taxpayer, Year)).

% spouse_not_member_of_household_last_6_months(CaseID, Taxpayer, Spouse, Year)
% §7703(b)(3) Spouse is not a member of the household for the last 6 months.
spouse_not_member_of_household_last_6_months(CaseID, Taxpayer, Spouse, Year) :-
    % This is a complex check of living arrangements. We simplify with a direct fact.
    fact(CaseID, spouse_not_member_of_household_last_6_months(Taxpayer, Spouse, Year)).
