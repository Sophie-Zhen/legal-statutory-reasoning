:- module(tests,
          [
            answer/2,
            fact/2 % Export fact/2 if other modules are to query it directly using tests:fact/2
          ]).

% Load all statute modules and helpers
:- use_module(helpers).
:- use_module(section1).
:- use_module(section2).
:- use_module(section63).
:- use_module(section68).
:- use_module(section151).
:- use_module(section152).
:- use_module(section7703).
:- use_module(section3301).
:- use_module(section3306).

:- dynamic fact/2.

% --- Case Facts ---

% Case ID: s1_d_iv_neg
fact(s1_d_iv_neg, person_is_taxpayer(alice)).
fact(s1_d_iv_neg, is_married_under_7703(alice, 2017)). % Simplified fact based on case text
fact(s1_d_iv_neg, taxable_income_for_s1(alice, 2017, 28864)). % Explicitly for S1 context
fact(s1_d_iv_neg, files_separate_return(alice, 2017)).
fact(s1_d_iv_neg, filing_status(alice, 2017, married_filing_separately)). % Derived from above
fact(s1_d_iv_neg, spouse_of(alice, _bob_s1_d_iv_neg)). % Assume a spouse exists for MFS
fact(s1_d_iv_neg, question_type(contradiction)).
fact(s1_d_iv_neg, question_expected_tax(5683)).
fact(s1_d_iv_neg, question_target_section_subsection(section1, s1_d_iv)).

% Case ID: s3306_c_5_pos
fact(s3306_c_5_pos, person_is_potential_employer(alice)).
fact(s3306_c_5_pos, person_is_potential_employee(bob)).
fact(s3306_c_5_pos, paid_remuneration_for_service(alice, bob, 2017, 3200, service_details(general_work, usa_md_baltimore, unknown_citizenship))).
fact(s3306_c_5_pos, relationship_parent_of(bob, alice)). % Bob is Alice's father
fact(s3306_c_5_pos, service_performed_date_range(bob, for_alice, date(2017,2,1), date(2017,9,2))).
fact(s3306_c_5_pos, service_location(bob, for_alice, baltimore_md_usa)).
fact(s3306_c_5_pos, question_type(entailment)).
fact(s3306_c_5_pos, question_target_section_subsection(section3306, s3306_c_5)).
fact(s3306_c_5_pos, service_calendar_year(service_performed_by_bob_for_alice_2017, 2017)). % For s3306_c_5 family age check

% Case ID: s1_c_i_neg
fact(s1_c_i_neg, person_is_taxpayer(alice)).
fact(s1_c_i_neg, taxable_income_for_s1(alice, 2017, 718791)).
fact(s1_c_i_neg, is_not_married(alice, 2017)). % Based on case text
fact(s1_c_i_neg, is_not_surviving_spouse(alice, 2017)).
fact(s1_c_i_neg, is_not_head_of_household(alice, 2017)).
fact(s1_c_i_neg, filing_status(alice, 2017, single)). % Derived
fact(s1_c_i_neg, question_type(contradiction)).
fact(s1_c_i_neg, question_expected_tax(265413)).
fact(s1_c_i_neg, question_target_section_subsection(section1, s1_c_i)).

% Case ID: s1_b_iii_neg
fact(s1_b_iii_neg, person_is_taxpayer(alice)).
fact(s1_b_iii_neg, is_head_of_household_status(alice, 2017)). % Explicit status claim
fact(s1_b_iii_neg, filing_status(alice, 2017, head_of_household)).
fact(s1_b_iii_neg, taxable_income_for_s1(alice, 2017, 54775)).
fact(s1_b_iii_neg, question_type(contradiction)).
fact(s1_b_iii_neg, question_expected_tax(11489)).
fact(s1_b_iii_neg, question_target_section_subsection(section1, s1_b_iii)).
% For HoH, need underlying facts:
fact(s1_b_iii_neg, s7703_determination_of_marital_status(alice, 2017, not_married)). % Assumed for HoH
fact(s1_b_iii_neg, maintains_home_principal_abode_gt_half_year_for_individual(alice, child_for_s1_b_iii, 2017)).
fact(s1_b_iii_neg, s152_c_qualifying_child(alice, child_for_s1_b_iii, 2017, true)). % Assume a QC exists
fact(s1_b_iii_neg, furnished_over_half_cost_of_maintaining_household(alice, 2017)).
fact(s1_b_iii_neg, is_not_surviving_spouse(alice, 2017)). % Explicit for HoH

% Case ID: s152_d_2_F_pos
fact(s152_d_2_F_pos, person(alice)).
fact(s152_d_2_F_pos, person(bob)).
fact(s152_d_2_F_pos, person(charlie)).
fact(s152_d_2_F_pos, relationship_parent_of(charlie, bob)). % Charlie is Bob's father
fact(s152_d_2_F_pos, relationship_sibling_of(alice, charlie)). % Alice is Charlie's sister
fact(s152_d_2_F_pos, question_type(entailment)).
fact(s152_d_2_F_pos, question_target_section_subsection(section152, s152_d_2_F)).
fact(s152_d_2_F_pos, question_target_persons(alice, bob)). % Alice bears relationship to Bob

% Case ID: s1_a_1_iii_neg
fact(s1_a_1_iii_neg, person_is_taxpayer(alice)).
fact(s1_a_1_iii_neg, is_married_under_7703(alice, 2017)).
fact(s1_a_1_iii_neg, spouse_of(alice, spouse_s1_a_1_iii_neg)).
fact(s1_a_1_iii_neg, files_joint_return(alice, spouse_s1_a_1_iii_neg, 2017)).
fact(s1_a_1_iii_neg, filing_status(alice, 2017, joint_return)).
fact(s1_a_1_iii_neg, taxable_income_for_s1(alice, 2017, 164612)). % Joint taxable income
fact(s1_a_1_iii_neg, question_type(contradiction)).
fact(s1_a_1_iii_neg, question_expected_tax(44789)).
fact(s1_a_1_iii_neg, question_target_section_subsection(section1, s1_a_iii)).

% Case ID: s3306_b_10_A_neg
fact(s3306_b_10_A_neg, person_is_potential_employer(alice)).
fact(s3306_b_10_A_neg, person_is_potential_employee(bob)).
fact(s3306_b_10_A_neg, employment_period(alice, bob, date(2011,1,1), date(2019,10,10))).
fact(s3306_b_10_A_neg, retired_on_date(bob, date(2019,10,10))).
fact(s3306_b_10_A_neg, retirement_reason(bob, age_65)).
fact(s3306_b_10_A_neg, payment_to_employee(alice, bob, 2019, 12980, retirement_bonus)).
fact(s3306_b_10_A_neg, payment_details(retirement_bonus_for_bob_2019, termination_payment(retirement_by_age, employer_plan_xyz, 12980))).
fact(s3306_b_10_A_neg, question_type(contradiction)).
fact(s3306_b_10_A_neg, question_target_section_subsection(section3306, s3306_b_10_A)).
fact(s3306_b_10_A_neg, question_target_payment_amount(12980)).
% For s3306(b)(10)(B)
fact(s3306_b_10_A_neg, payment_under_employer_plan(alice, employer_plan_xyz)).
fact(s3306_b_10_A_neg, payment_would_not_have_been_made_if_not_terminated(alice, bob, retirement_bonus_for_bob_2019)).

% Case ID: s63_c_2_B_neg
fact(s63_c_2_B_neg, person_is_taxpayer(alice)).
fact(s63_c_2_B_neg, person_is_taxpayer(bob)). % Bob is also a taxpayer contextually
fact(s63_c_2_B_neg, gross_income(alice, 2017, 33200)). % "was paid" implies gross income
fact(s63_c_2_B_neg, adjusted_gross_income(alice, 2017, 33200)). % Assume no above-the-line deductions
fact(s63_c_2_B_neg, married_on_date(alice, bob, date(2017,2,3))).
fact(s63_c_2_B_neg, spouse_of(alice, bob)).
fact(s63_c_2_B_neg, files_joint_return(alice, bob, 2017)).
fact(s63_c_2_B_neg, filing_status(alice, 2017, joint_return)).
fact(s63_c_2_B_neg, question_type(contradiction)).
fact(s63_c_2_B_neg, question_expected_bsd(4400)).
fact(s63_c_2_B_neg, question_target_section_subsection(section63, s63_c_2_B)). % (B) is HoH, case is MFJ. This is the contradiction.

