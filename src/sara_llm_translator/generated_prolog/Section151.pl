% §151. Allowance of deductions for personal exemptions

% (a) Allowance of deductions
% In the case of an individual, the exemptions provided by this section shall be allowed as deductions in computing taxable income.
s151_a(Event) :-
    individual(Event, Person),
    exemption_provided(Event, Exemption),
    allowed_as_deduction(Event, Exemption, taxable_income).

% (b) Taxpayer and spouse
% An exemption of the exemption amount for the taxpayer; and an additional exemption of the exemption amount for the spouse of the taxpayer if a joint return is not made by the taxpayer and his spouse, and if the spouse, for the calendar year in which the taxable year of the taxpayer begins, has no gross income and is not the dependent of another taxpayer.
s151_b(Event) :-
    taxpayer(Event, Taxpayer),
    exemption_amount(Event, ExemptionAmount),
    exemption(Event, Taxpayer, ExemptionAmount).

s151_b(Event) :-
    taxpayer(Event, Taxpayer),
    spouse(Event, Taxpayer, Spouse),
    exemption_amount(Event, ExemptionAmount),
    \+ (filed_joint_return(Event, Taxpayer, Spouse), \+ filed_for_refund_only(Event, Taxpayer, Spouse)),
    no_gross_income(Event, Spouse),
    \+ dependent_of_another_taxpayer(Event, Spouse),
    additional_exemption(Event, Spouse, ExemptionAmount).

% (c) Additional exemption for dependents
% An exemption of the exemption amount for each individual who is a dependent (as defined in section 152) of the taxpayer for the taxable year.
s151_c(Event) :-
    taxpayer(Event, Taxpayer),
    dependent(Event, Taxpayer, Dependent),
    exemption_amount(Event, ExemptionAmount),
    exemption(Event, Dependent, ExemptionAmount).

% (d) Exemption amount

% (1) In general
% Except as otherwise provided in this subsection, the term "exemption amount" means $2,000.
s151_d_1(Event, ExemptionAmount) :-
    \+ otherwise_provided_in_subsection(Event),
    ExemptionAmount = 2000.

% (2) Exemption amount disallowed in case of certain dependents
% In the case of an individual with respect to whom a deduction under this section is allowable to another taxpayer for a taxable year beginning in the calendar year in which the individual's taxable year begins, the exemption amount applicable to such individual for such individual's taxable year shall be zero.
s151_d_2(Event, Individual, ExemptionAmount) :-
    deduction_allowable_to_another_taxpayer(Event, Individual),
    ExemptionAmount = 0.

% (3) Phaseout

% (A) In general
% In the case of any taxpayer whose adjusted gross income for the taxable year exceeds the applicable amount in effect under section 68(b), the exemption amount shall be reduced by the applicable percentage.
s151_d_3_a(Event, Taxpayer, ReducedExemptionAmount) :-
    adjusted_gross_income(Event, Taxpayer, AGI),
    applicable_amount(Event, ApplicableAmount),
    AGI > ApplicableAmount,
    applicable_percentage(Event, Taxpayer, ApplicablePercentage),
    exemption_amount(Event, ExemptionAmount),
    ReducedExemptionAmount is ExemptionAmount - (ExemptionAmount * ApplicablePercentage / 100).

% (B) Applicable percentage
% For purposes of subparagraph (A), the term "applicable percentage" means 2 percentage points for each $2,500 (or fraction thereof) by which the taxpayer's adjusted gross income for the taxable year exceeds the applicable amount in effect under section 68(b). In the case of a married individual filing a separate return, the preceding sentence shall be applied by substituting "$1,250" for "$2,500". In no event shall the applicable percentage exceed 100 percent.
applicable_percentage(Event, Taxpayer, ApplicablePercentage) :-
    adjusted_gross_income(Event, Taxpayer, AGI),
    applicable_amount(Event, ApplicableAmount),
    Excess is AGI - ApplicableAmount,
    (   married_filing_separate(Event, Taxpayer)
    ->  Unit = 1250
    ;   Unit = 2500
    ),
    ApplicablePercentage is min(100, 2 * ceil(Excess / Unit)).

% (5) Special rules for taxable years 2018 through 2025
% In the case of a taxable year beginning after December 31, 2017, and before January 1, 2026, the term "exemption amount" means zero.
s151_d_5(Event, ExemptionAmount) :-
    taxable_year(Event, Year),
    Year > 2017,
    Year < 2026,
    ExemptionAmount = 0.