% §152. Dependent defined

% (a) In general

% For purposes of this subtitle, the term "dependent" means-
% (1) a qualifying child, or
% (2) a qualifying relative.

s152_a(Event) :-
    (qualifying_child(Event) ; qualifying_relative(Event)).

% (b) Exceptions

% (1) Dependents ineligible
% If an individual is a dependent of a taxpayer for any taxable year of such taxpayer beginning in a calendar year, 
% such individual shall be treated as having no dependents for any taxable year of such individual beginning in such calendar year.

s152_b_1(Event, Individual) :-
    dependent_of(Event, Individual, Taxpayer),
    taxable_year(Event, Taxpayer, CalendarYear),
    \+ has_dependents(Event, Individual, CalendarYear).

% (2) Married dependents
% An individual shall not be treated as a dependent of a taxpayer under subsection (a) if such individual has made a joint return 
% with the individual's spouse for the taxable year beginning in the calendar year in which the taxable year of the taxpayer begins.

s152_b_2(Event, Individual, Taxpayer) :-
    \+ (dependent_of(Event, Individual, Taxpayer),
        joint_return(Event, Individual, Spouse, CalendarYear),
        taxable_year(Event, Taxpayer, CalendarYear)).

% (c) Qualifying child

% (1) In general
% The term "qualifying child" means, with respect to any taxpayer for any taxable year, an individual-
% (A) who bears a relationship to the taxpayer described in paragraph (2),
% (B) who has the same principal place of abode as the taxpayer for more than one-half of such taxable year,
% (C) who meets the age requirements of paragraph (3), and
% (E) who has not filed a joint return (other than only for a claim of refund) with the individual's spouse for the taxable year 
% beginning in the calendar year in which the taxable year of the taxpayer begins.

qualifying_child(Event, Individual, Taxpayer) :-
    relationship_to_taxpayer(Event, Individual, Taxpayer),
    principal_abode(Event, Individual, Taxpayer, MoreThanHalfYear),
    age_requirements(Event, Individual, Taxpayer),
    \+ (filed_joint_return(Event, Individual, Spouse, CalendarYear),
        \+ filed_for_refund_only(Event, Individual, Spouse, CalendarYear)).

% (2) Relationship
% For purposes of paragraph (1)(A), an individual bears a relationship to the taxpayer described in this paragraph if such individual is-
% (A) a child of the taxpayer or a descendant of such a child, or
% (B) a brother, sister, stepbrother, or stepsister of the taxpayer or a descendant of any such relative.

relationship_to_taxpayer(Event, Individual, Taxpayer) :-
    (child_of(Event, Individual, Taxpayer) ;
     descendant_of_child(Event, Individual, Taxpayer) ;
     sibling(Event, Individual, Taxpayer) ;
     descendant_of_sibling(Event, Individual, Taxpayer)).

% (3) Age requirements
% For purposes of paragraph (1)(C), an individual meets the requirements of this paragraph if such individual is younger than the taxpayer 
% claiming such individual as a qualifying child and is less than 25 years old at the end of the taxable year.

age_requirements(Event, Individual, Taxpayer) :-
    younger_than(Event, Individual, Taxpayer),
    less_than_25_years_old(Event, Individual).

% (d) Qualifying relative

% (1) In general
% The term "qualifying relative" means, with respect to any taxpayer for any taxable year, an individual-
% (A) who bears a relationship to the taxpayer described in paragraph (2),
% (B) who has no income for the calendar year in which such taxable year begins, and
% (D) who is not a qualifying child of such taxpayer or of any other taxpayer for any taxable year beginning in the calendar year 
% in which such taxable year begins.

qualifying_relative(Event, Individual, Taxpayer) :-
    relationship_to_taxpayer_relative(Event, Individual, Taxpayer),
    no_income(Event, Individual, CalendarYear),
    \+ qualifying_child(Event, Individual, Taxpayer).

% (2) Relationship
% For purposes of paragraph (1)(A), an individual bears a relationship to the taxpayer described in this paragraph if the individual is any of the following with respect to the taxpayer:
% (A) A child or a descendant of a child.
% (B) A brother, sister, stepbrother, or stepsister.
% (C) The father or mother, or an ancestor of either.
% (D) A stepfather or stepmother.
% (E) A son or daughter of a brother or sister of the taxpayer.
% (F) A brother or sister of the father or mother of the taxpayer.
% (G) A son-in-law, daughter-in-law, father-in-law, mother-in-law, brother-in-law, or sister-in-law.
% (H) An individual (other than an individual who at any time during the taxable year was the spouse, determined without regard to section 7703, of the taxpayer) 
% who, for the taxable year of the taxpayer, has the same principal place of abode as the taxpayer and is a member of the taxpayer's household.

relationship_to_taxpayer_relative(Event, Individual, Taxpayer) :-
    (child_of(Event, Individual, Taxpayer) ;
     descendant_of_child(Event, Individual, Taxpayer) ;
     sibling(Event, Individual, Taxpayer) ;
     parent(Event, Individual, Taxpayer) ;
     ancestor_of_parent(Event, Individual, Taxpayer) ;
     stepparent(Event, Individual, Taxpayer) ;
     niece_or_nephew(Event, Individual, Taxpayer) ;
     aunt_or_uncle(Event, Individual, Taxpayer) ;
     in_law(Event, Individual, Taxpayer) ;
     (principal_abode(Event, Individual, Taxpayer, FullYear),
      member_of_household(Event, Individual, Taxpayer),
      \+ spouse(Event, Individual, Taxpayer))).