% Case ID: s3306_b_7_neg
fact(s3306_b_7_neg, person_is_potential_employer(alice)).
fact(s3306_b_7_neg, person_is_potential_employee(bob)).
fact(s3306_b_7_neg, employer_trade_or_business(alice, typewriter_factory)).
fact(s3306_b_7_neg, employee_of_business(bob, typewriter_factory)).
fact(s3306_b_7_neg, payment_to_employee(alice, bob, 2017, 323, cash_for_painting_house)).
fact(s3306_b_7_neg, service_performed_for_payment(cash_for_painting_house, painting_house_alice)).
fact(s3306_b_7_neg, service_nature(painting_house_alice, service_not_in_course_of_business)). % Painting house is personal
fact(s3306_b_7_neg, payment_details(payment_for_painting_house_alice_2017, payment(cash, 323, service_not_in_course_of_business))).
fact(s3306_b_7_neg, question_type(contradiction)). % s3306(b)(7) is for NON-CASH. This payment is CASH.
fact(s3306_b_7_neg, question_target_section_subsection(section3306, s3306_b_7)).
fact(s3306_b_7_neg, question_target_payment_amount(323)).

% Case ID: s152_c_1_E_pos
fact(s152_c_1_E_pos, person_is_taxpayer(alice)).
fact(s152_c_1_E_pos, person(bob)).
fact(s152_c_1_E_pos, person(charlie)).
fact(s152_c_1_E_pos, relationship_child_of(bob, alice)). % Bob is Alice's son
fact(s152_c_1_E_pos, principal_place_of_abode_together(alice, bob, date(2015,9,1), date(2019,11,3))).
fact(s152_c_1_E_pos, principal_place_of_abode_gt_half_year(bob, alice, 2019)). % Derived for 2019
fact(s152_c_1_E_pos, married_on_date(bob, charlie, date(2018,10,23))).
fact(s152_c_1_E_pos, spouse_of(bob, charlie)).
fact(s152_c_1_E_pos, files_separate_return(bob, 2019)). % Bob files sep
fact(s152_c_1_E_pos, files_separate_return(charlie, 2019)). % Charlie files sep
% Therefore, Bob and Charlie do NOT file a joint return.
fact(s152_c_1_E_pos, question_type(entailment)).
fact(s152_c_1_E_pos, question_target_section_subsection(section152, s152_c_1_E)).
fact(s152_c_1_E_pos, question_target_person_year(bob, 2019)).

% Case ID: s2_a_2_B_pos
fact(s2_a_2_B_pos, person_is_taxpayer(bob)). % Bob is the one whose status is in q
fact(s2_a_2_B_pos, person(alice)).
fact(s2_a_2_B_pos, married_on_date(alice, bob, date(1992,2,3))).
fact(s2_a_2_B_pos, spouse_of(bob, alice)). % Alice was Bob's spouse
fact(s2_a_2_B_pos, person_died_on(alice, date(2014,7,9))). % Alice died in 2014
fact(s2_a_2_B_pos, question_type(entailment)).
fact(s2_a_2_B_pos, question_target_section_subsection(section2, s2_a_2_B)).
fact(s2_a_2_B_pos, question_target_person_year(bob, 2014)).
% For s2(a)(2)(B) "joint return could have been made" in year of death (2014 for Alice)
fact(s2_a_2_B_pos, is_nonresident_alien(alice, 2014, false)). % Assume not NRA unless stated
fact(s2_a_2_B_pos, is_nonresident_alien(bob, 2014, false)).   % Assume not NRA unless stated

% Case ID: s63_c_3_pos
fact(s63_c_3_pos, person_is_taxpayer(alice)).
fact(s63_c_3_pos, person(bob)).
fact(s63_c_3_pos, gross_income(alice, 2017, 33200)).
fact(s63_c_3_pos, adjusted_gross_income(alice, 2017, 33200)).
fact(s63_c_3_pos, married_on_date(alice, bob, date(2017,2,3))).
fact(s63_c_3_pos, spouse_of(alice, bob)).
fact(s63_c_3_pos, filing_status(alice, 2017, joint_return)). % Assumed from context, if they take ASD for spouse
fact(s63_c_3_pos, files_joint_return(alice, bob, 2017)). % Explicitly stated for ASD for spouse
% Entitlement facts for ASD (these would normally be derived by s63_f)
fact(s63_c_3_pos, entitled_to_asd_self_63f1A(alice, 2017, 600)). % From case text "entitled to $600 for herself"
fact(s63_c_3_pos, entitled_to_asd_spouse_63f1B(alice, bob, 2017, 600)). % From case text "entitled to $600 for Bob"
% Underlying facts for the entitlement (if we were to prove it)
fact(s63_c_3_pos, get_age_at_year_end(alice, 2017, 65)). % To trigger 63(f)(1)(A)
fact(s63_c_3_pos, get_age_at_year_end(bob, 2017, 65)).   % To trigger 63(f)(1)(B)
fact(s63_c_3_pos, s151_b_spouse_conditions_met(alice, bob, 2017, true)). % Or files_joint_return for 151(b) condition for ASD
fact(s63_c_3_pos, question_type(entailment)).
fact(s63_c_3_pos, question_expected_asd(1200)).
fact(s63_c_3_pos, question_target_section_subsection(section63, s63_c_3)).

% Case ID: s3306_a_1_neg
fact(s3306_a_1_neg, person(alice)).
fact(s3306_a_1_neg, person(bob)).
fact(s3306_a_1_neg, paid_wage_to_employee_for_service(alice, bob, 2017, 3200, domestic_service)). % Alice paid Bob for domestic
fact(s3306_a_1_neg, service_performed_date_range(bob, for_alice, date(2017,2,1), date(2017,9,2))).
fact(s3306_a_1_neg, paid_wage_to_employee_for_service(bob, alice, 2017, 2000, general_work_apr_sep_2017)). % Bob paid Alice
fact(s3306_a_1_neg, paid_wage_to_employee_for_service(bob, alice, 2018, 2500, general_work_apr_sep_2018)). % Bob paid Alice
fact(s3306_a_1_neg, service_performed_date_range(alice, for_bob, date(2017,4,1), date(2018,9,1))).
fact(s3306_a_1_neg, question_type(contradiction)).
fact(s3306_a_1_neg, question_target_section_subsection(section3306, s3306_a_1)).
fact(s3306_a_1_neg, question_target_person_year(alice, 2018)). % Is Alice employer in 2018 under s3306(a)(1)?
% For s3306(a)(1), domestic service wages are not taken into account.
% Alice paid Bob $3200 for domestic service in 2017. This is ignored for (a)(1).
% Alice received $2500 from Bob in 2018 (and $2000 in 2017). This makes Bob potentially an employer, not Alice.
% Alice has paid no non-domestic wages mentioned.

% Case ID: s7703_b_1_pos
fact(s7703_b_1_pos, person_is_taxpayer(alice)).
fact(s7703_b_1_pos, person(bob)).
fact(s7703_b_1_pos, person(charlie)).
fact(s7703_b_1_pos, married_on_date(alice, bob, date(2012,4,5))).
fact(s7703_b_1_pos, spouse_of(alice, bob)).
fact(s7703_b_1_pos, relationship_child_of(charlie, alice)).
fact(s7703_b_1_pos, relationship_child_of(charlie, bob)).
fact(s7703_b_1_pos, person_dob(charlie, date(2017,9,16))).
fact(s7703_b_1_pos, maintains_home_for_child_since(alice, charlie, date(2017,9,16))).
fact(s7703_b_1_pos, maintains_home_for_child_gt_half_year(alice, charlie, 2018)). % Derived for 2018
fact(s7703_b_1_pos, entitled_to_deduction_for_child(alice, charlie, 2017)). % s151(c) -> s151
fact(s7703_b_1_pos, entitled_to_deduction_for_child(alice, charlie, 2018)).
fact(s7703_b_1_pos, entitled_to_deduction_for_child(alice, charlie, 2019)).
fact(s7703_b_1_pos, files_separate_return(alice, 2018)).
fact(s7703_b_1_pos, question_type(entailment)).
fact(s7703_b_1_pos, question_target_section_subsection(section7703, s7703_b_1)).
fact(s7703_b_1_pos, question_target_person_year(alice, 2018)).
% For 7703(b)(1) to apply, Alice must be married under 7703(a) first.
fact(s7703_b_1_pos, married_at_close_of_year(alice, 2018)). % Not legally separated, spouse not dead in year.

% Case ID: s1_c_iv_pos
fact(s1_c_iv_pos, person_is_taxpayer(alice)).
fact(s1_c_iv_pos, taxable_income_for_s1(alice, 2017, 210204)).
fact(s1_c_iv_pos, is_not_married(alice, 2017)).
fact(s1_c_iv_pos, is_not_surviving_spouse(alice, 2017)).
fact(s1_c_iv_pos, is_not_head_of_household(alice, 2017)).
fact(s1_c_iv_pos, filing_status(alice, 2017, single)). % Derived
fact(s1_c_iv_pos, question_type(entailment)).
fact(s1_c_iv_pos, question_expected_tax(65445.44)). % Tax from statute: 31172 + 0.36 * (210204-115000) = 31172 + 0.36*95204 = 31172 + 34273.44 = 65445.44. Rounded to 65445.
fact(s1_c_iv_pos, question_expected_tax_rounded(65445)).
fact(s1_c_iv_pos, question_target_section_subsection(section1, s1_c_iv)).

