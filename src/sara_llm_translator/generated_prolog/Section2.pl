% §2. Definitions and special rules

% (a) Definition of surviving spouse

% (1) In general
% For purposes of section 1, the term "surviving spouse" means a taxpayer-
% (A) whose spouse died during either of the two years immediately preceding the taxable year, and
% (B) who maintains as his home a household which constitutes for the taxable year the principal place of abode (as a member of such household) of a dependent (i) who (within the meaning of section 152) is a son, stepson, daughter, or stepdaughter of the taxpayer, and (ii) with respect to whom the taxpayer is entitled to a deduction for the taxable year under section 151.

s2_a_1_surviving_spouse(Taxpayer, TaxableYear) :-
    spouse_died(Taxpayer, Spouse, Year),
    (Year =:= TaxableYear - 1 ; Year =:= TaxableYear - 2),
    maintains_household(Taxpayer, Household, TaxableYear),
    principal_place_of_abode(Household, Dependent, TaxableYear),
    member_of_household(Dependent, Household),
    dependent_of(Taxpayer, Dependent),
    (son(Dependent, Taxpayer) ; stepson(Dependent, Taxpayer) ; daughter(Dependent, Taxpayer) ; stepdaughter(Dependent, Taxpayer)),
    entitled_to_deduction(Taxpayer, Dependent, TaxableYear).

% For purposes of this paragraph, an individual shall be considered as maintaining a household only if over half of the cost of maintaining the household during the taxable year is furnished by such individual.

s2_a_1_maintains_household(Taxpayer, Household, TaxableYear) :-
    cost_of_maintaining(Household, TaxableYear, TotalCost),
    furnished_by(Taxpayer, Household, TaxableYear, FurnishedCost),
    FurnishedCost > TotalCost / 2.

% (2) Limitations
% Notwithstanding paragraph (1), for purposes of section 1 a taxpayer shall not be considered to be a surviving spouse-
% (A) if the taxpayer has remarried at any time before the close of the taxable year, or
% (B) unless, for the taxpayer's taxable year during which his spouse died, a joint return could have been made.

s2_a_2_not_surviving_spouse(Taxpayer, TaxableYear) :-
    remarried(Taxpayer, Date),
    end_of_taxable_year(TaxableYear, EndDate),
    Date =< EndDate.

s2_a_2_not_surviving_spouse(Taxpayer, TaxableYear) :-
    spouse_died(Taxpayer, Spouse, Year),
    \+ joint_return_could_have_been_made(Taxpayer, Spouse, Year).

% (b) Definition of head of household

% (1) In general
% An individual shall be considered a head of a household if, and only if, such individual is not married at the close of his taxable year, is not a surviving spouse (as defined in subsection (a)), and either-
% (A) maintains as his home a household which constitutes for more than one-half of such taxable year the principal place of abode, as a member of such household, of-
% (i) a qualifying child of the individual (as defined in section 152(c)), but not if such child-
% (I) is married at the close of the taxpayer's taxable year, and
% (II) is not a dependent of such individual by reason of section 152(b)(2) or
% (ii) any other person who is a dependent of the taxpayer, if the taxpayer is entitled to a deduction for the taxable year for such person under section 151, or
% (B) maintains a household which constitutes for such taxable year the principal place of abode of the father or mother of the taxpayer, if the taxpayer is entitled to a deduction for the taxable year for such father or mother under section 151.

s2_b_1_head_of_household(Taxpayer, TaxableYear) :-
    \+ married_at_close_of_year(Taxpayer, TaxableYear),
    \+ s2_a_1_surviving_spouse(Taxpayer, TaxableYear),
    (   (   maintains_household(Taxpayer, Household, TaxableYear),
            principal_place_of_abode(Household, QualifyingChild, TaxableYear),
            member_of_household(QualifyingChild, Household),
            qualifying_child(Taxpayer, QualifyingChild),
            \+ (married_at_close_of_year(QualifyingChild, TaxableYear), \+ dependent_of(Taxpayer, QualifyingChild))
        )
    ;   (   maintains_household(Taxpayer, Household, TaxableYear),
            principal_place_of_abode(Household, Dependent, TaxableYear),
            member_of_household(Dependent, Household),
            dependent_of(Taxpayer, Dependent),
            entitled_to_deduction(Taxpayer, Dependent, TaxableYear)
        )
    ;   (   maintains_household(Taxpayer, Household, TaxableYear),
            principal_place_of_abode(Household, Parent, TaxableYear),
            member_of_household(Parent, Household),
            (father(Parent, Taxpayer) ; mother(Parent, Taxpayer)),
            entitled_to_deduction(Taxpayer, Parent, TaxableYear)
        )
    ).

% For purposes of this paragraph, an individual shall be considered as maintaining a household only if over half of the cost of maintaining the household during the taxable year is furnished by such individual.

s2_b_1_maintains_household(Taxpayer, Household, TaxableYear) :-
    cost_of_maintaining(Household, TaxableYear, TotalCost),
    furnished_by(Taxpayer, Household, TaxableYear, FurnishedCost),
    FurnishedCost > TotalCost / 2.

% (2) Determination of status
% Notwithstanding paragraph (1),
% (A) an individual who is legally separated from his spouse under a decree of divorce or of separate maintenance shall not be considered as married;
% (B) a taxpayer shall be considered as not married at the close of his taxable year if at any time during the taxable year his spouse is a nonresident alien; and
% (C) a taxpayer shall be considered as married at the close of his taxable year if his spouse (other than a spouse described in subparagraph (B)) died during the taxable year.

s2_b_2_not_married(Taxpayer, TaxableYear) :-
    legally_separated(Taxpayer, Date),
    end_of_taxable_year(TaxableYear, EndDate),
    Date =< EndDate.

s2_b_2_not_married(Taxpayer, TaxableYear) :-
    spouse_is_nonresident_alien(Taxpayer, Date),
    start_of_taxable_year(TaxableYear, StartDate),
    end_of_taxable_year(TaxableYear, EndDate),
    Date >= StartDate,
    Date =< EndDate.

s2_b_2_married(Taxpayer, TaxableYear) :-
    spouse_died(Taxpayer, Spouse, Year),
    Year =:= TaxableYear,
    \+ spouse_is_nonresident_alien(Taxpayer, _).

% (3) Limitations
% Notwithstanding paragraph (1), for purposes of this subtitle a taxpayer shall not be considered to be a head of a household-
% (A) if at any time during the taxable year he is a nonresident alien; or
% (B) by reason of an individual who would not be a dependent for the taxable year but for subparagraph (H) of section 152(d)(2).

s2_b_3_not_head_of_household(Taxpayer, TaxableYear) :-
    nonresident_alien(Taxpayer, Date),
    start_of_taxable_year(TaxableYear, StartDate),
    end_of_taxable_year(TaxableYear, EndDate),
    Date >= StartDate,
    Date =< EndDate.

s2_b_3_not_head_of_household(Taxpayer, TaxableYear) :-
    dependent_by_reason_of_152d2h(Dependent, Taxpayer, TaxableYear),
    \+ dependent_of(Taxpayer, Dependent).