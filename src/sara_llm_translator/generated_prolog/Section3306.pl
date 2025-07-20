% §3306. Definitions

% (a) Employer

% (1) In general
% The term "employer" means, with respect to any calendar year, any person who-
% (A) during the calendar year or the preceding calendar year paid wages of $1,500 or more, or
s3306_a_1_a(Event) :-
    agent_(Event, Person),
    year_(Event, Year),
    (paid_wages_(Event, Person, Amount), Amount >= 1500, (Year = current_year ; Year = preceding_year)).

% (B) on each of some 10 days during the calendar year or during the preceding calendar year, each day being in a different calendar week, employed at least one individual in employment for some portion of the day.
s3306_a_1_b(Event) :-
    agent_(Event, Person),
    year_(Event, Year),
    employed_days_(Event, Person, Days),
    Days >= 10,
    different_weeks_(Days),
    employed_individuals_(Event, Person, Count),
    Count >= 1.

% For purposes of this paragraph, there shall not be taken into account any wages paid to, or employment of, an employee performing domestic services referred to in paragraph (3).
s3306_a_1(Event) :-
    (s3306_a_1_a(Event) ; s3306_a_1_b(Event)),
    \+ (domestic_service_(Event, Employee)).

% (2) Agricultural labor
% In the case of agricultural labor, the term "employer" means, with respect to any calendar year, any person who-
% (A) during the calendar year or the preceding calendar year paid wages of $20,000 or more for agricultural labor, or
s3306_a_2_a(Event) :-
    agent_(Event, Person),
    year_(Event, Year),
    (paid_wages_(Event, Person, Amount), Amount >= 20000, (Year = current_year ; Year = preceding_year)),
    agricultural_labor_(Event).

% (B) on each of some 10 days during the calendar year or during the preceding calendar year, each day being in a different calendar week, employed at least 5 individuals in employment in agricultural labor for some portion of the day.
s3306_a_2_b(Event) :-
    agent_(Event, Person),
    year_(Event, Year),
    employed_days_(Event, Person, Days),
    Days >= 10,
    different_weeks_(Days),
    employed_individuals_(Event, Person, Count),
    Count >= 5,
    agricultural_labor_(Event).

s3306_a_2(Event) :-
    s3306_a_2_a(Event) ; s3306_a_2_b(Event).

% (3) Domestic service
% In the case of domestic service in a private home, local college club, or local chapter of a college fraternity or sorority, the term "employer" means, with respect to any calendar year, any person who during the calendar year or the preceding calendar year paid wages in cash of $1,000 or more for such service.
s3306_a_3(Event) :-
    agent_(Event, Person),
    year_(Event, Year),
    (paid_wages_in_cash_(Event, Person, Amount), Amount >= 1000, (Year = current_year ; Year = preceding_year)),
    domestic_service_(Event).

% (4) Special rule
% A person treated as an employer under paragraph (3) shall not be treated as an employer with respect to wages paid for any service other than domestic service referred to in paragraph (3) unless such person is treated as an employer under paragraph (1) or (2) with respect to such other service.
s3306_a_4(Event) :-
    s3306_a_3(Event),
    \+ (s3306_a_1(Event) ; s3306_a_2(Event)).

% (b) Wages

% For purposes of this chapter, the term "wages" means all remuneration for employment, including the cash value of all remuneration (including benefits) paid in any medium other than cash; except that such term shall not include-

% (1) that part of the remuneration which, after remuneration (other than remuneration referred to in the succeeding paragraphs of this subsection) equal to $7,000 with respect to employment has been paid to an individual by an employer during any calendar year, is paid to such individual by such employer during such calendar year;
s3306_b_1(Event) :-
    agent_(Event, Employer),
    recipient_(Event, Employee),
    year_(Event, Year),
    paid_remuneration_(Event, Employer, Employee, Amount),
    Amount > 7000,
    \+ (remuneration_exceptions_(Event)).

% (2) the amount of any payment (including any amount paid by an employer for insurance or annuities, or into a fund, to provide for any such payment) made to, or on behalf of, an employee or any of his dependents under a plan or system established by an employer which makes provision for his employees generally (or for his employees generally and their dependents) or for a class or classes of his employees (or for a class or classes of his employees and their dependents), on account of-
% (A) sickness or accident disability, or
% (C) death;
s3306_b_2(Event) :-
    agent_(Event, Employer),
    recipient_(Event, Employee),
    payment_type_(Event, Type),
    member(Type, [sickness, accident_disability, death]),
    under_plan_(Event, Employer).

% (7) remuneration paid in any medium other than cash to an employee for service not in the course of the employer's trade or business;
s3306_b_7(Event) :-
    agent_(Event, Employer),
    recipient_(Event, Employee),
    paid_remuneration_(Event, Employer, Employee, Medium),
    Medium \= cash,
    \+ in_course_of_business_(Event, Employer).

% (10) any payment or series of payments by an employer to an employee or any of his dependents which is paid-
% (A) upon or after the termination of an employee's employment relationship because of (i) death, or (ii) retirement for disability, and
% (B) under a plan established by the employer which makes provision for his employees generally or a class or classes of his employees (or for such employees or class or classes of employees and their dependents),
% other than any such payment or series of payments which would have been paid if the employee's employment relationship had not been so terminated;
s3306_b_10(Event) :-
    agent_(Event, Employer),
    recipient_(Event, Employee),
    termination_reason_(Event, Reason),
    member(Reason, [death, retirement_disability]),
    under_plan_(Event, Employer),
    \+ would_have_been_paid_(Event).