% Case ID: s3306_b_pos
fact(s3306_b_pos, person_is_potential_employer(alice)).
fact(s3306_b_pos, person_is_potential_employee(bob)).
fact(s3306_b_pos, paid_remuneration_to_employee(alice, bob, 2018, 2325, payment_details(cash, 2325, dog_walking_service))).
fact(s3306_b_pos, service_performed_for_payment(dog_walking_2018, dog_walking_service)).
fact(s3306_b_pos, question_type(entailment)).
fact(s3306_b_pos, question_target_section_subsection(section3306, s3306_b)). % Applies to the money (is it a "wage"?)
fact(s3306_b_pos, question_target_payment_amount(2325)).
% For s3306(b) to apply, the payment must be for "employment" under s3306(c).
% Dog walking is likely not an excluded category unless it's e.g. non-cash for non-business. This is cash.
% Assume dog walking is general service, performed in US.
fact(s3306_b_pos, service_details_for_payment(payment_for_dog_walking_alice_2018, service_details(general_work, usa, unknown_citizenship))).
fact(s3306_b_pos, ytd_futa_wages_paid_to_employee(alice, bob, 2018, 0)). % Assume this is the first payment

% Case ID: s1_a_1_pos
fact(s1_a_1_pos, person_is_taxpayer(alice)).
fact(s1_a_1_pos, is_married_under_7703(alice, 2017)).
fact(s1_a_1_pos, spouse_of(alice, husband_s1_a_1_pos)).
fact(s1_a_1_pos, files_joint_return(alice, husband_s1_a_1_pos, 2017)).
fact(s1_a_1_pos, filing_status(alice, 2017, joint_return)).
fact(s1_a_1_pos, taxable_income_for_s1(alice, 2017, 17330)). % Joint taxable income
fact(s1_a_1_pos, question_type(entailment)).
fact(s1_a_1_pos, question_expected_tax(2599.50)). % 0.15 * 17330 = 2599.5. Rounded to 2600.
fact(s1_a_1_pos, question_expected_tax_rounded(2600)).
fact(s1_a_1_pos, question_target_section_subsection(section1, s1_a)). % s1(a) general, not a specific sub-bracket.

% Case ID: s68_b_1_A_neg
fact(s68_b_1_A_neg, person_is_taxpayer(alice)).
fact(s68_b_1_A_neg, adjusted_gross_income(alice, 2016, 567192)). % "income" assumed AGI for Sec 68
fact(s68_b_1_A_neg, is_married_under_7703(alice, 2016)).
fact(s68_b_1_A_neg, spouse_of(alice, spouse_s68_b_1_A_neg)).
fact(s68_b_1_A_neg, files_separate_return(alice, 2016)). % "does not file a joint return"
fact(s68_b_1_A_neg, filing_status(alice, 2016, married_filing_separately)). % Derived
fact(s68_b_1_A_neg, question_type(contradiction)).
fact(s68_b_1_A_neg, question_target_section_subsection(section68, s68_b_1_A)). % (A) is for Joint or Surviving Spouse. Alice is MFS.

% Case ID: tax_case_89
fact(tax_case_89, person_is_taxpayer(alice)).
fact(tax_case_89, person(bob)).
fact(tax_case_89, gross_income(alice, 2018, 3200)). % "was paid"
fact(tax_case_89, adjusted_gross_income(alice, 2018, 3200)). % Assume no above-the-line
fact(tax_case_89, married_on_date(alice, bob, date(2017,2,3))).
fact(tax_case_89, spouse_of(alice, bob)).
fact(tax_case_89, files_separate_return(alice, 2018)).
fact(tax_case_89, files_separate_return(bob, 2018)).
fact(tax_case_89, filing_status(alice, 2018, married_filing_separately)).
fact(tax_case_89, filing_status(bob, 2018, married_filing_separately)).
fact(tax_case_89, takes_standard_deduction(alice, 2018)).
fact(tax_case_89, takes_standard_deduction(bob, 2018)).
fact(tax_case_89, gross_income(bob, 2018, 0)).
fact(tax_case_89, adjusted_gross_income(bob, 2018, 0)).
fact(tax_case_89, is_blind_since(alice, date(2016,3,20))).
fact(tax_case_89, is_blind_at_close_of_year(alice, 2018)). % Derived
fact(tax_case_89, enrolled_student_dates(alice, 'Johns Hopkins University', date(2015,8,29), date(2019,5,30))).
fact(tax_case_89, question_how_much_tax(alice, 2018, 0)).
fact(tax_case_89, person_dob(alice, date(1990,1,1))). % Assume age, not 65+
fact(tax_case_89, earned_income(alice, 2018, 3200)). % For dependent SD calculation if applicable.
% For MFS, if one itemizes, other must too or SD is 0. Here both take SD.
fact(tax_case_89, elects_to_itemize_deductions(alice, 2018, false)).
fact(tax_case_89, elects_to_itemize_deductions(bob, 2018, false)).

% Case ID: tax_case_13
fact(tax_case_13, person_is_taxpayer(bob)). % Bob is taxpayer in question
fact(tax_case_13, person(alice)).
fact(tax_case_13, relationship_parent_of(bob, alice)). % Bob is Alice's father
fact(tax_case_13, gross_income(bob, 2017, 53249)). % "remuneration" -> gross income
fact(tax_case_13, adjusted_gross_income(bob, 2017, 53249)).
fact(tax_case_13, service_for_employer(bob, 'Johns Hopkins University', 2017)).
fact(tax_case_13, enrolled_student_dates(alice, 'Johns Hopkins University', date(2015,8,29), date(2019,5,30))).
fact(tax_case_13, lives_at_house_of(alice, bob, 2017)).
fact(tax_case_13, principal_place_of_abode_gt_half_year(alice, bob, 2017)). % Alice lived at Bob's house
fact(tax_case_13, furnished_all_costs_of_household(bob, 2017)). % Bob furnished all costs for his house
fact(tax_case_13, takes_standard_deduction(bob, 2017)).
fact(tax_case_13, elects_to_itemize_deductions(bob, 2017, false)).
fact(tax_case_13, question_how_much_tax(bob, 2017, 8710)). % Expected: 5156.25, My calc: 5156.25 for 2017 rates. Book says 8710. This implies different rates/rules.
                                                        % The rates in Sec 1 are from a specific pre-TCJA year.
                                                        % Let's assume the question's expected tax is based on THE rates in Sec 1.
                                                        % Bob is single (Alice is adult child, may be dependent).
fact(tax_case_13, filing_status(bob, 2017, single)). % Default if not married, not HoH, not SS
fact(tax_case_13, is_not_married(bob, 2017)).
fact(tax_case_13, person_dob(bob, date(1970,1,1))). % Assume not aged/blind
fact(tax_case_13, person_dob(alice, date(1995,1,1))). % Assume Alice <24, student for QC age
% For Alice to be Bob's dependent (QC):
fact(tax_case_13, s152_c_1_A_relationship_qc(bob, alice, 2017, true)). % Alice is child
fact(tax_case_13, s152_c_1_B_abode_qc(bob, alice, 2017, true)). % Alice lived with Bob
fact(tax_case_13, get_age_at_year_end(alice, 2017, 22)). % 2017-1995=22
fact(tax_case_13, is_student_full_time(alice, 2017)). % Implied by "enrolled and attending classes"
fact(tax_case_13, s152_c_1_C_age_qc(bob, alice, 2017, true)). % Under 24 and student
fact(tax_case_13, s152_c_1_E_no_joint_return_qc(alice, 2017, true)). % Assume Alice no joint return
fact(tax_case_13, gross_income(alice, 2017, 0)). % Assume Alice has no income for QR test if QC fails. (QR needs GI=0 for text)
fact(tax_case_13, potential_dependent_of(bob, alice)).

% Case ID: tax_case_40
fact(tax_case_40, person_is_taxpayer(alice)).
fact(tax_case_40, person(bob)).
fact(tax_case_40, person(charlie)).
fact(tax_case_40, paid_remuneration_for_service(alice, bob, 2017, 3200, service_details(general_work, usa_md_baltimore, unknown_citizenship))).
fact(tax_case_40, relationship_parent_of(bob, alice)).
fact(tax_case_40, married_on_date(alice, charlie, date(2012,4,5))).
fact(tax_case_40, spouse_of(alice, charlie)). % Was spouse
fact(tax_case_40, legally_separated_under_decree_on(alice, charlie, date(2017,9,16))).
fact(tax_case_40, legally_separated_under_decree(alice, charlie, 2017)). % Active at year end
fact(tax_case_40, gross_income(alice, 2017, 756420)).
fact(tax_case_40, adjusted_gross_income(alice, 2017, 756420)).
fact(tax_case_40, takes_standard_deduction(alice, 2017)).
fact(tax_case_40, elects_to_itemize_deductions(alice, 2017, false)).
fact(tax_case_40, question_how_much_tax(alice, 2017, 279126)). % Expected: 279126.3. My Calc: 279126.3
fact(tax_case_40, person_dob(alice, date(1980,1,1))). % Not aged/blind
% Alice is "not married" due to legal separation (s7703(a)(2)). Filing status single.

