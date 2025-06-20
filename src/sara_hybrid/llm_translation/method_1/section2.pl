% section2.pl
% § 2. Definitions and special rules
:- module(section2,
          [ s2_a/3,    % s2_a(Person, Spouse, TaxYear): surviving spouse
            s2_b/3     % s2_b(Person, _, TaxYear): head of household
          ]).

%% § 2(a) Definition of “surviving spouse”
%% A taxpayer whose spouse died within the two years preceding the taxable year,
%% who maintains a household for a qualifying child-dependent, not remarried,
%% and able to file a joint return (no nonresident aliens).
s2_a(Person, Spouse, Year) :-
    % (1)(A) spouse died during either of the two years immediately preceding Year
    spouse_died(Person, Spouse, DeathYear),
    DeathYear >= Year-2,
    DeathYear <  Year,
    % (1)(B) maintains household for a dependent child
    maintains_household(Person, Year, Dependent),
    dependent(Dependent, Person, Year),
    ( relationship(Dependent, Person, son)
    ; relationship(Dependent, Person, stepson)
    ; relationship(Dependent, Person, daughter)
    ; relationship(Dependent, Person, stepdaughter)
    ),
    % over half the cost of maintaining that household
    cost_majority(Person, Year),
    % (2)(A) not remarried before the close of Year
    \+ remarried(Person, Year),
    % (2)(B) could have filed a joint return (no nonresident aliens)
    joint_return_possible(Person, Spouse, Year).

%% § 2(b) Definition of “head of household”
%% An individual who is not married at year-end, not a surviving spouse,
%% and either:
%%   (A) maintains household for qualifying child or other dependent, or
%%   (B) maintains household for parent,
%% plus usual cost-and-dependency tests, and subject to marital/nonresident-alien limitations.
s2_b(Person, _, Year) :-
    % (1) not married at close of Year
    \+ married(Person, Year),
    %    and not a surviving spouse
    \+ s2_a(Person, _, Year),

    % (1)(A) qualifying child‐or‐other‐dependent test
    (
      % (i) qualifying child case
      maintains_household(Person, Year, Dep),
      qualifying_child(Dep, Person, Year),
      \+ child_married(Dep, Year),
      dependent(Dep, Person, Year)
    ;
      % (ii) any other dependent
      maintains_household(Person, Year, Dep),
      dependent(Dep, Person, Year),
      \+ qualifying_child(Dep, Person, Year)
    ;
      % (1)(B) parent case
      maintains_household(Person, Year, Parent),
      parent(Parent, Person),
      dependent(Parent, Person, Year)
    ),

    % over half cost test
    cost_majority(Person, Year),

    % (2) determination rules
    \+ legally_separated(Person, Year),
    \+ spouse_nonresident_alien(Person, Year),

    % (3) final limitations
    \+ nonresident_alien(Person, Year),
    \+ invalid_dependent_152d(Person, Year).