% (11) remuneration for agricultural labor paid in any medium other than cash;
s3306_b_11(Event) :-
    agent_(Event, Employer),
    recipient_(Event, Employee),
    paid_remuneration_(Event, Employer, Employee, Medium),
    Medium \= cash,
    agricultural_labor_(Event).

% (15) any payment made by an employer to a survivor or the estate of a former employee after the calendar year in which such employee died;
s3306_b_15(Event) :-
    agent_(Event, Employer),
    recipient_(Event, Survivor),
    former_employee_(Event, Employee),
    year_of_death_(Employee, YearOfDeath),
    year_(Event, Year),
    Year > YearOfDeath.

% (c) Employment

% For purposes of this chapter, the term "employment" means any service, of whatever nature,
% (A) performed by an employee for the person employing him, irrespective of the citizenship or residence of either, within the United States, and
s3306_c_a(Event) :-
    agent_(Event, Employer),
    recipient_(Event, Employee),
    location_(Event, united_states).

% (B) performed outside the United States (except in a contiguous country with which the United States has an agreement relating to unemployment compensation) by a citizen of the United States as an employee of an American employer, except-
s3306_c_b(Event) :-
    agent_(Event, Employer),
    recipient_(Event, Employee),
    location_(Event, Location),
    \+ contiguous_country_with_agreement_(Location),
    citizen_(Employee, united_states),
    american_employer_(Employer).

% (1) agricultural labor unless-
% (A) such labor is performed for a person who-
% (i) during the calendar year or the preceding calendar year paid remuneration in cash of $20,000 or more to individuals employed in agricultural labor (including labor performed by an alien referred to in subparagraph (B)), or
% (ii) on each of some 10 days during the calendar year or the preceding calendar year, each day being in a different calendar week, employed in agricultural labor (including labor performed by an alien referred to in subparagraph (B)) for some portion of the day (whether or not at the same moment of time) 5 or more individuals; and
% (B) such labor is not agricultural labor performed by an individual who is an alien admitted to the United States to perform agricultural labor pursuant to sections 214(c) and 101(a)(15)(H) of the Immigration and Nationality Act.
s3306_c_1(Event) :-
    agricultural_labor_(Event),
    \+ (agent_(Event, Person),
        (paid_remuneration_in_cash_(Event, Person, Amount), Amount >= 20000 ;
         employed_days_(Event, Person, Days), Days >= 10, different_weeks_(Days), employed_individuals_(Event, Person, Count), Count >= 5),
        \+ (alien_admitted_for_agricultural_labor_(Event, Individual))).

% (2) domestic service in a private home, local college club, or local chapter of a college fraternity or sorority unless performed for a person who paid cash remuneration of $1,000 or more to individuals employed in such domestic service in the calendar year or the preceding calendar year;
s3306_c_2(Event) :-
    domestic_service_(Event),
    \+ (agent_(Event, Person),
        paid_cash_remuneration_(Event, Person, Amount),
        Amount >= 1000).

% (5) (A) service performed by an individual in the employ of his son, daughter, or spouse;
% (B) service performed by a child under the age of 21 in the employ of his father or mother;
s3306_c_5(Event) :-
    (employ_of_family_member_(Event, Individual, [son, daughter, spouse]) ;
     employ_of_parent_(Event, Child), age_(Child, Age), Age < 21).

% (6) service performed in the employ of the United States Government
s3306_c_6(Event) :-
    employ_of_government_(Event, united_states).

% (7) service performed in the employ of a State, or any political subdivision thereof.
s3306_c_7(Event) :-
    employ_of_state_(Event, State).

% (10) (A) service performed in the employ of a school, college, or university, if such service is performed
% (i) by a student who is enrolled and is regularly attending classes at such school, college, or university, or
% (ii) by the spouse of such a student, or
% (B) service performed in the employ of a hospital, if such service is performed by a patient of such hospital;
s3306_c_10(Event) :-
    (employ_of_educational_institution_(Event, Institution),
     (student_(Event, Student), enrolled_(Student, Institution) ;
      spouse_of_student_(Event, Spouse, Student), enrolled_(Student, Institution))) ;
    (employ_of_hospital_(Event, Hospital), patient_(Event, Patient, Hospital)).

% (11) service performed in the employ of a foreign government (including service as a consular or other officer or employee or a nondiplomatic representative);
s3306_c_11(Event) :-
    employ_of_foreign_government_(Event, Government).

% (13) service performed as a student nurse in the employ of a hospital or a nurses' training school by an individual who is enrolled and is regularly attending classes in a nurses' training school;
s3306_c_13(Event) :-
    employ_of_hospital_or_training_school_(Event, Institution),
    student_nurse_(Event, Student),
    enrolled_(Student, Institution).

% (16) service performed in the employ of an international organization;
s3306_c_16(Event) :-
    employ_of_international_organization_(Event, Organization).

% (21) service performed by a person committed to a penal institution.
s3306_c_21(Event) :-
    committed_to_penal_institution_(Event, Person).