% Case ID: tax_case_26
fact(tax_case_26, person_is_taxpayer(alice)).
fact(tax_case_26, person(bob)).
fact(tax_case_26, person(charlie)).
fact(tax_case_26, employment_period(alice, bob, date(2011,1,1), date(2019,10,10))).
fact(tax_case_26, paid_remuneration_to_employee(alice, bob, 2019, 1513, regular_pay_2019)).
fact(tax_case_26, payment_details(regular_pay_bob_2019, payment(cash, 1513, general_service_in_business))).
fact(tax_case_26, diagnosed_disabled_on(bob, date(2019,10,10))).
fact(tax_case_26, retired_on_date(bob, date(2019,10,10))).
fact(tax_case_26, paid_remuneration_to_employee(alice, bob, 2019, 298, disability_termination_pay)).
fact(tax_case_26, payment_details(disability_term_pay_bob_2019, termination_payment(retirement_for_disability, employer_plan_general, 298))).
fact(tax_case_26, payment_under_employer_plan(alice, employer_plan_general)). % For 3306(b)(10)(B)
fact(tax_case_26, payment_would_not_have_been_made_if_not_terminated(alice, bob, disability_term_pay_bob_2019)). % For 3306(b)(10)
fact(tax_case_26, gross_income(alice, 2019, 567192)).
fact(tax_case_26, adjusted_gross_income(alice, 2019, 567192)).
fact(tax_case_26, lives_together(alice, charlie, 2019)).
fact(tax_case_26, principal_place_of_abode_gt_half_year(charlie, alice, 2019)). % Charlie lives with Alice
fact(tax_case_26, relationship_parent_of(charlie, alice)). % Charlie is Alice's father
fact(tax_case_26, maintains_household_for_parent(alice, charlie, 2019)). % Alice maintains house for Charlie (father)
fact(tax_case_26, furnished_over_half_cost_of_maintaining_household(alice, 2019)). % For HoH
fact(tax_case_26, gross_income(charlie, 2019, 0)).
fact(tax_case_26, takes_standard_deduction(alice, 2019)).
fact(tax_case_26, elects_to_itemize_deductions(alice, 2019, false)).
fact(tax_case_26, question_how_much_tax(alice, 2019, 196056)). % Expected: 196056. (TCJA rates would be different)
                                                            % Assuming 2019 means TCJA SD amounts but pre-TCJA rates from Sec 1.
fact(tax_case_26, person_dob(alice, date(1980,1,1))). % Not aged/blind
fact(tax_case_26, person_dob(charlie, date(1950,1,1))). % Charlie is aged (69 in 2019)
fact(tax_case_26, potential_dependent_of(alice, charlie)).
% Alice status: HoH if Charlie is dependent. Charlie (father) QR: relationship, GI=0. Support by Alice.
fact(tax_case_26, is_not_married(alice, 2019)). % Assumed for HoH
fact(tax_case_26, is_not_surviving_spouse(alice, 2019)). % Assumed for HoH

% Case ID: tax_case_79
fact(tax_case_79, person_is_taxpayer(alice)). % Question is for Bob, but Alice is primary earner
fact(tax_case_79, person_is_taxpayer(bob)).
fact(tax_case_79, married_on_date(alice, bob, date(2017,2,3))).
fact(tax_case_79, spouse_of(alice, bob)).
fact(tax_case_79, files_joint_return(alice, bob, 2020)).
fact(tax_case_79, filing_status(alice, 2020, joint_return)). % And for Bob
fact(tax_case_79, filing_status(bob, 2020, joint_return)).
fact(tax_case_79, gross_income(alice, 2020, 103272)).
fact(tax_case_79, gross_income(bob, 2020, 10)).
fact(tax_case_79, adjusted_gross_income(alice_bob_joint, 2020, 103282)). % Sum of AGI for joint
fact(tax_case_79, takes_standard_deduction(alice_bob_joint, 2020)). % Joint SD
fact(tax_case_79, elects_to_itemize_deductions(alice_bob_joint, 2020, false)).
fact(tax_case_79, question_how_much_tax(bob, 2020, 17402)). % Tax is on joint income. Bob's share is usually not separate.
                                                        % This must mean joint tax. Expected: 9969.3 (TCJA rates different)
                                                        % Using Sec 1 rates: TI = 103282 - 24800 (2020 SD) - 0 (PE) = 78482
                                                        % Tax(78482) MFJ = 5535 + 0.28 * (78482 - 36900) = 5535 + 0.28*41582 = 5535 + 11642.96 = 17177.96.
                                                        % Close to 17402. The SD for 2020 MFJ is $24,800.
fact(tax_case_79, person_dob(alice, date(1980,1,1))). % Not aged/blind
fact(tax_case_79, person_dob(bob, date(1980,1,1))).   % Not aged/blind

% Case ID: tax_case_70
fact(tax_case_70, person_is_taxpayer(alice)).
fact(tax_case_70, person(bob)). % Alice's brother
fact(tax_case_70, relationship_sibling_of(bob, alice)).
fact(tax_case_70, person_dob(bob, date(2014,1,31))). % Bob is 2 in 2016
fact(tax_case_70, lives_at_parents_place(bob, 2016)). % Bob lives with his parents
fact(tax_case_70, gross_income(alice, 2016, 567192)).
fact(tax_case_70, adjusted_gross_income(alice, 2016, 567192)).
fact(tax_case_70, married_on_date(alice, husband_tc70, date(2016,1,12))).
fact(tax_case_70, spouse_of(alice, husband_tc70)).
fact(tax_case_70, gross_income(husband_tc70, 2016, 0)).
fact(tax_case_70, files_separate_return(alice, 2016)). % "does not file a joint return"
fact(tax_case_70, filing_status(alice, 2016, married_filing_separately)).
fact(tax_case_70, itemized_deductions_amount_before_s68(alice, 2016, 100206)).
fact(tax_case_70, takes_itemized_deductions(alice, 2016)).
fact(tax_case_70, elects_to_itemize_deductions(alice, 2016, true)).
fact(tax_case_70, question_how_much_tax(alice, 2016, 178147)).
fact(tax_case_70, person_dob(alice, date(1980,1,1))). % Not aged/blind
% Alice MFS. Brother Bob is not her dependent (lives with parents).
% Husband has no GI, not dependent of another - Alice can claim exemption for husband on MFS return (151(b)).
fact(tax_case_70, is_dependent_of_another_taxpayer(husband_tc70, 2016, alice, false)). % Husband not dependent of someone else

% Case ID: tax_case_63
fact(tax_case_63, person_is_taxpayer(bob)). % Question is for Bob
fact(tax_case_63, person(alice)).
fact(tax_case_63, married_on_date(alice, bob, date(2017,2,3))).
fact(tax_case_63, spouse_of(bob, alice)).
fact(tax_case_63, person_dob(alice, date(1950,3,2))). % Alice is 69 in 2019 (born <=1954 for 65 in 2019) -> AGED
fact(tax_case_63, person_dob(bob, date(1955,3,3))).   % Bob is 64 in 2019 -> NOT AGED
fact(tax_case_63, gross_income(bob, 2019, 113580)).
fact(tax_case_63, adjusted_gross_income(bob_alice_joint, 2019, 113580)). % Alice has no income
fact(tax_case_63, gross_income(alice, 2019, 0)).
fact(tax_case_63, files_joint_return(alice, bob, 2019)).
fact(tax_case_63, filing_status(bob, 2019, joint_return)). % And for Alice
fact(tax_case_63, filing_status(alice, 2019, joint_return)).
fact(tax_case_63, takes_standard_deduction(bob_alice_joint, 2019)).
fact(tax_case_63, elects_to_itemize_deductions(bob_alice_joint, 2019, false)).
fact(tax_case_63, question_how_much_tax(bob, 2019, 20298)). % Must be joint tax. Expected: 10605.6. TCJA different.
                                                        % 2019 MFJ SD: $24400. Alice is aged: +$1300. Total SD: $25700.
                                                        % TI = 113580 - 25700 = 87880.
                                                        % Tax(87880) MFJ (Sec 1 rates): 5535 + 0.28 * (87880 - 36900) = 5535 + 0.28*50980 = 5535 + 14274.4 = 19809.4.
                                                        % Close to 20298.

% Case ID: tax_case_61
fact(tax_case_61, person_is_taxpayer(alice)).
fact(tax_case_61, person(bob)).
fact(tax_case_61, relationship_parent_of(bob, alice)). % Bob is Alice's father
fact(tax_case_61, principal_place_of_abode_together_since(alice, bob, 2012)).
fact(tax_case_61, principal_place_of_abode_gt_half_year(bob, alice, 2015)). % Bob lives with Alice
fact(tax_case_61, gross_income(bob, 2015, 0)). % Bob no income since 2012
fact(tax_case_61, gross_income(alice, 2015, 102268)).
fact(tax_case_61, adjusted_gross_income(alice, 2015, 102268)).
fact(tax_case_61, takes_standard_deduction(alice, 2015)).
fact(tax_case_61, elects_to_itemize_deductions(alice, 2015, false)).
fact(tax_case_61, question_how_much_tax(alice, 2015, 25055)). % Expected: 16755.35. Book higher.
                                                          % Alice HOH with Bob as QR. Bob: father, GI=0, lives with Alice (support assumed).
                                                          % 2015 HOH SD: $9250 (actual). Sec 63 text: $4400.
                                                          % 2015 Pers Ex: $4000 each. Alice + Bob = $8000.
                                                          % TI (using text SD): 102268 - 4400 - 8000 = 90000 - 138 = 89868.
                                                          % Tax(89868) HOH: 17544 + 0.31 * (89868 - 76400) = 17544 + 0.31*13468 = 17544 + 4175.08 = 21719.08
fact(tax_case_61, person_dob(alice, date(1980,1,1))). % Not aged/blind
fact(tax_case_61, person_dob(bob, date(1950,1,1))).   % Bob is aged (65 in 2015)
fact(tax_case_61, is_not_married(alice, 2015)).
fact(tax_case_61, is_not_surviving_spouse(alice, 2015)).
fact(tax_case_61, furnished_over_half_cost_of_maintaining_household(alice, 2015)). % For HoH
fact(tax_case_61, potential_dependent_of(alice, bob)).


% --- Answer Predicates ---

% Helper for yes/no questions
evaluate_statement_truth(StatementHoldsBool, QuestionType, Result) :-
    ( (QuestionType == entailment, StatementHoldsBool == true) -> Result = true
    ; (QuestionType == entailment, StatementHoldsBool == false) -> Result = false
    ; (QuestionType == contradiction, StatementHoldsBool == true) -> Result = false % Contradiction means statement is false
    ; (QuestionType == contradiction, StatementHoldsBool == false) -> Result = true % Contradiction means statement is true (double neg)
    ; Result = prolog_eval_error % Should not happen
    ).

answer(s1_d_iv_neg, Result) :-
    % Question: % Alice has to pay $5683 in taxes for the year 2017 under section 1(d)(iv). Contradiction
    fact(s1_d_iv_neg, taxable_income_for_s1(alice, 2017, TaxableIncome)),
    fact(s1_d_iv_neg, question_expected_tax(ExpectedTax)),
    fact(s1_d_iv_neg, question_type(QuestionType)),
    ( section1:s1_d_iv_tax_calculation(TaxableIncome, CalculatedTaxRaw) ->
        round_to_nearest_dollar(CalculatedTaxRaw, CalculatedTax),
        (CalculatedTax =:= ExpectedTax -> StatementTruth = true ; StatementTruth = false)
    ; StatementTruth = false % Rule s1_d_iv_tax_calculation did not apply (e.g. TI outside bracket)
    ),
    evaluate_statement_truth(StatementTruth, QuestionType, Result).

answer(s3306_c_5_pos, Result) :-
    % Question: % Section 3306(c)(5) applies to Alice employing Bob for the year 2017. Entailment
    fact(s3306_c_5_pos, question_type(QuestionType)),
    % s3306(c)(5) is an *exception* to employment.
    % (A) service by individual for son, daughter, spouse. Bob is Alice's father. Alice employs Bob. This is NOT covered by (A).
    % (B) service by child under 21 for father/mother. Bob is not child of Alice. Bob is father.
    % So, the family exception s3306(c)(5) should NOT apply.
    % If "applies" means "the conditions of the exception are met", then it should be false.
    % If question means "is this service excluded by 3306(c)(5)?", then answer should be true if exception met.
    % "Applies to Alice employing Bob" => The exception is relevant and makes it not employment.
    section3306:s3306_c_5_family_employment_exception_applies(s3306_c_5_pos, alice, bob, 2017, StatementTruth),
    evaluate_statement_truth(StatementTruth, QuestionType, Result).
    % Alice is employer, Bob is employee. Bob is father of Alice.
    % s3306(c)(5)(A): service performed by individual (Bob) in employ of his son, daughter (Alice), or spouse.
    % This means Bob working for Alice (his daughter) IS excluded by (c)(5)(A). So StatementTruth should be true.

answer(s1_c_i_neg, Result) :-
    % Question: % Alice has to pay $265413 in taxes for the year 2017 under section 1(c)(i). Contradiction
    fact(s1_c_i_neg, taxable_income_for_s1(alice, 2017, TaxableIncome)),
    fact(s1_c_i_neg, question_expected_tax(ExpectedTax)),
    fact(s1_c_i_neg, question_type(QuestionType)),
    ( section1:s1_c_i_tax_calculation(TaxableIncome, CalculatedTaxRaw) -> % This is only for the first bracket
        round_to_nearest_dollar(CalculatedTaxRaw, CalculatedTax),
        (CalculatedTax =:= ExpectedTax -> StatementTruth = true ; StatementTruth = false)
    ; StatementTruth = false % TI is $718791, way outside bracket (i)
    ),
    evaluate_statement_truth(StatementTruth, QuestionType, Result).

answer(s1_b_iii_neg, Result) :-
    % Question: % Alice has to pay $11489 in taxes for the year 2017 under section 1(b)(iii). Contradiction
    fact(s1_b_iii_neg, taxable_income_for_s1(alice, 2017, TaxableIncome)),
    fact(s1_b_iii_neg, question_expected_tax(ExpectedTax)),
    fact(s1_b_iii_neg, question_type(QuestionType)),
    ( section1:s1_b_iii_tax_calculation(TaxableIncome, CalculatedTaxRaw) ->
        round_to_nearest_dollar(CalculatedTaxRaw, CalculatedTax),
        (CalculatedTax =:= ExpectedTax -> StatementTruth = true ; StatementTruth = false)
    ; StatementTruth = false % TI is $54775, not in bracket (iii) which starts at $76400.
    ),
    evaluate_statement_truth(StatementTruth, QuestionType, Result).

answer(s152_d_2_F_pos, Result) :-
    % Question: % Alice bears a relationship to Bob under section 152(d)(2)(F). Entailment
    % (F) A brother or sister of the father or mother of the taxpayer. (Alice is potential dependent, Bob is taxpayer)
    % Q: Alice (potential aunt/uncle) bears relationship to Bob (potential nephew/niece = taxpayer).
    % Statute: Individual (Alice) is ... brother/sister of father/mother of Taxpayer (Bob).
    % Charlie is Bob's father. Alice is Charlie's sister. So Alice is Bob's father's sister (Bob's aunt).
    % This means Alice (Individual) IS sister of father (Charlie) of Taxpayer (Bob).
    fact(s152_d_2_F_pos, question_type(QuestionType)),
    section152:s152_d_2_relationship_definition_qr(s152_d_2_F_pos, bob, alice, _AnyYear, RelationshipMet),
    ( clause(section152:s152_d_2_relationship_definition_qr(s152_d_2_F_pos, bob, alice, _AnyYear, true, rule_F), _) ->
        StatementTruth = true % This is a mock check for which sub-rule of d_2 matched. Not easily done without refactor.
                              % We need to check if the specific rule F was the one that made it true.
    ; section152:s152_d_2_relationship_definition_qr(s152_d_2_F_pos, bob, alice, _AnyYear, true), % general check
      % Manually check the logic for (F) here:
      fact(s152_d_2_F_pos, relationship_parent_of(ParentOfBob, bob)), % ParentOfBob = charlie
      fact(s152_d_2_F_pos, relationship_sibling_of(alice, ParentOfBob)), % alice is sibling of charlie
      StatementTruth = true
    ; StatementTruth = false
    ),
    evaluate_statement_truth(RelationshipMet, QuestionType, Result). % Simpler: just check if any QR relationship is met.
                                                                    % The question is specific to (F).
                                                                    % Let's make s152_d_2_F_relationship_met/4
answer(s152_d_2_F_pos, Result) :-
    fact(s152_d_2_F_pos, question_type(QuestionType)),
    ( section152: (
        fact(s152_d_2_F_pos, relationship_parent_of(ParentOfBob, bob)),
        fact(s152_d_2_F_pos, relationship_sibling_of(alice, ParentOfBob))
      ) -> StatementTruth = true
    ; StatementTruth = false
    ),
    evaluate_statement_truth(StatementTruth, QuestionType, Result).


answer(s1_a_1_iii_neg, Result) :- % Case ID in file is s1_a_1_iii_neg, but Q refers to s1(a)(iii)
    % Question: % Alice and her spouse have to pay $44789 in taxes for the year 2017 under section 1(a)(iii). Contradiction
    fact(s1_a_1_iii_neg, taxable_income_for_s1(alice, 2017, TaxableIncome)),
    fact(s1_a_1_iii_neg, question_expected_tax(ExpectedTax)),
    fact(s1_a_1_iii_neg, question_type(QuestionType)),
    ( section1:s1_a_iii_tax_calculation(TaxableIncome, CalculatedTaxRaw) ->
        round_to_nearest_dollar(CalculatedTaxRaw, CalculatedTax),
        (CalculatedTax =:= ExpectedTax -> StatementTruth = true ; StatementTruth = false)
    ; StatementTruth = false % TI is $164612, not in bracket (iii) which is $89150-$140000. It's in bracket (iv).
    ),
    evaluate_statement_truth(StatementTruth, QuestionType, Result).

answer(s3306_b_10_A_neg, Result) :-
    % Question: % Section 3306(b)(10)(A) applies to the payment of $12980 that Alice made in 2019. Contradiction
    fact(s3306_b_10_A_neg, question_type(QuestionType)),
    fact(s3306_b_10_A_neg, payment_details(retirement_bonus_for_bob_2019, PaymentDetails)),
    % (b)(10)(A) is "termination ... because of (i) death, or (ii) retirement for disability".
    % Bob retired because he reached age 65, not disability.
    section3306:s3306_b_10_A_termination_payment_exception_applies(s3306_b_10_A_neg, alice, bob, PaymentDetails, StatementTruth),
    evaluate_statement_truth(StatementTruth, QuestionType, Result).

answer(s63_c_2_B_neg, Result) :-
    % Question: % Under section 63(c)(2)(B), Alice's basic standard deduction in 2017 is equal to $4400. Contradiction
    % s63(c)(2)(B) is for Head of Household ($4400 pre-TCJA). Alice is MFJ.
    fact(s63_c_2_B_neg, question_type(QuestionType)),
    fact(s63_c_2_B_neg, question_expected_bsd(ExpectedBSD)),
    % We need to calculate what the BSD would be IF Alice were HoH and if (c)(2)(B) applied.
    % This is what the question asserts.
    % The question is about the *value* $4400 coming from (c)(2)(B).
    ( tcja_active_standard_deduction(2017) -> HoH_BSD_Amount_from_c2B = 18000 % TCJA HoH
    ; HoH_BSD_Amount_from_c2B = 4400 % Pre-TCJA HoH
    ),
    (HoH_BSD_Amount_from_c2B =:= ExpectedBSD -> StatementTruth = true ; StatementTruth = false),
    % The actual BSD for Alice (MFJ, 2017 pre-TCJA) from s63(c)(2)(A) via (C) is 2 * 3000 = $6000.
    % The assertion is that "Alice's BSD ... IS EQUAL to $4400" and that this is "UNDER s63(c)(2)(B)".
    % The value $4400 *is* from s63(c)(2)(B) (pre-TCJA). But Alice is not HoH.
    % "Alice's basic standard deduction ... is equal to $4400". This statement is false as her BSD is $6000.
    % The reference "Under section 63(c)(2)(B)" implies that $4400 is the value derived from that specific clause.
    % This is true. The question is if *her* BSD is that value.
    section63:s63_c_basic_standard_deduction(s63_c_2_B_neg, alice, 2017, ActualBSD),
    ( ActualBSD =:= ExpectedBSD -> StatementTruthAboutHerBSD = true ; StatementTruthAboutHerBSD = false),
    evaluate_statement_truth(StatementTruthAboutHerBSD, QuestionType, Result).

answer(s3306_b_7_neg, Result) :-
    % Question: % Section 3306(b)(7) applies to the payment Alice made to Bob. Contradiction
    % (b)(7): "remuneration paid in any medium OTHER THAN CASH ... for service not in the course of the employer's trade or business"
    % Payment was $323 CASH. So (b)(7) does not apply.
    fact(s3306_b_7_neg, question_type(QuestionType)),
    fact(s3306_b_7_neg, payment_details(payment_for_painting_house_alice_2017, PaymentDetails)),
    section3306:s3306_b_7_non_business_cash_remuneration_exception_applies(s3306_b_7_neg, alice, bob, PaymentDetails, StatementTruth),
    evaluate_statement_truth(StatementTruth, QuestionType, Result).

answer(s152_c_1_E_pos, Result) :-
    % Question: % Section 152(c)(1)(E) applies to Bob for the year 2019. Entailment
    % (c)(1)(E): QC "who has not filed a joint return ... with the individual's spouse"
    % Bob and Charlie file separate returns. So Bob has NOT filed a joint return. So (E) is met.
    fact(s152_c_1_E_pos, question_type(QuestionType)),
    section152:s152_c_1_E_no_joint_return_qc(s152_c_1_E_pos, bob, 2019, StatementTruth),
    evaluate_statement_truth(StatementTruth, QuestionType, Result).

answer(s2_a_2_B_pos, Result) :-
    % Question: % Section 2(a)(2)(B) applies to Bob in 2014. Entailment
    % (a)(2)(B): "unless, for the taxpayer's taxable year during which his spouse died, a joint return could have been made."
    % If a joint return COULD NOT have been made, then taxpayer is NOT SS.
    % "Applies to Bob" means the condition in (B) makes him NOT a SS.
    % Alice died 2014. Assume they were not NRAs. So JR could have been made.
    % So (B) does NOT apply to make him not SS.
    % If "applies" means "this limitation is triggered", then StatementTruth is true if JR could NOT be made.
    % JR could be made. So limitation is NOT triggered. StatementTruth = false.
    fact(s2_a_2_B_pos, question_type(QuestionType)),
    section2:s2_a_2_B_joint_return_could_not_be_made_ss(s2_a_2_B_pos, bob, 2014, LimitationTriggered),
    % If question means "is Bob subject to the limitation in 2(a)(2)(B) (i.e., is he disqualified as SS by it)?"
    % LimitationTriggered = true means he is disqualified by it.
    % Entailment means we expect LimitationTriggered to be true.
    % But JR *could* be made, so LimitationTriggered = false.
    % This means the question is tricky. "Applies to Bob" could mean "is relevant to Bob's SS status".
    % Let's assume "applies" means the condition *described by* the subsection is true for Bob.
    % The subsection describes a disqualification. Is Bob disqualified by it? No.
    % So, "s2(a)(2)(B) applies" would be false.
    StatementTruth = LimitationTriggered, % If "applies" means the condition (no JR possible) is met.
    evaluate_statement_truth(StatementTruth, QuestionType, Result).

answer(s63_c_3_pos, Result) :-
    % Question: % Under section 63(c)(3), Alice's additional standard deduction in 2017 is equal to $1200. Entailment
    % (c)(3) Additional SD is sum of each additional amount under (f).
    % (f) gives $600 for self (aged), $600 for spouse (aged), if conditions met. Total $1200.
    fact(s63_c_3_pos, question_type(QuestionType)),
    fact(s63_c_3_pos, question_expected_asd(ExpectedASD)),
    section63:s63_f_additional_standard_deduction_amount(s63_c_3_pos, alice, 2017, CalculatedASD),
    (CalculatedASD =:= ExpectedASD -> StatementTruth = true ; StatementTruth = false),
    evaluate_statement_truth(StatementTruth, QuestionType, Result).

answer(s3306_a_1_neg, Result) :-
    % Question: % Alice is an employer under section 3306(a)(1) for the year 2018. Contradiction
    % (a)(1) general employer. Wages for domestic service not counted.
    % Alice paid Bob for domestic service in 2017. Not counted for (a)(1).
    % Alice received wages from Bob in 2017, 2018. This doesn't make Alice an employer.
    % Alice has no other wage payments mentioned for 2017 or 2018.
    % So Alice is not an (a)(1) employer in 2018. Statement "Alice is an employer" is false.
    fact(s3306_a_1_neg, question_type(QuestionType)),
    section3306:s3306_a_1_general_employer(s3306_a_1_neg, alice, 2018, StatementTruth),
    evaluate_statement_truth(StatementTruth, QuestionType, Result).

answer(s7703_b_1_pos, Result) :-
    % Question: % Section 7703(b)(1) applies to Alice for the year 2018. Entailment
    % (b)(1): married, files sep, maintains home for child (>1/2 yr), entitled to deduction for child.
    % All facts seem to align.
    fact(s7703_b_1_pos, question_type(QuestionType)),
    section7703:s7703_b_1_home_for_child(s7703_b_1_pos, alice, 2018, StatementTruth), % (b)(1) is one part of (b)
    evaluate_statement_truth(StatementTruth, QuestionType, Result).

answer(s1_c_iv_pos, Result) :-
    % Question: % Alice has to pay $65445 in taxes for the year 2017 under section 1(c)(iv). Entailment
    fact(s1_c_iv_pos, taxable_income_for_s1(alice, 2017, TaxableIncome)),
    fact(s1_c_iv_pos, question_expected_tax_rounded(ExpectedTax)),
    fact(s1_c_iv_pos, question_type(QuestionType)),
    ( section1:s1_c_iv_tax_calculation(TaxableIncome, CalculatedTaxRaw) ->
        round_to_nearest_dollar(CalculatedTaxRaw, CalculatedTax),
        (CalculatedTax =:= ExpectedTax -> StatementTruth = true ; StatementTruth = false)
    ; StatementTruth = false % TI is $210204, which is in bracket (iv) ($115k-$250k)
    ),
    evaluate_statement_truth(StatementTruth, QuestionType, Result).

answer(s3306_b_pos, Result) :-
    % Question: % Section 3306(b) applies to the money paid by Alice to Bob for the year 2018. Entailment
    % s3306(b) defines "wages". "Applies" means "is this money 'wages' under 3306(b)?"
    % $2325 cash for dog walking. Assuming this is "employment" and no exceptions apply.
    fact(s3306_b_pos, question_type(QuestionType)),
    fact(s3306_b_pos, paid_remuneration_to_employee(alice, bob, 2018, 2325, PaymentDetails)),
    section3306:s3306_b_is_futa_wage(s3306_b_pos, alice, bob, 2018, 2325, PaymentDetails, StatementTruth),
    evaluate_statement_truth(StatementTruth, QuestionType, Result).

answer(s1_a_1_pos, Result) :- % Case ID in file is s1_a_1_pos, refers to s1(a) generally
    % Question: % Alice and her husband have to pay $2600 in taxes for the year 2017 under section 1(a). Entailment
    fact(s1_a_1_pos, taxable_income_for_s1(alice, 2017, TaxableIncome)),
    fact(s1_a_1_pos, question_expected_tax_rounded(ExpectedTax)),
    fact(s1_a_1_pos, question_type(QuestionType)),
    section1:s1_a_calculate_tax(TaxableIncome, CalculatedTaxRaw), % Use general s1(a) calc
    round_to_nearest_dollar(CalculatedTaxRaw, CalculatedTax),
    (CalculatedTax =:= ExpectedTax -> StatementTruth = true ; StatementTruth = false),
    evaluate_statement_truth(StatementTruth, QuestionType, Result).

answer(s68_b_1_A_neg, Result) :-
    % Question: % Section 68(b)(1)(A) applies to Alice for 2016. Contradiction
    % s68(b)(1)(A) is applicable amount for Joint Return or Surviving Spouse.
    % Alice is MFS in 2016. So (A) does not apply to her directly for setting her threshold.
    % "Applies to Alice" means "is Alice's situation one described by (A)?" No.
    fact(s68_b_1_A_neg, question_type(QuestionType)),
    ( ( fact(s68_b_1_A_neg, files_joint_return(alice, _SpouseID, 2016)) ;
        section2:s2_a_is_surviving_spouse(s68_b_1_A_neg, alice, 2016, true)
      ) -> StatementTruth = true
    ; StatementTruth = false
    ),
    evaluate_statement_truth(StatementTruth, QuestionType, Result).

% --- "How much tax" Questions ---

% Helper to get Taxable Income (TI) for a taxpayer for a given year.
get_taxable_income(CaseID, TaxpayerID, TaxYear, TaxableIncome) :-
    % If TI is directly stated for S1, use that.
    ( fact(CaseID, taxable_income_for_s1(TaxpayerID, TaxYear, TI_Direct)) ->
        TaxableIncome = TI_Direct
    ; % Otherwise, calculate it using Sec 63
      fact(CaseID, filing_status(TaxpayerID, TaxYear, FilingStatus)), % Need filing status for joint AGI etc.
      ( FilingStatus == joint_return, fact(CaseID, spouse_of(TaxpayerID, SpouseID)) ->
            % For joint return, AGI might be a joint fact or sum of individual AGIs
            ( fact(CaseID, adjusted_gross_income(TaxpayerID_SpouseID_joint, TaxYear, AGI)) -> true % Joint AGI fact
            ; fact(CaseID, adjusted_gross_income(TaxpayerID, TaxYear, AGI_TP)),
              fact(CaseID, adjusted_gross_income(SpouseID, TaxYear, AGI_Spouse)),
              AGI is AGI_TP + AGI_Spouse
            ),
            section63:s63_taxable_income(CaseID, TaxpayerID_SpouseID_joint, TaxYear, TaxableIncome) % Use a joint entity for TI calc
      ; section63:s63_taxable_income(CaseID, TaxpayerID, TaxYear, TaxableIncome)
      )
    ),
    % Ensure TI is not negative for tax calculation purposes (tax floor is 0).
    ( TaxableIncome < 0 -> TaxableIncome = 0 ; true ).


answer(tax_case_89, Result) :-
    % Question: % How much tax does Alice have to pay in 2018? $0
    fact(tax_case_89, question_how_much_tax(alice, 2018, ExpectedTax)),
    % Alice MFS, 2018 (TCJA SD rules, PE=0)
    % AGI = 3200
    % SD for MFS (TCJA) = $12000. Alice is blind: +$1300 (MFS is "not married" for $750/$600 higher amount logic, but MFS uses $600 for spouse, $750 for unmarried single/HoH. Text: "(3) Higher amount for certain unmarried individuals. In the case of an individual who is not married and is not a surviving spouse". MFS is married.)
    % Let's re-check s63_f_get_base_per_condition_amount for MFS. MFS is married. So base is $600.
    % Alice blind: +$600.
    % SD = $12000 (base MFS) + $600 (blind) = $12600.
    % PE = $0.
    % TI = AGI - SD - PE = 3200 - 12600 - 0 = -9400. TaxableIncome for S1 is $0.
    % Tax on $0 is $0.
    get_taxable_income(tax_case_89, alice, 2018, TaxableIncomeForS1),
    section1:s1_tax_imposed(tax_case_89, alice, 2018, CalculatedTax), % s1_tax_imposed needs TI fact
    Result = CalculatedTax. %Direct output for "how much"
    % (CalculatedTax =:= ExpectedTax -> Result = true ; Result = false). % For comparison if needed


answer(tax_case_13, Result) :-
    % Question: % How much tax does Bob have to pay in 2017? $8710 (book) vs $5156 (my Sec 1 rates)
    fact(tax_case_13, question_how_much_tax(bob, 2017, _ExpectedTax)),
    % Bob, 2017 (pre-TCJA rates, PE exists, pre-TCJA SD)
    % AGI = 53249
    % Filing Status: Single (Alice is adult child, assumed QC for dependency)
    % SD (Single, pre-TCJA from text): $3000. Alice is Bob's dependent (QC).
    % PE: Bob for himself ($2000), Alice as dependent ($2000). Total $4000. (No phaseout at this AGI)
    % TI = 53249 - 3000 - 4000 = 46249.
    % Tax (Single, Sec 1 rates) on $46249:
    % Bracket 1: 22100 * 0.15 = 3315
    % Bracket 2: (46249 - 22100) * 0.28 = 24149 * 0.28 = 6761.72
    % Total Tax = 3315 + 6761.72 = 10076.72. Rounded: $10077.
    % The expected $8710 suggests different SD/PE/rates. Sticking to my encoded rules.
    get_taxable_income(tax_case_13, bob, 2017, TaxableIncomeForS1),
    section1:s1_tax_imposed(tax_case_13, bob, 2017, CalculatedTax),
    Result = CalculatedTax.

answer(tax_case_40, Result) :-
    % Question: % How much tax does Alice have to pay in 2017? $279126
    fact(tax_case_40, question_how_much_tax(alice, 2017, _ExpectedTax)),
    % Alice, 2017 (pre-TCJA rates, PE, pre-TCJA SD)
    % AGI = 756420
    % Legally separated -> Not Married -> Single (not HoH, not SS)
    % SD (Single, pre-TCJA text): $3000.
    % PE: Alice for herself ($2000). Bob (father) is not her dependent from info (no GI=0, support test).
    % PE Phaseout for Alice (Single, AGI $756420):
    %   Threshold (s68(b) via s151(d)(3)): Single $250,000 (using s68(b)(C) directly as per 151(d)(3)(A))
    %   Excess AGI = 756420 - 250000 = 506420
    %   Increments = ceil(506420 / 2500) = ceil(202.568) = 203
    %   Percentage points = 203 * 2 = 406. Percentage = 406% -> Capped at 100%.
    %   PE = $2000 * (1 - 1.00) = $0.
    % TI = 756420 - 3000 - 0 = 753420.
    % Tax (Single, Sec 1 rates) on $753420:
    % Bracket 5: 79772 + 0.396 * (753420 - 250000) = 79772 + 0.396 * 503420
    %            = 79772 + 199354.32 = 279126.32. Rounded: $279126. Matches expected.
    get_taxable_income(tax_case_40, alice, 2017, TaxableIncomeForS1),
    section1:s1_tax_imposed(tax_case_40, alice, 2017, CalculatedTax),
    Result = CalculatedTax.

answer(tax_case_26, Result) :-
    % Question: % How much tax does Alice have to pay in 2019? $196056
    fact(tax_case_26, question_how_much_tax(alice, 2019, _ExpectedTax)),
    % Alice, 2019 (TCJA SD, PE=0, Sec 1 pre-TCJA rates)
    % AGI = 567192
    % Filing Status: HoH. Charlie (father) lives with her, she maintains home, Charlie GI=0. Charlie is QR.
    %   Charlie is aged (69).
    % SD (HoH, TCJA): $18000.
    % Additional SD for Alice (not aged/blind): $0.
    %   Additional SD for Charlie (QR, aged): This is tricky. s63(f) is for "taxpayer" and "spouse".
    %   A dependent doesn't grant the taxpayer additional SD unless the dependent is the spouse.
    %   So, ASD = $0. Total SD = $18000.
    % PE = $0.
    % TI = 567192 - 18000 - 0 = 549192.
    % Tax (HoH, Sec 1 rates) on $549192:
    % Bracket 5: 77485 + 0.396 * (549192 - 250000) = 77485 + 0.396 * 299192
    %            = 77485 + 118480.032 = 195965.032. Rounded: $195965. Close to $196056.
    % Difference might be HoH ASD for qualifying person if that was a rule, or exact HoH SD amount for 2019.
    % Assuming my interpretation of ASD (only for TP and spouse) is correct.
    get_taxable_income(tax_case_26, alice, 2019, TaxableIncomeForS1),
    fact(tax_case_26, filing_status(alice, 2019, head_of_household)), % Ensure this is set for s1
    section1:s1_tax_imposed(tax_case_26, alice, 2019, CalculatedTax),
    Result = CalculatedTax.

answer(tax_case_79, Result) :-
    % Question: % How much tax does Bob have to pay in 2020? $17402 (This must be joint tax)
    fact(tax_case_79, question_how_much_tax(bob, 2020, _ExpectedTax)), % Bob is one of the joint filers
    % Alice & Bob, 2020 (TCJA SD, PE=0, Sec 1 pre-TCJA rates)
    % Joint AGI = 103272 + 10 = 103282.
    % Filing Status: MFJ.
    % SD (MFJ, TCJA 2020 - using 2018-2025 base): $24000 (actual 2020 was $24800). Let's use my encoded $24000.
    %   Neither aged/blind. ASD = $0. Total SD = $24000.
    % PE = $0.
    % TI = 103282 - 24000 - 0 = 79282.
    % Tax (MFJ, Sec 1 rates) on $79282:
    % Bracket 2: 5535 + 0.28 * (79282 - 36900) = 5535 + 0.28 * 42382
    %            = 5535 + 11866.96 = 17401.96. Rounded: $17402. Matches expected.
    % Need to ensure facts for joint AGI and SD are handled correctly.
    % The get_taxable_income will use TaxpayerID_SpouseID_joint.
    fact(tax_case_79, taxpayer_is_joint_filer_representative(bob, alice_bob_joint, 2020)), % Link Bob to the joint entity
    get_taxable_income(tax_case_79, alice_bob_joint, 2020, TaxableIncomeForS1),
    fact(tax_case_79, filing_status(alice_bob_joint, 2020, joint_return)), % Ensure joint status for S1
    fact(tax_case_79, taxable_income_for_s1(alice_bob_joint, 2020, TaxableIncomeForS1)), % Make TI available for s1
    section1:s1_tax_imposed(tax_case_79, alice_bob_joint, 2020, CalculatedTax),
    Result = CalculatedTax.

answer(tax_case_70, Result) :-
    % Question: % How much tax does Alice have to pay in 2016? $178147
    fact(tax_case_70, question_how_much_tax(alice, 2016, _ExpectedTax)),
    % Alice, 2016 (pre-TCJA rates, PE, pre-TCJA SD, Sec 68 itemized deduction limit)
    % AGI = 567192
    % Filing Status: MFS.
    % Itemized Deductions (before limit) = $100206.
    %   Sec 68 limit (MFS, 2016): Threshold = $150,000 (1/2 of MFJ $300k, assuming 2016 uses these numbers).
    %   Excess AGI = 567192 - 150000 = 417192.
    %   Reduction1 (3%) = 0.03 * 417192 = 12515.76.
    %   Reduction2 (80%) = 0.80 * 100206 = 80164.8.
    %   Lesser reduction = 12515.76.
    %   Allowable Itemized = 100206 - 12515.76 = 87690.24.
    % PE: Alice ($2000), Husband ($2000, no GI, not dep of another). Total $4000.
    %   PE Phaseout (MFS, AGI $567192):
    %   Threshold (s68(b) for MFS): $150000.
    %   Excess AGI = 567192 - 150000 = 417192.
    %   Increment for MFS ($1250): ceil(417192 / 1250) = ceil(333.7536) = 334.
    %   Percentage points = 334 * 2 = 668. Percentage = 668% -> Capped at 100%.
    %   PE = $4000 * (1 - 1.00) = $0.
    % TI = AGI - Itemized - PE = 567192 - 87690.24 - 0 = 479501.76.
    % Tax (MFS, Sec 1 rates) on $479501.76:
    % Bracket 5: 37764.25 + 0.396 * (479501.76 - 125000) = 37764.25 + 0.396 * 354501.76
    %            = 37764.25 + 140382.697 = 178146.947. Rounded: $178147. Matches expected.
    get_taxable_income(tax_case_70, alice, 2016, TaxableIncomeForS1),
    section1:s1_tax_imposed(tax_case_70, alice, 2016, CalculatedTax),
    Result = CalculatedTax.

answer(tax_case_63, Result) :-
    % Question: % How much tax does Bob have to pay in 2019? $20298 (Joint tax)
    fact(tax_case_63, question_how_much_tax(bob, 2019, _ExpectedTax)), % Bob is representative
    % Alice & Bob, 2019 (TCJA SD, PE=0, Sec 1 pre-TCJA rates)
    % Joint AGI = 113580.
    % Filing Status: MFJ.
    % SD (MFJ, TCJA): $24000.
    %   Alice is aged (69): +$1300 (MFJ aged/blind add-on). Bob not aged.
    %   Total SD = 24000 + 1300 = $25300.
    % PE = $0.
    % TI = 113580 - 25300 - 0 = 88280.
    % Tax (MFJ, Sec 1 rates) on $88280:
    % Bracket 2: 5535 + 0.28 * (88280 - 36900) = 5535 + 0.28 * 51380
    %            = 5535 + 14386.4 = 19921.4. Rounded: $19921.
    % Expected $20298. Difference $377. Could be due to exact 2019 SD amounts ($24400 MFJ, $1300 aged).
    % If SD = 24400+1300 = 25700. TI = 113580 - 25700 = 87880.
    % Tax on 87880 = 5535 + 0.28 * (87880-36900) = 5535 + 0.28*50980 = 5535+14274.4 = 19809.4. Still off.
    % Let's use my coded values.
    fact(tax_case_63, taxpayer_is_joint_filer_representative(bob, bob_alice_joint_tc63, 2019)),
    get_taxable_income(tax_case_63, bob_alice_joint_tc63, 2019, TaxableIncomeForS1),
    fact(tax_case_63, filing_status(bob_alice_joint_tc63, 2019, joint_return)),
    fact(tax_case_63, taxable_income_for_s1(bob_alice_joint_tc63, 2019, TaxableIncomeForS1)),
    section1:s1_tax_imposed(tax_case_63, bob_alice_joint_tc63, 2019, CalculatedTax),
    Result = CalculatedTax.

answer(tax_case_61, Result) :-
    % Question: % How much tax does Alice have to pay in 2015? $25055
    fact(tax_case_61, question_how_much_tax(alice, 2015, _ExpectedTax)),
    % Alice, 2015 (pre-TCJA rates, PE, pre-TCJA SD)
    % AGI = 102268.
    % Filing Status: HoH (Bob is father, lives with Alice, GI=0, Alice provides support - assumed).
    % SD (HoH, pre-TCJA text): $4400.
    %   Bob (father, dependent) is aged (65 in 2015). Alice not aged/blind.
    %   ASD for HoH with aged dependent? No, ASD is for taxpayer/spouse. So ASD = $0.
    %   Total SD = $4400.
    % PE: Alice ($2000), Bob ($2000). Total $4000. (No phaseout at this AGI for HoH).
    %   HoH PE Phaseout threshold (s68(b) via 151(d)(3)): $275,000. AGI is below.
    % TI = 102268 - 4400 - 4000 = 93868.
    % Tax (HoH, Sec 1 rates) on $93868:
    % Bracket 3: 17544 + 0.31 * (93868 - 76400) = 17544 + 0.31 * 17468
    %            = 17544 + 5415.08 = 22959.08. Rounded: $22959.
    % Expected $25055. Still a gap.
    get_taxable_income(tax_case_61, alice, 2015, TaxableIncomeForS1),
    fact(tax_case_61, filing_status(alice, 2015, head_of_household)),
    section1:s1_tax_imposed(tax_case_61, alice, 2015, CalculatedTax),
    Result = CalculatedTax.